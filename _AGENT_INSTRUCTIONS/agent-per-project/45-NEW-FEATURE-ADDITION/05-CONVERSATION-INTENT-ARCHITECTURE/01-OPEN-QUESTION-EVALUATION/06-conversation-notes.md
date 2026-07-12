Excellent. I think we've now got a sustainable process:

1. Identify an architectural question.
2. Explore it until the abstraction becomes clear.
3. Record a single decision document.
4. Move on.

That is exactly how good architectures evolve.

---

# 06 — Conversation Notes

## Question

What is a Conversation Note?

## Recommendation

A Conversation Note is **durable Annotation intent attached to a canonical Conversation**.

It preserves **the user's own interpretation** of a Conversation.

It does **not** preserve the Conversation itself.

It does **not** replace message evidence.

---

## Purpose

Message evidence answers:

> What happened?

A Conversation Note answers:

> What do _I_ want to remember about this Conversation?

Examples:

- "Ask Cathie about the executor paperwork."
- "This is the thread where Dad agreed to sell the boat."
- "Contains the original kitchen quote."
- "This is where we decided to stay at the Hilton."

Notice that none of those statements exist in the messages themselves.

They are the user's interpretation.

---

## Why Notes are not Tags

A Tag says:

> What category does this Conversation belong to?

Examples:

- Family
- Taxes
- Hawaii
- Work

A Note says:

> What do I personally want to remember?

Those are fundamentally different.

A Conversation might have:

```
Tags

Family
Estate

Note

Contains the discussion where Dad agreed that Cathie would handle probate.
```

The Tag helps retrieve.

The Note preserves meaning.

---

## One note or many?

I recommend **one editable Conversation Note** initially.

Why?

Because the question is singular:

> What do I want to remember about this Conversation?

Not

> What collection of notes have I accumulated over three years?

Multiple notes immediately introduce:

- timestamps
- ordering
- deletion
- editing history
- threading
- searching
- scrolling

None of that is necessary to prove the concept.

One note keeps the feature focused.

---

## Relationship to Messages

Conversation Notes belong to Conversations.

They are **not** attached to individual messages.

Later, MessageLens may support message annotations.

Those are a different architectural concept.

Conversation Note:

> This Conversation contains the hotel booking.

Message Annotation:

> This specific message contains the confirmation number.

Those should remain distinct.

---

## Relationship to AI

AI may suggest a Conversation summary.

That is **not** a Conversation Note.

Conversation Notes represent the user's memory.

AI summaries represent generated interpretation.

The user may choose to copy or edit an AI summary into their own Note.

Only then does it become Conversation Intent.

---

## Retrieval

Conversation Notes naturally support retrieval.

Examples:

```
Has Notes
```

or

```
Search only inside Conversation Notes
```

Notice that this is different from searching message evidence.

Searching Notes searches user interpretation.

Searching Messages searches evidence.

---

## UI

Notes should be visible without dominating the Conversation.

My instinct is:

Conversation Card

↓

small "note" indicator

↓

Conversation Details

↓

full editable note

The note should feel like metadata about the Conversation, not another message.

---

## Architectural Rule

Conversation Notes are **Annotation intent**.

They answer:

> What do I want to remember about this Conversation?

They do not modify:

- graph facts
- message evidence
- Conversation identity
- source data

---

## Future Growth

Later features might include:

- message annotations
- AI-generated summaries
- reminders
- links
- pinned evidence
- note history

None of these should complicate the first implementation.

The first implementation should answer exactly one question:

> **If I return to this Conversation in five years, what do I wish my past self had told me?**

---

## Recommendation

**Approve.**

Conversation Notes should be:

- durable Conversation Intent;
- one editable note per Conversation initially;
- attached to canonical Conversation identity;
- distinct from Tags;
- distinct from message annotations;
- owned by the Conversations feature;
- stored in overlay;
- merged into read models;
- searchable independently of message evidence.

---

I think this may be my favorite decision so far.

There's something deeply aligned with MessageLens about it. A Conversation Note isn't about organizing data—it's about extending memory. It lets the user leave a message for their future self. That's a capability no messaging app has, and it fits the philosophy of MessageLens remarkably well.
