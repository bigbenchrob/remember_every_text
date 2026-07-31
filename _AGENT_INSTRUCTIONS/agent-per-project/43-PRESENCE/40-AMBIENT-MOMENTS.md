# Presence Ambient Moments

## Status

This document is the canonical architecture for Presence Ambient Moments.

It defines what a Moment is and when Presence may admit one.

Presence purpose is defined by [`00-PRESENCE.md`](00-PRESENCE.md). Episode
semantics are defined by
[`presence-episode-specification.md`](01-DESIGN-DOCUMENTS/presence-episode-specification.md)
and [`10-EPISODE-MODEL.md`](10-EPISODE-MODEL.md). Journey coordination is
defined by [`20-JOURNEY-COORDINATION.md`](20-JOURNEY-COORDINATION.md), and the
terminal presentation boundary is defined by
[`30-RENDERING.md`](30-RENDERING.md).

Ambient Moments assume those authorities already exist. They do not redefine
them.

## Definition

A Moment is optional, transient, subordinate content that may enrich a
suitable Active Episode without changing its meaning, authority, or outcome.

A Moment may illuminate why the current work matters. It is never part of the
interaction protocol and never becomes evidence about the work.

## Why Moments Exist

MessageLens works with memories, conversations, relationships, and events from
a person's life. Some long-running work creates a truthful opportunity to
surface a meaningful discovery without distracting from the work itself.

Moments preserve that human context. They allow Presence to communicate that
the material being processed is more than a collection of records while the
Active Episode remains the one authoritative communication.

This purpose does not make Moments mandatory. A Moment exists only when it
adds relevant meaning without creating another task, competing for attention,
or weakening the truthfulness of the Active Episode.

## Moment Authority

Moment responsibility follows this chain:

```text
Feature
    proposes truthful, relevant Moment content

Presence
    determines semantic eligibility and admission

Rendering
    determines whether and how an admitted Moment is presented under
    Presentation Policy
```

Accordingly:

- Features propose Moments.
- Presence determines eligibility and admission.
- Rendering determines concrete presentation and may suppress an admitted
  Moment when presentation conditions require it.
- Moments never determine Journey truth.
- Moments never alter the Active Episode.
- Moments never create, authorize, or request Journey transitions.
- Moments never generate Coordinator events.
- Moments never become operational evidence, progress evidence, liveness
  evidence, validation, or completion evidence.

No participant acquires another participant's authority merely because it
handles Moment content.

## Relationship to Journey

A Moment is not Journey state.

It cannot:

- become part of durable Journey truth;
- affect Journey lifecycle or foreground ownership;
- establish the current Journey position;
- create a current obligation;
- authorize or prevent a transition;
- survive restart as coordination truth.

A Moment proposal associated with a background Journey cannot appear within
the Foreground Journey. It may be reconsidered only if its own Journey later
becomes Foreground, its associated Episode context is again suitable, and the
proposal remains truthful and current.

Changing, suppressing, withdrawing, or omitting a Moment has no effect on the
Journey.

## Relationship to Episode

A Moment exists only in relation to one suitable Active Episode.

The Active Episode remains responsible for:

- semantic purpose;
- primary communication;
- current user responsibility;
- Completion Authority;
- permitted interactions and controls.

The Moment remains subordinate to all of them.

A Moment cannot:

- change the Episode family or purpose;
- add another user responsibility;
- add a response or control;
- become supporting explanation required to understand the Episode;
- change Completion Authority;
- complete or replace the Episode.

Episode replacement ends the current admission. A Moment associated with the
obsolete Episode is withdrawn immediately and cannot remain visible as if its
context were still current.

## Relationship to Renderer

The Renderer receives only Moments already admitted for the current Active
Episode and context.

The Renderer:

- preserves Moment subordination;
- applies Presentation Policy;
- determines concrete presentation;
- may suppress an admitted Moment when presentation would compete with the
  Active Episode;
- withdraws a Moment when its admission is no longer current.

The Renderer cannot:

- make an ineligible Moment eligible;
- promote a Moment into primary or required communication;
- turn a Moment into an interaction;
- emit a Coordinator-bound output from a Moment;
- use presentation behaviour as evidence that the Moment affected the user.

The Renderer remains completely truthful when no Moment is presented.

## Relationship to Presentation Policy

Presentation Policy governs the treatment of an already-admitted Moment.

It preserves:

- one meaningful thing at a time;
- the authority of the Active Episode;
- the distinction between primary, supporting, and ambient content;
- privacy and sensitivity boundaries;
- accessibility obligations;
- restraint in attention, cadence, and repetition;
- immediate withdrawal when context changes.

Presentation Policy may suppress an admitted Moment. It cannot make an
ineligible proposal eligible, expand the proposal's meaning, or grant it
semantic authority.

## Relationship to Features

Features own the facts and domain meaning from which Moment content may be
prepared.

A feature is responsible for proposing content that is:

- factually supported;
- relevant to the current work;
- accurately represented;
- accompanied by sufficient context to assess freshness, privacy, and
  sensitivity;
- withdrawn when its factual basis is no longer current.

A feature does not decide final eligibility, admission, presentation, or
foreground ownership. It cannot use a Moment to bypass the Episode contract or
communicate required operational information ambiently.

Presence does not reinterpret feature facts. It decides whether the proposed
content may lawfully coexist with the current Active Episode.

The contract through which features propose content is defined by
[`50-FEATURE-INTEGRATION.md`](50-FEATURE-INTEGRATION.md).

## Eligibility

Moment eligibility is semantic, not visual.

A proposal is eligible only when all of the following are true:

1. Its factual basis remains truthful and current.
2. Its relevance to the current Foreground Journey is established.
3. It is compatible with the current Active Episode family and purpose.
4. It does not compete with the user's current responsibility.
5. It does not compete with a required interaction, decision, explanation, or
   recovery action.
6. It remains optional and can disappear without changing comprehension or
   completion.
7. Its privacy and sensitivity are appropriate to the current context.
8. It can be presented accessibly without displacing authoritative
   communication.
9. Its admission remains timely and nonrepetitive.
10. It requires no interaction and produces no Coordinator output.

Visual room does not establish eligibility. A large surface does not make an
inappropriate Moment admissible, and a compact surface does not make a Moment
semantically invalid. Concrete presentation conditions may still require an
eligible Moment to be suppressed.

### Episode-Family Compatibility

Episode family informs eligibility because each family establishes a different
interaction priority.

#### Inform

A Moment may accompany an `Inform` only when it remains clearly subordinate to
the primary message and does not dilute required acknowledgement, important
explanation, completion, or failure communication.

#### Ask<T>

A Moment is suppressed while the user is answering an `Ask<T>`.

The question and its typed response contract own the user's attention. Ambient
content must not influence, distract from, or appear to qualify the requested
decision.

#### Work

`Work` commonly provides a suitable context for Moments when truthful work
evidence remains primary and no action or problem requires attention.

A Moment cannot substitute for progress, imply liveness, or make waiting appear
safer or more successful than feature facts establish.

#### Await

A Moment may accompany an `Await` only when it does not obscure the awaited
condition, the user's available actions, or recovery guidance.

An `Await` involving a problem, required intervention, or sensitive condition
normally excludes Moments.

## Admission

Eligibility establishes that a Moment may lawfully coexist with the current
Active Episode. Admission establishes that Presence has made that eligible
Moment available for current presentation.

Admission:

- is limited to the current Foreground Journey and Active Episode;
- preserves the Moment's feature provenance and contextual limits;
- grants no Journey, Episode, feature, or Renderer authority;
- may end without changing any durable state;
- does not guarantee presentation.

Rendering may suppress an admitted Moment under Presentation Policy. That
suppression does not retroactively make the proposal ineligible.

## Suppression

Suppression means that an otherwise eligible and admitted Moment is not
presented because current presentation conditions give authoritative
communication priority.

Moments are suppressed during:

- an `Ask<T>` or another required user decision;
- validation feedback requiring correction;
- failure communication;
- recoverable problems;
- urgent explanations;
- required instructions or actions;
- foreground ownership changes;
- Episode replacement;
- accessibility conditions in which ambient content would interrupt or
  confuse authoritative communication;
- any context in which one meaningful thing at a time would be violated.

Suppression is temporary and does not imply deletion. A proposal may remain
available for later eligibility and admission while its factual basis,
relevance, privacy, and validity remain current.

During foreground change or Episode replacement, presentation is suppressed
immediately and the prior admission is then withdrawn. Suppression never
extends a Moment beyond the Journey and Episode context that made it eligible.

Suppression also does not guarantee later presentation. The proposal may
expire, lose relevance, or become incompatible before another opportunity
arises.

## Lifecycle

The canonical Moment lifecycle is:

```text
proposal
    -> eligibility
    -> admission
    -> presentation or suppression
    -> withdrawal
    -> expiration
    -> possible future re-admission after fresh eligibility evaluation
```

### Proposal

The feature owns the proposed content, its factual basis, its domain meaning,
and its continuing relevance.

Proposal creates no obligation for Presence to admit or present the content.

### Eligibility

Presence evaluates the proposal against the current Foreground Journey, Active
Episode, user responsibility, privacy, sensitivity, accessibility, relevance,
and attention priority.

### Admission

Presence admits an eligible Moment into the current Episode context without
changing the Episode or Journey.

### Presentation

Rendering may present the admitted Moment under Presentation Policy. Concrete
presentation does not change the Moment's meaning or authority.

### Withdrawal

An admitted or presented Moment is withdrawn when its current context ends or
its continued presence is no longer truthful. Withdrawal includes Episode
replacement, foreground change, loss of eligibility, or feature withdrawal of
the proposal.

Withdrawal does not create a Coordinator event.

### Expiration

A proposal expires when its factual, contextual, privacy, relevance, or
freshness conditions no longer permit admission.

Expired content is not eligible merely because it was previously presented.

### Possible Future Re-admission

Prior eligibility or presentation never grants continuing authority. Future
admission requires a fresh eligibility decision against the then-current
Journey, Episode, feature facts, and presentation context.

## Suitable Content

Suitable Moments illuminate the human meaning or context of work already in
progress.

Examples include:

- a meaningful memory discovered in the material being processed;
- an emotionally significant exchange;
- historical context that gives a relationship or conversation perspective;
- an interesting observation grounded in feature-owned facts;
- reassuring context that does not claim progress, safety, success, or
  completion.

Suitable content remains truthful, contextual, concise, optional, and
noninteractive.

## Unsuitable Content

The following are never Moments:

- operational evidence;
- progress or liveness claims;
- warnings, failures, or recovery conditions;
- required instructions;
- validation or correction feedback;
- user choices or requests for input;
- controls or actions;
- facts required to understand the Active Episode;
- claims that work is safe, successful, or complete;
- unrelated novelty or decorative content;
- content selected primarily to capture attention.

If information could change what the user must understand, decide, or do, it
belongs in the Active Episode or feature-owned facts rather than in a Moment.

## Privacy and Sensitivity

Privacy is a canonical condition of eligibility.

A Moment must:

- respect the user's reasonable expectations for the current work;
- remain within the context that made its content relevant;
- avoid exposing personal material merely because it is available;
- preserve sensitivity supplied by the owning feature;
- yield whenever the current presentation context makes disclosure
  inappropriate;
- remain optional and easy for Presence to omit;
- never use intimate or emotionally significant content to demand attention.

Feature relevance is not sufficient by itself. Presence must withhold content
when privacy, sensitivity, or presentation context makes admission
inappropriate.

Rendering cannot broaden an admitted Moment's disclosure beyond the context
approved by Presence.

## Accessibility

Accessibility can constrain both admission and presentation.

For screen-reader presentation, a Moment must not repeatedly interrupt
authoritative status, required instructions, questions, validation, or
progress communication. Presence may suppress it rather than disturb the
semantic reading order.

Under reduced-motion preferences, a Moment remains optional and must not rely
on motion for meaning. Presence may present it without motion, present fewer
Moments, or omit it entirely.

Compact and nonvisual Renderers may omit Moments whenever ambient content
would compete with the Active Episode or cannot remain clearly subordinate.

Omission preserves complete semantic correctness because no required meaning,
interaction, evidence, or transition depends on a Moment.

## Replaceability

Moments are removable by design.

Removing every Moment from a Journey must leave:

- Journey truth unchanged;
- the same Active Episode derivable;
- every user responsibility intact;
- every required fact and explanation available;
- every permitted interaction unchanged;
- every transition and Completion Authority unchanged;
- all operational work correct;
- restart reconciliation correct.

This is the defining replaceability test for Moment content.

A Presence client may lawfully define no Moments. Presence remains complete
and correct.

## MessageLens Examples

### Meaningful Memory During Work

While archive ingestion truthfully continues under a `Work` Episode, a feature
may propose:

> The baby was born...

The content may be eligible when it is grounded in the material being
processed, privacy permits it, and no decision or problem requires attention.
It adds human meaning without becoming evidence that ingestion is active or
progressing.

### Emotionally Significant Discovery

A feature may propose:

> Congratulations, Dr. Campbell...

Presence admits it only when the current Episode and sensitivity context make
the discovery appropriate. The Moment does not become a claim about the
current operation or a prompt for response.

### Historical Context

A feature may propose:

> This conversation began in 2011.

This may provide historical perspective while remaining subordinate to the
Active Episode. If the fact is required to explain the operation, it is not a
Moment and belongs in authoritative Episode content instead.

### Suppressed During Ask<T>

Suppose Presence is asking the user to choose which archive source is correct.
Even if a meaningful memory is eligible in the wider Journey, it is suppressed
while the `Ask<T>` is active. The decision owns the user's attention, and the
Moment must not influence or compete with it.

### Air Traffic Control

An Air Traffic Control Presence client may define no Moments.

Weather, traffic, runway, and safety information can affect operational
decisions. They are authoritative information, not ambient enrichment. A
nonessential courtesy does not justify inventing a Moment category where the
domain has no meaningful need for one.

The absence of Moments leaves the ATC Journey entirely complete and truthful.

## Architectural Invariants

1. Moments are optional, transient, and subordinate.
2. Moments never become Journey truth.
3. Moments never alter the Active Episode.
4. Moments never create, authorize, request, or prevent Journey transitions.
5. Moments never complete Episodes or Journeys.
6. Moments never produce Coordinator events.
7. Moments never become operational, progress, liveness, validation, or
   completion evidence.
8. Features propose Moments; they do not decide admission or presentation.
9. Presence determines semantic eligibility and admission.
10. Rendering determines concrete presentation and may suppress admitted
    Moments under Presentation Policy.
11. Rendering cannot make an ineligible Moment eligible.
12. Eligibility is semantic, not visual.
13. A Moment is eligible only in relation to the current Foreground Journey and
    a suitable Active Episode.
14. A Moment cannot add user responsibility, interaction, or control.
15. A Moment cannot contain information required to understand or complete the
    Active Episode.
16. `Ask<T>`, required decisions, failures, urgent explanations, and recovery
    actions take priority over Moments.
17. Suppression is not deletion and grants no right to later presentation.
18. Episode replacement and foreground change withdraw current Moment
    admission.
19. Previous admission never bypasses fresh eligibility evaluation.
20. Privacy and sensitivity are canonical eligibility conditions.
21. Accessibility may require suppression or omission without semantic loss.
22. Presentation of a Moment never establishes that it was read, heard,
    understood, or valued.
23. Moment content cannot cross Journey or Episode context merely because it
    remains available.
24. Removing every Moment leaves the Journey completely correct.
25. Presence clients may legitimately define no Moments.

## Relationship to Other Presence Documents

- [`00-PRESENCE.md`](00-PRESENCE.md) defines why Presence exists and introduces
  Moments as gentle insight into meaningful work.
- [`presence-episode-specification.md`](01-DESIGN-DOCUMENTS/presence-episode-specification.md)
  defines the general Episode contract and Moment subordination.
- [`10-EPISODE-MODEL.md`](10-EPISODE-MODEL.md) defines the canonical
  interaction protocols to which Moments remain subordinate.
- [`20-JOURNEY-COORDINATION.md`](20-JOURNEY-COORDINATION.md) defines Journey
  truth, foreground ownership, and transitions that Moments cannot affect.
- [`30-RENDERING.md`](30-RENDERING.md) defines how admitted Moments may be
  presented while preserving Episode authority.
- This document defines Moment purpose, authority, eligibility, admission,
  suppression, lifecycle, privacy, accessibility, and replaceability.
- [`50-FEATURE-INTEGRATION.md`](50-FEATURE-INTEGRATION.md) defines the contract
  by which features propose Moment content and supply the facts needed to
  evaluate it.

## Review Checklist

Before accepting Moment behaviour, verify:

1. Is the content genuinely optional and subordinate?
2. Does the feature own its factual basis and domain meaning?
3. Is eligibility decided by Presence rather than appearance or available
   space?
4. Is the content compatible with the Active Episode family and user
   responsibility?
5. Could it influence a decision, obscure a problem, or compete with required
   explanation?
6. Are privacy and sensitivity appropriate to the current context?
7. Can accessibility preserve hierarchy, or must the Moment be suppressed?
8. Can the Moment disappear without changing Episode comprehension or
   completion?
9. Can it produce any interaction, evidence, or Coordinator event?
10. Does replacement or foreground change withdraw it immediately?
11. Would the entire Journey remain correct if every Moment were removed?
