---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-05-24
source_of_truth: doc
links:
  - ./seed.md
  - ./CHECKLIST.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
  - ../../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md
  - ../../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md
  - ../../42-SPEC-SYSTEM/REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
  - ../../42-SPEC-SYSTEM/REFERENCE/56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/00-view-spec-panel-architecture.md
tests: []
feature: conversation-topology-presentation
status: proposed
created: 2026-05-24
---

# Feature Proposal - Conversation Topology Presentation

**Proposed Branch**: `Ftr.convo-topol`  
**Status**: Proposed  
**Created**: 2026-05-24

---

## Overview

Shift the default Conversations mode away from a center-panel conversation browser and toward the intended MessageLens split:

- sidebar: conversation navigation, exploration, and compact conversation-shape recognition
- center panel: the selected conversation's resolved message stream

This feature is exploratory, but it must remain architecturally disciplined. The standalone HTML prototype in `experiments/conversation_shape_sandbox/` is a visual reference only. It must not become a source of production architecture.

## User Value

### Problem

The current conversation-default UI places the conversation list, controls, and message evidence into the center panel. That makes the sidebar nearly empty and violates the desired app grammar:

```text
navigation in sidebar
message evidence in center panel
```

The user loses persistent navigation context while reading messages, and the center panel becomes a conversation browser rather than an evidence stream.

### Proposed User-Facing Outcome

When the user enters Conversations mode:

1. The sidebar shows a compact list of conversation signatures.
2. Each signature gives the conversation a recognizable visual shape.
3. Selecting a signature updates selected conversation state, from which the center panel shows that conversation's messages.
4. The sidebar remains visible as the navigation/exploration surface while messages are read.

For the first implementation slice, no additional sort/filter/search controls should be added. The point is to validate the basic split and visual language before adding navigation enhancements.

## Existing Architecture Summary

- `ConversationBrowserView` currently lives in the center panel and combines conversation navigation with message-oriented behavior.
- Conversation messages are already displayable through `MessagesSpec.forConversation(...)`.
- The `conversation_graph` essential owns graph-backed conversation read models and repository boundaries.
- Sidebar flow state is the authoritative semantic state for the current top-level mode.
- Effective center/right panel providers derive visible panel content from sidebar state and compatible stored panel specs.
- Recent constitutional cleanup removed imperative panel clearing from `SidebarFlow`; this feature must not reintroduce it.

## Assumptions

1. The current graph-backed conversation read models contain enough data for a first compact signature list.
2. The first sidebar signature can reuse existing summary fields and add only lightweight read-model fields if necessary.
3. The center message stream can initially reuse the existing conversation message view.
4. The existing center-panel conversation browser and message-list pairing remains useful as a reference or diagnostic tool and should be preserved as a diagnostic/reference path, but removed from default Conversations routing.
5. This branch is allowed to experiment visually, but not architecturally.

## Hard Invariants

1. The sidebar owns conversation navigation and conversation-shape recognition.
2. The center panel shows resolved message evidence only.
3. Do not move filters, query builders, or conversation selection into the center panel.
4. Do not place SQL or database mechanics outside infrastructure repositories.
5. Do not copy HTML sandbox architecture into Flutter.
6. Do not create a parallel rogue state system.
7. Do not reintroduce imperative center-panel push, clearing, or synchronization patches.
8. Use existing theme tokens and shared widgets; avoid one-off colors and controls.
9. Preserve source-scoped graph identity and existing graph traversal boundaries.
10. Conversation signature facts must be computed outside widgets; widgets render only typed signature data.
11. Keep experimental components isolated and removable.

## Scope

### In Scope

1. Preserve the current center-panel conversation browser/message-list implementation for future diagnostic or reference use, while removing it from default Conversations routing.
2. Add a sidebar conversation signature list for Conversations mode.
3. Wire selecting a sidebar signature to the existing conversation message center view.
4. Keep the center panel focused on selected conversation messages.
5. Use real graph data from existing `conversation_graph` repositories/readers.
6. Port only the minimal visual primitives needed from the sandbox: canonical Trace signature, quiet participant-count cue, and selected-row affordance.
7. Add focused tests for flow-state derivation and sidebar selection behavior.

### Out Of Scope

- Additional sort/filter/search controls
- Contact-name reconstruction improvements
- AddressBook integration
- New database schema
- New import/projection behavior
- Full production visual polish
- Replacing the message rendering system
- Copying the sandbox's implementation structure
- Generic topology planning or graph orchestration changes
- Production-visible tuning panels; any visual tuning controls must be behind an experimental/dev-only flag

## Proposed Direction

### Phase 1 - Planning And Contract

Create and review:

- `PROPOSAL.md`
- `CHECKLIST.md`
- `DESIGN_NOTES.md`
- `TESTS.md`

No code changes until planning is approved.

### Phase 2 - Preserve Existing Center Browser Reference

Preserve the existing center-panel conversation browser path as a diagnostic/reference path, but remove it from default Conversations navigation once the new path works.

Do not move or rename it before the new sidebar signature path works unless doing so is necessary. Any reference path must remain explicit and discoverable; it should not become dead hidden code with unclear authority.

### Phase 3 - Sidebar Signature Read Model

Use existing graph repositories where possible. If additional signature fields are needed, add them through named infrastructure repository methods and typed application/domain models.

Candidate first signature facts:

- participant labels
- message count
- latest message date
- temporal density bins
- participant count
- group/single distinction
- attachment count or attachment density if already available cheaply

Trace is the baseline visual language for these facts. Hybrid is allowed only as an experimental diagnostic overlay, not as the default conversation signature.

### Phase 4 - Sidebar Cassette / Presentation

Add a Conversations-mode sidebar cassette that renders compact signature rows.

The cassette should be:

- dense
- scannable
- Trace-first
- visually restrained
- theme-token based
- keyboard/mouse selectable where practical
- clearly experimental in implementation naming if it introduces temporary visual instrumentation

Participant count should be present as topology context, not as a metadata pill. Prefer tiny muted dots or initials near the title or at the left edge of the trace frame, capped at five visible marks plus `+N`.

### Phase 5 - Center Message Pairing

Selecting a signature should update sidebar flow state or selected conversation state. The center panel projection should then derive:

```dart
MessagesSpec.forConversation(conversationId: ...)
```

The center panel should show the resolved message stream and avoid conversation browsing controls. Selection must not directly push, clear, or force-reset center content imperatively.

## Architecture Impact

| Area | Planned Change |
| --- | --- |
| Sidebar flow | Conversations branch gains a real conversation-selection navigation surface |
| Sidebar cassettes | Add or adapt a cassette for compact conversation signatures |
| Center panel | Stops being the default conversation browser surface |
| Conversation graph | May expose a narrow signature read model through existing repository boundaries |
| Messages feature | Reuse existing conversation message view where possible |
| Diagnostics | Preserve old center browser/list path for future reference outside default routing |

## Risks

1. **Center-panel browser logic may be entangled with message display.**  
   Mitigation: preserve the current path as a reference while routing default Conversations through the sidebar signature flow; separate reusable message view from browser/navigation only if needed.

2. **Signature rendering could become presentation-owned semantics.**  
   Mitigation: derive signature facts in application/read-model layers; widgets only render.

3. **Sidebar cassette could become a one-off mini-app.**  
   Mitigation: keep it inside the cassette/spec architecture and use existing action intents.

4. **Visual experimentation could drift away from theme rules.**  
   Mitigation: use theme providers and shared widgets; no hard-coded production colors.

## Approval Gate

Implementation should not begin until this proposal, checklist, design notes, and tests plan are reviewed.
