# Temporary Exceptions

This file is the single tracking point for any temporary migration exception
introduced during the authorship refactor.

Rules:

- A temporary exception must be explicit, narrow, and phase-scoped.
- A temporary exception must not become an alternate semantic writer.
- A temporary exception must not retain hidden UI state or executable behavior.
- If removing the exception changes user-visible behavior, the exception was
  carrying meaning and is invalid.
- Untracked exceptions are not allowed.

## Current Status

No temporary exceptions are currently tracked.

## Required Entry Format

When an exception is introduced, add one entry using this structure:

### Exception: <short conspicuous name>

- Location:
- Reason:
- Scope:
- Removal phase:
- Why it is not a semantic writer:
- Why it does not retain hidden state:
- What test/assertion/check will fail if it survives too long:
