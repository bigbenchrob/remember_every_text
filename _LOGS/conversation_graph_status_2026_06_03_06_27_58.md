# Conversation graph status log

- captured_at: 2026-06-03T06:27:58.470565
- action: Import + Project Graph
- source: graph status panel

## Build report

- started_at: 2026-06-03T13:27:17.677458Z
- finished_at: 2026-06-03T13:27:54.771982Z
- duration_ms: 37094
- completed_stages: import_chats, import_handles, import_contacts, import_messages, enrich_missing_text, import_attachments, import_chat_message_joins, import_chat_handle_joins, import_message_attachment_joins, project_handles, project_contacts, project_chat_handle_edges, project_chats, project_messages, project_attachments, project_chat_message_edges, project_message_attachment_edges

## Build stage timings

- import_chats: 54 ms
- import_handles: 2 ms
- import_contacts: 20 ms
- import_messages: 1 ms
- enrich_missing_text: 26 ms
- import_attachments: 1 ms
- import_chat_message_joins: 3412 ms
- import_chat_handle_joins: 142 ms
- import_message_attachment_joins: 1030 ms
- project_handles: 102 ms
- project_contacts: 25 ms
- project_chat_handle_edges: 51 ms
- project_chats: 52 ms
- project_messages: 17778 ms
- project_attachments: 4156 ms
- project_chat_message_edges: 7624 ms
- project_message_attachment_edges: 2609 ms

## Import result

- started_after_source_rowid: 149363
- inserted_messages: 0
- last_imported_source_rowid: not captured

## Rich-text enrichment result

- candidates: 35
- enriched_messages: 0
- missing_extractions: 35
- extractor_available: false

## Projection result

- examined_messages: 133218
- inserted_messages: 0

## Before

- source_messages: 133212
- import_ss_messages: 133218
- working_ss_messages: 133218
- associated_message_edges: 9
- source_chats: 239
- import_ss_chats: 242
- working_ss_chats: 242
- source_handles: 252
- import_ss_handles: 255
- working_ss_handles: 255
- import_ss_chat_to_message_edges: 112520
- working_ss_chat_to_message_edges: 112520
- duplicate_working_chat_to_message_edges: 0
- import_ss_chat_to_handle_edges: 327
- working_ss_chat_to_handle_edges: 327
- duplicate_working_chat_to_handle_edges: 0
- source_attachments: 38339
- import_ss_attachments: 38339
- working_ss_attachments: 38339
- import_ss_message_to_attachment_edges: 37744
- working_ss_message_to_attachment_edges: 37744
- duplicate_working_message_to_attachment_edges: 0
- source_max_rowid: 149363
- last_imported_source_rowid: 149363
- rowIdDelta: 0
- messageCountDelta: -6

## After

- source_messages: 133212
- import_ss_messages: 133218
- working_ss_messages: 133218
- associated_message_edges: 9
- source_chats: 239
- import_ss_chats: 242
- working_ss_chats: 242
- source_handles: 252
- import_ss_handles: 255
- working_ss_handles: 255
- import_ss_chat_to_message_edges: 112520
- working_ss_chat_to_message_edges: 112520
- duplicate_working_chat_to_message_edges: 0
- import_ss_chat_to_handle_edges: 327
- working_ss_chat_to_handle_edges: 327
- duplicate_working_chat_to_handle_edges: 0
- source_attachments: 38339
- import_ss_attachments: 38339
- working_ss_attachments: 38339
- import_ss_message_to_attachment_edges: 37744
- working_ss_message_to_attachment_edges: 37744
- duplicate_working_message_to_attachment_edges: 0
- source_max_rowid: 149363
- last_imported_source_rowid: 149363
- rowIdDelta: 0
- messageCountDelta: -6
