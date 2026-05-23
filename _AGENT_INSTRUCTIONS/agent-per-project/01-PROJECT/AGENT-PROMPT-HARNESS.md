AGENT PROMPT HARNESS — MessageLens

Purpose

This document defines reusable prompt harnesses for Copilot/Codex/agent work on MessageLens.

The goal is to reduce ambiguous agent runs, prevent architectural drift, and lower usage-based AI cost by making every non-trivial agent task start from clear inputs:

Context
Goal
Scope
Constraints
Known pitfalls
Required output

Core principle

Agents should not “figure out” MessageLens architecture from scratch on every task.

Every agent run should be aimed at a specific slice and constrained by the deterministic spec-driven architecture.

Global architecture rules

These rules apply to all MessageLens agent tasks.

1. Flow state is authoritative

Durable UI state comes from flow state.

Do not derive durable state from the current cassette rack, rendered widgets, selected cards, or prior UI composition.

2. Topology is deterministic

Given the same flow state, topology must derive the same sidebar/panel configuration.

Topology answers: “what comes next?”

It must not depend on incidental render state.

3. Cassette rack is a projection

The cassette rack is derived from flow state and topology.

It is not the source of truth.

Do not add new rack introspection helpers to infer user intent.

4. Coordinators route; they do not react

Coordinators may route specs to resolvers.

Coordinators must not use ref.watch().

Coordinators must not construct widgets.

Coordinators should return immutable payload/view-model data plus inert rendering metadata.

5. Resolvers produce data, not UI

Resolvers return view models or payloads.

They must not leak Widget, WidgetBuilder, ConsumerWidget, BuildContext, Ref, controllers, or closures carrying UI state across the boundary.

6. Presentation owns widgets

Feature presentation code may build widgets.

Essentials owns shared chrome, layout, spacing, rails, and sidebar composition.

Features provide semantics and payloads, not arbitrary layout authority.

7. Ephemeral and persistent flows are separate

Persistent choices update durable flow state.

Ephemeral actions are transient projections.

Ephemeral specs are replace-only and clear-only.

They must not participate in stable topology.

They must not linger as durable top-menu choices.

8. Settings is not special at disposal time

Do not fix Settings bugs with mode-switch hacks or disposal exceptions.

Use the stable/ephemeral lifecycle correctly.

9. Prefer structural fixes over spacing patches

For sidebar visual problems, first ask whether the semantic grouping/chrome model is missing a role.

Avoid scattered one-off padding or margin overrides.

10. Tests must protect architecture

When changing flow, topology, racks, specs, or settings behavior, add or update tests that enforce the contract, not merely the screenshot outcome.

Standard prompt harness

Use this for any non-trivial agent task.

PROMPT HARNESS — STANDARD

Context

This change is within MessageLens. The app is a macOS Flutter app using a deterministic, spec-driven UI architecture. Durable choices live in flow state. Sidebar cassette stacks and panel views are derived from specs/topology. Coordinators route specs to resolvers and must not construct widgets or watch providers.

Goal

[Describe the desired outcome.]

Scope

[Name the exact files, feature area, or layer. Keep scope as small as possible.]

Constraints

- Flow state is the durable source of truth.
- Do not derive state from the existing cassette rack.
- Do not add rack introspection helpers.
- Coordinators must not use ref.watch().
- Coordinators must not construct widgets.
- Resolvers must return data/view models, not UI.
- Essentials owns shared sidebar chrome, layout, rails, and spacing.
- Features provide payloads and semantics.
- Ephemeral specs are replace-only and clear-only.
- Ephemeral specs must not participate in stable topology.
- Preserve deterministic flow state → topology → specs → view model → UI mapping.

Known pitfalls

[Call out likely mistakes for this task.]

Required output

- First explain the intended approach.
- Then make the minimal implementation.
- Add or update tests where the architecture contract could regress.
- Do not broaden scope without explaining why.

Specialized harness: topology change

Use this when changing sidebar flow, cassette order, settings/menu behavior, or what appears next.

PROMPT HARNESS — TOPOLOGY CHANGE

Context

This is a topology change in MessageLens. Topology must remain deterministic and derived from flow state.

Goal

[Describe the new flow.]

Current behavior

[Describe what happens now.]

Desired behavior

[Describe the exact sidebar/panel result.]

Scope

[Topology files/spec files/dispatcher files only, unless a broader change is justified.]

Rules

- No deriving durable state from the current cassette rack.
- No rack introspection.
- Stable topology reads durable flow state only.
- Ephemeral actions do not affect stable topology.
- A given flow state must map to one predictable UI configuration.
- Settings transient actions must clear/replace as ephemeral projections, not become durable settings choices.

Deliverable

- Identify the topology decision point.
- Implement the minimal change.
- Add regression tests for deterministic behavior.
- Confirm persistent and ephemeral behavior separately.

Specialized harness: bug investigation

Use this when behavior is surprising and the root cause is not yet proven.

PROMPT HARNESS — BUG INVESTIGATION

Context

This bug occurs within MessageLens’ deterministic spec-driven UI pipeline.

Observed behavior

[What I see.]

Expected behavior

[What should happen.]

Suspected area

[Optional.]

Instructions

Trace the flow in this order:

1. User intent / dispatcher
2. Flow state mutation
3. Stable topology derivation
4. Ephemeral projection, if any
5. Ordered spec merge
6. Coordinator routing
7. Resolver output
8. Presentation/chrome rendering

Rules

- Do not propose a fix until the first divergence point is identified.
- Do not patch symptoms in presentation if the bug originates in flow/topology.
- Do not add new durable state unless required.
- Do not add rack introspection.

Deliverable

- Root cause.
- First divergence point.
- Minimal architecture-consistent fix.
- Regression test recommendation.

Specialized harness: feature addition

Use this when adding a new app feature, report, menu item, cassette, or panel.

PROMPT HARNESS — FEATURE ADDITION

Context

This is a new MessageLens feature. It must integrate through the existing deterministic spec pipeline.

Goal

[Feature description.]

User-facing behavior

[What the user should see and do.]

Integration points to evaluate

- Flow state
- Persistent vs ephemeral intent
- Sidebar topology
- Cassette specs
- Panel/view specs
- Coordinator/resolver
- Essentials chrome/layout
- Tests
- Changelog/docs

Constraints

- Do not introduce alternate state pathways.
- Do not make the rack authoritative.
- Do not let ephemeral choices become durable menu selections.
- Keep feature payload separate from shared layout/chrome.
- Prefer small feature-owned specs plus shared essentials-owned rendering contracts.

Deliverable

- Step-by-step implementation plan.
- File-by-file change list.
- Tests to add/update.
- Changelog note if user-visible.

Specialized harness: sidebar UI / cassette refinement

Use this for spacing, grouping, sidebar serenity, hero cards, info cards, dense lists, heatmaps, and cassette chrome.

PROMPT HARNESS — SIDEBAR UI REFINEMENT

Context

This is a sidebar cassette presentation refinement. Essentials owns shared layout, spacing, chrome, rails, and visual grouping. Features provide payload and semantic role.

Problem

[Describe what feels visually wrong.]

Goal

[Describe the desired visual outcome.]

Scope

[Prefer essentials sidebar chrome/sectioning/layout files unless the feature payload lacks needed semantics.]

Rules

- Do not solve shared layout problems inside one feature widget.
- Do not scatter one-off padding/margin overrides.
- Prefer adding or refining semantic grouping roles at the shared chrome level.
- Preserve centralized vertical rhythm.
- Dense list cassettes should use the shared dense/list style.
- If two cassettes read as one conceptual unit, model that grouping explicitly rather than relying only on global gaps.

Deliverable

- Identify whether this is a spacing issue, a semantic grouping issue, or a payload issue.
- Propose the shared chrome-level fix first.
- Implement minimal changes.
- Add visual or widget regression coverage if practical.

Specialized harness: documentation / agent-instructions update

Use this when updating \_AGENT_INSTRUCTIONS.

PROMPT HARNESS — DOCUMENTATION UPDATE

Context

This is an update to MessageLens agent instructions. These docs guide future Copilot/Codex work and should be clear, enforceable, and easy to scan.

Goal

[Describe what the documentation should teach or enforce.]

Placement

[Exact folder/file, or ask the agent to propose the best location.]

Rules

- Prefer durable architectural rules over one-off implementation notes.
- Use headings and bullets.
- Avoid vague advice.
- Include “do / do not” guidance where future agents could drift.
- Cross-reference related docs if needed.
- Keep terminology consistent: topology, specs, surface, cassette, resolver, coordinator, harness, artifact.

Deliverable

- Proposed doc placement.
- Exact text to insert.
- Any follow-up docs that should be updated.

Pre-flight checklist before running an agent

Before starting an agent session, confirm:

- Is the goal explicit?
- Is the scope bounded?
- Did I identify whether this is persistent or ephemeral?
- Did I list the architecture constraints?
- Did I warn about likely pitfalls?
- Did I ask for plan before broad edits?
- Did I specify expected tests?
- Did I avoid asking the agent to “look around and improve things” without a boundary?

Cost-control rules

These rules exist because agentic AI usage is metered and expensive.

1. Batch intent before execution

Do not run five small prompts when one structured prompt would do.

2. Use chat for thinking, agent for execution

Refine the plan before launching expensive repo-wide work.

3. Limit context explicitly

Name the files, folders, or architectural layer.

4. Avoid exploratory agent runs

If the task is vague, first ask for a diagnosis or plan, not implementation.

5. Reuse known constraints

Do not make the agent rediscover MessageLens rules every time.

6. Prefer minimal diffs

Large speculative diffs create review cost, test cost, and token cost.

7. Use code review selectively

Copilot code review may consume both AI credits and GitHub Actions minutes. Use it for meaningful cross-file changes, not tiny diffs.

Review rubric for agent output

Before accepting an agent’s work, check:

- Does durable state still come from flow state?
- Did the agent add rack introspection?
- Did any coordinator start watching providers?
- Did resolver output remain UI-free?
- Did feature code take over shared layout responsibility?
- Did ephemeral behavior remain replace-only/clear-only?
- Did Settings get a special-case disposal hack?
- Are tests enforcing the architecture, not just the current output?
- Is the diff smaller than expected?
- Did the change preserve deterministic reconstruction after mode switches/rebuilds?
