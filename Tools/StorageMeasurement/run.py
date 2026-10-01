#!/usr/bin/env python3
"""Synthetic-only benchmark orchestration; never searches for provider inputs."""
import datetime
import hashlib
import json
import os
import pathlib
import platform
import plistlib
import shutil
import sqlite3
import statistics
import subprocess

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
BINARY = HERE / '.build/storage-measurement'
OUT = HERE / '.build/run'

def invoke(*args):
    result = subprocess.run([str(BINARY), *map(str, args)], check=True, capture_output=True, text=True)
    return json.loads(result.stdout)

def reject(kind, path):
    result = subprocess.run([str(BINARY), 'read', kind, str(path), '258'], capture_output=True)
    assert result.returncode != 0, 'unsupported/malformed file accepted'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def command(*args):
    return subprocess.check_output(args, text=True).strip()

if OUT.exists():
    raise SystemExit('Existing run preserved. Move .build/run explicitly before another run.')
OUT.mkdir(parents=True)
results = {'environment': {
    'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'os': command('sw_vers'), 'machine': platform.machine(),
    'cpu': command('sysctl', '-n', 'machdep.cpu.brand_string'),
    'ram_bytes': command('sysctl', '-n', 'hw.memsize'),
    'swift': command('xcrun', 'swiftc', '--version'),
    'sdk': command('xcrun', '--show-sdk-version'),
    'sqlite': command('/usr/bin/sqlite3', ':memory:', 'select sqlite_version();'),
    'configuration': 'Swift -O, language mode 5, native macOS command line',
    'repetitions': 5, 'cold_definition': 'fresh process; OS caches uncontrolled',
}, 'samples': [], 'checks': [], 'fixtures': {}, 'fingerprints': {}}
for n in (258, 25800):
    source = OUT / f'fixture-{n}.json'
    invoke('generate', n, source)
    results['fixtures'][str(n)] = {'sha256': digest(source), 'bytes': source.stat().st_size,
                                   'stations': n, 'lines': n // 258 * 15,
                                   'operators': n // 258 * 2, 'aliases': n // 258 * 6}
    for rep in range(5):
        order = ('compact', 'sqlite') if rep % 2 == 0 else ('sqlite', 'compact')
        for kind in order:
            artifact = OUT / f'{n}-{rep}.{kind}'
            prep = invoke('prepare', kind, artifact, source)
            # Timings precede oracle verification to avoid an extra explicit cache warmup.
            read = invoke('read', kind, artifact, n)
            load = invoke('load', kind, artifact)
            check = invoke('verify', kind, artifact, source)
            assert prep['full_fixture_parses'] == 1
            assert read['full_fixture_parses'] == 0
            assert read['cache_count'] <= 256
            assert load['stations'] == n and load['record_decodes'] == n
            results['samples'].append({'size': n, 'backend': kind, 'repetition': rep,
                                       'artifact_bytes': artifact.stat().st_size,
                                       'prepare': prep, 'read': read, 'load': load})
            results['checks'].append({'size': n, 'backend': kind, 'repetition': rep, **check})
            print(f'{n} {kind} repetition {rep + 1}: verified', flush=True)
    # Compare repeated logical checksums across both adapters and all repetitions.
    assert len({r['read']['checksum'] for r in results['samples'] if r['size'] == n}) == 1
# Version and framing regressions use new synthetic copies only.
compact = (OUT / '258-0.compact').read_bytes()
header_size = int.from_bytes(compact[:8], 'big')
directory = plistlib.loads(compact[8:8+header_size])
for field, value in (('schema', 999), ('dataVersion', 'future-version')):
    changed = dict(directory); changed[field] = value
    header = plistlib.dumps(changed, fmt=plistlib.FMT_BINARY)
    path = OUT / f'unsupported-{field}.compact'
    path.write_bytes(len(header).to_bytes(8, 'big') + header + compact[8+header_size:])
    reject('compact', path)
for label, data in [('short', b'bad'), ('oversized-directory', (2**63).to_bytes(8, 'big'))]:
    path = OUT / f'{label}.compact'; path.write_bytes(data); reject('compact', path)
for kind in ('compact', 'sqlite'):
    path = OUT / f'oversized.{kind}'
    with path.open('wb') as f:
        f.truncate(256 * 1024 * 1024 + 1)
    reject(kind, path)
    path.unlink()
for label, sql in [('schema', 'PRAGMA user_version=999'),
                   ('data', "UPDATE metadata SET value=x'667574757265' WHERE key='dataVersion'")]:
    path = OUT / f'unsupported-{label}.sqlite'; shutil.copyfile(OUT / '258-0.sqlite', path)
    with sqlite3.connect(path) as db:
        db.execute(sql)
    reject('sqlite', path)
results['negative_checks'] = 8
# Fingerprint all compiled Swift inputs plus the prototype/method, no absolute paths.
paths = list((ROOT / 'TSUGINO/Data/Mapping').glob('*.swift'))
paths += list((ROOT / 'TSUGINO/Domain/Search').glob('*.swift'))
paths += list((ROOT / 'TSUGINO/Data/Search').glob('*.swift'))
paths += [ROOT / 'TSUGINO/Domain/Identifiers/CanonicalIdentifiers.swift']
paths += [ROOT / f'TSUGINO/Domain/Railway/{name}.swift' for name in
          ('GeoCoordinate', 'StationAdjacency', 'RailwayLineTopology', 'LocalizedRailName', 'Operator', 'Station', 'RailwayLine')]
paths += [HERE / p for p in ('main.swift', 'build.sh', 'run.py', 'README.md', 'CSQLite/shim.h', 'CSQLite/module.modulemap')]
results['fingerprints'] = {str(p.relative_to(ROOT)): digest(p) for p in sorted(paths)}
results['binary_sha256'] = digest(BINARY)
results['summary'] = {}
for n in (258, 25800):
    for kind in ('compact', 'sqlite'):
        samples = [r for r in results['samples'] if r['size'] == n and r['backend'] == kind]
        summary = {}
        for group in ('prepare', 'read', 'load'):
            for metric in samples[0][group]:
                values = [r[group][metric] for r in samples]
                summary[f'{group}.{metric}'] = {'median': statistics.median(values), 'min': min(values), 'max': max(values)}
        summary['artifact_bytes'] = {'median': statistics.median([r['artifact_bytes'] for r in samples]),
                                     'min': min(r['artifact_bytes'] for r in samples), 'max': max(r['artifact_bytes'] for r in samples)}
        results['summary'][f'{n}-{kind}'] = summary
(HERE / 'results.json').write_text(json.dumps(results, ensure_ascii=False, indent=2) + '\n')
print('All comparison checks passed; aggregate results.json written.')
