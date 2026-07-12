Agreed. That second question is now resolved cleanly.

The next issue should be:

What exactly is a Working Set?

This one matters because Working Sets could otherwise drift into being a disguised tag, a temporary selection, a saved search, or a sidebar mode.

My recommendation is:

A Working Set is a user-assembled collection of Conversations gathered for an active task or investigation.

It is defined by purpose and current use, not by shared semantic meaning.

Working Set versus Tag

A Tag answers:

What do these Conversations mean?

Examples:

- Family
- Canucks
- Hawaii Trip
- Taxes

A Working Set answers:

Which Conversations am I using together for this task?

Examples:

- Conversations to review before calling the accountant
- Threads relevant to finding the Hawaii hotel booking
- Conversations involved in preparing Claire’s birthday slideshow
- People to contact about the reunion

The same Conversation may have several Tags and belong to several Working Sets.

A Working Set should not silently create or modify Tags.

What a Working Set contains

For the first design, a Working Set should contain canonical Conversation identities.

It should not initially contain:

- arbitrary message selections;
- search queries;
- notes as standalone members;
- Contacts without a selected Conversation;
- copied Conversation data.

This keeps the first model clear:

Working Set
→ ordered or unordered membership
→ canonical Conversations

Messages may lead the user to add the source Conversation to a Working Set, but the member is the Conversation.

That preserves the One Conversation principle and prevents Working Sets from becoming a generic investigation database before the feature is understood.

Creation

A temporary Working Set should be created implicitly when the user begins collecting Conversations for a task.

The user should not need to name it before using it.

Conceptually:

No active Working Set
→ Add Conversation
→ Temporary Working Set exists

The UI may call it simply Working Set until saved.

Lifetime

Working Sets begin as temporary session intent.

They become durable only through an explicit action such as:

- Save Working Set
- Keep Working Set
- Name and Save

Saving should require a name because a durable collection needs an identity the user can recognize later.

Closing or replacing an unsaved Working Set should prompt only when meaningful work would be lost. The app should avoid repeatedly asking the user to preserve trivial temporary selections.

Saved Working Sets

A saved Working Set is durable overlay-backed intent.

It should preserve:

- its name;
- its Conversation membership;
- optional ordering, if the user has deliberately arranged it;
- creation and modified dates;
- perhaps a short note or purpose later.

It should survive:

- app restart;
- graph rebuild;
- changes to Conversation display names;
- changes to sorting or filtering.

It should refer to stable Conversation identity rather than storing copies of titles or participants.

Ordering

I think Working Sets should support explicit user ordering eventually.

Unlike Tags, Working Sets often represent workflow.

For example:

1. Accountant
2. Bank
3. Contractor
4. Insurance company

That order may matter to the task.

However, explicit ordering does not need to be part of the first implementation slice. Initial behavior may preserve insertion order.

Relationship to the sidebar

A Working Set should not require a permanent third top-level sidebar mode beside All and Favourites.

Instead, the current Working Set can appear as a selected retrieval scope or temporary collection within the Conversations experience.

For example:

Conversations
Working Set: Hawaii booking
[Claire] [Air Canada] [Hilton]

or as a token in the structured retrieval control:

[ Working Set: Hawaii booking ]

Saved Working Sets may later appear in a lightweight picker, recent list, or retrieval suggestions. They should not each become fixed navigation destinations.

Adding Conversations

A Conversation should be addable to the active Working Set from any surface where its identity is known:

- Conversation Card
- Search result context
- Contact-derived Conversation list
- Conversation excerpt panel
- perhaps a message action that means “add this message’s Conversation”

The action belongs to Conversation Intent, even when invoked from Search or Messages.

Removing Conversations

Removing a Conversation from a Working Set affects only that Working Set.

It must not:

- remove Tags;
- affect Favourite status;
- hide the Conversation;
- alter graph membership;
- delete the Conversation.

Multiple Working Sets

Durable saved Working Sets should support multiple named collections.

For the first implementation, I would allow only one active temporary Working Set at a time.

That keeps the user’s current task obvious and avoids turning temporary state into a project-management system.

The user can save the current set, clear it, or replace it.

Later, saved Working Sets can be reopened and made active.

Working Set versus Saved Investigation

A Working Set is a collection of Conversations.

A Saved Investigation is likely broader.

It may eventually preserve:

- a message search query;
- selected messages;
- selected Conversations;
- retrieval tokens;
- date ranges;
- notes;
- the active Working Set;
- navigation context.

Therefore:

A saved Working Set may become one component of a Saved Investigation, but it should not attempt to be the whole investigation model.

This boundary is important. It prevents Working Sets from expanding uncontrollably.

Recommended first-slice definition

Approve the following:

- A Working Set contains canonical Conversations.
- It represents current task context, not shared meaning.
- It begins as temporary session intent.
- It becomes durable only through explicit naming and saving.
- Only one temporary Working Set is active at a time.
- Saved Working Sets may be reopened later.
- Membership can be added from any surface that knows the canonical Conversation.
- Working Sets do not alter Tags, Favourites, visibility, or graph facts.
- Saved Investigations remain a future broader concept.

The central definition is:

A Tag says why Conversations belong together. A Working Set says why the user is using them together right now.
