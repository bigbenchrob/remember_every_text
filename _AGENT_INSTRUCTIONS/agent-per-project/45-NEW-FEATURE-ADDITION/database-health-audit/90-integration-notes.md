Integration with Support Bundle

The Database Health Report becomes a first-class component of:
	•	Export Support Bundle

Bundle structure:
	•	logs/
	•	app_environment.json
	•	database_health.json
	•	table_counts.csv
	•	relationship_checks.csv
	•	failing_relationship_samples.json (Phase 2)
	•	sanitized_relational_snapshot.json (Phase 3, optional)

⸻

Integration with Reset Flow

Replace:
	•	“Send logs”
	•	“Delete data folder”

With:
	•	“Export Support Bundle”
	•	“Reset App Data (move to backup)”

⸻

Reset Behavior

Instead of deletion:
	•	move:
~/Library/Application Support/com.bigbenchsoftware.MessageLens
→ MessageLens.backup-

This ensures:
	•	reversibility
	•	forensic inspection capability

⸻

Optional Combined Action

“Export Support Bundle and Reset”

Flow:
	1.	generate bundle (including database health)
	2.	move data folder
	3.	relaunch app

⸻

Future Extensions
	•	integrate health checks into onboarding diagnostics
	•	surface “health warnings” in-app
	•	allow internal debug UI to display report summaries

⸻

Final Note

This system transforms debugging from:

“Send me your database and I’ll poke at it”

into:

“Send me a precise structural report of what went wrong”

— which is faster, safer, and dramatically more scalable.