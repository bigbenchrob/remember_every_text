Absolutely. This should be the first implementation slice in Feature 25, and it should stay deliberately **side-effect-free**: define “the guidebook MessageLens ships” as a deterministic catalog object, validate it, and express the current production guidebook through that object — but do not yet install it into a database or alter runtime behavior.

The audit explicitly recommends this as the first slice because current production composition still has Onboarding constructing the full Schedule graph while also supplying runtime Agents. 01\-PRESENCE\-GUIDEBOOK\-LIFECYCLE\-ARCHITECTURE\-AUDIT.md

### Prompt for Codex — 02 Presence Guidebook Catalog Contract and Validator

Implement the first bounded slice of Feature Addition 25:

```text
25-PRESENCE-GUIDEBOOK-LIFECYCLE/
```

Create:

```text
02-PRESENCE-GUIDEBOOK-CATALOG-CONTRACT-IMPLEMENTATION.md
```

**This prompt is authorization to implement. Do not stop to ask for plan confirmation.**

Read first:

- `25-PRESENCE-GUIDEBOOK-LIFECYCLE/00-START-HERE.md`
- `25-PRESENCE-GUIDEBOOK-LIFECYCLE/01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md`
- Feature 23 handoff:
  `23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md`
- current production required-sources Onboarding Schedule builder
- current Presence Schedule/Trip/Step domain models
- current repository definition validation
- current TestAgent/Choice/FixedDestination/Tell definitions
- current production Agent resolver/composition
- current tests for required-sources Schedule topology

Use current code as source of truth.

Do not implement generation replacement yet.

Do not change `presence.db`.

Do not remove runtime reconciliation yet.

---

# 1. Goal

Introduce a deterministic, side-effect-free **Presence guidebook catalog contract** representing the complete guidebook content shipped by the current MessageLens build.

Conceptually:

```text
PresenceGuidebookCatalog
    Schedules
        Trips
            Steps
            occurrences
            routing/configuration
```

The catalog must describe guidebook geometry/content only.

It must not:

- open databases;
- mutate databases;
- resolve Agents;
- execute Steps;
- start a Scheduler;
- inspect runtime state;
- know archive paths;
- know Gate state;
- know Onboarding UI state.

The purpose is to separate:

```text
WHAT GUIDEBOOK THIS BUILD SHIPS
```

from:

```text
HOW THE GUIDEBOOK IS INSTALLED
HOW IT IS EXECUTED
WHICH DOMAIN AGENTS IMPLEMENT ITS CAPABILITIES
```

---

# 2. Preserve the settled runtime target

Feature 25 establishes that after installation:

```text
presence.db
    = sole runtime authority
```

and the shipped guidebook source is installation input, not a competing runtime definition. 00\-START\-HERE.md

This slice does **not** achieve that runtime transition yet.

Instead, it creates the clean authoring/install-input boundary that later lifecycle work will consume.

---

# 3. Catalog must be pure data

Create the smallest immutable contract that can represent the current production guidebook deterministically.

It must be possible to construct the catalog without:

```text
ProviderContainer
Ref
PresenceDatabase
PresenceRepository
PresenceScheduler
TestAgentResolver
OnboardingGate
filesystem access
archive admission
```

A unit test should be able to obtain the complete current catalog as ordinary in-memory data.

Prefer existing domain types where they are already pure and appropriate.

Do not duplicate the entire Presence object model merely to rename it “catalog.”

If current domain definitions already represent immutable Schedule/Trip/Step definitions cleanly, compose them.

---

# 4. Keep executable capability separate

The catalog may contain opaque capability identifiers such as:

```text
onboarding.messages-source-readable
onboarding.messages-source-access-denied
onboarding.contacts-source-readable
onboarding.messages-source-history-sufficient
```

It must not contain the executable Agent implementations.

Desired separation:

```text
CATALOG

TestStep
    agentId = "onboarding.messages-source-readable"
```

versus:

```text
RUNTIME COMPOSITION

TestAgentResolver
    "onboarding.messages-source-readable"
        -> concrete Onboarding Agent
```

This is essential to the blank-stare boundary.

---

# 5. Onboarding must stop owning sticks and balls at the authoring boundary

Today production Onboarding constructs Schedule 6 and knows its Schedule, Trip, Step, occurrence, text, and route identities. The architecture audit explicitly identifies that as transitional leakage. 01\-PRESENCE\-GUIDEBOOK\-LIFECYCLE\-ARCHITECTURE\-AUDIT.md

For this slice, move the **authored guidebook geometry/content** out of Onboarding runtime composition into a generic Presence guidebook/catalog boundary.

Afterward, Onboarding runtime should still own things such as:

```text
Agent implementations
Agent resolver bindings
FDA-settings opening authority
other domain-specific capabilities
```

but should no longer be the natural owner of:

```text
Schedule 6
Trip 303
Step 6302
Tell text
occurrence positions
Choice destinations
routing graph
```

Do not force every existing file boundary to become perfect in this slice if a broader runtime change would be required.

But the source of the authored graph should clearly move toward Presence guidebook installation ownership.

---

# 6. Do not choose serialization yet

Do not introduce:

```text
JSON
YAML
SQL seed files
binary assets
code generation
resource bundles
```

unless such a format already exists and is mechanically unavoidable.

For now, a deterministic Dart data structure is acceptable.

The architecture audit deliberately leaves authoring/serialization format open. 01\-PRESENCE\-GUIDEBOOK\-LIFECYCLE\-ARCHITECTURE\-AUDIT.md

This slice establishes the **contract**, not the storage syntax.

---

# 7. Catalog contents

The contract must be sufficient to represent all currently shipped production Presence guidebook content, including:

```text
Schedule identity/name

Trip identity/name

Schedule -> Trip occurrence order

Step identity/name/type

Trip -> Step occurrence order

TellStep text

TestStep
    opaque TestAgentId
    true destination
    false destination

FixedDestinationStep
    destination Trip

ChoiceStep
    ordered Choice options
        opaque value
        label
        destination Trip

Open FDA Settings Step
    subtype/configuration required by current production guidebook
```

Include only currently earned Step types.

Do not create speculative extensibility abstractions.

---

# 8. Determinism

Calling the current-guidebook factory twice must yield the same catalog.

At minimum validate determinism of:

- Schedule IDs;
- Trip IDs;
- Step IDs;
- occurrence positions;
- Step subtype configuration;
- Tell text;
- Agent IDs;
- Choice values/labels/order;
- route destinations.

Do not rely on:

- map iteration order unless explicitly deterministic;
- generated random IDs;
- database autoincrement;
- clock/time;
- runtime provider state.

---

# 9. Create a catalog validator

Implement a pure validator for the catalog.

It must perform no database I/O.

Use existing Presence/domain validation where sensible, but ensure the complete catalog can be validated before installation.

At minimum validate:

### Identity

- unique Schedule IDs;
- unique Trip IDs where required by the model;
- unique Step IDs where required;
- non-empty names according to current rules.

### Schedule composition

- every Schedule has at least one Trip occurrence;
- occurrence positions are valid and unique;
- a canonical Trip appears no more than once in the same Schedule if that remains a current invariant.

### Trip composition

- every Trip has at least one Step occurrence;
- Step occurrence positions are valid and unique.

### Step subtype

Each Step definition has exactly one valid concrete subtype.

No impossible combination such as:

```text
TellStep + ChoiceStep payloads
```

for one canonical identity.

### Routing

Every configured Trip destination:

- exists;
- belongs to the correct Schedule;
- is unambiguous.

### TestStep

- Agent ID is non-empty/valid;
- destinations satisfy current generic TestStep rules.

Do **not** require executable resolution of the Agent here unless the architecture cleanly distinguishes a separate runtime-capability validation pass.

### ChoiceStep

- at least two options;
- unique values within the Step;
- deterministic positions;
- valid destination Trips;
- labels may remain non-unique if that is the current rule.

Preserve all settled Choice semantics.

---

# 10. Separate structural validation from runtime capability validation

The guidebook catalog validator should answer:

> “Is this a coherent guidebook?”

It should not necessarily answer:

> “Can this running application resolve every Agent right now?”

If current architecture supports a clean second check:

```text
catalog structural validation
        ↓
runtime capability resolution validation
```

preserve that distinction.

Do not inject Agent implementations into the catalog merely to make validation convenient.

---

# 11. Express the current production guidebook through the catalog

Move or adapt the current required-sources production guidebook definition so that one pure entry point produces the catalog.

Conceptually:

```dart
PresenceGuidebookCatalog currentPresenceGuidebookCatalog()
```

or equivalent.

Do not use that exact API name if current project naming suggests a better one.

The important property is:

```text
no Ref
no repository
no database
no Agent implementation
```

The current production guidebook should be expressible from this boundary.

---

# 12. Preserve current IDs and topology for now

Do not use this slice to redesign or renumber the current guidebook.

Preserve current production:

- Schedule IDs;
- Trip IDs;
- Step IDs;
- occurrence IDs/positions;
- routes;
- Choice values;
- Agent IDs.

Step 6302 may still conflict with the existing development `presence.db` under the current runtime reconciliation model.

That is expected.

Do **not** tactically fix Step 6302 here.

This slice does not yet change installation/replacement behavior.

---

# 13. Preserve current production behavior

Runtime should behave exactly as before in this slice.

If the current production scheduler provider currently does:

```text
build authored Schedule
-> installOrExtendDefinition()
-> create Scheduler
```

it may temporarily become:

```text
obtain current catalog Schedule
-> installOrExtendDefinition()
-> create Scheduler
```

That is acceptable as an interim bridge.

Do not remove `installOrExtendDefinition()` yet.

Do not replace the database yet.

Do not change scheduler semantics.

Do not change completion semantics.

---

# 14. Preserve the Step-6302 failure as known transitional evidence

Do not weaken validation so the current development DB suddenly accepts changed Tell text.

The architecture audit concluded:

> the immutability guard was truthful; the lifecycle premise was incomplete. 01\-PRESENCE\-GUIDEBOOK\-LIFECYCLE\-ARCHITECTURE\-AUDIT.md

Therefore:

```text
same current old presence.db
+ current changed Step 6302
```

may still fail until generation replacement is implemented.

That is acceptable for this slice.

Document it explicitly.

---

# 15. Keep Onboarding Agents intact

Do not change the recently corrected source-readiness behavior:

```text
readable
accessDenied
unavailable
```

Do not change:

- EPERM/EACCES classification;
- FDA routing;
- source-unavailable routing;
- history sufficiency;
- sparse-history Choice;
- Import Anyway;
- Contacts readiness.

Only separate **guidebook geometry authoring** from **runtime specialist capability composition**.

---

# 16. Accepted-readiness seam remains transitional

The architecture audit also notes that Onboarding currently asks Presence about completion of numeric Schedule ID 6. 01\-PRESENCE\-GUIDEBOOK\-LIFECYCLE\-ARCHITECTURE\-AUDIT.md

Do not solve that in this slice unless a tiny mechanically necessary abstraction falls naturally out of the catalog contract.

Do not broaden scope into semantic outcome APIs.

Record it as a remaining blank-stare leak for a later slice.

---

# 17. Catalog location/ownership

Place the new catalog contract where it is clearly owned by generic Presence guidebook/lifecycle concerns, not by Onboarding.

Potential conceptual placement:

```text
lib/essentials/presence/...
```

or the existing Presence domain/application boundary that best matches current architecture.

Do not create a new top-level feature solely for the catalog.

Onboarding may temporarily import a current catalog accessor during the transition if needed, but the ownership direction must be clear:

```text
Presence guidebook content
    should not be owned by Onboarding runtime
```

---

# 18. Avoid premature installer abstractions

Do not add:

```text
PresenceGuidebookInstaller
PresenceGuidebookGeneration
PresenceReplacementService
PresenceDatabasePromoter
PresenceCatalogSerializer
```

unless a tiny interface is strictly required for the pure catalog boundary.

Those belong to later slices.

This slice should be almost boring:

```text
data
validator
current catalog
tests
```

---

# 19. Tests — pure catalog

Add focused tests proving:

### Current catalog builds without runtime infrastructure

No ProviderContainer, DB, Agent resolver, or archive required.

### Determinism

Two constructions compare equal / serialize to equivalent deterministic test representation.

### Current topology

Prove expected current production:

- Schedule exists;
- expected Trips exist;
- expected source-readiness TestSteps exist;
- sparse-history Choice exists;
- expected Tell text is present;
- expected routes are preserved.

Do not duplicate every topology test already present if those tests can consume the catalog instead.

Prefer migrating existing authored-Schedule tests toward the new source.

---

# 20. Tests — validator rejection cases

Add focused negative tests for at least:

```text
duplicate Schedule ID
duplicate occurrence position
missing destination Trip
invalid Step subtype composition
Trip with no Steps
Schedule with no Trips
ChoiceStep with < 2 options
duplicate ChoiceValue
invalid Choice destination
```

Use the smallest meaningful set consistent with current domain invariants.

Do not create a combinatorial validator test explosion.

---

# 21. Tests — opaque Agent boundary

Prove the catalog can contain:

```text
TestAgentId("onboarding.messages-source-readable")
```

without needing the actual Agent implementation.

Then separately preserve existing runtime tests proving the resolver can supply that implementation.

The catalog owns the opaque declaration.

The runtime composition owns executable capability.

---

# 22. Tests — production behavior unchanged

Run existing tests proving:

- source readiness;
- FDA routing;
- non-FDA unavailable routing;
- Contacts readiness;
- sparse-history flow;
- Re-check;
- Import Anyway;
- accepted readiness;
- scheduler initialization;
- production host composition.

The extraction must not change behavior.

---

# 23. Documentation

Create:

```text
25-PRESENCE-GUIDEBOOK-LIFECYCLE/
02-PRESENCE-GUIDEBOOK-CATALOG-CONTRACT-IMPLEMENTATION.md
```

Record:

1. final catalog contract;
2. why it is side-effect-free;
3. where it is owned;
4. which current guidebook content it represents;
5. validator responsibilities;
6. structural-vs-runtime-capability validation distinction;
7. deterministic-construction evidence;
8. how Onboarding geometry ownership changed;
9. which Onboarding runtime responsibilities remain;
10. current transitional use of `installOrExtendDefinition`;
11. Step-6302 blocker explicitly still unresolved pending lifecycle replacement;
12. accepted-readiness Schedule-ID leak still deferred;
13. no serialization choice made;
14. no generation marker added;
15. no database behavior changed;
16. tests;
17. deviations from Audit 01.

Update:

- `25-PRESENCE-GUIDEBOOK-LIFECYCLE/00-START-HERE.md`
- package index if present;
- Feature Addition `INDEX.md` if needed;
- `DOCUMENTATION_PASS_LOG.md`.

---

# 24. Verification

Run:

- new catalog tests;
- catalog-validator tests;
- existing Presence domain/repository tests relevant to definitions;
- required-sources Schedule tests;
- current Onboarding Agent tests;
- production composition tests;
- complete Onboarding suite;
- architecture tripwires;
- full suite if practical;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against the current development `presence.db` expecting Step 6302 to be fixed.

Do not delete or rewrite any database.

---

# Hard constraints

Do not:

- add guidebook generation metadata;
- add database replacement;
- delete `presence.db`;
- alter Drift schema;
- remove runtime reconciliation;
- weaken definition immutability;
- tactically fix Step 6302;
- choose JSON/YAML/SQL serialization;
- add migration chains;
- move run/trace state to Overlay;
- add Overlay fields;
- change Presence grammar;
- change Agent behavior;
- change source-readiness semantics;
- change ChoiceStep semantics;
- change Gate/harness routing;
- touch attachment archival.

If extracting the authored guidebook cleanly requires changing runtime semantics, stop and report the exact coupling instead of broadening the slice.

# Success criterion

At the end of this slice, MessageLens should have one clean answer to:

> **What guidebook does this build ship?**

Something conceptually like:

```text
currentPresenceGuidebookCatalog()
        |
        v
pure deterministic guidebook graph
        |
        +-- validate without DB
        |
        +-- later installer can consume it
        |
        +-- current runtime may temporarily bridge through
            existing installOrExtendDefinition
```

And Onboarding should be materially closer to:

```text
Onboarding
    supplies domain Agents/actions
```

rather than:

```text
Onboarding
    authors Schedule/Trip/Step geometry
```

No guidebook lifecycle behavior changes yet. The purpose of this slice is simply to **separate the book from the people who answer the questions inside it**.