# Local machine authorization v2

This is a disabled-by-default local decision command. It does not start a
listener, dispatch actions, provide SSO or isolate host users. The operator owns
the environment, policy file, state directory and credential distribution. A
wrapper must prevent untrusted requests from changing those inputs and enforce
the returned identity, tenant, exact action and resource at execution time.
An authorization JSON response is an audit result, not a transferable bearer token.

## Configure policy

Set `RELAY_MACHINE_ACCESS_ENABLED=true` and `RELAY_MACHINE_POLICY_PATH` to a
regular, non-symlink JSON file no larger than 64 KiB. Protect it and the state
directory with host permissions. Generate a unique high-entropy credential for
each identity; store only its SHA-256 digest in the policy. Supply the original
credential to `RELAY_MACHINE_REQUEST_SECRET` through the trusted environment.
Credentials must be 16–4096 characters; the minimum length is not an entropy test.
No shared-secret fallback exists.

```json
{
  "contract_version": "relay-machine-policy-v2",
  "identities": {
    "ci-reader": {
      "role": "reader",
      "tenant": "team-one",
      "secret_sha256": "REPLACE_WITH_64_LOWERCASE_HEX_DIGEST",
      "actions": ["runs.read.list", "runs.read.show"]
    }
  },
  "resources": {"team-one-runs": "team-one", "run-123": "team-one"},
  "approvals": []
}
```

The placeholder deliberately fails validation. Maximums are 128 identities,
256 registered resources and 128 approvals. Each identity has one tenant; every
requested resource must be registered to that same tenant. IDs are 1–128 ASCII
letters/digits plus `_ . : -`, starting with a letter or digit. Resource IDs are
opaque operator registrations, not caller-selected filesystem paths.

Supported actions are exactly `runs.read.list`, `runs.read.show`,
`runs.read.events`, `runs.read.export`, `runs.read.verify`, `runs.cancel`,
`runs.cleanup` and `missions.run`. Unknown names and prefixes never authorize.
Every role needs an explicit action grant. Reader and approver roles can only
use the read actions; operator mutations also require a matching policy approval.
The approver role cannot create approvals through this CLI: editing the trusted
policy is the operator's out-of-band approval procedure.

## Submit one request

Set `RELAY_MACHINE_REQUEST` to JSON with `contract_version` equal to
`relay-machine-request-v2`, `identity`, `tenant`, exact `action`, registered
`resource`, unique `request_id`, and integer `expires_at_ms` in Unix milliseconds.
Expiry must be strictly in the future and no more than five minutes ahead.
Then run `relay machine authorize --json`. Caller-supplied `role`, `approval`
and other unknown fields are rejected. `relay machine status --json` reports
whether a valid policy is configured without returning its contents.

A mutation needs an `approvals` entry containing the same identity, tenant,
action, resource, request ID and exact expiry. Changing any of them invalidates
the approval. The authenticated identity must have role `operator` and an exact
matching action grant. An approval does not override either tenant ownership or
role/action restrictions. Never derive policy approvals from request booleans.

## Replay, audit and recovery

Under an exclusive local lock, Relay checks every existing v2 audit record,
rejects reused `(identity, request_id)` pairs and atomically writes the updated
`machine-audit-v2.jsonl` before returning success. Valid authenticated policy
decisions—including denials—consume the request ID. Malformed, unauthenticated,
expired or replayed requests fail before adding a decision. The audit is capped
at 1 MiB; corruption, incomplete records, unsafe paths, a held lock or capacity
exhaustion fail closed. Records are not automatically evicted.

Credential rotation changes the policy digest while retaining audit/replay
state. Do not delete, roll back or restore an older audit while credentials
remain usable: host-owner rollback is outside this local protection. At capacity,
disable access, wait for all requests to expire, retire the affected identity
names/credentials, archive the complete audit, and provision new identities with
fresh credentials and a new state root. Preserve the old audit for review.

A crash can leave `machine-access.lock`. Stop all callers and verify no owner is
running before an operator removes that empty lock directory. Relay never steals
a lock on an assumed timeout. An interrupted atomic write leaves either the old
or new audit; only a successful durable write can return authorization success.
This is single-host replay protection, not a distributed transaction protocol.
Audit SHA-256 detects accidental corruption; it does not authenticate evidence
against a host owner who can rewrite the file and its digest.

## Migration and tests

The v1 shared-secret primitive and caller claims are explicitly rejected. Keep
historical `machine-audit.jsonl`; v2 uses separate storage and contracts. Migrate
trusted wrappers to the policy and request schemas before enabling access.

[Policy schema](../schemas/machine-policy-v2.schema.json),
[request schema](../schemas/machine-request-v2.schema.json), and
[result schema](../schemas/machine-access-v2.schema.json) define the JSON shapes.
`tests/relay_machine_access_smoke.sh` exercises legitimate reads/mutations,
forged claims, cross-tenant resources, approval binding, expiry, sequential and
concurrent replay, credential rotation, corruption/capacity, symlinks and locks.
