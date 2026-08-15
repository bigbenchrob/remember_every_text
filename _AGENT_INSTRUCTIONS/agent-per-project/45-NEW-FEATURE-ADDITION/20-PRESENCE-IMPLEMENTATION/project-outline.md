# Presence Tracer-Bullet Implementation Plan

The seed defines a sound tracer-bullet scope. The canonical Presence package
is complete and normative. This plan describes how to prove that architecture
without redesigning it or coupling it to onboarding, archive ingestion, or any
other MessageLens feature.

No implementation begins under this plan until its first coding task is
explicitly approved.

## Architectural Direction

Presence becomes a permanent project-wide subsystem at:

```text
lib/essentials/presence/
```

It is not an experiment and must not be organized around its first production
clients.

The tracer bullet is the first disposable client of Presence. It lives at:

```text
lib/features/presence_tracer/
```

This placement makes the dependency direction explicit:

```text
presence_tracer feature
    -> Presence contracts and coordination

Presence
    -> no MessageLens feature
```

Presence must never import onboarding, archive ingestion, Messages, Contacts,
attachments, or any other feature implementation. Features may depend on
Presence. Presence depends on no feature. This is an implementation invariant,
not merely a folder convention.

## Responsibility Chain

```text
Tracer client
    supplies Journey meaning
        |
        v
Pure Journey derivation
    derives exactly one truthful Episode
        |
        v
Journey Coordinator
    validates Provenance and commits transitions
        |
        v
Renderer
    projects the Active Episode
        |
        v
Presentation
    displays one interaction and returns typed events
```

The Journey owns continuity but performs no operational work. The Coordinator
owns transitions but not rendering. The Renderer preserves Episode semantics
but has no transition authority. Presentation owns concrete Flutter widgets
but never becomes Journey truth.

## Revised Package Layout

```text
lib/essentials/presence/
├── model/
│   ├── journey_identity.dart
│   ├── journey_revision.dart
│   ├── journey_lifecycle.dart
│   ├── episode_identity.dart
│   ├── activation_occurrence.dart
│   ├── interaction_occurrence.dart
│   ├── provenance.dart
│   ├── presence_journey.dart
│   ├── presence_episode.dart
│   ├── inform_episode.dart
│   └── ask_episode.dart
├── contracts/
│   ├── journey_derivation.dart
│   ├── journey_store.dart
│   └── renderer_interaction.dart
├── coordinator/
│   ├── journey_coordinator.dart
│   └── journey_coordinator_provider.dart
├── renderer/
│   ├── presence_renderer.dart
│   ├── renderer_input.dart
│   ├── renderer_output.dart
│   └── presentation_policy.dart
├── presentation/
│   ├── presence_renderer_view.dart
│   ├── inform_episode_view.dart
│   └── ask_string_episode_view.dart
└── feature_level_providers.dart

lib/features/presence_tracer/
├── domain/
│   ├── tracer_journey.dart
│   ├── tracer_journey_position.dart
│   └── tracer_journey_derivation.dart
├── application/
│   └── tracer_journey_actions_provider.dart
├── infrastructure/
│   └── in_memory_tracer_journey_store.dart
├── presentation/
│   └── presence_tracer_view.dart
└── feature_level_providers.dart
```

The exact file count may shrink when implementation shows that two small types
belong together. The ownership boundaries must not blur:

- `model/` contains immutable Presence identities and state descriptions;
- `contracts/` contains boundaries implemented or consumed by clients;
- `coordinator/` contains transition validation and commitment;
- `renderer/` contains semantic-preserving projection contracts;
- `presentation/` contains concrete Flutter presentation;
- `features/presence_tracer/` owns the example Journey's meaning, copy, state,
  and temporary in-memory storage.

The permanent Presence subsystem must not import the tracer client. The tracer
is made reachable through a small development-only application integration,
not through a separate `tool/` entry point and not through onboarding.

## Architectural Mapping

- **Journey:** immutable client-owned state containing stable identity,
  revision, lifecycle, semantic position, accepted name, and foreground
  disposition.
- **Episode:** a pure projection of current Journey truth. Only `Inform` and
  `Ask<String>` receive concrete support in this slice.
- **Coordinator:** validates current Provenance, rejects stale and duplicate
  interactions, commits one atomic revision, and requests fresh derivation.
- **Renderer:** receives the already-derived Active Episode and preserves its
  family, purpose, Completion Authority, and permitted interactions.
- **Presentation:** displays the Renderer input and emits only declared typed
  interactions. It never changes Journey state directly.
- **Provenance:** carries Journey identity, Journey revision, Episode identity,
  activation occurrence, and interaction occurrence.
- **Moment:** deliberately absent. The tracer introduces no placeholder Moment
  model or empty ambient-content machinery.
- **State storage:** accessed through a Presence contract. The tracer supplies
  an in-memory implementation and makes no production durability claim.

## Tracer Journey

The architecture-correct sequence is:

```text
Journey created
    |
    v
Inform / welcome
    |
    v
Inform / explanation
    |
    v
Ask<String>
    |
    v
typed response accepted
    |
    v
Journey becomes Completed
    |
    v
Inform / completion
    |
    v
Foreground released
```

The completion-purpose `Inform` communicates terminal Journey truth that has
already been established. Rendering or acknowledging that Episode does not
complete the Journey. Its acknowledgement only permits foreground Presence to
be released under the Journey contract.

## Revised Implementation Stages

### Stage 1: Identity, Revision, and Provenance

Implement only these immutable value objects:

- `JourneyIdentity`;
- `JourneyRevision`;
- `EpisodeIdentity`;
- `ActivationOccurrence`;
- `InteractionOccurrence`;
- `Provenance`.

Add focused pure-Dart unit tests for construction, equality, revision and
occurrence distinction, and complete Provenance identity. This stage contains
no Flutter, Riverpod, widgets, Renderer, Coordinator, Journey behaviour, or UI.

### Stage 2: Pure Journey Derivation

Introduce the minimum immutable Journey and Episode models required by the
tracer, together with one pure derivation contract and implementation.

Prove with pure-Dart tests that every valid immutable tracer Journey state
derives exactly one truthful Episode:

- created/ongoing welcome -> `Inform / welcome`;
- explanation position -> `Inform / explanation`;
- pending name -> `Ask<String> / input`;
- completed Journey awaiting summary discharge -> `Inform / completion`.

This stage has no Flutter, Riverpod, rendering, or Coordinator. It isolates the
semantic engine before orchestration exists.

### Stage 3: Journey Coordinator

Add the Coordinator and Journey-store contract. The tracer supplies its
in-memory store implementation.

Implement:

- Journey creation and foreground activation;
- acknowledgement handling;
- typed `String` response acceptance;
- atomic revision advancement;
- current-Provenance validation;
- stale activation rejection;
- duplicate interaction-occurrence rejection;
- Episode replacement and activation-occurrence renewal;
- completion before derivation of `Inform / completion`;
- foreground release after summary acknowledgement.

The Coordinator remains independent of Flutter and feature implementations.

### Stage 4: Renderer Contracts

Implement the minimum Renderer input, output, typed interaction, and
Presentation Policy contracts needed for `Inform` and `Ask<String>`.

Verify that the Renderer receives an already-derived Active Episode and can
produce only declared, provenance-bearing output. Do not add Moments,
automatic progression, `Work`, or `Await` support.

### Stage 5: Flutter Presentation

Implement restrained `Inform` and `Ask<String>` views using the existing theme
providers. Text-entry candidate state remains presentation-local. Submission
returns a typed candidate and never commits Journey state directly.

Widget tests verify one meaningful thing at a time, typed submission, current
Provenance, validation feedback presentation, and immediate loss of
interactivity after Episode replacement.

### Stage 6: Tracer Client Integration

Add `features/presence_tracer` as the first Presence client and expose it
through a narrowly scoped development-only application affordance. Do not
route it through onboarding or make production navigation depend on it.

Run the complete visible Journey from welcome through foreground release.
Presence remains permanent; this client may later be removed without changing
the subsystem.

### Stage 7: Reconstruction and Architecture Verification

Recreate the Coordinator over the same in-memory tracer store and verify:

- Journey identity remains stable;
- the same logical Episode identity is re-derived when still truthful;
- a new activation occurrence is issued;
- accepted decisions remain authoritative in the retained store;
- interactions from the earlier activation are rejected.

Add dependency tests proving that `lib/essentials/presence/` imports no feature
implementation and that no feature owns or redefines Presence protocols.

This simulates restart reconciliation without claiming persistence across a
real process restart.

## Revised Commit Sequence

1. `feat: add Presence authority value objects`
   - The six immutable value objects only.
   - Pure unit tests only.
   - No UI, Riverpod, widgets, Renderer, Coordinator, or Journey behaviour.

2. `feat: add pure Presence journey derivation`
   - Minimum Journey and Episode models.
   - Tracer Journey state and deterministic derivation.
   - Pure derivation tests.

3. `feat: add Presence journey coordination`
   - Coordinator and store contract.
   - Tracer-owned in-memory store.
   - Transition, atomicity, stale-event, and duplicate-event tests.

4. `feat: add Presence renderer contracts`
   - Renderer input/output and Presentation Policy contracts.
   - No concrete application integration.

5. `feat: add Presence tracer presentation`
   - Flutter Renderer views and widget tests.
   - Disposable tracer feature and development-only entry affordance.

6. `test: verify Presence reconstruction and boundaries`
   - Full tracer flow.
   - Coordinator reconstruction.
   - Dependency and architecture tests.

Every commit must compile and pass its focused tests. Generated Riverpod code
is introduced only in the first stage that genuinely requires provider wiring.

## Hard Implementation Invariants

- Presence is permanent; the tracer client is disposable.
- Presence imports no MessageLens feature implementation.
- Features may depend on Presence; Presence depends on no feature.
- Exactly one Episode is derived for every valid Foreground Journey state.
- Exactly one Active Episode exists while Presence is engaged.
- Only the Coordinator commits Journey transitions.
- Rendering never becomes Journey truth.
- Every Coordinator-bound Renderer event carries current Provenance.
- Stale activation and duplicate interaction occurrences are rejected
  mechanically.
- `Ask<String>` returns a typed candidate; presentation does not commit it.
- Journey completion precedes `Inform / completion`.
- Episode identity may survive reconstruction; activation occurrence must not.
- No Moments, feature operations, database, filesystem work, production
  onboarding integration, or speculative Episode families enter this slice.

## Remaining Implementation Risks

1. **Durability boundary**
   The seed excludes database and filesystem work. The tracer can prove a
   reconstruction-safe contract over retained in-memory state, but cannot prove
   persistence across process termination. A production client must not adopt
   Presence until a truthful durable Journey-store implementation exists.

2. **Generic contracts versus speculative abstraction**
   The derivation and store contracts must be sufficient for the tracer client
   without becoming a registry, workflow engine, or hypothetical multi-feature
   framework. Generalization should occur only when a second real client
   requires it.

3. **Typed rendering boundary**
   The model may represent `Ask<T>`, but the first concrete presentation handles
   only `Ask<String>`. It must not fall back to `dynamic`, untyped maps, or
   generic button events.

4. **Terminal Journey presentation**
   The Coordinator must allow a completed Journey to retain foreground Presence
   long enough to communicate its completion summary without implying that the
   summary completes the Journey or that a terminal Journey returned to
   Ongoing.

5. **Development-only client access**
   The tracer needs a visible application-owned entry without contaminating
   onboarding or production navigation. That integration should remain small,
   explicitly temporary, and dependent on the tracer feature rather than the
   Presence subsystem.

6. **Occurrence generation and duplicate rejection**
   Interaction occurrences must identify semantic submissions rather than
   rebuilds or pointer events. Their acceptance must remain atomic with the
   corresponding Journey transition.

## First Implementation Task

The first coding task is deliberately narrower than the rest of Presence.

Implement only:

- `JourneyIdentity`;
- `JourneyRevision`;
- `EpisodeIdentity`;
- `ActivationOccurrence`;
- `InteractionOccurrence`;
- `Provenance`;
- focused pure-Dart unit tests.

Do not add Flutter, Riverpod, widgets, Renderer contracts, Coordinator logic,
Journey behaviour, tracer UI, persistence, or application integration in that
commit.

This establishes the complete authority chain before any behavioural or
presentation code exists.
