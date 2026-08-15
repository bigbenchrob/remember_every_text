---
tier: project
scope: onboarding-source-readiness
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: implementation-record
links:
  - 54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
tests:
  - test/essentials/conversation_graph/infrastructure/repositories/sqlite_chat_db_source_probe_reader_test.dart
  - test/essentials/onboarding/application/messages_source_readiness_test_agent_test.dart
  - test/essentials/onboarding/infrastructure/system/macos_full_disk_access_test.dart
  - test/essentials/onboarding/application/required_sources_readiness_schedule_test.dart
  - test/essentials/onboarding/presentation/onboarding_presence_host_test.dart
---

# Truthful Messages Source Vs FDA Readiness Implementation

## Corrected Defect

Validation 54 found that the production prerequisite journey reduced every
failed Messages-source read to one Boolean. Every `false` result therefore
entered Full Disk Access remediation, including missing files, invalid SQLite
content, absent Messages schema, and other I/O failures for which FDA was not
the established cause.

This slice replaces that collapse with the smallest product distinction the
available evidence can support:

```text
MessagesSourceAccessResult
    readable
    accessDenied
    unavailable
```

Only `accessDenied` supports FDA guidance. All other failed reads become the
bounded, non-FDA `unavailable` result.

## Evidence Boundary

The source specialist still performs the real protected operation. Before the
read-only SQLite query, it opens the source file read-only so macOS filesystem
denial remains available as concrete evidence.

The low-level probe records:

- `EPERM` or `EACCES` while opening the source file: `accessDenied`;
- `ENOENT`: source missing;
- another filesystem error: filesystem read failure;
- SQLite open failure;
- expected Messages schema unavailable;
- query failure;
- successful query.

The product result intentionally does not expose that diagnostic detail.
Missing, invalid, schema, query, and ambiguous filesystem/SQLite failures all
project to `unavailable`.

MessageLens deliberately does **not** treat SQLite `CANTOPEN` by itself as FDA
proof. It also does not tell the person the source is corrupt, invalid, or
missing unless that narrower fact is independently useful and established.

## Ownership And Projection

The specialist owns concrete filesystem, SQLite, and Messages-source evidence.
Onboarding owns the human routing. Presence remains domain-blind.

Two Onboarding-owned generic `TestAgent` projections preserve the existing
Boolean Presence grammar:

1. `onboarding.messages-source-readable` begins one fresh evaluation.
2. When that result is false,
   `onboarding.messages-source-access-denied` consumes the same process-local
   observation and answers whether FDA remediation is warranted.

This prevents adjacent TestSteps from combining two different probes. The
observation is not durable and is not an indefinite cache. A retry returns to
the readable TestStep, which always performs a fresh evaluation. After process
reconstruction, the classification projection also evaluates afresh if no
current observation exists.

## Authored Workflow

The production Schedule now routes as follows:

```text
readable?
    yes -> ordinary Contacts and history checks
    no  -> access denied?
               yes -> existing FDA remediation and verification
               no  -> calm Messages-source-unavailable guidance
                         -> continue
                         -> fresh readable check
```

The non-FDA surface says only that MessageLens cannot currently use the
person's Messages data and suggests allowing recent Messages or local-data
changes to settle before continuing. It exposes no unsupported repair command,
raw exception, SQLite term, path, or FDA action.

The existing FDA journey still opens the macOS Full Disk Access settings pane
and re-checks the real protected read after restart. This slice initially tried
to change canonical Tell Step 6302 from **MessageLens Development** to
**MessageLens** under the same identity. Slice 56 restored its persisted payload
after the real upgrade path correctly rejected that semantic redefinition. A
future product-copy refinement requires a new canonical semantic identity; it
must not rewrite Step 6302.

## Compatibility

The two new Trips are an additive Schedule extension. Existing occurrence
identity is retained, the canonical confirmation occurrence is moved to the
final resolved position, and every pre-existing non-Test Step retains its
persisted meaning. See the
[Step-redefinition blocker correction](56-OBSERVED-ONBOARDING-STEP-REDEFINITION-BLOCKER-IMPLEMENTATION.md).

Unchanged:

- generic Presence `TestStep` and Boolean routing;
- Messages-history sufficiency and its `0-10` / `11+` policy;
- sparse-history `Re-check` / `Import Anyway` Choice;
- durable accepted-readiness handoff;
- `OnboardingGate` operational ownership and real production host;
- explicit opt-in Presence development harness;
- reset, mutation coordination, automatic recovery, and attachment archival.

No production archive was used to classify or manufacture failures.

## Verification

Focused tests establish:

- healthy, explicit permission-denied, missing, invalid-schema, query, and
  ambiguous filesystem outcomes;
- one coherent observation across adjacent Boolean projections;
- fresh evaluation after retry and process reconstruction;
- healthy, FDA, and non-FDA authored Schedule routes;
- FDA copy and Settings behavior;
- absence of FDA remediation in the non-FDA source journey;
- additive definition extension and checkpoint preservation;
- production resolver composition with both generic Onboarding Agents.

The remaining manual visual checks are:

1. FDA denied shows FDA guidance.
2. Restored FDA continues successfully.
3. A safely substituted disposable missing/unusable source shows no FDA
   guidance.
4. A future newly identified FDA instruction may use product-neutral naming;
   canonical Step 6302 must retain its historical payload.

Use development substitutions or disposable fixtures for the third check.
Do not alter the production source or production archive.

## Deviation From Validation 54

Validation 54 described the repair at the product-flow level but did not yet
identify reliable platform evidence. The implemented boundary is deliberately
narrower than a rich source-error taxonomy: only explicit POSIX permission
denial earns FDA specificity; every other failed protected read remains
truthfully unavailable.
