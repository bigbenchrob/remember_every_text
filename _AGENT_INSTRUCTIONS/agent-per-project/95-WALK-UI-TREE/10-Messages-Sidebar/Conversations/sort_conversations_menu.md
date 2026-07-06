# Review

---

## Surface

Messages sidebar -> Conversations -> Browse mode -> Sort menu.

This review covers the Sort menu used to order the conversation signature list
after the Show filter has selected the conversation universe.

---

## Purpose

Sort should help the user choose the most useful ordering for the currently
visible Browse results.

It should answer questions such as:

- What was updated most recently?
- Which conversations have the most total evidence?
- Which conversations by date of creation?
- Which conversations started most recently?
- Which conversations have the longest first-to-last span?
- Which conversations have gone quiet?

---

## User Goals

- Bring recently updated conversations to the top.
- Find the largest conversations by total message count.
- Find the oldest-starting conversations.
- Find conversations that started most recently.
- Find conversations with the longest first-to-last span.
- Find dormant conversations without relying on unclear "revived" semantics.
- Avoid interacting with Sort when the visible result set is already very
  small.

---

## Current Behaviour

The Sort menu currently includes:

- Recent
- Largest
- Longest-running
- Most active recently

Current issues observed in real use:

- `Recent` and `Most active recently` are hard to distinguish.
- `Largest` is vague.
- `Longest-running` was ambiguous: it could mean oldest start date or longest
  first-to-last duration.
- Sort remains active even when Show narrows the result set to six
  conversations or fewer, where sorting adds little value.

---

## What Works Well

- Sort belongs in Browse mode when the result set is large enough to need
  ordering.
- Sorting is useful in combination with Show; for example, Show `High activity`
  plus a start-date or span sort can surface important recurring family/friend
  conversations.
- The Sort control's visual placement and label weight are appropriate.
- `Most active recently` is understandable as a concept, but the label should
  become more direct.

---

## Issues

| Priority | Description |
| -------- | ----------- |
| High | `Recent` and `Most active recently` are ambiguous as separate choices. |
| High | `Longest-running` is ambiguous between oldest start date and first-to-last span. |
| High | Sort should be disabled when Show narrows the list to six conversations or fewer. |
| Medium | `Largest` is vague; `Most total messages` would be clearer. |
| Medium | `Dormant/revived` as a Show option is nebulous and should be removed from Show. |
| Medium | A `Dormant` sort order is clearer than a dormant/revived filter because it simply reverses recency. |

---

## UX Observations

- Sort should describe ordering, not semantic categories.
- Show should define the visible universe; Sort should order that universe.
- Each Sort mode should visually emphasize the summary metadata that explains
  the current ordering.
- When Sort is `Most recently updated`, a quiet time cue beside each
  conversation title is useful only for conversations updated today.
- If the visible universe is very small, Sort becomes low-value and should
  visibly disable rather than invite unnecessary interaction.
- "Recently updated" maps to user intuition better than abstract recency or
  activity language.
- Start-date sorting and span sorting should be separate options because they
  answer different questions.
- "Dormant" is easiest to understand as the reverse of "Most recently updated".

---

## Proposed Improvements

Revise Sort options to:

- Most recently updated
- Most total messages
- By date of creation
- Started most recently
- Longest first-to-last span
- Dormant

Revise Show dependencies:

- Add Show: `All`
- Remove Show: `Dormant/revived`

Disable Sort when the current Show selection narrows the visible conversation
list to six conversations or fewer.

Expected sort semantics:

- Most recently updated: newest `lastMessageAtUtc` first.
- Most total messages: largest `messageCount` first.
- By date of creation: oldest `firstMessageAtUtc` first.
- Started most recently: newest `firstMessageAtUtc` first.
- Longest first-to-last span: longest span between first and last message first.
- Dormant: oldest `lastMessageAtUtc` first.

Highlight the relevant summary metadata for each Sort mode:

- Most recently updated: highlight the ending date. If the ending date is today,
  display the update time beside the title.
- Most total messages: highlight the message count.
- By date of creation: highlight the starting date.
- Started most recently: highlight the starting date.
- Longest first-to-last span: highlight both dates and display the span in
  months beside the title.
- Dormant: do not highlight the metadata date; the glyph ring carries the
  dormancy signal.

The title-side cue is contextual ordering information, not durable conversation
metadata.

In `Dormant` mode, mark the last active month in the glyph with an orange ring.
This preserves the month dot's heatmap fill while making the inactive span from
last message to today easier to read. The exact last-message date remains
available in the metadata range without additional emphasis.

---

## Acceptance Criteria

- [x] Sort option `Recent` is removed or renamed so it no longer overlaps with
      `Most active recently`.
- [x] Sort option `Most active recently` becomes `Most recently updated`.
- [x] Sort option `Largest` becomes `Most total messages`.
- [x] Sort option `By date of creation` is added.
- [x] Sort option `Started most recently` is added.
- [x] Sort option `Longest first-to-last span` is added.
- [x] Sort option `Dormant` is added.
- [x] Show option `All` is added.
- [x] Show option `Dormant/revived` is removed.
- [x] Sort is disabled when the current Show result set contains six
      conversations or fewer.
- [x] Disabled Sort remains visually understandable and does not look broken.
- [x] Sort modes highlight the metadata segment that explains the ordering.
- [x] Most recently updated mode displays a quiet update-time cue beside the
      title only for conversations updated today.
- [x] Longest first-to-last span mode displays a quiet span-length cue beside
      the title.
- [x] Dormant mode highlights the last active glyph month with an orange ring.
- [x] No center-pane selection or message evidence behaviour changes.

---

## Notes

This review changes the previous tentative judgment that `Dormant/revived` could
remain. It should be removed because the concept is nebulous and better
represented by a `Dormant` sort order.

---

## Status

- [ ] Not Started
- [ ] Under Review
- [ ] Ready for Codex
- [x] Implemented
- [ ] Verified
