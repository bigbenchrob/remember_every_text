Purpose

Define the structure of database_health.json, the primary machine-readable artifact produced by the Database Health Audit system.

This file must summarize the structural health of the MessageLens database environment without exposing user content.

It is intended to support:
	•	human inspection
	•	support bundle review
	•	automated validation in tests
	•	future in-app diagnostics UI

⸻

Design Principles

The schema must be:
	•	deterministic
	•	privacy-safe
	•	forward-extensible
	•	tolerant of missing optional sections
	•	explicit about audit versioning

The file is a structured report, not a raw database export.

⸻

Top-Level Shape

database_health.json is a JSON object with this conceptual structure:

{
“schema_version”: “1.0.0”,
“generated_at”: “2026-04-16T15:23:11Z”,
“audit_version”: “phase1”,
“app”: { … },
“environment”: { … },
“databases”: [ … ],
“table_inventory”: [ … ],
“relationship_checks”: [ … ],
“invariant_checks”: [ … ],
“summary”: { … },
“phase2_samples”: { … },
“phase3_snapshot”: { … },
“errors”: [ … ]
}

⸻

Top-Level Fields

schema_version

String. Required.

Version of the report schema itself.

Example:
“1.0.0”

This changes when the JSON structure changes.

⸻

generated_at

String. Required.

UTC timestamp in ISO 8601 format indicating when the report was created.

Example:
“2026-04-16T15:23:11Z”

⸻

audit_version

String. Required.

Describes which audit level generated the file.

Allowed initial values:
	•	“phase1”
	•	“phase2”
	•	“phase3”

This is not the same as schema_version.

⸻

app

Object. Required.

Describes the running application that generated the report.

Shape:

{
“name”: “MessageLens”,
“bundle_id”: “com.bigbenchsoftware.MessageLens”,
“version”: “0.9.0”,
“build_number”: “123”,
“build_channel”: “debug”
}

Fields:
	•	name: string, required
	•	bundle_id: string, required
	•	version: string, required
	•	build_number: string, optional but strongly recommended
	•	build_channel: string, optional
	•	examples: “debug”, “release”, “testflight”, “local-dev”

⸻

environment

Object. Required.

High-level runtime environment information.

Shape:

{
“platform”: “macOS”,
“platform_version”: “15.4”,
“device_model”: “Macmini”,
“timezone”: “America/Vancouver”,
“has_full_disk_access”: true,
“startup_flags”: {
“option_launch_reset_requested”: false
}
}

Fields:
	•	platform: string, required
	•	platform_version: string, optional
	•	device_model: string, optional
	•	timezone: string, optional
	•	has_full_disk_access: boolean, optional
	•	startup_flags: object, optional
	•	diagnostic_notes: array of strings, optional

This section must remain content-free and privacy-safe.

⸻

databases

Array of objects. Required.

Describes each database file or logical database included in the audit.

Example:

[
{
“database_key”: “main”,
“role”: “application_primary”,
“accessible”: true,
“read_only_open_succeeded”: true,
“schema_user_version”: 8
},
{
“database_key”: “overlay”,
“role”: “user_overlays”,
“accessible”: true,
“read_only_open_succeeded”: true,
“schema_user_version”: 3
}
]

Each object shape:
	•	database_key: string, required
	•	stable internal key such as “main”, “overlay”, “historical_snapshot”
	•	role: string, required
	•	human-readable logical role
	•	accessible: boolean, required
	•	read_only_open_succeeded: boolean, required
	•	schema_user_version: integer, optional
	•	migration_version: string or integer, optional
	•	error: string, optional

⸻

Phase 1 Core Sections

table_inventory

Array of objects. Required.

Each entry describes one audited table.

Example:

[
{
“database_key”: “main”,
“table_name”: “messages”,
“exists”: true,
“row_count”: 182442,
“primary_key”: {
“column_name”: “id”,
“min_value”: 1,
“max_value”: 182442
},
“important_columns”: [
{
“column_name”: “guid”,
“null_count”: 0,
“non_null_count”: 182442,
“distinct_count”: 182442
},
{
“column_name”: “text”,
“omitted_for_privacy”: true
}
]
}
]

Each table object:
	•	database_key: string, required
	•	table_name: string, required
	•	exists: boolean, required
	•	row_count: integer, optional if table inaccessible
	•	primary_key: object, optional
	•	important_columns: array, optional
	•	notes: array of strings, optional
	•	error: string, optional

primary_key object:
	•	column_name: string, required
	•	min_value: integer, optional
	•	max_value: integer, optional

important_columns object:
	•	column_name: string, required
	•	null_count: integer, optional
	•	non_null_count: integer, optional
	•	distinct_count: integer, optional
	•	omitted_for_privacy: boolean, optional
	•	notes: array of strings, optional

Guideline:
If a sensitive column exists, it may appear only as a privacy note and must not expose values.

⸻

relationship_checks

Array of objects. Required.

Each entry reports the health of one relationship or join expectation.

Example:

[
{
“check_key”: “attachments_to_archived_attachments”,
“database_key”: “main”,
“relationship_type”: “one_to_one_expected”,
“parent_table”: “attachments”,
“child_table”: “archived_attachments”,
“join_expression_description”: “attachments.message_guid = archived_attachments.message_guid AND attachments.import_attachment_id = archived_attachments.import_attachment_id”,
“parent_row_count”: 38210,
“child_row_count”: 37981,
“matched_row_count”: 37981,
“unmatched_parent_row_count”: 229,
“unmatched_child_row_count”: 0,
“status”: “warning”
}
]

Fields:
	•	check_key: string, required
	•	database_key: string, required
	•	relationship_type: string, required
	•	examples:
	•	“one_to_one_expected”
	•	“one_to_many_expected”
	•	“join_table_coverage”
	•	“existence_check”
	•	parent_table: string, required
	•	child_table: string, optional
	•	join_expression_description: string, required
	•	parent_row_count: integer, optional
	•	child_row_count: integer, optional
	•	matched_row_count: integer, optional
	•	unmatched_parent_row_count: integer, optional
	•	unmatched_child_row_count: integer, optional
	•	status: string, required
	•	allowed:
	•	“pass”
	•	“warning”
	•	“fail”
	•	“not_applicable”
	•	“error”
	•	notes: array of strings, optional
	•	error: string, optional

This section is one of the most important in the report.

⸻

invariant_checks

Array of objects. Required.

These are application-defined integrity assertions.

Example:

[
{
“check_key”: “messages_should_have_chat_linkage”,
“severity”: “high”,
“description”: “Every imported message intended for timeline display should have at least one chat relationship.”,
“status”: “warning”,
“violation_count”: 449,
“evaluated_row_count”: 182442
}
]

Fields:
	•	check_key: string, required
	•	severity: string, required
	•	allowed:
	•	“low”
	•	“medium”
	•	“high”
	•	“critical”
	•	description: string, required
	•	status: string, required
	•	allowed:
	•	“pass”
	•	“warning”
	•	“fail”
	•	“not_applicable”
	•	“error”
	•	violation_count: integer, optional
	•	evaluated_row_count: integer, optional
	•	notes: array of strings, optional
	•	error: string, optional

This is where MessageLens-specific business logic belongs.

⸻

summary

Object. Required.

Provides a compact overall assessment.

Example:

{
“overall_status”: “warning”,
“table_count”: 14,
“relationship_check_count”: 8,
“invariant_check_count”: 6,
“pass_count”: 10,
“warning_count”: 3,
“fail_count”: 1,
“error_count”: 0,
“headline_findings”: [
“handle_message_join is empty”,
“229 attachments are missing archived matches”
]
}

Fields:
	•	overall_status: string, required
	•	allowed:
	•	“pass”
	•	“warning”
	•	“fail”
	•	“error”
	•	table_count: integer, required
	•	relationship_check_count: integer, required
	•	invariant_check_count: integer, required
	•	pass_count: integer, required
	•	warning_count: integer, required
	•	fail_count: integer, required
	•	error_count: integer, required
	•	headline_findings: array of strings, optional

This section should be easy to read in raw JSON.

⸻

Phase 2 Section

phase2_samples

Object. Optional.

This section is absent in pure Phase 1 reports.

Example:

{
“included”: true,
“hashing”: {
“used”: true,
“algorithm”: “sha256”,
“salt_scope”: “per_bundle”
},
“sample_sets”: [
{
“sample_key”: “attachments_missing_archived_match”,
“description”: “Sample attachments lacking archived matches.”,
“row_count”: 50,
“rows”: [
{
“attachment_id”: 1042,
“message_guid_hash”: “3c21d0d2d8d4…”,
“import_attachment_id”: 9981
}
]
}
]
}

Fields:
	•	included: boolean, required if section present
	•	hashing: object, optional
	•	sample_sets: array, required if included is true

hashing object:
	•	used: boolean, required
	•	algorithm: string, optional
	•	salt_scope: string, optional
	•	example: “per_bundle”

sample_set object:
	•	sample_key: string, required
	•	description: string, required
	•	row_count: integer, required
	•	rows: array of objects, required

Important rule:
Each sample set may define its own row object shape, but only with privacy-approved fields.

Recommended allowed field types in sample rows:
	•	integer
	•	boolean
	•	hashed string
	•	enum string

Disallowed:
	•	raw text
	•	paths
	•	names
	•	contact identifiers
	•	unredacted GUIDs if those are considered sensitive in your model

⸻

Phase 3 Section

phase3_snapshot

Object. Optional.

Only present for advanced relational exports.

Example:

{
“included”: true,
“hashing”: {
“used”: true,
“algorithm”: “sha256”,
“salt_scope”: “per_bundle”
},
“table_snapshots”: [
{
“table_name”: “messages”,
“row_count”: 500,
“columns”: [
“id”,
“message_guid_hash”,
“date_bucket”
],
“rows”: [
{
“id”: 1,
“message_guid_hash”: “ab1290…”,
“date_bucket”: “2026-04-16”
}
]
}
]
}

Fields:
	•	included: boolean, required if section present
	•	hashing: object, optional
	•	table_snapshots: array, required if included is true

table_snapshot object:
	•	table_name: string, required
	•	row_count: integer, required
	•	columns: array of strings, required
	•	rows: array of objects, required
	•	sampling_notes: array of strings, optional

This is deliberately flexible, since Phase 3 is meant to be diagnostic and targeted.

⸻

Error Reporting

errors

Array of objects. Required, but may be empty.

Example:

[
{
“scope”: “table_inventory”,
“database_key”: “main”,
“table_name”: “handle_message_join”,
“message”: “Failed to compute row count: no such table”
}
]

Fields:
	•	scope: string, required
	•	examples:
	•	“database_open”
	•	“table_inventory”
	•	“relationship_check”
	•	“invariant_check”
	•	“phase2_samples”
	•	“phase3_snapshot”
	•	database_key: string, optional
	•	table_name: string, optional
	•	check_key: string, optional
	•	message: string, required

Important rule:
Errors in one section must not prevent generation of the rest of the report.

⸻

Recommended Status Semantics

Use these consistently everywhere:

pass

The check completed and found no issues.

warning

The check completed and found a suspicious condition, but not necessarily a fatal one.

fail

The check completed and found a strong violation of an expected invariant.

error

The check itself could not be completed.

not_applicable

The check is valid in principle, but does not apply in this environment or schema version.

⸻

Recommended Minimal Phase 1 Required Fields

A Phase 1 report should always include:
	•	schema_version
	•	generated_at
	•	audit_version
	•	app
	•	environment
	•	databases
	•	table_inventory
	•	relationship_checks
	•	invariant_checks
	•	summary
	•	errors

phase2_samples and phase3_snapshot should be omitted entirely unless those phases were run.

⸻

Example Minimal Phase 1 Report

{
“schema_version”: “1.0.0”,
“generated_at”: “2026-04-16T15:23:11Z”,
“audit_version”: “phase1”,
“app”: {
“name”: “MessageLens”,
“bundle_id”: “com.bigbenchsoftware.MessageLens”,
“version”: “0.9.0”,
“build_number”: “123”,
“build_channel”: “debug”
},
“environment”: {
“platform”: “macOS”,
“platform_version”: “15.4”,
“timezone”: “America/Vancouver”,
“has_full_disk_access”: true,
“startup_flags”: {
“option_launch_reset_requested”: false
}
},
“databases”: [
{
“database_key”: “main”,
“role”: “application_primary”,
“accessible”: true,
“read_only_open_succeeded”: true,
“schema_user_version”: 8
}
],
“table_inventory”: [
{
“database_key”: “main”,
“table_name”: “messages”,
“exists”: true,
“row_count”: 182442,
“primary_key”: {
“column_name”: “id”,
“min_value”: 1,
“max_value”: 182442
}
},
{
“database_key”: “main”,
“table_name”: “handle_message_join”,
“exists”: true,
“row_count”: 0
}
],
“relationship_checks”: [
{
“check_key”: “messages_to_chat_message_join”,
“database_key”: “main”,
“relationship_type”: “join_table_coverage”,
“parent_table”: “messages”,
“child_table”: “chat_message_join”,
“join_expression_description”: “messages.guid = chat_message_join.message_guid”,
“parent_row_count”: 182442,
“child_row_count”: 181993,
“matched_row_count”: 181993,
“unmatched_parent_row_count”: 449,
“status”: “warning”
}
],
“invariant_checks”: [
{
“check_key”: “messages_should_have_chat_linkage”,
“severity”: “high”,
“description”: “Every imported message intended for timeline display should have at least one chat relationship.”,
“status”: “warning”,
“violation_count”: 449,
“evaluated_row_count”: 182442
}
],
“summary”: {
“overall_status”: “warning”,
“table_count”: 2,
“relationship_check_count”: 1,
“invariant_check_count”: 1,
“pass_count”: 0,
“warning_count”: 2,
“fail_count”: 0,
“error_count”: 0,
“headline_findings”: [
“handle_message_join is empty”,
“449 messages are missing chat linkage”
]
},
“errors”: []
}

⸻

Implementation Notes

1. Prefer omission over null clutter

If a field is not relevant, omit it rather than filling the report with nulls.

2. Keep keys stable

Do not casually rename:
	•	check_key
	•	database_key
	•	table_name

These will become useful in tests and support workflows.

3. Make check_key values durable

Examples:
	•	messages_to_chat_message_join
	•	attachments_to_archived_attachments
	•	messages_should_have_chat_linkage

Use stable identifiers, not prose.

4. Never serialize raw sensitive values

Even in “just for debugging” mode.

5. Treat this file as a contract

Once adopted, changes to structure should bump schema_version.

⸻

Suggested Future Extensions

Possible later additions:
	•	duration_ms per section
	•	query_versions for audit SQL provenance
	•	schema_fingerprint
	•	recommended_next_actions
	•	support_bundle_id

These are not required for the first implementation.

⸻

Recommended Initial Dart Modeling Strategy

A practical model split would be:
	•	DatabaseHealthReport
	•	AppReportInfo
	•	EnvironmentReportInfo
	•	AuditedDatabaseInfo
	•	TableInventoryEntry
	•	ImportantColumnSummary
	•	RelationshipCheckResult
	•	InvariantCheckResult
	•	HealthReportSummary
	•	Phase2SamplesSection
	•	Phase2SampleSet
	•	Phase3SnapshotSection
	•	Phase3TableSnapshot
	•	HealthReportError

That keeps the JSON contract explicit and testable.