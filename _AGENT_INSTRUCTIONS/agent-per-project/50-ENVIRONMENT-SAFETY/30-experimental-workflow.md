# EXPERIMENTAL WORKFLOW

## Purpose

Define the safe procedure for performing high-risk changes to the MessageLens data pipeline.

---

## Core Principle

Never experiment on irreplaceable state.

---

## Workflow

1. Perform SNAPSHOT PROTOCOL

2. Confirm snapshot success

3. Perform experimental changes

4. Observe behavior

---

## If System Behaves Correctly

- proceed
- optionally create new snapshot

---

## If System Behaves Incorrectly

DO NOT:

- attempt incremental fixes
- manually edit databases
- weaken validators

INSTEAD:

1. STOP
2. Perform RECOVERY PROTOCOL
3. Analyze issue using PIPELINE DEBUGGING PROTOCOL

Agents MUST NOT suggest database edits as a first-line response to inconsistency.

---

## Agent Instruction

Before any high-risk task, agent MUST:

1. explicitly recommend snapshot
2. wait for confirmation
3. only then proceed

---

## Example Invocation

User:

"Proceed with archival import experiment. Follow experimental workflow."

Agent:

- performs snapshot protocol
- confirms
- proceeds

---

END
