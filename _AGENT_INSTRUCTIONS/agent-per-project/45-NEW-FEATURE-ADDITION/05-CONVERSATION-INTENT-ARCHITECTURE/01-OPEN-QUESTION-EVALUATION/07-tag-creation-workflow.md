# Open Question Evaluation: Tag Creation and Management Workflow

The Conversation Intent architecture is now considered settled.

The Conversation Tags package has been consolidated and now contains primarily tag-specific product questions.

Please create a new evaluation document under:

\_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/

named something like:

07-tag-creation-and-management-workflow.md

This is an exploratory product-design evaluation.

Do not modify application source code.

Do not modify the Conversation Intent package.

Do not modify the Conversation Tags package.

Do not modify previous evaluation documents.

Append all work performed to DOCUMENTATION_PASS_LOG.md.

---

# Question

What is the correct workflow for creating, editing, and managing Conversation Tags?

The objective is to maximize the likelihood that users will naturally adopt tags without making tagging feel like filing or administration.

---

# Guiding Philosophy

Tags should emerge naturally while the user is working with Conversations.

The primary workflow should be:

"I am looking at this Conversation."

↓

"This Conversation is about Hawaii."

↓

Create or apply the "Hawaii Trip" tag.

Tagging should feel like preserving meaning, not organizing files.

---

# Evaluate

Consider questions such as:

- Where should the first tag normally be created?
- Should tag creation happen inline from a Conversation?
- Should there be a global Tag Manager?
- If so, should it be primary or secondary?
- When should users ever need to visit a Tag Manager?
- How should existing tags be selected?
- How should new tags be created?
- How should duplicate names be prevented?
- How should renaming work?
- How should deletion work?
- How should tag cleanup work as the number of tags grows?
- How should tags appear on Conversation Cards?
- How should compact cards differ from expanded surfaces?

---

# Product Principles

Assume:

- Tags are durable Meaning intent.
- Tags are not folders.
- Tags should encourage retrieval and discovery.
- Tags should not create administrative burden.
- The feature should encourage users to think about Conversations, not about maintaining a taxonomy.

---

# Explore

Evaluate whether the product should primarily be:

Conversation-first

or

Tag-first.

The current hypothesis is:

Conversation-first.

Users naturally create tags while viewing Conversations.

A Tag Manager becomes useful only after tags already exist.

Determine whether this philosophy appears sound.

---

# Deliverable

Produce a recommendation covering:

- primary workflow
- secondary workflow
- lifecycle of a tag
- relationship to Conversation Cards
- relationship to Structured Conversation Retrieval
- scalability
- UX risks
- implementation guidance (high level only)

Conclude with a clear recommendation for the first implementation slice.

Do not propose implementation details.

Do not redesign the Conversation Intent architecture.

The objective is to determine how tagging should feel from the user's perspective.
