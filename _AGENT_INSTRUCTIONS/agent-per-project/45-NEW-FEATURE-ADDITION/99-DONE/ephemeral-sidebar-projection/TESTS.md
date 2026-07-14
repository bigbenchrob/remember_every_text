---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-04-18
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ../../55-EPHEMERAL-SPEC-HANDLING/INVIOLATE_RULES.md
tests: []
feature: ephemeral-sidebar-projection
status: proposed
created: 2026-04-18
---

# Test Plan - Ephemeral Sidebar Projection

## Stable Projection Tests

- [ ] Stable projection reconstructs from durable flow state only
- [ ] Stable projection remains logically derivable from flow state even where implementation still uses explicit rack mutation helpers
- [ ] Persistent settings context rebuilds the stable settings branch without any ephemeral settings flow present
- [ ] Stable projection does not contain send-logs or reset-message-data expansion state

## Ephemeral Projection Tests

- [ ] Dispatching an ephemeral intent creates an ephemeral cassette chain for the active mode
- [ ] Dispatching a second ephemeral intent replaces the first ephemeral projection rather than accumulating another branch
- [ ] Ephemeral projection is cleared on mode change for the mode being left
- [ ] Ephemeral projection is cleared when durable context changes incompatibly
- [ ] Ephemeral projection never feeds back into stable provider state
- [ ] No public ephemeral-provider behavior depends on stable-rack style mutation operations such as push or truncate

## Coordinator Tests

- [ ] The coordinator reads stable projection and ephemeral projection separately
- [ ] A small essentials helper/provider owns the merged stable-first ordered spec list before the coordinator resolves payloads
- [ ] Visible sidebar order is stable specs first and ephemeral specs second
- [ ] Ephemeral cassettes still resolve through normal feature coordinator and payload routing

## Intent And Dispatcher Tests

- [ ] Persistent intents update durable flow state and stable projection only
- [ ] Ephemeral intents update ephemeral projection only
- [ ] The dispatcher does not inspect payload fields or row metadata to decide whether an intent is persistent or ephemeral
- [ ] The dispatcher routes on typed persistent versus typed ephemeral intent classes rather than a mixed intent plus a semantic field
- [ ] Cancelling an ephemeral flow clears the ephemeral projection without mutating durable flow state

## Topology Tests

- [ ] Ephemeral roots may derive only ephemeral descendants
- [ ] No stable cassette is ever derived beneath an ephemeral root
- [ ] Stable topology does not consult ephemeral provider state
- [ ] Ephemeral topology is resolved through a distinct topology path from stable topology

## Migration Regression Tests

- [ ] `SidebarUtilityCassetteSpec.settingsMenu` no longer carries transient expansion state
- [ ] Settings top menu emits intrinsic persistent or ephemeral intents instead of a mixed intent
- [ ] Inert settings menu group headers emit no intent and cannot trigger either persistent or ephemeral routing
- [ ] The settings-mode exit cleanup hack is removed and no longer required for correctness
- [ ] Leaving and re-entering Settings restores stable projection only
- [ ] No new behavior in the migrated settings flow depends on cassette index as a source of meaning
