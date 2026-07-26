# Search Investigation Compatibility

Canonical ownership and panel rules live in:

* [`../../../40-FEATURES/search/INTERACTIONS_AND_NAVIGATION.md`](../../../40-FEATURES/search/INTERACTIONS_AND_NAVIGATION.md)
* [`../../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md`](../../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md)

This UI-walk document records how those rules apply to Search All Messages.

## Purpose

Search All Messages distinguishes the user's primary investigation from the
subordinate Conversation context opened from one result.

The current investigation is identified by an opaque, generation-based
`SearchInvestigationId`. Equal query values do not imply the same investigation.

## Investigation transitions

The identity advances when the primary investigation changes:

* query text changes, including clearing with the field's clear button
* AND/OR mode changes
* month browsing begins from the heatmap

It does not advance when:

* the user leaves Search All Messages
* the user returns without changing the investigation
* a Conversation excerpt is opened
* another result is opened within the same investigation

## Stored and effective Conversation context

A Search-created Conversation excerpt carries the opaque identity of the
investigation that created it. Conversations owns the excerpt; Search owns the
identity lifecycle; navigation compares identity without interpreting Search
semantics.

The stored excerpt remains in the right-panel stack. It is effective only when:

1. Search All Messages is the active sidebar branch; and
2. its originating identity equals the current Search investigation identity.

When compatibility fails, the effective right-panel stack becomes empty. The
end sidebar closes through derived visibility, and the selected message anchor
disappears because message evidence reads the effective spec. No query, heatmap,
or mode control explicitly clears Conversation state.

This preserves restoration after temporary navigation away while preventing an
old excerpt from reviving after query A -> query B -> query A.

## Governing principle

> A subordinate context must never outlive the investigation that created it.

Fix compatibility and derivation when this rule is violated. Do not add
imperative cleanup calls to each new Search interaction.

## Investigation status row

The static scope description below the Search controls has become one Search
Investigation Status occupant. It derives both its description and active state
from the current Search presentation boundary:

```text
Message text contains "smok"

or, after 175 ms unresolved:

activity indicator  Message text contains "smok" · Searching...
```

The delay is presentation-local, so it suppresses transient activity chrome
without creating another source of Search state. The status text aligns with
the Search field through the shared leading control slot, and the occupant's
geometry remains stable when activity begins or completes. Vertical separation
continues to come from the explicit fixed-height matrix occupant below it, not
from status-row padding.

## Deferred next slice

Every message displayed in Search All Messages is removed from conversational
ordering and should eventually expose the Context / In Conversation action, not
only rows classified as active search results. That separate slice should reuse
the investigation provenance described here.
