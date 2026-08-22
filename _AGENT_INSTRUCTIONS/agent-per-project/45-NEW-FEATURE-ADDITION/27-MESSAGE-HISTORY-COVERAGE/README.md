---
tier: project
scope: message-history-coverage
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: feature-work-package-index
---

# Feature 27: Message History Coverage

This work package establishes truthful current-Mac message-history accounting.

## Start

- [Opening seed](seed.md)

## Prompts

1. [Correctness and query architecture](prompts/02-MESSAGE-HISTORY-COVERAGE-CORRECTNESS-AND-QUERY-ARCHITECTURE.MD)
2. [Product presentation](prompts/03-MESSAGE-HISTORY-COVERAGE-PRODUCT-PRESENTATION.MD)
3. [Final state and layout conformance](prompts/04-MESSAGE-HISTORY-COVERAGE-FINAL-STATE-AND-LAYOUT-CONFORMANCE.MD)

## Responses

1. [Semantics and architecture audit](responses/01-MESSAGE-HISTORY-COVERAGE-SEMANTICS-AND-ARCHITECTURE-AUDIT.md)
2. [Correctness and query architecture implementation](responses/02-MESSAGE-HISTORY-COVERAGE-CORRECTNESS-AND-QUERY-ARCHITECTURE-IMPLEMENTATION.md)
3. [Product presentation implementation](responses/03-MESSAGE-HISTORY-COVERAGE-PRODUCT-PRESENTATION-IMPLEMENTATION.md)
4. [Final state and layout conformance implementation](responses/04-MESSAGE-HISTORY-COVERAGE-FINAL-STATE-AND-LAYOUT-CONFORMANCE-IMPLEMENTATION.md)

## Current Invariant

Message History Coverage partitions every physical row currently present in
this Mac's `chat.db.message` table by exact current-source row identity.
Historical sources and attachment-recovery donors cannot contribute to that
partition.

The product presentation is intentionally proportional to uncertainty: a
complete report is calm and concise, while an incomplete report makes the
exact exception primary.

## Status

**READY.** The final conformance pass aligns the Track A title through the same
canonical center-column geometry as the report body, preserves one stable
composition across every report state, and closes the feature without changing
its settled accounting semantics.
