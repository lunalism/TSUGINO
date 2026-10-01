#!/usr/bin/env python3
"""Fresh-process measurements, serial execution; invented artifacts only."""
import hashlib,json,platform,statistics,subprocess,time,tempfile,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
BIN=HERE.parent/'.build/repository-measurement'
OUT=Path(tempfile.mkdtemp(prefix='tsugino-validated-repository-'))
PROGRESS=HERE.parent/'.build/validated-measurement-progress.json'
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def command(*args): return subprocess.check_output(args,text=True).strip()
def call(mode,scale,case,path):
    result=subprocess.run([str(BIN),mode,str(scale),case,str(path)],capture_output=True,text=True)
    if result.returncode:
        (OUT/'failure.log').write_text(result.stdout+'\n'+result.stderr)
        raise RuntimeError(f'{mode}/{scale}/{case} failed; inspect ignored failure.log')
    return json.loads(result.stdout)
samples=[]; fingerprints={}
if '--summarize-only' in sys.argv:
    samples=json.loads(PROGRESS.read_text())
else:
    for repetition in range(5):
        for scale in [1,100]:
            for case in (['baseline','history'] if repetition%2==0 else ['history','baseline']):
                root=OUT/f'{scale}-{case}-{repetition}';root.mkdir()
                path=root/('package' if case=='history' else 'railway.sqlite')
                prep=call('prepare',scale,case,path)
                artifact=path/'railway.sqlite' if case=='history' else path
                before=digest(artifact)
                key=f'{scale}-{case}'
                if key in fingerprints: assert fingerprints[key]==before, 'nondeterministic artifact'
                previous_results=HERE/'before-membership-fix.json'
                if previous_results.exists():
                    original=json.loads(previous_results.read_text())
                    expected=next(x['artifactSHA256'] for x in original['samples'] if x['scale']==scale and x['case']==case)
                    assert before==expected, 'validation optimization changed artifact bytes'
                fingerprints[key]=before
                ordinary=call('ordinary',scale,case,artifact)
                full=call('full',scale,case,artifact)
                assert digest(artifact)==before,'read mutated artifact'
                assert ordinary['consumedResults']==2688,'query result counts differ'
                sample={'repetition':repetition,'scale':scale,'case':case,'artifactBytes':artifact.stat().st_size,'artifactSHA256':before,'prepare':prep,'ordinary':ordinary,'full':full}
                samples.append(sample)
                PROGRESS.write_text(json.dumps(samples,indent=2))
                print(f"sample {len(samples)}/20: {key} open={ordinary['openMs']:.2f}ms",flush=True)
def stats(values):return {'min':min(values),'median':statistics.median(values),'max':max(values)}
summary={}
for scale in [1,100]:
 for case in ['baseline','history']:
    rows=[s for s in samples if s['scale']==scale and s['case']==case]
    metrics={'artifactBytes':[s['artifactBytes'] for s in rows]}
    for key in ['openMs','firstQueryMs','warmMedianMs','warmP95Ms','closeMs','reopenMs','reopenFirstMs']:
        metrics[key]=[s['ordinary'][key] for s in rows]
    metrics['openPlusFirstMs']=[s['ordinary']['openMs']+s['ordinary']['firstQueryMs'] for s in rows]
    metrics['fullLoadMs']=[s['full']['fullLoadMs'] for s in rows]
    metrics['ordinaryPeakMiB']=[s['ordinary']['ordinaryPeakMemory']['peak']/2**20 for s in rows]
    metrics['fullPeakMiB']=[s['full']['loadedMemory']['peak']/2**20 for s in rows]
    metrics['warmRSSDeltaMiB']=[(s['ordinary']['warmPassMemory'][-1]['rss']-s['ordinary']['primedMemory']['rss'])/2**20 for s in rows]
    for key in ['fixtureMs','baselineBuildMs']+(['transitionBuildMs','historyBytes'] if case=='history' else []):metrics[key]=[s['prepare'][key] for s in rows]
    summary[f'{scale}-{case}']={k:stats(v) for k,v in metrics.items()}
paths=[*REPO.glob('TSUGINO/Data/Storage/*.swift'),*REPO.glob('TSUGINO/Data/Mapping/*.swift'),*REPO.glob('TSUGINO/Domain/**/*.swift'),*REPO.glob('TSUGINO/Data/Search/*.swift'),*HERE.parent.glob('Sources/*.swift'),*HERE.glob('*.swift'),HERE/'METHOD.md',HERE/'run.py',HERE/'build.sh']
result={'method':'METHOD.md','environment':json.loads((HERE/'environment.json').read_text()),'repetitions':5,'summary':summary,'samples':samples,'binarySHA256':digest(BIN),'sourceFingerprints':{str(p.relative_to(REPO)):digest(p) for p in sorted(set(paths))}}
(HERE/'results.json').write_text(json.dumps(result,indent=2)+'\n')
print('All 20 samples and artifact/behavior checks passed.',flush=True)
