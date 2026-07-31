The canonical Presence semantic architecture is now established.

Read these normative documents carefully:

- 43-PRESENCE/00-PRESENCE.md
- 43-PRESENCE/01-DESIGN-DOCUMENTS/presence-episode-specification.md
- 43-PRESENCE/10-EPISODE-MODEL.md
- 43-PRESENCE/20-JOURNEY-COORDINATION.md

Also inspect:

- 43-PRESENCE/30-RENDERING.md (currently a placeholder)
- 43-PRESENCE/README.md
- relevant existing MessageLens presentation architecture and documentation conventions

This is an architectural design-analysis task only.

Do not modify canonical Presence documents.
Do not write Flutter code.
Do not propose Riverpod providers, widget classes, routing implementations, animation code, or concrete file structures.
Do not design the final visual appearance of onboarding.

The purpose is to determine the canonical Presence rendering contract before writing 30-RENDERING.md.

---

## Central Question

How does Presence transform one truthful Active Episode into calm, accessible, replaceable presentation without allowing presentation to acquire semantic or operational authority?

The Renderer is terminal and replaceable.

It presents the Active Episode and permitted Moments.

It may capture only interactions declared by the Episode contract.

It never determines Journey truth, advances a Journey, performs work, or interprets feature-domain facts independently.

---

1. Define Rendering

---

Formally analyze what Presence rendering is.

Distinguish:

- Episode semantics
- rendering policy
- concrete presentation
- visual styling
- feature-supplied content
- user interaction capture

Determine which of these belong in the canonical rendering architecture and which belong elsewhere.

State what a Renderer is and is not.

---

2. Rendering Pipeline

---

Analyze the canonical one-way pipeline:

Durable Journey truth +
Current feature-owned facts
->
Active Episode
->
Rendering policy
->
Concrete presentation
->
Declared user interaction
->
Journey Coordinator

Determine:

- what enters the Renderer;
- what may leave it;
- what the Renderer may transform;
- what semantic information must be preserved exactly;
- what must never flow backward as inferred truth.

---

3. Renderer Authority

---

Define the Renderer’s permitted authority.

It may potentially:

- select an approved presentation treatment for the Episode family and purpose;
- arrange semantic content;
- expose declared controls;
- collect a candidate typed response;
- return acknowledgement or supporting-action events;
- schedule presentation-only transitions such as fades;
- present feature-supplied progress and Moments.

It must never:

- select the Active Episode;
- reinterpret its completion authority;
- manufacture actions;
- validate feature-domain meaning;
- commit answers;
- start, pause, cancel, retry, or complete operations;
- decide that an awaited condition is satisfied;
- infer progress or liveness;
- advance the Journey;
- seize or change foreground Presence.

Test and refine this boundary.

---

4. Semantic Preservation

---

Determine which Episode semantics every Renderer must preserve regardless of platform or visual treatment.

Consider:

- Episode identity;
- family;
- semantic purpose;
- completion authority;
- primary message;
- supporting explanation;
- feature-supplied facts;
- declared user responsibility;
- permitted response contract;
- supporting actions;
- progress evidence;
- Moment eligibility.

Explain what presentation may vary without changing the Episode.

Determine when a presentation change would constitute an illegal semantic reinterpretation.

---

5. Presentation Policy

---

Analyze whether Presence needs a canonical presentation-policy layer between Episode and concrete Renderer.

Possible responsibilities may include:

- choosing acknowledgement versus automatic presentation progression where already authorized by the Episode;
- minimum readable duration;
- calm pacing;
- transition timing;
- whether supporting detail is initially visible;
- control emphasis;
- Moment admission and cadence;
- accessibility announcement priority;
- reduction of motion;
- interruption handling.

Do not assume all belong there.

Distinguish semantic policy from cosmetic styling.

Determine which policies must be project-wide and which may vary by platform, context, accessibility settings, or feature-supplied content.

---

6. One Thing at a Time

---

Formalize the “one meaningful thing at a time” principle.

Analyze:

- whether one Active Episode may have several visible regions;
- when supporting explanation remains subordinate rather than becoming a second competing interaction;
- whether optional detail may expand;
- whether multiple controls are permissible;
- how validation feedback fits without becoming another Episode;
- how progress facts and Moments coexist without competing for attention.

The principle must not be reduced to “one widget” or “one sentence.”

---

7. Family-Specific Rendering Contracts

---

For each canonical Episode family, analyze what rendering must and must not support.

Inform:

- message hierarchy;
- acknowledgement;
- Coordinator-authorized automatic progression;
- completion summaries.

Ask<T>:

- one constrained question;
- collection of a typed candidate response;
- validation feedback;
- draft input;
- response submission;
- prevention of generic form-building.

Work:

- indeterminate, measurable, and phased evidence;
- truthful liveness;
- progress updates retaining Episode identity;
- Journey controls that may be exposed without becoming Work results;
- Moments subordinate to Work.

Await:

- awaited-condition explanation;
- supporting external actions;
- reassurance about leaving and returning;
- refreshed condition facts;
- prohibition against “I did it” becoming evidence.

---

8. User Interaction Events

---

Determine the canonical categories of events a Renderer may return.

Consider:

- acknowledgement;
- typed candidate response;
- submission;
- supporting command invocation;
- validation correction;
- Journey-control request;
- detail expansion or collapse;
- accessibility or navigation events.

Separate semantic events from presentation-local events.

Determine which events reach the Coordinator and which must remain entirely within rendering.

No arbitrary callbacks or untyped action maps should be permitted.

---

9. Validation

---

Analyze validation ownership for Ask<T>.

Distinguish:

- presentation-local validation;
- structural contract validation;
- feature-domain validation;
- Coordinator acceptance;
- durable commitment.

Determine how validation feedback returns to the Renderer without allowing the Renderer to own domain truth.

---

10. Automatic Progression and Timing

---

Resolve the rendering implications of Inform Episodes that may advance without acknowledgement.

Determine:

- who authorizes automatic progression;
- whether timing can ever complete an Episode;
- how minimum readable duration differs from completion authority;
- what happens when Journey truth changes before a fade or timer completes;
- how stale presentation timers are invalidated;
- how reduced-motion and accessibility requirements affect timing without changing semantics.

No animation, delay, or timer may become Journey truth.

---

11. Episode Replacement

---

Analyze what happens when the Coordinator derives a new Active Episode.

Determine:

- how the Renderer recognizes identity continuity versus replacement;
- how progress updates affect an existing presentation;
- how obsolete presentation is withdrawn;
- whether outgoing animation may continue briefly;
- why an outgoing presentation cannot remain interactive;
- how stale responses are rejected;
- what happens when foreground ownership changes.

---

12. Moments

---

Analyze only the rendering boundary for Moments; do not write the full Ambient Moments model.

Determine:

- how a Renderer receives eligible Moments;
- how they remain subordinate to the Active Episode;
- how cadence and transition may be presentation policy;
- how Moments are suppressed when they would compete with a question, problem, or required action;
- how reduced motion, privacy, and accessibility affect presentation;
- why Moments never generate Journey events.

Identify which questions must be deferred to 40-AMBIENT-MOMENTS.md.

---

13. Accessibility

---

Treat accessibility as part of the rendering contract, not a later cosmetic pass.

Analyze:

- semantic reading order;
- focus ownership;
- keyboard operation;
- screen-reader announcements;
- reduced motion;
- readable timing;
- preservation of typed input;
- progress announcements;
- prevention of repeated announcements during frequent updates;
- transition behaviour when Episodes change.

Determine what belongs canonically in Presence versus concrete platform implementation.

---

14. Multiple Renderers and Contexts

---

Pressure-test renderer replaceability.

Could the same Episode contract be rendered through:

- the primary macOS Presence surface;
- a compact maintenance surface;
- a future iPad experience;
- an accessibility-optimized renderer;
- a nonvisual test renderer?

Determine what must remain invariant and what may differ.

Do not design these renderers.

---

15. Rendering Failure

---

Analyze what happens if rendering itself fails, is unavailable, or is replaced.

Determine:

- whether a Journey continues to exist;
- whether feature operations may continue;
- how the Active Episode is later re-presented;
- why Renderer failure is not Journey failure;
- when inability to obtain required user input becomes a coordination concern.

---

## Pressure Test

Apply the proposed rendering model to:

1. Welcome to MessageLens.
2. Full Disk Access explanation.
3. Awaiting Full Disk Access with an Open System Settings action.
4. User leaves and later returns.
5. Archive-name input with invalid and then valid input.
6. Indeterminate archive scan.
7. Measurable import whose progress updates frequently.
8. Phased import with no meaningful global percentage.
9. Meaningful message excerpts fading during Work.
10. External drive disconnected.
11. Background Journey requests attention while another Journey is Foreground.
12. Import completes while MessageLens is not foregrounded.
13. Active Episode changes while an outgoing fade is running.
14. Reduced-motion and screen-reader use.

For each scenario identify:

- Active Episode semantics;
- Renderer inputs;
- permitted presentation policy;
- permitted Renderer output;
- forbidden Renderer behaviour;
- identity continuity or replacement;
- accessibility considerations.

---

## Architectural Invariants

Propose the strongest canonical rendering invariants.

Include at least:

- rendering is a projection, never authority;
- only the Active Episode may be rendered as the current Presence interaction;
- Renderer output is limited to declared contracts;
- rendering cannot advance Journeys;
- presentation timing cannot establish completion;
- stale presentations cannot remain interactive;
- progress presentation cannot manufacture operational truth;
- Moments remain subordinate;
- visual appearance cannot redefine Episode family or completion authority;
- the Renderer is replaceable without changing Journey or Episode semantics.

Expand and refine this list.

---

## Deliverables

Create a design-analysis document in:

43-PRESENCE/01-DESIGN-DOCUMENTS/

Use the existing naming and documentation conventions.

Also preserve the prompt in:

43-PRESENCE/00-PROMPTS/

if that is the established convention for this Presence work.

Do not modify:

- 30-RENDERING.md;
- any other canonical Presence document;
- application code.

Conclude the analysis with:

1. Recommended canonical rendering model.
2. Recommended Renderer input and output contracts.
3. Recommended distinction between semantic policy and concrete presentation.
4. Remaining architectural questions before writing 30-RENDERING.md.
5. Proposed outline for 30-RENDERING.md.
6. Any narrowly scoped terminology refinements that should later be reflected in earlier Presence documents.
