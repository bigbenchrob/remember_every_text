# Visual Language

## Conversation Manifestations

When the same Conversation appears in multiple places, reuse the same core
Conversation Card grammar wherever practical:

- participant/title identity
- conversation metadata
- timeline/signature glyph
- Favourite state/action

Local layout may adapt to available space, but the user should recognize that
each manifestation refers to the same Conversation entity.

Do not create visually unrelated local versions of a Conversation unless a
review explicitly justifies the exception.

When a Conversation Card appears as the header for a right-side search-result
excerpt, it should read as the parent Conversation identity, not as another
message item. The excerpt label and highlighted message then explain why this
particular window is being shown.

Blue remains the language of current focus or interaction. Orange remains the
language of correspondence: the same message or Conversation appearing in
another lens.

## Peer Panel Bands

Primary peer panels should share a common vertical rhythm so they feel like
parts of one application surface rather than independently designed columns.

The preferred band order is:

1. Panel title: the lens or surface identity.
2. Primary object/mode information: the thing currently being inspected or the
   main mode context.
3. Secondary metadata/interactions: search controls, excerpt descriptions,
   scope notes, or explanatory controls.
4. Content: the actual navigable evidence or results.

Examples:

- Search sidebar: `Search all messages` -> search mode/context -> supporting
  controls or guidance -> heatmap/navigation.
- Center panel: `All messages` -> result/date/count metadata -> search controls
  -> message results.
- Right sidebar: `Conversation` -> Conversation Card -> excerpt description ->
  conversation excerpt.

Do not use panel titles to narrate how the user arrived at a view. The title
names the lens. The primary object block identifies the selected object.

Extended usage guidance should not create an extra band above primary content.
Keep persistent orientation copy short in the primary information band, then
place task guidance or how-to text after the primary content as
post-content guidance.

Post-content guidance is not leftover overflow. It has its own role: it teaches
how the current panel connects to neighbouring panels after the user has seen
the primary navigation or evidence object. For example, Search sidebar copy
above the heatmap establishes the heatmap's scope, while copy below the heatmap
can explain how the heatmap, message list, and search controls work together.
