# Presence Episode Model

## Status

This document is the canonical definition of the Episode protocols permitted
by Presence.

The four canonical Episode families are:

- `Inform`;
- `Ask<T>`;
- `Work`;
- `Await`.

They are project-wide architectural protocols. Features may use them, but may
not redefine them or introduce additional Episode families.

## Classification Rule

An Episode family is determined by the authority capable of truthfully
completing the interaction.

Episodes are not classified by:

- appearance;
- controls;
- button labels;
- visual layout;
- feature ownership;
- narrative tone.

Two Episodes that look similar may belong to different families if different
authorities complete them. Two Episodes that look different may belong to the
same family if their completion protocol is the same.

The family answers:

> Who or what can truthfully establish that this interaction is complete?

## Protocol Comparison

| Family | Governing question | Completion authority | User response | Operational activity | Restart behaviour |
| --- | --- | --- | --- | --- | --- |
| `Inform` | What should the user understand? | Acknowledgement or a Coordinator transition justified by Journey state | No domain response; acknowledgement may be permitted | Does not perform or evidence operational work | Re-derived while its informational obligation remains current |
| `Ask<T>` | What typed answer is required? | A valid user-authored response accepted through the Journey contract | Required typed response | Does not perform work; related work may remain durably suspended | Re-derived with the same pending question until a response is durably accepted |
| `Work` | What operation is actively progressing? | Feature-supplied operational evidence | No intrinsic response | Feature-owned work is active | Reconciled with durable operation state and current operational evidence |
| `Await` | What external condition must become true? | Independently observed condition | No authoritative response; supporting action may be permitted | No active progress is implied; verification may recur | Awaited condition is re-evaluated before the Episode is re-presented |

## Shared Renderer Boundary

The Renderer presents the Active Episode but cannot complete it or advance its
Journey.

Every interaction returned to the Coordinator carries Provenance:

- Journey identity;
- Journey revision;
- Episode identity;
- activation occurrence;
- interaction occurrence.

Episode identity identifies the logical interaction obligation and may survive
restart. Activation occurrence identifies one grant of foreground rendering
authority and never survives restart reconciliation. Interaction occurrence
identifies one semantic interaction and permits duplicate rejection.

The Coordinator accepts an interaction only when its Provenance remains
current and the interaction is declared by the Active Episode.

A Renderer may also report a declared Presentation Observation, such as:

> Readable opportunity provided.

This reports only a presentation condition. It never establishes
acknowledgement, understanding, or Episode completion and is never Journey
evidence by itself.

## Inform

### Purpose

`Inform` communicates something the user should presently understand.

It is appropriate when the interaction requires no feature-domain answer and
does not depend on operational progress or an external condition becoming
true.

### Governing Question

> What should the user understand?

### Completion Authority

An `Inform` Episode completes through one of two declared protocols:

- the user acknowledges the information; or
- the Coordinator determines from Journey state that the informational
  transition has been discharged.

Acknowledgement means that the user chose to continue. It does not prove that
the user understood the content.

For a completion-purpose `Inform`, Journey success or completion must already
be authoritative in durable Journey state. Displaying or acknowledging the
Episode does not cause the underlying Journey to succeed.

### Permitted User Interaction

The user may:

- acknowledge the information;
- continue when continuation carries no domain decision.

The user does not return a feature-domain value.

### Permitted Feature Interaction

The feature may supply:

- truthful domain facts;
- the meaning that should be communicated;
- any outcome already established by feature or Journey state.

The feature may not use `Inform` to obtain consent, a choice, or input.

### Permitted Coordinator Behaviour

The Coordinator may:

- derive the Episode while its informational obligation is current;
- accept an acknowledgement;
- advance when the declared informational completion policy is satisfied;
- preserve terminal Journey truth while presenting a completion summary.

### Permitted Renderer Behaviour

The Renderer may:

- present the supplied meaning and facts;
- offer acknowledgement or non-semantic continuation when declared;
- return the acknowledgement interaction with current Provenance;
- report the Presentation Observation "Readable opportunity provided" when
  automatic progression is already authorized.

The Renderer may not infer acknowledgement, declare Journey completion, or
turn a continuation control into a hidden domain choice.

### Durable State Requirements

Durable Journey state must identify:

- the current Journey position;
- whether acknowledgement is required;
- whether any required acknowledgement has been durably accepted;
- any outcome facts that justify a completion-purpose Episode.

### Restart and Resumption

After restart:

- an unacknowledged or otherwise current `Inform` is re-derived;
- an already discharged `Inform` is not shown merely because it was previously
  rendered;
- a completion summary reflects existing terminal Journey truth.

### Semantic Purposes

The constrained `Inform` purposes are:

- `welcome`;
- `explanation`;
- `transition`;
- `completion`.

These are purposes within `Inform`. They are not Episode families.

### Common Misuse

- disguising confirmation or consent as Continue;
- presenting operational progress as static information;
- treating a completion screen as the authority that completes a Journey;
- using `Inform` as a generic screen for behaviour that has another completion
  authority.

### Examples

- welcoming the user to MessageLens;
- explaining why Full Disk Access is needed;
- communicating a transition between Journey phases;
- reporting a completed import whose outcome is already durable.

## Ask\<T\>

### Purpose

`Ask<T>` obtains one constrained, typed answer whose meaning is inherently
user-authored.

It is appropriate when the Journey cannot truthfully continue until the user
provides a confirmation, choice, or value.

### Governing Question

> What typed answer is required?

### Completion Authority

A valid user response, accepted through the Journey contract, completes an
`Ask<T>` Episode.

The response is authoritative only for matters the user genuinely decides or
supplies. A user assertion must not replace an independently observable
condition.

### Permitted User Interaction

The user may provide exactly the response permitted by the Episode contract.

The response must have constrained meaning. Generic button events and
uninterpreted maps of values are not canonical `Ask<T>` results.

### Permitted Feature Interaction

The feature may supply:

- the domain question;
- valid choices or input constraints;
- the meaning and consequences of the available response;
- feature-owned validation facts.

The feature may not perform the choice on the user's behalf or redefine the
response protocol through a custom interaction.

### Permitted Coordinator Behaviour

The Coordinator may:

- derive the pending question from Journey state;
- receive the candidate typed response;
- validate it against the declared contract and current feature facts;
- durably accept the response;
- transition the Journey only after acceptance.

### Permitted Renderer Behaviour

The Renderer may:

- present the question and permitted response form;
- collect a candidate response;
- return that candidate response with current Provenance;
- present validation feedback supplied through the contract.

The Renderer may not validate business meaning independently, persist the
answer as Journey truth, or advance the Journey.

### Durable State Requirements

Durable Journey state must identify:

- the pending question;
- the constraints required to reconstruct it;
- the accepted typed response once the Journey commits it;
- the suspended Journey position to resume.

Unsubmitted draft persistence is not guaranteed by the `Ask<T>` family. If
required, it must be established by the Journey's durable contract.

### Restart and Resumption

After restart:

- a still-pending question is re-derived;
- an uncommitted candidate response is not treated as accepted truth;
- a durably accepted response advances to the Episode implied by the new
  Journey state.

### Semantic Purposes

The constrained `Ask<T>` purposes are:

- `confirmation`;
- `choice`;
- `input`.

These are purposes within `Ask<T>`. They are not Episode families.

### Common Misuse

- using untyped actions as domain results;
- asking the user to confirm a condition the application can observe;
- embedding several unrelated decisions in one Episode;
- allowing rendering to validate or commit business meaning;
- using `Ask<T>` as a form-building escape hatch.

### Examples

- asking the user to name an archive;
- asking which of two candidate Messages databases is intended;
- requesting explicit confirmation for a genuinely user-owned decision.

## Work

### Purpose

`Work` communicates the truthful state of feature-owned work that is actively
progressing.

Presence represents the operation. It does not perform it.

### Governing Question

> What operation is actively progressing?

### Completion Authority

Feature-supplied operational evidence completes a `Work` Episode.

Completion cannot be inferred from:

- elapsed time;
- animation;
- a displayed percentage;
- renderer lifecycle;
- user patience;
- the absence of a reported error.

### Permitted User Interaction

`Work` requires no intrinsic user response.

Pause, cancellation, postponement, or other Journey controls are not `Work`
completion results. If permitted, their semantics belong to Journey
coordination.

### Permitted Feature Interaction

The feature operation may publish:

- liveness;
- current phase;
- measurable progress when a truthful denominator exists;
- checkpoints;
- completion evidence;
- interruption or failure facts.

The feature must not publish invented precision or presentation instructions as
operational truth.

### Permitted Coordinator Behaviour

The Coordinator may:

- derive `Work` while feature evidence says work is active;
- select the purpose that truthfully describes available evidence;
- preserve Journey continuity across checkpoints and interruptions;
- transition only when operational evidence establishes a new Journey state.

The Coordinator does not perform the work.

### Permitted Renderer Behaviour

The Renderer may:

- present current operational facts;
- communicate indeterminate activity truthfully;
- present measurable progress when supplied;
- present phases without inventing additional ones.

The Renderer may not start, stop, complete, estimate, or repair the operation.

### Durable State Requirements

Durable state must preserve enough truth to distinguish:

- the operation being performed;
- its current phase or checkpoint;
- whether it is active, interrupted, failed, or complete;
- the evidence basis for any measurable progress;
- the Journey position that follows reconciliation.

### Restart and Resumption

After restart, the Coordinator reconciles durable operation state with current
feature evidence.

It then:

- re-derives `Work` if the operation remains active or validly resumes;
- derives an appropriate `Await` or `Ask<T>` if progress now depends on an
  external condition or user decision;
- derives a later Episode if completion is already authoritative.

Previously rendered progress is never used as evidence.

### Semantic Purposes

The constrained `Work` purposes are:

- `indeterminate`;
- `measurable`;
- `phased`.

These are purposes within `Work`. They are not Episode families.

### Common Misuse

- inventing a percentage where no truthful denominator exists;
- treating a long duration as evidence of progress;
- starting work from the Renderer;
- using a visual animation as liveness evidence;
- classifying blocked or suspended work as active `Work`;
- making transient Moments responsible for progress or completion.

### Examples

- scanning an archive when no reliable percentage exists;
- importing messages with a truthful completed-unit and total-unit measure;
- reporting a multi-phase archive operation from feature-supplied phase facts.

## Await

### Purpose

`Await` communicates that the Journey cannot presently advance until an
external condition becomes true.

It is quiescent rather than actively progressing, even when Presence may
periodically receive new evidence about the condition.

### Governing Question

> What external condition must become true?

### Completion Authority

Independent observation of the awaited condition completes an `Await` Episode.

A user may perform an action that helps satisfy the condition, but performing
or reporting that action is not completion when the resulting condition can be
verified.

### Permitted User Interaction

The user may:

- invoke a supporting external action;
- leave the application;
- return later;
- restart the application;
- satisfy the condition outside MessageLens.

These interactions do not themselves establish completion.

If the Journey instead requires a user-authored decision, the correct family
is `Ask<T>`.

### Permitted Feature Interaction

The feature may supply:

- the condition that must become true;
- truthful observations of that condition;
- domain guidance about how the condition may be satisfied;
- any safe supporting action available to the user.

The feature may not treat a click or user assertion as proof when the condition
is independently observable.

### Permitted Coordinator Behaviour

The Coordinator may:

- derive `Await` while the condition remains unsatisfied;
- route a declared supporting action without treating it as completion;
- re-evaluate the condition when new evidence becomes available;
- advance only after observation establishes that the condition is satisfied;
- preserve the Journey checkpoint that will resume.

### Permitted Renderer Behaviour

The Renderer may:

- explain what is awaited;
- communicate what the user may do;
- expose a declared supporting action;
- reassure the user that leaving and returning are permitted;
- present updated condition facts supplied through the Episode.

The Renderer may not declare the condition satisfied or treat a supporting
action as completion.

### Durable State Requirements

Durable state must identify:

- the awaited condition;
- the Journey checkpoint that depends on it;
- any context required to re-evaluate it;
- the intended continuation after it becomes true.

The observed condition itself must be refreshed from its truthful authority
when appropriate.

### Restart and Resumption

After restart, the Coordinator first re-evaluates the awaited condition.

- If it remains false, the `Await` Episode is re-derived.
- If it is true, the Journey advances without requiring the user to repeat the
  supporting action or claim completion.
- If a new decision is required, the Coordinator derives `Ask<T>` from the new
  Journey state.

### Semantic Purposes

The constrained `Await` purposes are:

- `externalAction`;
- `recoverableCondition`;
- `returnOrRestart`;
- `passiveCondition`.

These are purposes within `Await`. They are not Episode families.

### Common Misuse

- treating "I did it" as evidence of an observable condition;
- using `Await` while work is actively progressing;
- hiding a user decision inside a supporting action;
- allowing the Renderer to poll, verify, or own the condition;
- confusing recoverability with a separate Episode family.

### Examples

- waiting for Full Disk Access after directing the user to System Settings;
- waiting for a disconnected external drive to return;
- waiting for a condition that may become true while MessageLens is closed.

## Classification Examples

### Welcome

`Inform / welcome`

The Journey requires the user to receive an introduction. No domain answer,
operation, or external condition is involved.

### Permission Explanation

`Inform / explanation`

The feature supplies why Full Disk Access matters. Presence communicates that
meaning before any external action is requested.

### Waiting for Full Disk Access

`Await / externalAction`

The user may open System Settings, but independently observed permission state
completes the Episode.

### Archive Naming

`Ask<String> / input`

The user authors the archive name. A valid accepted name completes the Episode.

### Archive Scanning

`Work / indeterminate`

The scan is active, but no truthful denominator supports a percentage.
Operational evidence completes it.

### Archive Import

`Work / measurable` or `Work / phased`

The feature publishes truthful progress or phase facts. Those facts, not the
presentation, establish completion.

### External Drive Disconnected

`Await / recoverableCondition`

Observed drive availability completes the Episode. A reconnect button or user
claim does not.

### Import Completed

`Inform / completion`

The Journey is already durably complete. The Episode communicates the
authoritative outcome; it does not create it.

## Forbidden Extensions

The canonical vocabulary is closed.

Accordingly:

- features cannot introduce custom Episode families;
- features cannot bypass Presence with feature-specific interaction protocols;
- features cannot disguise custom screens as semantic purposes;
- Renderers cannot reinterpret Episode semantics or completion authority;
- every Coordinator-bound Renderer interaction carries Provenance;
- Episode identity may survive restart, but activation authority does not;
- Presentation Observations are never Journey evidence by themselves;
- operations cannot emit Episodes directly;
- operations publish facts;
- Presence derives Episodes from Journey state and feature facts;
- controls, visual treatments, and copy cannot redefine a protocol;
- an apparent gap in the vocabulary must be resolved in canonical Presence
  architecture rather than patched within one feature.

## Relationship to Other Presence Documents

- [`00-PRESENCE.md`](00-PRESENCE.md) defines why Presence exists.
- [`Presence Episode Specification`](01-DESIGN-DOCUMENTS/presence-episode-specification.md)
  defines what an Episode is.
- This document defines which canonical Episode protocols exist.
- [`20-JOURNEY-COORDINATION.md`](20-JOURNEY-COORDINATION.md) defines how
  Journeys move between Episodes.
- [`30-RENDERING.md`](30-RENDERING.md) defines how Episodes become
  presentation.
- [`40-AMBIENT-MOMENTS.md`](40-AMBIENT-MOMENTS.md) defines transient content
  within suitable Episodes.
- [`50-FEATURE-INTEGRATION.md`](50-FEATURE-INTEGRATION.md) defines how features
  participate.

## Review Checklist

Before accepting new Presence behaviour, verify:

- Is this the correct canonical Episode family?
- Who or what can truthfully complete this Episode?
- Is that completion authority observable or inherently user-authored?
- Is Presence deriving the interaction from durable Journey state and
  feature-supplied facts?
- Could the same truthful Episode be re-derived after application restart?
- Does the semantic purpose remain subordinate to its family?
- Is the Renderer limited to presentation and response capture?
- Is the feature attempting to invent new interaction machinery?
- Is an operation attempting to emit an Episode rather than publish facts?
- Would the protocol remain valid if the rendering technology changed?
