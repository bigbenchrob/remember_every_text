# 58 - Coordinated Spec-Driven Content System

This folder is a working architecture brief for the system we were actively
stabilizing during this session.

It exists for one reason: another agent should be able to audit the intended
design, compare it to the current implementation, and identify flaws without
having to reconstruct the investigation from chat logs or stale older docs.

This folder does not attempt to retroactively correct earlier architecture
documents. Treat it as the current audit packet for the sidebar, panel, and
message-surface coordination model.

## What this packet covers

- The target model for a pure, immutable, declarative surface system
- The role of sidebar cassette layout versus cassette payloads versus render
  widgets
- How center-panel content should derive from canonical sidebar flow state
- The three-layer message display model: scope, ordinal access, and hydration
  with attachment provenance
- How live Messages attachments and archived/imported historical images fit
  into the same hydrated message pipeline
- The specific ways the current implementation still falls short of that model

## File guide

- `00-system-objectives-and-invariants.md`
  Overall system intent, invariants, and the "interlocking gears" model
- `10-sidebar-panel-coordination.md`
  Sidebar cassette layout, sidebar payload transport, center/right panel
  projection, and the single-writer goal
- `20-message-display-pipeline.md`
  Message-surface layering, ordinal access, hydration, search, and attachment
  provenance for live and archived images
- `30-current-state-caveats-and-audit-focus.md`
  Current implementation status, known impurities, and the highest-value audit
  questions

## Current stance

The system is moving away from transporting or caching built widgets as state
and toward transporting only semantic state and immutable render payloads.

That transition has begun, but it is not complete.