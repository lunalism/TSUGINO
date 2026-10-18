#!/usr/bin/env python3
"""Consumer §32.6 matched winner-ordering validation driver.

Baseline = production source at BASE_COMMIT; optimized = the working tree. Both trees are
exported to the raw-evidence directory with identical harness bytes, so only the solver differs.
Invented data only; one explicit iPhone Simulator; strictly serial; never touches a device.
Usage:
  python3 -B Tools/PreparedRouteMeasurement/WinnerOrdering/run.py validate   # harness validation (4 calls, dev build)
  python3 -B Tools/PreparedRouteMeasurement/WinnerOrdering/run.py run        # builds, then the matched protocol
  python3 -B Tools/PreparedRouteMeasurement/WinnerOrdering/run.py summarize  # markdown tables from results.json
"""
import datetime
import hashlib
import json
import os
import pathlib
import shutil
import statistics
import subprocess
import sys
import time

import importlib.util

HERE = pathlib.Path(__file__).resolve().parent
# §31 driver helpers (sh, power_source, simulator, utc, UDID, BUNDLE), loaded under a distinct name.
_spec = importlib.util.spec_from_file_location('prs_measurement_run', HERE.parent / 'run.py')
base = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(base)

ROOT = HERE.parent.parent.parent
RESULTS = HERE / 'results.json'
PREDICTIONS = HERE / 'predictions.json'
BASE_COMMIT = '3368eb13d102831ba473b84e13cb0f0329451cf6'
SOLVER = 'TSUGINO/Data/Routing/InternalRouteSolver.swift'
HARNESS = ['TSUGINOTests/PreparedRouteMeasurementTests.swift', 'TSUGINOTests/Support/PreparedRouteMeasurementProbe.swift',
           'TSUGINOTests/Support/PreparedRouteWorkloads.swift']
# §32.6 matched subset with its §31 discovery classes (results.json, run 20261016T190846Z).
CASES = [('W1-0064', 'C'), ('W1-0128', 'C'), ('W1-0256', 'C'), ('W1-0257', 'I-solver'), ('W2a-08', 'C'),
         ('W2a-09', 'C'), ('W2a-10', 'I-solver'), ('W2b-5', 'C'), ('W3-025', 'C'), ('W5-4', 'C')]
TARGETS = ['W1-0128', 'W1-0256']
TREES = ['baseline', 'optimized']
CALL_CEILING = 660           # §32.6 envelope: 320 timing + 320 stage + 20 V-D
WALL_SECONDS = 2 * 3600      # §32.6 total experiment wall clock
PROCESS_CAP = 20 * 60
WATCHDOG = {'V-D': 180, 'V-O': 60}
OVERRIDES = {'V-D': [], 'V-O': ['SWIFT_OPTIMIZATION_LEVEL=-O', 'SWIFT_COMPILATION_MODE=wholemodule']}
REPS = 7
# Discovery (V-D, hooked) for both trees, then two alternated V-O rounds.
PLAN = ([('V-D', 'discovery', t, 0) for t in TREES]
        + [('V-O', p, t, 1) for p in ('timing', 'stage') for t in TREES]
        + [('V-O', p, t, 2) for p in ('timing', 'stage') for t in reversed(TREES)])


def sha(path):
    return hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()


def tree_digest(tree):
    """SHA-256 over the sorted (path, file SHA-256) list of the exported source tree."""
    h = hashlib.sha256()
    for p in sorted(q for q in tree.rglob('*') if q.is_file()):
        h.update(f'{p.relative_to(tree)}\0{sha(p)}\n'.encode())
    return h.hexdigest()


class Matched:
    def __init__(self, raw=None):
        stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
        self.run_id = stamp
        self.raw = pathlib.Path(raw or f'/private/tmp/tsugino-ordering-{stamp}')
        self.records, self.processes, self.events = [], [], []
        self.calls, self.start, self.halted, self.invocation = 0, None, None, 0
        self.trees = {}

    def log(self, text):
        line = f'[{base.utc()}] calls={self.calls} {text}'
        print(line, flush=True)
        with open(self.raw / 'progress.log', 'a') as handle:
            handle.write(line + '\n')

    def export(self):
        """Baseline: git archive of BASE_COMMIT plus the working harness bytes. Optimized: git archive
        of HEAD plus every modified/untracked working file. Neither build touches the checkout."""
        changed = base.sh('git', '-C', str(ROOT), 'ls-files', '-m', '-o', '--exclude-standard').splitlines()
        for name, commit, overlay in (('baseline', BASE_COMMIT, HARNESS), ('optimized', 'HEAD', changed)):
            tree = self.raw / f'{name}-src'
            tree.mkdir(parents=True)
            archive = subprocess.run(['git', '-C', str(ROOT), 'archive', commit], capture_output=True, check=True).stdout
            subprocess.run(['tar', '-x', '-C', str(tree)], input=archive, check=True)
            for rel in overlay:
                if (ROOT / rel).is_file():
                    (tree / rel).parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(ROOT / rel, tree / rel)
            self.trees[name] = tree
        b, o = self.trees['baseline'], self.trees['optimized']
        same_harness = all(sha(b / h) == sha(o / h) for h in HARNESS)
        base_solver = subprocess.run(['git', '-C', str(ROOT), 'show', f'{BASE_COMMIT}:{SOLVER}'], capture_output=True, check=True).stdout
        return {'baseCommit': BASE_COMMIT, 'optimizedOverlay': sorted(changed), 'harnessIdentical': same_harness,
                'baselineSolverIsBaseCommit': hashlib.sha256(base_solver).hexdigest() == sha(b / SOLVER),
                'fingerprints': {name: {'solver': sha(t / SOLVER), **{h: sha(t / h) for h in HARNESS}, 'treeDigest': tree_digest(t)}
                                 for name, t in self.trees.items()}}

    def derived(self, tree, variant):
        return self.raw / f'dd-{tree}-{"debug" if variant == "V-D" else "optimized"}'

    def xcodebuild(self, tree, variant, action, extra=()):
        return ['xcodebuild', '-project', str(self.trees[tree] / 'TSUGINO.xcodeproj'), '-scheme', 'TSUGINO',
                '-configuration', 'Debug', '-destination', f'platform=iOS Simulator,id={base.UDID}',
                '-derivedDataPath', str(self.derived(tree, variant)), '-parallel-testing-enabled', 'NO',
                *OVERRIDES[variant], *extra, action]

    def record_command(self, command):
        return ' '.join(command).replace(str(ROOT), '<repo>').replace(str(self.raw), '<raw>')

    def build(self, tree, variant):
        log = self.raw / f'build-{tree}-{variant}.log'
        command = self.xcodebuild(tree, variant, 'build-for-testing')
        began = time.time()
        with open(log, 'w') as handle:
            code = subprocess.run(command, stdout=handle, stderr=subprocess.STDOUT).returncode
        self.processes.append({'kind': 'build', 'tree': tree, 'variant': variant, 'command': self.record_command(command),
                               'exit': code, 'seconds': round(time.time() - began, 1)})
        self.log(f'build {tree} {variant} exit={code}')
        return code == 0

    def invoke(self, tree, variant, pass_name, round_no, cases, label='matched', command=None):
        """One xcodebuild test-without-building = one fresh test-host process."""
        if self.halted:
            return []
        remaining_wall = WALL_SECONDS - (time.time() - self.start)
        if self.calls >= CALL_CEILING or remaining_wall <= 0:
            self.halted = 'call envelope exhausted' if self.calls >= CALL_CEILING else 'wall-clock envelope exhausted'
            self.log(f'halt: {self.halted}')
            return []
        self.invocation += 1
        tag = f'{self.invocation:03d}-{tree}-{variant}-{pass_name}-r{round_no}'
        out, inflight, log = self.raw / f'{tag}.jsonl', self.raw / f'{tag}.inflight', self.raw / f'{tag}.log'
        env = {'TSUGINO_PRS_MEASURE': '1', 'TSUGINO_PRS_PASS': pass_name, 'TSUGINO_PRS_GROUP': 'matched',
               'TSUGINO_PRS_OUT': str(out), 'TSUGINO_PRS_INFLIGHT': str(inflight), 'TSUGINO_PRS_VARIANT': f'{tree}/{variant}',
               'TSUGINO_PRS_RUN': self.run_id, 'TSUGINO_PRS_WATCHDOG': str(WATCHDOG[variant]),
               'TSUGINO_PRS_CALL_BUDGET': str(CALL_CEILING - self.calls), 'TSUGINO_PRS_DEADLINE': str(int(self.start + WALL_SECONDS)),
               'TSUGINO_PRS_CASES': ','.join(f'{i}={c}' for i, c in cases) if pass_name != 'discovery' else '',
               'TSUGINO_PRS_ONLY': ','.join(i for i, _ in cases) if pass_name == 'discovery' else '',
               'TSUGINO_PRS_REPS': str(REPS) if pass_name != 'discovery' else '', 'TSUGINO_PRS_MEDIANS': ''}
        full_env = dict(os.environ)
        full_env.update({f'TEST_RUNNER_{k}': v for k, v in env.items()})
        command = command or self.xcodebuild(tree, variant, 'test-without-building',
                                             ['-only-testing:TSUGINOTests/PreparedRouteMeasurementTests'])
        began = time.time()
        load_start = base.sh('sysctl', '-n', 'vm.loadavg')
        killed = False
        with open(log, 'w') as handle:
            try:
                code = subprocess.run(command, stdout=handle, stderr=subprocess.STDOUT, env=full_env,
                                      timeout=min(PROCESS_CAP, max(60, remaining_wall + 60))).returncode
            except subprocess.TimeoutExpired:
                code, killed = None, True
        records = []
        if out.exists():
            for line in out.read_text().splitlines():
                if line.startswith('PRS_MEASURE '):
                    records.append({**json.loads(line[len('PRS_MEASURE '):]), 'tree': tree, 'round': round_no, 'label': label})
        process = {'kind': 'test', 'tag': tag, 'tree': tree, 'variant': variant, 'pass': pass_name, 'round': round_no,
                   'label': label, 'exit': code, 'seconds': round(time.time() - began, 1), 'killed': killed,
                   'loadStart': load_start, 'loadEnd': base.sh('sysctl', '-n', 'vm.loadavg')}
        if killed or not any(r.get('kind') == 'end' for r in records):
            case = inflight.read_text().strip() if inflight.exists() else ''
            base.sh('xcrun', 'simctl', 'terminate', base.UDID, base.BUNDLE)
            clean = base.sh('pgrep', '-fl', f'Devices/{base.UDID}/.*TSUGINO.app/TSUGINO') == ''
            records.append({'kind': 'sample', 'class': 'H', 'caseID': case or None, 'tree': tree, 'round': round_no,
                            'pass': pass_name, 'variant': f'{tree}/{variant}', 'label': label, 'hostCleanupVerified': clean,
                            'reason': 'external 20-min cap' if killed else f'process ended without end record (exit {code})'})
            self.halted = self.halted or f'class H in {tag}'
            process['hostCleanupVerified'] = clean
        used = next((r.get('calls') for r in records if r.get('kind') == 'end'), None)
        if used is None:
            used = sum(1 for r in records if r.get('kind') == 'sample' and r.get('class') not in ('S', 'H'))
        self.calls += used
        process['calls'] = used
        self.processes.append(process)
        self.records.extend(records)
        for r in records:
            if r.get('kind') == 'stop':
                self.events.append({'tag': tag, **r})
                self.halted = self.halted or r['reason']
        self.log(f'{tag}: exit={code} calls={used} records={len(records)} {process["seconds"]}s')
        return records

    def metadata(self):
        return {'utcStart': base.utc(), 'runID': self.run_id, 'raw': str(self.raw),
                'xcodebuild': base.sh('xcodebuild', '-version'), 'swift': base.sh('xcrun', 'swift', '--version'),
                'sdk': base.sh('xcrun', '--sdk', 'iphonesimulator', '--show-sdk-version'), 'simulator': base.simulator(),
                'host': {'sw_vers': base.sh('sw_vers'), 'model': base.sh('sysctl', '-n', 'hw.model'),
                         'cpu': base.sh('sysctl', '-n', 'machdep.cpu.brand_string'), 'ncpu': base.sh('sysctl', '-n', 'hw.ncpu'),
                         'memsize': base.sh('sysctl', '-n', 'hw.memsize'), 'power': base.power_source(),
                         'load': base.sh('sysctl', '-n', 'vm.loadavg')},
                'git': {'head': base.sh('git', '-C', str(ROOT), 'rev-parse', 'HEAD'),
                        'status': base.sh('git', '-C', str(ROOT), 'status', '--porcelain=v1', '--untracked-files=all')},
                'variants': {'V-D': 'standard Debug (-Onone, DEBUG, testability)',
                             'V-O': 'optimized DEBUG-condition test build: Debug + SWIFT_OPTIMIZATION_LEVEL=-O '
                                    'SWIFT_COMPILATION_MODE=wholemodule; NOT Release'},
                'envelope': {'calls': CALL_CEILING, 'wallSeconds': WALL_SECONDS, 'processCapSeconds': PROCESS_CAP,
                             'watchdogSeconds': WATCHDOG, 'reps': REPS},
                'plan': [list(p) for p in PLAN], 'predictionsSHA256': sha(PREDICTIONS)}

    def admitted(self, tree):
        rows = [r for r in self.records if r.get('kind') == 'sample' and r.get('pass') == 'discovery' and r.get('tree') == tree]
        got = [(r['caseID'], r['class']) for r in rows]
        if got != CASES:
            self.halted = self.halted or f'{tree} discovery classes {got} differ from the §31 classes'
        return got

    def run(self):
        if RESULTS.exists():
            raise SystemExit('results.json exists: an earlier run is preserved; move it explicitly before another run.')
        self.raw.mkdir(parents=True)
        provenance = self.export()
        meta = self.metadata()
        meta['provenance'] = provenance
        self.log(f'raw={self.raw} provenance={json.dumps(provenance)[:300]}')
        if not (provenance['harnessIdentical'] and provenance['baselineSolverIsBaseCommit']):
            self.halted = 'source provenance check failed'
        for tree in TREES:
            for variant in ('V-D', 'V-O'):
                if not self.halted and not self.build(tree, variant):
                    self.halted = f'build failed: {tree} {variant}'
        self.start = time.time()
        meta['experimentStartUTC'] = base.utc()
        admitted = {}
        for variant, pass_name, tree, round_no in PLAN:
            if pass_name == 'discovery':
                self.invoke(tree, variant, pass_name, round_no, CASES)
                admitted[tree] = self.admitted(tree)
            else:
                self.invoke(tree, variant, pass_name, round_no, admitted.get(tree) or CASES)
        meta['utcEnd'] = base.utc()
        meta['experimentSeconds'] = round(time.time() - self.start, 1)
        result = {'metadata': meta, 'halted': self.halted, 'calls': self.calls, 'processes': self.processes,
                  'events': self.events, 'admitted': admitted, 'records': self.records}
        RESULTS.write_text(json.dumps(result, indent=1, sort_keys=True) + '\n')
        self.log(f'done: calls={self.calls} halted={self.halted} seconds={meta["experimentSeconds"]}')

    def validate(self, derived):
        """Harness validation on an existing dev build (not a matched build): 4 calls on cases outside
        the matched subset, recorded separately and never counted as measurement."""
        self.raw.mkdir(parents=True)
        self.trees['optimized'] = ROOT
        self.start = time.time()
        for pass_name, cases in (('discovery', [('W1-0001', 'C'), ('W5-1', 'C')]), ('timing', [('W1-0001', 'C')])):
            command = ['xcodebuild', '-project', str(ROOT / 'TSUGINO.xcodeproj'), '-scheme', 'TSUGINO', '-configuration', 'Debug',
                       '-destination', f'platform=iOS Simulator,id={base.UDID}', '-derivedDataPath', str(derived),
                       '-parallel-testing-enabled', 'NO', '-only-testing:TSUGINOTests/PreparedRouteMeasurementTests',
                       'test-without-building']
            saved = globals()['REPS']
            globals()['REPS'] = 1
            try:
                self.invoke('optimized', 'V-D', pass_name, 0, cases, label='validation', command=command)
            finally:
                globals()['REPS'] = saved
        print(json.dumps({'calls': self.calls, 'halted': self.halted,
                          'samples': [(r.get('pass'), r.get('caseID'), r.get('class'), r.get('repetition'), r.get('winnerDigest'))
                                      for r in self.records if r.get('kind') == 'sample']}, indent=1))


def summarize():
    data = json.loads(RESULTS.read_text())
    prior = json.loads((HERE.parent / 'results.json').read_text())
    digests = {r['caseID']: r.get('winnerDigest') for r in prior['records'] if r.get('pass') == 'discovery' and r.get('kind') == 'sample'}
    pred = json.loads(PREDICTIONS.read_text())
    rows = [r for r in data['records'] if r.get('kind') == 'sample' and r.get('label', 'matched') == 'matched']

    def med(values):
        values = [v for v in values if v is not None]
        return statistics.median(values) / 1e6 if values else None

    def fmt(values):
        values = [v / 1e6 for v in values if v is not None]
        return f'{statistics.median(values):.3f} [{min(values):.3f}–{max(values):.3f}]' if values else '—'
    print('| Case | Tree | Class | Winners | Digest = §31 | Solver work (V-D) | Predicted | Last observed |')
    print('|---|---|---|---:|---|---:|---:|---|')
    for case, _ in CASES:
        for tree in TREES:
            r = next((x for x in rows if x['pass'] == 'discovery' and x['tree'] == tree and x['caseID'] == case), None)
            if not r:
                continue
            u = r.get('solverUsage') or {}
            p = pred[case][tree]
            same = '—' if r.get('winnerDigest') is None and digests.get(case) is None else ('yes' if r.get('winnerDigest') == digests.get(case) else 'NO')
            print(f"| {case} | {tree} | {r['class']} | {r.get('winners', '—')} | {same} | {u.get('work')} | {p['work']} "
                  f"{'(=)' if u.get('work') == p['work'] else '(≠)'} | {u.get('observedAt')} |")
    print()
    print('| Case | Tree | V-D ordering segment ms | V-D solve ms |')
    print('|---|---|---:|---:|')
    for case, _ in CASES:
        for tree in TREES:
            r = next((x for x in rows if x['pass'] == 'discovery' and x['tree'] == tree and x['caseID'] == case), None)
            if not r:
                continue
            e = r.get('solverStageEntryNs') or {}
            seg = (e['admission'] - e['ordering']) / 1e6 if 'ordering' in e and 'admission' in e else None
            print(f"| {case} | {tree} | {'—' if seg is None else f'{seg:.2f}'} | {(r.get('stageNs') or {}).get('solve', 0) / 1e6:.2f} |")
    print()
    print('| Case | Round | Baseline stage solve ms | Optimized stage solve ms | Ratio | Baseline whole ms | Optimized whole ms |')
    print('|---|---:|---:|---:|---:|---:|---:|')
    verdict = {}
    for case, _ in CASES:
        for rnd in (1, 2):
            def pick(tree, pass_name, key, sub=None):
                return [((x.get(key) or {}).get(sub) if sub else x.get(key)) for x in rows
                        if x['pass'] == pass_name and x['tree'] == tree and x['caseID'] == case and x.get('round') == rnd and not x.get('warmup')]
            bs, os_ = pick('baseline', 'stage', 'stageNs', 'solve'), pick('optimized', 'stage', 'stageNs', 'solve')
            bw, ow = pick('baseline', 'timing', 'wholeNs'), pick('optimized', 'timing', 'wholeNs')
            ratio = (med(os_) / med(bs)) if med(bs) and med(os_) is not None else None
            if case in TARGETS:
                verdict.setdefault(case, []).append(ratio is not None and ratio <= 0.5)
            print(f"| {case} | {rnd} | {fmt(bs)} | {fmt(os_)} | {'—' if ratio is None else f'{ratio:.3f}'} | {fmt(bw)} | {fmt(ow)} |")
    print()
    for case in TARGETS:
        ok = verdict.get(case, [])
        print(f'{case}: stage-solve median ratio ≤ 0.5 in both rounds: {"MET" if len(ok) == 2 and all(ok) else "NOT MET"} ({ok})')
    print(f"calls={data['calls']} halted={data['halted']} seconds={data['metadata'].get('experimentSeconds')}")


if __name__ == '__main__':
    command = sys.argv[1] if len(sys.argv) > 1 else ''
    if command == 'run':
        Matched().run()
    elif command == 'validate' and len(sys.argv) > 2:
        Matched().validate(pathlib.Path(sys.argv[2]))
    elif command == 'summarize':
        summarize()
    else:
        raise SystemExit(__doc__)
