# Historical Archives Hub Semantic Cleanup Implementation

Date: 2026-08-17

## Outcome

Historical Archives now distinguishes durable knowledge of an archive source
from the human-facing claim that the folder is currently part of MessageLens.

> MessageLens knows about this source
>
> is not equivalent to
>
> This folder has been added to MessageLens.

The initial `hub` context is intentionally silent. The sidebar already presents
the available navigation choices, and no center-panel archive content appears
until the user explicitly selects an added folder or begins the add journey.

## Folders Already Added

The former **Known Archive Sources** heading is now **Folders Already Added**.
Membership is derived from the established imported-source lookup:

1. resolve the persisted source metadata's canonical historical source key;
2. find that key in the source-scoped import ledger;
3. require a positive source-scoped imported message count.

Persisted workflow metadata alone cannot create a cartouche. A preflight-only
source and a registered source whose imported message count has returned to
zero are both absent from the list. Their canonical source identity may remain
available for deterministic recognition, diagnostics, and a later fresh add
journey.

The cartouche's message count comes from the same ledger match that establishes
membership. The generic imported-status line was removed because membership
under **Folders Already Added** already states that fact.

The sidebar provider watches the ordinary message-data version signal. Import
and source-scoped removal already bump that signal, so the list re-evaluates its
ledger-backed membership after the normal mutation refresh without changing
source registration or persistence semantics.

## Center Panel

The virgin hub renders only the center-panel canvas. It does not render a
neutral Narrator prompt or fall back to the retired control-panel surface.

An explicitly selected added folder still presents:

- source/folder identity;
- source-scoped imported message count;
- the recorded date range;
- existing details and source-management capabilities.

The redundant `Status: Already imported` instrumentation row is omitted from
this selected-source context. Add-flow recognition remains unchanged and may
still state that the chosen folder is already part of MessageLens while the
sidebar points to the corresponding cartouche in orange.

If an old cartouche callback reaches the workflow after its source has been
removed, the lookup cannot prove positive imported truth and the workflow
returns to the hub. It cannot manufacture selected-source context from stale
metadata.

## Preserved Boundaries

This cleanup changes presentation and read-model qualification only. It does
not change:

- canonical historical source identity;
- source registration;
- database schema or persistence format;
- import, removal, or mutation-authority behavior;
- Add Archive inspection or execution;
- Narrator progression or orange recognition behavior;
- production, staging, donor, or attachment data.

## Verification

Focused coverage proves:

- an empty hub center panel;
- the **Folders Already Added** heading;
- positive-count imported membership;
- exclusion of preflight-only and removed zero-count sources;
- survival of source metadata when sidebar membership disappears;
- refresh-driven removal of a zero-count cartouche;
- selected-source message/date facts without imported-status repetition;
- stale cartouche navigation returning to the hub;
- later Add Archive eligibility for a remembered but currently unimported
  source;
- navigation reset and existing add/recognition behavior remaining intact.

Verification completed with:

- 45 focused Historical Archives workflow, provider, resolver, and widget
  tests;
- 90 Settings feature tests;
- 374 architecture tripwires;
- `flutter analyze` with no issues;
- formatting and `git diff --check` clean.
