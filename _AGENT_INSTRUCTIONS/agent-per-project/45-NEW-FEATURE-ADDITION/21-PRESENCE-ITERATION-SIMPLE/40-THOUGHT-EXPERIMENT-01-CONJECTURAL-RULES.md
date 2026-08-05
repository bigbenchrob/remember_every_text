# THOUGHT EXPERIMENT — A CONJECTURAL SET OF ABSOLUTE RULES

> **Status**
>
> This is a thought experiment, not canonical architecture or a final proposal.
> Its rules are treated as absolute only inside this experiment so their
> consequences can be carried forward rigorously. The purpose is to expose
> contradictions, pressure points, and hidden assumptions. Terminology remains
> provisional; mechanism is the subject of the experiment.

## 1. Objective

Can a complex guided workflow be explained with a small set of actors, linear
Journeys, and upward-only signals?

The experiment deliberately excludes arbitrary jump-based branching. It asks
how far composition and early successful completion can explain onboarding
before the rule set breaks down.

## 2. Actors

### Contracting Entity

A Contracting Entity commissions a Journey to accomplish one purpose. It does
not sequence the Journey's Steps. When the Journey succeeds, the Contracting
Entity receives that result.

Possible examples include Onboarding, Archive Import, and Help.

### Journey

A Journey owns an ordered set of Steps. It progresses by advancing its current
Step position after the current Step succeeds.

A Journey is successful when either:

- it reaches the end of its ordered Steps; or
- a Step establishes that the Journey's purpose has already been achieved.

The experiment describes a Journey as **successful** or **not yet successful**.
It does not introduce a broad failure model.

### Step

A Step is simple and has one purpose. It determines when that purpose has been
achieved and reports upward. It knows nothing about sibling Steps.

Candidate Step forms in the source thought experiment are Tell, Ask, Do, and
Audit. Their inclusion here is conjectural, not an accepted implementation
plan.

### Agent

An Agent performs specialized external work for a Step, such as opening System
Settings, inspecting Full Disk Access, or locating a database. The Agent is not
part of the Journey hierarchy. It performs work on behalf of a Step and reports
its result to that Step.

## 3. Journey

The experiment permits only one kind of Journey. Specialized Journey subclasses
are excluded. Different behavior must arise from ordered Steps and composition.

Every Journey must have a one-sentence purpose. If its purpose cannot be stated
clearly in one sentence, that is evidence that the Journey may contain more than
one undertaking and should be decomposed.

## 4. Step

Each Step has one purpose and owns the simple logic needed to determine whether
that purpose has been achieved.

The ordinary path is linear:

```text
current Step succeeds
    -> Journey advances to the next Step
```

A Step may also establish that continuing is unnecessary because its parent
Journey's purpose is already achieved. This is early successful completion, not
an arbitrary jump to another Step.

## 5. Agent

Agents contain specialized external capability so Steps can remain small. A Do
or Audit Step may ask an Agent to act or observe, then interpret the result only
far enough to decide whether the Step or its parent Journey has succeeded.

An Agent does not sequence Steps, advance Journeys, or become a child in the
Journey hierarchy.

## 6. Parent-Child Relationships

The conjectural hierarchy is:

```text
Contracting Entity
    -> Journey
        -> Step
```

An Agent has a service relationship with a Step rather than a parent-child
relationship.

The central experimental hypothesis is that a Journey may implement a Step:

```text
Parent Journey
    -> Step
        -> Child Journey
```

A Journey may not be the direct child of another Journey. The parent Journey
continues to know only that it is waiting for its current Step to succeed.

## 7. Upward-Only Signals

Signals move only from a child toward its parent. No downward signal instructs
a child how to proceed.

The conjecture permits two meanings:

1. **I have succeeded.**
2. **Your purpose has already been achieved; succeed now.**

Applied to the hierarchy:

- a Step can report its own success to its parent Journey;
- a Step can establish that its parent Journey has already succeeded;
- a child Journey can report success to the Step it implements;
- a Journey can report success to its Contracting Entity.

The names of these signals remain provisional. The restriction on their
direction and meaning is what the experiment evaluates.

## 8. Linear Progression

Journeys do not branch by jumping between Step positions. Their ordinary
behavior is always:

```text
Step succeeds
    -> advance once
    -> present the next Step
```

If a workflow requires repeated arbitrary jumps, the conjecture has not earned
an exception. That requirement is evidence that the proposed universe may be
insufficient.

## 9. Early Successful Completion

A Step may discover that its parent Journey's stated purpose is already true.
In that case, the Journey succeeds without visiting its remaining Steps.

Early completion is successful because the purpose has been achieved. It is not
termination caused by a generic failure or cancellation state.

A child Journey likewise reports success to its parent Step. If the child
Journey is not yet successful, it sends no success signal and the parent Step
cannot pretend otherwise.

## 10. FDA Example

Consider a child Journey with the one-sentence purpose:

> Ensure that Full Disk Access has been granted.

The parent onboarding Journey reaches an Audit Step. That Step is implemented
by the FDA Journey.

The FDA Journey first asks an Agent whether Full Disk Access is already granted.

If the answer is **yes**:

```text
Audit result establishes FDA Journey purpose
    -> FDA Journey succeeds early
    -> child Journey reports success to parent Audit Step
    -> Audit Step reports success to onboarding Journey
    -> onboarding Journey advances linearly
```

If the answer is **no**:

```text
initial Audit Step succeeds without completing the Journey
    -> FDA Journey advances normally
    -> later Tell, Ask, or Do Steps guide the user
```

This example tests whether linear progression plus early success can replace
ordinary branching. It is not an implementation proposal.

## 11. Evaluation Criteria

The conjecture remains coherent only while:

- every Journey has one sentence of purpose;
- every Step has one purpose;
- Journeys remain linear and ignorant of specialized Step behavior;
- external complexity remains in Agents;
- parent components remain ignorant of child implementation;
- the two upward signal meanings remain sufficient;
- nested implementation through a Step is simpler than a specialized parent
  Journey or arbitrary branching.

The experiment is valuable even if it fails. Repeated exceptions, hidden
downward commands, arbitrary jumps, or increasingly elaborate signal meanings
would identify where the conjecture breaks.

## 12. Open Questions

- Can a Step implemented by a child Journey remain simpler than one more capable
  Step?
- Does an Audit genuinely require a child Journey?
- Is early successful completion sufficient to express the FDA workflow?
- Can a child Journey that is not yet successful wait truthfully without adding
  a broad failure model?
- Does revisiting the FDA check require repeating a Journey?
- If a `REPEAT JOURNEY` mechanism becomes necessary, is that an earned concept or
  evidence that the conjectural rules are failing?

`REPEAT JOURNEY` is not an accepted rule in this experiment. It is retained only
as an explicit pressure point inherited from the source material.

The governing question is:

> How far can this small universe explain onboarding before it breaks?
