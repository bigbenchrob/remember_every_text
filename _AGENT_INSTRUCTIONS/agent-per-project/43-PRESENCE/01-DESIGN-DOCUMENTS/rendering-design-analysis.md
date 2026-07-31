# Presence Rendering Design Analysis

## Recommended Canonical Rendering Model

Presence rendering is the terminal projection of one truthful Active Episode
into an accessible interaction surface.

The Renderer receives semantics that have already been derived. It may organize
and present those semantics, apply approved presentation policy, and capture
only the interactions declared by the Episode contract. It cannot determine
what is true, choose the Active Episode, perform feature work, or advance the
Journey.

The canonical flow is one-way:

```text
Durable Journey truth + current feature-owned facts
    -> Journey Coordinator
    -> Active Episode
    -> presentation policy
    -> concrete presentation
    -> declared interaction with Provenance
    -> Journey Coordinator
```

Nothing observed in the presentation becomes Journey or feature truth merely
because it was displayed, entered, animated, or acknowledged locally.

The model should distinguish five responsibilities:

| Responsibility | Owner |
| --- | --- |
| Determine Journey truth and Active Episode | Journey Coordinator |
| Define interaction semantics and completion authority | Episode contract |
| Define project-wide presentation behaviour | Presence presentation policy |
| Project the contract into a platform surface | Concrete Renderer |
| Perform work and establish domain facts | Owning feature |

The Renderer is terminal and replaceable. A different Renderer may change the
presentation without changing the Journey, Episode family, completion
authority, or permitted interaction.

## What Rendering Is

Rendering is a semantic-preserving transformation from an Active Episode to a
concrete, usable presentation.

It includes:

- arranging the Episode's primary and supporting content;
- selecting an approved treatment for the declared family and purpose;
- exposing only declared interactions and controls;
- presenting supplied progress evidence without estimating new facts;
- admitting eligible Moments according to presentation policy;
- maintaining readable pacing, focus, and accessibility;
- returning typed, provenance-bearing interaction events.

Rendering is not:

- Episode derivation;
- Journey coordination;
- feature-domain interpretation;
- operation execution;
- validation of business meaning;
- persistence of accepted decisions;
- proof that work or an awaited condition has completed;
- a source of progress, liveness, or completion truth.

### Architectural Layers

#### Episode semantics

Episode semantics define what the current interaction means:

- identity and family;
- semantic purpose;
- completion authority;
- primary communication;
- user responsibility;
- typed response contract, if any;
- declared supporting actions and Journey controls;
- supplied progress evidence;
- eligibility for subordinate Moments.

These semantics are canonical and Renderer-independent.

#### Presentation policy

Presentation policy governs how an already-authorized interaction is presented
calmly and accessibly. It may define pacing, hierarchy, control emphasis,
announcement behaviour, detail disclosure, and Moment cadence.

Policy cannot create semantic authority that the Episode does not contain.

#### Concrete presentation

Concrete presentation is the platform-specific projection: visible regions,
controls, reading order, focus behaviour, and nonvisual equivalents.

It may vary across platforms and contexts while preserving the same Episode
contract.

#### Visual styling

Visual styling includes typography, color, spacing, shape, and motion. It is
subordinate to semantic hierarchy and accessibility. It is not canonical
Episode meaning.

#### Feature-supplied content

Features own domain facts and content preparation. The Coordinator uses those
facts to derive the Episode. The Renderer receives approved content through the
Episode; it does not independently query or reinterpret feature state.

#### User interaction capture

The Renderer may capture only interactions declared by the Active Episode. A
captured value or command request is candidate evidence, not accepted Journey
truth.

## Rendering Pipeline

### Inputs

The Renderer requires an immutable presentation snapshot containing:

- Provenance for the current activation;
- Episode family and semantic purpose;
- completion-authority contract;
- primary message and supporting explanation;
- declared user responsibility;
- typed response contract, when applicable;
- declared supporting actions and Journey controls;
- feature-prepared progress or condition facts included by the Episode;
- currently eligible Moments;
- validation feedback authorized by the Coordinator;
- presentation context, including accessibility preferences.

The Renderer should not receive unrestricted feature repositories, operations,
or raw domain facts merely to decide what to show.

### Permitted Transformations

The Renderer may:

- map semantic hierarchy to platform hierarchy;
- choose among approved treatments for the same contract;
- adapt layout to available space;
- adapt motion, pacing, and announcements to accessibility settings;
- preserve local draft and disclosure state while Episode identity remains
  current;
- render updated evidence under the same Episode identity;
- withdraw obsolete presentation when identity changes.

### Outputs

Semantic outputs must be typed and carry Provenance sufficient to reject stale
interaction:

- acknowledgement;
- typed candidate response submission;
- declared supporting-command request;
- declared Journey-control request;
- Presentation Observation required by an already-authorized policy.

Presentation-local events do not leave the Renderer:

- draft editing before submission;
- detail expansion and collapse;
- focus and navigation movement;
- scrolling;
- animation progress;
- Moment transition;
- accessibility exploration.

### Prohibited Reverse Flow

The Renderer must not report inferred claims such as:

- "the user understood";
- "the operation is alive";
- "the import is 70% complete";
- "Full Disk Access is granted";
- "the external drive is available";
- "the response is acceptable to the feature";
- "the Journey should now advance."

Only the declared interaction is returned. The Coordinator and owning feature
determine its meaning against current truth.

## Provenance

Provenance is the identity chain accompanying every Coordinator-bound
interaction:

- Journey identity;
- Journey revision;
- Episode identity;
- activation occurrence;
- interaction occurrence.

Journey identity identifies the undertaking. Journey revision identifies the
durable Journey state from which the Active Episode was derived. Episode
identity identifies the logical interaction obligation and may remain stable
across reconstruction and restart.

Activation occurrence identifies one grant of foreground rendering authority.
It changes when the Active Episode is replaced, foreground ownership changes,
a Journey later regains foreground Presence, or restart reconciliation permits
rendering again. Episode identity may survive restart. Activation authority
does not.

Interaction occurrence identifies one semantic interaction crossing the
Renderer/Coordinator boundary. It permits duplicate rejection and correlates
later feedback. For `Ask<T>`, the interaction occurrence is the submission
occurrence.

The Coordinator accepts an interaction only when:

- the Journey identity and revision remain current;
- the Episode remains the Active Episode;
- the activation occurrence remains effective;
- the interaction occurrence has not already been consumed;
- the interaction is declared by the current Episode contract.

Provenance contains no Renderer, platform, widget, route, or serialization
identity. It is a shared Presence concept, not a rendering implementation
detail.

## Renderer Authority

The Renderer may select presentation treatment only within the alternatives
allowed by the Episode and policy. It may arrange content, expose declared
controls, collect input, present progress, and manage presentation-only
transitions.

It may not:

- select, retain, or replace the Active Episode;
- change family, purpose, or completion authority;
- invent an action or hide a required responsibility;
- start, pause, cancel, retry, or complete feature operations;
- accept a domain response;
- determine that an external condition is satisfied;
- infer progress or liveness;
- advance or terminate a Journey;
- choose foreground Presence;
- keep an obsolete presentation interactive.

This boundary should be mechanically enforced by narrow input and output
contracts. The Renderer should not be given capabilities it is forbidden to
exercise.

## Semantic Preservation

Every Renderer must preserve:

1. Episode identity and Provenance.
2. Episode family.
3. Semantic purpose.
4. Completion authority.
5. Primary communication.
6. Supporting explanation and its subordinate status.
7. Declared user responsibility.
8. Permitted response type and constraints.
9. Declared supporting actions and Journey controls.
10. Supplied feature facts and progress basis.
11. Moment eligibility and subordination.

Presentation may vary in:

- layout and visual composition;
- typography and color;
- visible versus initially collapsed supporting detail;
- motion and transition treatment;
- compactness;
- input-control idiom;
- nonvisual presentation;
- pacing within policy bounds.

A presentation is an illegal reinterpretation if it:

- makes an optional action appear required;
- makes a supporting action appear to complete an `Await`;
- presents an `Ask<T>` as unconstrained free-form input;
- presents estimated progress as measured fact;
- converts acknowledgement into domain consent;
- omits a required user responsibility;
- changes which event completes the Episode;
- gives a Moment equal or greater authority than the Active Episode.

## Presentation Policy

Presence benefits from a canonical policy layer, but that layer must remain
presentation policy rather than semantic policy.

### Project-Wide Policy

Project-wide policy should govern:

- one meaningful thing at a time;
- stable semantic hierarchy;
- minimum readable opportunity before authorized automatic progression;
- stale-presentation withdrawal;
- suppression of competing Moments;
- preservation of typed input during same-identity updates;
- calm progress cadence;
- accessibility reading order and focus principles;
- reduced-motion equivalence;
- announcement throttling;
- required distinction between primary, supporting, and ambient content.

### Context-Dependent Policy

Platform, surface, and accessibility context may govern:

- exact timing above the minimum readable opportunity;
- transition style;
- compact versus expanded layout;
- whether optional detail begins collapsed;
- keyboard and focus mechanics;
- screen-reader announcement phrasing and priority;
- Moment transition treatment;
- motion reduction;
- available presentation density.

### Policy Must Not Decide

Presentation policy must not:

- choose the Episode;
- decide whether acknowledgement is semantically required;
- alter the response type;
- create supporting commands;
- determine operation truth;
- establish completion from elapsed time;
- decide foreground ownership.

Automatic progression is permitted only when the Episode contract and
Coordinator already authorize it. Policy may govern readable presentation; it
cannot manufacture authorization.

## One Meaningful Thing at a Time

One meaningful thing at a time is an attention invariant, not a widget-count
rule.

One Active Episode may contain several visible regions when they form one
coherent interaction:

- a primary statement or question;
- subordinate explanation;
- one response area;
- declared supporting actions;
- quiet progress evidence;
- an eligible Moment.

The presentation remains one meaningful thing when:

- all regions explain or serve the same Episode purpose;
- only one interaction has semantic priority;
- supporting content is visually and accessibly subordinate;
- controls have clearly distinct roles;
- optional detail does not create a parallel task;
- a Moment can disappear without changing the interaction.

Multiple controls are permissible when the Episode contract declares them and
their hierarchy is clear. For example, a primary typed response may coexist
with a secondary postpone request. Several equally emphasized, unrelated
choices would violate the principle.

Validation feedback remains part of the same `Ask<T>` Episode while the
question and completion authority remain unchanged. It does not become a new
Episode merely because the presentation gains an error message.

Progress facts and Moments may coexist only when progress remains the
authoritative Work communication and the Moment remains optional, transient,
and noninteractive.

## Family-Specific Rendering Contracts

### Inform

Rendering must support:

- a clear primary message;
- subordinate explanation;
- declared acknowledgement when required;
- Coordinator-authorized automatic progression;
- completion and failure summaries;
- sufficient reading opportunity.

Rendering must not:

- infer that visible content was understood;
- turn automatic timing into Journey truth;
- treat acknowledgement as feature-domain consent;
- add choices not declared by the Episode.

If automatic progression is authorized, the Renderer may report a Presentation
Observation that a readable opportunity was provided. The Coordinator still
verifies current Provenance and Journey truth before advancing.

### Ask<T>

Rendering must support:

- one constrained question;
- a presentation appropriate to the declared response type;
- local draft input;
- typed candidate submission;
- authorized validation feedback;
- preservation of draft during same-identity feedback and updates;
- correction and resubmission.

Rendering must not:

- become a generic form builder;
- infer a response schema;
- validate feature-domain meaning independently;
- commit the answer;
- advance on local control state alone.

If a Journey genuinely requires several independent questions, they should
normally be sequential Episodes. Several fields are permissible only when they
form one indivisible typed response and one completion decision.

### Work

Rendering must support truthful evidence for:

- indeterminate work, without invented percentage;
- measurable work, using supplied numerator, denominator, and basis;
- phased work, naming the current phase without implying a false global
  percentage;
- liveness or last-update facts when supplied by the feature;
- same-identity evidence updates;
- declared Journey-control requests;
- subordinate Moments.

Rendering must not:

- calculate operational progress from UI timing;
- infer liveness from animation;
- smooth supplied values into false evidence;
- start, pause, cancel, retry, or complete work directly;
- treat a Journey-control request as its successful result.

Frequent updates should preserve Episode identity and avoid repeatedly
announcing the entire Episode.

### Await

Rendering must support:

- a clear statement of the awaited condition;
- explanation of what the user may do;
- declared supporting external actions;
- reassurance that leaving is safe when truthful;
- refreshed condition facts under the same Episode identity;
- recovery guidance.

Rendering must not:

- treat "I did it" as proof of the external condition;
- perform or own condition observation;
- imply progress when none is known;
- make a supporting action appear to complete the Episode.

A supporting action may open System Settings or reveal instructions. The
feature-owned observer establishes whether the awaited condition later became
true.

## Coordinator-Bound Renderer Outputs

### Declared User Interactions

The canonical user-interaction categories should be closed and typed:

| Event | Meaning |
| --- | --- |
| **Acknowledge** | User performed the Episode's declared acknowledgement. |
| **SubmitCandidate<T>** | User submitted a typed candidate response for the current `Ask<T>`. |
| **RequestSupportingCommand** | User invoked a command explicitly declared by the Episode. |
| **RequestJourneyControl** | User requested a declared cancel, postpone, retry, resume, or abandon action. |

Every interaction carries Provenance. Action interactions must identify one
action declared by that Episode. Arbitrary callbacks, string action names, and
untyped maps should not cross the rendering boundary.

Submission is the semantic event for an `Ask<T>`. Individual keystrokes and
draft changes remain local unless the Episode contract explicitly requires a
durable draft, in which case durability is coordinated outside rendering.

### Presentation Observations

A Presentation Observation is a Renderer-originated report that a declared
presentation condition occurred. The canonical example is:

> Readable opportunity provided.

It reports only what the Renderer can know about presentation. It does not
claim that the user read, understood, acknowledged, or accepted anything.

A Presentation Observation carries Provenance and may leave the Renderer only
when the Episode and Presentation Policy declare it relevant. The Coordinator
alone determines whether it has any significance for a Journey transition. It
is never Journey evidence by itself.

### Rendering-Local Events

These remain local:

- candidate editing;
- structural affordance feedback before submission;
- expansion and collapse;
- focus changes;
- navigation;
- scrolling;
- animation completion not required by policy;
- Moment cycling;
- accessibility exploration.

Accessibility events should not become Journey events merely because they
indicate that content received focus or was announced.

## Validation

Validation has separate authorities:

| Validation layer | Responsibility |
| --- | --- |
| **Presentation-local** | Input mechanics such as preventing impossible control states or showing declared format guidance. |
| **Structural contract** | Checks the submitted candidate against constraints encoded in the typed response contract. |
| **Feature-domain** | Determines whether the candidate is meaningful and acceptable in the feature domain. |
| **Coordinator acceptance** | Confirms current Provenance and whether accepted evidence authorizes a Journey transition. |
| **Durable commitment** | Persists the accepted decision atomically with the authorized Journey transition. |

The Renderer may apply a shared structural validator supplied by the response
contract, but it does not own or redefine the rules. Feature-domain validation
must occur through the owning feature and Coordinator path.

Rejected input returns as authorized feedback associated with the same Episode
identity and originating interaction occurrence. The Renderer presents that
feedback while preserving the candidate draft where safe. Rejection does not
imply a new Episode unless the Journey's semantic obligation changes.

## Automatic Progression and Timing

Elapsed presentation time is never completion authority.

For an automatically advancing `Inform`:

1. the Episode contract declares that acknowledgement is not required;
2. Coordinator policy authorizes automatic progression;
3. rendering policy establishes a minimum readable opportunity;
4. the Renderer may report the Presentation Observation "Readable opportunity
   provided";
5. the Coordinator verifies Provenance and current Journey truth;
6. only the Coordinator commits the transition.

If Journey truth changes before the observation, the old presentation is
withdrawn and its timer becomes stale. A late observation is rejected because
its Journey revision or activation occurrence is no longer current.

Reduced motion may remove the fade. Screen-reader use may require a longer or
explicit reading opportunity. These adaptations change presentation timing,
not completion semantics.

## Episode Identity, Updates, and Replacement

### Identity Continuity

The same Episode identity remains when:

- measurable progress changes;
- phase evidence changes without changing the interaction obligation;
- an awaited condition is rechecked but remains unsatisfied;
- validation feedback is returned for the same question;
- supporting facts refresh without changing purpose or completion authority.

The Renderer updates the existing presentation and preserves safe local state.

### Replacement

A new identity replaces the presentation when the Journey's logical
interaction obligation changes.

On replacement:

- the new presentation becomes the only interactive Presence surface;
- the Coordinator issues a new activation occurrence;
- the outgoing presentation is immediately semantically inert;
- an outgoing visual transition may finish briefly;
- focus transfers according to accessibility policy;
- stale drafts and responses cannot reach the new Episode;
- late interactions are rejected by Provenance;
- Moments associated with the old Episode are withdrawn.

Foreground ownership change is also replacement. A background Journey's
presentation cannot remain interactive after another Journey becomes
Foreground.

Visual continuity must never imply semantic continuity. Conversely, a minor
visual rebuild must not manufacture a new Episode identity.

## Moments at the Rendering Boundary

The Renderer receives only Moments already eligible for the Active Episode and
current context. It may apply presentation policy to cadence and transition,
but it cannot promote a Moment into semantic content or emit Journey events
from it.

Moments must:

- remain subordinate to the Active Episode;
- be optional and transient;
- disappear without affecting Episode completion;
- yield to questions, failures, required actions, and urgent explanation;
- respect privacy and accessibility context;
- avoid repeated screen-reader interruption;
- not become evidence of progress or liveness.

Rendering policy may suppress an otherwise eligible Moment when current
presentation conditions would cause competition. It may not make an ineligible
Moment eligible.

The following belong in `40-AMBIENT-MOMENTS.md`:

- Moment categories and content contracts;
- feature eligibility rules;
- privacy classification;
- selection and rotation authority;
- cadence limits;
- repetition policy;
- provenance and expiration;
- cross-Journey admission.

## Accessibility Contract

Accessibility is a canonical rendering obligation.

Every Renderer must preserve:

- semantic reading order matching Episode hierarchy;
- clear identification of primary communication and current responsibility;
- keyboard access to every declared interaction;
- predictable focus on Episode replacement;
- typed-input preservation during same-identity updates;
- reduced-motion equivalence;
- sufficient readable opportunity;
- meaningful, throttled progress announcements;
- nonvisual distinction between primary content, supporting explanation, and
  Moments;
- prevention of obsolete presentations receiving focus or input.

### Canonical Presence Responsibilities

Presence should define:

- semantic order;
- focus-transfer intent;
- announcement priority;
- when an update is significant enough to announce;
- requirement to suppress repetitive progress announcements;
- reduced-motion semantic equivalence;
- preservation rules for drafts;
- stale-presentation inaccessibility.

### Platform Responsibilities

Concrete Renderers define:

- platform accessibility roles;
- key bindings and focus APIs;
- exact announcement mechanism;
- platform-specific timing;
- visual focus indicators;
- motion implementation;
- text scaling and reflow.

Frequent Work updates should update accessible values without announcing every
change. Phase changes, meaningful thresholds, problems, and completion may
justify announcements according to policy.

## Multiple Renderers

The same Episode contract should be renderable through:

- the primary macOS Presence surface;
- a compact maintenance surface;
- a future iPad surface;
- an accessibility-optimized surface;
- a nonvisual test Renderer.

All must preserve Episode identity, family, purpose, Completion Authority,
content hierarchy, declared interactions, evidence basis, and Provenance.

They may differ in layout, density, styling, motion, control idiom, optional
detail disclosure, and announcement strategy.

A nonvisual test Renderer should be able to inspect the Episode and emit only
declared typed events. If a test Renderer requires feature knowledge or widget
inspection to determine the next event, the contract is incomplete.

## Rendering Failure and Absence

Renderer availability is not Journey truth.

If rendering fails or is unavailable:

- the Journey continues to exist;
- durable Journey state remains authoritative;
- feature operations may continue if their own safety policy permits;
- no Episode is completed by the failure;
- the current Active Episode can be re-derived and presented later;
- required user input remains outstanding;
- background work does not become failed merely because it cannot be shown.

When rendering returns, the Coordinator reconciles current truth and derives
the Episode that is truthful now. It does not restore the old visual tree.
Rendering resumes under a new activation occurrence, even when the same
Episode identity remains truthful.

If required user input cannot be obtained, that becomes a coordination concern:
the Journey may remain ongoing, release foreground Presence, request attention,
or enter a recoverable blocked position according to policy. Rendering failure
itself is still not feature-operation failure.

## Pressure Test

### 1. Welcome to MessageLens

- **Episode:** `Inform / welcome`; acknowledgement or authorized automatic
  progression as declared.
- **Inputs:** Welcome identity, primary introduction, supporting orientation,
  declared completion mode.
- **Policy:** Calm hierarchy and sufficient reading opportunity.
- **Output:** Acknowledgement or the Presentation Observation "Readable
  opportunity provided" only if declared.
- **Forbidden:** Inferring understanding from visibility.
- **Identity:** Replaced when the Journey advances beyond welcome.
- **Accessibility:** Initial focus and announcement identify Presence without
  reading unrelated application chrome first.

### 2. Full Disk Access Explanation

- **Episode:** `Inform / explanation`; user understanding is the current
  obligation.
- **Inputs:** Rationale, consequence, next-step preview, acknowledgement mode.
- **Policy:** Supporting detail may expand but remains one explanation.
- **Output:** Declared acknowledgement.
- **Forbidden:** Opening settings or claiming permission.
- **Identity:** Replacement by the later `Await`.
- **Accessibility:** Explanation precedes action preview in reading order.

### 3. Awaiting Full Disk Access

- **Episode:** `Await / externalAction`; completion authority is observed
  permission state.
- **Inputs:** Awaited condition, supporting Open System Settings command,
  leave-and-return reassurance.
- **Policy:** Supporting command is prominent but not presented as completion.
- **Output:** Supporting-command request.
- **Forbidden:** Treating the button press or "done" assertion as permission
  evidence.
- **Identity:** Continues while the condition remains unsatisfied.
- **Accessibility:** Condition and independent completion mechanism are stated
  explicitly.

### 4. User Leaves and Later Returns

- **Episode:** Whatever current truth derives, commonly the same `Await`.
- **Inputs:** Reconciled current Journey and feature facts, never prior UI.
- **Policy:** Re-present calmly without replaying obsolete transitions.
- **Output:** Only events declared by the newly derived Episode.
- **Forbidden:** Restoring stale visual state as semantic state.
- **Identity:** Same identity if the obligation is unchanged; replacement if
  the condition was satisfied while away.
- **Accessibility:** Focus begins at the current obligation, not a historical
  message.

### 5. Archive-Name Input

- **Episode:** `Ask<ArchiveName>`.
- **Inputs:** Typed constraints, candidate draft, authorized validation
  feedback.
- **Policy:** One question, one response area, quiet correction feedback.
- **Output:** Typed candidate submission.
- **Forbidden:** Renderer committing the name or inventing domain naming rules.
- **Identity:** Remains through invalid submission; replaced after accepted
  commitment.
- **Accessibility:** Error is associated with the field and announced once
  without discarding input.

### 6. Indeterminate Archive Scan

- **Episode:** `Work / indeterminate`.
- **Inputs:** Operation identity, phase or liveness evidence actually supplied,
  declared Journey controls.
- **Policy:** Activity may be communicated without a percentage.
- **Output:** Declared Journey-control request only.
- **Forbidden:** Progress inferred from time, animation, or item samples.
- **Identity:** Same throughout the scan unless the semantic obligation changes.
- **Accessibility:** Avoid continuously announcing animation; announce
  meaningful phase or status changes.

### 7. Measurable Import

- **Episode:** `Work / measurable`.
- **Inputs:** Supplied numerator, denominator, basis, liveness, and controls.
- **Policy:** Throttle visual and spoken updates while preserving truthful
  current values.
- **Output:** Declared Journey-control request.
- **Forbidden:** Smoothing or extrapolating a false percentage.
- **Identity:** Same Episode across progress updates.
- **Accessibility:** Announce meaningful thresholds, not every increment.

### 8. Phased Import

- **Episode:** `Work / phased`.
- **Inputs:** Current phase, known phase sequence if supplied, phase-local facts.
- **Policy:** Emphasize phase identity; avoid a fabricated global percentage.
- **Output:** Declared control request.
- **Forbidden:** Treating phase ordinal as global completion.
- **Identity:** Usually continuous across phases when the interaction obligation
  remains "import in progress."
- **Accessibility:** Announce phase changes once.

### 9. Message Excerpts During Work

- **Episode:** `Work`; excerpts are eligible Moments.
- **Inputs:** Active Work contract plus approved Moment content.
- **Policy:** Gentle cadence; suppress when status or action requires attention.
- **Output:** No Journey event from the Moment.
- **Forbidden:** Making excerpts interactive progress evidence.
- **Identity:** Work Episode remains continuous as Moments change.
- **Accessibility:** Moments must not repeatedly interrupt progress
  announcements; reduced motion may present fewer or static Moments.

### 10. External Drive Disconnected

- **Episode:** `Await / recoverableCondition` or a truthful recovery `Ask<T>`,
  depending on Journey policy.
- **Inputs:** Feature-observed disconnection, required condition, supporting
  actions.
- **Policy:** Problem explanation takes priority; suppress Moments.
- **Output:** Declared supporting command or Journey-control request.
- **Forbidden:** Claiming reconnection from a button press.
- **Identity:** Replacement from Work to Await because completion authority
  changed.
- **Accessibility:** Focus and announcement move to the actionable condition.

### 11. Background Journey Requests Attention

- **Episode:** The current Active Episode remains effective until the
  Coordinator changes foreground ownership.
- **Inputs:** Renderer receives no replacement merely from a feature attention
  request.
- **Policy:** Any non-Presence notification is outside Active Episode rendering.
- **Output:** No foreground decision.
- **Forbidden:** Background feature seizing or replacing Presence.
- **Identity:** Replacement only after Coordinator arbitration.
- **Accessibility:** Avoid unsolicited focus theft.

### 12. Import Completes in Background

- **Episode:** No active completion presentation until the Coordinator makes the
  Journey Foreground and derives a truthful `Inform`.
- **Inputs:** Once foregrounded, authoritative completion facts.
- **Policy:** Completion may be concise; no replay of stale progress.
- **Output:** Declared acknowledgement if required.
- **Forbidden:** Renderer inferring completion from missing updates.
- **Identity:** New completion Episode replaces prior Work obligation.
- **Accessibility:** Completion announcement occurs when presented, not
  repeatedly while backgrounded.

### 13. Episode Changes During Outgoing Fade

- **Episode:** New Episode is immediately the sole active semantic interaction.
- **Inputs:** New identity and presentation snapshot.
- **Policy:** Old visual may finish a noninteractive fade.
- **Output:** Only events from the new presentation are accepted.
- **Forbidden:** Outgoing controls remaining active.
- **Identity:** Definite replacement; stale interactions rejected by
  Provenance.
- **Accessibility:** Old content is removed from focus and semantics
  immediately, regardless of visible fade.

### 14. Reduced Motion and Screen Reader

- **Episode:** Semantics are unchanged for every family.
- **Inputs:** Same Episode plus accessibility presentation context.
- **Policy:** Replace motion with immediate or low-motion transitions; use
  semantic reading order and throttled announcements.
- **Output:** Same declared event categories.
- **Forbidden:** Changing completion authority because animation is absent or
  assuming announcement equals acknowledgement.
- **Identity:** Same continuity and replacement rules.
- **Accessibility:** Presentation adapts without losing hierarchy, controls,
  draft state, or truth.

## Canonical Rendering Invariants

1. Rendering is a projection, never an authority.
2. Only the Active Episode may be rendered as the current Presence interaction.
3. Renderer input is derived from current Journey truth and approved feature
   facts; it is not an independent fact-gathering surface.
4. Renderer output is limited to typed events declared by the Active Episode.
5. Every Coordinator-bound Renderer interaction carries Provenance.
6. Provenance contains Journey identity, Journey revision, Episode identity,
   activation occurrence, and interaction occurrence.
7. Episode identity may survive restart; activation authority cannot.
8. An interaction from an obsolete activation occurrence cannot affect Journey
   truth.
9. An interaction occurrence may be accepted at most once.
10. A Presentation Observation reports only a presentation condition and is
    never Journey evidence by itself.
11. Rendering cannot advance, complete, fail, or abandon a Journey.
12. Presentation timing cannot establish Episode completion.
13. Visibility, focus, or announcement cannot establish user understanding.
14. Stale presentations become noninteractive immediately on replacement.
15. Outgoing visual transitions cannot extend semantic lifetime.
16. Progress presentation cannot estimate or manufacture operational truth.
17. Renderer animation cannot establish liveness.
18. Visual appearance cannot redefine family, purpose, responsibility, or
    completion authority.
19. Supporting actions cannot be presented as proof of their outcome.
20. Validation feedback cannot make the Renderer owner of domain truth.
21. Local draft state cannot become durable Journey truth accidentally.
22. Moments remain subordinate, nonauthoritative, and unable to emit Journey
    events.
23. Accessibility adaptations preserve Episode semantics.
24. Renderer failure is not Journey or operation failure.
25. The Renderer is replaceable without changing Journey or Episode semantics.

## Recommended Renderer Contracts

### Input Contract

The canonical input should be an immutable Active Episode presentation
snapshot containing:

- semantic Episode contract;
- Provenance;
- approved feature-prepared content and evidence;
- declared actions and controls;
- authorized validation feedback;
- eligible Moments;
- presentation and accessibility context.

The input should expose no unrestricted operational authority.

### Output Contract

The canonical semantic output should contain two closed categories of typed,
Provenance-bearing events:

- declared user interactions:
  - acknowledge;
  - submit typed candidate;
  - request declared supporting command;
  - request declared Journey control;
- declared Presentation Observations, including "Readable opportunity
  provided."

All other interaction remains presentation-local.

## Semantic Policy Versus Concrete Presentation

Semantic policy belongs in the Episode and Journey contracts:

- family;
- purpose;
- completion authority;
- required responsibility;
- permitted response;
- available commands;
- foreground ownership.

Canonical presentation policy belongs to Presence rendering:

- one meaningful thing at a time;
- semantic hierarchy;
- calm pacing;
- readable opportunity;
- stale withdrawal;
- Moment subordination;
- accessibility intent;
- announcement discipline;
- local-state preservation.

Concrete presentation belongs to each Renderer:

- layout;
- platform controls;
- visual styling;
- exact motion;
- focus APIs;
- key bindings;
- screen-reader mechanism;
- responsive adaptation.

## Remaining Architectural Questions

Before writing `30-RENDERING.md`, settle only questions that materially affect
the canonical contract:

1. Which presentation policies are mandatory project-wide versus defaults that
   a platform Renderer may override.
2. Whether local Ask drafts must ever survive application termination, and if
   so which non-rendering owner persists them.
3. Whether validation feedback is represented within the same Episode snapshot
   or as a separate rendering response envelope.
4. How foreground attention requests are surfaced without creating a second
   simultaneous Presence interaction.
5. Which accessibility announcement thresholds are canonical and which remain
   platform policy.

The complete Moment admission and cadence model remains deferred to
`40-AMBIENT-MOMENTS.md`.

## Proposed Outline for `30-RENDERING.md`

1. Purpose and definition
2. Rendering authority boundary
3. Canonical one-way pipeline
4. Renderer input contract
5. Renderer output events
6. Semantic preservation
7. Presentation policy
8. One meaningful thing at a time
9. Family-specific rendering contracts
10. Validation and typed response capture
11. Timing and automatic progression
12. Episode identity, update, and replacement
13. Moment rendering boundary
14. Accessibility contract
15. Multiple Renderers and replaceability
16. Rendering failure and recovery
17. Canonical invariants
18. Review checklist

## Narrow Terminology Refinements

Later canonical editing should use these distinctions consistently:

- **Renderer** means the terminal semantic-preserving projector, not merely a
  visual widget tree.
- **Presentation policy** means permitted behaviour for presenting an existing
  Episode; it does not mean Journey or completion policy.
- **Concrete presentation** means one platform projection of the Episode.
- **Presentation Observation** means a Renderer report that a declared
  presentation condition occurred, such as "Readable opportunity provided." It
  is never Journey evidence by itself.
- **Provenance** means the Journey identity, Journey revision, Episode identity,
  activation occurrence, and interaction occurrence accompanying every
  Coordinator-bound interaction.
- **Activation occurrence** means one grant of foreground rendering authority.
  It does not survive restart.
- **Interaction occurrence** means one semantic interaction crossing the
  Renderer/Coordinator boundary.
- **Replacement** means semantic withdrawal of one Episode presentation and
  activation of another, even when a visual transition overlaps briefly.
- **Draft** means Renderer-local candidate state until another owner explicitly
  makes it durable.

The canonical Presence, Episode, and Journey documents use these refinements
now. They should also govern the later canonical authoring of
`30-RENDERING.md`.
