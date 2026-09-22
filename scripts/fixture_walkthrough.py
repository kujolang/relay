#!/usr/bin/env python3
"""Install a committed Relay archive in an empty home and verify a fixture export."""
import argparse
import hashlib
import html
import json
import os
import signal
import time
from pathlib import Path
import subprocess
import tarfile
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--relay-root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--browser', type=Path, help='Optional Chromium executable for PNG transcript screenshots')
    args = parser.parse_args()
    root = args.relay_root.resolve()
    output = args.output.resolve()
    if output.exists():
        raise SystemExit('output must be a new directory')
    pins = json.loads((root / 'release/dependencies.json').read_text())['dependencies']
    revisions = {}
    for name, pin in pins.items():
        if not pin['required']:
            continue
        checkout = root.parent / name
        revision = subprocess.check_output(['git', '-C', str(checkout), 'rev-parse', 'HEAD'], text=True).strip()
        assert revision == pin['revision'], (name, revision, pin['revision'])
        subprocess.run(['git', '-C', str(checkout), 'diff', '--quiet', 'HEAD', '--'], check=True)
        revisions[name] = revision
    kujo = Path(os.environ.get('KUJO_BIN', str(root.parent / 'kujo/target/release/kujo'))).resolve()
    source = subprocess.check_output(['git', '-C', str(root), 'rev-parse', 'HEAD'], text=True).strip()
    subprocess.run(['git', '-C', str(root), 'diff', '--quiet', 'HEAD', '--'], check=True)
    output.mkdir(parents=True)
    transcript = []
    with tempfile.TemporaryDirectory(prefix='relay-first-run-') as temporary:
        base = Path(temporary).resolve()
        home, install, work, state = (base / name for name in ['home', 'relay', 'workspace', 'state'])
        for directory in [home, install, work]:
            directory.mkdir()
        archive = base / 'relay.tar'
        subprocess.run(['git', '-C', str(root), 'archive', '--format=tar', '-o', str(archive), source], check=True)
        with tarfile.open(archive) as bundle:
            for member in bundle.getmembers():
                assert not member.issym() and not member.islnk()
                assert not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            bundle.extractall(install)
        # A clean home and explicit allowlist prevent inherited Relay/provider config.
        env = {'PATH': '/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin', 'HOME': str(home),
               'TMPDIR': str(base), 'LANG': 'en_US.UTF-8', 'KUJO_BIN': str(kujo),
               'RELAY_ROOT': str(install), 'RELAY_STATE_ROOT': str(state),
               'RELAY_OFFLINE_FIXTURE': 'true', 'RELAY_AI_SDK_PATH': str(root.parent / 'ai-sdk'),
               'RELAY_AGENTS_SDK_PATH': str(root.parent / 'agents-sdk'),
               'KUJO_AGENTS_PATH': str(root.parent / 'kujo-agents'),
               'RELAY_EVAL_ENTRY': str(root.parent / 'eval/main.kujo')}
        for name in ['packwrite', 'runledger', 'changebucket']:
            env['RELAY_' + name.upper() + '_ROOT'] = str(root.parent / name)
            env['RELAY_' + name.upper() + '_BIN'] = str(root.parent / name / 'bin' / name)
        run_id = ''

        def clean(value):
            text = json.dumps(value, indent=2)
            for old, new in [(str(base), '$DEMO'), (str(root.parent), '$PINNED_DEPENDENCIES')]:
                text = text.replace(old, new)
            if run_id:
                text = text.replace(run_id, '$RUN_ID')
            return json.loads(text)

        def relay(label, *command, expect_json=True):
            proc = subprocess.run([str(install / 'bin/relay'), *command], env=env, cwd=work,
                                  text=True, capture_output=True, timeout=120)
            assert proc.returncode == 0, (label, proc.stdout, proc.stderr)
            value = json.loads(proc.stdout) if expect_json else proc.stdout.strip()
            if expect_json:
                assert value['ok'], (label, value)
            transcript.append({'step': label, 'command': 'relay ' + ' '.join(command), 'result': value})
            return value

        version = relay('Installed archive', '--version', expect_json=False)
        assert version == 'relay ' + (root / 'VERSION').read_text().strip()
        doctor = relay('Check dependencies', 'doctor', '--json')
        agents = relay('Validate agents', 'agents', 'validate', '--json')
        chat = relay('Fixture chat', 'chat', 'Summarize the mission boundary', '--fixture', '--json')
        for cmd in [['init', '-q'], ['config', 'user.email', 'relay@example.invalid'], ['config', 'user.name', 'Relay']]:
            subprocess.run(['git', '-C', str(work), *cmd], env=env, check=True)
        (work / 'README.md').write_text('Disposable first-run workspace\n')
        subprocess.run(['git', '-C', str(work), 'add', '.'], env=env, check=True)
        subprocess.run(['git', '-C', str(work), 'commit', '-qm', 'first-run baseline'], env=env, check=True)
        mission = json.loads((install / 'examples/fixture-mission.json').read_text())
        mission['repository'] = str(work)
        spec = base / 'mission.json'
        spec.write_text(json.dumps(mission))
        run = relay('Run bounded mission', 'missions', 'run', str(spec), '--fixture', '--json')
        run_id = run['run']['run_id']
        assert run['run']['status'] == 'completed'
        verified = relay('Verify evidence', 'runs', 'verify', run_id, '--json')
        export = base / 'verified-export.json'
        env['RELAY_SIGNING_KEY'] = os.urandom(32).hex()
        relay('Export signed bundle', 'runs', 'export', run_id, '--signed', '--key-id', 'walkthrough', '--output', str(export), '--json')
        # Verification cannot accidentally depend on the originating store.
        env['RELAY_STATE_ROOT'] = str(base / 'absent-store')
        signature = relay('Verify portable export', 'runs', 'verify-signature', str(export), '--json')
        assert signature['signature_valid'] and not (base / 'absent-store').exists()
        assert env['RELAY_SIGNING_KEY'] not in json.dumps(transcript)
        normalized = clean(transcript)
        (output / 'transcript.json').write_text(json.dumps(normalized, indent=2) + '\n')
        receipt = {'format': 'relay-fixture-walkthrough-v1', 'ok': True, 'source_commit': source,
                   'generator_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                   'runtime_revision': revisions['kujo'], 'runtime_sha256': hashlib.sha256(kujo.read_bytes()).hexdigest(),
                   'dependencies': revisions, 'fresh_home': True, 'archive_install': True,
                   'fixture_only': True, 'mission_status': run['run']['status'], 'run_verified': verified['ok'],
                   'signature_valid_without_origin_store': signature['signature_valid'],
                   'transcript_sha256': hashlib.sha256((output / 'transcript.json').read_bytes()).hexdigest()}
        (output / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
        cards = [
            ('01-install', 'Install. Check. Run.', [('relay --version', version), ('relay doctor --json', {'ok': doctor['ok'], 'mode': doctor['mode']}), ('relay agents validate --json', {'ok': agents['ok']}), ('relay chat ... --fixture --json', {'ok': chat['ok'], 'mode': 'fixture'})]),
            ('02-evidence', 'One mission. Verifiable evidence.', [('relay missions run mission.json --fixture --json', {'ok': run['ok'], 'status': run['run']['status']}), ('relay runs verify $RUN_ID --json', {key: verified[key] for key in ['ok', 'integrity_valid', 'state_valid', 'receipts_valid', 'events_valid', 'packet_manifest_valid']}), ('relay runs verify-signature verified-export.json --json', clean(signature))])]
        for name, title, commands in cards:
            blocks = ''.join('<section><div class="command">$ ' + html.escape(command) + '</div><pre>' + html.escape(json.dumps(value, indent=2) if not isinstance(value, str) else value) + '</pre></section>' for command, value in commands)
            page = '<!doctype html><meta charset="utf-8"><title>Relay verified fixture transcript</title><style>body{margin:0;background:#111;color:#eee;font:17px ui-monospace,monospace;padding:48px}main{max-width:1120px;margin:auto}small{color:#aaa;letter-spacing:2px}h1{font:600 42px system-ui;margin:16px 0 30px}section{padding:20px 24px;background:#1c1c1c;border:1px solid #444;margin:14px 0;border-radius:8px}.command{color:#aaa}pre{white-space:pre-wrap;overflow-wrap:anywhere;font:16px/1.45 ui-monospace,monospace;margin-bottom:0}footer{font:14px/1.6 system-ui;color:#aaa;margin-top:26px}</style><main><small>RELAY / FIRST VERIFIED RUN</small><h1>' + html.escape(title) + '</h1>' + blocks + '<footer>Generated transcript screenshot · actual offline fixture results<br>Source ' + source[:12] + ' · Kujo ' + revisions['kujo'][:12] + '<br>Selected fields shown. Full normalized command results: transcript.json</footer></main>'
            path = output / (name + '.html')
            path.write_text(page)
            if args.browser:
                screenshot = output / (name + '.png')
                process = subprocess.Popen([str(args.browser.resolve()), '--headless', '--disable-gpu', '--no-first-run', '--no-default-browser-check', '--disable-background-networking', '--hide-scrollbars', '--timeout=10000', '--virtual-time-budget=1000', '--user-data-dir=' + str(base / ('browser-' + name)), '--window-size=1280,1200', '--screenshot=' + str(screenshot), path.as_uri()], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
                try:
                    deadline = time.monotonic() + 45
                    while time.monotonic() < deadline:
                        if screenshot.is_file():
                            data = screenshot.read_bytes()
                            if data.startswith(b'\x89PNG\r\n\x1a\n') and data.endswith(b'IEND\xaeB`\x82'):
                                break
                        if process.poll() is not None:
                            raise RuntimeError('browser exited without a complete screenshot')
                        time.sleep(0.1)
                    else:
                        raise RuntimeError('screenshot deadline exceeded')
                finally:
                    if process.poll() is None:
                        os.killpg(process.pid, signal.SIGTERM)
                        try:
                            process.wait(timeout=5)
                        except subprocess.TimeoutExpired:
                            os.killpg(process.pid, signal.SIGKILL)
                            process.wait()
    print('PASS isolated archive install, fresh-home fixture mission, verified portable export and transcript')


if __name__ == '__main__':
    main()
