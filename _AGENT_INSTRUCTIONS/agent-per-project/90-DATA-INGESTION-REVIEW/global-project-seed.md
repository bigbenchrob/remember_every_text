This is exactly the kind of document that benefits from being written before any code changes. It establishes the rules of the game so that every subsequent task can be judged against them.

MessageLens Production Readiness Master Plan

Purpose

The purpose of the Production Readiness project is to transition MessageLens from an actively evolving development application into a trustworthy long-term personal archive.

The emphasis of this phase is no longer adding major features. Instead, it is ensuring that every operation affecting the user’s permanent data is predictable, recoverable, observable and worthy of trust.

This project will be coordinated from:

90-DATA-INGESTION-REVIEW

This folder contains focused sub-projects devoted to each aspect of data ingestion and preservation.

⸻

Guiding Principles

Production data is sacred

The user’s active MessageLens data folder is now considered the production archive.

It is never again used as an experimental environment.

Development, testing and experimentation take place elsewhere.

Every design decision in this phase begins with this assumption.

⸻

Preservation over convenience

MessageLens is fundamentally an archival application.

Whenever there is tension between convenience and preservation, preservation wins.

Data should be added rather than replaced.

Historical evidence should never be discarded merely because a newer source exists.

⸻

Every operation should inspire confidence

Large operations such as onboarding, archival imports and attachment reconciliation should feel calm, deliberate and transparent.

The software should communicate:

“I’ve got this.”

The interface should never leave the user wondering whether something important has happened behind the scenes.

⸻

Evidence is never assumed

Every import should produce evidence describing what occurred.

The user should never have to guess:

- whether messages were imported
- whether attachments were copied
- whether duplicates were skipped
- whether errors occurred

Every significant operation should leave behind an auditable record.

⸻

Production changes should be intentional

Whenever practical, production modifications should follow the sequence:

Source

↓

Analysis

↓

Validation

↓

Review

↓

Commit

The system should avoid modifying production data until it has first demonstrated exactly what will occur.

⸻

Project Structure

The Production Readiness project is expected to consist of a number of focused workstreams.

These are intentionally independent so they can be developed, tested and documented separately.

⸻

Workstream 1 — Onboarding Review

Purpose:

Review and refine the complete first-run experience.

Topics include:

- first launch
- permissions
- initial database creation
- first message import
- attachment import
- progress presentation
- interruption handling
- recovery after restart
- completion experience

Deliverables:

- onboarding workflow review
- implementation recommendations
- user experience polish
- recovery procedures

⸻

Workstream 2 — Production Data Protection

Purpose:

Define how production archives are protected from development activity.

Topics include:

- production versus sandbox environments
- snapshot strategy
- migration safety
- rollback planning
- operational rules
- developer workflow

Deliverables:

- production data policy
- recommended workflows
- safety checklist

⸻

Workstream 3 — Historical Messages Import

Purpose:

Develop a reliable process for importing Apple Messages folders from historical sources.

Potential sources include:

- older Macs
- Time Machine backups
- archived Messages folders
- recovered drives

Topics include:

- duplicate detection
- provenance recording
- incremental import
- message reconciliation
- attachment reconciliation

Deliverables:

- import architecture
- validation process
- testing plan

⸻

Workstream 4 — Archived MessageLens Import

Purpose:

Allow previous MessageLens archives to contribute information to the current production archive.

Topics include:

- compatibility checking
- schema evolution
- duplicate resolution
- overlay merging
- attachment reconciliation

Deliverables:

- import strategy
- conflict resolution rules
- migration procedures

⸻

Workstream 5 — Attachment Integrity

Purpose:

Ensure that MessageLens can account for every attachment referenced by imported messages.

Topics include:

- attachment discovery
- missing attachment detection
- duplicate attachment handling
- checksum validation
- repair opportunities

Deliverables:

- attachment integrity report
- reconciliation procedures
- repair workflow

⸻

Workstream 6 — Import Validation

Purpose:

Ensure that every ingestion process produces objective evidence describing what occurred.

Typical reports may include:

- messages scanned
- new messages imported
- duplicates detected
- attachments discovered
- attachments copied
- missing attachments
- elapsed time
- warnings
- errors

The objective is to replace uncertainty with measurable evidence.

⸻

Workstream 7 — Production Health

Purpose:

Provide ongoing visibility into the state of the archive.

Potential indicators include:

- database integrity
- attachment integrity
- overlay integrity
- archive completeness
- storage usage
- historical source inventory

The goal is to reassure the user that the archive remains healthy over time.

⸻

Development Strategy

Each workstream follows the same progression:

1. Understand the current implementation.
2. Document existing behaviour.
3. Identify deficiencies.
4. Propose improvements.
5. Validate the design.
6. Implement.
7. Test using disposable sandbox environments.
8. Repeat until the behaviour is considered production-ready.

Only after successful validation should the corresponding procedure be applied to the production archive.

⸻

Definition of Success

The Production Readiness project is complete when:

- the production archive is treated as immutable during development
- onboarding is calm, informative and resilient
- historical imports are repeatable and trustworthy
- archived MessageLens data can be safely merged
- attachment preservation is verifiable
- every ingestion operation produces objective evidence
- the user can confidently expand their archive without fear of data loss

⸻

Long-Term Vision

MessageLens is evolving beyond a viewer for today’s Messages database.

Its purpose is to become a permanent, continuously improving archive of a person’s digital conversations.

As new historical sources are discovered over the years, they should enrich the archive rather than complicate it.

Every recovered message, every recovered attachment and every recovered conversation contributes another piece of a personal history that MessageLens preserves with care.

The final measure of success is not merely that MessageLens imports data correctly.

It is that the user entrusts it with a lifetime of conversations without hesitation.

I think this is an excellent fit for 90-DATA-INGESTION-REVIEW/00-PRODUCTION-READINESS-MASTER-PLAN.md. It establishes the philosophy and the workstreams without prematurely committing us to implementation details. As each workstream begins, it can then have its own numbered subfolder (10-ONBOARDING-REVIEW, 20-PRODUCTION-DATA-PROTECTION, 30-HISTORICAL-MESSAGES-IMPORT, etc.) containing analyses, design notes, and eventually Codex implementation prompts.
