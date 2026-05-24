You are beginning a new exploratory/research feature branch for MessageLens.

It is intended to determine the direction of the MessageLens app design as we move to a conversation-centric from a contact-centric emphasis.

Use the standalone prototype in experiments/conversation_shape_sandbox/ as design reference only. Do not copy its architecture into production. Preserve the principle: sidebar handles navigation, controls, exploration, and conversation-shape recognition; center panel remains the resolved message stream.

Branch name suggestion:

Ftr:convo-topol

This is NOT a normal production feature branch.

This branch exists to explore, discover, and validate a new visual language for understanding conversations and relationships through temporal topology and perceptual pattern recognition.

READ THIS CAREFULLY:
The goal is NOT:

- “build a prettier chat UI”
- “modernize the app”
- “move controls into content”
- “copy Discord/iMessage/Slack”
- “improve message bubbles”

The goal IS:
to discover whether conversations possess recognizable visual identities that can be perceived pre-attentively through compact temporal/topological signatures and subtle message-stream rendering techniques.

This work is exploratory and research-oriented.

======================================================================
CORE PHILOSOPHY
======================================================================

MessageLens is NOT a conventional messaging app.

Most messaging UIs optimize:

- immediacy
- input
- reactions
- notifications
- ephemeral interaction

MessageLens optimizes:

- historical cognition
- temporal navigation
- relational topology
- density
- re-entry
- autobiographical recognition
- exploratory browsing

The interface must support:
“recognition under compression.”

The user should be able to:

- blur the UI
- zoom out
- remove textual detail
- glance rapidly

…and STILL distinguish:

- active long-running friendship
- sparse transactional pharmacy thread
- sports event group chat
- seasonal reality-show conversation
- dormant/revived conversation
- family logistics thread
- attachment-heavy planning conversation

This is a perceptual-recognition problem, not a metadata-display problem.

We can start by simply presenting the conversation signatures in the sidebar,
clicking on any of which brings up the formatted messages in the center panel.
Once this is satisfactorily in place we can consider further elements to aid
sidebar navigation and message presentation.

======================================================================
ABSOLUTE ARCHITECTURAL INVARIANTS
======================================================================

These are NON-NEGOTIABLE.

1. SIDEBAR VS CENTER PANEL SEMANTICS

Sidebar:

- navigation
- exploration
- narrowing
- topology
- historical shape
- conversation selection
- temporal orientation
- filters
- perceptual instrumentation

Center panel:

- resolved message stream ONLY

NEVER move conversation-selection semantics into the center panel.

The center panel must NEVER become:

- a query builder
- a navigation page
- a mode-selection surface
- a conversation browser

The user must NEVER lose navigational context while reading messages.

The semantic split is sacred.

2. NO ARCHITECTURAL ENTROPY

This is an exploratory branch, BUT:

- do not bypass core architecture
- do not create rogue state systems
- do not create parallel database access paths
- do not bypass providers
- do not inject ad hoc globals
- do not compromise spec-driven architecture

Exploratory rendering is allowed.
Architectural degradation is NOT allowed.

3. EXPERIMENTAL SYSTEMS MUST BE REMOVABLE

All experimental systems must be:

- isolated
- clearly named
- self-contained
- removable
- non-authoritative

This is a laboratory, not production canon.

4. NO “WEB APP” DRIFT

Do NOT collapse:

- navigation
- controls
- results
- and content

…into a monolithic page.

Avoid:

- giant settings panels
- dashboard pages
- center-panel filtering workflows
- “everything in one view” design

======================================================================
PRIMARY RESEARCH QUESTIONS
======================================================================

We are trying to discover:

1. Can conversations possess recognizable visual identities?

2. Which visual primitives carry actual meaning?

3. Which signals survive:

- blur
- compression
- grayscale
- reduced scale
- rapid scanning

4. Can users recognize:

- cadence
- density
- silence
- bursts
- dominance
- continuity
- revival
- attachment ecology
- participant rhythm

…WITHOUT reading metadata?

5. Can subtle message-stream rendering techniques improve group-chat readability WITHOUT:

- rainbow UI
- cartoon avatars
- giant spacing
- visual fragmentation
- “Discordification”

======================================================================
IMPLEMENTATION DIRECTION
======================================================================

Create a dedicated experimental subsystem.

Suggested names:

- ConversationTopologyLab
- ConversationShapeLab
- ConversationTopologySurface
- ConversationTopologyInstrumentation

This subsystem may:

- expose experimental controls
- render alternate visualizations
- support temporary instrumentation
- expose live tuning sliders
- allow rapid iteration

This subsystem is explicitly experimental.

======================================================================
INITIAL FEATURE SET
======================================================================

Implement a first-pass experimental topology visualization system using REAL MessageLens data.

Possible topology dimensions:

- message density
- temporal cadence
- silence gaps
- burst clustering
- participant dominance
- attachment density
- seasonal recurrence
- revival events
- continuity
- conversational rhythm

Potential visual primitives:

- density traces
- cadence islands
- silence corridors
- dominance spines
- revival flares
- attachment rainfall
- conversational braids
- activity plateaus
- pulse clusters
- temporal waves

DO NOT over-smooth.

Slight irregularity and texture are valuable.

======================================================================
MESSAGE STREAM EXPERIMENTS
======================================================================

Experiment carefully with:

- subtle participant accents
- restrained participant colors
- tiny avatar/initial badges
- indentation rhythm
- cadence shaping
- density
- spacing

DO NOT:

- create rainbow chat bubbles
- use saturated colors
- add excessive whitespace
- turn the UI into Slack/Discord
- use giant avatars
- destroy reading density

Group-chat readability should emerge through:

- layered weak signals
  NOT
- one overpowering signal

Identity should exist simultaneously in:

- indentation
- subtle color
- rhythm
- badge presence
- spacing
- cadence

No single mechanism should dominate.

======================================================================
EXPERIMENTAL CONTROLS
======================================================================

Expose instrumentation controls INSIDE THE EXPERIMENTAL LAB ONLY.

These are NOT production settings.

Potential controls:

- blur amount
- grayscale mode
- saturation
- signature compression
- trace smoothing
- indentation step
- density spacing
- border/accent strength
- participant color mode
- visualization mode
- topology weighting

The purpose is perceptual discovery.

======================================================================
IMPORTANT DESIGN PRINCIPLES
======================================================================

The visual signatures should eventually become:

- recognizable
- memorable
- emotionally legible
- autobiographically meaningful

The sidebar should become:
a compressed map of communication history.

The user should gradually learn:
“That shape is Claire.”
“That pulse cluster is hockey season.”
“That sparse waveform is the pharmacy.”
“That broad dense plateau is vacation planning.”

The system should support:
pre-attentive recognition.

======================================================================
RESEARCH PROCESS
======================================================================

Do NOT prematurely optimize for:

- abstraction
- reuse
- cleanup
- architecture purity
- polish
- settings UX
- conventionality

Instead optimize for:

- perceptual clarity
- recognizability
- topology discovery
- visual meaning
- exploratory iteration

This branch is a laboratory.

We are inventing a visual language for conversation topology.

======================================================================
INITIAL DELIVERABLES
======================================================================

1. Experimental conversation topology sidebar renderer.

2. Real-data topology signatures.

3. Blur/grayscale testing modes.

4. Experimental message-stream rendering variations.

5. Instrumentation controls.

6. Clear architectural separation between:

- experimental rendering
- durable application state

7. A running DESIGN_NOTES.md documenting discoveries:

- what works
- what fails
- what remains recognizable under compression
- what becomes noise
- emergent visual vocabulary
- surprising autobiographical patterns discovered in real data

======================================================================
MOST IMPORTANT PRINCIPLE
======================================================================

We are NOT merely visualizing messages.

We are attempting to visualize the shape of human relationships over time.
