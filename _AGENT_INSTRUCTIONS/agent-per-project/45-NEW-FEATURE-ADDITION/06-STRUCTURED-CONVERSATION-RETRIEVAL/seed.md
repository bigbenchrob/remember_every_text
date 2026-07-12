I think this one is going to be fun.

More importantly, I think it becomes one of those documents that changes the way people think about MessageLens. It isn't defining a widget; it's defining a new interaction model.

I'd deliberately make it a **product philosophy** document rather than a UI specification.

---

# Feature Proposal: Structured Conversation Retrieval

Please create a new work package under:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/`

This is **not** an implementation task.

Do not modify application source code, tests, configuration, generated files, databases, or assets.

You may read anywhere in the repository.

Documentation changes are confined to the new work package and `DOCUMENTATION_PASS_LOG.md`.

---

# Purpose

Define the product philosophy and architectural model for **Structured Conversation Retrieval**.

This feature replaces the traditional "search conversations" mindset with a retrieval system based on **Conversation metadata** and **Conversation Intent**.

The goal is not to search message content.

The goal is to help the user progressively narrow the Conversation universe until the desired Conversation becomes obvious.

---

# Core Principle

There are two fundamentally different retrieval systems in MessageLens.

## All Messages Search

Answers:

> Where was this said?

It operates on message content.

It returns message evidence.

---

## Structured Conversation Retrieval

Answers:

> Which Conversation am I trying to work with?

It operates on:

- Conversation identity
- Conversation metadata
- Conversation Intent

It returns Conversations.

These two systems solve different problems and should remain conceptually distinct.

---

# Retrieval Philosophy

Conversation Retrieval should not feel like typing into a generic search box.

Instead, it should feel like progressively describing the Conversation being sought.

The user builds a retrieval expression from structured tokens.

Example:

```
👤 Claire
🏷 Family
★ Favourite
```

Each accepted token becomes a badge.

Typing continues after each badge is accepted.

The retrieval field remains active until the user is finished describing the desired Conversations.

---

# Typeahead

Typing should present structured candidates.

Examples:

Typing:

```
cla
```

suggests:

```
👤 Claire
```

Typing:

```
fam
```

suggests:

```
🏷 Family
```

Typing:

```
fav
```

suggests:

```
★ Favourite
```

Selecting a suggestion converts it into a badge rather than leaving free-form text.

This emphasizes that the user is selecting known Conversation metadata or Conversation Intent rather than performing substring search.

---

# Token Types

Initially explore tokens such as:

- 👤 Contact
- 🏷 Tag
- ★ Favourite
- 📁 Working Set
- 👥 Group Conversation
- 🚫 Suppressed
- 📝 Has Notes

Do not treat this list as complete.

The architecture should support future Conversation metadata and Conversation Intent tokens naturally.

---

# Relationship To Conversation Intent

Conversation Retrieval consumes Conversation Intent.

It does not own it.

Conversation Retrieval should be able to retrieve Conversations using:

- Tags
- Favourites
- Working Sets
- Visibility
- Notes
- future Conversation Intent

without defining those concepts itself.

---

# Relationship To Conversation Lenses

Conversation Retrieval determines:

> Which Conversations?

Conversation Lenses determine:

> How should those Conversations be viewed?

Examples:

```
Tokens

👤 Claire
🏷 Family

↓

Lens

Dormant

↓

Conversation list
```

or

```
Tokens

🏷 Canucks

↓

Lens

Most Recently Active

↓

Conversation list
```

Retrieval and Lenses should remain orthogonal.

---

# Relationship To Search

Structured Conversation Retrieval must never become message-content search.

Examples:

Searching for:

```
Hawaii
```

should not silently search message text.

Instead it might suggest:

```
🏷 Hawaii Trip
```

or

```
👤 Hawaii Travel Group
```

if such metadata exists.

Searching message content remains the responsibility of All Messages Search.

---

# Product Philosophy

Structured Conversation Retrieval should feel like retrieving memories by meaning rather than searching text.

The experience should encourage recognition rather than query construction.

Users should gradually assemble meaningful Conversation descriptors rather than invent search syntax.

The resulting Conversation list should become increasingly focused until the desired Conversation is obvious.

---

# Future Growth

The architecture should naturally accommodate future token types without redesign.

Potential future examples include:

- AI-confirmed classifications
- Attachment presence
- Date-based Conversation characteristics
- Conversation age
- Dormancy
- Participation patterns
- Future Conversation Intent categories

Adding a new retrieval token should not require inventing another sidebar mode.

---

# Deliverables

Create a complete exploratory work package including:

- overview
- proposal
- design notes
- UX philosophy
- architectural considerations
- relationship to Conversation Intent
- relationship to Conversation Lenses
- relationship to All Messages Search
- open questions
- implementation phases
- validation strategy
- completion checklist

---

# Success Criteria

After reading this package, a future developer should understand:

- why Structured Conversation Retrieval exists;
- why it is fundamentally different from message search;
- how badge-based retrieval works;
- why retrieval operates on Conversation metadata and Conversation Intent;
- how retrieval and Conversation Lenses complement each other;
- and how this architecture allows MessageLens to grow without accumulating additional sidebar modes or one-off retrieval interfaces.

Append all work performed to `DOCUMENTATION_PASS_LOG.md`.

I have a feeling this is going to become one of the signature interaction models of MessageLens. The moment we shifted from "search box" to "structured retrieval," the whole thing started to feel less like a messaging app and more like a tool for navigating memory. That's a genuinely distinctive direction.
