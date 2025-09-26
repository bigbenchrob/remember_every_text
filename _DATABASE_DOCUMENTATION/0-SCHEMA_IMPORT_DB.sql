-- Import DB Schema & Mapping (iMessage Ingest Ledger)
-- Complete SQLite DDL schema for import.db

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS schema_migrations (
  version            INTEGER PRIMARY KEY,
  applied_at_utc     TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS import_batches (
  id                 INTEGER PRIMARY KEY,
  started_at_utc     TEXT    NOT NULL,
  finished_at_utc    TEXT,
  source_chat_db     TEXT,
  source_addressbook TEXT,
  host_info_json     TEXT,
  notes              TEXT
);

CREATE TABLE IF NOT EXISTS source_files (
  id                 INTEGER PRIMARY KEY,
  batch_id           INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE CASCADE,
  path               TEXT    NOT NULL,
  sha256_hex         TEXT,
  size_bytes         INTEGER,
  mtime_utc          TEXT,
  UNIQUE(path, sha256_hex)
);

CREATE TABLE IF NOT EXISTS import_logs (
  id                 INTEGER PRIMARY KEY,
  batch_id           INTEGER REFERENCES import_batches(id) ON DELETE SET NULL,
  at_utc             TEXT    NOT NULL,
  level              TEXT    NOT NULL CHECK(level IN ('debug','info','warn','error')),
  message            TEXT    NOT NULL,
  context_json       TEXT
);

CREATE TABLE IF NOT EXISTS contacts (
  id                  INTEGER PRIMARY KEY,
  source_record_id    INTEGER,
  display_name        TEXT,
  given_name          TEXT,
  family_name         TEXT,
  organization        TEXT,
  is_organization     INTEGER NOT NULL DEFAULT 0 CHECK(is_organization IN (0,1)),
  created_at_utc      TEXT,
  updated_at_utc      TEXT,
  batch_id            INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS contact_channels (
  id                  INTEGER PRIMARY KEY,
  contact_id          INTEGER NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
  kind                TEXT    NOT NULL CHECK(kind IN ('email','phone')),
  value               TEXT    NOT NULL,
  label               TEXT,
  UNIQUE(kind, value)
);

CREATE TABLE IF NOT EXISTS handles (
  id                  INTEGER PRIMARY KEY,
  source_rowid        INTEGER,
  service             TEXT NOT NULL CHECK(service IN ('iMessage','SMS','Unknown')),
  raw_identifier      TEXT NOT NULL,
  normalized_address  TEXT,
  country             TEXT,
  last_seen_utc       TEXT,
  batch_id            INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT,
  UNIQUE(service, raw_identifier)
);
CREATE INDEX IF NOT EXISTS idx_handles_norm ON handles(normalized_address);

CREATE TABLE IF NOT EXISTS chats (
  id                  INTEGER PRIMARY KEY,
  source_rowid        INTEGER,
  guid                TEXT    NOT NULL,
  service             TEXT    CHECK(service IN ('iMessage','SMS','Unknown')),
  display_name        TEXT,
  is_group            INTEGER NOT NULL DEFAULT 0 CHECK(is_group IN (0,1)),
  created_at_utc      TEXT,
  updated_at_utc      TEXT,
  batch_id            INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT,
  UNIQUE(guid)
);

CREATE TABLE IF NOT EXISTS chat_participants (
  chat_id             INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  handle_id           INTEGER NOT NULL REFERENCES handles(id) ON DELETE CASCADE,
  role                TEXT CHECK(role IN ('member','owner','unknown')) DEFAULT 'member',
  added_at_utc        TEXT,
  PRIMARY KEY (chat_id, handle_id)
);
CREATE INDEX IF NOT EXISTS idx_participants_handle ON chat_participants(handle_id);

CREATE TABLE IF NOT EXISTS messages (
  id                      INTEGER PRIMARY KEY,
  source_rowid            INTEGER,
  guid                    TEXT    NOT NULL,
  chat_id                 INTEGER NOT NULL REFERENCES chats(id)    ON DELETE CASCADE,
  sender_handle_id        INTEGER REFERENCES handles(id)           ON DELETE SET NULL,
  service                 TEXT CHECK(service IN ('iMessage','SMS','Unknown')),
  is_from_me              INTEGER NOT NULL CHECK(is_from_me IN (0,1)),
  date_utc                TEXT,
  date_read_utc           TEXT,
  date_delivered_utc      TEXT,
  subject                 TEXT,
  text                    TEXT,
  attributed_body_blob    BLOB,
  item_type               TEXT CHECK(item_type IN ('text','attachment-only','sticker','reaction-carrier','system','unknown')),
  error_code              INTEGER,
  is_system_message       INTEGER NOT NULL DEFAULT 0 CHECK(is_system_message IN (0,1)),
  thread_originator_guid  TEXT,
  associated_message_guid TEXT,
  balloon_bundle_id       TEXT,
  payload_json            TEXT,
  batch_id                INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT,
  UNIQUE(guid)
);
CREATE INDEX IF NOT EXISTS idx_messages_chat_date ON messages(chat_id, date_utc);
CREATE INDEX IF NOT EXISTS idx_messages_assoc ON messages(associated_message_guid);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_handle_id);

CREATE TABLE IF NOT EXISTS chat_message_join_source (
  chat_id   INTEGER NOT NULL REFERENCES chats(id)    ON DELETE CASCADE,
  message_id INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  source_rowid INTEGER,
  PRIMARY KEY (chat_id, message_id)
);

CREATE TABLE IF NOT EXISTS attachments (
  id                  INTEGER PRIMARY KEY,
  source_rowid        INTEGER,
  guid                TEXT,
  transfer_name       TEXT,
  uti                 TEXT,
  mime_type           TEXT,
  total_bytes         INTEGER,
  is_sticker          INTEGER NOT NULL DEFAULT 0 CHECK(is_sticker IN (0,1)),
  is_outgoing         INTEGER CHECK(is_outgoing IN (0,1)),
  created_at_utc      TEXT,
  local_path          TEXT,
  sha256_hex          TEXT,
  batch_id            INTEGER NOT NULL REFERENCES import_batches(id) ON DELETE RESTRICT
);
CREATE TABLE IF NOT EXISTS message_attachments (
  message_id          INTEGER NOT NULL REFERENCES messages(id)     ON DELETE CASCADE,
  attachment_id       INTEGER NOT NULL REFERENCES attachments(id)  ON DELETE CASCADE,
  source_rowid        INTEGER,
  PRIMARY KEY (message_id, attachment_id)
);
CREATE INDEX IF NOT EXISTS idx_attach_created ON attachments(created_at_utc);

CREATE TABLE IF NOT EXISTS reactions (
  id                      INTEGER PRIMARY KEY,
  carrier_message_id      INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  target_message_guid     TEXT    NOT NULL,
  action                  TEXT    NOT NULL CHECK(action IN ('add','remove')),
  kind                    TEXT    NOT NULL CHECK(kind IN ('love','like','dislike','laugh','emphasize','question','unknown')),
  reactor_handle_id       INTEGER REFERENCES handles(id) ON DELETE SET NULL,
  reacted_at_utc          TEXT,
  parse_confidence        REAL CHECK(parse_confidence >= 0.0 AND parse_confidence <= 1.0) DEFAULT 1.0
);
CREATE INDEX IF NOT EXISTS idx_reactions_target ON reactions(target_message_guid);
CREATE INDEX IF NOT EXISTS idx_reactions_reactor ON reactions(reactor_handle_id);

CREATE TABLE IF NOT EXISTS message_links (
  id                  INTEGER PRIMARY KEY,
  message_id          INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  url                 TEXT    NOT NULL,
  start               INTEGER,
  end                 INTEGER
);

CREATE VIEW IF NOT EXISTS v_messages_expanded AS
SELECT
  m.id               AS message_id,
  m.guid             AS message_guid,
  m.chat_id,
  c.guid             AS chat_guid,
  m.date_utc,
  m.is_from_me,
  m.text,
  m.item_type,
  m.associated_message_guid,
  h.id               AS sender_handle_id,
  h.normalized_address AS sender_address
FROM messages m
JOIN chats c           ON c.id = m.chat_id
LEFT JOIN handles h    ON h.id = m.sender_handle_id;