---
tier: project
scope: presence-onboarding-first-moves
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: implementation-record
links:
  - ./01-CURRENT-OWNERSHIP-INVENTORY.md
  - ./02-TARGET-OWNERSHIP-PROPOSAL.md
  - ./04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md
tests: []
---

# First Mechanical Moves

> **Historical implementation record:** This document describes the first
> pre-generic move. Later slices retired the specialized test authorities and
> branches it deliberately left in place. For current architecture, read
> [`09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md`](09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md).

## Files Moved To Onboarding

| Previous path under `features/presence_iteration_simple/` | New path under `essentials/onboarding/application/` |
| --- | --- |
| `infrastructure/development/linear_presence_experiment_fixture.dart` | `required_sources_readiness_schedule.dart` |
| `infrastructure/development/full_disk_access_presence_adapter.dart` | `full_disk_access_presence_adapter.dart` |
| `infrastructure/development/contacts_source_readiness_presence_adapter.dart` | `contacts_source_readiness_presence_adapter.dart` |
| `application/real_fda_presence_authority_provider.dart` | `real_fda_presence_authority_provider.dart` |
| `application/real_contacts_source_readiness_authority_provider.dart` | `real_contacts_source_readiness_authority_provider.dart` |

The two generated provider files moved with their handwritten owners.

Focused tests moved from the experiment/Presence test trees to
`test/essentials/onboarding/application/`:

- `required_sources_readiness_schedule_test.dart`;
- `full_disk_access_presence_adapter_test.dart`;
- `contacts_source_readiness_presence_adapter_test.dart`;
- `real_fda_presence_authority_provider_test.dart`.

## Why These Moves Were Safe

These files already owned:

- onboarding copy;
- onboarding test order and routes;
- onboarding remediation;
- composition of real onboarding specialists;
- translation of specialist results for the current workflow.

The moves changed physical ownership and imports only. They did not change
definitions, IDs, routing arms, copy, provider behavior, or execution.

## Files Deliberately Not Moved

The following remain under Presence pending the TestStep/Agent decision:

- `domain/entities/step.dart`;
- the three specialized authority contracts;
- specialized subtype tables in `presence_database.dart`;
- specialized branches in `drift_presence_schedule_repository.dart`;
- specialized parameters on `presence_schedule_repository_provider.dart`.

Moving any of these now would either make Presence import Onboarding or require
the prohibited genericization/schema work.

The following remain under `presence_iteration_simple` because they are
development harness concerns:

- host and presentation;
- source-mode substitution;
- diagram and topology projection;
- trace and visualization providers/models/views.

Specialist source readers and repositories remain with Conversation Graph,
Address Book, and onboarding's macOS infrastructure.

## Public Provider Seam

The two onboarding-owned real-authority providers are exported through
`lib/essentials/onboarding/feature_level_providers.dart`. External experiment
consumers use that public seam with explicit `show` lists. Internal onboarding
code continues to import exact sibling files.

## Behavior Preservation

The following remain unchanged:

- Messages source-readiness routing;
- FDA remediation and Settings opening;
- restart at the verification Trip;
- Contacts source-readiness and retry loop;
- Trip-boundary checkpoint semantics;
- execution trace;
- Mermaid topology and live visualization;
- `presence.db` schema and contents;
- production onboarding.

## Verification

The ownership-only move passed:

- focused Onboarding tests: 65 passed;
- complete Presence and development-harness tests: 47 passed;
- architecture tripwires: 354 passed;
- `flutter analyze`: no issues;
- macOS Debug build: succeeded as `MessageLens Development.app`;
- formatting: completed for all moved and affected Dart files;
- checked Mermaid artifact: regenerated successfully from the onboarding-owned
  Schedule definition;
- `git diff --check`: passed.

The macOS build retained the pre-existing CocoaPods warning for
`volume_controller`'s `PrivacyInfo.xcprivacy`; it did not affect the build.

## Unresolved Ownership Questions

The unresolved load-bearing boundary is the reconstruction of specialist work:
how a generic persisted Step can request an opaque specialist Agent without
Presence knowing what that Agent does. This pass intentionally stops before
that design.
