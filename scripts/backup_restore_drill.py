#!/usr/bin/env python3
"""Disposable offline recovery drill; never reads or replaces an operator store."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time


def inventory(directory):
    result = {}
    for path in sorted(directory.rglob('*')):
        if path.is_symlink():
            raise ValueError('backup contains a symbolic link')
        if path.is_file():
            result[path.relative_to(directory).as_posix()] = {
                'bytes': path.stat().st_size,
                'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
            }
        elif not path.is_dir():
            raise ValueError('backup contains a non-regular entry')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--relay-root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = args.relay_root.resolve()
    kujo = os.environ.get('KUJO_BIN', str(root.parent / 'kujo/target/release/kujo'))
    evidence = {'format': 'relay-backup-restore-drill-v1', 'fixture_only': True,
                'drill_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                'source_commit': subprocess.check_output(['git', '-C', str(root), 'rev-parse', 'HEAD'], text=True).strip(),
                'runtime_revision': (root / 'RUNTIME_VERSION').read_text().strip(),
                'scope': 'quiesced completed run evidence; no running workspace or machine replay rollback',
                'recovery': {}, 'negative_cases': {}}
    with tempfile.TemporaryDirectory(prefix='relay-restore-drill-') as temporary:
        base = Path(temporary).resolve()
        work, source, backup = base / 'work', base / 'source', base / 'backup'
        work.mkdir()
        for command in [['init', '-q'], ['config', 'user.email', 'relay@example.invalid'], ['config', 'user.name', 'Relay']]:
            subprocess.run(['git', '-C', str(work), *command], check=True)
        (work / 'README.md').write_text('Disposable recovery fixture\n')
        subprocess.run(['git', '-C', str(work), 'add', '.'], check=True)
        subprocess.run(['git', '-C', str(work), 'commit', '-qm', 'fixture'], check=True)
        env = {**os.environ, 'KUJO_BIN': kujo, 'RELAY_ROOT': str(root),
               'RELAY_OFFLINE_FIXTURE': 'true', 'RELAY_STORE_BACKEND': 'json'}

        def relay(state, *command, success=True, backend='json'):
            proc = subprocess.run([kujo, 'run', str(root / 'main.kujo'), '--', *command, '--json'],
                                  env={**env, 'RELAY_STATE_ROOT': str(state), 'RELAY_STORE_BACKEND': backend},
                                  text=True, capture_output=True, timeout=120)
            value = json.loads(proc.stdout)
            if success:
                assert proc.returncode == 0 and value['ok'], (command, value, proc.stderr)
            else:
                assert proc.returncode != 0 and not value['ok'], (command, value)
            return value

        mission = json.loads((root / 'examples/fixture-mission.json').read_text())
        mission['repository'] = str(work)
        spec = base / 'mission.json'
        spec.write_text(json.dumps(mission))
        run = relay(source, 'missions', 'run', str(spec), '--fixture', '--skip-agent-smoke')
        run_id = run['run']['run_id']
        relay(source, 'runs', 'verify', run_id)
        started = time.perf_counter()
        before = inventory(source / 'runs')
        backup.mkdir()
        shutil.copytree(source / 'runs', backup / 'runs')
        assert inventory(backup / 'runs') == before == inventory(source / 'runs')
        (backup / 'manifest.json').write_text(json.dumps(before, sort_keys=True))
        evidence['backup_ms'] = round((time.perf_counter() - started) * 1000)
        evidence['files'] = len(before)
        evidence['bytes'] = sum(entry['bytes'] for entry in before.values())
        evidence['manifest_sha256'] = hashlib.sha256((backup / 'manifest.json').read_bytes()).hexdigest()
        evidence['observed_rpo_completed_runs'] = 0

        def restore(destination, backend, mutate=None, interrupt=False):
            staging = destination.with_name(destination.name + '-staging')
            shutil.copytree(backup / 'runs', staging / 'runs')
            if mutate:
                mutate(staging / 'runs' / run_id)
            if interrupt:
                return staging
            assert inventory(staging / 'runs') == before, 'backup inventory mismatch'
            relay(staging, 'runs', 'verify', run_id, backend=backend)
            listed = relay(staging, 'runs', 'list', backend=backend)
            assert listed['runs'][run_id]['status'] == 'completed'
            assert (staging / ('index.json' if backend == 'json' else 'run-index.sqlite3')).is_file()
            assert inventory(staging / 'runs') == before
            staging.rename(destination)
            relay(destination, 'runs', 'verify', run_id, backend=backend)
            return destination

        # Make the original authoritative location unavailable before recovery.
        offline_runs = base / 'offline-original-runs'
        (source / 'runs').rename(offline_runs)
        for backend in ['json', 'sqlite']:
            started = time.perf_counter()
            restored = restore(base / ('restored-' + backend), backend)
            evidence['recovery'][backend] = {'observed_rto_ms': round((time.perf_counter() - started) * 1000),
                                             'cache_rebuilt': True, 'authoritative_bytes_unchanged': True,
                                             'post_publish_verification': True}
        for name, mutation in [('partial', lambda run_dir: (run_dir / 'report.json').unlink()),
                               ('corrupt', lambda run_dir: (run_dir / 'state.json').write_text('{corrupt'))]:
            destination = base / name
            try:
                restore(destination, 'json', mutation)
                raise RuntimeError('invalid restore was published')
            except AssertionError as error:
                assert str(error) == 'backup inventory mismatch'
            assert not destination.exists()
            staging = destination.with_name(destination.name + '-staging')
            relay(staging, 'runs', 'verify', run_id, success=False)
            evidence['negative_cases'][name] = 'inventory and Relay verification rejected; not published'
        destination = base / 'interrupted'
        staging = restore(destination, 'json', interrupt=True)
        assert not destination.exists() and staging.exists()
        # Discard only this drill's unpublished staging and retry from the verified snapshot.
        shutil.rmtree(staging)
        restore(destination, 'json')
        evidence['negative_cases']['interrupted'] = 'unpublished staging discarded; retry verified'
        assert inventory(offline_runs) == before
        offline_runs.rename(source / 'runs')
        evidence['source_unchanged'] = True
        evidence['original_location_unavailable_during_recovery'] = True
    evidence['ok'] = True
    evidence['limitations'] = ['single completed fixture run on this host',
                              'measured durations are observations, not an SLA',
                              'RPO requires writer quiescence; production backup cadence is operator-owned',
                              'machine audit/capability state and repository workspaces require separate recovery policies']
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(evidence, indent=2) + '\n')
    print('PASS fixture backup/restore, both cache rebuilds, partial/corrupt/interrupted restoration')


if __name__ == '__main__':
    main()
