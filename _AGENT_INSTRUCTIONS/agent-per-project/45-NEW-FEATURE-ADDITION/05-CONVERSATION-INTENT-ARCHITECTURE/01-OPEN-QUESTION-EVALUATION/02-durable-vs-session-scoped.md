The next issue should be:

# Which Conversation Intent types are durable, and which are session-scoped?

This needs to be resolved before we decide what a Working Set actually is.

## Recommended model

Conversation Intent should support at least three lifetimes.

### Durable intent

This is meaning the user expects MessageLens to remember indefinitely.

Examples:

- Core Favourite
- Tags
- Hidden or ignored status
- Conversation notes
- user-confirmed classifications

Durable intent belongs in overlay storage and survives:

- application restarts
- graph rebuilds
- reimport
- changes to Conversation display names
- changes to sorting or sidebar state

### Session-scoped intent

This is temporary working context that exists only while the user is actively exploring.

Examples:

- a provisional collection of Conversations assembled during the current investigation
- temporary selections
- uncommitted filters
- short-lived comparison groups

Session intent should not automatically become permanent user data.

It may live in application state rather than durable overlay storage.

### Persistable working intent

I think Working Sets need a middle category.

A Working Set may begin as temporary:

> These are the Conversations I am examining right now.

But the user may later decide:

> Keep this so I can return to it.

Therefore, a Working Set should probably support an explicit transition:

```text
temporary Working Set
→ save
→ durable Working Set
```

The system should not force every investigation to become permanent, but it also should not discard useful work merely because the app closes.

## Why this distinction matters

Without explicit lifetime semantics, MessageLens could accumulate large amounts of accidental user intent:

- abandoned searches
- temporary selections
- one-time investigations
- speculative AI suggestions
- obsolete working groups

Conversely, treating everything as temporary would undermine MessageLens’s purpose as a memory and rediscovery application.

The user must be able to distinguish:

> I am working with this now.

from:

> This is part of how I permanently understand my communication history.

## Recommended classification

| Intent type                                   | Default lifetime                 |
| --------------------------------------------- | -------------------------------- |
| Core Favourite                                | Durable                          |
| Tag                                           | Durable                          |
| Hidden / ignored                              | Durable                          |
| Conversation note                             | Durable                          |
| Confirmed AI classification                   | Durable                          |
| Unconfirmed AI suggestion                     | Temporary                        |
| Working Set                                   | Temporary until explicitly saved |
| Saved Working Set                             | Durable                          |
| Current filters and selected retrieval tokens | Session-scoped                   |
| Saved Investigation                           | Durable                          |

## Working Sets are not Tags

A Working Set and a Tag may contain the same Conversations, but they express different things.

A Tag says:

> These Conversations share meaning.

A Working Set says:

> These are the Conversations I am currently using together for a task.

For example:

- `Hawaii Trip` may be a durable Tag.
- `Find the hotel booking discussion` may be a temporary Working Set containing several Hawaii-tagged Conversations.
- The user might save that Working Set if it becomes an investigation they expect to revisit.

A temporary Working Set should not silently create or alter Tags.

## Storage consequence

The shared Conversation Intent architecture should not assume that every intent assignment is persisted identically.

It needs a lifetime distinction, but that does not necessarily require one generic storage structure for everything.

The important architectural rule is:

> Conversation Intent shares identity and ownership principles, but different intent types may have different persistence lifetimes.

## Recommendation

**Approve the following model:**

- Favourites, Tags, Hidden state, Notes, and confirmed classifications are durable.
- Ordinary filters and selections are session state.
- Working Sets begin as temporary working context.
- The user may explicitly save a Working Set, converting it into durable intent.
- Temporary state must never silently become durable.
- Durable intent must never be lost merely because it was first created during an exploratory session.

This gives Working Sets a clear identity without turning them into either disposable selections or disguised Tags.
