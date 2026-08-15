Refactor the first nested-Journey experiment to remove the permanent Step-to-Journey definition coupling.

The experiment proved that a Step may be completed by running a child Journey.

It did not prove that a Journey should be stored as a field on a Step.

The current representation:

EnsureFullDiskAccessStep.childJourney

is rejected.

It makes the Step permanently own one specific Journey, prevents clean reuse/configuration, and creates a typed Step/Journey dependency cycle.

Fix this now before continuing the FDA experiment.

---

## Controlling boundary

Steps and Journeys are independent, reusable definitions.

Neither definition may permanently contain the other.

Composition occurs when a concrete workflow is assembled or executed.

The desired relationship is:

independent Step definition
independent Journey definition
composition/runtime layer connects them

Do not preserve childJourney as a Step field under another name.

---

## Goal

Retain the proven runtime behaviour:

- the parent Onboarding Journey reaches an FDA-related Step;
- that Step is fulfilled by running the independent
  ensure_fda_has_been_granted Journey;
- child success completes the enclosing Step;
- the parent Journey then advances;
- when the child remains incomplete, the parent remains on the enclosing Step.

But remove:

- Step -> Journey domain-object ownership;
- Journey -> Step type dependency cycles caused by nested definitions;
- permanent one-to-one coupling between one Step definition and one child Journey.

---

## Planning first

Before editing code, inspect the implementation and propose the smallest composition mechanism.

Evaluate only concrete options that satisfy the current experiment, such as:

1. A composition object created by the experimental host that pairs:
   - one parent Step occurrence;
   - one child Journey definition.

2. A child-Journey key on the Step, resolved outside the domain entity.

3. A JourneyView/composition callback that supplies the child Journey when the
   relevant Step is presented.

4. Another smaller mechanism evident from the current code.

Do not choose based on hypothetical future frameworks.

Choose based on:

- no Step/ Journey definition cycle;
- independent reuse;
- human comprehensibility;
- no provider or registry unless required;
- no persistence changes;
- minimum code for the two existing true/false scenarios.

Report the proposed representation before broadening implementation.

---

## Hard invariants

- Step.dart must not import Journey.
- Journey.dart must not import specialized Step implementations beyond the
  existing base Step relationship.
- No Step field may have type Journey.
- No Journey field may encode its parent Step.
- The fake agent remains independent.
- The child Journey remains linear.
- The parent Journey still sees only completion of its current Step.
- No arbitrary Step jumps.
- No downward signal framework.
- No nested-Journey persistence yet.

---

## Preferred conceptual shape

The final runtime should read conceptually like:

parent Journey
presents composite-capable Step occurrence

composition layer
supplies independent child Journey

child JourneyView
owns child JourneyProgress

child succeeds
-> composition layer reports enclosing Step completion

The parent Step definition should know no more than is strictly required to
identify its role in the composition.

If no identifier is currently required, do not add one.

---

## Scope discipline

Do not add:

- generic Journey registry;
- provider infrastructure;
- dependency-injection framework;
- Drift columns for child journeys;
- child_journey_id;
- parent_step_id;
- recursive persistence;
- repeat/resume;
- real FDA checking;
- System Settings;
- new routing semantics;
- general composite Step framework beyond what this refactor requires.

Do not redesign Tell, Ask, JourneyProgress, or existing database loading.

---

## Tests

Preserve and adapt the existing nested-Journey tests.

Prove:

1. Step.dart has no Journey import.
2. No Step stores a Journey object.
3. The child Journey definition can exist independently.
4. The same child Journey definition can be supplied to more than one enclosing
   Step occurrence or test composition without modification.
5. The true path still propagates child success to parent advancement.
6. The false path still leaves the parent on the enclosing Step while the child
   remains active.
7. The parent Journey never inspects FDA or agent output.
8. The fake agent remains Journey/Step/Flutter-independent.
9. No persistence or provider was introduced.

---

## Documentation

Update 30-SYSTEM-BOUNDARIES.md only after the refactor proves the new boundary.

Record:

- Steps and Journeys are independent definitions.
- Nested execution is a composition relationship, not definition ownership.
- A Step may be fulfilled by a child Journey without containing that Journey.
- Composition belongs outside both definitions.

Do not present the specific experimental composition mechanism as permanent
architecture unless the implementation clearly earns that claim.

---

## Completion report

Report:

1. The rejected coupling removed.
2. The new composition mechanism.
3. Which object now supplies the child Journey.
4. Which object owns child JourneyProgress.
5. How success propagates.
6. Whether any Step/Journey import cycle remains.
7. Whether the child Journey is independently reusable.
8. Every file changed.
9. Test and analyzer results.
10. Whether the revised representation should be retained or subjected to one
    more experiment.

Do not continue the FDA workflow in this task.
