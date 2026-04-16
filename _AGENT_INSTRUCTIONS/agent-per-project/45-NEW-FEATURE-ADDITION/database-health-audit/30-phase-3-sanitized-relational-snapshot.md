Goal

Provide a minimal, privacy-safe relational model for deep debugging of complex issues.

This is a last-resort diagnostic tool.

⸻

Philosophy

Reconstruct the shape of the database, not its contents.

⸻

Outputs

sanitized_relational_snapshot.json (or CSV set)

Contains reduced versions of key tables.

⸻

Included Tables (Example)

messages:
	•	id
	•	message_guid_hash
	•	date_bucket (rounded)

attachments:
	•	id
	•	message_guid_hash
	•	import_attachment_id
	•	mime_group (image/video/other)

join tables:
	•	message_guid_hash
	•	attachment_id
	•	chat_id_hash

⸻

Transformations
	•	all GUIDs → hashed
	•	timestamps → rounded (e.g. day-level)
	•	MIME types → grouped categories
	•	no paths, no filenames

⸻

Size Control
	•	optional sampling (e.g. subset of messages)
	•	or filtering to problematic regions only

⸻

When to Use

Only when:
	•	Phase 1 + Phase 2 are insufficient
	•	a complex relational bug cannot be reproduced locally
	•	deeper structural replay is required

⸻

Design Constraints
	•	must remain impossible to recover:
	•	message content
	•	contact identity
	•	file identity

⸻

Success Criteria

Developer can:
	•	simulate joins locally
	•	trace relationship breakdowns
	•	debug multi-stage import issues