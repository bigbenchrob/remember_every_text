We need to pause implementation churn and establish a coherent architectural model for “message evidence surfaces” throughout the app.

The current problem is not merely cosmetic placement of controls.

It is a conceptual issue involving:

navigation
topology
evidence display
local projection/view state
semantic consistency

The app is no longer behaving like a traditional messaging client.

It is increasingly becoming:

a communication graph explorer
a semantic evidence browser
a relational intelligence system over message archives

The UI architecture must now reflect that reality.

⸻

CORE ARCHITECTURAL PRINCIPLE

We should explicitly separate:

Navigation / topology
Evidence / content
Local projection controls

These are distinct conceptual layers.

⸻

PROPOSED UI SEMANTICS

SIDEBAR

navigation / topology / selection

The sidebar should primarily contain:

contact selection
conversation selection
graph traversal
heatmap navigation
relationship topology
concentration-oriented exploration
semantic navigation structures

The sidebar should NOT become overloaded with:

detailed evidence controls
large filtering toolbars
per-conversation view-state complexity

Reason:
The sidebar represents the broader communication landscape.

⸻

CENTER PANEL

evidence surface

The center panel should contain:

message evidence
conversation projections
semantic projections
search evidence
recovered-message evidence
timeline slices

The center panel is where the user reads, interprets, reviews, and investigates communication evidence.

⸻

VIEW CONTROLS

local projection state

Controls like:

oldest/newest first
latest 100 / latest 500
text / no-text
associated/system/reaction filtering
from me / received
semantic overlays

are NOT:

global app navigation
raw evidence themselves

They are:

controls governing the projection of the currently selected evidence surface

Therefore:
they should belong to the currently selected conversation/evidence projection.

⸻

IMPORTANT RULE

Do NOT place large persistent control panels directly inline with message evidence.

Reason:
This visually interrupts conversational flow and breaks immersion in the evidence stream.

The eye should primarily encounter:

messages
relationships
chronology
semantic evidence

—not tooling chrome.

⸻

RECOMMENDED STRUCTURE

Preferred structure:

Conversation projection header
↓
Optional/collapsible local controls
↓
Canonical message evidence list

Example conceptual structure:

⸻

Conversation graph timeline
964 messages • oldest→newest • all messages

[▾ View options]

⸻

Expanded:

Ordering:

oldest first
newest first

Scope:

latest 100
latest 500

Message types:

all
text
no text
associated

Direction:

from me
received

⸻

This preserves:

calmness
semantic hierarchy
evidence immersion
progressive disclosure

while still exposing analytical power.

⸻

CRITICAL CONSISTENCY REQUIREMENT

There should be ONE canonical message evidence rendering system throughout the app.

Codex is currently oscillating between:

legacy message list rendering
newer aligned conversation rendering
different alignment semantics
different metadata placement patterns

This must stop.

The app now needs a canonical:

MessageEvidenceList

or equivalent conceptual component.

⸻

CANONICAL MESSAGE EVIDENCE PRINCIPLES

All message evidence surfaces should share:

alignment semantics
spacing rules
sender labeling
timestamp treatment
attachment rendering
metadata placement
search highlighting behavior
reaction/system-message rendering
semantic overlays
chronology treatment

The only thing that should vary is:

the projection/query source

NOT:

the visual language

⸻

IMPORTANT ARCHITECTURAL INSIGHT

The app now contains many semantic projections over the same communication graph.

Examples:

conversation view
heatmap jump results
search results
semantic overlays
recovered-message pools
participant overlap exploration
legal/investigative review slices

Users must feel they are traversing:

one coherent evidence system

not:

unrelated mini-applications

⸻

ALIGNMENT DIRECTION

The newer aligned-message rendering direction is preferred over the older legacy flat list.

Reason:
left/right alignment emphasizes:

conversational directionality
relational flow
participant interaction
communication topology

This aligns strongly with the graph-oriented architecture.

The older flat-list approach feels:

archival
row-oriented
database-centric

The newer aligned approach feels:

relational
conversational
topology-aware
flow-oriented

⸻

IMPLEMENTATION REQUEST

Please propose:

A canonical MessageEvidenceList architecture
A reusable message rendering contract
A reusable local projection-controls pattern
Rules for:
projection headers
disclosure/collapse behavior
evidence/control separation
metadata placement
semantic overlays
A migration strategy away from legacy message-list variants
Identification of all current divergent message rendering systems
A proposal for how all future evidence surfaces should compose:
projection header
optional local controls
canonical evidence list

Most importantly:

We are no longer designing isolated screens.

We are designing:

semantic evidence projections
    over
a traversable communication graph

The message rendering system must now reflect that architectural reality.
