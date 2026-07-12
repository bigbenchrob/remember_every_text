---
tier: project
scope: architecture-checklist
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: doc
status: approved-architecture
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
---

# Conversation Intent Checklist

This checklist records approved architecture decisions and future implementation
planning gates. It is not authorization to implement.

## Package Creation

- [x] Create Conversation Intent architecture package.
- [x] Define Conversation Intent.
- [x] Distinguish source state, graph state, and user intent.
- [x] Explain overlay ownership.
- [x] Explain relationship to Conversation Tags.
- [x] Explain relationship to Favourites and Working Sets.
- [x] Explain relationship to Search, Discovery, and Conversation Lenses.
- [x] Document product philosophy.
- [x] Document open questions.
- [x] Document phased implementation strategy.
- [x] Document validation strategy.
- [x] Review package with user.
- [x] Consolidate approved open-question decisions into canonical package docs.

## Phase 0: Concept Approval

- [x] Confirm "Conversation Intent" is the right term.
- [x] Confirm Tags should be treated as a durable feature built on this
      seam.
- [x] Confirm Favourites remain user-facing as Favourites.
- [x] Confirm Working Sets remain distinct from Tags.
- [x] Confirm Suppressed visibility state belongs to the intent seam.
- [x] Confirm Conversation Notes are one-note-per-Conversation Annotation
      intent initially.
- [x] Confirm Saved Investigations are outside this package and need separate
      architecture later.

## Phase 1: Existing Intent Audit

- [ ] Audit Core Favourites ownership and persistence.
- [ ] Audit Conversation sidebar mode state to ensure it does not own durable
      intent.
- [ ] Audit any suppressed/spam-like Conversation state, if present.
- [ ] Audit overlay identity forms used by existing Conversation user intent.
- [ ] Identify transitional seams that should be documented before
      implementation.

## Phase 2: Minimal Shared Intent Model

Future design work should define, at architectural level:

- [x] stable Conversation identity reference;
- [x] durable versus session intent distinction;
- [x] intent owner boundaries;
- [x] read-model merge rules;
- [ ] export/import expectations;
- [x] AI suggestion versus confirmed intent distinction.

Do not choose schema names or provider names in this phase.

## Phase 3: Tags Built On Intent

When Tags enter implementation planning:

- [ ] Confirm the Tags package references Conversation Intent.
- [ ] Define Tags as one durable intent type.
- [ ] Ensure tag assignment uses stable Conversation identity.
- [ ] Ensure tag display is available wherever the Conversation appears.
- [ ] Ensure Search/Discovery can consume tag state without owning it.

## Phase 4: Structured Conversation Retrieval

Future retrieval design should consider:

- [ ] contact identity badges;
- [ ] tag badges;
- [ ] favourite badges;
- [ ] working-set badges;
- [ ] visibility badges;
- [ ] note/classification badges;
- [ ] Conversation Lenses applied to selected intent scopes.

This phase is not message-content search.

## Completion Criteria

Conversation Intent architecture is ready when:

- [x] user-authored/user-confirmed Conversation meaning has one documented
      conceptual home;
- [x] Favourites, Tags, Working Sets, Suppressed state, Notes, and confirmed AI
      classifications can be described without separate special-case
      architectures;
- [x] durable intent is stored in overlay/user-intent storage;
- [x] graph projection does not read or write intent;
- [x] sidebar state does not own durable intent;
- [x] read models can merge graph facts and intent at read time;
- [x] Search, Messages, Contacts, and Discovery can consume intent without
      owning it;
- [x] future Conversation retrieval can be modeled as matching people,
      favourites, tags, working sets, visibility, and other intent tokens.

## Explicit Non-Goals

- [ ] Do not implement database schema in this package.
- [ ] Do not implement provider or widget names in this package.
- [ ] Do not collapse Favourites, Tags, and Working Sets into one UI.
- [ ] Do not implement AI suggestions.
- [ ] Do not implement structured retrieval yet.
- [ ] Do not implement Saved Investigations in this package.
