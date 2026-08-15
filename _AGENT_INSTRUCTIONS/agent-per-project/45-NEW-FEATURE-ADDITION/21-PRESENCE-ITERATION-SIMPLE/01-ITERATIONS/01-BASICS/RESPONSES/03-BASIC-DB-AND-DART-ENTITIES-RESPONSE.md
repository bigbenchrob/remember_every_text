# Iteration 1A: Basic Database and Dart Entities

## Scope

This response plans only the persisted definition of one Journey and its three
ordered Steps.

It does not plan runtime progress, Next, the current Step, Done, presentation,
or any concept from the historical Presence design.

The prompt refers to `00-THREE-STEP-TELL-JOURNEY/`, but that path is not
present in the iteration package. This response therefore relies only on the
fresh-start rules and the complete Iteration 1 behaviour restated in the
current prompt. If the missing path was intended to add requirements, it should
be restored and checked before coding.

## Recommendation

Iteration 1A does not add these tables to an existing MessageLens database and
does not create a dedicated physical database file. Neither physical placement
choice is required by the current behaviour.

- The conversation graph is source-derived and cannot honestly own a
  laboratory Journey definition.
- The overlay database is durable production state. Iteration 1A has no reason
  to migrate it or place disposable laboratory seed data there.
- The source-scoped import ledger is owned by imported source facts and is not
  an application-definition store.

Define one self-contained Drift schema/module owned by a narrow shared Presence
essential. The Journey tables, generated mapping, and repository boundary are
logically separate from unrelated MessageLens schemas. This does not choose
whether a later physical executor uses a dedicated SQLite file or an approved
shared physical home.
The current model is already independent of the disposable three-step client:
it defines generic Journeys, ordered Steps, and loading by Journey identity.
Deleting the client would not make those concepts describe the client; it would
only leave the shared capability temporarily without a consumer.

This is not promotion based on possible future reuse. The ownership is shared
today because neither the schema nor the loading contract contains onboarding,
archive ingestion, tracer, presentation, or three-step-specific meaning. The
experimental feature is the first client of the capability, not its domain
owner.

Treat the Drift module as genuine shared application infrastructure, not as a
class that exists only to support a test. Iteration 1A supplies an in-memory
executor. A later runtime integration may supply a physical executor, but
whether that executor opens a dedicated SQLite file or another approved
physical home remains intentionally undecided. The next development
integration should consume the shared repository while the disposable client
continues to own Journey 42's fixture content and presentation.

Do not give Iteration 1A a physical filename or runtime provider. If a later
iteration chooses long-lived physical storage, its construction must pass
through MessageLens's existing central database lifecycle boundary.
`essentials/presence` owns Journey schema, domain entities, the loading
contract, and its concrete Drift implementation. `essentials/db` separately
owns admitted path authority, physical file inventory, database construction,
closure, and lifecycle. No `essentials/db` bridge is required until a physical
runtime home is actually chosen.

## Minimal Database Schema

### `journeys`

| Column | Type | Constraint | Requirement served |
| --- | --- | --- | --- |
| `id` | integer | primary key | Identifies Journey 42 for loading. |
| `name` | text | not null | Stores `Three-step Tell Journey`. |

### `steps`

| Column | Type | Constraint | Requirement served |
| --- | --- | --- | --- |
| `id` | integer | primary key | Gives each of the three Steps a stable row identity. |
| `journey_id` | integer | not null, references `journeys.id` | Associates each Step with Journey 42 and rejects orphan Steps. |
| `position` | integer | not null | Defines deterministic Step order. |
| `text` | text | not null | Stores the statement displayed by the Step. |

The pair `(journey_id, position)` must be unique. Two Steps in one Journey
cannot occupy the same ordered position.

Use explicit integer identifiers rather than auto-incrementing identifiers in
this iteration. The seed already supplies Journey and Step identities, and no
creation workflow exists.

Do not add cascade deletion. Iteration 1A has no deletion behaviour.

Do not constrain a Journey to exactly three rows in the schema. The focused
seed and load test establish the three-Step behaviour. Enforcing a fixed child
count relationally would add machinery unrelated to the current loading
requirement.

## Position Convention

Use zero-based positions:

```text
0 -> Hello one
1 -> Hello two
2 -> Hello three
```

This matches the seed supplied by the prompt and the indexing convention of
the later in-memory ordered list. No translation is required when runtime
progress is introduced.

Position should be non-negative. That constraint follows directly from the
chosen zero-based convention rather than from a hypothetical future feature.

## Minimal Dart Entities

Use two plain Dart classes.

```text
Journey
    int id
    String name
    List<Step> steps

Step
    int id
    String text
```

The `Journey.steps` list is constructed in database position order. `Step`
does not expose `position`; ordering is already represented by its location in
the loaded list.

Use ordinary constructors and final fields. Do not add Freezed, equality,
copying, serialization, inheritance, interfaces, or a `Tell` subtype. There is
only one Step kind, so `Step.text` fully represents the current requirement.

## Exact File Locations

The narrowest compliant Iteration 1A tree is:

```text
lib/essentials/presence/
├── domain/
│   ├── entities/
│   │   ├── journey.dart
│   │   └── step.dart
│   └── repositories/
│       └── journey_repository.dart
└── infrastructure/
    ├── data_sources/
    │   └── local/
    │       ├── journey_definition_store.dart
    │       └── journey_definition_store.g.dart
    └── repositories/
        └── drift_journey_repository.dart

test/essentials/presence/
├── infrastructure/
│   └── repositories/drift_journey_repository_test.dart
└── support/
    └── journey_42_seed.dart
```

The Journey 42 support fixture is test-owned in Iteration 1A. When the real
experimental client is added, its development-only integration will own the
equivalent disposable seed, conceptually under:

```text
lib/features/presence_iteration_simple/infrastructure/development/
└── journey_42_seed.dart
```

That later file is not part of the Iteration 1A coding task.

Layer ownership is deliberate:

- `domain/entities/journey.dart` and `domain/entities/step.dart` contain the
  plain shared domain entities. The repository uses `domain/entities/`, not a
  generic `model/` directory, for such concepts.
- `domain/repositories/journey_repository.dart` is the Drift-independent
  loading boundary consumed by clients. It exposes only
  `Future<Journey> loadJourney(int id)`.
- `infrastructure/data_sources/local/journey_definition_store.dart` contains
  only the Drift schema and executor-backed access machinery. The name
  describes its logical responsibility without implying a dedicated physical
  SQLite file.
- `infrastructure/repositories/drift_journey_repository.dart` performs the
  ordered queries, maps generated rows to domain entities, and implements the
  domain repository contract.
- Tests mirror the owned essentials path. The Journey 42 seed is support data,
  not shared Presence infrastructure.

The `essentials/presence` name identifies the small shared capability proven by
the current model. It does not restore the historical Presence architecture.
Only Journey definitions, Step definitions, ordered loading, and the one-method
repository boundary belong there in Iteration 1A.

The experimental feature remains responsible for:

- choosing and requesting Journey 42;
- the disposable `Hello one`, `Hello two`, and `Hello three` fixture used by
  its development integration;
- the temporary real-application presentation;
- Next, Done, and in-memory progress when later iteration prompts introduce
  them.

Those responsibilities do not move into the shared essential merely because
the client consumes shared Journey definitions.

## Drift Mapping

Use Drift because the project already uses it for app-owned relational schema,
generated SQL mapping, constraints, and in-memory database tests.

The Drift table classes `Journeys` and `Steps` would normally generate row
classes named `Journey` and `Step`, which would collide with the two minimal
Dart entities. Use Drift's data-class naming annotation to generate neutral
row names such as `JourneyRow` and `StepRow`. This is generator plumbing, not a
second entity model.

The domain repository should expose one loading method:

```text
loadJourney(42) -> Journey
```

`DriftJourneyRepository` implements that method by:

1. loading the Journey row by primary key;
2. loading its Step rows ordered by `position` ascending;
3. creating `Step` objects;
4. returning one `Journey` containing the ordered list.

A repository is justified here for one concrete reason: the disposable client
must consume Journey definitions without importing Drift, generated row types,
or the shared subsystem's local database. This is not a generic CRUD
abstraction. Do not add creation, update, deletion, search, caching, a DAO
interface, mapper hierarchy, or generic loader.

`JourneyDefinitionStore` remains an infrastructure detail. It accepts a Drift
executor and exposes the registered tables and generated query machinery needed
by `DriftJourneyRepository`; it does not become the domain-facing loading
contract. Naming it `JourneyDatabase` would be legal but needlessly suggest
that Iteration 1A has already chosen a standalone physical database.

Foreign-key enforcement must be enabled when the store opens against SQLite.
Declaring a Drift reference without enabling SQLite foreign keys would not
satisfy the orphan-rejection requirement.

## Seed Strategy

Keep Journey 42's seed outside the shared essential. `Hello one`, `Hello two`,
and `Hello three` are laboratory content owned by the experimental client, not
generic Presence definitions.

Iteration 1A keeps that content in test support and uses it to verify the
shared repository. The next real-application slice may add the same fixture to
the experimental client's development integration; it must not move the
fixture into `essentials/presence` or a production migration.

Insert:

```text
journeys
42 | Three-step Tell Journey

steps
1 | 42 | 0 | Hello one
2 | 42 | 1 | Hello two
3 | 42 | 2 | Hello three
```

Insert the Step rows out of order in the test. This proves that the loading
method, rather than insertion order, establishes the returned order.

Do not seed through a production migration. That would put laboratory data in
every user archive. Do not add a development startup hook in Iteration 1A. The
shared schema/module and repository are runtime-capable even though this first
test uses an in-memory executor; only the disposable fixture remains
test/client owned.

## Required Constraints

### Journey primary key

Required because the only requested loading operation identifies Journey 42.

### Step primary key

Required because each Step is an entity with the requested `id` field.

### Step foreign key

Required because a Step belongs to one Journey and orphan Steps must be
rejected.

### Non-negative position

Required by the chosen zero-based ordering convention.

### Unique Journey position

Required because deterministic ordering is ambiguous if two Steps in one
Journey claim the same position.

No other uniqueness, timestamp, status, or child-count constraint is required
by Iteration 1A.

## Required Tests

### Journey 42 loads in position order

Using an in-memory Drift executor:

1. seed Journey 42;
2. insert its Step rows out of order;
3. call `loadJourney(42)`;
4. assert the Journey id and name;
5. assert exactly three Steps;
6. assert Step ids and statements are returned in positions 0, 1, 2.

### Duplicate position is rejected

Insert two Step rows for Journey 42 with the same position and assert that the
database rejects the second row.

### Orphan Step is rejected

Insert a Step whose `journey_id` does not exist and assert that the database
rejects it. This also proves that foreign-key enforcement is active in the
test database.

No runtime-progress, presentation, restart, or interaction tests belong in
Iteration 1A.

## Existing Conventions That Add Necessary Plumbing

The placement decision follows concrete repository examples:

- `features/contacts`, `features/handles`, `features/messages`,
  `features/attachments`, and `features/address_book_folders` place feature
  entities under `domain/entities/`.
- `features/handles` and `features/address_book_folders` place concrete local
  source access under `infrastructure/data_sources/local/` and repositories
  under `infrastructure/repositories/`.
- `features/conversations` keeps overlay-backed concrete repositories in
  `infrastructure/repositories/`, exposes their contracts and generated
  providers through application files, and uses
  `feature_level_providers.dart` only as its external seam.
- Shared essentials such as `search` and `source_scoped_import` place
  client-independent contracts in application/domain boundaries and concrete
  implementations in infrastructure. `source_scoped_import/domain/ports`
  demonstrates that a shared essential may expose a narrow domain-facing port
  while hiding source/database machinery.
- The current tree has no feature-local `@DriftDatabase` class to copy. Its
  existing Drift schemas are app-level shared systems. That evidence supports
  keeping the generic Journey-definition database with the shared subsystem,
  not burying it inside its first disposable client.
- Presentation is a sibling feature layer, not a responsibility of domain or
  infrastructure. It is intentionally absent from Iteration 1A.
- `essentials/db` centrally owns admitted archive paths, persistent database
  construction, disposal, and physical database inventory. This convention
  will require a lifecycle bridge only if a later iteration chooses physical
  runtime storage. Schema and repository behaviour remain owned by
  `essentials/presence` regardless of that later choice.

Drift requires:

- one generated `part` file;
- generated row and companion classes;
- a schema version;
- explicit table registration;
- an executor in tests;
- foreign-key activation for SQLite enforcement.

The generated row classes are persistence plumbing and must not be promoted
into duplicate runtime entities.

If a later iteration chooses physical persistence for the real development
client, MessageLens conventions additionally require central provider
construction, admitted archive-root authority, a physical home, lifecycle
closure, database inventory, and a migration policy. The resulting dependency
direction would be:

```text
experimental client
    -> essentials/presence domain repository
    -> essentials/presence Drift repository and definition store
    <- constructed through essentials/db lifecycle authority
```

`essentials/db` may then import the concrete Presence store solely to supply and
close its physical executor, as it already does for other subsystem databases.
Presence must not duplicate path or lifecycle authority. Iteration 1A requires
none of that physical-lifecycle complexity; it requires only the one-method
repository abstraction that keeps clients independent of Drift.

## Explicitly Not Included

- Next;
- current Step;
- Done state;
- runtime progress;
- a Journey run or execution record;
- persistence across application runs;
- a physical database file;
- a database provider;
- production startup seeding;
- development startup integration and its client-owned Journey 42 seed;
- Episode, Inform, Await, Work, or any historical Presence entity;
- Step type or `Tell` subtype;
- action or completion fields;
- status, lifecycle, revision, or version;
- timestamps;
- provenance, activation, or identity wrappers;
- app-level navigation and presentation ownership;
- JSON payloads or metadata;
- repositories beyond the single `JourneyRepository.loadJourney(int id)`
  contract;
- DTO/domain pairs or mapper hierarchies;
- generic Step protocols;
- sealed unions or Freezed classes;
- deletion behaviour;
- presentation or animation;
- future Ask or Wait support.

## Smallest Recommended First Coding Task

Create only:

1. the `Journeys` and `Steps` Drift tables;
2. the executor-backed `JourneyDefinitionStore` with foreign keys enabled;
3. the plain `Journey` and `Step` Dart entities;
4. the one-method `JourneyRepository` contract;
5. `DriftJourneyRepository.loadJourney(int id)`;
6. the test-owned Journey 42 seed;
7. one focused test proving Journey 42 loads with `Hello one`, `Hello two`,
   and `Hello three` in position order.

Generate the Drift output and run that focused test, the architecture
tripwires, and the analyzer. Constraint tests may be added in the same coding
slice because they protect requirements already present in Iteration 1A; they
must not expand into runtime behaviour.
