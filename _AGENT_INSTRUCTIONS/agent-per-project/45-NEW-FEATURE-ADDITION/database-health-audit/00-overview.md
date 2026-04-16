database-health-audit / 00-overview.md

Purpose

Provide a privacy-safe, deterministic diagnostic system for analyzing the structural integrity of MessageLens databases during remote debugging.

This system must allow developers to diagnose issues such as:
	•	incomplete or missing join tables
	•	partially populated import stages
	•	orphaned records
	•	broken or inconsistent relationships

— without exposing any user content (message text, contacts, attachments, etc.).

⸻

Core Principle

Do not export the database.
Generate a diagnostic artifact derived from the database.

All outputs must be purpose-built, not derived from copying and scrubbing raw SQLite files.

⸻

Non-Negotiable Privacy Constraints

The database health audit must NEVER export:
	•	message text or attributedBody
	•	contact names, phone numbers, or emails
	•	file paths or attachment filenames
	•	URLs or preview metadata
	•	any user-generated freeform content

Allowed data types:
	•	internal numeric ids
	•	hashed identifiers (GUIDs, handles, chats)
	•	counts, booleans, enums
	•	timestamps (optionally rounded)
	•	aggregate statistics
	•	small sampled subsets of failing rows

⸻

Output Philosophy

The system produces a Database Health Report, which is:
	•	deterministic
	•	compact
	•	human-readable
	•	machine-parseable (JSON/CSV)
	•	safe to send without hesitation

This report is bundled into the Support Bundle alongside logs.

⸻

High-Level Architecture

DatabaseHealthAuditService:
	•	opens databases in read-only mode
	•	executes a fixed suite of diagnostic SQL queries
	•	transforms results into structured JSON/CSV
	•	writes outputs into the support bundle directory

No mutation of the database is permitted.

⸻

Relationship to Other Systems

This feature integrates with:
	•	option-modifier-bypass startup flow
	•	support bundle export system
	•	onboarding diagnostics (optional reuse of checks)

It replaces the need for:
	•	raw database sharing
	•	ad hoc manual SQL debugging by testers

⸻

Phased Implementation Strategy
	•	Phase 1: Structural Health Report (aggregate only)
	•	Phase 2: Sanitized Failure Sampling
	•	Phase 3: Sanitized Relational Snapshot (targeted, advanced)

Each phase builds on the previous and must remain independently safe.