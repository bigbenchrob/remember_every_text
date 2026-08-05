# Tell and Ask Journey-Definition Schema

## Scope

This response plans only the smallest revision that lets one persisted Journey
contain ordered Tell and Ask Steps.

It does not implement the revision. It does not decide answer ownership,
persistence, Journey completion semantics, additional Step kinds, or a general
Step framework.

The store still receives an injected in-memory executor. No physical runtime
database has been chosen, so this revision requires neither a physical
migration nor a new database-location decision.

## Recommended Schema

### `journeys`

| Column | Type | Constraint |
| --- | --- | --- |
| `id` | integer | primary key |
| `name` | text | not null |

### `steps`

| Column | Type | Constraint |
| --- | --- | --- |
| `id` | integer | primary key |
| `journey_id` | integer | not null, references `journeys.id` |
| `position` | integer | not null, non-negative |
| `type` | text | not null, one of `tell` or `ask` |

The pair `(journey_id, position)` remains unique.

### `tell_steps`

| Column | Type | Constraint |
| --- | --- | --- |
| `step_id` | integer | primary key, references `steps.id`, delete cascades |
| `text` | text | not null |

### `ask_steps`

| Column | Type | Constraint |
| --- | --- | --- |
| `step_id` | integer | primary key, references `steps.id`, delete cascades |
| `question` | text | not null |

This models shared facts once in `steps` and subtype facts only in the
corresponding subtype table. It adds no nullable payload columns to the base
table.

## Discriminator

Store `type` as text with exactly two allowed values:

```text
tell
ask
```

Text is preferable to an integer here because the database remains directly
inspectable and no hidden numeric mapping must be maintained. The schema check
constraint rejects every other value. The discriminator is infrastructure
data; the Dart domain objects do not need a type property that duplicates
their runtime subtype.

## Keys and Referential Constraints

Each subtype table uses `step_id` as both its primary key and its foreign key.
This expresses that:

- a subtype row has no identity independent of its base Step;
- one Step can have at most one Tell row;
- one Step can have at most one Ask row;
- a subtype row cannot exist without a base Step.

Deleting a base Step should cascade to its subtype row. This is not a Step
deletion feature. It is the relational consequence of the subtype row having
no independent existence.

Foreign-key enforcement remains enabled when the Drift store opens.

## Database and Repository Responsibilities

The database should prevent the constraints it can express plainly:

- orphan subtype rows;
- duplicate subtype rows of one kind;
- duplicate positions within one Journey;
- negative positions;
- unknown discriminator values;
- null subtype payloads.

Ordinary foreign keys and checks cannot simply enforce that every base row has
exactly one matching subtype row and no row in the other subtype table. Adding
triggers or duplicated subtype discriminator columns would be disproportionate
to this iteration.

The repository should therefore reject:

- a Tell base row without Tell data;
- an Ask base row without Ask data;
- a Tell base row with Ask data;
- an Ask base row with Tell data;
- a base row with both subtype rows;
- an unknown type if corrupt data somehow bypasses the database check.

A malformed definition is a load failure. A direct `StateError` identifying
the Step and violated invariant is sufficient for this experiment; no error
hierarchy is required.

## Loading Strategy

Continue loading the Journey row first. Load all of its Steps in one ordered
query that starts from `steps` and left-joins both subtype tables:

```text
steps
    LEFT JOIN tell_steps ON tell_steps.step_id = steps.id
    LEFT JOIN ask_steps ON ask_steps.step_id = steps.id
    ORDER BY steps.position ASC
```

One joined query is clearer than separate subtype queries for the two proven
types because each result exposes the complete integrity decision:

- the discriminator;
- whether Tell data exists;
- whether Ask data exists.

Each base row then maps directly to one concrete domain object after its
combination is validated. No mapper hierarchy, subtype repository, or generic
payload object is necessary.

## Domain Model

Use the minimal sealed hierarchy:

```dart
sealed class Step {
  const Step({required this.id});

  final int id;
}

final class TellStep extends Step {
  const TellStep({required super.id, required this.text});

  final String text;
}

final class AskStep extends Step {
  const AskStep({required super.id, required this.question});

  final String question;
}
```

`Journey` continues to contain `List<Step>`. `JourneyProgress` continues to
select Steps only by ordered position and should remain unchanged.

The hierarchy contains no answer, completion, validation, presentation, or
discriminator API.

## Journey 42 Fixture

Revise the disposable development fixture to persist:

```text
position 0: TellStep — "Hello one"
position 1: AskStep — "What should I call you?"
position 2: TellStep — "Hello three"
```

Each fixture Step requires one base row followed by exactly one matching
subtype row. Inserting the physical rows out of order may remain useful for
proving that repository order comes from persisted `position`.

The fixture still belongs to the experimental client, not to shared Presence
infrastructure. It stores no answer.

Because no physical runtime Journey database exists, regenerate the current
schema at schema version 1 rather than inventing a migration from disposable
in-memory state.

## Required Tests

Repository and schema tests should prove:

1. A mixed Journey loads in persisted position order.
2. A `tell` row becomes `TellStep` with its text preserved.
3. An `ask` row becomes `AskStep` with its question preserved.
4. Orphan Tell and Ask subtype rows fail their foreign keys.
5. A base row missing its expected subtype data fails to load.
6. A discriminator/subtype mismatch fails to load.
7. A base row with both subtype rows fails to load.
8. An unknown discriminator is rejected by the schema.
9. Existing duplicate-position and negative-position constraints remain.

Domain tests should prove:

10. `JourneyProgress` advances through mixed concrete Step subclasses.
11. `Journey` and `JourneyProgress` require no subtype-specific behaviour.

Presentation tests should remain Drift-independent. The existing Tell and Ask
widget tests continue to construct only their view models and approved domain
input.

## Immediate Presentation Consequence

Once the domain hierarchy exists, `JourneyView` can inspect the current
runtime subtype and select `TellStepView` for a `TellStep` or `AskStepView` for
an `AskStep`.

That direct two-case selection does not justify a generic Step-view interface,
factory, registry, or provider. The selection is not implemented by this
planning task.

## Files Likely to Change

Core schema and domain:

- `lib/essentials/presence/domain/entities/step.dart`
- `lib/essentials/presence/infrastructure/data_sources/local/journey_definition_store.dart`
- generated `journey_definition_store.g.dart`
- `lib/essentials/presence/infrastructure/repositories/drift_journey_repository.dart`

The following should remain structurally unchanged:

- `lib/essentials/presence/domain/entities/journey.dart`
- `lib/essentials/presence/domain/entities/journey_progress.dart`
- `lib/essentials/presence/domain/repositories/journey_repository.dart`

Fixture and focused tests:

- `lib/features/presence_iteration_simple/infrastructure/development/journey_42_fixture.dart`
- `test/essentials/presence/infrastructure/repositories/drift_journey_repository_test.dart`
- `test/essentials/presence/domain/entities/journey_progress_test.dart`

A subsequent coherent presentation adaptation will touch:

- `JourneyView` and its test;
- `TellStepViewModel` and its test inputs;
- `AskStepViewModel` and its test inputs.

## Explicitly Not Included

- answer ownership or persistence;
- Ask validation beyond the already proven local nonblank rule;
- Ask integration into Journey progression in this planning task;
- Wait, Action, FDA, or worker Steps;
- completion or restart state;
- providers;
- physical database placement;
- CRUD methods or subtype repositories;
- generic Step results, payloads, view contracts, factories, or registries;
- JSON, Freezed, metadata bags, or speculative schema columns.

## Smallest Recommended Coding Task

Implement the relational and domain revision as one focused slice:

1. replace the concrete `Step` entity with `Step`, `TellStep`, and `AskStep`;
2. split the Drift payload into `steps`, `tell_steps`, and `ask_steps`;
3. regenerate Drift code;
4. update the repository's joined load and integrity checks;
5. revise Journey 42's fixture;
6. update repository and mixed-progression tests.

Before ending that coding slice, make only the narrow presentation changes
required for the application to compile against the sealed hierarchy. Do not
introduce answer storage or a generalized renderer while doing so.

The resulting model keeps `Journey` blissfully ignorant: it owns one ordered
`List<Step>`, while the database and repository ensure that every item in that
list is one truthful concrete subtype.
