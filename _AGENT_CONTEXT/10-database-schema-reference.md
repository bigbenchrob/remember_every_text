# Database Schema Reference

## 🚨 CRITICAL: Read This Before Making Database Queries

This document contains the **authoritative schema** for the working database used by this application. **ALWAYS** reference this before writing SQL queries or Drift operations.

## Database Locations

```bash
# Working Database (current application data)
/Users/rob/sqlite_rmc/remember_every_text/working.db

# Import Database (staging area for imports)
/Users/rob/sqlite_rmc/remember_every_text/macos_import.db
```

## Schema Source of Truth

The Drift schema is defined in:

```
lib/essentials/databases/infrastructure/data_sources/working/drift_db.dart
```

## Table Schemas

### 📋 `messages` Table

| Column                  | Type    | Constraints                       | Description                     |
| ----------------------- | ------- | --------------------------------- | ------------------------------- |
| `id`                    | INTEGER | PRIMARY KEY AUTOINCREMENT         | Unique message identifier       |
| `chat_id`               | INTEGER | NOT NULL, REFERENCES chats(id)    | Parent chat                     |
| `sender_handle_id`      | INTEGER | NULLABLE, REFERENCES handles(id)  | Sender's handle                 |
| `timestamp`             | INTEGER | NOT NULL                          | Unix timestamp                  |
| `content`               | TEXT    | NULLABLE                          | Message text content            |
| `is_from_me`            | BOOLEAN | DEFAULT FALSE                     | True if sent by user            |
| `has_attachments`       | BOOLEAN | DEFAULT FALSE                     | True if message has attachments |
| `quoted_message_id`     | INTEGER | NULLABLE, REFERENCES messages(id) | Reply-to message                |
| `import_source_id`      | INTEGER | NULLABLE                          | Import tracking                 |
| `import_last_synced_at` | INTEGER | NULLABLE                          | Last sync timestamp             |

**❌ COMMON MISTAKES:**

- ❌ Using table name `message` (singular) - it's `messages` (plural)
- ❌ Using field `text` - it's `content`
- ❌ Using field `message_id` - it's just `id`

### 📎 `attachments` Table

| Column                  | Type    | Constraints                       | Description                    |
| ----------------------- | ------- | --------------------------------- | ------------------------------ |
| `id`                    | INTEGER | PRIMARY KEY AUTOINCREMENT         | Unique attachment identifier   |
| `message_id`            | INTEGER | NOT NULL, REFERENCES messages(id) | Parent message                 |
| `file_path`             | TEXT    | NOT NULL                          | Path to attachment file        |
| `mime_type`             | TEXT    | NULLABLE                          | MIME type (e.g., "image/jpeg") |
| `file_size`             | INTEGER | NULLABLE                          | Size in bytes                  |
| `thumbnail_path`        | TEXT    | NULLABLE                          | Path to thumbnail              |
| `import_source_id`      | INTEGER | NULLABLE                          | Import tracking                |
| `import_last_synced_at` | INTEGER | NULLABLE                          | Last sync timestamp            |

**✅ JOIN PATTERN:**

```sql
SELECT m.*, a.*
FROM messages m
JOIN attachments a ON a.message_id = m.id
WHERE m.id = ?;
```

**❌ WRONG JOIN:**

```sql
-- ❌ This is WRONG - there's no message_guid field!
JOIN attachments a ON a.message_guid = m.guid
```

### 💬 `chats` Table

| Column                  | Type    | Constraints                       | Description                     |
| ----------------------- | ------- | --------------------------------- | ------------------------------- |
| `id`                    | INTEGER | PRIMARY KEY AUTOINCREMENT         | Unique chat identifier          |
| `contact_id`            | INTEGER | NULLABLE, REFERENCES contacts(id) | Related contact                 |
| `guid`                  | TEXT    | UNIQUE NOT NULL                   | Global unique identifier        |
| `display_name`          | TEXT    | NULLABLE                          | Chat display name               |
| `start_date`            | INTEGER | NULLABLE                          | Unix timestamp of first message |
| `end_date`              | INTEGER | NULLABLE                          | Unix timestamp of last message  |
| `message_count`         | INTEGER | DEFAULT 0                         | Total messages in chat          |
| `import_source_id`      | INTEGER | NULLABLE                          | Import tracking                 |
| `import_last_synced_at` | INTEGER | NULLABLE                          | Last sync timestamp             |

### 👤 `contacts` Table

| Column                  | Type    | Constraints               | Description               |
| ----------------------- | ------- | ------------------------- | ------------------------- |
| `id`                    | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique contact identifier |
| `display_name`          | TEXT    | NOT NULL                  | Contact's display name    |
| `avatar_path`           | TEXT    | NULLABLE                  | Path to avatar image      |
| `first_seen`            | INTEGER | NULLABLE                  | First message timestamp   |
| `last_seen`             | INTEGER | NULLABLE                  | Last message timestamp    |
| `total_messages`        | INTEGER | DEFAULT 0                 | Total messages            |
| `is_group`              | BOOLEAN | DEFAULT FALSE             | Is this a group chat      |
| `import_source_id`      | INTEGER | NULLABLE                  | Import tracking           |
| `import_last_synced_at` | INTEGER | NULLABLE                  | Last sync timestamp       |

### 📱 `handles` Table

| Column             | Type    | Constraints                       | Description              |
| ------------------ | ------- | --------------------------------- | ------------------------ |
| `id`               | INTEGER | PRIMARY KEY AUTOINCREMENT         | Unique handle identifier |
| `contact_id`       | INTEGER | NULLABLE, REFERENCES contacts(id) | Related contact          |
| `address`          | TEXT    | NOT NULL                          | Phone number or email    |
| `service`          | TEXT    | NOT NULL                          | "iMessage" or "SMS"      |
| `import_source_id` | INTEGER | NULLABLE                          | Import tracking          |

**UNIQUE KEY:** `(address, service)` - same address can exist for both iMessage and SMS

### 👥 `chat_participants` Table

| Column      | Type    | Constraints            | Description        |
| ----------- | ------- | ---------------------- | ------------------ |
| `chat_id`   | INTEGER | REFERENCES chats(id)   | Chat               |
| `handle_id` | INTEGER | REFERENCES handles(id) | Participant handle |

**PRIMARY KEY:** `(chat_id, handle_id)` - composite key

## Common Query Patterns

### ✅ Get Messages with Attachments

```sql
SELECT
  m.id,
  m.content,
  m.timestamp,
  m.is_from_me,
  a.file_path,
  a.mime_type
FROM messages m
LEFT JOIN attachments a ON a.message_id = m.id
WHERE m.chat_id = ?
ORDER BY m.timestamp DESC;
```

### ✅ Get Chat with Participants

```sql
SELECT
  c.*,
  h.address,
  h.service
FROM chats c
LEFT JOIN chat_participants cp ON cp.chat_id = c.id
LEFT JOIN handles h ON h.id = cp.handle_id
WHERE c.id = ?;
```

### ✅ Get Messages for Chat

```sql
SELECT
  m.*,
  h.address as sender_address,
  COUNT(a.id) as attachment_count
FROM messages m
LEFT JOIN handles h ON h.id = m.sender_handle_id
LEFT JOIN attachments a ON a.message_id = m.id
WHERE m.chat_id = ?
GROUP BY m.id
ORDER BY m.timestamp DESC;
```

## Drift Access Patterns

### Using Drift DAOs

```dart
// ✅ CORRECT: Use Drift's generated query builders
final messages = await db.select(db.messages)
  .join([
    leftOuterJoin(
      db.attachments,
      db.attachments.messageId.equalsExp(db.messages.id),
    ),
  ])
  .where(db.messages.chatId.equals(chatId))
  .get();
```

### Using Custom Queries

```dart
// ✅ CORRECT: Use Drift's custom queries with correct field names
final result = await db.customSelect(
  'SELECT m.*, a.file_path FROM messages m '
  'LEFT JOIN attachments a ON a.message_id = m.id '
  'WHERE m.chat_id = ?',
  variables: [Variable.withInt(chatId)],
  readsFrom: {db.messages, db.attachments},
).get();
```

## 🔥 CRITICAL Anti-Patterns

### ❌ NEVER Do These:

```sql
-- ❌ WRONG: Singular table name
SELECT * FROM message WHERE id = 1;

-- ✅ CORRECT: Plural table name
SELECT * FROM messages WHERE id = 1;

-- ❌ WRONG: Non-existent guid join
JOIN attachments a ON a.message_guid = m.guid

-- ✅ CORRECT: Use message_id
JOIN attachments a ON a.message_id = m.id

-- ❌ WRONG: Using 'text' field
SELECT m.text FROM messages m;

-- ✅ CORRECT: It's 'content'
SELECT m.content FROM messages m;

-- ❌ WRONG: Hardcoded path
/Users/rob/Library/Application Support/remember_every_text/working.db

-- ✅ CORRECT: Use documented path
/Users/rob/sqlite_rmc/remember_every_text/working.db
```

## Field Name Mapping (Common Mistakes)

| ❌ WRONG                   | ✅ CORRECT          | Table             |
| -------------------------- | ------------------- | ----------------- |
| `message`                  | `messages`          | Table name        |
| `text`                     | `content`           | messages field    |
| `message_guid`             | N/A (doesn't exist) | -                 |
| `guid`                     | `guid`              | chats field only  |
| `message_id` (in messages) | `id`                | messages.id       |
| `file_name`                | `file_path`         | attachments field |

## Quick Reference Card

```
TABLE: messages
- JOIN TO: attachments ON attachments.message_id = messages.id
- JOIN TO: chats ON messages.chat_id = chats.id
- JOIN TO: handles ON messages.sender_handle_id = handles.id

TABLE: attachments
- JOIN TO: messages ON attachments.message_id = messages.id

TABLE: chats
- JOIN TO: messages ON messages.chat_id = chats.id
- JOIN TO: chat_participants ON chat_participants.chat_id = chats.id

DATABASE PATH: /Users/rob/sqlite_rmc/remember_every_text/working.db
```

## When in Doubt

1. **Check the Drift schema file first**: `lib/essentials/databases/infrastructure/data_sources/working/drift_db.dart`
2. **Use sqlite3 to inspect**: `sqlite3 /Users/rob/sqlite_rmc/remember_every_text/working.db ".schema messages"`
3. **Reference this document** before writing any SQL

---

**Last Updated:** October 2, 2025  
**Schema Version:** 1  
**Source:** `remember_this_text/lib/essentials/databases/infrastructure/data_sources/working/drift_db.dart`
