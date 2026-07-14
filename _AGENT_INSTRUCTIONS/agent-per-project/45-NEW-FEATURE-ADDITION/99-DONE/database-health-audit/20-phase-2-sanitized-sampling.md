Goal

Provide targeted visibility into failures by exporting small, privacy-safe samples of problematic rows.

This phase is activated only when Phase 1 reveals anomalies.

⸻

Key Idea

Export only the edges of failure, not the full dataset.

⸻

Outputs

failing_relationship_samples.json

Contains small samples (e.g. first 50–200 rows) of:
	•	unmatched foreign keys
	•	orphaned rows
	•	missing join relationships

⸻

Data Rules

Allowed fields:
	•	numeric ids
	•	hashed identifiers (GUIDs, handle IDs, chat IDs)
	•	enum/status values

Disallowed:
	•	any raw identifiers that could be user-visible
	•	any content fields

⸻

Hashing Strategy

If exporting identifiers like GUIDs:
	•	use a one-way hash
	•	use a per-bundle salt
	•	ensure consistency within the bundle

Example:

message_guid → message_guid_hash

⸻

Example Samples

attachments missing archived match:
	•	attachment_id
	•	message_guid_hash
	•	import_attachment_id

messages missing chat linkage:
	•	message_id
	•	message_guid_hash

⸻

Sampling Rules
	•	deterministic ordering (e.g. ORDER BY id)
	•	capped sample size (e.g. LIMIT 100)
	•	prioritize earliest failures

⸻

Design Constraints
	•	no full-table dumps
	•	no ability to reconstruct user identity
	•	samples must be minimal but sufficient

⸻

Success Criteria

A developer should be able to:
	•	inspect concrete failing cases
	•	reproduce join logic issues
	•	validate assumptions about key relationships