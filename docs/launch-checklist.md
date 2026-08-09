# Relay v1.0.0 release checklist

This checklist separates repository-controlled preparation from exact-candidate, approval-gated, external-administration, and release-owner work. An item is complete only when its evidence exists for the stated commit.

## Repository-controlled preparation

- [x] Product and CLI metadata report `1.0.0`; mission and evidence versions are explicitly independent.
- [x] `LICENSE`, `VERSION`, `CHANGELOG.md`, `kennel.toml`, `CONTRIBUTING.md`, and `SECURITY.md` are present and consistent.
- [x] Stable commands, flags, exit codes, environment, JSON contracts, compatibility, limitations, and security boundaries are documented.
- [x] Mission `1.0.0` plus legacy `0.1.0` acceptance and unsupported-version rejection have committed fixtures.
- [x] README badges, installation, quick start, workflows, provider setup, integrations, troubleshooting, and release verification are current.
- [x] CI and release-preparation workflows use immutable action/dependency revisions and least-privilege permissions.
- [x] Deterministic source archive, checksums, SBOM, provenance, manifest, evidence summary, reproducibility, and clean-install smoke tooling is committed.
- [x] Aggregate acceptance discovers every committed `*_smoke.sh` and includes schema, Markdown-link, and metadata checks.

## Exact-candidate verification

- [ ] Focused commands and aggregate acceptance pass with Kujo `9b77dce592047121cb71066629836ad89252f3ce` for the final candidate commit.
- [ ] Kennel validation passes for the final candidate commit.
- [ ] ShipCheck gate exits `0` with 16/16 checks passing for the final candidate commit.
- [ ] Two artifact builds from the same commit are equivalent and the archive-install smoke passes.
- [ ] macOS platform job passes for the final candidate.
- [ ] Linux platform job passes for the final candidate.
- [ ] Workcell success and intentional workload-failure paths are rerun against the exact final candidate; both manifests verify and the run IDs/receipts are retained.

## Approval-gated live provider proof

- [ ] Release owner explicitly approves the configured credentials and provider/model.
- [ ] Bounded external chat routes through Watchdog with request correlation and matched usage.
- [ ] Bounded provider-generated tool mission routes through Watchdog and produces verified tool, run, and export evidence.
- [ ] Evidence is redacted and records exact Relay, Kujo, Watchdog, AI SDK, Agents SDK, provider, and model identities without credentials.

Until these items pass, external provider compatibility is an explicit release blocker. Local Watchdog with a stub provider is useful regression evidence but is not a substitute.

## External GitHub administration

- [x] GitHub-hosted Linux, macOS x86_64, and macOS arm64 runners start successfully for the candidate branch.
- [ ] Configure `KUJO_ECOSYSTEM_TOKEN` with read access to the private `kujolang/kujo-agents` repository. Candidate CI run `31290237627` started all three platform jobs but each failed closed while fetching pinned revision `f0c95b66fbc74057481ef228961eb6e69ff8886a`; artifact guard run `31290237616` passed.
- [ ] Required checks and branch protection are configured by a repository administrator.
- [ ] The final candidate CI and release-preparation workflow runs are retained and reviewed.

## Release-owner actions

- [ ] Review the final diff, clean tree, pushed commits, exact-candidate evidence, and all blockers.
- [ ] Create and push `v1.0.0` only after every required gate is green.
- [ ] Approve the tag workflow publication job.
- [ ] Verify uploaded checksums, provenance, SBOM, manifest, source archive, and clean-install behavior.
- [ ] Create or approve the public GitHub release only for the verified tag.

No tag, package publication, signing, notarization, deployment, or public release is part of release preparation.

## Intentionally deferred post-v1

- Authenticated multi-tenant service operation.
- Durable transactional multi-host storage, retention, and disaster recovery.
- Hosted orchestration and operator service management.
- Full Spec/Dispatch workflow import and negotiation.
- Automatic CaseFile/Redact integration and provider-independent certification.
- Cryptographic signing authority and universal enterprise certification.
- Unrestricted shell or autonomous production access.

These are outside the scoped local v1 contract and do not become implemented through documentation or integrity hashes.
