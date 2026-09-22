#!/usr/bin/env python3
"""Disposable cold/warm index profiling with per-process peak RSS and unchanged budgets."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import resource
import statistics
import subprocess
import sys
import tempfile
import time


def measure(command):
    started = time.perf_counter_ns()
    try:
        result = subprocess.run(command, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, timeout=300)
    except subprocess.TimeoutExpired:
        result = subprocess.CompletedProcess(command, 124, stderr=b'benchmark command exceeded 300 seconds')
    usage = resource.getrusage(resource.RUSAGE_CHILDREN)
    sample = {'elapsed_ms': (time.perf_counter_ns() - started) / 1_000_000,
              'peak_rss_bytes': int(usage.ru_maxrss * (1 if sys.platform == 'darwin' else 1024)),
              'returncode': result.returncode}
    if result.returncode:
        sample['stderr_tail'] = result.stderr.decode(errors='replace')[-2000:]
    print(json.dumps(sample))
    return result.returncode


def cpu_sample():
    path = Path('/proc/stat')
    if not path.exists():
        return {'available': False, 'reason': 'Linux /proc/stat is required for quiet-host qualification'}
    def read():
        return [int(n) for n in path.read_text().splitlines()[0].split()[1:9]]
    before = read()
    time.sleep(0.25)
    after = read()
    deltas = [b-a for a,b in zip(before,after)]
    total = sum(deltas)
    idle = 100*deltas[3]/total if total else 0
    return {'available': True, 'idle_percent': round(idle,2), 'quiet': idle >= 90}


def quiet_sample(required):
    deadline = time.monotonic()+30
    sample = cpu_sample()
    while required and sample.get('available') and not sample['quiet'] and time.monotonic()<deadline:
        time.sleep(0.5)
        sample = cpu_sample()
    if required and not sample.get('quiet',False):
        raise RuntimeError('host did not meet >=90% idle before the sample: '+json.dumps(sample))
    return sample


def summarize(samples):
    elapsed = [s['elapsed_ms'] for s in samples]
    rss = [s['peak_rss_bytes'] for s in samples]
    return {'samples': samples, 'median_ms': statistics.median(elapsed),
            'p95_ms': sorted(elapsed)[math.ceil(.95*len(elapsed))-1],
            'median_peak_rss_bytes': statistics.median(rss), 'max_peak_rss_bytes': max(rss)}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile',choices=['small','medium','large'],required=True)
    parser.add_argument('--backend',choices=['json','sqlite'],required=True)
    parser.add_argument('--iterations',type=int,default=5)
    parser.add_argument('--require-quiet',action='store_true')
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    if not 1 <= args.iterations <= 50: parser.error('iterations must be 1..50')
    if args.output.exists(): parser.error('output must not exist')
    root=Path(__file__).resolve().parents[1]
    kujo=Path(os.environ.get('KUJO_BIN',str(root.parent/'kujo/target/release/kujo'))).resolve()
    budgets=json.loads((root/'benchmarks/budgets.json').read_text())
    config=next(p for p in budgets['representative_profiles'] if p['name']==args.profile)
    receipt={'format':'relay-cold-warm-profile-v1','source_commit':subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD'],text=True).strip(),
             'runtime_revision':(root/'RUNTIME_VERSION').read_text().strip(),
             'runtime_sha256':hashlib.sha256(kujo.read_bytes()).hexdigest(),
             'profiler_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
             'phase_source_sha256':hashlib.sha256((root/'scripts/profile_index.kujo').read_bytes()).hexdigest(),'platform':platform.system().lower()+'-'+platform.machine().lower(),
             'profile':args.profile,'backend':args.backend,'iterations':args.iterations,'dataset':config,
             'cache_definition':'cold: both persisted caches absent before every command; warm: selected index primed; OS page caches are not flushed',
             'rss_definition':'per-invocation RUSAGE_CHILDREN high-water RSS, normalized to bytes; worker starts fresh for each command',
             'quiet_definition':'Linux CPU idle >=90% over 250ms immediately before every measured command/phase; dedicated hosted runner when recorded',
             'runner_environment':os.environ.get('RUNNER_ENVIRONMENT','local'),'cpu_count':os.cpu_count(),
             'github_run_id':os.environ.get('GITHUB_RUN_ID'),'modes':{},'budget_breaches':[],'measurement_complete':False,'ok':False}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    def save(): args.output.write_text(json.dumps(receipt,indent=2)+'\n')
    try:
        with tempfile.TemporaryDirectory(prefix='relay-profile-') as tmp:
            base=Path(tmp).resolve(); state=base/'state'; home=base/'home';home.mkdir()
            env={'PATH':os.environ.get('PATH','/usr/bin:/bin'),'HOME':str(home),'LANG':'C','TMPDIR':str(base),
                 'RELAY_ROOT':str(root),'RELAY_STATE_ROOT':str(state),'RELAY_STORE_BACKEND':args.backend,'KUJO_BIN':str(kujo)}
            fixture={'state_root':str(state),'profile':args.profile,'run_count':config['runs'],
                     'event_count':config['events_per_target_run'],'artifact_bytes':config['artifact_bytes_per_target_run']}
            created=subprocess.run([str(kujo),'run',str(root/'scripts/benchmark_fixture.kujo'),'--interpreter'],
                                   env={**env,'RELAY_BENCHMARK_FIXTURE':json.dumps(fixture)},text=True,capture_output=True,timeout=300,check=True)
            run_id=json.loads(created.stdout)['target_run_id']
            prefix=[str(kujo),'run',str(root/'main.kujo'),'--']
            def call(command,success=True):
                proc=subprocess.run(prefix+command,env=env,text=True,capture_output=True,timeout=300)
                value=json.loads(proc.stdout)
                assert (proc.returncode==0)==success and value['ok']==success,(command,value,proc.stderr)
                return value
            def clear():
                # Only this process's freshly generated temporary fixture is touched.
                for name in ['index.json','run-index.sqlite3','run-index.sqlite3-wal','run-index.sqlite3-shm','run-index.sqlite3-journal']:
                    path=state/name
                    if path.exists():path.unlink()
            for mode in ['cold','warm']:
                data={name:[] for name in ['runs_list','runs_verify','runs_watch_completed','runs_export']}
                phases=[]
                commands={'runs_list':['runs','list','--limit','100','--json'],
                          'runs_verify':['runs','verify',run_id,'--json'],
                          'runs_watch_completed':['runs','watch',run_id,'--timeout-ms','120000','--poll-ms','10','--json'],
                          'runs_export':['runs','export',run_id,'--output',str(base/'export.json'),'--json']}
                for iteration in range(args.iterations):
                    for name,command in commands.items():
                        if mode=='cold':clear()
                        else:call(['runs','list','--limit','100','--json'])
                        quiet=quiet_sample(args.require_quiet)
                        worker=subprocess.run([sys.executable,__file__,'--measure',*prefix,*command],env=env,text=True,capture_output=True,timeout=310)
                        measured=json.loads(worker.stdout)
                        assert worker.returncode==0,(name,measured)
                        measured['quiet_before']=quiet
                        data[name].append(measured)
                        receipt['modes'][mode]={'commands':{n:summarize(v) for n,v in data.items() if v},'phases':phases}
                        save()
                    if mode=='cold':clear()
                    else:call(['runs','list','--limit','100','--json'])
                    quiet=quiet_sample(args.require_quiet)
                    phase=subprocess.run([str(kujo),'run',str(root/'scripts/profile_index.kujo'),'--interpreter'],env=env,text=True,capture_output=True,timeout=300,check=True)
                    value=json.loads(phase.stdout);assert value['ok'] and value['records']==config['runs'],value
                    assert value['index_source']==('rebuild' if mode=='cold' else args.backend),value
                    value['quiet_before']=quiet;phases.append(value)
                for name,summary in receipt['modes'][mode]['commands'].items():
                    limit=budgets['p95_ms'][args.profile][name]*(1+budgets['regression_percent']/100)
                    if summary['p95_ms']>limit:receipt['budget_breaches'].append({'mode':mode,'command':name,'p95_ms':summary['p95_ms'],'limit_ms':limit})
            # Cached reads must still detect authoritative tampering on this backend.
            call(['runs','list','--limit','100','--json'])
            state_file=state/'runs'/run_id/'state.json';original=state_file.read_bytes()
            tampered=json.loads(original);tampered['status']='failed';state_file.write_text(json.dumps(tampered))
            listed=call(['runs','list','--limit','500','--json'])
            assert listed['runs'][run_id]['integrity_valid'] is False,listed
            call(['runs','verify',run_id,'--json'],success=False)
            state_file.write_bytes(original)
            restored=call(['runs','list','--limit','500','--json'])
            assert restored['runs'][run_id]['integrity_valid'] is True
            receipt['tamper_detected_on_warm_cache']=True
            receipt['restored_state_accepted']=True
        receipt['measurement_complete']=True
        receipt['quiet_verified']=all(s['quiet_before'].get('quiet',False) for m in receipt['modes'].values() for c in m['commands'].values() for s in c['samples']) and all(p['quiet_before'].get('quiet',False) for m in receipt['modes'].values() for p in m['phases'])
        receipt['ok']=not receipt['budget_breaches'] and (receipt['quiet_verified'] or not args.require_quiet)
    except Exception as error:
        receipt['error']=str(error)
    save()
    print(args.output)
    return 0 if receipt['ok'] else 1


if __name__=='__main__':
    raise SystemExit(measure(sys.argv[2:]) if len(sys.argv)>1 and sys.argv[1]=='--measure' else main())
