---
name: tecton
description: >-
  Run Tecton plan and tests via Pants in the data-science repo.
  Handles long-running commands with proper output capture to avoid truncation.
---

# Tecton Operations Skill

## Critical: Output Handling for Long Commands

Tecton commands (especially `tecton-plan`) produce very long output that gets
truncated. **Capture to a literal file under `/tmp/opencode/` and inspect it with
the Read tool / `rg`:**

```bash
PANTS_CONCURRENT=True pants tecton-plan --workspace=<workspace> --skip-tests 2>&1 | tee /tmp/opencode/tecton-plan.txt; echo "EXIT_CODE: ${PIPESTATUS[0]}"
```

Then inspect `/tmp/opencode/tecton-plan.txt`:
- Use the **Read tool** (offset/limit) to view sections.
- Use `rg "error|Error|ERROR" /tmp/opencode/tecton-plan.txt` to find failures.

**Key points:**
- Write the capture file to a **literal** `/tmp/opencode/...` path. `tee` to a
  `$(mktemp)` variable is blocked by bash-guard (unresolved-variable write target).
- Capture the real exit code with `echo "EXIT_CODE: ${PIPESTATUS[0]}"` — `$?` would
  report `tee`'s exit code, not pants'.
- Inspect with the Read tool or `rg`; no manual cleanup needed (`/tmp/opencode` is
  ephemeral, and `rm` would trigger a permission prompt).

## Environment

- This skill prefixes pants invocations with `PANTS_CONCURRENT=True` so multiple
  plan/test runs can proceed in parallel. The `PANTS_CONCURRENT=True pants tecton-plan *`
  and `PANTS_CONCURRENT=True pants test *` forms are allow-listed in `opencode.jsonc`,
  so they run without a permission prompt.
- All commands must be run from the data-science repo root.

## Workspaces for Testing

- **`checkoutandsale-v1-staging`**: Staging workspace - check against this first
- **`bence-dev`**: Personal dev workspace for clarifying issues if staging fails with confusing errors

If staging passes, no need to check against `bence-dev`. Use `bence-dev` only when staging errors are unclear.

## Operations

### tecton-plan

Runs `tecton plan` against a workspace. Use `--skip-tests` to speed up iteration.

```bash
# Plan against staging (check this first)
PANTS_CONCURRENT=True pants tecton-plan --workspace=checkoutandsale-v1-staging --skip-tests 2>&1 | tee /tmp/opencode/tecton-plan-staging.txt; echo "EXIT_CODE: ${PIPESTATUS[0]}"

# Plan against dev workspace (only if staging errors are unclear)
PANTS_CONCURRENT=True pants tecton-plan --workspace=bence-dev --skip-tests 2>&1 | tee /tmp/opencode/tecton-plan-dev.txt; echo "EXIT_CODE: ${PIPESTATUS[0]}"
```

Inspect the capture files with the Read tool or `rg`.

### tecton-test-run

Run Tecton tests using the pants test goal with `--tecton-test-run` flag.

```bash
# Run all tecton tests in a directory
PANTS_CONCURRENT=True pants test --tecton-test-run projects/features/repos/sig_tecton/tests/sig_tecton/datasources/orders/::

# Run a specific test file
PANTS_CONCURRENT=True pants test --tecton-test-run projects/features/repos/sig_tecton/tests/sig_tecton/datasources/orders/test_orders_datasources.py

# Run a specific test function
PANTS_CONCURRENT=True pants test --tecton-test-run projects/features/repos/sig_tecton/tests/path/to/test_file.py -- -k test_function_name
```

For long test runs, capture and inspect:

```bash
PANTS_CONCURRENT=True pants test --tecton-test-run projects/features/repos/sig_tecton/tests/:: 2>&1 | tee /tmp/opencode/tecton-test.txt; echo "EXIT_CODE: ${PIPESTATUS[0]}"
```
