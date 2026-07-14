database-health-audit / 10-phase-1-structural-health.md

Goal

Provide a complete structural overview of the database without exposing any row-level user data.

This phase must be sufficient to diagnose:
	•	missing or empty tables
	•	major pipeline failures
	•	obvious join inconsistencies

⸻

Outputs

database_health.json

Primary structured report.

table_counts.csv

Simple tabular overview for quick scanning.

⸻

Required Metrics

1. Table Inventory

For each table:
	•	table_name
	•	row_count
	•	min_id (if applicable)
	•	max_id (if applicable)

Example:

messages: 182442
attachments: 38210
message_attachment_join: 31004

⸻

2. Null / Empty Analysis

For critical columns:
	•	count_null
	•	count_non_null

Example:

attachments.local_path:
	•	null: 12,004
	•	non_null: 26,206

⸻

3. Relationship Coverage

For each known relationship:

Report:
	•	parent_count
	•	child_count
	•	matched_count
	•	unmatched_count

Example:

attachments → archived_attachments:
	•	matched: 37,981
	•	unmatched: 229

⸻

4. Orphan Detection

Explicit counts of:
	•	child rows with no parent
	•	parent rows with no child (if relevant)

⸻

5. Pipeline Integrity Checks

Codify known invariants:

Examples:
	•	messages should have chat linkage
	•	attachments should map to import_attachment_id
	•	archived_attachments should map to attachments

Each invariant reports:
	•	pass/fail
	•	violation_count

⸻

Design Constraints
	•	No row-level exports
	•	No identifiers beyond counts
	•	No hashing required at this stage

⸻

Success Criteria

A developer should be able to answer:
	•	“Which tables are empty?”
	•	“Which relationships are broken?”
	•	“Where did the pipeline fail?”

— without needing any further data.