# Open Question Evaluation: Tag Visibility Policy

## Question

Should Conversation visibility be modeled as a separate Conversation Intent type, or should visibility be expressed as a property of Tags?

## Original Thinking

The original Conversation Intent architecture treated **Suppressed** as its own Conversation Intent category.

The model was:

    Conversation
        ↓
    Suppressed

This worked, but it introduced a second mechanism alongside Tags.

One mechanism expressed:

> What this Conversation means.

The other expressed:

> Whether this Conversation should normally appear.

Although functional, the two concepts evolved independently despite often describing the same underlying class of Conversations.

---

## Implementation Experience

During implementation and early manual use, a practical example emerged.

Several Conversations were tagged:

- 2FA
- Frequent
- Kelowna
- Family

The natural next thought was not:

> Hide this particular Conversation.

Instead it was:

> I almost never want to browse **2FA Conversations**.

That realization changed the architectural model.

The user was not trying to suppress one Conversation.

The user was trying to suppress an entire class of Conversations.

Examples include:

- 2FA
- Spam
- Delivery Notifications
- One-off Business
- Appointment Reminders

Those are semantic categories.

The suppression belongs to the category itself.

---

## Revised Model

Instead of:

    Conversation
        ↓
    Suppressed

the preferred model becomes:

    Conversation
        ↓
    Tag Assignment
        ↓
    Tag Definition
        ↓
    Visibility Policy

Conversation visibility is therefore determined by the Tags attached to it.

The Conversation itself no longer requires a separate suppression mechanism.

---

## Product Philosophy

Suppression is not about pretending a Conversation does not exist.

It is about saying:

> Conversations of this type are rarely useful during ordinary browsing.

This fits the MessageLens philosophy of emphasizing meaningful information rather than removing information.

The graph remains complete.

The user's browsing experience becomes more focused.

---

## Advantages

### One Less Architectural Mechanism

Conversation Intent no longer requires both:

- Tag assignment
- Conversation suppression

A single Tag system provides:

- classification;
- retrieval;
- visibility policy.

This simplifies both implementation and future maintenance.

### Bulk Suppression

Applying a suppressing Tag immediately affects every Conversation carrying that Tag.

Examples:

- 2FA
- Spam
- Delivery
- One-off Business

The user no longer needs to suppress Conversations individually.

Instead they classify them once.

### Better Retrieval

Suppressed Conversations are not lost.

Structured Conversation Retrieval can still retrieve them explicitly.

For example:

> 🏷 2FA

returns all suppressed 2FA Conversations.

Default Browse remains clean while retrieval remains complete.

### Better Discovery

Users may later ask:

> Show suppressed Conversations.

or

> Show Conversations tagged 2FA.

Nothing has been deleted.

Only the default browsing policy has changed.

---

## User Interface

The implementation does not need to expose "Tag Visibility Policy" directly.

The UI may instead provide familiar actions such as:

- Hide Conversation
- Suppress from Browse

Internally these actions simply apply an appropriate suppressing Tag.

Likewise, some Tags may appear in a separate section of the Tag editor.

Example:

**Meaning**

- Family
- Kelowna
- Taxes

**Suppress from ordinary browsing**

- 2FA
- Spam
- Delivery

This communicates the consequence without exposing implementation details.

A generic **Hidden** Tag may also exist as a built-in system Tag for users who simply wish to hide a single Conversation without creating a more descriptive category.

---

## Architectural Principle

Visibility is better modeled as **policy attached to Tag definitions** than as a separate Conversation-level intent.

Conversation Intent remains attached to canonical Conversation identity.

Tags remain Meaning intent.

Visibility becomes a property of certain Tag definitions.

This removes an entire architectural mechanism while making suppression more powerful, more semantic, and more scalable.

---

## Decision

**Approve.**

Conversation visibility should be implemented as **Tag Visibility Policy**.

Rather than storing a separate suppression state on Conversations, suppression should be expressed through Tag definitions whose visibility policy excludes matching Conversations from ordinary browsing and Discovery.

Structured Conversation Retrieval should always be able to retrieve those Conversations explicitly through their Tags.

This architecture unifies:

- semantic classification;
- bulk suppression;
- retrieval;
- discovery;
- future visibility management;

under a single, consistent Tag model.
