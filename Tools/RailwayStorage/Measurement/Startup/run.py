#!/usr/bin/env python3
"""Run only the explicitly named Simulator; never enumerate physical devices."""
import argparse, hashlib, json, pathlib, subprocess, time
p=argparse.ArgumentParser()
p.add_argument('--simulator', required=True)
p.add_argument('--app', required=True, type=pathlib.Path)
p.add_argument('--artifact', required=True, type=pathlib.Path)
p.add_argument('--output', required=True, type=pathlib.Path)
a=p.parse_args()
a.output=a.output.resolve()
a.output.mkdir(parents=True, exist_ok=False)
def run(*args, check=True):
    result = subprocess.run(args, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if check and result.returncode:
        raise RuntimeError(result.stdout)
    return result
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
bundle='com.lunalism.TSUGINO'
run('xcrun','simctl','install',a.simulator,str(a.app.resolve()))
container=pathlib.Path(run('xcrun','simctl','get_app_container',a.simulator,bundle,'data').stdout.strip())
dest=container/'Documents'/'StartupMeasurement'
dest.mkdir(parents=True,exist_ok=True)
(dest/'railway.sqlite').write_bytes(a.artifact.read_bytes())
metadata={'simulator':a.simulator,'artifactSHA256':sha(a.artifact),'artifactBytes':a.artifact.stat().st_size,
          'executableSHA256':sha(a.app/'TSUGINO'),'samples':[]}
(a.output/'identity.json').write_text(json.dumps(metadata,indent=2))
for i in range(5):
    for mode in (['baseline','enabled'] if i%2==0 else ['enabled','baseline']):
        run('xcrun','simctl','terminate',a.simulator,bundle,check=False)
        time.sleep(2)
        key=f'{mode}-{i}'
        capture=run('xcrun','xctrace','record','--template','App Launch','--device',a.simulator,
                    '--output',str((a.output/f'{key}.trace').resolve()),'--time-limit','6s',
                    '--launch','--',bundle,'--repository-startup',mode,str(i),check=False)
        (a.output/f'{key}.log').write_text(capture.stdout)
        if capture.returncode: raise SystemExit(f'Capture failed: {key}; see retained log')
        probe=dest/f'{key}.json'
        if not probe.exists(): raise SystemExit(f'Missing probe: {key}')
        data=json.loads(probe.read_text())
        if data['status']!='ok': raise SystemExit(f'Probe failed: {key}')
        (a.output/f'{key}.json').write_bytes(probe.read_bytes())
        metadata['samples'].append(data)
        (a.output/'identity.json').write_text(json.dumps(metadata,indent=2))
        print(f'Completed {key}',flush=True)
assert sha(dest/'railway.sqlite')==metadata['artifactSHA256']
run('xcrun','simctl','terminate',a.simulator,bundle,check=False)
