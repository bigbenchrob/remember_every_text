Do not implement Iteration 1A yet.

The revised planning response correctly recovered MessageLens’s DDD conventions, but we now want to reconsider one ownership decision:

Should the generic Journey-definition database and its loading boundary live under a shared Presence essential rather than inside the first experimental feature?

This is a focused architecture-and-placement review.

Do not write application code.
Do not modify database schema.
Do not begin Iteration 1A implementation.
Do not restore concepts from the historical 43-PRESENCE architecture.

Read:

- the three PRESENCE-ITERATION-SIMPLE root orientation documents;
- the latest 03-BASIC-DB-AND-DART-ENTITIES-RESPONSE.md;
- the project’s DDD and feature-ownership documentation;
- representative code under lib/essentials/;
- the existing essentials/db architecture;
- representative feature domain and infrastructure folders.

---

## Controlling premise

This remains an implementation-led redesign from first principles.

We are not restoring the previous Presence architecture.

However, the current iteration has already identified data that appears intrinsically shared rather than owned by the disposable three-step client:

journeys

- id
- name

steps

- id
- journey_id
- position
- text

These records describe Journeys and Steps generically.

They do not describe:

- onboarding;
- archive ingestion;
- the tracer;
- one MessageLens domain feature;
- one specific presentation.

The three-step Tell feature is the first client of that data, not necessarily its owner.

---

## Question to resolve

Would the following ownership better match the actual design?

Shared Presence essential
owns generic Journey and Step definitions,
their database schema,
and the narrow loading boundary.

Experimental feature
supplies or requests Journey 42,
owns the temporary real-world test and presentation,
and later owns in-memory progress for this iteration.

In other words:

lib/essentials/presence/
shared Journey-definition capability

lib/features/<experimental-presence-client>/
first client of that capability

Do not accept this automatically. Test it against the repository’s real DDD rules.

---

## Important distinction

Do not treat “possibly reusable in future” as sufficient justification for essentials.

Instead evaluate whether the current model is already non-feature-specific today.

Ask:

1. If the experimental three-step feature were deleted tomorrow, would Journey, Step, their ordering, and loadJourney(id) still form a coherent shared capability?
2. Does placing the schema inside the feature create false ownership?
3. Would another client such as onboarding, archive ingestion, or contextual help reasonably consume the same definitions without depending on the tracer feature?
4. Does the existing repository treat shared databases and repositories as essentials even when their first client is only one feature?
5. Is this best understood as a new shared subsystem, or is that conclusion still premature?

---

## Potential shared structure

Evaluate a structure consistent with the project’s actual conventions, conceptually resembling:

lib/essentials/presence/
├── domain/
│ ├── entities/
│ │ ├── journey.dart
│ │ └── step.dart
│ └── repositories/
│ └── journey_repository.dart
└── infrastructure/
├── data_sources/
│ └── local/
│ ├── journey_database.dart
│ └── journey_seed.dart
└── repositories/
└── drift_journey_repository.dart

This is only a candidate.

Do not copy it if the repository uses a different established essentials structure.

Inspect the actual tree and propose the narrowest compliant layout.

---

## Repository question

The prior response deliberately avoided a repository and exposed:

loadJourney(int id)

directly on the Drift database.

Reconsider this in light of shared DDD ownership.

Determine whether MessageLens conventions require:

- a domain-facing repository contract;
- a concrete Drift repository implementation;
- the database to remain an infrastructure detail.

Do not introduce a repository merely because DDD textbooks use one.

Introduce it only if it serves a concrete present requirement:

The experimental feature should consume Journey definitions without knowing Drift.

If a repository is warranted, it should initially expose only the operation required now:

loadJourney(int id)

No creation, update, deletion, search, generic queries, caching, or future-facing API.

---

## Database lifecycle boundary

Keep separate:

1. Ownership of Journey schema and loading behaviour.
2. Physical SQLite lifecycle, path authority, opening, closure, and inventory.

Determine how these relate to the existing essentials/db system.

A likely result may be:

- essentials/presence owns the schema and repository;
- essentials/db supplies the centralized physical database lifecycle bridge.

But inspect the project and state the actual correct dependency direction.

Do not duplicate responsibilities already owned by essentials/db.

---

## Experimental seed

Reconsider whether Journey 42 seed data belongs inside the shared essential.

The schema and loading capability may be generic while:

Hello one
Hello two
Hello three

remain laboratory fixture data owned by the experimental client or its development integration.

Prefer not to place disposable tracer content inside permanent shared infrastructure unless there is a concrete reason.

Distinguish:

- shared schema;
- shared entities;
- shared loading contract;
- experimental Journey 42 fixture.

---

## Preserve the minimal model

Unless this ownership review reveals a genuine problem, preserve:

journeys

- id
- name

steps

- id
- journey_id
- position
- text

Journey

- id
- name
- ordered Steps

Step

- id
- text

Do not add:

- Step types;
- Tell subclasses;
- runtime progress;
- current Step;
- Done;
- status;
- persistence of execution;
- Ask;
- Wait;
- actions;
- completion criteria;
- providers beyond an immediate repository convention;
- generic protocols;
- historical Presence concepts.

---

## Required deliverable

Revise only the ownership, layering, file-placement, repository, lifecycle, and seed sections of:

03-BASIC-DB-AND-DART-ENTITIES-RESPONSE.md

Do not implement code.

Report:

1. Repository documentation and examples inspected.
2. Whether Journey/Step are already genuinely shared concepts in Iteration 1A.
3. Whether a new lib/essentials/presence/ home is justified now.
4. The corrected exact file tree.
5. Which entities and contracts belong in domain.
6. Which concrete Drift pieces belong in infrastructure.
7. Whether a repository is justified, and the one method it requires.
8. How essentials/presence relates to essentials/db.
9. Where the disposable Journey 42 seed belongs.
10. What remains owned by the experimental feature.
11. Any complexity added solely by repository conventions.
12. Confirmation that no historical Presence concept was restored merely for consistency.

Do not begin implementation.
