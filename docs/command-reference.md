# Relay command reference

Relay commands return process exit code `0` on success and nonzero on invalid input, policy denial, failed evidence, or failed provider execution. Add `--json` to machine-facing commands; JSON output is the stable integration surface and terminal prose is for humans.

## Environment

| Variable | Purpose | Default |
|---|---|---|
| `KUJO_BIN` | Kujo runtime binary | `../kujo/target/release/kujo` |
| `RELAY_ROOT` | Relay checkout used to resolve sibling tools | current directory |
| `RELAY_OFFLINE_FIXTURE` | Select deterministic fixture mode | `true` |
| `RELAY_WATCHDOG_URL` | Watchdog-compatible OpenAI base URL for live calls | required when live |
| `RELAY_API_KEY_ENV` | Name of the provider credential environment variable | `OPENAI_API_KEY` |
| `RELAY_MODEL` / `RELAY_PROVIDER` | Defaults for model listing/probes | `gpt-4.1-mini` / `openai-compatible` |
| `RELAY_FALLBACK_MODEL` | Visible model fallback after a failed primary call | unset |

Run `relay doctor --json` before a live or CI invocation. Fixture mode does not require Watchdog or credentials; live mode fails closed when either is absent.

## Commands

```text
relay doctor [--json]
relay chat <prompt> [--model <id>] [--provider <id>] [--fixture] [--stream] [--json]
relay models list [--json]
relay models inspect <model> [--json]
relay models probe <model> [--fixture] [--json]
relay agents list|inspect <agent>|validate [--json]
relay missions create [spec.json] [--output <path>] [--json]
relay missions run <spec.json> [--fixture] [--pause-after-plan] [--skip-agent-smoke] [--json]
relay missions inspect|pause|resume|report <run-id> [--json]
relay runs list|inspect|events|changes|evaluations <run-id> [--json]
relay benchmark run <repository> [--json]
```

## Mission contract

Mission specs are JSON objects with `name`, `goal`, a Git `repository`, `actions`, and optional `workflow`, `model`, `provider`, `allow_writes`, `approval`, `allowed_commands`, `acceptance_criteria`, and `budgets` fields. Supported actions are deliberately narrow:

- `write_file`: relative path, only with `allow_writes: true` and `approval.approved: true`.
- `run_command`: read-oriented `git`, `kujo`, `bash scripts/`, or `sh scripts/` commands that pass policy.

Budget fields are non-negative integers: `max_steps`, `max_repairs`, and `max_tokens`. A budget failure is recorded as a failed run with a typed failure class; it is never reported as completed.

## JSON evidence

A successful mission JSON result contains `run_id`, `status`, `current_step`, `budgets`, `events`, `artifacts`, `action_results`, `changes`, `evaluations`, `runledger`, and `runledger_finish`. Run artifacts live under `.relay/runs/<run-id>/` and include `state.json`, `events.jsonl`, `agent/`, `eval.json`, `changes.json`, `evaluations.json`, `report.json`, and `report.md` when the corresponding phase ran.

`--pause-after-plan` creates a supported checkpoint at `implementation`. `missions resume` executes the stored pending actions and reruns ChangeBucket and Eval. Arbitrary crash replay is not yet supported.

## Exit-code guidance

- `0`: command or mission succeeded and required evidence passed.
- `1`: user-visible failure such as invalid spec, policy denial, failed provider call, failed action, failed evaluation, or budget exhaustion.
- `2`: unknown top-level command or usage failure.
- `3`/`4`: runtime or Kujo interpreter failure; inspect stderr and the run directory if one exists.
