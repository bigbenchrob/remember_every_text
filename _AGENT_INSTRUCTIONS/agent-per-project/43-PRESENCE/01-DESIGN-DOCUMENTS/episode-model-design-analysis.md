# Presence Episode Model Design Analysis

## Recommendation

Reduce the candidate six families to four canonical control protocols:

| Family | Governing question | Completion authority |
| --- | --- | --- |
| **Inform** | What should the user understand? | Acknowledgement or coordinator transition |
| **Ask\<T\>** | What typed answer is required? | Validated user response |
| **Work** | What operation is actively progressing? | Feature-supplied operational evidence |
| **Await** | What external condition must become true? | Independently observed condition |

`Direct` and `Resolve` are not distinct protocols:

- **Direct** is an `Await` whose purpose is `externalAction`. Clicking "Open
  System Settings" may initiate an action, but verified permission completes
  the Episode.
- **Resolve** describes why an Episode arose. Its actual protocol is either
  `Ask` for a decision or `Await` for a recoverable condition.

This makes completion mechanically truthful rather than dependent on screen
wording.

## Family Contracts

### Inform

- No feature-domain input.
- May permit a Presence-level acknowledgement such as Continue.
- Does not start operational work.
- Completes through acknowledgement or an explicit coordinator transition.
- On restart, the Journey re-derives whether the information remains current.
- Common misuse: disguising a decision as a generic Continue action.

### Ask\<T\>

- Requires one constrained, typed response.
- Returns a validated domain value such as confirmation, choice, archive name,
  or candidate selection.
- Does not itself perform work; existing work may be durably suspended.
- Completes only when a valid response is accepted.
- Durable state records the pending question and any accepted answer.
- Common misuse: generic untyped buttons or using Ask for externally
  verifiable conditions.

### Work

- Represents an operation that is genuinely active.
- Does not return a user result.
- May begin or continue feature-owned work through Journey coordination;
  rendering never starts it.
- Completes only from operational evidence supplied by the feature.
- Durable state requires operation identity, checkpoint, and the basis for any
  progress claim.
- Common misuse: invented percentages, UI-owned work, or treating elapsed time
  as progress.

### Await

- Represents quiescence while waiting for an external condition, return,
  restart, or recovery.
- May expose a supporting command such as opening System Settings, but that
  command does not complete the Episode.
- Completes only when the awaited condition is observed.
- Durable state records the condition and the Journey checkpoint to resume.
- Common misuse: trusting "I did it" when the condition can be verified, or
  using Await for active work.

## Semantic Purpose

Purpose should be a family-scoped constrained field, not an unconstrained
string or a subtype hierarchy:

- `Inform`: welcome, explanation, transition, completion
- `Ask`: confirmation, choice, input
- `Work`: indeterminate, measurable, phased
- `Await`: passive condition, external action, return or restart, recoverable
  condition

"Ambient" should not be a `Work` purpose. Meaningful excerpts are Moments
subordinate to a Work Episode. They never alter sequencing or operational
state.

Completion is appropriately an `Inform` purpose, but terminality belongs to
durable Journey state. A completion Episode cannot independently declare that
the Journey succeeded.

## Common Episode Fields

Every Episode should carry only:

- stable Episode identity;
- Journey identity;
- family-scoped semantic purpose;
- primary semantic message;
- optional supporting explanation;
- feature-supplied facts needed to present that message.

Other data should remain family-specific:

- typed result contract: `Ask`;
- progress evidence: `Work`;
- awaited condition: `Await`;
- actions: constrained by the relevant family.

Expected user responsibility should derive from the family. Resumability should
be a system invariant, not an optional Boolean. Minimum display duration is
presentation policy, not durable meaning. Accessibility announcements should
derive from semantic content and purpose unless later evidence shows that
explicit announcement priority is required.

## Renderer Boundary

Every interaction returned from the Renderer to the Coordinator carries
Provenance:

- Journey identity;
- Journey revision;
- Episode identity;
- activation occurrence;
- interaction occurrence.

Episode identity identifies the logical interaction obligation and may survive
restart. Activation occurrence identifies one grant of foreground rendering
authority and does not survive restart reconciliation. Interaction occurrence
identifies one semantic interaction and permits duplicate rejection.

A Presentation Observation such as "Readable opportunity provided" reports
only a presentation condition. It never establishes acknowledgement,
understanding, or completion and is never Journey evidence by itself.

## Scenario Evaluation

| Scenario | Episode | Feature supplies | Presence owns | Result or durable state |
| --- | --- | --- | --- | --- |
| Welcome to MessageLens | `Inform / welcome` | Introductory meaning | Calm presentation and acknowledgement | Acknowledgement; onboarding position |
| Explain Full Disk Access | `Inform / explanation` | Permission rationale | Explanation grammar | No result; Journey position |
| Open System Settings and return | `Await / externalAction` | Launch command and permission verifier | Direction and continuity | No asserted result; awaited permission |
| Relaunch and verify permission | `Await / returnOrRestart` | Permission evidence | Resumption and reevaluation | Verified condition |
| Ask the user to name an archive | `Ask / input` | Naming constraints | Input interaction | Typed archive name |
| Scan without a reliable percentage | `Work / indeterminate` | Liveness and scan evidence | Truthful indeterminate status | Operation checkpoint |
| Import with measurable progress | `Work / measurable` | Completed and total units | Progress presentation | Import checkpoint |
| Show fading meaningful excerpts | Moment within `Work` | Meaningful excerpts | Restrained transient presentation | No result or sequencing effect |
| External drive disconnected | `Await / recoverableCondition` | Drive requirement and availability probe | Recovery guidance | Observed reconnection |
| Two candidate Messages databases | `Ask / choice` | Candidates and consequences | Constrained choice | Typed candidate identity |
| Report 42,614 messages added | `Inform / completion` | Counts and historical reach | Completion presentation | Completed Journey |
| Report that nothing was added | `Inform / completion` | No-change outcome | Completion presentation | Completed Journey |

## Canonicalization Status

The questions raised by this analysis are settled in
[`10-EPISODE-MODEL.md`](../10-EPISODE-MODEL.md). In particular, the canonical
model establishes:

- policy-governed acknowledgement or automatic progression for `Inform`;
- `Await` as the condition-driven family;
- stable Episode identity separated from activation occurrence;
- constrained supporting commands that cannot masquerade as completion;
- cancellation and postponement as Journey controls.

The design outline from this analysis was realized by the canonical Episode
model rather than remaining a competing specification.

## Strongest Architectural Invariants

- The Foreground Journey has exactly one Active Episode.
- The Episode family is determined by what can truthfully complete it.
- Durable Journey state is truth; the Active Episode is its interaction
  projection.
- Features own facts, work, and domain meaning. Presence owns the interaction
  protocol.
- Renderers cannot advance Journeys or start work.
- User assertions never replace independently observable evidence.
- Moments cannot change Episode or Journey state.
- Features cannot introduce custom Episode families or custom screens without
  extending the canonical Presence model.
- Every Coordinator-bound Renderer interaction carries Provenance.
- Episode identity may survive restart, but activation authority does not.
- Application restart cannot erase the information required to re-derive the
  truthful Active Episode.
