"""Offline DEC-083 correspondence requests; synthetic verification only so far.

Representation/owner-asserted closure and integrity, never evidence authentication,
Trip identity inference, allocation, registry mutation or S9 acceptance. See README.
"""
import argparse
from contextlib import contextmanager
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import secrets
import stat
import sys

FORMAT = "tsugino.trip-correspondence-request"
CONTEXT_FORMAT = "tsugino.trip-correspondence-context"
MAX_BYTES = 256 * 1024
MAX_DEPTH = 32
REPOSITORY = str(Path(__file__).resolve().parents[2])
ROLES = frozenset(("sourceProfileAcceptance", "candidateApplicability",
                   "passengerClassification", "sourceOrder", "stationCrosswalk",
                   "firstRealTripBaselineAudit"))
OPTIONAL_ROLES = frozenset(("s9Review",))
PREREQUISITES = frozenset(("movementEvidence", "endpointDispositions",
                          "immutableS9SnapshotAcceptance", "realTripRegistrationToolingCheckpoint",
                          "p3T1RealImport", "productionRegistryAdoption"))
CONFIRMATION = "approveExactSourceIdentityAsNewRecurringRunRequest"
SOURCE_FIELDS = frozenset(("sourceID", "namespace", "key", "profileID", "profileVersion",
                           "inputSHA256", "publisherID", "resourceID", "feedRevision"))
BASELINE_FIELDS = frozenset(("lineageID", "schemaVersion", "revision", "registrySHA256"))


class RequestError(Exception):
    """Only fixed, non-private codes escape public interfaces."""


def fail(code):
    raise RequestError(code)


def fields(value, names):
    if type(value) is not dict or set(value) != set(names):
        fail("invalidFields")


def text(value, maximum=1024):
    if type(value) is not str or not value or not value.strip():
        fail("invalidText")
    try:
        size = len(value.encode("utf-8", "strict"))
    except UnicodeError:
        fail("invalidUnicode")
    if size > maximum:
        fail("resourceLimit")


def token(value):
    if type(value) is not str or re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._:-]{0,127}", value) is None:
        fail("invalidIdentifier")


def digest(value):
    if type(value) is not str or re.fullmatch(r"[0-9a-f]{64}", value) is None:
        fail("invalidDigest")


def timestamp(value):
    if type(value) is not str or re.fullmatch(r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z", value) is None:
        fail("invalidTimestamp")
    try:
        datetime.datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ")
    except ValueError:
        fail("invalidTimestamp")


def _pairs(items):
    result = {}
    for key, value in items:
        if key in result:
            fail("duplicateJSONKey")
        result[key] = value
    return result


def _number(raw):
    if len(raw) > 16:
        fail("resourceLimit")
    return int(raw)


def _noninteger(_):
    fail("invalidJSONNumber")


def decode(raw):
    """Bound syntax before decoding, preserve Unicode scalars without normalization."""
    if type(raw) is not bytes or not 0 < len(raw) <= MAX_BYTES:
        fail("resourceLimit")
    try:
        decoded = raw.decode("utf-8", "strict")
        depth, quoted, escaped = 0, False, False
        for char in decoded:
            if quoted:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == '"':
                    quoted = False
            elif char == '"':
                quoted = True
            elif char in "[{":
                depth += 1
                if depth > MAX_DEPTH:
                    fail("resourceLimit")
            elif char in "]}":
                depth -= 1
        value = json.loads(decoded, object_pairs_hook=_pairs, parse_int=_number,
                           parse_float=_noninteger, parse_constant=_noninteger)
        # Also reject lone surrogates encoded as JSON escapes, including in keys.
        canonical(value)
        return value
    except (ValueError, UnicodeError, RecursionError):
        fail("invalidJSON")


def canonical(value):
    try:
        raw = json.dumps(value, ensure_ascii=False, sort_keys=True,
                         separators=(",", ":"), allow_nan=False).encode("utf-8", "strict")
    except (ValueError, TypeError, UnicodeError, RecursionError):
        fail("invalidRepresentation")
    if not 0 < len(raw) <= MAX_BYTES:
        fail("resourceLimit")
    return raw


def _source(value):
    fields(value, SOURCE_FIELDS)
    for name in SOURCE_FIELDS - {"inputSHA256", "namespace", "key"}:
        text(value[name])
    text(value["key"], 4096)
    digest(value["inputSHA256"])
    if value["namespace"] != "gtfs.trip_id":
        fail("unsupportedNamespace")


def _baseline(value):
    fields(value, BASELINE_FIELDS)
    token(value["lineageID"])
    digest(value["registrySHA256"])
    # This workflow supports only the audited first-allocation boundary, not
    # arbitrary later baselines. The supplied context pins the exact hash too.
    if type(value["schemaVersion"]) is not int or value["schemaVersion"] != 2:
        fail("unsupportedBaseline")
    if type(value["revision"]) is not int or value["revision"] != 6:
        fail("unsupportedBaseline")


def _mapping(value):
    fields(value, ("version", "sha256"))
    text(value["version"])
    digest(value["sha256"])


def _evidence(values, source, baseline, mapping):
    if type(values) is not list or not len(ROLES) <= len(values) <= len(ROLES | OPTIONAL_ROLES):
        fail("invalidEvidenceInventory")
    roles, ids = set(), set()
    for item in values:
        fields(item, ("role", "evidenceID", "sha256", "locator", "source", "baseline", "mapping"))
        token(item["role"])
        token(item["evidenceID"])
        text(item["locator"], 4096)
        digest(item["sha256"])
        if item["role"] not in ROLES | OPTIONAL_ROLES:
            fail("unknownEvidenceRole")
        if item["role"] in roles or item["evidenceID"] in ids:
            fail("duplicateEvidence")
        roles.add(item["role"])
        ids.add(item["evidenceID"])
        _source(item["source"])
        _baseline(item["baseline"])
        _mapping(item["mapping"])
        if item["source"] != source or item["baseline"] != baseline or item["mapping"] != mapping:
            fail("evidenceScopeMismatch")
    if not ROLES <= roles:
        fail("missingEvidenceRole")
    return sorted(values, key=lambda item: item["role"])


def validate_context(value):
    fields(value, ("format", "schemaVersion", "ownerAuthority", "source", "baseline", "mapping", "evidence"))
    if value["format"] != CONTEXT_FORMAT or type(value["schemaVersion"]) is not int or value["schemaVersion"] != 1:
        fail("unsupportedContext")
    token(value["ownerAuthority"])
    _source(value["source"])
    _baseline(value["baseline"])
    _mapping(value["mapping"])
    result = dict(value)
    result["evidence"] = _evidence(value["evidence"], value["source"], value["baseline"], value["mapping"])
    return result


def _payload(value, context):
    fields(value, ("requestID", "ownerAuthority", "mode", "source", "baseline", "mapping",
                   "baselineCapability", "evidence", "conclusion", "unresolvedPrerequisites"))
    token(value["requestID"])
    token(value["ownerAuthority"])
    if value["mode"] != "distinctNewRun":
        fail("unsupportedRequestMode")
    _source(value["source"])
    _baseline(value["baseline"])
    _mapping(value["mapping"])
    if value["baselineCapability"] != "noTripIdentityStateInIdentifiedBaseline":
        fail("invalidBaselineAssertion")
    for name in ("ownerAuthority", "source", "baseline", "mapping"):
        if value[name] != context[name]:
            fail("contextMismatch")
    evidence = _evidence(value["evidence"], value["source"], value["baseline"], value["mapping"])
    if evidence != context["evidence"]:
        fail("evidenceInventoryMismatch")
    conclusion = value["conclusion"]
    fields(conclusion, ("distinctNewRunRequested", "existingCanonicalTripTarget", "priorCanonicalTripBinding",
                        "acceptedCanonicalCompetitors", "externalSemanticCompetition",
                        "semanticDistinctnessFromAllSourceRows", "affirmativeReasoning", "basisEvidenceIDs"))
    if (conclusion["distinctNewRunRequested"] is not True or conclusion["existingCanonicalTripTarget"] is not None
            or conclusion["priorCanonicalTripBinding"] != "noneStructurallyPossibleInPriorBaseline"
            or conclusion["acceptedCanonicalCompetitors"] != "noneStructurallyPossibleInPriorBaseline"
            or conclusion["externalSemanticCompetition"] != "notGloballyDisproved"
            or conclusion["semanticDistinctnessFromAllSourceRows"] is not False):
        fail("invalidCorrespondenceAssertion")
    text(conclusion["affirmativeReasoning"], 8192)
    basis = conclusion["basisEvidenceIDs"]
    ids = {item["evidenceID"] for item in evidence}
    required_basis = {item["evidenceID"] for item in evidence
                      if item["role"] in ("sourceProfileAcceptance", "candidateApplicability")}
    if type(basis) is not list or not 2 <= len(basis) <= len(ids):
        fail("invalidReasoningBasis")
    for item in basis:
        token(item)
    if len(set(basis)) != len(basis) or not required_basis <= set(basis) <= ids:
        fail("invalidReasoningBasis")
    unresolved = value["unresolvedPrerequisites"]
    if type(unresolved) is not list or len(unresolved) != len(PREREQUISITES):
        fail("invalidPrerequisites")
    for item in unresolved:
        token(item)
    if set(unresolved) != PREREQUISITES:
        fail("invalidPrerequisites")
    result = dict(value)
    result["evidence"] = evidence
    result["conclusion"] = dict(conclusion, basisEvidenceIDs=sorted(basis))
    result["unresolvedPrerequisites"] = sorted(unresolved)
    return result


def proposal_digest(payload):
    return hashlib.sha256(canonical({"domain": FORMAT + "/proposal/v1", "format": FORMAT,
                                    "schemaVersion": 1, "payload": payload})).hexdigest()


def approved_digest(payload, approval):
    metadata = {name: approval[name] for name in ("authorityID", "approvedAt", "proposalSHA256")}
    return hashlib.sha256(canonical({"domain": FORMAT + "/approval/v1", "format": FORMAT,
                                    "schemaVersion": 1, "payload": payload,
                                    "ownerApproval": metadata})).hexdigest()


def validate(document, context, require_approval=False):
    context = validate_context(context)
    fields(document, ("format", "schemaVersion", "payload", "approval"))
    if document["format"] != FORMAT or type(document["schemaVersion"]) is not int or document["schemaVersion"] != 1:
        fail("unsupportedRequest")
    payload = _payload(document["payload"], context)
    approval = document["approval"]
    if approval is None:
        if require_approval:
            fail("approvalRequired")
    else:
        fields(approval, ("authorityID", "approvedAt", "proposalSHA256", "approvedContentSHA256"))
        token(approval["authorityID"])
        timestamp(approval["approvedAt"])
        digest(approval["proposalSHA256"])
        digest(approval["approvedContentSHA256"])
        if approval["authorityID"] != context["ownerAuthority"]:
            fail("authorityMismatch")
        if approval["proposalSHA256"] != proposal_digest(payload) or approval["approvedContentSHA256"] != approved_digest(payload, approval):
            fail("approvalDigestMismatch")
    result = dict(document, payload=payload)
    # Return detached JSON values: approving or editing a returned record must
    # not mutate the supplied proposal/context through shared nested objects.
    return json.loads(canonical(result))


def prepare(payload, context):
    return validate(dict(format=FORMAT, schemaVersion=1, payload=payload, approval=None), context)


def approve(document, context, expected_digest, authority, approved_at, confirmation):
    document = validate(document, context)
    if document["approval"] is not None:
        fail("alreadyApproved")
    if confirmation != CONFIRMATION:
        fail("explicitApprovalRequired")
    digest(expected_digest)
    if expected_digest != proposal_digest(document["payload"]):
        fail("proposalDigestMismatch")
    token(authority)
    timestamp(approved_at)
    if authority != document["payload"]["ownerAuthority"]:
        fail("authorityMismatch")
    metadata = dict(authorityID=authority, approvedAt=approved_at, proposalSHA256=expected_digest)
    metadata["approvedContentSHA256"] = approved_digest(document["payload"], metadata)
    return validate(dict(document, approval=metadata), context, require_approval=True)


def summary(document):
    """No caller-controlled identity/text is printed, even when equal to a key."""
    payload = document["payload"]
    return dict(status="approvalRecorded" if document["approval"] else "unapprovedProposal",
                mode="distinctNewRun", evidenceRoleCount=len(payload["evidence"]),
                unresolvedPrerequisiteCount=len(payload["unresolvedPrerequisites"]),
                proposalSHA256=proposal_digest(payload), evidenceAuthenticated=False,
                registrationAuthorized=False, s9Accepted=False)


def _parts(path):
    if type(path) is not str or not path.startswith("/") or "\x00" in path:
        fail("unsafePath")
    parts = path.split("/")[1:]
    if not parts or any(part in ("", ".", "..", ".git") for part in parts):
        fail("unsafePath")
    if os.path.commonpath((path, REPOSITORY)) == REPOSITORY:
        fail("repositoryPathForbidden")
    return parts


def _directory(info, private=False):
    mode = stat.S_IMODE(info.st_mode)
    if not stat.S_ISDIR(info.st_mode) or info.st_uid not in (0, os.geteuid()):
        fail("unsafeDirectory")
    if private:
        if info.st_uid != os.geteuid() or mode != 0o700:
            fail("unsafePrivateDirectory")
    elif mode & 0o022 and not (mode & stat.S_ISVTX and info.st_uid == 0):
        fail("unsafeDirectory")


def _file(info):
    if (not stat.S_ISREG(info.st_mode) or info.st_uid != os.geteuid()
            or stat.S_IMODE(info.st_mode) != 0o600 or info.st_nlink != 1):
        fail("unsafePrivateFile")


def _identity(info):
    return (info.st_dev, info.st_ino)


@contextmanager
def _parent(path):
    parts = _parts(path)
    descriptors, links = [], []
    try:
        repository_identity = _identity(os.stat(REPOSITORY, follow_symlinks=False))
        fd = os.open("/", os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
        descriptors.append(fd)
        _directory(os.fstat(fd))
        for name in parts[:-1]:
            next_fd = os.open(name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            descriptors.append(next_fd)
            info = os.fstat(next_fd)
            _directory(info)
            # Case aliases and macOS volume aliases must not bypass the lexical
            # check: no ancestor descriptor may enter this repository inode.
            if _identity(info) == repository_identity:
                fail("repositoryPathForbidden")
            links.append((fd, name, next_fd))
            fd = next_fd
        _directory(os.fstat(fd), private=True)

        def recheck():
            for parent, name, child in links:
                info = os.stat(name, dir_fd=parent, follow_symlinks=False)
                _directory(info)
                if _identity(info) != _identity(os.fstat(child)):
                    fail("pathChanged")
            _directory(os.fstat(fd), private=True)

        recheck()
        yield fd, parts[-1], recheck
    finally:
        for descriptor in reversed(descriptors):
            os.close(descriptor)


def read_private(path):
    try:
        with _parent(path) as (parent, name, recheck):
            fd = os.open(name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=parent)
            try:
                before = os.fstat(fd)
                _file(before)
                if not 0 < before.st_size <= MAX_BYTES:
                    fail("resourceLimit")
                chunks, remaining = [], MAX_BYTES + 1
                while remaining:
                    chunk = os.read(fd, min(remaining, 65536))
                    if not chunk:
                        break
                    chunks.append(chunk)
                    remaining -= len(chunk)
                raw = b"".join(chunks)
                after = os.fstat(fd)
                _file(after)
                if (before.st_size, before.st_mtime_ns, before.st_ctime_ns) != (after.st_size, after.st_mtime_ns, after.st_ctime_ns):
                    fail("inputChanged")
                recheck()
                if _identity(os.stat(name, dir_fd=parent, follow_symlinks=False)) != _identity(after):
                    fail("pathChanged")
                return decode(raw)
            finally:
                os.close(fd)
    except OSError:
        fail("privateIORejected")


def write_private(path, document):
    """Publish complete bytes by no-clobber hard link; no partial destination."""
    raw = canonical(document)
    try:
        with _parent(path) as (parent, name, recheck):
            temporary = ".correspondence-" + secrets.token_hex(16)
            fd, published, identity = None, False, None
            try:
                try:
                    os.stat(name, dir_fd=parent, follow_symlinks=False)
                except FileNotFoundError:
                    pass
                else:
                    fail("outputExists")
                fd = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=parent)
                os.fchmod(fd, 0o600)
                _file(os.fstat(fd))
                identity = _identity(os.fstat(fd))
                remaining = memoryview(raw)
                while remaining:
                    count = os.write(fd, remaining)
                    if count <= 0:
                        fail("privateIORejected")
                    remaining = remaining[count:]
                os.fsync(fd)
                recheck()
                os.link(temporary, name, src_dir_fd=parent, dst_dir_fd=parent, follow_symlinks=False)
                published = True
                os.unlink(temporary, dir_fd=parent)
                _file(os.fstat(fd))
                recheck()
                if _identity(os.stat(name, dir_fd=parent, follow_symlinks=False)) != identity:
                    fail("pathChanged")
                os.fsync(parent)
            except BaseException:
                if published:
                    try:
                        if _identity(os.stat(name, dir_fd=parent, follow_symlinks=False)) == identity:
                            os.unlink(name, dir_fd=parent)
                    except OSError:
                        pass
                raise
            finally:
                if fd is not None:
                    os.close(fd)
                    try:
                        os.unlink(temporary, dir_fd=parent)
                    except FileNotFoundError:
                        pass
    except OSError:
        fail("privateIORejected")


class _Parser(argparse.ArgumentParser):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, allow_abbrev=False, **kwargs)

    def error(self, message):
        fail("invalidArguments")


def main(argv=None):
    try:
        parser = _Parser(description="Offline private correspondence representation; real use requires separate authorization.")
        sub = parser.add_subparsers(dest="command", required=True)
        for command in ("prepare", "inspect", "approve", "verify"):
            child = sub.add_parser(command)
            child.add_argument("--input", required=True)
            child.add_argument("--context", required=True)
            if command in ("prepare", "approve"):
                child.add_argument("--output", required=True)
            if command == "approve":
                child.add_argument("--proposal-sha256", required=True)
                child.add_argument("--authority", required=True)
                child.add_argument("--approved-at", required=True)
                child.add_argument("--approve-distinct-new-run", action="store_true", required=True,
                                   help="I approve this exact source identity as a new recurring-run request for later allocation; not final S9 acceptance.")
        args = parser.parse_args(argv)
        # Validate all paths before reading either private input, without discovery.
        _parts(args.input)
        _parts(args.context)
        if args.command in ("prepare", "approve"):
            _parts(args.output)
        context = validate_context(read_private(args.context))
        value = read_private(args.input)
        if args.command == "prepare":
            document = prepare(value, context)
            write_private(args.output, document)
        elif args.command == "approve":
            document = approve(value, context, args.proposal_sha256, args.authority,
                               args.approved_at, CONFIRMATION if args.approve_distinct_new_run else None)
            write_private(args.output, document)
        else:
            document = validate(value, context, require_approval=args.command == "verify")
        if args.command == "verify":
            result = dict(status="approvedRepresentationValid", evidenceAuthenticated=False,
                          registrationAuthorized=False, s9Accepted=False)
        else:
            result = summary(document)
        print(json.dumps(result, sort_keys=True, separators=(",", ":")))
        return 0
    except RequestError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    except (OSError, ValueError, TypeError, RecursionError):
        print("invalidRepresentation", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("interrupted", file=sys.stderr)
        return 130


if __name__ == "__main__":
    sys.exit(main())
