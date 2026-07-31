# Presence Journey Coordination Design Analysis

## Recommended Canonical Model

A Journey is the durable record of one user-relevant undertaking. It owns
interaction continuity, not the feature operation itself.

Its durable truth should contain:

- stable Journey identity and feature ownership;
- the user intent that created it;
- lifecycle and current semantic position;
- transition revision or logical occurrence;
- accepted user decisions;
- references to relevant operations and awaited conditions;
- terminal outcome;
- foreground or postponement disposition.

Feature-owned operation checkpoints remain feature truth. Journey state
references and interprets them; it does not duplicate their internals.

Transient observations include rendered UI, Moments, animation, sampled
progress, uncommitted input, and the previously displayed Episode.

## Lifecycle

| Stage | Meaning |
| --- | --- |
| **Created** | Durable undertaking exists before presentation or operational work begins. |
| **Ongoing** | Journey has begun and remains nonterminal. Work, questions, and waiting are positions within this lifecycle, not lifecycle states themselves. |
| **Completed** | Intended outcome is durably established. |
| **Failed** | Feature evidence establishes that the undertaking cannot continue or recover. |
| **Abandoned** | User has durably relinquished the undertaking after required operational safety conditions are satisfied. |
| **Archived** | Terminal Journey is removed from active coordination but retained according to history policy. |

Activation is separate from lifecycle: it means the Journey currently owns
foreground Presence.

Interruption and application termination are not automatically lifecycle
transitions. They become meaningful only if durable facts change.

## Transition Protocol

A Journey transition is an atomic, evidence-authorized change from one valid
durable Journey state to another.

- Requests may originate from typed user responses, feature facts, observed
  external conditions, application reconciliation, or declared Coordinator
  policy.
- Authorization belongs to the Journey Coordinator, applying the Journey
  contract to current state and feature-owned evidence.
- Evidence must match the current logical Journey occurrence, expected prior
  state, and Episode completion authority.
- Atomicity means either the complete new Journey state is committed or the old
  state remains authoritative.
- External side effects are not part of that atomic boundary. Durable intent
  precedes them; feature evidence later confirms their result.
- Failed transitions leave the prior state intact or establish an explicit
  recoverable state. They never leave an implicitly half-advanced Journey.

This is the Mechanical Impossibility Principle applied to coordination: stale
responses and obsolete operational events cannot advance a different Journey
occurrence.

## Coordinator Boundary

The Coordinator owns:

- deriving the Active Episode from Journey state and feature facts;
- validating evidence against the current transition;
- committing Journey transitions;
- restart reconciliation;
- foreground Presence ownership;
- replacement of obsolete Episodes.

It must never:

- perform operational work;
- directly determine feature-domain truth;
- render;
- infer facts from widgets;
- manufacture progress;
- make unsafe feature decisions;
- treat commands as evidence of their success.

Features define domain meaning, validation, commands, and facts. The
Coordinator governs how those facts advance the Journey.

## Concurrent Journeys

Multiple Journeys may exist and remain ongoing.

Only one Journey may be the Foreground Journey, so only one Episode is the
Active Episode application-wide. Other Journeys may continue feature-owned
operations if their safety rules permit, but they do not have an active
rendered Episode.

Foreground ownership is separate from operational activity:

- background completion does not automatically interrupt the user;
- features may request attention but cannot seize Presence;
- postponing a Journey releases foreground ownership without falsifying its
  lifecycle;
- foreground selection must survive restart if continuity requires it.

## Episode Identity

Episode identity represents one logical interaction obligation within one
Journey occurrence.

- Progress updates reconstruct the same `Work` Episode.
- Restart reconstructs the same Episode when the obligation remains current.
- Similar content encountered after a completed transition receives a new
  identity.
- Recurring semantic purposes are separate occurrences.
- Historical replay is read-only history, not Episode reactivation.
- A change in completion authority normally implies a new Episode.

## Provenance and Activation

Every interaction crossing from the Renderer to the Coordinator carries
Provenance:

- Journey identity;
- Journey revision;
- Episode identity;
- activation occurrence;
- interaction occurrence.

Episode identity represents the logical interaction obligation. Activation
occurrence represents one grant of foreground rendering authority. It changes
when the Active Episode is replaced, foreground ownership changes, a Journey
later regains foreground Presence, or restart reconciliation permits rendering
again.

Interaction occurrence identifies one semantic interaction and permits
duplicate rejection. For `Ask<T>`, validation feedback refers to the
originating interaction occurrence.

The Coordinator accepts an interaction only while all Provenance remains
current and the interaction is declared by the Active Episode.

## Restart Reconciliation

On restart, the Coordinator:

1. loads durable Journeys;
2. obtains current facts from feature-owned authorities;
3. reconciles pending commands, operations, and awaited conditions;
4. commits any transitions already justified by current truth;
5. selects the Foreground Journey;
6. derives its truthful Active Episode;
7. issues a new activation occurrence;
8. allows rendering only after derivation.

Previously rendered UI is never consulted. If Full Disk Access was granted
while MessageLens was closed, the obsolete `Await` cannot reappear.

The same Episode identity may remain truthful after restart. Its former
activation occurrence never does, so interactions from the previous rendering
authority cannot affect current Journey truth.

## Journey Controls

| Control | Ownership |
| --- | --- |
| **Cancel** | Journey-level request; feature determines whether active work can safely stop. |
| **Postpone** | Journey-level foreground decision; releases Presence without implying operational cancellation. |
| **Retry** | Journey transition using feature-owned retry semantics and fresh evidence. |
| **Pause** | Feature-operation capability; Journey records only the confirmed coordination consequence. |
| **Resume** | Journey request routed to the feature; `Work` follows only after active-operation evidence. |
| **Abandon** | Terminal Journey decision after required safety and cleanup conditions are established. |

These controls may be presented through Episodes, but they are not
Episode-family completion results by default.

## Operations and Failure

Operations publish identity, status, phase, liveness, truthful progress basis,
checkpoints, outcomes, recoverability, and dependency facts. They never
publish Episodes, semantic purposes, copy, or layout, and never need to know
which Episode is active.

- A recoverable interruption leaves the Journey ongoing. Current facts derive
  `Work`, `Await`, or `Ask<T>`.
- A recoverable failure is described by feature-owned failure facts and
  available recovery. The Coordinator derives the corresponding protocol.
- A permanent failure establishes a durably failed Journey, followed by a
  truthful `Inform`.
- External dependency loss leaves the Journey ongoing and normally derives
  `Await`.
- User abandonment is a terminal Journey transition, not an operational error.
- Application termination causes no semantic transition by itself.

## Pressure Test

| Scenario | Journey state and Coordinator action | Episode and completion authority | Durable truth |
| --- | --- | --- | --- |
| First launch | Create and foreground onboarding Journey | `Inform / welcome`; acknowledgement | Onboarding created, welcome pending |
| Full Disk Access explanation | Advance to permission rationale | `Inform / explanation`; acknowledgement | Explanation obligation |
| Quit before granting access | No transition caused by quitting | No active UI while closed | Awaiting permission |
| Permission granted while closed | Reconcile observed permission on restart | Skip obsolete `Await`; observed condition | Permission satisfied |
| Return next day without permission | Re-derive same obligation | Same `Await`; permission observation | Same Journey occurrence |
| Import interrupted halfway | Reconcile checkpoint and operation status | `Work` if resuming; otherwise truthful `Await` | Import identity and checkpoint |
| Drive disconnected | Record dependency consequence | `Await / recoverableCondition`; drive observation | Missing dependency and resume point |
| Drive reconnected | Atomically advance after observation | `Work`; operational evidence | Dependency restored |
| Import completes | Commit authoritative outcome | `Inform / completion`; Journey outcome | Terminal completed Journey |
| Completion acknowledged | Release foreground Presence | No domain result | Completion already terminal |
| Start another import | Create a new Journey identity | Newly derived Episode | Prior Journey remains historical |

## Strongest Invariants

- Exactly one Journey is the Foreground Journey.
- Exactly one Episode is the Active Episode.
- Only the Coordinator commits Journey transitions.
- Every transition requires evidence from its declared authority.
- Durable intent exists before externally consequential work is requested.
- External effects are reconciled; they are never assumed.
- Operations publish facts, never Episodes.
- Rendered UI is never Journey truth.
- Obsolete Episodes cannot survive reconciliation.
- Every Coordinator-bound Renderer interaction carries Provenance.
- Episode identity may survive restart, but activation authority does not.
- An obsolete activation occurrence cannot affect Journey truth.
- An interaction occurrence may be accepted at most once.
- Terminal Journey identities are never reused for a new undertaking.

## Deferred Policy Questions

The canonical coordination architecture is established in
[`20-JOURNEY-COORDINATION.md`](../20-JOURNEY-COORDINATION.md). It intentionally
leaves these policy questions for later decisions:

1. Foreground arbitration when a background Journey needs urgent user
   attention.
2. Whether postponed Journey selection must always be durable.
3. Retention and archival policy for terminal Journeys.
4. The exact contract for operation-request acceptance and reconciliation.
5. Whether terminal failure and abandonment always receive a final `Inform`.
6. Whether only one long-running operation may execute, independently of
   Presence ownership.

## Canonical Result

The proposed outline was realized by
[`20-JOURNEY-COORDINATION.md`](../20-JOURNEY-COORDINATION.md) rather than
remaining a competing coordination specification.

## Episode Model Refinements Reflected Canonically

The canonical Episode and Journey documents establish that:

- the Foreground Journey is the single foreground Presence owner;
- durable `Work` details may remain feature-owned and referenced by Journey
  state;
- pause, retry, cancellation, and postponement are Journey controls;
- progress updates do not create new Episode identities.
