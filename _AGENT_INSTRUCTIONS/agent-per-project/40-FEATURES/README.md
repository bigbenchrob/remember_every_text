---
tier: project
scope: features
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: doc
links:
	- ../45-NEW-FEATURE-ADDITION/README.md
	- ../42-SPEC-SYSTEM/README.md
	- ./chat-handles/CHARTER.md
	- ../90-USE-CASE-ILLUSTRATIONS/README.md
tests: []
---

# Features Library

This directory documents shipped features, feature-like app capabilities, and a few historical feature plans that still explain current behavior.

Current code structure wins over older feature docs. When this folder intersects with specs, sidebar cassettes, panel view specs, or cross-surface orchestration, follow the canonical architecture in [`../42-SPEC-SYSTEM/`](../42-SPEC-SYSTEM/).

Feature docs must not imply that features own app-level orchestration. Features may define feature-owned spec variants, coordinators, resolvers, payloads/view models, and render-edge components. Essentials owns top-level routing, global flow state, sidebar topology, panel stacks, shared chrome, and cross-surface reconciliation.

## Feature Index

| Feature | Key Docs |
| --- | --- |
| `chat-handles/` | Draft scaffold for handle identity/linking concerns. Current concrete implementation is split across `lib/features/handles`, `lib/features/contacts/application/services/manual_handle_link_service.dart`, and overlay DB handle overrides. |
| `chats/` | Draft scaffold for chat aggregate and recent-chat projection. Current code has repository/view-model support but no active `ViewSpec.chats` route. |
| `contact-favourites/` | [`RECENTS-FAVORITES.md`](contact-favourites/RECENTS-FAVORITES.md) — Picker section precedence, de-duplication, and semantic preservation rules |
| `contact-names/` | Current notes for participant naming overrides, virtual participants, and overlay/working separation. |
| `identify-stray-handles/` | [`MASTER_PLAN.md`](identify-stray-handles/MASTER_PLAN.md) — 3-phase plan: overlay schema + virtual participants → sidebar review + Handle Lens → polish & bulk ops |
| `messages/` | Current unified message timeline, `MessagesSpec` entry points, ordinal strategies, hydration, recovered scopes, and message search. |
| `onboarding/` | Legacy V1 planning notes. Current canonical docs are in [`../25-ONBOARDING-AND-ARCHIVE/`](../25-ONBOARDING-AND-ARCHIVE/) and code lives primarily under `lib/essentials/onboarding` plus `lib/features/environment_readiness`. |
| `rationalized-message-views/` | Historical implementation packet for the now-merged unified message timeline. Keep as context; use `messages/` for current guidance. |
| `search/` | Legacy feature scaffold. Current search services and indexing live under `lib/essentials/search`; message surfaces consume them through timeline view models. |
| `tooltips/` | Current small cross-surface tooltip system. Only contacts tooltip routing is currently implemented. |

## Current `lib/features` Modules

The current code tree also contains feature modules that do not all have full documentation folders here:

| Code module | Current role |
| --- | --- |
| `address_book_folders` | AddressBook source folder discovery and readiness support. The old presentation/loading widgets and user-selectable candidate workflow are retired; the active value is the source path resolver used by onboarding and source-scoped contact import. |
| `attachments` | Attachment archive, graph evidence resolution, deterministic recovery, and archive settings support. The old generic `Attachment`/`AttachmentId` feature-domain model is retired. |
| `chats` | Chat repository, recent-chat and timeline support. |
| `contacts` | Contact picker/sidebar cassettes, favorites, virtual participants, contact profile/name overrides, tooltip spec. |
| `environment_readiness` | ViewSpec-driven readiness panel used by onboarding/system surfaces. |
| `handles` | Stray-handle review cassettes, graph/overlay handle providers, manual-linking operations, and Handle Lens support. |
| `messages` | Message timeline scopes, sidebar heatmaps/navigators, ViewSpec handling, hydration, recovered-message surfaces. |
| `reactions` | Retired feature shell. Reaction evidence is preserved by message import/projection semantics and retained legacy reaction tables, not by an active standalone feature module. |
| `settings` | Settings sidebar cassettes and settings action surfaces. |
| `sidebar_utilities` | Top-chat/settings menu cassettes and shared sidebar utility specs. |

## Required Files Per Feature

For a fully documented shipped feature, create or maintain the following documents inside the feature folder:

| File | Purpose |
| --- | --- |
| `CHARTER.md` | Captures mission, outcomes, stakeholders, and open questions. |
| `DOMAIN_AND_DATA_MAP.md` | Lists aggregates, tables, and external systems touched by the feature. |
| `STATE_AND_PROVIDER_INVENTORY.md` | Catalogues Riverpod providers, state objects, and invalidation rules. |
| `INTERACTIONS_AND_NAVIGATION.md` | Describes user flows, ViewSpec entry points, and cross-feature touchpoints. |
| `TESTING_AND_MONITORING.md` | Defines automated coverage, fixtures, and telemetry expectations. |
| `WORK_LOG.md` | Tracks ongoing changes, decisions, and follow-up items. |

## Using the Templates

Reusable markdown templates for each file live in `agent-instructions-shared/AGENT_PER_PROJECT_SCHEMA/per_project_folder_file_schema.yaml` under the `templates` section. When you migrate a feature from `45-NEW-FEATURE-ADDITION/`, copy in the templates and populate them with project-specific details. Existing features should adopt the same structure for consistency.

## Migration Workflow

1. **Promote a Feature**: Move the feature folder from `45-NEW-FEATURE-ADDITION/{feature}` to `40-FEATURES/{feature}` once it ships.
2. **Apply Templates**: Ensure all required files exist and are filled out using the templates as a starting point.
3. **Backfill History**: Update `WORK_LOG.md` with past milestones and decisions.
4. **Link Documentation**: Cross-reference supporting docs (database guides, provider notes, etc.) so future contributors have a complete map.

Historical proposal folders may remain here when they explain why the current system exists. Label them as historical, legacy, transitional, or superseded so agents do not treat old plans as current implementation guidance.

## Adding New Features Directly

For features that already exist but lack documentation, create a folder here and populate the six required files using the templates. This keeps the feature library consistent regardless of whether work began in the new-feature staging area.
