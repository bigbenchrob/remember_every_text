---
tier: project
scope: sidebar-info-card-typography
owner: @rob
last_reviewed: 2026-04-26
source_of_truth: doc
links:
  - ./README.md
  - ./00-sidebar-cassettes-controls-and-info-cards.md
  - ./20-navigation-row-emphasis-rules.md
  - ../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
  - ../42-SPEC-SYSTEM/REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
tests: []
---

# Info-Card Typography And Supplemental Content

This document captures how sidebar info cards should use type rhythm, bullets, captions, and supplemental content.

The goal is to keep explanatory sidebar cards readable, lightweight, and clearly non-interactive unless they intentionally include a small supporting action.

## Core idea

Sidebar info cards should read cleanly in a narrow column.

That means:

- strong title hierarchy
- comfortable paragraph rhythm
- brief bullets when they help scanning
- restrained supplemental content

The card should support comprehension quickly, not force the user to decode dense micro-layout decisions.

## Primary goals

1. Keep explanatory prose readable in a narrow sidebar width.
2. Prevent small text treatments from becoming fuzzy or decorative.
3. Use bullets and captions only when they improve scanning.
4. Keep supplemental content subordinate to the main explanatory text.

## Typography principles

### 1. Titles should name one idea cleanly

An info-card title should usually identify the card’s single purpose.

Good titles are:

- short
- specific
- sentence-like when that improves tone

Avoid titles that try to summarize the entire card body.

### 2. Body text should do the main explanatory work

Most sidebar explanation should live in normal body text.

Body text should be the default place for:

- overview statements
- interpretation
- caveats
- short instructions

Do not demote important explanation into tiny footnote styling just because it is secondary.

### 3. Small text should be used sparingly

Caption or footnote-like text is appropriate for:

- lightweight metadata
- very short secondary labels
- low-priority clarifiers

It is not appropriate for paragraphs the user is actually expected to read carefully.

If the user needs to read it, it usually belongs in body text.

### 4. Paragraph rhythm matters more than ornament

In a narrow sidebar, readability comes more from spacing and short paragraph units than from decorative text styling.

Prefer:

- one or two short paragraphs
- clear paragraph breaks
- concise sentences

Over:

- long dense blocks
- frequent style changes within the same thought
- stacked caption-sized paragraphs

## Bullet rules

### 1. Use bullets only when the content benefits from scanning

Bullets are useful when the user needs to parse:

- a small set of categories
- a short checklist
- parallel examples
- grouped evidence items

If the content reads naturally as short prose, keep it as prose.

### 2. Keep bullets short and structurally parallel

Bullets work best when they share a similar shape.

Avoid bullets that turn into mini paragraphs unless there is no clearer alternative.

### 3. Wrapped bullets need a clear second-line indent

If a bullet wraps in the sidebar, the continuation line should align as a continuation of the bullet text, not as a new paragraph.

This is especially important in narrow widths where wrapping happens often.

### 4. Do not over-bullet a short card

If a card only has one or two short ideas, bullets may add more visual structure than the content needs.

Use them when they clarify; skip them when they only add noise.

## Caption and footnote guidance

### Captions

Captions are appropriate for:

- small labels beneath a primary statement
- lightweight contextual hints
- short supporting metadata

Captions should support, not carry, the main idea.

### Footnotes

Footnotes should be rare in sidebar info cards.

Use them only when the content is genuinely lower-priority and still brief.

Do not place substantive explanation in a visual footnote style if it harms legibility.

If the sentence matters to understanding, prefer normal body text.

## Supplemental content rules

### 1. Supplemental content should remain subordinate to the body text

Optional supplemental content can be useful, but it should not become a second main card inside the card.

It should feel like support for the explanation, not a competing panel.

### 2. Good supplemental content is small and semantically tied to the text

Good examples:

- a tiny supporting status row
- a short metadata block
- a compact legend
- a single small supporting action

Bad examples:

- a large embedded interactive surface
- a mini dashboard
- a dense nested control group unrelated to the explanation

### 3. Supplemental content should not erase the card’s primary role

If the card’s main job is to explain, the explanation should remain the visual anchor.

If supplemental content becomes visually louder than the prose, the card should probably be split or recast as a different cassette type.

### 4. One small supporting action can be acceptable

An info card may include a tightly scoped supporting action when it is clearly subordinate to the explanatory purpose.

Examples:

- a single “learn more” or contextual helper action
- a narrow “open related report” follow-up

But if the action becomes the main reason the card exists, it is no longer primarily an info card.

## Composition guidance

### One-card explanation

Use when the idea is simple enough to explain in:

- one title
- one or two paragraphs
- optional short bullet list

### Multi-card explanation

If the explanation contains multiple distinct ideas, split it into separate lightweight cards instead of piling several typography modes into one card.

This usually produces a clearer sidebar than trying to solve density with tiny text or stacked footnotes.

### Explanation plus supplemental content

Use when the explanation benefits from one small supporting element.

The recommended order is usually:

1. title
2. body text
3. optional bullets or short secondary paragraph
4. small supplemental content block if still needed

## Anti-patterns

Avoid these:

- important explanation rendered as tiny footnote text
- long prose blocks with no paragraph breaks
- heavy use of bullets for content that is not list-shaped
- supplemental content that visually overwhelms the card body
- several different text scales used just to force density into one card

## Relationship to other docs

This document builds on:

- `00-sidebar-cassettes-controls-and-info-cards.md` for the overall role of info cards in sidebar composition
- `20-navigation-row-emphasis-rules.md` for the distinction between actionable rows and explanatory cards

Theming details still belong in `../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md`.

Payload transport and optional supplemental-content contracts still belong in the sidebar cassette architecture docs.

This doc answers a narrower question:

Once a sidebar card is explanatory, how should its text and small supporting content be arranged so it stays readable and appropriately lightweight?

## Current reference candidates

Useful current reference cases:

- Message History Coverage explanatory cards
- shared sidebar info cards with short bullets and supporting prose
- any sidebar card that carries semantic body text plus optional supplemental content

## Future expansion

Likely follow-on docs for this section:

- interaction-state examples for hover, selection, and disabled rows in `50-interaction-state-examples-for-hover-selection-and-disabled-rows.md`
- examples of when an info card should be split into multiple cards
- typography guidance for mixed metadata plus explanation cards
