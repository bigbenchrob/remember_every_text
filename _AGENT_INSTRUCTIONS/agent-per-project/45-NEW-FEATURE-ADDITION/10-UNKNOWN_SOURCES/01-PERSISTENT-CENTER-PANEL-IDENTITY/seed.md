# Persistent Center-Panel Identity

## Background

The introduction of the Unknown Sources investigations (Identify and Numeric IDs) revealed a weakness in the current center-panel architecture.

The current implementation treats the absence of a selected source as though the center panel itself has disappeared.

An idle presentation was added to prevent the Track Matrix from collapsing, but that implementation exposed a deeper issue:

The center-panel header itself has no persistent identity.

Instead it repeatedly changes role.

Examples:

    Numeric sender IDs
        (repeating the selected sidebar investigation)

    Identify unknown sources
        (an instruction masquerading as a page title)

    75137
        (promoting the selected record identifier to the page title)

The result is that the center panel feels as though it repeatedly disappears and is replaced by different miniature pages.

I believe the center panel should instead have a stable semantic identity.

---

# Governing Principle

The center-panel header should identify the enduring presentation, not echo the current control state or promote the selected record’s identifier into a page title.

The sidebar determines which investigation supplies the messages.

A selected source determines whose messages are currently shown.

Neither should replace the semantic identity of the center panel.

---

# A Stable Information Hierarchy

The center panel should always begin with a Messages-oriented heading.

Examples:

    Messages from unknown sources

or

    Messages from numeric IDs

That heading should remain constant throughout the investigation.

Beneath it, the presentation changes.

---

## Idle Investigation

The idle state is not merely "nothing selected."

It is the active investigation with no current target.

Rather than simply instructing the user to click something, the center panel should explain:

- what the current investigation contains;
- why these items appear here;
- what actions are available;
- what the user is expected to do (if anything).

The large empty center panel is an opportunity to orient the user.

For example:

    Messages from numeric IDs

    Numeric IDs are commonly used for authentication codes,
    delivery updates, appointment reminders, alerts, and other
    automated messages.

    You can select one to review its messages. Nothing here
    requires action. Sources you dismiss remain available from
    the Show menu.

Likewise:

    Messages not linked to a contact

    These phone numbers, email addresses, and business identities
    could not be matched to a contact in your Mac's Contacts data.

    Select one to review its messages. When you recognize it,
    you can link it to an existing contact or create a
    MessageLens contact so its messages are identified in future.

The wording is illustrative rather than final.

The important idea is that the idle state explains the investigation rather than merely requesting a selection.

---

## Selected Target

Once a source has been selected, the overall page identity remains unchanged.

Instead of:

    75137

becoming the page title, it becomes the current subject.

For example:

    Messages from numeric IDs

    75137
    March 2026 · 3 messages

    [search]
    [Dismiss]

    [messages]

Likewise:

    Messages not linked to a contact

    (604) 307-8325
    May 2018 – June 2020 · 243 messages

    [search]
    [Create Contact]
    [Link to Existing]
    [Dismiss]

    [messages]

The selected source is the subject.

The page heading remains the identity.

---

# Conceptual Model

The center panel contains three distinct layers.

Panel identity

    Messages from numeric IDs

Investigation explanation

    What these sources are.
    Why they appear here.
    What the user can do.

Current target

    75137

The current implementation collapses all three concepts into one interchangeable title slot.

I believe these should become explicit layers.

---

# Architectural Principle

An unselected investigation state should explain what the user is seeing, why those items are grouped together, and what actions are available—not merely instruct them to select something.

---

# Generalization

Although discovered while implementing Unknown Sources, I suspect this principle applies more broadly.

Investigation-based pages should possess:

- a persistent semantic identity;
- an explanatory idle presentation;
- a selected-target presentation.

Selection changes the subject of the investigation.

It should not redefine the identity of the page itself.

---

# Relationship To Existing Principles

This proposal complements several existing MessageLens architectural principles.

- Track Matrix
  The matrix continues to negotiate truthful geometry.

- Investigation Flow
  The investigation remains active even without a selected target.

- Mechanical Impossibility Principle
  The center panel should never become architecturally absent while an investigation remains active.

Instead, the active investigation always projects one truthful presentation.

The selected target merely determines which truthful presentation variant is currently displayed.
