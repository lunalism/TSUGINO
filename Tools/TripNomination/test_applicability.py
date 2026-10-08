"""Invented archives only: actual reader and CLI, no real railway data."""
import contextlib
import csv
import hashlib
import io
import json
import os
import pty
import select
import signal
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock
import zipfile
import applicability as a


SYNTHETIC_LABEL = f"N{1:02d}"


def csv_bytes(rows):
    fields = list(dict.fromkeys(k for r in rows for k in r))
    out = io.StringIO(newline=''); w = csv.DictWriter(out, fields, lineterminator='\r\n')
    w.writeheader(); w.writerows(rows); return out.getvalue().encode()


class ApplicabilityTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='synthetic-applicability-'); self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name).resolve()/'invented.zip'
        self.trip = dict(trip_id='invented-é', route_id='invented-route', service_id='invented-service')
        self.trips = [self.trip]; self.route = dict(route_id='invented-route'); self.extra = {}
        self.rows = [dict(trip_id=self.trip['trip_id'],stop_id='invented-'+str(i),stop_sequence=str(3+i*7),pickup_type='0',drop_off_type='0') for i in range(14)]

    def write(self):
        members = {'trips.txt':self.extra.pop('trips.txt',csv_bytes(self.trips)),'routes.txt':csv_bytes([self.route]),'stop_times.txt':csv_bytes(self.rows),
                   'calendar.txt':b'\xff','calendar_dates.txt':b'\xff',**self.extra}
        with zipfile.ZipFile(self.path,'w',compression=zipfile.ZIP_DEFLATED) as z:
            for name,data in members.items():z.writestr(name,data)
        raw=self.path.read_bytes();return len(raw),hashlib.sha256(raw).hexdigest()

    def check_result(self, expected, reason=None, label=SYNTHETIC_LABEL):
        size,digest=self.write();original=a.n._read_member;opened=[]
        def read(*args):opened.append(args[3]);return original(*args)
        with mock.patch.object(a.n,'_read_member',side_effect=read):
            try:r=a.read_applicability(str(self.path),size,digest,label,14,a.PROFILE)
            except a.EvidenceError as exc:r=a.held_result(exc.reason)
        self.assertEqual(r.applicability,expected,r.reasons)
        if reason:self.assertIn(reason,r.reasons)
        self.assertNotIn(b'calendar.txt',opened);self.assertNotIn(b'calendar_dates.txt',opened)
        for secret in ('invented-é','invented-route','invented-service','invented-0','invented-booking','invented-flex'):
            self.assertNotIn(secret,json.dumps(r.aggregate()))
        return r

    def frequency(self,value='0',key=None):
        self.extra['frequencies.txt']=csv_bytes([dict(trip_id=key or self.trip['trip_id'],start_time='06:00:00',end_time='09:00:00',headway_secs='600',exact_times=value)])

    def flex(self,field=None):
        r=self.rows[0];r.update(start_pickup_drop_off_window='06:00:00',end_pickup_drop_off_window='08:00:00',pickup_type='1',drop_off_type='1')
        if field:
            r.pop('stop_id');r[field]='invented-flex'
            if field=='location_group_id':self.extra['location_groups.txt']=csv_bytes([dict(location_group_id='invented-flex')])
            else:self.extra['locations.geojson']=json.dumps(dict(type='FeatureCollection',features=[dict(type='Feature',id='invented-flex',properties={},geometry=dict(type='Polygon',coordinates=[[[0,0],[1,0],[1,1],[0,0]]]))])).encode()

    def book(self,field='pickup_booking_rule_id',kind='0',**fields):
        self.rows[0][field]='invented-booking';self.extra['booking_rules.txt']=csv_bytes([dict(booking_rule_id='invented-booking',booking_type=kind,**fields)])

    def test_ordinary(self):
        r=self.check_result('eligible');self.assertEqual(r.frequency_status,'matchedProfile');self.assertEqual(r.flexible_status,'matchedProfile')
    def test_duplicate_key(self):self.trips.append(dict(self.trip));self.check_result('held',a.Reason.DUPLICATE_EXACT_KEY)
    def test_missing_service(self):self.trip['service_id']='';self.check_result('held',a.Reason.MISSING_SERVICE)
    def test_missing_route(self):self.trip['route_id']='';self.check_result('held',a.Reason.MISSING_ROUTE)
    def test_missing_route_target(self):self.route['route_id']='other';self.check_result('held',a.Reason.ROUTE_MISSING_OR_AMBIGUOUS)
    def test_frequency_no_match(self):self.frequency(key='other');self.check_result('eligible')
    def test_frequency_bad_header(self):self.extra['frequencies.txt']=b'trip_id,start_time,end_time,headway_secs,exact_times\ninvented-\xc3\xa9,06:00:00,08:00:00,600,9\n';self.check_result('held',a.Reason.FREQUENCY_MEMBER_MALFORMED)
    def test_frequency_bad_enum(self):self.frequency('01');self.check_result('held',a.Reason.FREQUENCY_MEMBER_MALFORMED)
    def test_group(self):self.flex('location_group_id');self.check_result('excluded',a.Reason.FLEX_LOCATION)
    def test_zone(self):self.flex('location_id');self.check_result('excluded',a.Reason.FLEX_LOCATION)
    def test_window(self):self.flex();self.check_result('excluded',a.Reason.FLEX_LOCATION)
    def test_window_single_digit_hour_shape(self):self.flex();self.rows[0]['start_pickup_drop_off_window']='6:00:00';self.check_result('excluded')
    def test_missing_location(self):self.flex('location_group_id');self.extra['location_groups.txt']=b'location_group_id\nother\n';self.check_result('held')
    def test_duplicate_location(self):self.flex('location_group_id');self.extra['location_groups.txt']=b'location_group_id\ninvented-flex\ninvented-flex\n';self.check_result('held')
    def test_location_conflict(self):self.flex('location_group_id');self.rows[0]['stop_id']='invented-0';self.check_result('held')
    def test_missing_window(self):self.flex();self.rows[0]['end_pickup_drop_off_window']='';self.check_result('held')
    def test_bad_window(self):self.flex();self.rows[0]['start_pickup_drop_off_window']='bad';self.check_result('held')
    def test_window_arrival(self):self.flex();self.rows[0]['arrival_time']='opaque';self.check_result('held')
    def test_window_pickup(self):self.flex();self.rows[0]['pickup_type']='3';self.check_result('held')
    def test_window_continuous(self):self.flex();self.rows[0]['continuous_pickup']='0';self.check_result('held')
    def test_route_windows_on_other_trip(self):
        self.trips.append(dict(self.trip,trip_id='other'));self.rows.append(dict(trip_id='other',stop_id='invented-other',stop_sequence='1',start_pickup_drop_off_window='06:00:00',end_pickup_drop_off_window='08:00:00',pickup_type='1',drop_off_type='1'))
        self.route['continuous_pickup']='0';self.rows[0]['continuous_pickup']='1';self.check_result('held')
    def test_booking(self):self.book();self.check_result('excluded',a.Reason.BOOKING_RULE)
    def test_alighting_booking(self):self.book('drop_off_booking_rule_id');self.check_result('excluded',a.Reason.BOOKING_RULE)
    def test_generic_booking_ignored(self):self.rows[0]['booking_rule_id']='not-authorized-field';self.check_result('eligible')
    def test_missing_booking_member(self):self.book();del self.extra['booking_rules.txt'];self.check_result('held')
    def test_missing_booking_target(self):self.book();self.extra['booking_rules.txt']=b'booking_rule_id,booking_type\nother,0\n';self.check_result('held')
    def test_duplicate_booking_target(self):self.book();self.extra['booking_rules.txt']=b'booking_rule_id,booking_type\ninvented-booking,0\ninvented-booking,0\n';self.check_result('held')
    def test_bad_booking(self):self.book(kind='9');self.check_result('held',a.Reason.BOOKING_RULE_MALFORMED)
    def test_booking_notice_required(self):self.book(kind='1');self.check_result('held')
    def test_same_day_booking(self):self.book(kind='1',prior_notice_duration_min='5');self.check_result('excluded')
    def test_booking_service_id_is_opaque_and_calendar_unread(self):self.book(kind='2',prior_notice_last_day='1',prior_notice_last_time='17:00:00',prior_notice_service_id='opaque');self.check_result('excluded',a.Reason.BOOKING_RULE)
    def test_explicit_passenger(self):self.rows[0]['pickup_type']='';self.check_result('held',a.Reason.OCCURRENCE_PROFILE_MISMATCH)
    def test_bad_pickup(self):self.rows[0]['pickup_type']='01';self.check_result('held')
    def test_terminal_interval(self):self.rows[-1].update(continuous_pickup='0',continuous_drop_off='3');self.check_result('eligible')
    def test_terminal_cannot_hide_incoming(self):self.route['continuous_pickup']='0';self.rows[-1]['continuous_pickup']='1';self.check_result('excluded')
    def test_terminal_bad_enum(self):self.rows[-1]['continuous_pickup']='bad';self.check_result('held')
    def test_all_intervals_override(self):self.route.update(continuous_pickup='3',continuous_drop_off='2');self.rows[:13]=[dict(r,continuous_pickup='1',continuous_drop_off='1') for r in self.rows[:13]];self.check_result('eligible')
    def test_numeric_order(self):self.route['continuous_pickup']='0';self.rows[0]['continuous_pickup']='1';self.rows.reverse();self.check_result('held')
    def test_scalar_competitor(self):self.trips.append(dict(self.trip,trip_id='invented-e\u0301'));self.frequency(key='invented-e\u0301');self.check_result('eligible')
    def test_whitespace_competitor(self):self.trips.append(dict(self.trip,trip_id=self.trip['trip_id']+' '));self.frequency(key=self.trip['trip_id']+' ');self.check_result('eligible')
    def test_wrong_label(self):self.check_result('held',a.Reason.CANDIDATE_MISSING,label='N09')
    def test_duplicate_sequence(self):self.rows[-1]['stop_sequence']='3';self.check_result('held',a.Reason.MEMBER_MALFORMED)
    def test_count_mismatch(self):self.rows.pop(13);self.check_result('held',a.Reason.OCCURRENCE_COUNT_MISMATCH)
    def test_reordered_trips_header_keeps_exact_key_count(self):
        self.extra['trips.txt']=b'service_id,route_id,trip_id\r\ninvented-service,invented-route,invented-\xc3\xa9\r\n'
        self.check_result('eligible')
    def test_missing_stop_and_flex_location_holds(self):
        self.rows[0].pop('stop_id');self.check_result('held',a.Reason.FLEX_STRUCTURE_INVALID)
    def test_booking_type_two_service_id_is_allowed_without_calendar_read(self):
        self.book(kind='2',prior_notice_last_day='2',prior_notice_last_time='18:00:00',prior_notice_service_id='opaque-calendar-service')
        self.check_result('excluded',a.Reason.BOOKING_RULE)
    def test_booking_type_zero_forbids_service_id(self):
        self.book(prior_notice_service_id='opaque');self.check_result('held',a.Reason.BOOKING_RULE_MALFORMED)
    def test_booking_type_two_requires_last_window(self):
        self.book(kind='2',prior_notice_last_day='2');self.check_result('held',a.Reason.BOOKING_RULE_MALFORMED)
    def test_booking_start_day_requires_start_time(self):
        self.book(kind='2',prior_notice_last_day='2',prior_notice_last_time='18:00:00',prior_notice_start_day='5')
        self.check_result('held',a.Reason.BOOKING_RULE_MALFORMED)
    def test_booking_type_one_max_and_start_day_conflict(self):
        self.book(kind='1',prior_notice_duration_min='5',prior_notice_duration_max='30',prior_notice_start_day='5',prior_notice_start_time='00:00:00')
        self.check_result('held',a.Reason.BOOKING_RULE_MALFORMED)
    def test_booking_type_one_valid_maximum(self):
        self.book(kind='1',prior_notice_duration_min='5',prior_notice_duration_max='30');self.check_result('excluded')

    def test_identity_before_semantics(self):
        size,digest=self.write()
        with self.assertRaises(a.EvidenceError) as ctx:a.read_applicability(str(self.path),size,'0'*64,SYNTHETIC_LABEL,14,a.PROFILE)
        self.assertEqual(ctx.exception.reason,a.Reason.ARCHIVE_IDENTITY_MISMATCH)
    def test_actual_cli_entrypoint(self):
        size,digest=self.write(); argv=[sys.executable,'-B','-W','error',a.__file__,'--archive',str(self.path),
            '--expected-size',str(size),'--expected-sha256',digest,'--label',SYNTHETIC_LABEL,'--expected-count','14','--profile',a.PROFILE]
        pid,master=pty.fork()
        if pid==0:
            env=dict(os.environ)
            for key in ('SSH_CONNECTION','SSH_CLIENT','SSH_TTY'):env.pop(key,None)
            os.execve(sys.executable,argv,env)
        output=bytearray(); finished=False; deadline=time.monotonic()+10
        try:
            while time.monotonic()<deadline:
                ready,_,_=select.select([master],[],[],0.1)
                if not ready:continue
                try:chunk=os.read(master,65536)
                except OSError:break
                if not chunk:break
                output.extend(chunk)
            else:self.fail('invented applicability CLI timed out')
            _,status=os.waitpid(pid,0);finished=True
            self.assertEqual(os.waitstatus_to_exitcode(status),0,bytes(output))
            text=bytes(output).decode('ascii')
            line=next(x for x in text.splitlines() if x.startswith('{'))
            self.assertEqual(json.loads(line)['applicability'],'eligible')
            for secret in ('invented-é','invented-route','invented-service',str(self.path)):self.assertNotIn(secret,text)
        finally:
            if not finished:os.kill(pid,signal.SIGKILL)
            os.close(master)

    def test_cli_validates_terminal_before_archive(self):
        with mock.patch.object(a, '_Terminal') as terminal:
            terminal.side_effect = a.SessionError('localTerminalRequired')
            self.assertEqual(a.main(['--archive','/not-read','--expected-size','1','--expected-sha256','0'*64,
                                     '--label',SYNTHETIC_LABEL,'--expected-count','14','--profile',a.PROFILE]), 1)
            terminal.assert_called_once()




    def test_frequency_bad_time_shape(self):
        self.frequency(); self.extra['frequencies.txt'] = self.extra['frequencies.txt'].replace(b'06:00:00', b'bad')
        self.check_result('held', a.Reason.FREQUENCY_MEMBER_MALFORMED)
    def test_frequency_duplicate_primary_key(self):
        self.frequency(); data = self.extra['frequencies.txt']; self.extra['frequencies.txt'] += data.split(b'\r\n')[1]+b'\r\n'
        self.check_result('held', a.Reason.FREQUENCY_MEMBER_MALFORMED)
    def test_frequency_same_start_different_end_holds(self):
        self.frequency(); data = self.extra['frequencies.txt']
        self.extra['frequencies.txt'] += data.split(b'\r\n')[1].replace(b'09:00:00', b'10:00:00') + b'\r\n'
        self.check_result('held', a.Reason.FREQUENCY_MEMBER_MALFORMED)
    def test_inherited_continuous_exclusion_has_reason(self):
        for field in ('continuous_pickup', 'continuous_drop_off'):
            self.route = dict(route_id='invented-route', **{field: '0'})
            self.check_result('excluded', a.Reason.CONTINUOUS_ONLY)
    def test_malformed_zone_coordinates_hold(self):
        self.flex('location_id'); original = self.extra['locations.geojson']
        for coordinates in (None, 'invalid', {}, [], [None], [[None]],
                            [[[0, 0], [1, 0], [1, 1]]],
                            [[[0, 0], [1, 0], [1, 1], [2, 2]]],
                            [[[0, 0], [True, 0], [1, 1], [0, 0]]]):
            with self.subTest(coordinates=coordinates):
                obj = json.loads(original)
                obj['features'][0]['geometry']['coordinates'] = coordinates
                self.extra['locations.geojson'] = json.dumps(obj).encode()
                self.check_result('held', a.Reason.FLEX_REFERENCE_INVALID)
    def test_multipolygon_zone_excluded(self):
        self.flex('location_id'); obj = json.loads(self.extra['locations.geojson'])
        geometry = obj['features'][0]['geometry']
        geometry.update(type='MultiPolygon', coordinates=[geometry['coordinates']])
        self.extra['locations.geojson'] = json.dumps(obj).encode()
        self.check_result('excluded', a.Reason.FLEX_LOCATION)
    def test_valid_exclusion_does_not_hide_invalid_booking(self):
        self.frequency(); self.book(kind='invalid'); self.check_result('held', a.Reason.BOOKING_RULE_MALFORMED)
    def test_valid_flex_does_not_hide_invalid_frequency(self):
        self.flex(); self.frequency('bad'); self.check_result('held', a.Reason.FREQUENCY_MEMBER_MALFORMED)
    def test_window_dropoff_forbidden(self):
        self.flex(); self.rows[0]['drop_off_type']='0'; self.check_result('held')
    def test_window_nonordinary_route_invalid_even_override(self):
        self.flex(); self.route['continuous_pickup']='0';self.rows[0]['continuous_pickup']='1';self.check_result('held')
    def test_bad_zone_geometry(self):
        self.flex('location_id');self.extra['locations.geojson']=self.extra['locations.geojson'].replace(b'Polygon',b'Point');self.check_result('held')
    def test_missing_location_window_pair(self):
        self.flex('location_id');self.rows[0]['start_pickup_drop_off_window']='';self.check_result('held')
    def test_route_duplicate_target(self):
        self.extra['routes.txt']=csv_bytes([self.route,self.route]);self.check_result('held',a.Reason.ROUTE_MISSING_OR_AMBIGUOUS)
    def test_booking_forbidden_notice(self):
        self.book(prior_notice_duration_min='3');self.check_result('held',a.Reason.BOOKING_RULE_MALFORMED)
    def test_valid_prior_day_booking(self):
        self.book(kind='2',prior_notice_last_day='1',prior_notice_last_time='17:00:00');self.check_result('excluded')
    def test_booking_time_single_digit_hour_shape(self):
        self.book(kind='2',prior_notice_last_day='1',prior_notice_last_time='7:00:00');self.check_result('excluded')
    def test_symlink_input_rejected(self):
        size,digest=self.write();link=self.path.parent/'invented-link';link.symlink_to(self.path)
        with self.assertRaises(a.EvidenceError):a.read_applicability(str(link),size,digest,SYNTHETIC_LABEL,14,a.PROFILE)
    def test_input_mutation_rejected(self):
        size,digest=self.write();original=a._evaluate
        def mutate(*args):
            result=original(*args);self.path.write_bytes(b'invented-changed');return result
        with mock.patch.object(a,'_evaluate',side_effect=mutate),self.assertRaises(a.EvidenceError):
            a.read_applicability(str(self.path),size,digest,SYNTHETIC_LABEL,14,a.PROFILE)
    def test_cli_hash_failure_has_no_semantic_output(self):
        size,_=self.write(); out,err=io.StringIO(),io.StringIO()
        with mock.patch.object(a, '_Terminal') as terminal:
            terminal.return_value.__enter__.return_value = mock.Mock()
            terminal.return_value.__enter__.return_value.write = mock.Mock()
            with contextlib.redirect_stderr(err):
                self.assertEqual(a.main(['--archive',str(self.path),'--expected-size',str(size),'--expected-sha256','0'*64,
                                         '--label',SYNTHETIC_LABEL,'--expected-count','14','--profile',a.PROFILE]), 1)
        terminal.assert_called_once()
        self.assertEqual(err.getvalue(), '')


    def test_cli_returns_aggregate_for_excluded_or_held(self):
        for invalid, expected in ((False, 'excluded'), (True, 'held')):
            self.frequency('9' if invalid else '1'); size,digest=self.write(); out=io.StringIO()
            terminal=mock.MagicMock(); terminal.__enter__.return_value=terminal
            with mock.patch.object(a, '_Terminal', return_value=terminal), contextlib.redirect_stdout(out):
                code=a.main(['--archive',str(self.path),'--expected-size',str(size),'--expected-sha256',digest,
                             '--label',SYNTHETIC_LABEL,'--expected-count','14','--profile',a.PROFILE])
            self.assertEqual(code, 1); self.assertEqual(json.loads(terminal.write.call_args[0][0])['applicability'], expected)
            self.assertNotIn(self.trip['trip_id'], terminal.write.call_args[0][0])


def install():
    for field in ('continuous_pickup','continuous_drop_off'):
        for value in ('','1','0','2','3','bad'):
            def case(self,field=field,value=value):
                self.route[field]=value;self.check_result('held' if value=='bad' else ('eligible' if value in ('','1') else 'excluded'))
            setattr(ApplicabilityTests,'test_route_'+field+'_'+(value or 'empty'),case)
        for value in ('0','2','3',''):
            def case(self,field=field,value=value):
                self.route[field]='2' if value=='' else '1';self.rows[0][field]=value;self.rows[1][field]='1';self.check_result('excluded')
            setattr(ApplicabilityTests,'test_override_'+field+'_'+(value or 'inherit'),case)
    for field in ('pickup_type','drop_off_type'):
        for value in ('1','2','3'):
            def case(self,field=field,value=value):self.rows[0][field]=value;self.check_result('excluded',a.Reason.NONORDINARY_PICKUP)
            setattr(ApplicabilityTests,'test_method_'+field+'_'+value,case)
    for value in ('0','1'):
        def case(self,value=value):self.frequency(value);self.check_result('excluded',a.Reason.FREQUENCY_MATCH)
        setattr(ApplicabilityTests,'test_frequency_exact_'+value,case)

install()
if __name__=='__main__':unittest.main()
