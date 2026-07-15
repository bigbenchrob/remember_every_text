# Implement TrackOccupant

## First Vertical Slice — Search Track A And Track B

The Cross-Column Layout Tracks architecture has been proven through the first Track A and Track B slices.

The TrackOccupant architecture analysis is now approved.

Proceed with the first TrackOccupant implementation slice.

Work autonomously through implementation, focused tests, analyzer, and documentation. Do not pause for routine implementation choices. Pause only for a genuine architectural contradiction, an unresolved ownership conflict, or a risk of data loss.

---

# Objective

Replace the current Search-page Track A and Track B page-level numeric requirement declarations with declarative `TrackOccupant` objects.

The rendered page should remain visually equivalent to the current successful Track A/Track B implementation.

This slice proves that:

- every visible item placed in a Track can be represented by a `TrackOccupant`;
- constant and calculated occupants share one abstraction;
- occupants calculate requirements from the same presentation contracts used to build their widgets;
- the page resolves requirements without knowing occupant types;
- page-level magic height values can be removed.

---

# Approved Architecture

The flow is:

    prepared presentation data
        -> TrackOccupant
            -> TrackRequirement
            -> presentation Widget
        -> page resolves ResolvedTrackPlan
        -> columns render occupants inside resolved allocations

A `TrackOccupant` is a declarative presentation adapter.

It owns:

- calculating its natural `TrackRequirement`;
- constructing the corresponding presentation widget.

It does not own:

- providers;
- repositories;
- graph facts;
- user-intent mutation;
- page-level spacing;
- sibling-column knowledge;
- sidebar cassette sequencing.

---

# First-Slice Scope

Implement TrackOccupants only for the existing Search-page Track A and Track B participants.

## Track A

Sidebar:

- Search top menu occupant.

Center:

- `All messages` title occupant.

Right:

- `Conversation` title occupant.

## Track B

Sidebar:

- no occupant.

Center:

- result metadata occupant containing the date span, message count, and only the metadata already approved for Track B.

Right:

- no occupant.

Do not introduce Track C or later tracks.

Do not move search controls, orientation text, Conversation Cards, excerpt descriptions, heatmaps, or cassette content into Tracks.

---

# Generic TrackOccupant Contract

Introduce the smallest honest generic abstraction.

The precise API should follow repository conventions, but conceptually it should provide:

    TrackRequirement requirement(TrackRequirementContext context)

    Widget build(
      BuildContext context,
      ResolvedTrackAllocation allocation,
    )

The Track system must interact with every occupant through this common contract.

The coordinator must not branch on concrete occupant types.

Do not add speculative fields or framework features that this slice does not need.

---

# TrackRequirement

Keep `TrackRequirement` height-only for this slice.

Do not yet add:

- minimum height;
- maximum height;
- compact height;
- overflow policy;
- alignment preference.

Preserve naming that allows future extension, but implement only the requirement currently proven necessary.

---

# TrackRequirementContext

Create a small immutable context containing only inputs genuinely required by this slice.

For text occupants this may include:

- available width;
- `TextScaler`;
- `TextDirection`;
- locale, where required for exact text layout.

Do not pass repositories, providers, feature state, or mutation APIs.

Avoid taking `BuildContext` directly in requirement calculation if the needed environmental values can first be resolved into a plain context object.

---

# Constant And Calculated Requirements

Constant and calculated occupants are ordinary implementations of the same abstraction.

The page and coordinator must not distinguish between them.

## Constant occupants

A constant occupant has a genuinely fixed natural outer height supplied by the same presentation contract used to render its widget.

Examples in or near this slice:

- Search top menu;
- future fixed controls;
- future spacing shim occupants.

A constant must not be duplicated independently in page code and widget code.

Use one shared presentation metric as the source of truth.

## Calculated occupants

A calculated occupant derives its natural requirement from its current presentation data and constraints.

Text occupants should calculate exact natural height using Flutter typography machinery such as `TextPainter`.

Do not:

- estimate from character count;
- use page magic numbers;
- query already-built Widgets;
- use `GlobalKey`;
- use post-frame measurement;
- use intrinsic-layout repair;
- use custom RenderObjects.

---

# Required Occupant Types

Implement only the smallest occupant set required by this slice.

Likely forms include:

## TextTrackOccupant

Used for:

- `All messages`;
- `Conversation`;
- center metadata.

It should receive the same:

- text;
- exact `TextStyle`;
- line limits;
- wrapping/overflow rules;

used to construct the matching `Text` presentation.

Its requirement calculation and widget construction must remain synchronized.

## TopMenuTrackOccupant

Used for the Search sidebar top menu.

It is an ordinary `TrackOccupant`, not a special coordinator case.

Its natural height may be constant if the complete control has a stable outer-height presentation contract.

If so:

- expose or extract one shared metric near the control implementation;
- use that same metric for both the control and occupant requirement;
- do not reproduce the value in Search-page layout code.

Do not create a broad fixed-control framework unless the repository already supports one naturally.

---

# Empty Cells

An empty Track cell has no occupant.

It contributes no requirement.

Do not create `EmptyTrackOccupant`.

For Search Track B:

- sidebar supplies no occupant;
- right panel supplies no occupant.

---

# Fixed-Height Spacing Occupants

Do not implement a fixed-height spacing occupant in this slice.

Record and preserve the settled rule:

> Future page-specific spacing is an ordinary track cell containing a
> fixed-height TrackOccupant, conceptually building a `SizedBox`.

Do not introduce:

- `ShimTrack`;
- a spacing subsystem;
- special coordinator behavior for spacing.

---

# Content-Tight Rule

Preserve the current strict invariant:

> Occupied Tracks contain no discretionary vertical spacing. Their height is the maximum natural requirement declared by their occupants. All intentional cross-column spacing is represented by explicit empty Tracks.

TrackOccupants must not include page-level breathing room in their requirements.

Do not reintroduce:

- top or bottom padding as layout;
- hidden slack;
- compatibility-band allowance;
- guessed control heights;
- page-specific offsets.

Intrinsic geometry genuinely belonging to a control remains part of that control’s natural requirement.

---

# Coordinator

The coordinator should remain deliberately small.

Its responsibility is only:

    collect requirements from occupants

    -> group requirements by TrackId

    -> resolve maximum height per Track

    -> create ResolvedTrackPlan

It must know nothing about:

- Search;
- text;
- top menus;
- Conversations;
- cards;
- glyphs;
- sidebar cassette types.

---

# Rendering And Ownership

The Search page or its page-level layout adapter owns:

- selecting TrackOccupants;
- supplying requirement contexts;
- resolving the shared plan.

Columns own:

- which occupants participate;
- rendering occupants in the resolved allocation.

Widgets remain pure presentation.

Do not make the underlying text or menu widgets aware of sibling columns or Track resolution.

---

# Compatibility

Preserve the existing successful Track A/Track B visual result.

The current compatibility wrappers may remain if needed, but they must receive their geometry from the resolved Track plan.

Do not:

- remove the wrapper system;
- migrate other pages;
- redesign Track A or Track B;
- introduce new visual spacing;
- retune the Search page beyond correcting requirement-source drift.

Colored Track diagnostics should continue to function.

---

# Files And Placement

Place generic Track infrastructure with the existing cross-column Track layout infrastructure unless repository inspection reveals a clearly better established owner.

Place feature-specific or widget-specific occupants and metrics with their presentation owners.

In particular:

- generic Track abstractions must not know about Search or Conversations;
- top-menu presentation metrics should live with the top-menu/dropdown presentation contract;
- Search composition may instantiate the occupants but should not own their internal measurement logic.

Follow current project naming and file-organization conventions.

---

# Tests

Add focused tests covering at least:

## Generic behavior

- occupants produce `TrackRequirement` values;
- the resolver uses the tallest occupant in a Track;
- no occupant means no requirement;
- the coordinator does not require concrete occupant-type knowledge.

## Text occupants

- one-line title requirement uses exact typography;
- metadata requirement uses the exact presentation style;
- requirement changes correctly with text scaling;
- requirement changes correctly when available width causes wrapping, if wrapping is permitted;
- built text and measured text use the same line/overflow contract.

## Top-menu occupant

- requirement matches the shared top-menu presentation metric;
- no independent Search-page magic height remains;
- Track A remains governed by the top menu when it is the tallest occupant.

## Search integration

- Track A and Track B resolved heights remain content-tight;
- Track B remains occupied only by center metadata;
- sidebar/right empty Track B cells contribute nothing;
- Search page renders with and without the right Conversation panel;
- existing colored diagnostics still show correct Track boundaries.

Run focused tests and `flutter analyze`.

Report pre-existing failures separately.

---

# Explicit Non-Goals

Do not implement:

- Track C or later Tracks;
- fixed-height spacing occupants;
- Conversation Card TrackOccupant;
- Conversation glyph TrackOccupant;
- card or glyph metrics extraction;
- sidebar cassette Track participation;
- automatic cassette placement;
- Contacts or Conversations-page migration;
- wrapper retirement;
- general-purpose control-occupant framework;
- caching;
- compact variants;
- baseline negotiation;
- custom layout/render objects;
- post-frame measurement.

---

# Documentation

Update the Cross-Column Layout Tracks work package to record:

- implemented TrackOccupant abstraction;
- first-slice occupant types;
- final API and ownership choices;
- source-of-truth presentation metrics;
- tests and analyzer results;
- deferred occupants and Tracks;
- any deviations from the architecture analysis.

Update the checklist accurately.

Append the work to `DOCUMENTATION_PASS_LOG.md`.

---

# Final Report

At completion, report:

- implemented TrackOccupant workflow;
- final generic API;
- occupant types added;
- how text requirements are calculated;
- how the top-menu constant is shared with its presentation widget;
- page-level numeric requirements removed;
- files changed, grouped by generic layout, presentation occupants, integration, tests, and documentation;
- test and analyzer results;
- visual/manual verification steps;
- deviations from the approved analysis;
- remaining deferred work.

Do not claim the complete TrackOccupant system is finished.

This task completes only the first Search Track A/Track B vertical slice.
