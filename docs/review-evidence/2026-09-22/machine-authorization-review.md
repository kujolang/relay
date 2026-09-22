# Machine authorization remediation — G5

Outcome: the caller-authority flaw is fixed in `5c5a909`. This is a local
operator-policy primitive, not a remote authorization service or final release
certification. The full release gate result is recorded in the execution ledger.

## Reproduction and invariant

Before the fix, `cli.cmd_machine` parsed `RELAY_MACHINE_REQUEST` and passed its
claims directly to `enterprise.authorize_machine_request`. A request containing
identity `claimed-user`, role `operator`, tenant `other-tenant`, unknown action
`unknown.delete.all` and `approval: true` returned `authorized: true` when the
shared fixture secret matched. This was reproduced with pinned Kujo before editing.

The invariant is now: only an operator-owned policy can grant authority to an
authenticated identity, and a decision applies to one exact registered resource,
tenant, action and unexpired, unused request ID. Mutations additionally require
an operator role and a matching out-of-band approval. No input prefix or caller
role/approval can supply authority.

## Patch and compatibility

`src/machine_access.kujo` is the shared boundary, re-exported through
`src/enterprise.kujo` for the unchanged CLI caller. It loads a bounded policy,
checks per-identity credential digests, derives role/tenant, checks resource
ownership and exact grants, and binds approvals to the complete request.
A local exclusive lock covers replay scanning and atomic audit replacement.
Success is returned only after persistence; corrupt/full/unsafe audit state fails.

The v2 request, policy and response have distinct schema files. The optional v1
shared-secret authority is rejected explicitly rather than retained as a bypass.
Historical v1 audit is preserved and never used as v2 replay state. Command names,
disabled defaults and success/error exit meanings remain; run/export formats are
unchanged. Legitimate readers and explicitly approved operators retain their
workflows after configuration migration. See the
[migration guide](../../machine-authorization.md).

## Verification

- Syntax/import: pinned Kujo `check` passed for the new module and enterprise
  re-exports; Markdown links, shell syntax and `git diff --check` passed.
- Security trigger: `tests/relay_machine_access_smoke.sh` rejects caller-selected
  role/approval, unknown and prefix actions, wrong identity/credential, tenant
  and resource substitution, missing/malformed/oversized policy, v1 request,
  expired/future/noninteger expiry and malformed identifiers.
- Persistence: sequential and concurrent duplicate calls admit at most one;
  credential rotation retains replay rejection; corrupt, partial and oversized
  audit, held lock and symlink paths deny authorization.
- Legitimate controls: reader access and approved operator mutation succeed;
  actual policy/request/result output passes the three v2 schemas. Approval
  mismatch tests use fresh state roots so replay cannot mask a binding failure.
- Integration: the existing enterprise smoke calls the new boundary suite and
  continues to exercise signed export, verification and failed-run handoff.
- Independent read-only investigation and candidate review traced the shared
  boundary and found no remaining concrete bypass in the documented trust model.

## Limits

The operator owns policy, credential provisioning, environment and filesystem
state. A wrapper must enforce the decision on the same registered resource and
tenant; this CLI does not execute the requested action. Local audit hashes detect
corruption, not hostile host-owner rewriting. No live credentials or transport
were used. Final-candidate multi-platform, provider, performance and Workcell
proof remain separate v88 gates.

Full gate evidence: source `5c5a909d9b8d76b71d7ffa29396015c66a8f4e14`,
pinned Kujo `9b77dce592047121cb71066629836ad89252f3ce`, isolated pinned
sibling worktrees on macOS x86_64. All 37 smoke scripts, 28 schemas, contracts,
source/link/metadata checks, Kennel, ShipCheck 16/16 and reproducible clean-install
archives passed. Gate log SHA-256: `44911c26924a9641ea3f0830c94dcbce76dc8c6f800d45bf03d8bebc55d94ed4`.
