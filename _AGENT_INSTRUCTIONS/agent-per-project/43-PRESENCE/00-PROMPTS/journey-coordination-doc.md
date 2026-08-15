The Journey Coordination analysis has now converged.
The following documents are now considered normative:

- 43-PRESENCE/00-PRESENCE.md
- 43-PRESENCE/01-DESIGN-DOCUMENTS/presence-episode-specification.md
- 43-PRESENCE/10-EPISODE-MODEL.md
  Read those carefully.
  Also read the Journey Coordination design analysis.
  Your task is to replace the placeholder in:
  43-PRESENCE/20-JOURNEY-COORDINATION.md
  with the canonical Journey Coordination architecture.
  This is now a normative architectural document.
  Do not redesign the model.
  Do not revisit Presence philosophy.
  Do not propose implementation classes, Flutter widgets, Riverpod providers, rendering technology, or database schemas.
  The purpose of this document is to define:
  "How Journeys are coordinated."
  Nothing else.

---

## Scope

Define the canonical Journey model.
A Journey is the durable authority for one user-relevant undertaking.
The Journey owns interaction continuity.
Feature operations own operational work.
Presence derives Episodes from Journey truth.

---

## Definition

Formally define:

- Journey
- Journey identity
- Journey authority
- Relationship to Episodes
- Relationship to feature operations
- Relationship to Moments
  State clearly that:
  A Journey is durable truth.
  An Episode is the current interaction derived from that truth.

---

## Durable Journey State

Define the durable semantic information owned by a Journey.
Include concepts such as:

- stable identity
- originating user intent
- lifecycle
- current semantic position
- accepted user decisions
- references to feature-owned operations
- references to awaited conditions
- foreground ownership
- terminal outcome
  Also distinguish durable truth from transient presentation.
  State explicitly that rendered UI, animation, Moments, progress displays, and previous Episodes are never durable Journey state.

---

## Lifecycle

Define the canonical Journey lifecycle.
Include:

- Created
- Ongoing
- Completed
- Failed
- Abandoned
- Archived
  State that:
  work,
  waiting,
  questions,
  and progress
  are Episode concerns occurring within an ongoing Journey rather than lifecycle states.
  Also distinguish lifecycle from foreground ownership.

---

## Foreground Presence

Adopt the following terminology consistently:

- Ongoing Journey
- Foreground Journey
- Active Episode
- Active feature operation
  Avoid the ambiguous phrase:
  "active Journey"
  State that:
  Only one Journey owns foreground Presence.
  Only one Episode is active.
  Multiple Journeys may remain ongoing.
  Multiple feature operations may exist according to feature policy.

---

## Journey Transitions

Define:
What is a Journey transition?
Who may request one?
Who authorizes one?
What evidence is required?
What makes a transition atomic?
What happens when evidence is obsolete?
State explicitly:
External side effects are not part of the atomic transition.
Durable intent precedes externally consequential work.
Feature evidence later reconciles the result.
Coordinator transitions are authoritative.

---

## Coordinator Responsibilities

Define exactly what belongs to the Journey Coordinator.
Define exactly what never belongs there.
Include:

- Episode derivation
- transition validation
- reconciliation
- foreground ownership
- restart recovery
- replacement of obsolete Episodes
  Exclude:
- rendering
- operational work
- feature-domain decisions
- database logic
- progress invention
- business rules

---

## Foreground Arbitration

Define the canonical policy.
Background Journeys may require user attention.
They do not seize Presence.
Instead:

- attention is recorded as Journey truth
- foreground arbitration determines whether and when Presence changes ownership
  Make this a Coordinator responsibility.

---

## Operations

Clarify the operation contract.
Operations publish:

- facts
- checkpoints
- liveness
- progress basis
- dependency changes
- outcomes
  Operations never publish:
- Episodes
- semantic purposes
- copy
- rendering
- navigation
- presentation
  Operations never know which Episode is active.

---

## Command and Reconciliation

Add a dedicated section explaining:

1. Journey records durable intent.
2. Coordinator issues feature request.
3. Feature accepts or rejects.
4. Feature publishes evidence.
5. Coordinator reconciles Journey truth.
6. Presence derives the appropriate Episode.
   State explicitly that:
   requesting work
   is not
   evidence that work has begun.
   Likewise,
   issuing a command
   is not
   evidence that it succeeded.

---

## Restart Reconciliation

Describe restart as a first-class architectural concern.
Explain:

- loading durable Journeys
- obtaining feature truth
- reconciling pending commands
- reconciling operations
- reconciling awaited conditions
- deriving truthful Episodes
- restoring foreground ownership
  State that rendered UI is never consulted.

---

## Journey Controls

Define Journey-level concepts:

- cancel
- postpone
- retry
- resume
- abandon
  Clarify which require feature cooperation.
  Clarify that these are Journey controls rather than Episode-family results.

---

## Failure

Distinguish:

- recoverable interruption
- recoverable failure
- permanent failure
- dependency loss
- user abandonment
- application termination
  Determine which become Journey transitions.
  Determine which merely produce different Episodes.

---

## Architectural Invariants

Produce the strongest possible canonical invariants.
Include:

- exactly one Foreground Journey
- exactly one Active Episode
- Journeys are durable truth
- Episodes are derived
- Coordinator alone commits transitions
- transitions require declared evidence
- obsolete evidence cannot advance a Journey
- operations publish facts only
- rendered UI is never authoritative
- obsolete Episodes disappear after reconciliation
- Journey identities are never reused
  Expand where appropriate.

---

## Relationship to Other Presence Documents

Explain:
00-PRESENCE
defines why Presence exists.
Presence Episode Specification
defines what an Episode is.
10-EPISODE-MODEL
defines which interaction protocols exist.
20-JOURNEY-COORDINATION
defines how Journeys advance through truthful state.
30-RENDERING
will define how Episodes become presentation.
40-AMBIENT-MOMENTS
will define transient content.
50-FEATURE-INTEGRATION
will define how features participate.

---

## Review Checklist

Conclude with a concise review checklist.
Reviewers should ask:

- Is this Journey truth or feature truth?
- Who owns this responsibility?
- What evidence authorizes this transition?
- Could this Journey be reconstructed after restart?
- Is the Coordinator deriving Episodes rather than receiving them?
- Is foreground ownership unambiguous?
- Is rendering completely replaceable?

---

## Output

Modify only:
43-PRESENCE/20-JOURNEY-COORDINATION.md
Do not modify any other canonical Presence document unless a cross-reference is required.
After completion:

1. Summarize any architectural refinements introduced.
2. Identify any assumptions that remain.
3. Explain whether any changes should later be reflected in the Episode Model.

I have one suggestion that isn’t part of the prompt.

I think 20-JOURNEY-COORDINATION.md is where the Presence architecture becomes complete. After that, I would stop and let it sit for a day before writing 30-RENDERING.md. Rendering is now intentionally downstream of everything you’ve established. If you sleep on the Journey document and still find it coherent the next morning, you’ll know the architectural core is solid before you concern yourself with how any of it looks on screen.
