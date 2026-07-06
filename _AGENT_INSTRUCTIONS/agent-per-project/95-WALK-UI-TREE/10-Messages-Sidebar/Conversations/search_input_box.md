# Review

---

## Surface

Messages sidebar -> Conversations -> Browse mode -> "Find conversations" search field.

This review covers the search input shown above the Conversations sidebar filter/sort controls.

---

## Purpose

The search field currently appears to help the user narrow the conversation list.

The central review question is whether this field deserves to exist at all. It should not be preserved merely because it is available. It should remain only if it supports a meaningful workflow that is not already better served elsewhere in MessageLens.

---

## User Goals

- Find conversations involving a known person or handle.
- Search for message content and inspect evidence.
- Move from message evidence into conversation context when needed.
- Avoid confusing search surfaces that appear similar but search different data.
- Understand whether they are searching conversation identity or message bodies.

---

## Current Behaviour

The field filters only the conversation metadata already loaded for the Conversations sidebar.

Currently included:

- conversation display title
- participant names / labels / handles
- latest message preview

Currently not included:

- full message history
- all messages in a conversation
- attachment text or media metadata
- recovered/deleted-message evidence

Examples:

- Searching for `Claire` matches because it is a conversation title or participant label.
- Searching for a phone/email fragment may match because participant handles are included.
- Searching for `Kelowna` only matches if the latest preview happens to contain that word.

---

## What Works Well

- The field can quickly narrow the list by visible conversation identity.
- It is lightweight and local to Browse mode.
- It may help when the user remembers a participant handle but does not want to switch to Contacts.
- It does not currently trigger expensive full-message searches from the sidebar.

---

## Issues

| Priority | Description |
| -------- | ----------- |
| High | The label "Find conversations" overpromises. Users reasonably expect message-content search across conversations. |
| High | The actual search scope is narrow and non-obvious: title, participants, handles, and latest preview only. |
| High | Searching for people is already better served by Contacts -> Conversations. |
| High | Searching message content is already better served by All Messages / evidence search. |
| Medium | Including latest message preview makes the search feel inconsistent because some content terms match by accident while most do not. |
| Medium | The field adds visual and cognitive weight to the Conversations sidebar without a clearly distinct workflow. |
| Low | If retained, it would need clearer wording such as "Find by person or handle", but even that may duplicate better surfaces. |

---

## UX Observations

- Conversations is primarily a conversation browser, not an evidence search surface.
- All Messages is the stronger place to search message bodies because it can show exact matching evidence, highlighting, and context.
- Contacts -> Conversations is the stronger place to find conversations involving a known person.
- The current field risks teaching the user an incorrect mental model: that Conversations search can search what was said.
- Removing a weak control may improve clarity more than renaming or redesigning it.
- The current Favourites/Browse split makes Browse controls more prominent; weak controls in that area now matter more.

---

## Proposed Improvements

Treat the existing search field as a candidate for removal.

Recommended direction for the next implementation slice:

- Remove the "Find conversations" input from the Conversations Browse control group.
- Preserve the existing Show and Sort controls.
- Do not replace it with another conversation-title search field unless a compelling user workflow emerges.

Do not implement full message search inside the Conversations sidebar for this review.

Rationale:

- People/contact discovery belongs primarily in Contacts -> Conversations.
- Message-content discovery belongs primarily in All Messages.
- Conversations should remain the conversation browser and contextual exploration surface.

---

## Future Design Direction: Working Set

Record a future concept: Working Set.

A Working Set would be a temporary collection of conversations assembled during an investigation or search session.

Example workflow:

```text
Search "Kelowna"
-> All Messages
-> Five conversations contain Kelowna
-> Add conversations to Working Set
-> Switch to Conversations
-> Explore those conversations in context
```

Working Set is distinct from Favourites:

- Favourites are long-term, user-curated relationship anchors.
- Working Set is temporary, task/session-oriented, and investigation-driven.

This is a future design concept only. Do not implement it as part of this review.

For now, users can approximate this workflow by temporarily favouriting conversations and later removing them.

---

## Acceptance Criteria

- [ ] The review explicitly flags the current search field as a candidate for removal.
- [ ] The review explains that current search includes title, participant labels/handles, and latest preview only.
- [ ] The review explains that current search does not search full message history.
- [ ] The review explains why people search is better served by Contacts -> Conversations.
- [ ] The review explains why message-content search is better served by All Messages.
- [ ] The review records Working Set as a future concept distinct from Favourites.
- [ ] No Working Set implementation is proposed for the current slice.
- [ ] Any implementation plan keeps scope limited to the Conversations sidebar Browse control group.

---

## Notes

If the field is removed, this should not be understood as rejecting search in conversation workflows generally. It means the current sidebar-local metadata search is not strong enough to justify its cost.

Future conversation-oriented search should begin from evidence search and then support movement into conversation context, rather than duplicating message search inside the conversation browser.

---

## Status

- [ ] Not Started
- [x] Under Review
- [ ] Ready for Codex
- [ ] Implemented
- [ ] Verified
