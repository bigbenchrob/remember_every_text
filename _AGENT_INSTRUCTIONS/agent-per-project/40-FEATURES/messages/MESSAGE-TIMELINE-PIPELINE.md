---
tier: feature
scope: message-timeline-pipeline
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: doc
links:
  - ./DOMAIN_AND_DATA_MAP.md
  - ./STATE_AND_PROVIDER_INVENTORY.md
  - ./INTERACTIONS_AND_NAVIGATION.md
  - ./message-display-flow-walkthrough.md
  - ../../10-DATABASES/02-db-working.md
  - ../../10-DATABASES/12-identity-model-contacts-handles-participants.md
  - ../../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../../25-ONBOARDING-AND-ARCHIVE/70-attachments-end-to-end.md
  - ../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
tests: []
feature: messages
doc_type: pipeline
status: active
---

# Message Timeline Pipeline

## TL;DR

- Messages are rendered through a spec-driven pipeline.
- Timeline ordering is based on ordinal indexes, not raw timestamps alone.
- Identity and attachments are resolved before rendering.
- UI renders from payloads/view models such as `MessageListItem`, not raw database rows.

The current unified timeline path is:

`ViewSpec.messages(MessagesSpec...)` -> `MessageTimelineScope` -> ordinal strategy -> per-row hydration -> `MessageListItem` -> `MessageCard`.

## Timeline Authority Rule

The message timeline must be derived only from:

- ordinal ordering
- participant identity resolution
- attachment availability state
- resolved payload/view model

It must not be derived from:

- raw timestamps
- raw database rows
- file system state
- UI reconstruction

## 1. Message Source (Working DB)

The message timeline reads from `working.db`, not directly from `chat.db` or `macos_import.db`.

Core working data:

| Working data | Purpose |
| --- | --- |
| `workingMessages` / SQL `messages` | Projected message rows consumed by timeline hydration. |
| `participants` / Drift `WorkingParticipants` | Resolved participant rows joined for sender identity. |
| `handles_canonical` and `handle_to_participant` | Canonical handle and participant linkage used during sender resolution. |
| `attachments` / Drift `workingAttachments` | Projected attachment metadata loaded by message GUID. |
| `global_message_index` | Global ordinal ordering across messages. |
| `message_index` | Chat-scoped ordinal ordering. |
| `contact_message_index` | Contact-scoped ordinal ordering. |
| `read_state`, `message_read_marks`, `reaction_counts`, `reactions` | Supporting presentation and state projection. |

Raw rows are not rendered directly. The hydration layer joins and transforms working data into `MessageListItem` objects before widgets are built.

## 2. Ordering Model

Timeline ordering is ordinal-based.

An ordinal is a stable position within a `MessageTimelineScope`. The scope decides which index or list owns the ordering:

| Scope | Ordering source |
| --- | --- |
| `MessageTimelineScope.global()` | `global_message_index` |
| `MessageTimelineScope.contact(...)` | `contact_message_index` |
| `MessageTimelineScope.chat(...)` | `message_index` |
| `MessageTimelineScope.recovered(...)` | recovered message list strategy |

The ordinal model exists so the UI can:

- build a fast skeleton list from `totalCount`
- jump to latest or month positions deterministically
- hydrate only visible rows
- avoid offset paging across large datasets
- preserve scroll behavior when new rows arrive

Relationship of identifiers:

- Source ROWIDs are preserved through import/projection for traceability.
- Working message IDs identify projected message rows.
- Ordinals identify a message's position within a specific timeline scope.
- A message can have different ordinals in different scopes.

UI must not infer ordering from timestamps alone. Timestamps are index inputs and display data; the ordinal index is the timeline ordering contract.

## 3. Incremental Update Flow

Automatic sync is driven by `ChatDbChangeMonitor`.

Current sequence:

1. `ChatDbChangeMonitor` polls `MAX(ROWID)` from `~/Library/Messages/chat.db`.
2. On increase, it runs `orchestratedLedgerImportServiceProvider.runImport()`.
3. On successful import, it calls `attachmentArchiveServiceProvider.archiveImportedBatch(batchId: importResult.batchId)`.
4. It then calls `handlesMigrationServiceProvider.run(incrementalMode: true)`.
5. On successful migration, it calls `messageDataVersionProvider.bump()`.

The timeline reacts to provider invalidation/version signals, not direct source database polling.

Current scope refresh behavior:

- global and chat scopes watch `messageDataVersionProvider`
- contact scopes watch `contactTimelineDisplayVersionProvider(scope: ...)`
- recovered scopes watch `recoveredUnlinkedMessagesProvider(contactId: ...)`

Do not close or invalidate `driftWorkingDatabaseProvider` from the incremental path. The current contract is to preserve the Drift connection and signal UI refresh through versioned providers.

## 4. Identity Resolution

Identity must follow the participant model documented in `../../10-DATABASES/12-identity-model-contacts-handles-participants.md`.

Message hydration joins:

`workingMessages.senderHandleId` -> `handles_canonical` -> `handle_to_participant` -> `workingParticipants`

Display name resolution order is:

1. overlay override
2. contact/participant name
3. fallback handle

The UI must not derive identity from raw handle strings or display-name text. Raw handles are endpoint identifiers; participants are the app identity unit.

Recovered timelines may have uncertain sender identity. They must preserve that uncertainty with recovered sender labels or `Unknown sender` rather than inventing contact membership.

## 5. Attachment Resolution

Attachment rendering follows the archive-first model documented in `../../25-ONBOARDING-AND-ARCHIVE/70-attachments-end-to-end.md`.

Timeline hydration:

1. loads projected attachments from `workingAttachments` by `messageGuid`
2. converts them into attachment hydration data
3. resolves display availability through `attachmentResolverProvider`
4. attaches resolved state to `MessageListItem`

Attachment availability states:

| State | Meaning |
| --- | --- |
| `pendingArchive` | A live file exists and archive ingestion has been triggered. |
| `available` | A displayable file is available under the current source policy. |
| `unavailableAwaitingRecovery` | The attachment is known but not displayable now. |
| `nonRecoverable` | No viable display or recovery path is known. |

The timeline renders from resolved attachment state. It must never render directly from live Apple file paths or assume file existence from `local_path`.

## 6. Hydration Model

The timeline is intentionally staged.

Lightweight stage:

- `messageTimelineOrdinalProvider(scope: ...)` computes `totalCount`
- the view builds a `ScrollablePositionedList` skeleton
- rows exist by ordinal before their content is loaded

Per-row hydration stage:

- visible rows watch `messageByTimelineOrdinalProvider(scope: ..., ordinal: ...)`
- hydration maps `ordinal -> messageId -> working row joins -> MessageListItem`
- search and pending-message contexts can hydrate direct IDs through `messageByIdProvider(messageId: ...)`

Content cost differs by type:

- text and timestamps are lightweight
- identity joins and overlay metadata are moderate
- attachments, media availability, and previews are heavier

Hydration must avoid loading an entire large timeline at once. Visible rows hydrate independently so scrolling remains responsive under large datasets.

Rendering placeholders should keep row height stable enough to avoid scroll jumps when richer content arrives.

## 7. View Model / Payload Layer

The view model and hydration providers are the payload layer for message timelines.

Key providers:

| Provider | Responsibility |
| --- | --- |
| `messageTimelineViewModelProvider(scope: ...)` | Timeline UI state facade: search controller, debounce, search results, ordinal state, jump methods. |
| `messageTimelineOrdinalProvider(scope: ...)` | Total count, scroll controllers, ordinal strategy, jump operations. |
| `messageTimelineIndexCoordinatorProvider(scope: ...)` | Coordinates active scope index behavior. |
| `messageByTimelineOrdinalProvider(scope: ..., ordinal: ...)` | Current unified per-row hydration provider. |
| `messageByIdProvider(messageId: ...)` | Direct ID hydration for search and pending/context rows. |
| `timelineMetadataProvider(scope: ...)` | Scope metadata such as counts and date ranges. |

This layer combines:

- message row data
- participant/display-name resolution
- overlay user metadata
- attachment state
- recovered-message metadata where applicable

It produces UI-ready data. It must not create widgets.

## 8. Spec-System Integration

Panel message timelines are selected by `ViewSpec.messages(MessagesSpec...)`.

Examples:

- `MessagesSpec.globalTimeline(...)`
- `MessagesSpec.forContact(...)`
- `MessagesSpec.forHandle(...)`
- `MessagesSpec.recoveredUnlinkedMessages(...)`
- `MessagesSpec.searchResultContext(...)`

The canonical rendering pipeline is:

Spec → Coordinator → Resolver → Payload / ViewModel → Rendering

Current panel code still has a legacy/current-state boundary where `ViewSpecCoordinator.buildForSpec(...)` returns widgets through feature resolvers. That is documented in `42-SPEC-SYSTEM` as a migration boundary, not an approved pattern for new work.

New message timeline work must keep selection, resolution, hydration, payload/view model construction, and rendering distinguishable even when existing panel code still returns widgets.

## 9. Rendering Layer

Rendering builds widgets from `MessageListItem`.

Current render path:

- `MessagesTimelineView` chooses timeline/search/recovered layout for the active `MessageTimelineScope`.
- `_MessageRow` watches row hydration and handles loading/error/null states.
- `MessageCard` chooses text, image, video, or link-preview presentation from `MessageListItem`.
- `MessageUserMetadataCardDecorator` applies saved/tag metadata affordances around cards.

Layout behavior:

- analysis-style timelines use full-width message cards
- chat-style timelines use bubble layout
- sender/receiver styling comes from `isFromMe`, sender name, card layout, and grouping metadata
- grouping decisions are computed from adjacent hydrated metadata, not from raw SQL in the widget tree

Rendering must not:

- re-query source or working databases directly
- infer missing identity, ordering, or attachment state
- bypass the payload/hydration layer
- treat a missing attachment file as a reason to suppress the message

## 10. Failure Modes / Edge Cases

| Case | Handling |
| --- | --- |
| Missing attachments | Attachment resolver returns an unavailable state; message remains visible. |
| Delayed archive availability | Resolver can return `pendingArchive`; later archive availability refreshes resolved display state. |
| Identity ambiguity | Participant/handle joins and overlay resolution provide best available label; recovered timelines preserve uncertainty instead of fabricating identity. |
| Multiple handles for one person | Participant model and handle-to-participant links group identity; UI must not collapse based on strings. |
| Out-of-order ingestion | Migration/index rebuild owns final ordinal ordering; UI must trust indexes, not arrival order or timestamps alone. |
| Partial hydration during scroll | Rows show skeleton/loading states until `MessageListItem` is available. |
| Missing projected row for ordinal | Hydration returns null; UI shows skeleton/empty row state rather than crashing. |
| DB maintenance/reset | `messageTimelineOrdinalProvider` short-circuits to an empty state while `dbMaintenanceLockProvider` is true. |

## 11. Performance Constraints

Message timelines can be large.

Performance rules:

- Build the skeleton list from counts and ordinals.
- Hydrate visible rows only.
- Keep heavy work out of scroll callbacks and widget build methods.
- Use providers/strategies for DB work.
- Keep placeholder dimensions stable enough to avoid scroll jitter.
- Preserve stable ordering so jumps and current position remain meaningful after updates.

Staged hydration exists to avoid blocking the UI thread with large message, identity, attachment, and preview work.

## 12. Non-Negotiable Rules

- Do not render directly from DB rows.
- Do not derive ordering from timestamps alone.
- Do not bypass the ordinal strategy for timeline ordering.
- Do not bypass the participant identity model.
- Do not derive identity from raw handle strings or display names.
- Do not render attachments from live Apple file paths.
- Do not perform heavy work during scroll or directly in widget build methods.
- Do not bypass the spec pipeline for panel navigation.
- Do not transport widgets through new coordinator patterns.
- Do not hide messages because identity, attachment, or preview hydration is incomplete.

## 13. Current Caveats

Known current-state caveats:

- Current unified row hydration provider is `messageByTimelineOrdinalProvider`; some older shared hydration files and docs still reference `messageByOrdinalProvider`.
- Panel `ViewSpecCoordinator` currently returns widgets for `MessagesSpec` variants. Treat this as a legacy/current-state migration boundary, not a pattern to spread.
- `MessagesSpec.forChat(...)` and `MessagesSpec.forChatInDateRange(...)` currently route to placeholder panels in `ViewSpecCoordinator`.
- Current `MessageRowMapper` applies overlay display-name overrides and participant display names for normal timelines. Verify handle fallback behavior before assuming every unlinked sender can display a handle in the unified timeline.
- Recovered timelines use a list-backed ordinal strategy and recovered repositories rather than the normal working index tables. They are not backed by the same indexing guarantees as normal working timelines.
  As a result, recovered timelines may differ in ordering stability, performance characteristics, and provider behavior compared to normal working timelines, and must not be assumed to share identical guarantees.

## References

- `./message-display-flow-walkthrough.md` - step-by-step current timeline walkthrough.
- `./STATE_AND_PROVIDER_INVENTORY.md` - current provider inventory.
- `../../10-DATABASES/12-identity-model-contacts-handles-participants.md` - identity model.
- `../../25-ONBOARDING-AND-ARCHIVE/70-attachments-end-to-end.md` - attachment pipeline.
- `../../20-DATA-IMPORT-MIGRATION/01-overview.md` - import/migration and incremental update flow.
- `../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md` - panel/spec boundaries.
