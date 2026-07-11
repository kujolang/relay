# Architecture Decision Records

## ADR-001: New composition repository

Context: Dispatch, Agents SDK, and the workflow kits each own adjacent but different concerns. Decision: create `relay` as a thin composition/runtime repository. Rationale: adding mission coordination to any one subsystem would blur ownership. Consequence: adapters must preserve upstream contracts and report unavailable integrations honestly. Rejected: replacing Dispatch or embedding a second provider SDK.

## ADR-002: Library-first runtime with thin CLI

Context: Paperclip, Hermes, CI, MCP, and humans need the same operation surface. Decision: `src/runtime.kujo` owns state transitions and evidence; `src/cli.kujo` only parses and renders. Rationale: machine callers should not depend on terminal prose. Consequence: the runtime's JSON state is the integration boundary.

## ADR-003: Explicit mission/run vocabulary

Context: existing tools use run, workflow, task, packet, and report with distinct meanings. Decision: mission is the requested bounded objective; run is one execution; workflow is the selected step template. Rationale: matches Dispatch and RunLedger without collapsing their ownership.

## ADR-004: Adapter composition over copied implementations

Context: Kujo currently has no stable cross-repository package import contract for these repos. Decision: use narrow subprocess adapters plus one AI SDK bridge. Rationale: avoids a third provider/tool contract and proves the actual CLIs. Consequence: process startup and path configuration are explicit risks.

## ADR-005: Watchdog is the live AI route

Context: Watchdog owns proxying and telemetry; AI SDK owns normalized provider calls. Decision: live requests use `RELAY_WATCHDOG_URL` as the configured compatible base URL, while fixture mode is explicitly marked as a no-network bypass. Rationale: preserves provider independence and avoids an unverified fake telemetry claim.

## ADR-006: Deterministic completion authority

Context: model claims are not evidence. Decision: completion requires action success plus Eval success; ChangeBucket and RunLedger artifacts are persisted regardless. Rationale: follows Eval and Loop Engineering contracts. Consequence: model-generated plans and adaptive repair are deferred.

## ADR-007: Declarative, least-privilege actions

Context: unrestricted shell/filesystem authority is unsafe. Decision: MVP accepts explicit `write_file` and allowlisted `run_command` actions, with approval metadata, realpath workspace checks, deny patterns, and `allow_writes`. Rationale: makes authority inspectable and testable. Consequence: agents cannot yet invent arbitrary tool calls.

## ADR-008: File artifacts plus JSONL events

Context: RunLedger, PackWrite, ChangeBucket, and Eval already produce inspectable files. Decision: keep run state/report JSON, human Markdown, and AgentEvent-compatible JSONL under one run directory, append JSONL with the Kujo append primitive, and record artifact digests. Rationale: simple resume/export, bounded write cost, and machine-readable integrity evidence without a parallel database.
