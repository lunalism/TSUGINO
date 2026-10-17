#!/usr/bin/env python3
"""Driver tests for run.py with synthetic test-host processes (no xcodebuild, Simulator or device).

Each invocation spawns a real child process (this file, in --fake-host mode) that writes
PRS_MEASURE records like the Swift emitter; `sh` is replaced so load and host-cleanup probes
are synthetic. Usage: python3 -B -I Tools/PreparedRouteMeasurement/test_run.py
"""
import json
import os
import pathlib
import sys
import tempfile
import time
import unittest
from unittest import mock

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import run  # noqa: E402


def fake_host():
    """Synthetic test host: emits the records named by TEST_RUNNER_FAKE_SCENARIO."""
    env = {k[len('TEST_RUNNER_'):]: v for k, v in os.environ.items() if k.startswith('TEST_RUNNER_')}
    if 'TSUGINO_PRS_RUN' not in env:  # build-for-testing stand-in: nothing to emit
        return
    common = {'schema': 1, 'runID': env['TSUGINO_PRS_RUN'], 'variant': env['TSUGINO_PRS_VARIANT'],
              'pass': env['TSUGINO_PRS_PASS'], 'utc': 'synthetic', 'thermalState': 'nominal'}
    out = pathlib.Path(env['TSUGINO_PRS_OUT'])
    inflight = pathlib.Path(env['TSUGINO_PRS_INFLIGHT'])

    def emit(**fields):
        with open(out, 'a') as handle:
            handle.write('PRS_MEASURE ' + json.dumps({**common, **fields}, sort_keys=True) + '\n')
    scenario, group = env['FAKE_SCENARIO'], env['TSUGINO_PRS_GROUP']
    if scenario == 'memory-watchdog':
        emit(kind='sample', caseID=group, **{'class': 'W'}, watchdogFired=True, failure='CancellationError',
             repetition=-1, warmup=True, memory={'peakMethod': 'ledger_phys_footprint_peak (process lifetime)'})
        emit(kind='end', calls=1, stopped=False)
    elif scenario == 'class-u':
        emit(kind='sample', caseID='W2a-03', **{'class': 'U'}, mismatch='unexpected cancel-pass outcome R')
        emit(kind='stop', reason='class U in cancel pass')
        emit(kind='end', calls=10, stopped=True)
    elif scenario == 'memory-guard':
        emit(kind='sample', caseID=group, **{'class': 'C'})
        emit(kind='stop', reason='memory guard phys_footprint 1 > 2 GiB', caseID=group)
        emit(kind='end', calls=1, stopped=True)
    elif scenario == 'crash':  # one sample, then the host dies without an end record
        inflight.write_text('W1-0008')
        emit(kind='sample', caseID='W1-0002', **{'class': 'C'})
        sys.exit(65)
    elif scenario == 'hang':
        inflight.write_text('W5-5')
        time.sleep(30)
    elif scenario == 'pipeline':  # discovery admits one C case per group; other passes complete it
        case = f'{group}-case'
        if env['TSUGINO_PRS_PASS'] == 'discovery':
            emit(kind='sample', caseID=case, **{'class': 'C'})
        elif env['TSUGINO_PRS_PASS'] != 'cancel':
            for (admitted, cls) in (item.split('=') for item in env['TSUGINO_PRS_CASES'].split(',')):
                emit(kind='sample', caseID=admitted, **{'class': cls})
        emit(kind='end', calls=0 if env['TSUGINO_PRS_PASS'] == 'cancel' else 1, stopped=False)


class DriverTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = pathlib.Path(self.tmp.name)
        self.load = 0
        self.probes = []
        patches = [mock.patch.object(run, 'sh', self.fake_sh),
                   mock.patch.object(run, 'RESULTS', self.dir / 'results.json'),
                   mock.patch.object(run.Experiment, 'xcodebuild', self.fake_xcodebuild)]
        for p in patches:
            p.start()
            self.addCleanup(p.stop)
        self.addCleanup(self.tmp.cleanup)
        os.environ['TEST_RUNNER_FAKE_SCENARIO'] = 'pipeline'
        self.addCleanup(os.environ.pop, 'TEST_RUNNER_FAKE_SCENARIO', None)

    def fake_sh(self, *args):
        self.probes.append(args)
        if args == ('sysctl', '-n', 'vm.loadavg'):
            self.load += 1
            return f'{{ {self.load}.00 0.00 0.00 }}'
        if args == ('pmset', '-g', 'batt'):
            return "Now drawing from 'AC Power'\n -InternalBattery-0 (id=1234567)\t100%; charged; 0:00 remaining present: true"
        return ''  # simctl terminate / pgrep (no host left) / metadata

    @staticmethod
    def fake_xcodebuild(_self, variant, action, extra=()):
        return [sys.executable, '-B', str(pathlib.Path(__file__).resolve()), '--fake-host', variant, action, *extra]

    def experiment(self, scenario):
        os.environ['TEST_RUNNER_FAKE_SCENARIO'] = scenario
        e = run.Experiment()
        e.raw = self.dir / 'raw'
        e.raw.mkdir()
        e.start = time.time()
        return e

    def test_load_is_recorded_at_start_and_end_of_every_test_process(self):
        e = self.experiment('memory-watchdog')
        e.invoke('V-O', 'memory', 'W1-0001', [('W1-0001', 'C')], family='W1')
        e.invoke('V-O', 'memory', 'W1-0002', [('W1-0002', 'C')], family='W1')
        self.assertEqual([(p['loadStart'], p['loadEnd']) for p in e.processes],
                         [('{ 1.00 0.00 0.00 }', '{ 2.00 0.00 0.00 }'), ('{ 3.00 0.00 0.00 }', '{ 4.00 0.00 0.00 }')])

    def test_memory_watchdog_record_counts_the_call_and_does_not_halt(self):
        e = self.experiment('memory-watchdog')
        records = e.invoke('V-O', 'memory', 'W1-0001', [('W1-0001', 'C')], family='W1')
        self.assertEqual([r['class'] for r in records if r['kind'] == 'sample'], ['W'])
        self.assertIsNone(e.halted)
        self.assertEqual((e.calls, e.processes[0]['calls'], e.dead_groups, e.events), (1, 1, set(), []))

    def test_class_u_stop_halts_and_later_invocations_do_not_spawn(self):
        e = self.experiment('class-u')
        e.invoke('V-O', 'cancel', 'W9', [('W2a-03', 'C')])
        self.assertEqual((e.halted, e.calls), ('class U in cancel pass', 10))
        self.assertEqual(e.invoke('V-O', 'memory', 'W1-0001', [('W1-0001', 'C')]), [])
        self.assertEqual(len(e.processes), 1)

    def test_memory_guard_stop_marks_the_family_dead_without_halting(self):
        e = self.experiment('memory-guard')
        e.invoke('V-O', 'memory', 'W6-2844', [('W6-2844', 'C')], family='W6')
        self.assertIsNone(e.halted)
        self.assertEqual(e.dead_groups, {'W6'})

    def test_process_without_end_record_is_class_h_with_verified_cleanup(self):
        e = self.experiment('crash')
        records = e.invoke('V-D', 'reference', 'W1', [('W1-0002', 'C')])
        h = records[-1]
        self.assertEqual((h['class'], h['caseID'], h['hostCleanupVerified']), ('H', 'W1-0008', True))
        self.assertEqual(h['reason'], 'process ended without end record (exit 65)')
        self.assertEqual((e.calls, e.dead_groups, e.processes[0]['exit']), (1, {'W1'}, 65))
        self.assertIn(('pgrep', '-fl', f'Devices/{run.UDID}/.*TSUGINO.app/TSUGINO'), self.probes)

    def test_process_cap_kills_the_host_and_records_class_h(self):
        e = self.experiment('hang')
        with mock.patch.object(run, 'PROCESS_CAP', 1):
            records = e.invoke('V-O', 'timing', 'W5', [('W5-5', 'I-solver')])
        self.assertEqual((records[-1]['class'], records[-1]['caseID'], records[-1]['reason']),
                         ('H', 'W5-5', 'external 20-min cap'))
        self.assertTrue(e.processes[0]['killed'])
        self.assertIsNone(e.processes[0]['exit'])
        self.assertLess(e.processes[0]['seconds'], 10)

    def test_metadata_and_build_records_omit_battery_id_and_checkout_path(self):
        e = self.experiment('pipeline')
        meta = e.metadata()
        self.assertEqual(meta['host']['power'], "Now drawing from 'AC Power'")
        self.assertTrue(e.build('V-D'))
        recorded = json.dumps({'metadata': meta, 'processes': e.processes})
        self.assertNotIn('1234567', recorded)
        self.assertNotIn(str(run.ROOT), recorded)
        self.assertIn('<repo>/Tools/PreparedRouteMeasurement/test_run.py', e.processes[0]['command'])

    def test_call_envelope_halts_before_spawning(self):
        e = self.experiment('pipeline')
        e.calls = run.CALL_CEILING
        self.assertEqual(e.invoke('V-D', 'discovery', 'W1'), [])
        self.assertEqual((e.halted, e.processes), ('call envelope exhausted', []))

    def test_full_run_writes_schema_with_per_process_load(self):
        e = self.experiment('pipeline')
        e.raw.rmdir()
        with mock.patch.object(run.Experiment, 'build', lambda _self, variant: True):
            e.run()
        data = json.loads(run.RESULTS.read_text())
        self.assertEqual(set(data), {'metadata', 'halted', 'calls', 'processes', 'events', 'admitted', 'deadGroups', 'records'})
        tests = [p for p in data['processes'] if p['kind'] == 'test']
        # 9 discovery + 3 × 9 timed + 9 memory + 1 cancel processes.
        self.assertEqual(len(tests), 46)
        self.assertTrue(all(p['loadStart'].startswith('{') and p['loadEnd'].startswith('{') for p in tests))
        self.assertEqual(data['calls'], 45)
        self.assertIsNone(data['halted'])
        self.assertEqual(set(data['metadata']['fingerprints']), set(run.PRODUCTION + run.HARNESS))
        self.assertEqual(data['admitted']['W1'], [['W1-case', 'C']])


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--fake-host':
        fake_host()
    else:
        unittest.main()
