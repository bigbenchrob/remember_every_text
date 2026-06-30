Start a restricted new feature slice: Unified Message Evidence Header.

Goal:
Bring all center-panel message evidence headers into a shared semantic/header presentation system without changing message evidence rendering, message data sources, or sidebar behavior.

This is a restricted presentation-architecture feature, not a redesign.

Core principle:
Source-specific composers write meaning.
A shared header renderer writes form.

Do NOT build a magical header composer that infers wording from raw data.

Do NOT hard-code separate full headers per surface.

Instead:
source-specific scope/header composers should produce a typed MessageEvidenceHeaderModel, and one shared MessageEvidenceHeader renderer should render it consistently.

Canonical flow:

MessageEvidenceScope / source route
→ source-specific header composition
→ MessageEvidenceHeaderModel
→ shared MessageEvidenceHeader renderer

The Contact All Messages header is the current visual gold standard:

- no card
- no heavy panel
- no framed header box
- calm title
- compact scope/date/count line
- optional interaction row
- subtle blur/fade barrier between header and scrolling messages
- minimal chrome

Surfaces to audit first:

- Contact / All messages
- Contact / By conversation
- Conversations
- Search all messages
- Search result context
- From unfamiliar sources
- Recovered deleted messages
- Recovered no-handle messages
- Handle-filtered messages

First deliverable:
Create a short proposal/design note before coding.

Document:

1. Existing header implementations and files.
2. Which header elements are shared:
   - primary identity/title
   - participant/context line
   - date range
   - message count
   - scope/caveat explanation
   - search/filter row
   - scope-specific actions
3. Which differences are legitimate source-specific meaning.
4. Proposed MessageEvidenceHeaderModel shape.
5. Proposed shared renderer responsibilities.
6. Surfaces to migrate in the first slice.
7. Surfaces deferred.
8. Tests needed.

Initial implementation slice:

- Introduce MessageEvidenceHeaderModel.
- Introduce or refine shared MessageEvidenceHeader renderer.
- Migrate one or two low-risk graph-backed surfaces first, preferably Contact All Messages and Conversation messages.
- Preserve current behavior and wording as much as possible.
- Do not move navigation controls into the center panel.
- Do not change MessageEvidenceScope, skeleton, hydration, or row rendering.
- Do not add new message renderers.
- Do not add new data queries.

Header model should allow, but not require:

- title
- subtitle/context
- participant display list or label
- date range
- message count
- scope note/caveat
- active filter/scope chip
- search field config
- source-specific actions

Important invariant:
The renderer controls typography, spacing, blur/fade, chrome minimization, and layout rhythm.
The source-specific composer controls semantic wording and which optional regions exist.

Target:
Every message evidence surface should feel like the same reading environment, even when the selected evidence source differs.
