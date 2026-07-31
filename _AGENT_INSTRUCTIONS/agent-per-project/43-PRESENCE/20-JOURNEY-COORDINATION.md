# Presence Journey Coordination

## Status

This document is the canonical architecture for coordinating Presence
Journeys.

It defines how durable Journeys advance through truthful state. It does not
define Episode protocols, feature operations, rendering, or persistence
technology.

## Definition

A Journey is the durable authority for one user-relevant undertaking.

The Journey owns interaction continuity across:

- Episodes;
- operational work;
- user decisions;
- external dependencies;
- interruption;
- application termination;
- restart;
- completion.

A Journey does not perform the undertaking. Feature operations own operational
work and publish facts about it.

A Journey is durable truth about:

- why the undertaking exists;
- where it stands semantically;
- which decisions have been accepted;
- which operational or external facts it currently depends upon;
- whether it is ongoing or terminal;
- whether it owns foreground Presence.

A Journey is not the source of feature-operational truth. It references and
reconciles feature-owned facts without duplicating their internal authority.

### Journey Identity

Every Journey has one stable identity for one logical undertaking.

That identity:

- survives interruption and restart;
- is shared by every Episode derived for the undertaking;
- distinguishes simultaneous or repeated undertakings;
- is never reused after completion, failure, abandonment, or archival.

Starting another archive import creates another Journey even when its purpose
and presentation resemble an earlier import.

### Journey Authority

Journey state is authoritative for Presence coordination.

It determines:

- the current semantic position;
- which completion evidence is relevant;
- which user decisions have been accepted;
- which Episode can presently be derived;
- whether the Journey owns foreground Presence;
- whether the undertaking is terminal.

Feature operations remain authoritative for whether work has started, is
progressing, has stopped, or has completed.

Presence therefore derives interaction from two compatible authorities:

```text
durable Journey truth
    +
current feature-owned facts
    ->
truthful Episode
```

### Relationship to Episodes

An Episode is the current interaction derived from Journey truth and current
feature facts.

A Journey may produce many Episodes over time. It does not store rendered
Episodes as durable meaning.

The logical occurrence represented by an Episode remains stable while the same
interaction obligation remains current. Updated progress or explanatory facts
do not by themselves create a new occurrence.

When Journey truth changes such that a different interaction protocol or
completion authority applies, the Coordinator derives a new Episode.

### Relationship to Feature Operations

A feature operation performs work and publishes facts.

A Journey may reference an operation and record the semantic consequences of
its evidence. It does not absorb the operation's implementation, checkpoint
format, business rules, or progress calculations.

Operations never know which Episode is active.

### Relationship to Moments

Moments are transient content subordinate to a suitable Active Episode.

They are never Journey state and cannot:

- request a transition;
- authorize a transition;
- affect foreground ownership;
- survive restart as coordination truth;
- alter operational work.

## Durable Journey State

A Journey owns the minimum durable semantic state required to reconstruct its
coordination after interruption.

That state includes:

- stable Journey identity;
- owning feature or undertaking kind;
- originating user intent;
- canonical lifecycle;
- current semantic position;
- transition revision or logical occurrence;
- accepted user decisions;
- references to feature-owned operations;
- references to awaited conditions;
- pending durable command intent;
- foreground or postponed disposition;
- attention requirements;
- terminal outcome when established.

The Journey may retain references to evidence needed for explanation or audit.
It does not duplicate feature-owned operational state merely to make Presence
self-contained.

The following are never durable Journey state:

- rendered UI;
- widgets or screens;
- animation state;
- Moments;
- progress displays;
- previously rendered Episodes;
- inferred completion based on elapsed time;
- unaccepted user responses;
- an operation command treated as if it had succeeded.

An implementation may preserve additional information for accessibility,
history, or diagnostics, but such information does not become Journey authority
unless the canonical Journey contract assigns it semantic meaning.

## Lifecycle

The canonical Journey lifecycle is:

### Created

The undertaking has a durable identity and originating intent, but has not yet
entered ongoing coordination.

Creation precedes presentation and any externally consequential work requested
for that Journey.

### Ongoing

The undertaking has begun and remains nonterminal.

An ongoing Journey may currently involve:

- information;
- a question;
- active work;
- an awaited condition;
- interruption;
- recoverable failure;
- postponement.

These are semantic positions and Episode concerns within an ongoing Journey.
They are not additional lifecycle states.

### Completed

Authoritative evidence establishes that the intended undertaking succeeded.

Completion is terminal. A completion-purpose `Inform` may communicate the
outcome, but presentation does not create the completed state.

### Failed

Feature-owned evidence establishes that the undertaking cannot continue or
recover within its contract.

Failure is terminal. A failure summary may still need foreground Presence, but
the underlying Journey no longer returns to Ongoing.

### Abandoned

The user has durably relinquished the undertaking and any required feature
safety or cleanup conditions have been satisfied.

Abandonment is terminal. A request to cancel work is not abandonment until the
Journey can truthfully establish this state.

### Archived

A terminal Journey has been removed from active coordination and retained
according to the applicable history policy.

Archival does not reactivate, retry, or erase the undertaking's feature-owned
results. A similar future undertaking receives a new Journey identity.

### Lifecycle and Foreground Ownership

Lifecycle and foreground ownership are independent.

Use these terms consistently:

- **Ongoing Journey**: a nonterminal undertaking;
- **Foreground Journey**: the Journey currently owning Presence;
- **Active Episode**: the one Episode currently presented for that Foreground
  Journey;
- **Active feature operation**: feature-owned work currently executing.

Avoid the phrase "active Journey" because it does not distinguish ongoing
coordination, foreground ownership, and operational activity.

## Foreground Presence

Only one Journey owns foreground Presence.

Only the Foreground Journey has an Active Episode.

Multiple Journeys may remain Ongoing. Multiple feature operations may exist
when feature and application safety policy permits. Operational concurrency
does not grant foreground ownership.

When Presence is engaged, exactly one Journey is Foreground. When no Journey
requires Presence, there is no Foreground Journey and no Active Episode.

Foreground ownership is durable whenever continuity across restart requires
the user to return to the same undertaking.

Postponing a Journey releases foreground ownership without changing its
lifecycle or implying that its feature operation stopped.

### Activation Occurrence

When the Coordinator activates an Episode for the Foreground Journey, it
issues a new activation occurrence.

Episode identity represents the logical interaction obligation and may remain
stable across progress updates, reconstruction, and restart. Activation
occurrence represents one grant of foreground rendering authority. It changes
when:

- the Active Episode is replaced;
- foreground ownership changes;
- a Journey later regains foreground Presence;
- restart reconciliation permits rendering again.

Episode identity may survive restart. Activation authority does not.

## Foreground Arbitration

A background Journey may develop a need for user attention. It does not seize
Presence.

Instead:

1. the attention requirement becomes Journey truth;
2. foreground arbitration considers the current user intent, existing
   Foreground Journey, urgency, and applicable safety policy;
3. the Journey Coordinator determines whether and when foreground ownership
   changes;
4. only then is an Episode activated for the newly Foreground Journey.

Features may request attention by publishing facts through their approved
contract. They may not:

- replace the Foreground Journey;
- render over the Active Episode;
- invent priority outside the arbitration policy;
- interrupt the user because an operation completed.

Background completion therefore remains durable and discoverable without
automatically becoming an interruption.

## Journey Transitions

A Journey transition is an atomic, evidence-authorized change from one valid
durable Journey state to another.

It may change:

- semantic position;
- accepted user decisions;
- pending command intent;
- referenced operation or condition;
- foreground disposition;
- lifecycle;
- terminal outcome.

### Transition Requests

A transition may be requested because of:

- a typed user response;
- user acknowledgement;
- feature-published operational evidence;
- an observed external condition;
- restart reconciliation;
- a Journey-level control;
- declared Coordinator policy.

A request is not authority. It presents candidate evidence or intent for
validation.

Every interaction crossing from the Renderer to the Coordinator carries
Provenance:

- Journey identity;
- Journey revision;
- Episode identity;
- activation occurrence;
- interaction occurrence.

Interaction occurrence identifies one semantic interaction and allows
duplicate delivery to be rejected. For `Ask<T>`, it is the submission
occurrence to which validation feedback refers.

### Transition Authorization

Only the Journey Coordinator commits Journey transitions.

The Coordinator authorizes a transition by applying the Journey contract to:

- current durable Journey state;
- the expected logical occurrence or revision;
- current Provenance for a Renderer-originated interaction;
- the declared Episode completion authority;
- current feature-owned facts;
- the candidate evidence or user intent.

This does not make the Coordinator the owner of feature-domain truth.
Feature-owned evidence and validation remain authoritative within their domain.

### Required Evidence

Evidence must:

- come from the authority declared by the current Episode protocol;
- refer to the correct Journey identity;
- carry the current Journey revision, Episode identity, and activation
  occurrence when it originated from the Renderer;
- identify an interaction occurrence that has not already been accepted;
- remain compatible with the current semantic position;
- apply to the expected logical occurrence;
- satisfy feature-owned validity constraints;
- be current enough for the proposed transition.

User assertions never replace independently observable evidence.

### Obsolete Evidence

Evidence that belongs to an earlier Journey position, Episode occurrence,
activation occurrence, operation attempt, or Journey identity is rejected.

Obsolete evidence cannot:

- advance the Journey;
- recreate a prior Episode;
- overwrite a later user decision;
- complete a replacement operation.

### Atomicity

A Journey transition is atomic when either:

- the complete new Journey state becomes authoritative; or
- the complete previous Journey state remains authoritative.

There is no valid state in which half of a semantic transition has committed.

Accepted user decisions, semantic position, and the transition revision must
not disagree about which occurrence is current.

### Failed Transitions

If validation or commitment fails:

- the previous durable state remains authoritative; or
- a separate, explicit transition establishes a truthful recoverable or
  terminal state.

The Coordinator never repairs a partial transition by inferring what probably
happened from rendered UI.

### External Side Effects

External side effects are not part of the atomic Journey transition.

The governing sequence is:

```text
durable Journey intent
    -> feature request
    -> feature acceptance or rejection
    -> feature evidence
    -> Journey reconciliation
```

Durable intent precedes externally consequential work. Feature evidence later
establishes what actually occurred.

## Journey Coordinator Responsibilities

The Journey Coordinator is responsible for:

- loading and interpreting durable Journey state;
- obtaining current facts through feature-owned contracts;
- deriving the truthful Episode;
- validating transition requests and evidence;
- committing atomic Journey transitions;
- reconciling pending commands and feature operations;
- reconciling awaited conditions;
- selecting and restoring foreground ownership;
- arbitrating attention requests;
- replacing obsolete Episodes;
- preserving continuity across interruption and restart;
- recognizing terminal state.

The Coordinator is not responsible for:

- rendering;
- constructing screens or controls;
- performing operational work;
- querying feature databases directly;
- implementing feature business rules;
- inventing progress;
- calculating feature-domain facts;
- deciding whether a feature operation is technically safe;
- interpreting UI state as evidence;
- storing widgets or rendered Episodes;
- allowing a feature to define a private interaction protocol.

The Coordinator coordinates authoritative facts. It does not manufacture them.

## Operations

Feature operations publish:

- stable operation identity;
- acceptance or rejection of requested work;
- status;
- liveness;
- phase;
- checkpoints;
- truthful progress basis;
- dependency changes;
- interruption facts;
- recoverability;
- outcomes;
- completion or failure evidence.

Feature operations never publish:

- Episodes;
- Episode families;
- semantic purposes;
- Presence copy;
- Moments;
- rendering;
- navigation;
- presentation;
- foreground ownership.

Operations never know which Episode is active.

An operation may continue while its Journey is not Foreground if feature and
application safety policy permit. Presence ownership is not execution
authority.

## Command and Reconciliation

Requesting work is not evidence that work has begun.

Issuing a command is not evidence that it succeeded.

The canonical command sequence is:

1. The Journey records durable intent.
2. The Coordinator issues the declared request through the feature contract.
3. The feature accepts or rejects the request.
4. The feature performs any accepted work and publishes evidence.
5. The Coordinator reconciles that evidence with current Journey truth.
6. Presence derives the appropriate Episode.

If MessageLens terminates between any two steps, restart reconciliation resumes
from durable Journey intent and feature truth.

The Coordinator must not:

- issue an irreversible request before durable intent exists;
- infer acceptance because no rejection arrived;
- infer success because a command returned;
- mark work active before feature evidence says it is active;
- mark work complete before feature evidence says it is complete.

Repeated request delivery must not create semantic duplication. Feature request
and operation identity must allow reconciliation to distinguish one logical
attempt from another without relying on presentation state.

## Restart Reconciliation

Restart is an ordinary Journey condition, not an exceptional recovery path.

On restart, the Journey Coordinator:

1. loads durable Journeys;
2. restores terminal and Ongoing lifecycle truth;
3. obtains current facts from feature-owned authorities;
4. reconciles pending requests and their acceptance or rejection;
5. reconciles active, interrupted, completed, and failed operations;
6. re-evaluates awaited external conditions;
7. commits any transitions already justified by current evidence;
8. resolves foreground ownership;
9. derives the one truthful Active Episode;
10. issues a new activation occurrence;
11. permits rendering from that derivation.

Rendered UI, former widget state, animation, and previously displayed Episodes
are never consulted.

The same Episode identity may be re-derived when the logical interaction
obligation remains current. The previous activation occurrence is never
restored. Outputs from that earlier activation therefore cannot affect current
Journey truth.

Consequently:

- permission granted while MessageLens was closed advances the Journey without
  replaying an obsolete `Await`;
- completed work is not shown as still running;
- interrupted work is not shown as complete;
- an unaccepted user response is not restored as truth;
- an obsolete Episode cannot reappear merely because it was last visible.

## Journey Controls

Journey controls express user intent about the undertaking. They are not
Episode-family results by default.

### Cancel

Cancel requests that applicable feature work stop.

The feature owns whether cancellation is supported, safe, accepted, and
complete. Requesting cancellation does not establish that work stopped and
does not by itself abandon the Journey.

### Postpone

Postpone releases foreground Presence while preserving the Journey's durable
position.

It does not imply:

- operation cancellation;
- operation pause;
- failure;
- abandonment.

### Retry

Retry requests a new attempt permitted by feature-owned recovery semantics.

The Journey records durable retry intent. The feature establishes whether the
request is accepted and publishes evidence for the new attempt. Evidence from
the earlier attempt cannot complete the new one.

### Resume

Resume requests continuation of feature work or Journey coordination.

The feature determines whether operational resumption is supported and
publishes evidence when work is active. Presence derives `Work` only after that
evidence exists.

### Abandon

Abandon expresses that the user no longer wishes to pursue the undertaking.

The Journey becomes Abandoned only after any required safety, cancellation, or
cleanup conditions are satisfied. A Journey cannot use abandonment to conceal
work whose operational disposition remains unknown.

### Pause

Pause is not a universal Journey control.

Where a feature supports pausing, it is a feature-operation capability. The
Journey records the confirmed coordination consequence and derives an
appropriate Episode from the resulting facts.

## Failure and Recovery

### Recoverable Interruption

A recoverable interruption means current work stopped or lost continuity but
the undertaking remains viable.

The Journey normally remains Ongoing. Current facts may derive:

- `Work` while automatic recovery is active;
- `Await` while an external condition is required;
- `Ask<T>` when a user-authored decision is required.

The interruption itself is feature truth. Its coordination consequence may
produce a Journey transition.

### Recoverable Failure

A recoverable failure means one attempt failed but the undertaking still has a
valid recovery path.

The Journey remains Ongoing. The feature owns:

- failure facts;
- available recovery;
- retry safety;
- candidate alternatives.

The Coordinator derives the canonical Episode whose completion authority
matches the required next step.

### Permanent Failure

A permanent failure is established only by feature-owned evidence that the
undertaking cannot continue or recover.

The Coordinator transitions the Journey to Failed. A subsequent `Inform` may
communicate the outcome but does not create it.

### Dependency Loss

Loss of an external dependency does not automatically fail the Journey.

The feature publishes the dependency fact. The Journey normally remains
Ongoing and derives `Await` when restoration of that dependency is the
truthful completion condition.

### User Abandonment

User abandonment is an intentional terminal Journey outcome.

It is not:

- feature failure;
- operation cancellation;
- application termination;
- loss of foreground Presence.

### Application Termination

Application termination causes no semantic transition by itself.

Durable Journey state and feature-owned facts determine the truthful state on
restart.

## Terminal State and Archival

Completed, Failed, and Abandoned are terminal lifecycle states.

A terminal Journey:

- cannot return to Ongoing;
- may retain foreground Presence long enough to communicate its outcome;
- may be archived after its remaining informational obligation is discharged;
- cannot be reused for another undertaking.

Archival is a coordination-retention decision. It does not delete or reinterpret
feature-owned results.

Historical presentation of an archived Journey is not Journey reactivation and
does not create an Active Episode.

## Architectural Invariants

Every Presence Journey implementation must preserve these invariants:

1. A Journey is durable authority for one user-relevant undertaking.
2. Journey identities are never reused.
3. Lifecycle and foreground ownership are independent.
4. Whenever Presence is engaged, exactly one Journey is Foreground.
5. Exactly one Episode is active.
6. Multiple Journeys may remain Ongoing.
7. Operational concurrency is governed by feature and application safety
   policy, not foreground Presence.
8. Episodes are derived from Journey truth and current feature facts.
9. Only the Journey Coordinator commits Journey transitions.
10. Every transition requires evidence from its declared authority.
11. Obsolete evidence cannot advance a Journey.
12. A transition either commits completely or leaves the prior state
    authoritative.
13. Durable intent precedes externally consequential work.
14. A request is not evidence of acceptance, activity, or success.
15. Operations publish facts, never Episodes.
16. Operations never know which Episode is active.
17. Rendered UI is never Journey truth.
18. Moments cannot affect coordination.
19. Restart reconciliation never consults previous presentation.
20. Obsolete Episodes disappear after reconciliation.
21. Every Coordinator-bound Renderer interaction carries Provenance.
22. Provenance contains Journey identity, Journey revision, Episode identity,
    activation occurrence, and interaction occurrence.
23. Interactions from obsolete activation occurrences cannot affect Journey
    truth.
24. An interaction occurrence may be accepted at most once.
25. Presentation Observations are never Journey evidence by themselves.
26. Terminal Journeys cannot return to Ongoing.
27. Features cannot seize foreground Presence.

## Relationship to Other Presence Documents

- [`00-PRESENCE.md`](00-PRESENCE.md) defines why Presence exists.
- [`Presence Episode Specification`](01-DESIGN-DOCUMENTS/presence-episode-specification.md)
  defines what an Episode is.
- [`10-EPISODE-MODEL.md`](10-EPISODE-MODEL.md) defines which interaction
  protocols exist.
- This document defines how Journeys advance through truthful state.
- [`30-RENDERING.md`](30-RENDERING.md) defines how Episodes become
  presentation.
- [`40-AMBIENT-MOMENTS.md`](40-AMBIENT-MOMENTS.md) defines transient content
  within suitable Episodes.
- [`50-FEATURE-INTEGRATION.md`](50-FEATURE-INTEGRATION.md) defines how features
  participate.

## Review Checklist

Before accepting Journey coordination behaviour, verify:

- Is this Journey truth or feature truth?
- Is the responsibility owned by the Journey, Coordinator, feature, operation,
  Episode, or Renderer?
- What evidence authorizes the transition?
- Does that evidence belong to the current Journey occurrence?
- Could the Journey be reconstructed after application restart?
- Is durable intent recorded before consequential work is requested?
- Is a request being mistaken for acceptance or success?
- Is the Coordinator deriving Episodes rather than receiving them?
- Is foreground ownership unambiguous?
- Can a background Journey request attention without seizing Presence?
- Is rendering completely replaceable?
- Could obsolete evidence or presentation revive an invalid Episode?
