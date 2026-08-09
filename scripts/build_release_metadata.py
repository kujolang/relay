#!/usr/bin/env python3
import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


def run(root, *args, text=True):
    return subprocess.check_output(args, cwd=root, text=text)


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def status(name, default="not-recorded"):
    return os.environ.get(name, default)


def main():
    if len(sys.argv) != 5:
        print("usage: build_release_metadata.py <repo> <output> <commit> <archive>", file=sys.stderr)
        return 2
    root = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2]).resolve()
    commit = sys.argv[3]
    archive = Path(sys.argv[4]).resolve()
    version = (root / "VERSION").read_text().strip()
    dependencies = json.loads((root / "release/dependencies.json").read_text())
    contracts = json.loads((root / "release/contracts.json").read_text())
    epoch = int(run(root, "git", "show", "-s", "--format=%ct", commit).strip())
    created = datetime.fromtimestamp(epoch, timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    archive_digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    paths = run(root, "git", "ls-tree", "-r", "--name-only", commit).splitlines()
    files = []
    for index, relative in enumerate(paths, 1):
        content = run(root, "git", "show", f"{commit}:{relative}", text=False)
        files.append({
            "SPDXID": f"SPDXRef-File-{index}",
            "fileName": f"./{relative}",
            "checksums": [{"algorithm": "SHA256", "checksumValue": hashlib.sha256(content).hexdigest()}],
            "licenseConcluded": "NOASSERTION",
            "copyrightText": "NOASSERTION",
        })
    sbom = {
        "spdxVersion": "SPDX-2.3",
        "dataLicense": "CC0-1.0",
        "SPDXID": "SPDXRef-DOCUMENT",
        "name": f"relay-v{version}",
        "documentNamespace": f"https://kujo.dev/relay/sbom/{version}/{commit}",
        "creationInfo": {"created": created, "creators": ["Tool: relay-build-release-artifacts-v1"]},
        "packages": [{
            "name": "relay",
            "SPDXID": "SPDXRef-Package-relay",
            "versionInfo": version,
            "downloadLocation": "https://github.com/kujolang/relay",
            "filesAnalyzed": True,
            "licenseConcluded": "MIT",
            "licenseDeclared": "MIT",
            "copyrightText": "Copyright (c) 2026 Kujolang",
        }],
        "files": files,
        "relationships": [{"spdxElementId": "SPDXRef-Package-relay", "relationshipType": "CONTAINS", "relatedSpdxElement": item["SPDXID"]} for item in files],
    }
    provenance = {
        "_type": "https://in-toto.io/Statement/v1",
        "subject": [{"name": archive.name, "digest": {"sha256": archive_digest}}],
        "predicateType": "https://slsa.dev/provenance/v1",
        "predicate": {
            "buildDefinition": {
                "buildType": "https://kujo.dev/relay/source-archive/v1",
                "externalParameters": {"relay_version": version, "source_commit": commit},
                "internalParameters": {"source_date_epoch": epoch},
                "resolvedDependencies": [{"uri": f"https://github.com/kujolang/{name}", "digest": {"gitCommit": item["revision"]}} for name, item in sorted(dependencies["dependencies"].items())],
            },
            "runDetails": {
                "builder": {"id": "https://github.com/kujolang/relay/scripts/build_release_artifacts.sh"},
                "metadata": {"invocationId": f"relay-{commit}", "startedOn": created, "finishedOn": created},
            },
        },
    }
    results = {
        "source_checks": status("RELAY_SOURCE_CHECK_RESULT"),
        "cli_contracts": status("RELAY_CLI_CONTRACT_RESULT"),
        "aggregate_acceptance": status("RELAY_ACCEPTANCE_RESULT"),
        "schemas": status("RELAY_SCHEMA_RESULT"),
        "markdown_links": status("RELAY_MARKDOWN_RESULT"),
        "release_metadata": status("RELAY_METADATA_RESULT"),
        "kennel": status("RELAY_KENNEL_RESULT"),
        "shipcheck": status("RELAY_SHIPCHECK_RESULT"),
        "workcell": status("RELAY_WORKCELL_RESULT"),
        "live_provider": status("RELAY_LIVE_PROVIDER_RESULT", "blocked-approval-or-credentials-required"),
    }
    platforms = {
        "linux-x86_64": status("RELAY_PLATFORM_LINUX_X86_64", "pending-ci"),
        "macos-x86_64": status("RELAY_PLATFORM_MACOS_X86_64", "pending-ci"),
        "macos-arm64": status("RELAY_PLATFORM_MACOS_ARM64", "pending-ci"),
    }
    manifest = {
        "format": "relay-release-manifest-v1",
        "relay_version": version,
        "git_commit": commit,
        "created_at": created,
        "kujo_runtime_revision": dependencies["dependencies"]["kujo"]["revision"],
        "dependencies": dependencies["dependencies"],
        "source_archive": {"name": archive.name, "sha256": archive_digest},
        "contracts": contracts,
        "results": results,
        "workcell": {"status": results["workcell"], "run_id": status("RELAY_WORKCELL_RUN_ID", "")},
        "supported_platforms": platforms,
        "live_provider_proof": {"status": results["live_provider"], "provider": status("RELAY_LIVE_PROVIDER_ID", ""), "model": status("RELAY_LIVE_MODEL_ID", "")},
    }
    write_json(output / f"relay-v{version}.sbom.spdx.json", sbom)
    write_json(output / f"relay-v{version}.provenance.json", provenance)
    write_json(output / f"relay-v{version}.manifest.json", manifest)
    summary = [
        f"# Relay v{version} release evidence",
        "",
        f"- Git commit: `{commit}`",
        f"- Source archive SHA-256: `{archive_digest}`",
        f"- Kujo revision: `{manifest['kujo_runtime_revision']}`",
        f"- Workcell: `{results['workcell']}` (`{manifest['workcell']['run_id'] or 'no run recorded'}`)",
        f"- Live provider: `{results['live_provider']}`",
        "",
        "## Gate results",
        "",
    ]
    summary.extend(f"- {name.replace('_', ' ')}: `{value}`" for name, value in results.items())
    summary.extend(["", "## Platform evidence", ""])
    summary.extend(f"- {name}: `{value}`" for name, value in platforms.items())
    (output / f"relay-v{version}.evidence.md").write_text("\n".join(summary) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
