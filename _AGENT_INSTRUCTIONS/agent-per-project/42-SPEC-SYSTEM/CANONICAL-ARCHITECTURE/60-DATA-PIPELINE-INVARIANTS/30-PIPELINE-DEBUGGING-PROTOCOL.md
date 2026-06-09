# PIPELINE DEBUGGING PROTOCOL

## Purpose

This document defines the required step-by-step process for diagnosing and
fixing source-scoped graph pipeline issues.

Agents MUST follow this protocol.

Do not skip steps.
Do not jump directly to fixes.
Do not modify data before understanding the failure.

---

## 1. Guiding Principles

- The system is invariant-driven.
- Most bugs are invariant violations.
- Symptoms are not root causes.
- Data is evidence, not something to "fix".
- Retained legacy compatibility paths are not ordinary app authority.

---

## 2. High-Level Flow

1. Observe the symptom.
2. Classify the failure mode.
3. Identify the violated invariant.
4. Locate the responsible layer.
5. Gather evidence read-only.
6. Form a hypothesis.
7. Confirm the hypothesis.
8. Implement the minimal fix.
9. Add a regression test.

---

## 3. Step 1 — Observe The Symptom

Examples:

- graph build failed.
- UI missing data.
- duplicate data visible.
- system appears idle after source change.
- search/heatmap/timeline navigation disagrees with visible rows.
- attachment evidence missing even though source/graph rows exist.
- retained compatibility path appears in an ordinary app surface.

Record:

- exact error message.
- logs.
- graph status panel values.
- timestamps.
- triggering action: startup, poll, import, graph build, archive/recovery,
  search, or UI navigation.

---

## 4. Step 2 — Classify Failure Mode

Use:

`20-PIPELINE-FAILURE-MODES.md`

Select one or more:

- source-scoped ledger incompleteness.
- graph projection inconsistency.
- cursor false no-op.
- trigger/orchestration failure.
- authority boundary violation.
- overlay authority violation.
- evidence spine violation.
- retained compatibility leakage.
- silent tolerance failure.

Do NOT proceed without classification.

---

## 5. Step 3 — Identify Violated Invariant

Use:

`10-PIPELINE-INVARIANTS-CORE.md`

Examples:

- `working_ss.db` must match graph projection rules.
- graph relationships use canonical `ss_id` endpoints.
- overlay user intent is not projection data.
- timeline-like evidence scopes use full skeletons, not pagination.
- source-scoped import is the ordinary source-fact boundary.

State explicitly:

> "Invariant violated: ..."

---

## 6. Step 4 — Locate The Layer

Determine where the problem originates:

- source (`chat.db`, AddressBook, Apple attachment paths)
- source-scoped ledger (`macos_import_ss.db`)
- graph projection (`working_ss.db`)
- overlay merge (`user_overlays.db`)
- evidence spine scope/skeleton/hydration
- retained compatibility bridge (`macos_import.db`, `working.db`)
- orchestration / monitor
- UI rendering

Do not guess. Verify with evidence.

---

## 7. Step 5 — Gather Evidence (READ-ONLY)

This is the most important step.

### 7.1 Database Inspection

Use read-only SQL only. No writes.

Typical checks:

- source/import/graph row counts.
- `MAX(source_rowid)` versus source cursor.
- graph endpoint anti-joins.
- duplicate edge detection.
- missing `ss_id` / invalid identity checks.
- overlay key form and merge precedence.

### 7.2 Logs And Status

Look for:

- `ChatDbChangeMonitor` decisions.
- graph build start/stop/stage timing.
- source-scoped import counts.
- graph projection counts.
- graph health diagnostics.
- evidence spine scope/skeleton size.
- retained compatibility bridge usage.

### 7.3 Code Path Tracing

Identify:

- where decisions are made.
- where graph build or retained compatibility rebuild runs.
- where validation occurs.
- where evidence scopes are composed.
- where row hydration is performed.

---

## 8. Step 6 — Form Hypothesis

Examples:

- "`working_ss.db.chat_to_message` is missing edges for imported source rows."
- "Startup concluded graph was ready from cursor equality, but import count is
  lower than source count."
- "A recovered surface is still using retained `working.db` as ordinary
  authority."
- "A message-bearing surface uses latest-N hydration instead of a full
  skeleton."

Hypothesis MUST:

- explain all observed symptoms.
- map to a known failure mode.
- identify the layer that owns the fix.

---

## 9. Step 7 — Confirm Hypothesis

Confirm using additional read-only checks:

- targeted SQL queries.
- graph health report.
- evidence scope/skeleton inspection.
- focused reproduction.
- provider dependency tracing.

Do not proceed to fix until confirmed.

---

## 10. Step 8 — Implement Fix

Rules:

- fix logic, not data.
- preserve invariants.
- keep change localized to the owning layer.

Typical fix locations:

- source-scoped importer.
- graph projector/build service.
- graph readiness/health checker.
- evidence scope/skeleton/hydration provider.
- overlay merge repository.
- retained compatibility bridge.
- lifecycle/orchestration service.

DO NOT:

- delete data as a "solution".
- weaken validation.
- add fallback paths.
- patch `working_ss.db` or retained `working.db` as the real fix.
- put SQL/semantic policy in widgets.

---

## 11. Step 9 — Add Regression Test

Every fix SHOULD include a test that:

- reproduces the failure condition.
- verifies correct behavior after the fix.

Examples:

- graph edge projected after source topology import.
- equal cursor + count mismatch triggers graph rebuild.
- duplicate graph edge prevented.
- overlay display name wins over graph/imported name.
- evidence scope search matches full skeleton, not visible rows only.

---

## 12. Emergency Data Intervention (Rare)

Allowed only when:

- user is blocked.
- root cause is already understood.
- fix is being implemented separately.

Examples:

- clearing one corrupt local derived database before a graph rebuild.

Requirements:

- must not touch Apple source data.
- must not touch overlay user intent unless user explicitly requests it.
- must be documented.
- must not replace the proper fix.

---

## 13. Anti-Patterns

Agents MUST NOT:

- jump to fixes without classification.
- modify DB before understanding issue.
- weaken validators.
- introduce new data paths.
- rely on "seems to work" behavior.
- treat retained legacy DBs as the ordinary app source.
- create source-specific message renderers.

---

## 14. Example

Symptom:

- Contact heatmap shows full date range, but handle-filtered messages jump to
  seemingly random months.

Classification:

- evidence spine violation.

Invariant violated:

- timeline-like scopes must use the full logical selected message universe;
  pagination is not timeline navigation.

Evidence:

- heatmap used all-contact skeleton while message list used handle-filtered
  hydration.

Root cause:

- selected handle was not included in the evidence skeleton scope.

Fix:

- compose handle-filtered `MessageEvidenceScope` before skeleton construction.

---

## 15. Key Insight

Debugging is not:

> "fix the bug"

It is:

> "identify the violated invariant and restore it"

---

END
