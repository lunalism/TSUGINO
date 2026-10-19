#!/usr/bin/env python3
"""Synthetic driver tests for the §34.8 matched protocol (no xcodebuild, Simulator or device).
Usage: python3 -B -I Tools/PreparedRouteMeasurement/RelationIndex/test_run.py"""
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
    env = {k[len('TEST_RUNNER_'):]: v for k, v in os.environ.items() if k.startswith('TEST_RUNNER_')}
    out = pathlib.Path(env['TSUGINO_PRS_OUT'])
    common = {'schema': 1, 'runID': env['TSUGINO_PRS_RUN'], 'variant': env['TSUGINO_PRS_VARIANT'],
              'pass': env['TSUGINO_PRS_PASS'], 'utc': 'synthetic', 'thermalState': 'nominal'}

    def emit(**fields):
        with open(out, 'a') as handle:
            handle.write('PRS_MEASURE ' + json.dumps({**common, **fields}) + '\n')
    scenario, calls = env['FAKE_SCENARIO'], 0
    if env['TSUGINO_PRS_PASS'] == 'discovery':
        for case in env['TSUGINO_PRS_ONLY'].split(','):
            tree = env['TSUGINO_PRS_VARIANT'].split('/')[0]
            cls = dict(run.CASES_BY_TREE[tree])[case]
            if scenario == 'drift' and tree == 'optimized' and case == 'W5-5':
                cls = 'I-solver'  # predicted to complete
            emit(kind='sample', caseID=case, **{'class': cls}); calls += 1
    else:
        reps = int(env['TSUGINO_PRS_REPS'])
        for case, cls in (item.split('=') for item in env['TSUGINO_PRS_CASES'].split(',')):
            for rep in range(-1, reps):
                emit(kind='sample', caseID=case, **{'class': cls}, repetition=rep, warmup=rep < 0); calls += 1
    emit(kind='end', calls=calls, stopped=False)


class MatchedDriverTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        patches = [mock.patch.object(run.base, 'sh', lambda *a: '{ 1.00 1.00 1.00 }' if a[:2] == ('sysctl', '-n') else ''),
                   mock.patch.object(run.Matched, 'xcodebuild', self.fake_xcodebuild)]
        for p in patches:
            p.start()
            self.addCleanup(p.stop)

    @staticmethod
    def fake_xcodebuild(_m, tree, variant, action, extra=()):
        return [sys.executable, '-B', str(pathlib.Path(__file__).resolve()), '--fake-host']

    def matched(self, scenario):
        os.environ['TEST_RUNNER_FAKE_SCENARIO'] = scenario
        self.addCleanup(os.environ.pop, 'TEST_RUNNER_FAKE_SCENARIO', None)
        m = run.Matched(raw=pathlib.Path(self.tmp.name) / 'raw')
        m.raw.mkdir()
        m.start = time.time()
        return m

    def execute(self, m):
        admitted = {}
        for variant, pass_name, tree, rnd in run.PLAN:
            if pass_name == 'discovery':
                m.invoke(tree, variant, pass_name, rnd, run.CASES_BY_TREE[tree])
                admitted[tree] = m.admitted(tree)
            else:
                m.invoke(tree, variant, pass_name, rnd, admitted.get(tree) or run.CASES_BY_TREE[tree])
        return admitted

    def test_trees_use_their_own_predicted_classes(self):
        m = self.matched('ok')
        admitted = self.execute(m)
        self.assertEqual(dict(admitted['baseline'])['W5-5'], 'I-solver')
        self.assertEqual(dict(admitted['optimized'])['W5-5'], 'C')
        self.assertEqual(dict(admitted['optimized'])['W8-004M'], 'I-solver')

    def test_plan_alternates_and_uses_exactly_the_envelope(self):
        m = self.matched('ok')
        self.execute(m)
        self.assertEqual([(p['tree'], p['variant'], p['pass'], p['round']) for p in m.processes],
                         [('baseline', 'V-D', 'discovery', 0), ('optimized', 'V-D', 'discovery', 0),
                          ('baseline', 'V-O', 'timing', 1), ('optimized', 'V-O', 'timing', 1),
                          ('baseline', 'V-O', 'stage', 1), ('optimized', 'V-O', 'stage', 1),
                          ('optimized', 'V-O', 'timing', 2), ('baseline', 'V-O', 'timing', 2),
                          ('optimized', 'V-O', 'stage', 2), ('baseline', 'V-O', 'stage', 2)])
        self.assertEqual((m.calls, m.halted), (run.CALL_CEILING, None))
        self.assertTrue(all(p['loadStart'] and p['loadEnd'] for p in m.processes))

    def test_class_drift_after_discovery_halts_before_timing(self):
        m = self.matched('drift')
        self.execute(m)
        self.assertIn('optimized discovery classes', m.halted)
        self.assertEqual(len(m.processes), 2)

    def test_call_envelope_halts_before_spawning(self):
        m = self.matched('ok')
        m.calls = run.CALL_CEILING
        self.assertEqual(m.invoke('baseline', 'V-O', 'timing', 1, run.CASES), [])
        self.assertEqual((m.halted, m.processes), ('call envelope exhausted', []))

    def test_recorded_commands_hide_checkout_and_raw_paths(self):
        m = self.matched('ok')
        command = ['xcodebuild', '-project', str(run.ROOT / 'TSUGINO.xcodeproj'), '-derivedDataPath', str(m.raw / 'dd')]
        self.assertEqual(m.record_command(command), 'xcodebuild -project <repo>/TSUGINO.xcodeproj -derivedDataPath <raw>/dd')


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--fake-host':
        fake_host()
    else:
        unittest.main()
