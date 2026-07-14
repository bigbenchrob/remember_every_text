---
tier: project
scope: checklist
owner: agent-per-project
last_reviewed: 2025-12-24
source_of_truth: historical-record
links:
  - ./PROPOSAL.md
  - ./PHASES.md
tests: []
---

# Checklist — Global Messages Timeline

> Current conformance note (2026-06-19): this checklist records the original
> global timeline implementation target. Future work must use a graph-backed
> `MessageEvidenceScope` with a full logical skeleton and shared evidence-row
> hydration. Do not restore retained `working.db` ordinal/index providers as
> the ordinary global timeline authority.

## Proposal / Scope
- [x] Confirm v1 scope choice: A / B / C. _(Chose B: filters framework only for now)_
- [x] Confirm entry point in UI/navigation. _(Added `TopChatMenuChoice.globalTimeline` + `MessagesSpec.globalTimelineV2()`)_
- [ ] Confirm required correspondent label fields (name vs handle). _(TODO in hydration provider; using senderName for now)_

## Data & Index
- [x] Historical target: verify `message_index` has monthKey support and required lookup methods. _(Superseded by graph evidence skeletons.)_
- [x] Historical target: verify mapping for "jump to search hit" (messageId → ordinal). _(Superseded by graph `message_ss_id` evidence scopes.)_
- [x] Confirm DB maintenance lock behavior for global providers. _(Ordinal provider short-circuits with totalCount=0 during lock)_

## Providers & View Model
- [x] Create `global_messages` view model module with VM + `jump/` + `hydration/`. _(All created: VM, ordinal provider, hydration provider)_
- [x] Graph-era target: ensure all DB access goes through graph evidence spine/repository boundaries. _(Do not use retained `driftWorkingDatabaseProvider`.)_
- [x] Ensure controller/timer lifecycle is idempotent in VM. _(Search controller properly disposed; listener attached only once)_

## UI
- [x] Implement dumb global timeline view. _(GlobalTimelineV2View with browse skeleton + hydration)_
- [ ] Add prominent correspondent label per row. _(Using senderName; needs enhancement for global-specific UI model)_
- [x] Implement two modes: browse vs search. _(Browse done; search placeholder exists in VM but not wired to real provider)_
- [x] Verify no scroll jitter during hydration. _(Using fixed-height skeleton placeholders)_

## Search
- [ ] Implement global search provider. _(VM has debounce + placeholder; no real search provider yet)_
- [ ] Add "jump to result" behavior. _(Framework exists; not implemented)_
- [ ] Ensure unknown senders are discoverable (no contact required). _(Will work once search provider built)_

## Tests
- [ ] Provider tests for ordinal/jumps.
- [ ] Provider tests for global search results.
- [ ] Widget smoke tests for browse/search switching.

## Verification
- [ ] Manual: open All Messages, scroll, jump month, search, jump to hit. _(Partially: can open, browse; search/month-jump not wired)_
- [x] `flutter analyze` clean. _(Verified earlier)_
- [x] `dart run build_runner build --delete-conflicting-outputs` clean. _(Ran successfully earlier)_

## Documentation
- [ ] Add/extend `40-FEATURES/messages/` docs with global timeline section.
- [ ] Include a human-readable mechanistic walkthrough for global timeline.
