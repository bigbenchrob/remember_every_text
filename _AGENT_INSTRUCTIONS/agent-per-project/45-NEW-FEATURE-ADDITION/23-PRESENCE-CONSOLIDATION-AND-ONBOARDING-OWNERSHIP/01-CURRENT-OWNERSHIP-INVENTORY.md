---
tier: project
scope: presence-onboarding-ownership-inventory
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: code-audit
links:
  - ./00-START-HERE.md
  - ./02-TARGET-OWNERSHIP-PROPOSAL.md
tests: []
---

# Current Ownership Inventory

> **Historical snapshot:** This inventory records the pre-generic ownership
> pressure at the start of the consolidation. For current architecture, read
> [`09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md`](09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md).

## Classification Key

- **A — Generic Presence machinery**
- **B — Onboarding-owned workflow meaning**
- **C — Specialist implementation owned elsewhere**
- **D — Development/test harness only**
- **E — Unclear; requires an architectural decision**

Generated Riverpod and Drift files follow the ownership of their handwritten
source and are not separate architectural units.

## Presence

| Current file or group | Class | Why |
| --- | --- | --- |
| `domain/entities/execution_trace_event.dart` | A | Closed, domain-neutral execution observations. |
| `domain/entities/schedule_definition.dart` | A | Generic Schedule composition. |
| `domain/entities/schedule_run.dart` | A | Generic durable Trip checkpoint. |
| `domain/entities/trip.dart` and `trip_definition_id.dart` | A | Generic transient Trip execution and canonical Trip identity. |
| `domain/repositories/presence_schedule_repository.dart` | A | Generic definition, run, checkpoint, and trace contract. |
| `domain/services/presence_scheduler.dart` | A | Generic Schedule execution and Trip-boundary checkpointing. |
| `infrastructure/data_sources/local/presence_database.dart` | E | Most tables are generic, but FDA, Contacts-readiness, and FDA-Settings subtype tables encode onboarding meanings. |
| `infrastructure/repositories/drift_presence_schedule_repository.dart` | E | Generic persistence is mixed with construction, validation, and authority injection for three onboarding-specific Step types. |
| `application/presence_schedule_repository_provider.dart` | E | Opens generic Presence persistence but requires three onboarding-specific capabilities. |
| `domain/entities/step.dart` | E | `TellStep` and `FixedDestinationStep` are generic; `FdaTestStep`, `ContactsSourceReadinessStep`, and `OpenFdaSettingsStep` carry onboarding meaning. |
| `domain/services/messages_source_readiness_authority.dart` | E | A good narrow capability, but its Messages meaning is not generic workflow machinery. |
| `domain/services/contacts_source_readiness_authority.dart` | E | A good narrow capability, but its Contacts meaning is not generic workflow machinery. |
| `domain/services/fda_settings_opening_authority.dart` | E | A good narrow capability, but its macOS FDA meaning is not generic workflow machinery. |
| `feature_level_providers.dart` | A/E | The public repository seam is appropriate; the provider it exports currently carries the specialized dependency problem above. |

The E files are genuine boundary pressure. They remain untouched because
correcting them requires the later `TestStep`/Agent-resolution decision and
possibly a schema migration.

## Onboarding

| Current file or group | Class | Why |
| --- | --- | --- |
| Existing `lib/essentials/onboarding/domain/` | B | Owns onboarding status, environment meaning, and onboarding `ViewSpec`. |
| Existing gate, environment-report, reset, failure, and readiness application files | B | Decide onboarding state and coordinate onboarding behavior. |
| Existing onboarding overlay and development panel | B/D | Overlay is current onboarding presentation; the dev panel is a development surface. |
| `application/required_sources_readiness_schedule.dart` | B | Owns user copy, test order, remediation, destinations, and the complete required-sources workflow. |
| `application/full_disk_access_presence_adapter.dart` | B | Translates onboarding's existing protected-source service into the current Presence capabilities. |
| `application/contacts_source_readiness_presence_adapter.dart` | B | Translates specialist Address Book results into onboarding's current readiness fact. |
| `application/real_fda_presence_authority_provider.dart` | B | Composes the real onboarding FDA service for the workflow. |
| `application/real_contacts_source_readiness_authority_provider.dart` | B | Composes the real Contacts specialist for the workflow. |

The last five files graduated from the temporary experiment feature during
this pass. They were already answering onboarding questions rather than
generic Presence questions.

## Specialist Owners And Candidate Agents

An **Agent**, in the current architectural discussion, means a specialist
invoked by a Step to perform domain-specific work or establish a fact. This is
a role, not a new base class.

| Specialist | Class | Existing narrow seam | Ownership assessment |
| --- | --- | --- | --- |
| `SqliteChatDbSourceProbeReader` | C | `ChatDbSourceProbeReader` | Conversation Graph owns truthful read-only `chat.db` probing. Onboarding consumes the result; Presence must not learn SQLite. |
| `AddressBookFolderRepository` and its path/SQLite helpers | C | `getFinalFolderAggregate()` | Address Book owns source discovery, viability, ranking, and querying. Onboarding consumes availability. |
| `MacosFullDiskAccess` | C within Onboarding infrastructure | `FullDiskAccess` | Owns the macOS protected-source path and FDA Settings action. It does not route a Schedule. |
| macOS `open` process invocation inside `MacosFullDiskAccess` | C within Onboarding infrastructure | `FullDiskAccess.openSettings()` | Platform-specific remediation work remains outside Presence. |

These are current Agent candidates. No registry, common Agent interface, or
persisted Agent identity is justified by this inventory alone.

## `presence_iteration_simple` Experiment Feature

| File or group | Class | Disposition |
| --- | --- | --- |
| `application/linear_presence_experiment_provider.dart` | D | Keep. Development host composition and explicit experiment startup. |
| diagram, trace, and visualization providers | D | Keep. Read-only laboratory observation. |
| `presence_run_visualization.dart` and builder | D | Keep. Development visualization model. |
| `application/development_contacts_source_provider.dart` | D | Keep. Machine-local source substitution for repeatable testing. |
| `infrastructure/development/development_contacts_source_mode_store.dart` | D | Keep. Laboratory configuration only. |
| `development_contacts_source_readiness_authority.dart` | D | Keep. Chooses the configured real/disposable test condition. |
| Mermaid document/renderer and topology projection/projector | D | Keep. Development definition inspection. |
| `presentation/linear_presence_experiment_host.dart` | D | Keep. Disposable manual execution host. |
| `presence_presentation_tokens.dart` | D | Keep. Current experiment presentation only. |
| `schedule_run_visualization_view.dart` | D | Keep. Live inspection surface only. |
| former `linear_presence_experiment_fixture.dart` | B | Graduated to Onboarding as `required_sources_readiness_schedule.dart`. |
| former FDA and Contacts Presence adapters/providers | B | Graduated to Onboarding application ownership. |

No current experiment file should graduate into generic Presence. The
experiment uses Presence; it does not define Presence machinery.

## Production Onboarding

`OnboardingGate`, Environment Readiness, current overlay behavior, archive
admission, production preservation, source access policy, import, graph build,
and attachment archival remain unchanged. The new Schedule remains exercised
through the development host and has not replaced production onboarding.

## Boundary Findings

1. The ownership conjecture is supported by the current repository.
2. The Schedule definition and integration adapters were the clearest misplaced
   onboarding code.
3. Presence currently contains onboarding-specific Step and persistence
   knowledge. This is architectural debt proven by code, not a reason to rush
   a generic abstraction.
4. Specialist expertise is already separated behind narrow contracts.
5. The experiment feature is now substantially a true client/harness rather
   than the owner of onboarding meaning.
