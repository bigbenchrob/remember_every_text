**Evaluation**
The seed identifies the correct architectural problem. The center panel currently conflates three concepts:

1. Panel identity
2. Investigation orientation
3. Selected source

The existing state model already separates them sufficiently:

- `StrayHandleInvestigation` identifies the investigation.
- `HandleInvestigationTarget` identifies `idle` or `selectedSource`.
- `HandleSourcePresentation` supplies the selected source facts.

No new navigation state or ViewSpec variant is needed.

**Governing Principle**

Persistent identity belongs in the header. Investigation orientation belongs
in the first thing the user reads after the header.

This is a reading-order rule, not a fixed widget-placement rule. In Unknown
Sources, the idle presentation naturally uses the evidence region because no
source evidence is present yet. Another feature may place its orientation in a
header Track when that better expresses its own presentation.

**Recommended Identity**
Use a stable, investigation-specific Messages heading:

- Identify: **Messages not linked to a contact**
- Numeric IDs: **Messages from numeric IDs**

The heading remains unchanged when sources are selected or dismissed. Switching between Identify and Numeric IDs legitimately changes it because that starts a different investigation.

**Selected Presentation**
For a selected source:

```text
Messages not linked to a contact
(604) 307-8325
May 2018 to June 2020 · 243 messages
[search]
[actions]
[messages]
```

The endpoint becomes the current subject, never the panel title. The existing “Unfamiliar source” line is likely redundant once this hierarchy is established.

**Idle Presentation**
The idle state should retain the same panel title. It uses the space normally
occupied by evidence to orient the user to the current investigation:

```text
Messages from numeric IDs

Numeric IDs are commonly used for authentication codes,
delivery updates, reminders, and alerts.

Select one to review its messages. Nothing here requires
action. Dismissed IDs remain available from Show.
```

The explanation replaces evidence. It does not replace the header.

For this presentation, the explanatory material belongs in the idle evidence
region rather than being stretched across several header Tracks. The Matrix
should coordinate shared header geometry; it should not become a
document-layout system for local explanatory prose.

**Ownership**

- **Handles** owns investigation meaning, endpoint classification, source facts, and review actions.
- **Messages** owns the center-panel wording, hierarchy, occupants, and evidence presentation.
- **Navigation** owns Matrix placement.
- **ViewSpec state** owns whether the target is idle or selected.
- **Tracks** continue to negotiate truthful occupant dimensions.

The center-panel identity is a projection of the active investigation. It is
derived every time and is never cached or independently maintained as mutable
UI state. No transient selection or UI event assigns the page title.

**Implementation Plan**

1. Replace the idle-only presentation model with one investigation presentation contract containing:
   - stable panel title;
   - idle orientation copy;
   - optional category-specific supporting language.

2. Make both idle and selected rendering consume that same panel title.

3. Revise current Matrix occupancy:
   - `A2`: persistent panel identity.
   - `B2`: selected source subject when present.
   - Existing later cells: metrics, search, actions, and explicit spacing.
   - Idle state leaves source-specific cells empty and presents orientation as
     the first content in the evidence region.

4. Extend the canonical idle evidence frame to accept a Messages-owned
   orientation presentation rather than rendering a blank `Expanded`. This is
   the Unknown Sources implementation of the reading-order principle, not a
   universal requirement that orientation always live in a body widget.

5. Remove the selected endpoint and loading source label from the title position. Loading/error states should preserve panel identity and report their condition below it.

6. Add focused tests proving:
   - idle and selected states share the same heading;
   - selecting another source changes only the subject;
   - switching investigations changes the heading;
   - endpoints never become panel titles;
   - idle explanations are investigation-specific;
   - selected metrics, search, actions, and messages remain unchanged;
   - no artificial minimum Track heights are introduced.

7. Update the Unknown Sources proposal and current Matrix occupancy documentation after implementation.

**Recommendation**
Proceed as a narrow presentation refactor. Within Unknown Sources, treat stable
identity, idle orientation, and selected subject as a proven presentation
pattern. Do not generalize it into a universal investigation-page framework
yet. If future investigations converge naturally, the pattern can later be
promoted into a broader UI standard.

**Implemented Slice**

The first implementation now derives one Messages-owned presentation contract
from `StrayHandleInvestigation` for both idle and selected targets:

- Identify projects `Messages not linked to a contact`.
- Numeric IDs projects `Messages from numeric IDs`.
- A selected endpoint appears as the current subject beneath that identity.
- Loading and error presentations retain the same investigation-derived
  identity.
- Idle orientation occupies the evidence region and explains the active
  investigation instead of replacing the header.

The Matrix places the persistent identity in A2 and the optional selected
subject in B2. It continues to coordinate shared header geometry only. Local
explanatory prose remains inside the Messages-owned evidence presentation.
