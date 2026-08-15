The Episode Model is now considered architecturally stable.
Read the following normative Presence documents before beginning:

- 43-PRESENCE/00-PRESENCE.md
- 43-PRESENCE/01-DESIGN-DOCUMENTS/presence-episode-specification.md
- 43-PRESENCE/10-EPISODE-MODEL.md
  Also inspect:
- 43-PRESENCE/20-JOURNEY-COORDINATION.md (currently placeholder)
- the Presence README
  This is an architectural analysis task only.
  Do not modify any canonical documents.
  Do not write Flutter code.
  Do not design providers, widgets, databases, rendering technology, or implementation classes.
  The purpose of this analysis is to determine the canonical Journey coordination model before writing 20-JOURNEY-COORDINATION.md.

---

## Central Question

A Journey is the durable authority.
An Episode is the current interaction derived from that authority.
How should a Journey advance through truthful state transitions while preserving the architectural principles already established?

---

## Topics to Analyze

1. Journey lifecycle

- Creation
- Activation
- Episode derivation
- Operational work
- Waiting
- Interruption
- Restart
- Reconciliation
- Completion
- Archival or disposal
  Identify which states are durable truth and which are transient observations.

2. Transition authority
   Define:

- What is a Journey transition?
- Who may request one?
- Who may authorize one?
- What evidence is required?
- What makes a transition atomic?
- How should failed or partially completed transitions behave?

3. Coordinator responsibilities
   Determine precisely what belongs to the Coordinator and what must never belong there.
4. Concurrent Journeys
   Analyze whether multiple Journeys may exist.
   If so:

- Can more than one be active?
- Can more than one own Presence?
- How is foreground ownership determined?

5. Episode identity
   Differentiate between:

- Reconstructing the same Episode
- Revisiting similar content later
- Recurring Episode purposes
- Historical replay

6. Restart reconciliation
   Determine:

- How the Coordinator discovers current truth
- How obsolete Episodes disappear
- How new Episodes are derived
- Why rendered UI is never authoritative

7. Journey controls
   Determine whether the following belong to Journey, Episode, or Feature:

- Cancel
- Postpone
- Retry
- Pause
- Resume
- Abandon
  Explain why.

8. Operations
   Clarify the relationship:
   Feature Operation
   ↓
   Journey Coordinator
   ↓
   Episode
   Determine exactly what operations publish.
   Determine exactly what they never publish.
   Should operations ever know which Episode currently exists?
9. Failure and recovery
   Analyze:

- Recoverable interruption
- Recoverable failure
- Permanent failure
- User abandonment
- Application termination
- External dependency disappearance
  Determine whether these are Journey concepts, Episode concepts, or Feature concepts.

10. Architectural invariants
    Propose the strongest Journey invariants.
    Pressure-test the model against:

- First launch
- Full Disk Access request
- User quits before granting permission
- User grants permission while MessageLens is closed
- User returns the next day
- Archive import interrupted halfway
- External drive disconnected
- Drive reconnected
- Import completes
- Journey completion
- User immediately starts another archive import
  For each scenario identify:
- Journey state
- Coordinator action
- Episode
- Completion authority
- Durable truth
  Conclude with:

1. Recommended canonical Journey model.
2. Remaining unresolved architectural questions.
3. Proposed outline for 20-JOURNEY-COORDINATION.md.
4. Any refinements suggested for the Episode Model.
   Do not modify any canonical Presence documents.
   Do not begin implementation.
