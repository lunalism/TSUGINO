#!/usr/bin/env python3
"""Consumer §30 bounded invented routing experiment driver.

Invented data only. One explicit iPhone Simulator, one xcodebuild at a time, serial
search calls. Never touches a physical device, provider input or private data.
Usage:
  python3 Tools/PreparedRouteMeasurement/run.py run        # builds, then the experiment
  python3 Tools/PreparedRouteMeasurement/run.py summarize  # markdown tables from results.json
"""
import datetime
import hashlib
import json
import pathlib
import statistics
import subprocess
import sys
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
RESULTS = HERE / 'results.json'
UDID = '84E47945-9D2E-446F-8C40-B835A9D15880'  # explicit iPhone 17 Simulator (§30.6)
BUNDLE = 'com.lunalism.TSUGINO'
GROUPS = ['W1', 'W2a', 'W2b', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8']
CALL_CEILING = 1506          # §30.5 envelope
WALL_SECONDS = 4 * 3600      # §30.5 total wall-clock budget
PROCESS_CAP = 20 * 60        # §30.5 per-xcodebuild cap
WATCHDOG = {'V-D': 180, 'V-O': 60}
OVERRIDES = {'V-D': [], 'V-O': ['SWIFT_OPTIMIZATION_LEVEL=-O', 'SWIFT_COMPILATION_MODE=wholemodule']}
CARRIERS = ['W7o-2880', 'W2a-08', 'W1-0256', 'W2a-03']
PRODUCTION = ['TSUGINO/Data/Routing/PreparedRouteSearcher.swift', 'TSUGINO/Data/Routing/PreparedRouteSearchView.swift',
              'TSUGINO/Data/Routing/InternalRouteSolver.swift', 'TSUGINO/Data/Routing/PreparedInternalSearchInput.swift',
              'TSUGINO/Data/Routing/QualifiedConnectionEvidence.swift',
              'TSUGINO/Data/Routing/RequestScopedSearchInputClosure.swift',
              'TSUGINO/Data/Timetable/TimetableOccurrenceInventory.swift']
HARNESS = ['TSUGINOTests/Support/PreparedRouteWorkloads.swift', 'TSUGINOTests/Support/PreparedRouteMeasurementProbe.swift',
           'TSUGINOTests/PreparedRouteWorkloadTests.swift', 'TSUGINOTests/PreparedRouteMeasurementTests.swift',
           'Tools/PreparedRouteMeasurement/run.py', 'Tools/PreparedRouteMeasurement/README.md']


def sh(*args):
    try:
        return subprocess.run(args, capture_output=True, text=True, timeout=120).stdout.strip()
    except Exception as error:  # metadata is best effort; record the failure
        return f'unavailable: {error}'


def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def simulator():
    try:
        listing = json.loads(sh('xcrun', 'simctl', 'list', 'devices', '-j'))
    except ValueError:
        return 'unavailable'
    for runtime, devices in listing.get('devices', {}).items():
        for device in devices:
            if device.get('udid') == UDID:
                return {'name': device.get('name'), 'udid': UDID, 'runtime': runtime,
                        'deviceType': device.get('deviceTypeIdentifier')}
    return 'not found'


def power_source():
    """Power source line only (`pmset -g batt` line 1); battery identifiers are never recorded."""
    lines = sh('pmset', '-g', 'batt').splitlines()
    return lines[0] if lines else 'unavailable'


def public(command):
    """Recorded command line with the checkout path replaced by `<repo>`."""
    return ' '.join(command).replace(str(ROOT), '<repo>')


def utc():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


class Experiment:
    def __init__(self):
        stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
        self.raw = pathlib.Path(f'/private/tmp/tsugino-prs-measure-{stamp}')
        self.run_id = stamp
        self.records, self.processes, self.events = [], [], []
        self.calls, self.start, self.halted = 0, None, None
        self.dead_groups = set()
        self.invocation = 0

    def log(self, text):
        line = f'[{utc()}] calls={self.calls} {text}'
        print(line, flush=True)
        with open(self.raw / 'progress.log', 'a') as handle:
            handle.write(line + '\n')

    def derived(self, variant):
        return self.raw / ('dd-debug' if variant == 'V-D' else 'dd-optimized')

    def xcodebuild(self, variant, action, extra=()):
        return ['xcodebuild', '-project', str(ROOT / 'TSUGINO.xcodeproj'), '-scheme', 'TSUGINO', '-configuration', 'Debug',
                '-destination', f'platform=iOS Simulator,id={UDID}', '-derivedDataPath', str(self.derived(variant)),
                '-parallel-testing-enabled', 'NO', *OVERRIDES[variant], *extra, action]

    def build(self, variant):
        log = self.raw / f'build-{variant}.log'
        command = self.xcodebuild(variant, 'build-for-testing')
        began = time.time()
        with open(log, 'w') as handle:
            code = subprocess.run(command, stdout=handle, stderr=subprocess.STDOUT, cwd=ROOT).returncode
        self.processes.append({'kind': 'build', 'variant': variant, 'command': public(command), 'exit': code,
                               'seconds': round(time.time() - began, 1), 'log': str(log)})
        self.log(f'build {variant} exit={code}')
        return code == 0

    def host_cleanup(self):
        sh('xcrun', 'simctl', 'terminate', UDID, BUNDLE)
        remaining = sh('pgrep', '-fl', f'Devices/{UDID}/.*TSUGINO.app/TSUGINO')
        return remaining == ''

    def invoke(self, variant, pass_name, group, cases=None, medians=None, family=None):
        """One xcodebuild test-without-building = one fresh test-host process."""
        if self.halted:
            return []
        remaining_wall = WALL_SECONDS - (time.time() - self.start)
        if self.calls >= CALL_CEILING or remaining_wall <= 0:
            self.halted = 'call envelope exhausted' if self.calls >= CALL_CEILING else 'wall-clock envelope exhausted'
            self.log(f'halt: {self.halted}')
            return []
        self.invocation += 1
        tag = f'{self.invocation:03d}-{variant}-{pass_name}-{group}'
        out, inflight, log = self.raw / f'{tag}.jsonl', self.raw / f'{tag}.inflight', self.raw / f'{tag}.log'
        env = {'TSUGINO_PRS_MEASURE': '1', 'TSUGINO_PRS_PASS': pass_name, 'TSUGINO_PRS_GROUP': group,
               'TSUGINO_PRS_OUT': str(out), 'TSUGINO_PRS_INFLIGHT': str(inflight), 'TSUGINO_PRS_VARIANT': variant,
               'TSUGINO_PRS_RUN': self.run_id, 'TSUGINO_PRS_WATCHDOG': str(WATCHDOG[variant]),
               'TSUGINO_PRS_CALL_BUDGET': str(CALL_CEILING - self.calls),
               'TSUGINO_PRS_DEADLINE': str(int(self.start + WALL_SECONDS)),
               'TSUGINO_PRS_CASES': ','.join(f'{i}={c}' for i, c in (cases or [])),
               'TSUGINO_PRS_MEDIANS': medians or ''}
        import os
        full_env = dict(os.environ)
        full_env.update({f'TEST_RUNNER_{k}': v for k, v in env.items()})
        command = self.xcodebuild(variant, 'test-without-building', ['-only-testing:TSUGINOTests/PreparedRouteMeasurementTests'])
        began = time.time()
        load_start = sh('sysctl', '-n', 'vm.loadavg')
        killed = False
        with open(log, 'w') as handle:
            try:
                code = subprocess.run(command, stdout=handle, stderr=subprocess.STDOUT, cwd=ROOT, env=full_env,
                                      timeout=min(PROCESS_CAP, max(60, remaining_wall + 60))).returncode
            except subprocess.TimeoutExpired:
                code, killed = None, True
        records = []
        if out.exists():
            for line in out.read_text().splitlines():
                if line.startswith('PRS_MEASURE '):
                    records.append(json.loads(line[len('PRS_MEASURE '):]))
        process = {'kind': 'test', 'tag': tag, 'variant': variant, 'pass': pass_name, 'group': group, 'exit': code,
                   'seconds': round(time.time() - began, 1), 'killed': killed, 'log': str(log),
                   'loadStart': load_start, 'loadEnd': sh('sysctl', '-n', 'vm.loadavg')}
        ended = any(r.get('kind') == 'end' for r in records)
        if killed or not ended:
            case = inflight.read_text().strip() if inflight.exists() else ''
            clean = self.host_cleanup()
            records.append({'kind': 'sample', 'class': 'H', 'caseID': case or None, 'family': group, 'pass': pass_name,
                            'variant': variant, 'reason': 'external 20-min cap' if killed else f'process ended without end record (exit {code})',
                            'hostCleanupVerified': clean})
            self.dead_groups.add(family or group)
            process['hostCleanupVerified'] = clean
            self.log(f'{tag}: class H case={case} cleanup={clean}')
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
                if r['reason'].startswith('class U'):
                    self.halted = r['reason']
                elif 'envelope' in r['reason']:
                    self.halted = r['reason']
                elif 'memory guard' in r['reason']:
                    self.dead_groups.add(family or group)
        self.log(f'{tag}: exit={code} calls={used} records={len(records)} {round(time.time() - began, 1)}s')
        return records

    def metadata(self):
        return {
            'utcStart': utc(), 'runID': self.run_id, 'raw': str(self.raw),
            'xcodebuild': sh('xcodebuild', '-version'), 'swift': sh('xcrun', 'swift', '--version'),
            'sdk': sh('xcrun', '--sdk', 'iphonesimulator', '--show-sdk-version'),
            'simulator': simulator(),
            'host': {'sw_vers': sh('sw_vers'), 'model': sh('sysctl', '-n', 'hw.model'),
                     'cpu': sh('sysctl', '-n', 'machdep.cpu.brand_string'), 'ncpu': sh('sysctl', '-n', 'hw.ncpu'),
                     'memsize': sh('sysctl', '-n', 'hw.memsize'), 'power': power_source(), 'load': sh('uptime')},
            'git': {'head': sh('git', '-C', str(ROOT), 'rev-parse', 'HEAD'),
                    'status': sh('git', '-C', str(ROOT), 'status', '--porcelain=v1', '--untracked-files=all')},
            'fingerprints': {p: sha(p) for p in PRODUCTION + HARNESS},
            'variants': {'V-D': 'standard Debug (-Onone, DEBUG, testability)',
                         'V-O': 'optimized DEBUG-condition test build: Debug + SWIFT_OPTIMIZATION_LEVEL=-O '
                                'SWIFT_COMPILATION_MODE=wholemodule; NOT Release'},
            'envelope': {'calls': CALL_CEILING, 'wallSeconds': WALL_SECONDS, 'processCapSeconds': PROCESS_CAP,
                         'watchdogSeconds': WATCHDOG},
        }

    def samples(self, pass_name, variant=None):
        return [r for r in self.records if r.get('kind') == 'sample' and r.get('pass') == pass_name
                and (variant is None or r.get('variant') == variant)]

    def run(self):
        if RESULTS.exists():
            raise SystemExit('results.json exists: an earlier run is preserved; move it explicitly before another run.')
        self.raw.mkdir(parents=True)
        meta = self.metadata()
        self.log(f'raw={self.raw}')
        if not (self.build('V-D') and self.build('V-O')):
            self.halted = 'build failed'
        self.start = time.time()
        meta['experimentStartUTC'] = utc()
        admitted = {}
        if not self.halted:
            for group in GROUPS:
                records = self.invoke('V-D', 'discovery', group)
                admitted[group] = [(r['caseID'], r['class']) for r in records
                                   if r.get('kind') == 'sample' and r.get('class') in ('C', 'R', 'I-prep', 'I-solver')]
        classes = {i: c for cases in admitted.values() for i, c in cases}
        for variant, pass_name in [('V-D', 'reference'), ('V-O', 'timing'), ('V-O', 'stage')]:
            for group in GROUPS:
                if admitted.get(group) and group not in self.dead_groups:
                    self.invoke(variant, pass_name, group, admitted[group])
        for group in GROUPS:
            for case, cls in admitted.get(group, []):
                if group not in self.dead_groups:
                    self.invoke('V-O', 'memory', case, [(case, cls)], family=group)
        medians = []
        for carrier in CARRIERS:
            rows = [r for r in self.samples('stage', 'V-O') if r.get('caseID') == carrier and not r.get('warmup')]
            stages = {}
            for r in rows:
                for k, v in (r.get('stageNs') or {}).items():
                    stages.setdefault(k, []).append(v)
            if stages:
                medians.append(carrier + ':' + ';'.join(f'{k}={int(statistics.median(v))}' for k, v in stages.items()))
        carriers = [(c, classes[c]) for c in CARRIERS if c in classes]
        self.invoke('V-O', 'cancel', 'W9', carriers, '|'.join(medians))
        meta['utcEnd'] = utc()
        meta['experimentSeconds'] = round(time.time() - self.start, 1)
        result = {'metadata': meta, 'halted': self.halted, 'calls': self.calls, 'processes': self.processes,
                  'events': self.events, 'admitted': admitted, 'deadGroups': sorted(self.dead_groups),
                  'records': self.records}
        RESULTS.write_text(json.dumps(result, indent=1, sort_keys=True) + '\n')
        self.log(f'done: calls={self.calls} halted={self.halted} seconds={meta["experimentSeconds"]}')


def summarize():
    data = json.loads(RESULTS.read_text())
    rows = [r for r in data['records'] if r.get('kind') == 'sample']

    def ms(values):
        values = [v / 1e6 for v in values if v is not None]
        if not values:
            return '—'
        return f'{statistics.median(values):.3f} [{min(values):.3f}–{max(values):.3f}]'
    print('| Case | Discovery class | Winners | Solver work (V-D) | V-D whole ms (n=3) | V-O whole ms (n=7) | V-O CPU ms | V-O prep ms | V-O solve ms |')
    print('|---|---|---:|---:|---:|---:|---:|---:|---:|')
    order = [r['caseID'] for r in rows if r.get('pass') == 'discovery']
    for case in order:
        disc = next(r for r in rows if r.get('pass') == 'discovery' and r.get('caseID') == case)
        def pick(p):
            return [r for r in rows if r.get('pass') == p and r.get('caseID') == case and not r.get('warmup')]
        ref, tim, stg = pick('reference'), pick('timing'), pick('stage')
        work = (disc.get('solverUsage') or {}).get('work')
        observed = (disc.get('solverUsage') or {}).get('observedAt')
        print(f"| {case} | {disc.get('class')} | {disc.get('winners', '—')} | {work if work is not None else '—'}"
              f"{'' if observed in (None, 'terminal') else ' (last at ' + observed + ')'} | {ms([r.get('wholeNs') for r in ref])} | "
              f"{ms([r.get('wholeNs') for r in tim])} | {ms([(r.get('cpuUserNs') or 0) + (r.get('cpuSystemNs') or 0) for r in tim])} | "
              f"{ms([(r.get('stageNs') or {}).get('preparation') for r in stg])} | {ms([(r.get('stageNs') or {}).get('solve') for r in stg])} |")
    print()
    print('| Case | F1−F0 MiB | peak−F1 MiB (max of 4 calls) | residual after release MiB | peak method |')
    print('|---|---:|---:|---:|---|')
    for case in order:
        mem = [r for r in rows if r.get('pass') == 'memory' and r.get('caseID') == case and r.get('memory')]
        if not mem:
            continue
        m0 = mem[0]['memory']
        mib = lambda v: f'{v / 1048576:.1f}' if isinstance(v, (int, float)) else '—'
        peak = max((r['memory'].get('peak') or 0) for r in mem)
        print(f"| {case} | {mib(m0['f1'] - m0['f0'] if m0.get('f1') and m0.get('f0') else None)} | "
              f"{mib(peak - m0['f1'] if m0.get('f1') else None)} | {mib(mem[-1]['memory'].get('released') - m0['f1'] if m0.get('f1') else None)} | "
              f"{m0.get('peakMethod')} |")
    print()
    print('| Carrier | Target | δ | n | Landing stages | Observed at | Latency ms (median [min–max]) | Throw latency ms | Outcomes |')
    print('|---|---|---:|---:|---|---|---:|---:|---|')
    cancel = [r for r in rows if r.get('pass') == 'cancel' and r.get('cancel')]
    keys = sorted({(r['caseID'], r['cancel']['target'], r['cancel']['delta']) for r in cancel})
    for case, target, delta in keys:
        group = [r for r in cancel if (r['caseID'], r['cancel']['target'], r['cancel']['delta']) == (case, target, delta)]
        landing = sorted({r['cancel'].get('landingStage', '—') for r in group})
        observed = sorted({r['cancel'].get('observedAt', '—') for r in group})
        outcomes = sorted({r['class'] for r in group})
        print(f"| {case} | {target} | {delta} | {len(group)} | {', '.join(landing)} | {', '.join(observed)} | "
              f"{ms([r['cancel'].get('latencyNs') for r in group])} | {ms([r['cancel'].get('throwLatencyNs') for r in group])} | "
              f"{', '.join(outcomes)} |")


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'run':
        Experiment().run()
    elif len(sys.argv) > 1 and sys.argv[1] == 'summarize':
        summarize()
    else:
        raise SystemExit(__doc__)
