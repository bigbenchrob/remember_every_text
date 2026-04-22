# 54 — Sidebar Cassette Spec System

> Reference note: This folder is deep-dive reference material. Prefer
> [42-SPEC-SYSTEM/README.md](../../README.md) and
> [CANONICAL-ARCHITECTURE/00-overview.md](../../CANONICAL-ARCHITECTURE/00-overview.md)
> as entry points before using these details.

How the sidebar composes and displays a vertical stack of multi-feature cassette cards.

## Key Idea

The sidebar is a **managed stack** of cassettes. Each cassette is described by a
`CassetteSpec`, which wraps a feature-specific inner spec. The system:

1. Maintains an ordered list of specs (the **rack**)
2. Resolves each spec to a `SidebarCassettePayload` via feature coordinators
3. Routes each payload through the shared sidebar render router to apply the appropriate chrome
4. Renders the stack

Features own the content. Essentials owns the stack, chrome, and composition.

For the contacts/messages branch, the visible rack is no longer the only place
where flow meaning lives. Canonical flow state is owned by
`sidebar_flow_state_provider.dart`, and the cassette rack plus center-panel
routing are expected to remain coherent with that state.

## Documents

| File | Purpose |
|---|---|
| [00-cassette-system-architecture.md](00-cassette-system-architecture.md) | Full architecture: rack state, cascade, coordinator dispatch, card chrome, **card configuration patterns** |
| [10-layout-and-optical-composition.md](10-layout-and-optical-composition.md) | Canonical ownership contract for sidebar layout, feature-owned complex bodies, and optical tuning inside the constrained frame |
| [INVIOLATE_RULES.md](INVIOLATE_RULES.md) | Non-negotiable rules for the cassette system |

## Key Code Locations

| Component | Path |
|---|---|
| `CassetteSpec` sealed class | `lib/essentials/sidebar/domain/entities/cassette_spec.dart` |
| Rack state provider | `lib/essentials/sidebar/application/cassette_rack_state_provider.dart` |
| Canonical flow-state owner | `lib/essentials/sidebar/application/sidebar_flow_state_provider.dart` |
| App-level coordinator | `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart` |
| Cascade topology | `lib/essentials/sidebar/domain/entities/cascade/` |
| Card view model | `lib/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart` |
| Card widgets | `lib/essentials/sidebar/presentation/view/` |
| Sidebar barrel | `lib/essentials/sidebar/feature_level_providers.dart` |

## Prerequisite Reading

- [52 — Feature Handling of X-Surface Specs](../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/) for the general coordinator → resolver → widget_builder pattern

