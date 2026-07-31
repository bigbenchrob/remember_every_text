# Presence Feature Integration

## Status

This document is the canonical architecture for feature participation in
Presence.

It defines the ownership boundary and truthful information flow between
features and Presence.

Presence purpose is defined by [`00-PRESENCE.md`](00-PRESENCE.md). Episode
protocols are defined by [`10-EPISODE-MODEL.md`](10-EPISODE-MODEL.md). Journey
continuity and transition authority are defined by
[`20-JOURNEY-COORDINATION.md`](20-JOURNEY-COORDINATION.md). Rendering is defined
by [`30-RENDERING.md`](30-RENDERING.md), and Moment admission is defined by
[`40-AMBIENT-MOMENTS.md`](40-AMBIENT-MOMENTS.md).

Feature Integration assumes those authorities already exist. It does not
redefine them.

## Central Principle

> Features own domain meaning. Presence owns interaction.

Features know what is true, what work is possible, what work is safe, and what
domain result means.

Presence knows how one durable undertaking remains coherent for the user, what
interaction is currently truthful, and how that interaction is presented.

Neither side becomes simpler by absorbing the other's authority. The boundary
exists so domain truth and interaction truth can evolve independently while
remaining compatible.

## Integration Boundary

The canonical relationship is:

```text
Feature domain and operations
    publish facts, capabilities, validation, and evidence

Presence
    reconciles those facts with durable Journey truth
    derives the one truthful Active Episode
    presents its declared interaction

User interaction
    returns through the Coordinator

Feature domain and operations
    receive only mediated requests whose intent is durably established
```

The boundary is semantic rather than presentational. A feature supplies the
meaning and truth required for interaction. It does not supply a private
interaction protocol or concrete presentation.

## Feature Responsibilities

Features own:

- domain vocabulary and user-domain meaning;
- business rules and validity constraints;
- factual truth within their domain;
- operational work;
- operation identity and attempt identity;
- command meaning, availability, safety, acceptance, and outcome;
- operational state and evidence;
- truthful liveness, phase, progress basis, and checkpoints;
- external dependency facts they can observe;
- interruption, recoverability, completion, and failure facts;
- feature-domain validation;
- preparation of truthful user-visible factual content;
- privacy and sensitivity meaning for feature-owned content;
- relevance and freshness of feature-owned content;
- proposal, refresh, and withdrawal of Moment content.

Features never own:

- Journeys or Journey lifecycle;
- Active Episode derivation;
- Episode families, purposes, or Completion Authority protocols;
- Presence transitions;
- foreground ownership or arbitration;
- Presentation Policy;
- Rendering;
- Moment eligibility or admission;
- project-wide interaction semantics.

A feature may describe a fact, capability, consequence, or required domain
decision. It cannot decide that those facts must appear as a particular
Episode or presentation.

## Presence Responsibilities

Presence owns:

- durable Journey continuity;
- semantic Journey position;
- accepted user decisions within the Journey contract;
- foreground ownership and arbitration;
- derivation and replacement of the Active Episode;
- enforcement of canonical Episode protocols;
- enforcement of Completion Authority;
- interaction semantics;
- Coordinator validation and transition authorization;
- durable Journey intent preceding feature requests;
- reconciliation of feature evidence with Journey truth;
- atomic Journey transitions;
- Rendering and Presentation Policy;
- Moment eligibility and admission;
- continuity across interruption and restart.

Presence never owns:

- feature business rules;
- operational execution;
- feature-domain state;
- technical safety of feature commands;
- feature-domain validation;
- calculation of feature facts or progress;
- observation authority that belongs to a feature;
- the factual basis or domain meaning of a Moment proposal.

Presence coordinates authoritative facts. It does not manufacture them.

## Feature to Presence

A feature may supply the facts and capabilities Presence needs to derive a
truthful interaction.

### Current Domain Facts

Current facts may include:

- the domain subject under consideration;
- factual explanation relevant to the user;
- available choices and their domain consequences;
- input constraints;
- observed external conditions;
- dependency availability;
- privacy and sensitivity classifications;
- relevance and freshness.

Facts remain feature-owned even when Presence incorporates them into an
Episode.

### Operational Evidence

Feature operations may supply:

- stable operation and attempt identity;
- request acceptance or rejection;
- current operational status;
- truthful liveness evidence;
- current phase;
- measurable progress and its factual basis;
- checkpoints;
- interruption facts;
- recoverability;
- dependency loss or restoration;
- completion evidence;
- recoverable or permanent failure evidence;
- terminal outcome facts.

Operational evidence describes what is true. It does not prescribe an Episode,
transition, message, or visual treatment.

### Validation Results

Features may supply:

- feature-domain acceptance of a typed candidate;
- feature-domain rejection and its truthful explanation;
- current valid choices or constraints;
- evidence that a previously valid candidate is now stale;
- the domain consequences of acceptance.

Validation results do not commit Journey transitions. The Coordinator remains
responsible for currentness, Provenance, transition authorization, and durable
acceptance.

### Command Capabilities

Features may describe:

- which operations or supporting actions are available;
- what each command means;
- whether it is currently safe and permitted;
- what acceptance or rejection means;
- what later evidence can establish its outcome.

Describing a capability does not expose a control, authorize a request, or
establish that the command ran.

### Moment Proposals

Features may propose Moment content together with the factual basis, relevance,
freshness, privacy, and sensitivity needed for Presence to evaluate it.

A Moment proposal is not an Episode, event, instruction, progress fact, or
request for attention.

## Information Features Must Not Supply

Features and operations must not supply:

- Journey transitions;
- Episode instances or private Episode families;
- semantic purposes outside the canonical Episode model;
- Completion Authority chosen for presentation convenience;
- foreground ownership decisions;
- Presentation Policy;
- concrete presentation or navigation instructions;
- Renderer state;
- fabricated progress or liveness;
- Moment eligibility or admission decisions;
- claims that a user gesture completed an observable condition;
- claims that a request succeeded merely because it was issued.

Feature-prepared user-visible content remains factual content. It cannot carry
a hidden interaction protocol.

## Presence to Feature

Presence never forwards raw presentation events to a feature as commands.

The mandatory flow for an interaction that can lead to feature work is:

```text
Renderer interaction
    -> Coordinator validation
    -> durable Journey intent
    -> feature request
    -> feature acceptance or rejection
    -> operational evidence
    -> reconciliation
```

Every boundary in this sequence preserves a distinct truth:

- **Renderer interaction** reports declared user intent with current
  Provenance.
- **Coordinator validation** establishes that the interaction belongs to the
  current Journey, Episode, activation, and declared protocol.
- **Durable Journey intent** records what the Journey has truthfully requested
  before externally consequential work begins.
- **Feature request** asks the owning feature to validate or perform a declared
  domain action.
- **Feature acceptance or rejection** establishes whether the feature accepted
  the request under its own rules and safety constraints.
- **Operational evidence** establishes what actually happened after any
  accepted request.
- **Reconciliation** applies current feature truth to current Journey truth and
  derives the resulting Episode or transition.

A Renderer-originated event never becomes a feature command merely because the
user invoked a control.

### Typed User Responses

A typed candidate from `Ask<T>` first returns to the Coordinator with
Provenance.

The Coordinator determines whether the candidate belongs to the current
interaction and satisfies the structural contract. When feature-domain
validation or action is required, Presence records the applicable durable
intent before issuing the feature request.

The feature accepts or rejects domain meaning. The Coordinator reconciles that
result and commits any authorized Journey transition.

The raw candidate is never business truth merely because it was submitted.

### Acknowledgements

Acknowledgement belongs to the `Inform` protocol. It normally affects Journey
coordination rather than feature truth.

If discharging an `Inform` allows a feature request already authorized by
Journey truth, the Coordinator first validates the acknowledgement and records
the resulting durable Journey intent. The acknowledgement is neither domain
consent nor an operational command.

### Supporting-Command Requests

A supporting command request expresses intent to invoke one command declared
for the current Episode.

The Coordinator validates the request and records durable intent before
requesting feature action. Feature acceptance is not assumed. The Episode does
not complete until evidence from its declared Completion Authority justifies
that result.

### Journey-Control Requests

Journey controls express user intent about the undertaking.

The Coordinator determines their coordination meaning. When fulfilling a
control requires feature action, such as cancellation, retry, resume, or a
feature-supported pause, the same mediated request flow applies.

Requesting a Journey control never establishes that the feature action was
accepted or completed.

### Validated Interaction Results

Presence may issue a feature request derived from a structurally valid, current
interaction. This means only that the interaction is valid within the Presence
contract.

It does not mean:

- the domain candidate is acceptable;
- the requested command is safe;
- the feature accepted the request;
- operational work began;
- the requested outcome occurred.

Those remain feature-owned truths.

## Validation

Validation preserves separate authorities.

| Validation layer | Authority |
| --- | --- |
| **Presentation-local** | Maintains valid interaction mechanics and presents declared format guidance. |
| **Structural contract** | Determines whether a candidate conforms to the typed response contract declared by the Episode. |
| **Feature-domain** | Determines whether the candidate is meaningful and acceptable under current business rules and domain facts. |
| **Coordinator acceptance** | Verifies Provenance, current Journey truth, current Episode authority, and whether accepted evidence authorizes a transition. |
| **Durable commitment** | Makes the accepted Journey decision and transition authoritative. |

The canonical validation flow is:

```text
typed candidate with Provenance
    -> currentness and structural validation
    -> durable pending intent when feature participation is required
    -> feature-domain validation
    -> feature acceptance or rejection
    -> Coordinator reconciliation
    -> durable acceptance and authorized Journey transition
```

Feature rejection returns truthful validation facts. Presence presents those
facts within the same `Ask<T>` while the logical question remains current.

No layer acquires another layer's authority merely because validation crosses
the integration boundary.

## Operations

Features perform operations. Presence represents their user-relevant meaning.

An operation:

- has feature-owned identity and state;
- follows feature-owned business and safety rules;
- may begin only after the feature accepts a valid request or under previously
  established feature authority;
- publishes truthful facts and evidence;
- continues, pauses, stops, retries, or fails according to feature and
  application safety policy;
- never knows which Episode is active;
- never advances a Journey.

Presence:

- records durable Journey intent before requesting consequential work;
- relates the operation to the Journey without absorbing operational state;
- derives `Work` only from evidence that work is active;
- derives another Episode when current truth establishes another completion
  authority;
- never starts, performs, estimates, repairs, or completes the operation.

Features publish facts. Presence derives interaction.

## Long-Running Work

Long-running work preserves the same boundary throughout its lifecycle.

### Start

Presence records durable Journey intent before requesting work. The feature
accepts or rejects the request. Presence derives `Work` only after feature
evidence truthfully establishes activity.

### Progress

The feature supplies truthful liveness, phase, progress basis, and checkpoints.
Presence presents only the evidence supplied and never invents precision.

### Checkpoints

The feature owns checkpoint meaning and operational resumability. The Journey
may reference a checkpoint when continuity requires it, but Presence does not
reinterpret or duplicate feature-owned checkpoint state.

### Interruption

The feature establishes that work was interrupted and whether recovery is
possible. Presence reconciles those facts with Journey truth and derives the
Episode whose Completion Authority matches the next truthful obligation.

### Restart Reconciliation

On restart, Presence loads durable Journey truth and obtains current facts from
feature authorities.

It does not infer operational state from prior presentation. The feature
establishes whether work is active, interrupted, complete, failed, or safe to
resume. Presence reconciles that evidence before deriving the Active Episode.

### Completion

The feature publishes completion evidence and outcome facts. The Coordinator
validates their relevance to the current Journey and operation occurrence,
commits the authorized transition, and may derive an `Inform` that communicates
the already-established result.

Displaying completion does not complete the operation.

### Failure

The feature publishes truthful failure and recoverability facts. Presence does
not infer failure from silence, elapsed time, missing presentation updates, or
a rejected command.

## Failure and Recovery

### Recoverable Failure

The feature owns:

- the failure facts;
- whether recovery remains possible;
- available recovery actions;
- retry safety;
- valid alternatives;
- evidence for any later attempt.

Presence keeps the Journey Ongoing and derives the canonical Episode required
by current truth. That may be `Inform`, `Ask<T>`, `Work`, or `Await`; the feature
does not select the family.

### Permanent Failure

The feature publishes evidence that the undertaking cannot continue or recover
within its contract. The Coordinator determines whether that evidence applies
to the current Journey and commits the transition to Failed.

A failure summary communicates an outcome already established in Journey
truth. It does not create failure.

### Retry

The feature defines whether retry is supported and safe. Presence may expose a
declared Journey control only when the Journey contract permits it.

The user's retry request becomes durable Journey intent before a new feature
request is issued. The feature accepts or rejects the new attempt and publishes
evidence under the appropriate operation occurrence. Earlier evidence cannot
complete the later attempt.

### Dependency Loss

The feature publishes dependency availability and any operational consequence.
Presence normally keeps the Journey Ongoing and derives `Await` when
independent observation of dependency restoration is the truthful Completion
Authority.

Restoration is established by feature evidence, not by user assertion or a
supporting command.

## Moment Integration

Moment integration preserves the authority chain defined by
[`40-AMBIENT-MOMENTS.md`](40-AMBIENT-MOMENTS.md):

```text
Feature
    proposes truthful, relevant content

Presence
    evaluates semantic eligibility and admission

Rendering
    determines concrete presentation under Presentation Policy
```

The feature owns:

- the content's factual basis;
- its domain meaning;
- relevance and freshness;
- privacy and sensitivity meaning;
- refresh and withdrawal when feature truth changes.

Presence owns:

- compatibility with the current Foreground Journey and Active Episode;
- semantic eligibility;
- admission and withdrawal from the Episode context;
- enforcement of subordination and optionality.

Rendering owns:

- concrete presentation;
- presentation-time suppression under Presentation Policy;
- immediate withdrawal of obsolete presentation.

A refreshed proposal receives a fresh eligibility decision. A withdrawn or
expired proposal cannot remain admitted because it was previously presented.

Moment proposals never become operational evidence, interactions, or
Coordinator events.

## MessageLens Examples

### Onboarding

**Feature owns:** environment facts, readiness requirements, available archive
choices, domain consequences, and validation of user-supplied choices.

**Presence owns:** the onboarding Journey, foreground continuity, derivation of
welcome, explanation, questions, awaited conditions, and completion
communication.

**Interaction returned:** acknowledgements and typed onboarding choices return
to the Coordinator. Feature requests follow only after currentness validation
and durable Journey intent.

**Moment involvement:** optional and normally absent while the user is making
required setup decisions.

### Full Disk Access

**Feature owns:** truthful permission status, why access is required, the
meaning of any supporting action, and observation of permission changes.

**Presence owns:** the explanatory `Inform`, the `Await` while access remains
absent, and the transition after independent evidence says access exists.

**Interaction returned:** a supporting-command request may ask the feature to
open the relevant system location. Invoking it does not establish permission.

**Moment involvement:** none while a required permission condition owns the
user's attention.

### Archive Ingestion

**Feature owns:** source validation, import work, operation identity, phases,
checkpoints, truthful progress, recoverability, completion, and failure facts.

**Presence owns:** durable Journey intent, foreground interaction, the `Work`
Episode while evidence says import is active, and later Episodes derived from
completion, failure, interruption, or dependency facts.

**Interaction returned:** Journey-control requests such as retry, postpone, or
cancel are mediated by the Coordinator. Feature action follows only after
durable intent and feature acceptance.

**Moment involvement:** meaningful memories may be proposed during suitable
`Work`, but never serve as progress or liveness evidence.

### Archive Scan

**Feature owns:** scan activity, discovered facts, liveness, phase, any truthful
progress basis, findings, and completion evidence.

**Presence owns:** truthful `Work` communication and any transition justified
by current scan evidence.

**Interaction returned:** declared Journey controls are mediated through the
Coordinator; the Renderer does not control the scan.

**Moment involvement:** a meaningful discovery may be proposed when privacy
and attention context permit it.

### Attachment Import

**Feature owns:** attachment source facts, availability, transfer work,
operation identity, truthful counts, checkpoints, recoverability, and outcomes.

**Presence owns:** the Journey's interaction continuity, `Work` while import is
active, `Await` when an independently observable dependency is missing, and
communication of already-established completion or failure.

**Interaction returned:** a supporting request or Journey control is mediated
through the Coordinator and cannot itself establish source availability or
transfer success.

**Moment involvement:** optional contextual content is permitted only when it
does not disclose sensitive material or compete with required operational
communication.

## Forbidden Coupling

### Features Must Never

Features must never:

- create, emit, advance, complete, or archive Journeys;
- create or emit Episodes;
- introduce private Episode families or interaction protocols;
- request a specific screen, control, or presentation treatment;
- invoke Rendering directly;
- decide foreground ownership or seize Presence;
- treat a Renderer interaction as a feature command;
- infer user intent from visibility, focus, or presentation state;
- infer operation acceptance or success from a request;
- make operational correctness depend on Renderer availability;
- use Presence state as feature-domain truth;
- make a Moment carry required information or operational evidence;
- publish fabricated progress, liveness, completion, or failure.

### Presence Must Never

Presence must never:

- invent, reinterpret, or override feature facts;
- perform feature business logic;
- perform, pause, retry, cancel, repair, or complete operational work;
- decide technical command safety;
- perform feature-domain validation;
- treat a raw user interaction as accepted business truth;
- issue consequential feature requests before durable Journey intent exists;
- infer feature acceptance because no rejection arrived;
- infer activity or success because a request returned;
- duplicate feature-owned operational state as Journey truth;
- calculate progress from elapsed time or presentation behaviour;
- expose interactions not declared by the current Episode;
- make a Moment eligible because presentation space is available.

## Replaceability

Presence and features remain independently replaceable at their boundary.

Removing Presence cannot make feature operations incorrect. Work that requires
user participation may remain safely blocked, but operational truth must not
depend on presentation availability.

A feature may be replaced without changing Presence architecture when the
replacement preserves the same domain meaning, facts, command semantics,
validation authority, and evidence contracts.

Presence may be replaced as an interaction system without changing the
feature's business rules, operational truth, or safety requirements.

Replaceability does not mean every undertaking can proceed without interaction.
It means an unavailable interaction system cannot cause feature work to become
false, unsafe, or incorrectly complete.

## Architectural Invariants

1. Features own domain meaning. Presence owns interaction.
2. Features own business rules, operational work, factual truth, and
   feature-domain validation.
3. Presence owns Journey continuity, Episode derivation, interaction semantics,
   foreground arbitration, transitions, and presentation.
4. Features publish facts and capabilities; Presence derives interaction.
5. Features and operations never publish Episodes.
6. Presence never performs feature operations.
7. Presence never invents or overrides feature facts.
8. Operations never know which Episode is active.
9. Raw Renderer interactions are candidate intent, never feature commands or
   business truth.
10. Every Renderer interaction is validated by the Coordinator with current
    Provenance before it can affect Journey intent.
11. Durable Journey intent precedes every externally consequential feature
    request made for that Journey.
12. A feature request is not feature acceptance.
13. Feature acceptance is not evidence that operational work began or
    succeeded.
14. Operational evidence, not request delivery or presentation, establishes
    activity, progress, completion, and failure.
15. Reconciliation applies feature evidence to current Journey truth before a
    transition is committed.
16. Structural validation, feature-domain validation, Coordinator acceptance,
    and durable commitment retain distinct authorities.
17. Acknowledgements, typed responses, supporting-command requests, and
    Journey-control requests never bypass the Coordinator.
18. A user assertion cannot replace independently observable evidence.
19. Features define command meaning and safety; Presence coordinates declared
    user intent concerning those commands.
20. Checkpoint meaning and operational resumability remain feature-owned.
21. Restart reconciliation uses durable Journey truth and current feature
    facts, never former presentation.
22. Feature failure evidence does not select an Episode family; Presence derives
    the protocol whose Completion Authority matches the next obligation.
23. Moment proposals remain proposals until Presence establishes eligibility
    and admission.
24. Moment presentation never creates feature or Journey truth.
25. Rendering mechanics never enter feature contracts.
26. Removing Presence cannot make feature operations incorrect; work requiring
    participation remains safely blocked.
27. Replacing a feature does not change canonical Presence architecture when
    the integration contract remains truthful.
28. Replacing Presence does not change feature business rules, operational
    truth, or safety policy.

## Relationship to Other Presence Documents

- [`00-PRESENCE.md`](00-PRESENCE.md) defines the project-wide purpose and the
  principle that features supply work while Presence supplies interaction.
- [`presence-episode-specification.md`](01-DESIGN-DOCUMENTS/presence-episode-specification.md)
  defines the general Episode contract and its relationship to feature facts
  and operations.
- [`10-EPISODE-MODEL.md`](10-EPISODE-MODEL.md) defines the closed interaction
  protocols features may consume but never redefine.
- [`20-JOURNEY-COORDINATION.md`](20-JOURNEY-COORDINATION.md) defines durable
  intent, mediated requests, transition authority, and reconciliation.
- [`30-RENDERING.md`](30-RENDERING.md) defines the terminal presentation
  boundary through which declared user interactions originate.
- [`40-AMBIENT-MOMENTS.md`](40-AMBIENT-MOMENTS.md) defines the Moment authority
  chain from feature proposal through Presence admission to Rendering.
- This document defines how feature truth and Presence interaction cross their
  shared boundary without exchanging ownership.

## Review Checklist

Before accepting a Presence feature integration, verify:

1. Is each fact and business rule owned by the feature?
2. Is each interaction protocol owned by Presence?
3. Does the feature publish facts rather than Episodes or presentation
   instructions?
4. Does every Renderer interaction return first to the Coordinator with current
   Provenance?
5. Is durable Journey intent established before consequential feature work is
   requested?
6. Can the feature accept or reject the request under its own authority?
7. Is request delivery being mistaken for acceptance, activity, or success?
8. Does operational evidence establish what actually happened?
9. Does reconciliation precede any resulting Journey transition?
10. Are validation authorities kept distinct?
11. Can restart recover from durable Journey truth and current feature facts?
12. Does a feature failure publish evidence rather than choose interaction?
13. Does a Moment remain a proposal until Presence admits it?
14. Could the feature remain operationally correct while Presence is absent?
15. Could another feature satisfy the same Presence contract without changing
    canonical Presence architecture?
