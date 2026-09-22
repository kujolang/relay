# Mission Plan: Bounded Repository Mission

## Objective
Deliver a small, self-contained change to the repository (feature, fix, or refactor) with every step independently verifiable and a clean, reviewable diff.

## Scope
- **In scope:** One bounded change area (single module/subsystem), its tests, and docs directly affected.
- **Out of scope:** Unrelated refactors, dependency upgrades, formatting-only churn, new features beyond the stated goal.

## Steps (each with a verifiable exit criterion)

1. **Recon & baseline**
   - Read relevant code, tests, and docs; run the existing test suite to confirm a green baseline.
   - *Verify:* Baseline test run passes; affected files identified and listed.

2. **Define acceptance criteria**
   - Write down the exact behavior expected after the change (inputs → outputs, error cases).
   - *Verify:* Criteria are concrete and testable; no ambiguous "improve" statements.

3. **Write failing tests first**
   - Add or update tests that encode the acceptance criteria.
   - *Verify:* New tests fail against current code for the right reason.

4. **Implement the minimal change**
   - Make the smallest change that satisfies the criteria; no drive-by edits.
   - *Verify:* New tests pass; full suite still passes; no unrelated files touched (`git diff --stat` check).

5. **Lint, type-check, and docs**
   - Run linters/type checks; update docs/comments touched by the change.
   - *Verify:* All checks exit 0; docs match actual behavior.

6. **Self-review & cleanup**
   - Re-read the diff; remove debug code, dead branches, and stray files.
   - *Verify:* Diff is minimal and intentional; no TODOs left behind.

7. **Final verification & handoff**
   - Run the full verification suite once more from a clean state; summarize the change.
   - *Verify:* Clean checkout passes all checks; summary describes what/why/how verified.

## Risks & Mitigations
- **Hidden coupling:** Mitigated by baseline test run and full-suite re-run after change.
- **Scope creep:** Mitigated by explicit out-of-scope list and diff-size check at step 4.
- **Flaky tests:** Re-run failures twice before attributing to the change.

## Definition of Done
All steps verified, full suite green from clean state, diff limited to the bounded scope, and a concise change summary produced.