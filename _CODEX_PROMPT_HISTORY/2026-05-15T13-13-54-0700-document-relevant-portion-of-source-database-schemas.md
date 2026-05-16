---
created_at: 2026-05-15T13:13:54-07:00
title: "Document relevant portion of source database schemas"
tags: []
source: codex_prompt_history.html
---

# Document relevant portion of source database schemas

## Prompt

```text
We have encountered another case where source database fields were inferred incorrectly inside importer logic.

Current example:
MessageImporter attempted to read:

- message.chat_id

from Apple chat.db.message, but that column does not exist in the observed schema.

This is an architectural warning sign.

Goal

Create or update source-contract documentation under:

_AGENT_INSTRUCTIONS/agent-per-project/15-MACOS-SOURCE-DATABASES/

This is documentation-only.

Do not modify Dart code.

Purpose

These docs should define the app-relevant semantic access surface for Apple source databases.

Do NOT create exhaustive schema dumps.

Do NOT catalog irrelevant Apple internals.

Initial target docs

Please create/update:

00-OVERVIEW.md
10-CHAT-DB.md
20-ADDRESSBOOK-DB.md

Focus

Document only fields/tables likely relevant to MessageLens readers/importers:

For chat.db:
- message
- handle
- chat
- chat_message_join
- chat_handle_join
- attachment
- message_attachment_join

Critically document relationship ownership:

- message does NOT directly own chat_id
- message-to-chat relationship is via chat_message_join
- chat-to-handle relationship is via chat_handle_join
- message-to-attachment relationship is via message_attachment_join

For AddressBook:
- document only app-relevant contact/person/email/phone/name/image fields or tables already used or likely to be used
- avoid exhaustive Apple schema cataloging

Architectural guidance to include

These docs should state clearly:

- Apple databases are external source contracts, not app-owned schemas.
- Importers/readers must not infer source fields.
- Relationship ownership must be verified explicitly.
- Source-local row IDs are not globally meaningful.
- Multi-source/archive support requires source_id + source_table + source_rowid provenance.
- Source docs define the semantic contract that importers/readers should consult.

Desired output

Report:
- docs added/updated
- key relationship clarifications documented
- incorrect assumptions identified
- recommended follow-up fix for MessageImporter

Do not make the MessageImporter code fix in this task.
```
