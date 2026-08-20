# Presence Rendering

## Status

This document is the canonical architecture for Presence Rendering.

It defines how one truthful Active Episode becomes presentation while
preserving its semantics.

Journey coordination is defined by
[`20-JOURNEY-COORDINATION.md`](20-JOURNEY-COORDINATION.md). Episode semantics
and protocols are defined by
[`presence-episode-specification.md`](01-DESIGN-DOCUMENTS/presence-episode-specification.md)
and [`10-EPISODE-MODEL.md`](10-EPISODE-MODEL.md).

Rendering assumes those authorities already exist. It does not redefine them.

## Definition

Presence Rendering is the terminal, replaceable projection of one truthful
Active Episode into an accessible interaction surface.

The Renderer receives semantics that have already been derived. It presents
those semantics according to Presentation Policy and captures only the
interactions declared by the Episode contract.

Rendering is a one-way semantic projection:

```text
Durable Journey truth and current feature-owned facts
    -> Journey Coordinator
    -> Active Episode
    -> Presentation Policy
    -> concrete presentation
    -> declared interaction or Presentation Observation with Provenance
    -> Journey Coordinator
```

Nothing becomes Journey truth or feature truth merely because it was
displayed, entered, focused, announced, or observed within presentation.

## Renderer Role

The Renderer is responsible for:

- projecting the Active Episode into a concrete presentation;
- preserving the Episode's semantic hierarchy;
- exposing only declared interactions and controls;
- presenting supplied facts without estimating or reinterpreting them;
- collecting candidate user responses;
- applying Presentation Policy;
- preserving safe presentation-local state while Episode identity remains
  current;
- returning declared Coordinator-bound outputs with Provenance;
- withdrawing obsolete presentation authority when the Active Episode
  changes.

The Renderer is not responsible for:

- deriving or selecting the Active Episode;
- deciding Journey truth;
- interpreting feature-domain facts;
- performing feature operations;
- determining Completion Authority;
- accepting a domain response;
- deciding that an external condition is satisfied;
- establishing progress, liveness, success, failure, or completion;
- advancing, terminating, or foregrounding a Journey;
- persisting accepted decisions as Journey truth.

The Renderer presents. It does not coordinate.

## Semantic Preservation

Every concrete Renderer must preserve:

1. Journey identity and revision.
2. Episode identity and activation occurrence.
3. Episode family.
4. Semantic purpose.
5. Completion Authority.
6. Primary communication.
7. Supporting explanation and its subordinate status.
8. Declared user responsibility.
9. Permitted response type and constraints.
10. Declared supporting commands and Journey controls.
11. Supplied feature facts and the basis of any progress evidence.
12. Moment eligibility and subordination.

Concrete presentation may vary in composition, visual treatment, pacing,
density, disclosure, and interaction idiom. Those differences are lawful only
when the preserved semantics remain unchanged.

A presentation violates the Episode contract if it:

- makes an optional action appear required;
- makes a supporting command appear to complete an `Await`;
- presents an `Ask<T>` as an unconstrained response;
- presents estimated progress as measured fact;
- converts acknowledgement into feature-domain consent;
- omits a required user responsibility;
- changes which authority can complete the Episode;
- gives a Moment equal or greater authority than the Active Episode.

## Renderer Authority

The Renderer may choose a concrete treatment only within the Active Episode
contract and Presentation Policy.

It may:

- arrange primary and supporting content;
- expose declared controls;
- collect local draft input;
- present supplied progress and condition evidence;
- manage presentation-local disclosure and attention;
- adapt presentation to its current context;
- update presentation while the same Episode identity remains current.

It may not:

- change Episode family, purpose, or Completion Authority;
- create interactions or commands not declared by the Episode;
- hide a required responsibility;
- start, pause, cancel, retry, repair, or complete feature work;
- treat elapsed presentation time as operational evidence;
- infer user understanding from visibility or attention;
- retain an obsolete Episode as the effective interaction;
- choose the Foreground Journey.

Renderer authority is intentionally narrow. A Renderer must not receive
semantic or operational authority merely because it needs to present the
result of that authority.

## Presentation Policy

Presentation Policy defines project-wide behaviour for presenting an
already-derived Active Episode calmly, truthfully, and accessibly.

Presentation Policy governs:

- one meaningful thing at a time;
- stable semantic hierarchy;
- minimum readable opportunity for authorized automatic progression;
- immediate semantic withdrawal of stale presentation;
- preservation of safe local state during same-identity updates;
- calm presentation of progress and condition changes;
- accessibility reading order and attention intent;
- equivalent meaning across presentation adaptations;
- announcement priority and repetition limits;
- the distinction between primary, supporting, and ambient content.

Presentation Policy may allow concrete presentation to vary according to
surface, available space, accessibility context, and current presentation
conditions.

Presentation Policy cannot:

- select or replace the Active Episode;
- decide whether acknowledgement is semantically required;
- alter the permitted response type;
- create supporting commands or Journey controls;
- establish feature truth;
- decide foreground ownership;
- authorize Journey progression from presentation time alone.

### Presentation Policy and Concrete Presentation

Presentation Policy states the canonical behavioural constraints. Concrete
presentation is one realization of those constraints.

Concrete presentation may choose how the Episode is arranged and expressed.
It must not reinterpret what the Episode means.

Changing concrete presentation does not change Journey state, Episode
identity, Completion Authority, or the permitted interaction contract.

## One Meaningful Thing at a Time

One meaningful thing at a time is an attention invariant, not a limit on the
number of visible elements.

One Active Episode may contain:

- one primary statement or question;
- subordinate explanation;
- one coherent response area;
- declared supporting commands;
- declared Journey controls;
- quiet progress or condition evidence;
- an eligible subordinate Moment.

The presentation remains one meaningful thing only when:

- every element serves the same Episode purpose;
- one interaction has semantic priority;
- supporting information remains subordinate;
- controls have distinct and truthful roles;
- optional detail does not create a parallel task;
- any Moment can disappear without changing the interaction.

Validation feedback remains part of the same `Ask<T>` while the question,
purpose, and Completion Authority remain unchanged.

Progress evidence and a Moment may coexist only while progress remains the
authoritative `Work` communication and the Moment remains optional,
transient, and noninteractive.

## Renderer Input Contract

The Renderer receives an immutable Active Episode presentation description.

That description contains:

- Provenance for the current activation;
- Episode family and semantic purpose;
- Completion Authority contract;
- primary communication and supporting explanation;
- declared user responsibility;
- typed response contract, when applicable;
- declared supporting commands and Journey controls;
- feature-prepared facts included by the Episode;
- supplied progress or condition evidence;
- authorized validation feedback;
- currently eligible Moments;
- Presentation Policy and relevant presentation context.

The input must contain enough semantic information to render truthfully
without independently acquiring feature knowledge or operational authority.

The Renderer does not use unrestricted domain access to decide the contents of
the Active Episode.

## Renderer Output Contract

Coordinator-bound Renderer output consists of two closed categories:

1. declared user interactions;
2. declared Presentation Observations.

Every Coordinator-bound output is typed and carries Provenance.

### Declared User Interactions

The permitted interaction categories are:

| Interaction | Meaning |
| --- | --- |
| **Acknowledge** | The user performed the acknowledgement declared by the Episode. |
| **SubmitCandidate<T>** | The user submitted a typed candidate for the current `Ask<T>`. |
| **RequestSupportingCommand** | The user invoked one supporting command declared by the Episode. |
| **RequestJourneyControl** | The user requested one Journey control declared for the current context. |

An interaction is candidate evidence or intent. It does not accept itself,
complete the Episode, or advance the Journey.

Draft editing, disclosure changes, focus movement, navigation within the
presentation, and accessibility exploration remain presentation-local unless
another Presence authority explicitly gives them architectural significance.

### Presentation Observations

A Presentation Observation reports that a presentation condition declared by
the Episode and Presentation Policy occurred.

The canonical example is:

> Readable opportunity provided.

A Presentation Observation reports only what the Renderer can know about
presentation. It cannot establish that the user read, heard, understood,
acknowledged, or accepted anything.

A Presentation Observation:

- is emitted only when declared relevant;
- carries current Provenance;
- is interpreted only by the Coordinator;
- is never Journey evidence by itself;
- cannot independently authorize a Journey transition.

## Provenance

Provenance is the identity chain accompanying every Coordinator-bound
interaction and Presentation Observation:

- Journey identity;
- Journey revision;
- Episode identity;
- activation occurrence;
- interaction occurrence.

Journey identity identifies the undertaking. Journey revision identifies the
durable Journey state from which the Active Episode was derived. Episode
identity identifies the logical interaction obligation.

Activation occurrence identifies one grant of foreground rendering authority.
Episode identity may survive reconstruction and restart. Activation authority
does not. Restart reconciliation issues a new activation occurrence before
rendering resumes.

Interaction occurrence identifies one semantic interaction crossing the
Renderer and Coordinator boundary. It permits duplicate rejection and
correlates later feedback. For `Ask<T>`, it identifies the candidate submission
to which validation feedback refers.

The Coordinator accepts output only when:

- Journey identity and revision remain current;
- the Episode remains the Active Episode;
- the activation occurrence remains effective;
- the interaction occurrence has not already been consumed;
- the output is declared by the current Episode contract.

Provenance contains no identity belonging solely to a concrete Renderer or its
presentation technology.

## Family-Specific Rendering Responsibilities

### Inform

The Renderer presents:

- one clear primary message;
- subordinate explanation;
- declared acknowledgement when required;
- sufficient readable opportunity;
- an already-established completion or failure summary when supplied.

The Renderer may participate in Coordinator-authorized automatic progression
only through the declared Presentation Observation.

It must not:

- infer understanding;
- treat visibility as acknowledgement;
- turn continuation into an undeclared domain choice;
- present a completion summary as the authority that completed the Journey.

### Ask<T>

The Renderer presents:

- one constrained question;
- a response form faithful to the declared response type;
- local candidate state;
- authorized guidance and validation feedback;
- correction and resubmission of the same semantic answer.

The Renderer returns a typed candidate with Provenance.

It must not:

- infer or broaden the response contract;
- validate feature-domain meaning independently;
- commit the answer as Journey truth;
- advance from local response state alone.

Several presented fields are permitted only when they form one indivisible
typed response and one completion decision. Independent questions require
independent Episodes.

### Work

The Renderer presents only supplied operational evidence.

It may present:

- indeterminate work without invented percentage;
- measurable work with its supplied numerator, denominator, and basis;
- phased work without implying false global precision;
- supplied liveness or last-update facts;
- same-identity evidence updates;
- declared Journey controls;
- an eligible subordinate Moment.

It must not:

- calculate progress from presentation time;
- infer liveness from presentation activity;
- smooth supplied evidence into false facts;
- start, stop, retry, repair, or complete the operation;
- present a Journey-control request as its successful outcome.

Frequent updates preserve Episode identity while the interaction obligation
remains unchanged.

Where commentary and factual evidence form one continuing operational
presentation, Presentation Policy may preserve their stable spatial
relationship while commentary changes or becomes silent. Silence must not be
filled with placeholder content, and spatial continuity must not imply that
the absent commentary still applies.

After operational truth becomes complete, Presentation Policy may retain the
fully resolved evidence for a bounded readable opportunity. This does not
extend the operation, retain active progress, or grant the Renderer completion
authority. It only allows the human to perceive already-completed truth.

### Await

The Renderer presents:

- the condition being awaited;
- what the user may truthfully do;
- declared supporting commands;
- reassurance that leaving and returning are safe when that is true;
- refreshed condition facts supplied through the Episode;
- recovery guidance when supplied.

It must not:

- observe or declare the external condition independently;
- treat a supporting command as completion;
- treat a user assertion as proof of an independently observable condition;
- imply active progress when none is established.

The owning feature establishes whether the awaited condition became true. The
Coordinator determines the resulting Journey transition.

## Validation Ownership

Validation preserves separate layers of authority:

| Validation layer | Responsibility |
| --- | --- |
| **Presentation-local** | Maintains valid interaction mechanics and presents declared format guidance. |
| **Structural contract** | Tests a candidate against constraints already encoded in its typed response contract. |
| **Feature-domain** | Determines whether the candidate is meaningful and acceptable within the owning domain. |
| **Coordinator acceptance** | Verifies Provenance and determines whether accepted evidence authorizes a Journey transition. |
| **Durable commitment** | Persists the accepted result atomically with the authorized Journey transition. |

The Renderer may apply structural constraints supplied by the response
contract. It does not own or redefine them. It does not perform feature-domain
validation merely because it presents the question.

Rejected input returns as authorized feedback associated with the same Episode
identity and originating interaction occurrence. The Renderer presents that
feedback and preserves safe candidate state. Rejection does not create a new
Episode unless the Journey's semantic obligation changes.

## Automatic Progression

Elapsed presentation time is never Completion Authority.

An `Inform` may advance without acknowledgement only when:

1. the Episode contract declares that acknowledgement is not required;
2. the Coordinator has already authorized automatic progression for the
   current Episode;
3. Presentation Policy defines the required readable opportunity;
4. the Renderer reports `Readable opportunity provided` with current
   Provenance;
5. the Coordinator verifies current Journey truth and Provenance;
6. the Coordinator commits the transition.

The Presentation Observation does not itself establish understanding,
completion, or transition authority.

If Journey truth or activation changes before the observation is accepted,
the observation is stale and cannot affect the Journey.

Accessibility adaptations may alter how readable opportunity is provided.
They do not alter the Episode's completion semantics.

## Episode Continuity and Replacement

### Same-Identity Updates

Episode identity remains stable while the same logical interaction obligation
continues, including when:

- progress evidence changes;
- phase evidence changes without changing the obligation;
- an awaited condition is rechecked but remains unsatisfied;
- validation feedback returns for the same question;
- supporting facts refresh without changing purpose or Completion Authority.

The Renderer updates the presentation and preserves safe local state.

### Replacement

A different Episode replaces the presentation when the Journey's logical
interaction obligation changes.

On replacement:

- the new Active Episode becomes the only effective Presence interaction;
- the Coordinator issues a new activation occurrence;
- the obsolete presentation becomes immediately noninteractive;
- stale local responses cannot reach the new Episode;
- late Coordinator-bound output is rejected through Provenance;
- presentation-local state belonging to the obsolete Episode is withdrawn;
- Moments belonging to the obsolete Episode are withdrawn.

Foreground ownership change also replaces the effective presentation. A
background Journey's Episode cannot remain interactive after another Journey
becomes Foreground.

Visual continuity never establishes semantic continuity. A presentation-only
reconstruction never creates a new Episode identity while the logical
obligation remains unchanged.

### Restart

Rendered presentation is not durable Journey state.

After restart, the Coordinator reconciles durable Journey truth and current
feature facts, re-derives the truthful Active Episode, and issues a new
activation occurrence. The Renderer presents that current Episode rather than
reconstructing authority from prior presentation.

The same Episode identity may remain truthful. Output from the previous
activation cannot affect current Journey truth.

## Accessibility

Accessibility is a canonical Rendering obligation.

Every Renderer must preserve:

- semantic reading order matching the Episode hierarchy;
- clear identification of primary communication and current responsibility;
- access to every declared interaction;
- predictable attention transfer when the Active Episode changes;
- safe candidate preservation during same-identity updates;
- equivalent semantics across accessibility adaptations;
- sufficient readable opportunity;
- meaningful, restrained progress communication;
- nonvisual distinction between primary, supporting, and ambient content;
- immediate exclusion of obsolete presentation from interaction and attention.

Accessibility adaptation may change concrete presentation, pacing, and
attention treatment. It cannot alter Episode semantics, Completion Authority,
or Journey truth.

## Replaceability and Rendering Absence

The Renderer is replaceable.

Different Renderers may present the same Active Episode differently. Each must
preserve:

- Episode identity and Provenance;
- family and semantic purpose;
- Completion Authority;
- content hierarchy;
- declared user responsibility;
- declared interactions and controls;
- the evidence basis of supplied facts;
- Presentation Policy obligations.

Renderer availability is not Journey truth.

If Rendering is unavailable or fails:

- the Journey continues to exist;
- durable Journey state remains authoritative;
- feature operations continue or stop according to their own safety policy;
- no Episode completes because presentation disappeared;
- required user interaction remains outstanding;
- the truthful Active Episode can be re-derived later.

When Rendering becomes available again, it receives current truth under a new
activation occurrence. Prior presentation is not restored as authority.

## Moment Boundary

Rendering may present only Moments already declared eligible for the Active
Episode and current context.

The Renderer preserves their optional, transient, noninteractive, and
subordinate status. It may suppress an eligible Moment when presenting it
would compete with the Active Episode. It cannot make an ineligible Moment
eligible or emit Journey evidence from a Moment.

Moment categories, content contracts, eligibility, selection, privacy,
cadence, repetition, expiration, and cross-Journey admission belong to
[`40-AMBIENT-MOMENTS.md`](40-AMBIENT-MOMENTS.md).

## Architectural Invariants

1. Rendering is a terminal projection, never an authority.
2. Only the Active Episode may be the effective Presence interaction.
3. Renderer input is derived from current Journey truth and approved
   feature-owned facts.
4. The Renderer does not independently acquire facts to decide what to
   present.
5. Renderer output is limited to typed interactions and Presentation
   Observations declared by the Active Episode.
6. Every Coordinator-bound Renderer output carries Provenance.
7. Provenance contains Journey identity, Journey revision, Episode identity,
   activation occurrence, and interaction occurrence.
8. Episode identity may survive restart; activation authority cannot.
9. Output from an obsolete activation occurrence cannot affect Journey truth.
10. An interaction occurrence may be accepted at most once.
11. A Presentation Observation is never Journey evidence by itself.
12. Rendering cannot advance, complete, fail, or abandon a Journey.
13. Presentation timing cannot establish Episode completion.
14. Visibility, focus, announcement, or local acknowledgement cannot establish
    user understanding.
15. Obsolete presentation becomes noninteractive immediately on replacement.
16. Presentation continuity cannot extend semantic lifetime.
17. Progress presentation cannot estimate or manufacture operational truth.
18. Presentation activity cannot establish operational liveness.
19. Concrete presentation cannot redefine family, purpose, responsibility, or
    Completion Authority.
20. Supporting commands cannot be presented as proof of their outcome.
21. Validation feedback cannot make the Renderer owner of domain truth.
22. Presentation-local state cannot become durable Journey truth accidentally.
23. Moments remain subordinate, nonauthoritative, and unable to emit Journey
    events.
24. Accessibility adaptations preserve Episode semantics.
25. Rendering failure is not Journey or feature-operation failure.
26. The Renderer is replaceable without changing Journey or Episode
    semantics.

## Relationship to Other Presence Documents

- [`00-PRESENCE.md`](00-PRESENCE.md) defines Presence purpose and shared
  vocabulary.
- [`presence-episode-specification.md`](01-DESIGN-DOCUMENTS/presence-episode-specification.md)
  defines the general Episode contract.
- [`10-EPISODE-MODEL.md`](10-EPISODE-MODEL.md) defines the canonical Episode
  families and their Completion Authorities.
- [`20-JOURNEY-COORDINATION.md`](20-JOURNEY-COORDINATION.md) defines Journey
  truth, foreground ownership, transitions, and restart reconciliation.
- [`40-AMBIENT-MOMENTS.md`](40-AMBIENT-MOMENTS.md) defines Moment content
  policy and admission.
- [`50-FEATURE-INTEGRATION.md`](50-FEATURE-INTEGRATION.md) defines how features
  supply prepared content and receive typed Presence interactions.

## Review Checklist

Before approving a Presence Renderer, verify:

1. Does it receive one already-derived Active Episode?
2. Does it preserve family, purpose, Completion Authority, and responsibility?
3. Are all Coordinator-bound outputs declared, typed, and provenance-bearing?
4. Can an obsolete activation still emit an effective interaction?
5. Does any presentation state masquerade as Journey or feature truth?
6. Does Presentation Policy govern treatment without changing semantics?
7. Does the presentation maintain one meaningful thing at a time?
8. Are family-specific responsibilities preserved?
9. Is validation authority kept outside presentation where required?
10. Can automatic progression occur only through Coordinator authorization?
11. Does replacement make obsolete presentation immediately noninteractive?
12. Are accessibility adaptations semantically equivalent?
13. Could another Renderer present the same Episode without feature knowledge?
14. Does Rendering remain truthful if Moments are absent?
