# Conversation Tags Consolidation Pass

The Conversation Intent architecture is now considered the canonical foundation for user-authored Conversation meaning.

Please perform a documentation consolidation pass for:

\_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/

This is **not** an implementation task.

Do not modify application source code, tests, configuration, generated files, databases, or assets.

You may read anywhere in the repository.

Documentation changes are confined to:

- the Conversation Tags work package
- DOCUMENTATION_PASS_LOG.md

Do not modify the Conversation Intent package or its evaluation documents.

---

# Objective

Conversation Tags should now become a focused feature package built on top of the Conversation Intent architecture.

It should no longer redefine architectural concepts that are now owned elsewhere.

Instead, it should describe what makes Tags unique as a user-facing feature.

---

# Architectural Ownership

Assume the following concepts are now owned by the Conversation Intent architecture:

- Conversation Intent
- Intent Categories
- Intent Lifetimes
- Overlay ownership
- Stable Conversation identity
- Working Sets
- Suppressed visibility
- Conversation Notes
- Structured Conversation Retrieval
- General Conversation Intent architecture

Do not duplicate these concepts.

Reference them where appropriate.

---

# Tags Should Focus On

The package should now primarily answer questions such as:

- What problem do Tags solve?
- Why are Tags useful to MessageLens?
- What makes Tags different from other Conversation Intent categories?
- How should users create Tags?
- How should users rename Tags?
- How should duplicate Tags be handled?
- Should Tags support colour?
- How should Tags appear on Conversation Cards?
- How should tag editing feel?
- How should tag management scale?
- How do Tags support retrieval and discovery?

These are product questions rather than architectural questions.

---

# Relationship To Conversation Intent

Tags are now understood to be:

- durable Meaning intent;
- attached to canonical Conversation identity;
- stored through the Conversation Intent seam;
- consumed by Structured Conversation Retrieval;
- consumed by Conversation Lenses.

The package should simply reference those architectural decisions rather than repeating them.

---

# Open Questions

Review the remaining open questions.

Remove any that have already been resolved by the Conversation Intent package.

Leave only questions that are genuinely specific to the Tags feature.

---

# Philosophy

The Conversation Intent package explains how the architecture works.

The Conversation Tags package should explain why Tags exist and how users experience them.

Architecture belongs in Conversation Intent.

Product behaviour belongs in Conversation Tags.

---

# Deliverables

Update, where appropriate:

- README.md
- PROPOSAL.md
- DESIGN_NOTES.md
- CHECKLIST.md
- TESTS.md

Append all work performed to DOCUMENTATION_PASS_LOG.md.

The goal is for the Conversation Tags package to become a concise feature specification that depends on the Conversation Intent architecture rather than re-explaining it.
