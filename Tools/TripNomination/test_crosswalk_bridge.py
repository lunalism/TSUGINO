"""Invented archives/mappings only; actual in-process Swift ABI exercised."""
import copy
import ctypes
import csv
import hashlib
import io
import json
import os
from pathlib import Path
import struct
import tempfile
import unittest
from unittest import mock

import crosswalk_bridge as b
from test_occurrences import package

LIB = Path(__file__).resolve().parents[1] / "StaticDataIntake/.build/libtsugino-crosswalk.dylib"


class BridgeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.library = b.Library(str(LIB), hashlib.sha256(LIB.read_bytes()).hexdigest())

    @classmethod
    def tearDownClass(cls):
        cls.library.close()

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="synthetic-bridge-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.values = ["syn-one","syn-two"] * 7
        self.archive = self.root / "invented.zip"
        self.install_archive()
        self.source = "SYN/bridge"
        self.sid = "stn_0000000000000001"
        self.registry = dict(schemaVersion=2, revision=6, entities=[dict(id=self.sid,state="active")], references=[])
        for value in dict.fromkeys(self.values):
            self.registry["references"].append(dict(canonicalID=self.sid,sourceID=self.source,namespace="gtfs.stop_id",value=value,
                status=dict(state="active"),firstSeenInputSHA256=self.archive_hash,
                provenance=dict(inputSHA256=self.archive_hash,member=dict(name="stops.txt",sha256="b"*64),table="stops",field="stop_id",providerKey=value),originalNames=[],attachedBy="syn-review"))
        self.reviews = dict(schemaVersion=1,inputs=[dict(gtfsSourceID=self.source,gtfsArchiveSHA256=self.archive_hash),dict(gtfsSourceID="SYN/other",gtfsArchiveSHA256="d"*64)],decisions=[],stations=[dict(reviewID="syn-review",stationID=self.sid,sides=[dict(gtfsSourceID=self.source,stops=list(dict.fromkeys(self.values)))])])
        self.config = dict(registryPath=str(self.root/"registry.json"),reviewsPath=str(self.root/"reviews.json"),registrySHA256="",reviewsSHA256="",registryRevision=6,sourceID=self.source,inputSHA256=self.archive_hash,namespace="gtfs.stop_id",expectedCount=14)
        self.write_mapping()

    def install_archive(self, profiles=None, count=14, inversions=False):
        text = io.StringIO(newline="")
        w = csv.writer(text,lineterminator="\n"); w.writerow(["trip_id","stop_id","stop_sequence","pickup_type","drop_off_type"])
        for i in range(count):
            pickup,drop = profiles[i] if profiles else ("0","0")
            w.writerow(["t",self.values[i%len(self.values)],count-i if inversions else 3*i+1,pickup,drop])
        self.raw_archive = package(text.getvalue().encode("utf-8")); self.archive.write_bytes(self.raw_archive)
        self.archive_hash = hashlib.sha256(self.raw_archive).hexdigest()

    def write_mapping(self):
        for obj,role,path in [(self.registry,"registrySHA256",self.config["registryPath"]),(self.reviews,"reviewsSHA256",self.config["reviewsPath"])]:
            raw=json.dumps(obj,ensure_ascii=True,separators=(",",":")).encode();Path(path).write_bytes(raw);os.chmod(path,0o600)
            self.config[role]=hashlib.sha256(raw).hexdigest()

    def run_bridge(self, library=None, **kw):
        args=dict(archive=str(self.archive),expected_size=len(self.raw_archive),expected_sha256=self.archive_hash,label="N01",expected_count=14,expected_inversions=0,profile=b.PROFILE,configuration=self.config,library=library or self.library)
        args.update(kw);return b.run(**args)

    def ffi(self, frame, config=None):
        return self.library.verify(config or self.config,frame)

    def test_complete_repeat_shared_station_no_persistence_or_private_output(self):
        before={p.name:p.read_bytes() for p in self.root.iterdir()}
        with mock.patch("subprocess.Popen",side_effect=AssertionError("subprocess")),mock.patch("socket.socket",side_effect=AssertionError("network")):
            first=self.run_bridge();second=self.run_bridge()
        self.assertEqual(first,second);self.assertTrue(first["readyForPrivateCrosswalk"])
        self.assertEqual(first["requestedMappingCount"],14);self.assertEqual(first["resolvedMappingCount"],14);self.assertEqual(first["repeatedOccurrenceCount"],12)
        self.assertEqual(first["passengerProfileMatchedCount"],14)
        output=json.dumps(first)
        for secret in self.values+[self.sid,"b"*64]:self.assertNotIn(secret,output)
        self.assertEqual(before,{p.name:p.read_bytes() for p in self.root.iterdir()})

    def test_corrected_diagnostics_distinguish_fourteen_occurrence_failure_classes(self):
        # Invented unique occurrences: no assertion about the real failure cause.
        self.values = ["syn-causal-" + str(i) for i in range(14)]
        self.install_archive()
        template = copy.deepcopy(self.registry["references"][0])
        self.registry["references"] = []
        for value in self.values:
            ref = copy.deepcopy(template)
            ref.update(value=value, firstSeenInputSHA256=self.archive_hash)
            ref["provenance"].update(inputSHA256=self.archive_hash, providerKey=value)
            self.registry["references"].append(ref)
        self.reviews["inputs"][0]["gtfsArchiveSHA256"] = self.archive_hash
        self.reviews["stations"][0]["sides"][0]["stops"] = self.values[:]
        self.config["inputSHA256"] = self.archive_hash
        baseline_r, baseline_e = copy.deepcopy(self.registry), copy.deepcopy(self.reviews)
        self.write_mapping()
        self.assertTrue(self.run_bridge()["readyForPrivateCrosswalk"])
        for cause in ("producerAuthority", "missingClosure", "reviewIDMismatch", "wrongTarget",
                      "missingDependency", "sourceRevision", "inactive", "memberDisagreement"):
            with self.subTest(cause=cause):
                self.registry, self.reviews = copy.deepcopy(baseline_r), copy.deepcopy(baseline_e)
                if cause == "producerAuthority":
                    for i, ref in enumerate(self.registry["references"]): ref["attachedBy"] = "syn-review:" + str(i)
                elif cause == "missingClosure": self.reviews["stations"] = []
                elif cause == "reviewIDMismatch": self.reviews["stations"][0]["reviewID"] = "syn-other-review"
                elif cause == "wrongTarget": self.reviews["stations"][0]["stationID"] = "stn_0000000000000002"
                elif cause == "missingDependency": self.reviews["stations"][0]["sides"][0]["stops"].append("syn-unavailable")
                elif cause == "sourceRevision":
                    for ref in self.registry["references"]: ref["provenance"]["inputSHA256"] = "c" * 64
                elif cause == "inactive":
                    for ref in self.registry["references"]: ref["status"] = dict(state="absent")
                elif cause == "memberDisagreement": self.registry["references"][0]["provenance"]["member"]["sha256"] = "f" * 64
                self.write_mapping()
                result = self.run_bridge()
                succeeds = cause in ("producerAuthority", "reviewIDMismatch")
                evidence = "matched" if succeeds else ("notEvaluated" if cause in ("sourceRevision", "inactive") else "mismatched")
                member = "notEvaluated" if cause in ("sourceRevision", "inactive") else ("mismatched" if cause == "memberDisagreement" else "matched")
                for name, value in dict(registryIdentityMatched=True, requestedMappingCount=14,
                    resolvedMappingCount=14 if succeeds else 0, heldMappingCount=0 if succeeds else 14,
                    reviewEvidenceMatched=evidence, memberIdentityConsistent=member,
                    readyForPrivateCrosswalk=succeeds, repeatedOccurrenceCount=0,
                    sourceOrderPreserved=True, passengerProfileMatchedCount=14).items():
                    self.assertEqual(result[name], value)

    def test_actual_ffi_unicode_and_delimiter_keys_resolve_exactly(self):
        self.values=(["é","e\u0301","syn,|\nvalue"]*5)[:14]
        self.install_archive()
        base=copy.deepcopy(self.registry["references"][0]);self.registry["references"]=[]
        for value in dict.fromkeys(self.values):
            ref=copy.deepcopy(base);ref["value"]=value;ref["firstSeenInputSHA256"]=self.archive_hash
            ref["provenance"]["inputSHA256"]=self.archive_hash;ref["provenance"]["providerKey"]=value
            self.registry["references"].append(ref)
        self.reviews["inputs"][0]["gtfsArchiveSHA256"]=self.archive_hash
        self.reviews["stations"][0]["sides"][0]["stops"]=list(dict.fromkeys(self.values))
        self.config["inputSHA256"]=self.archive_hash;self.write_mapping()
        result=self.run_bridge();self.assertTrue(result["readyForPrivateCrosswalk"])
        self.assertEqual(result["repeatedOccurrenceCount"],11)

    def test_actual_ffi_independent_member_and_review_statuses(self):
        # Separate internally consistent assignments, disagreeing requested members.
        self.registry["entities"].append(dict(id="stn_0000000000000002",state="active"))
        self.registry["references"][1]["canonicalID"] = "stn_0000000000000002"
        self.registry["references"][1]["attachedBy"] = "syn-distinct-introducing-authority"
        self.registry["references"][1]["provenance"]["member"]["sha256"] = "f" * 64
        self.reviews["stations"] = [dict(reviewID="syn-assignment-"+str(i),stationID=ref["canonicalID"],
            sides=[dict(gtfsSourceID=self.source,stops=[ref["value"]])]) for i,ref in enumerate(self.registry["references"])]
        self.write_mapping()
        result = self.run_bridge()
        self.assertEqual(result["resolvedMappingCount"],0)
        self.assertEqual(result["heldMappingCount"],14)
        self.assertEqual(result["reviewEvidenceMatched"],"matched")
        self.assertEqual(result["memberIdentityConsistent"],"mismatched")
        self.assertFalse(result["readyForPrivateCrosswalk"])
        self.registry["references"][1]["provenance"]["member"]["sha256"] = "b" * 64
        self.reviews["stations"] = []
        self.write_mapping()
        result = self.run_bridge()
        self.assertEqual(result["memberIdentityConsistent"],"matched")
        self.assertEqual(result["reviewEvidenceMatched"],"mismatched")

    def test_wrapper_rejects_invalid_abi_diagnostic_words(self):
        original = self.library.call
        def fake(words, status):
            def call(config, config_length, frame, frame_length, output, output_count):
                for i, word in enumerate(words): output[i] = word
                return status
            return call
        try:
            for words, status in [([14,14,0,12,1,3,1,1],0),([14,14,0,12,1,0,1,1],0),
                                  ([14,14,0,12,0,1,1,1],0),([14,0,14,12,1,1,1,2],1)]:
                self.library.call = fake(words,status)
                with self.assertRaisesRegex(b.BridgeError,"invalidBridgeResult"):
                    self.ffi(b.encode_keys(self.values))
        finally:
            self.library.call = original

    def test_owner_cli_emits_only_aggregate_and_qualifies_terminal(self):
        from test_session import MemoryTerminal
        terminal=MemoryTerminal([])
        argv=["--archive",str(self.archive),"--expected-size",str(len(self.raw_archive)),"--expected-sha256",self.archive_hash,
              "--label","N01","--profile",b.PROFILE,"--library",str(LIB),"--library-sha256",hashlib.sha256(LIB.read_bytes()).hexdigest(),
              "--registry",self.config["registryPath"],"--registry-sha256",self.config["registrySHA256"],
              "--reviews",self.config["reviewsPath"],"--reviews-sha256",self.config["reviewsSHA256"],
              "--source",self.source,"--input-sha256",self.archive_hash,"--namespace","gtfs.stop_id",
              "--registry-revision","6","--expected-count","14","--expected-inversions","0"]
        with mock.patch.object(b,"_Terminal",return_value=terminal):self.assertEqual(b.main(argv),0)
        text="".join(terminal.output)
        for secret in self.values+[self.sid,"b"*64,str(self.archive)]:self.assertNotIn(secret,text)
        self.assertTrue(json.loads(text)["readyForPrivateCrosswalk"])
        stderr=io.StringIO()
        import contextlib
        with mock.patch.object(b,"_Terminal",side_effect=b.SessionError("invented")),mock.patch.object(b,"read_occurrences") as reader,contextlib.redirect_stderr(stderr):
            self.assertEqual(b.main(argv),1);reader.assert_not_called()
        self.assertNotIn(str(self.archive),stderr.getvalue())

    def test_missing_profile_columns_and_NUL_do_not_reach_mapping(self):
        for data in [b"trip_id,stop_id,stop_sequence\n"+b"t,syn-one,1\n",b"trip_id,stop_id,stop_sequence,pickup_type,drop_off_type\nt,syn\0one,1,0,0\n"]:
            self.raw_archive=package(data);self.archive.write_bytes(self.raw_archive);self.archive_hash=hashlib.sha256(self.raw_archive).hexdigest()
            self.config["inputSHA256"]=self.archive_hash;lib=mock.Mock()
            with self.assertRaises(b.BridgeError):self.run_bridge(lib)
            lib.verify.assert_not_called()

    def test_profile_invalid_prevents_mapping_call(self):
        for pair in [("1","1"),("0","1"),("","0"),("2","0"),("0","")]:
            profiles=[("0","0")]*14;profiles[5]=pair;self.install_archive(profiles)
            self.config["inputSHA256"]=self.archive_hash
            lib=mock.Mock()
            with self.assertRaisesRegex(b.BridgeError,"passengerProfileMismatch"):self.run_bridge(lib)
            lib.verify.assert_not_called()

    def test_count_and_inversions_prevent_mapping_call(self):
        for count,inversions in [(13,False),(14,True)]:
            self.install_archive(count=count,inversions=inversions);self.config["inputSHA256"]=self.archive_hash;lib=mock.Mock()
            with self.assertRaisesRegex(b.BridgeError,"unexpectedOccurrences"):self.run_bridge(lib)
            lib.verify.assert_not_called()

    def test_reader_once_and_key_memory_wiped_after_call(self):
        captured=[]
        lib=mock.Mock()
        def verify(config,frame):captured.append(frame);return {"readyForPrivateCrosswalk":True}
        lib.verify.side_effect=verify
        with mock.patch.object(b,"read_occurrences",wraps=b.read_occurrences) as reader:self.run_bridge(lib);self.assertEqual(reader.call_count,1)
        self.assertEqual(captured[0],bytearray(len(captured[0])))

    def test_failure_memory_wiped_no_retry(self):
        captured=[];lib=mock.Mock()
        def fail(config,frame):captured.append(frame);raise b.BridgeError("inventedFailure")
        lib.verify.side_effect=fail
        with mock.patch.object(b,"read_occurrences",wraps=b.read_occurrences) as reader:
            with self.assertRaises(b.BridgeError):self.run_bridge(lib)
            self.assertEqual(reader.call_count,1)
        self.assertFalse(any(captured[0]))

    def test_framing_exact_unicode_delimiters_order_duplicates(self):
        values=["é","e\u0301","comma,\n|\0x"," white ","é"]
        frame=b.encode_keys(values);offset=8;decoded=[]
        self.assertEqual(struct.unpack(">II",frame[:8]),(2,5))
        for _ in values:
            length=struct.unpack(">I",frame[offset:offset+4])[0];offset+=4
            decoded.append(bytes(frame[offset:offset+length]).decode());offset+=length
        self.assertEqual([x.encode() for x in decoded],[x.encode() for x in values]);self.assertEqual(offset,len(frame))
        # Real Swift parser reaches mapping checks instead of rejecting this framing.
        config=dict(self.config,expectedCount=5)
        result=self.ffi(frame,config);self.assertEqual(result["heldMappingCount"],5)

    def test_actual_ffi_rejects_bad_frames(self):
        good=b.encode_keys(self.values)
        frames=[bytearray(),bytearray(struct.pack(">II",1,14)),bytearray(struct.pack(">II",2,65)),bytearray(struct.pack(">III",2,1,0xffffffff)),good+bytearray(b"x"),good[:-1],bytearray(struct.pack(">III",2,1,1)+b"\xff"),bytearray(struct.pack(">III",2,1,4097)+b"x"*4097)]
        for frame in frames:
            with self.subTest(length=len(frame)),self.assertRaises(b.BridgeError):self.ffi(frame)

    def test_encoding_bounds(self):
        for values in [[],["x"]*65,["x"*4097],[""],["\ud800"]]:
            with self.assertRaises(b.BridgeError):b.encode_keys(values)
        self.assertLessEqual(len(b.encode_keys(["x"*4096]*64)),b.MAX_FRAME_BYTES)

    def test_absent_and_inactive_mappings_hold(self):
        for mode in ["absent","inactive"]:
            reg=copy.deepcopy(self.registry)
            if mode=="absent":reg["references"]=[x for x in reg["references"] if x["value"]!="syn-two"]
            else:reg["references"][0]["status"]={"state":"absent"}
            original=self.registry;self.registry=reg;self.write_mapping()
            result=self.run_bridge();self.assertFalse(result["readyForPrivateCrosswalk"]);self.assertGreater(result["heldMappingCount"],0)
            self.registry=original

    def test_registry_hash_and_revision_fail(self):
        for field,value in [("registrySHA256","0"*64),("registryRevision",7),("reviewsSHA256","0"*64)]:
            config=dict(self.config);config[field]=value
            with self.assertRaisesRegex(b.BridgeError,"artifactIdentityMismatch"):self.ffi(b.encode_keys(self.values),config)

    def test_provenance_failures_hold(self):
        original=copy.deepcopy(self.registry)
        for mode in ["archive","member","inconsistent","table","field"]:
            self.registry=copy.deepcopy(original);ref=self.registry["references"][0];p=ref["provenance"]
            if mode=="archive":p["inputSHA256"]="c"*64
            elif mode=="member":p["member"]["name"]="routes.txt"
            elif mode=="inconsistent":p["member"]["sha256"]="f"*64
            elif mode=="table":p["table"]="routes"
            elif mode=="field":p["field"]="stop_code"
            self.write_mapping();result=self.run_bridge()
            self.assertFalse(result["readyForPrivateCrosswalk"]);self.assertGreater(result["heldMappingCount"],0)

    def test_ffi_null_lengths_and_output_lifetime(self):
        out=(ctypes.c_uint64*8)(*[99]*8)
        status=self.library.call(None,0,None,0,out,8)
        self.assertEqual(status,2);self.assertEqual(list(out),[0]*8)
        buf=(ctypes.c_ubyte*1)(1)
        for length in [0,2**64-1]:
            self.assertEqual(self.library.call(buf,length,buf,length,out,8),2)
        self.assertEqual(self.library.call(buf,1,buf,1,None,8),2)
        self.assertTrue(self.run_bridge()["readyForPrivateCrosswalk"])

    def test_library_hash_and_abi_guards(self):
        with self.assertRaisesRegex(b.BridgeError,"libraryIdentityMismatch"):b.Library(str(LIB),"0"*64)
        with self.assertRaisesRegex(b.BridgeError,"invalidLibrary"):b.Library("/invented/not-searched", "0"*64)
        fake=mock.Mock();fake.tsugino_crosswalk_abi_version.return_value=1
        with mock.patch.object(ctypes,"CDLL",return_value=fake),self.assertRaisesRegex(b.BridgeError,"unsupportedABI"):
            b.Library(str(LIB),hashlib.sha256(LIB.read_bytes()).hexdigest())

    def test_invalid_expectations_and_archive_identity(self):
        with mock.patch.object(b,"read_occurrences") as reader:
            with self.assertRaisesRegex(b.BridgeError,"invalidExpectations"):self.run_bridge(expected_count=13)
            reader.assert_not_called()
        self.archive.write_bytes(b"changed")
        with self.assertRaisesRegex(b.BridgeError,"occurrenceReadFailed"):self.run_bridge()


if __name__=="__main__":unittest.main()
