# Pending Implementations

This file tracks implementation ideas that originated in another review but
should be reconsidered when the UI walk reaches All Messages.

## UI-DEBT-002 — Add message source conversation to Working Set

Source review:

- `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/search_input_box.md`
- `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/working_set_display_mode.md`

The Conversations search-field review identified a future Working Set concept:
users may search message evidence, find several conversations relevant to an
investigation, and then collect those conversations temporarily for contextual
exploration.

That workflow depends on All Messages being able to mark or collect the
conversation associated with a message result. Therefore the implementation
should be designed here, during the All Messages review, not during the
Conversations sidebar review.

Do not implement Working Set until this review area explicitly evaluates it.

## Context Action For Every Search Message

Source:

- `search_investigation_compatibility.md`

Every message displayed in Search All Messages is removed from its
conversational ordering and should therefore expose the Context / In
Conversation action, not only messages classified as active search results.

This is a separate UI slice. It should reuse the implemented Search
investigation provenance when requesting a Conversation excerpt and must not
reintroduce imperative panel cleanup.
