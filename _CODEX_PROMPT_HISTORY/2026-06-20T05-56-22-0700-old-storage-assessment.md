---
created_at: 2026-06-20T05:56:22-07:00
title: "old storage assessment"
tags: []
source: codex_prompt_history.html
---

# old storage assessment

## Prompt

```text
I would like you to treat the following as a policy and architecture review request before further retained-storage cleanup.

Policy Decision: Legacy Database Disposition

After reviewing the current migration state, my decision is:

macos_import.db
working.db

are NOT intended to become permanent reference databases.

They should be treated as:

retained transitional compatibility storage

only.

The target end state is:

chat.db / AddressBook
→ macos_import_ss.db
→ working_ss.db
→ graph read models
→ Message Evidence Spine
→ overlay intent

without ordinary dependence on:

macos_import.db
working.db

for application behavior.

Reasoning

Historical message text is not at risk.

The authoritative historical source remains:

chat.db
historical chat.db backups
AddressBook source data

The fragile asset is attachment recovery, not message rows.

Attachments live in:

* current Messages attachment storage
* historical Messages backups
* historical MessageLens archive folders

not in:

macos_import.db
working.db

The important requirement is therefore:

graph identity
→ source identity
→ archive/recovery location
→ attachment retrieval

not:

graph identity
→ legacy working/import database

Installed Base Consideration

There is currently no external installed user base.

My copy is the only active deployment.

This means:

* we do not need long-term backward compatibility for existing customers
* we do not need to preserve legacy databases indefinitely for upgrade safety
* we can optimize for architectural correctness and future maintainability

while still preserving archive/recovery integrity.

Existing Safety Measure

A full backup of the current Application Support data folder has already been created.

Therefore:

* retained legacy databases no longer need to function as rollback insurance
* retirement decisions can be evaluated on architectural and data-integrity grounds rather than fear of data loss

Requested Evaluation

Please review the current retained uses of:

macos_import.db
working.db

and classify each remaining dependency as:

1. Must remain temporarily for archive/recovery integrity.
2. Can be migrated to graph/source-scoped identity.
3. Diagnostic-only.
4. Historical-only.
5. Safe deletion candidate.

I am not asking for immediate deletion.

I am asking for a retirement-oriented review using the assumption that:

working.db
macos_import.db

are transitional compatibility artifacts rather than permanent architectural components.

Desired Outcome

Produce:

* an updated retained-storage assessment
* remaining blockers to retirement
* recommended retirement sequence
* any archive/recovery risks that would make retirement unsafe

The goal is to determine whether the project is now ready to move from:

retained compatibility storage

toward:

explicit retirement planning

for the legacy databases.
```
