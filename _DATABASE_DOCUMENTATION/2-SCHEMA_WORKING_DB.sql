/* =========================
   0) PRAGMAS & META
   ========================= */
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS schema_migrations (
  version            INTEGER PRIMARY KEY,          -- monotonically increasing
  applied_at_utc     TEXT NOT NULL                 -- ISO8601
);

/* Tracks last fully-applied import batch (from import.db) so we can resume. */
CREATE TABLE IF NOT EXISTS projection_state (
  id                 INTEGER PRIMARY KEY CHECK(id=1),
  last_import_batch_id INTEGER,                    -- import.import_batches.id
  last_projected_at_utc TEXT
);

INSERT OR IGNORE INTO projection_state (id, last_import_batch_id, last_projected_at_utc)
VALUES (1, NULL, NULL);

/* App-level preferences / flags (pinned chats, sort mode, etc.). */
CREATE TABLE IF NOT EXISTS app_settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

/* =========================
   1) IDENTITIES (lightweight, UI-facing)
   ========================= */
/*
  Identity is the displayable sender/participant “face” in the UI.
  It can link to a normalized address (phone/email), and optionally to a contacts snapshot guid/id you maintain elsewhere.
  Repositories read/write these; they are NOT the import "handles" directly, but derived from them.
*/

CREATE TABLE IF NOT EXISTS identities (
  id                  INTEGER PRIMARY KEY,
  normalized_address  TEXT,                        -- e164/email (nullable for “system”)
  service             TEXT CHECK(service IN ('iMessage','SMS','Unknown')) DEFAULT 'Unknown',
  display_name        TEXT,                        -- user-overridable pretty name
  contact_ref         TEXT,                        -- optional pointer (e.g., contacts table in working or external)
  avatar_ref          TEXT,                        -- path/URL to avatar if you cache
  is_system           INTEGER NOT NULL DEFAULT 0 CHECK(is_system IN (0,1)),
  UNIQUE(service, normalized_address)
);

CREATE INDEX IF NOT EXISTS idx_identities_name ON identities(display_name);

/* Optional mapping back to import handles (many import handles can fold into one identity). */
CREATE TABLE IF NOT EXISTS identity_handle_links (
  identity_id         INTEGER NOT NULL REFERENCES identities(id) ON DELETE CASCADE,
  import_handle_id    INTEGER NOT NULL,            -- import.handles.id
  PRIMARY KEY (identity_id, import_handle_id)
);

/* =========================
   2) CHATS (Aggregate Root)
   ========================= */
/*
  Chat PK is the Apple/Message GUID (stable, string). We keep a surrogate integer too for local joins.
  Chat rows are heavily denormalized for fast list rendering.
*/

CREATE TABLE IF NOT EXISTS chats (
  id                  INTEGER PRIMARY KEY,
  guid                TEXT NOT NULL UNIQUE,        -- from import.chats.guid
  service             TEXT CHECK(service IN ('iMessage','SMS','Unknown')) DEFAULT 'Unknown',
  is_group            INTEGER NOT NULL CHECK(is_group IN (0,1)),
  /* Display name precedence: user_custom_name > computed_name. */
  user_custom_name    TEXT,                        -- user override
  computed_name       TEXT,                        -- derived from participants (kept up-to-date by projector)
  display_name        TEXT GENERATED ALWAYS AS (COALESCE(user_custom_name, computed_name)) VIRTUAL,
  last_message_at_utc TEXT,
  last_sender_identity_id INTEGER REFERENCES identities(id) ON DELETE SET NULL,
  last_message_preview TEXT,                       -- short snippet for list
  unread_count        INTEGER NOT NULL DEFAULT 0 CHECK(unread_count >= 0),
  pinned              INTEGER NOT NULL DEFAULT 0 CHECK(pinned IN (0,1)),
  archived            INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)),
  muted_until_utc     TEXT,                        -- if snoozed/muted
  favourite           INTEGER NOT NULL DEFAULT 0 CHECK(favourite IN (0,1)),
  created_at_utc      TEXT,                        -- earliest message time in this chat (projected)
  updated_at_utc      TEXT                         -- last projection timestamp for this row
);

CREATE INDEX IF NOT EXISTS idx_chats_sort ON chats(pinned DESC, last_message_at_utc DESC);
CREATE INDEX IF NOT EXISTS idx_chats_display ON chats(display_name);

/* Participants projection (ordered for title construction). */
CREATE TABLE IF NOT EXISTS chat_participants_proj (
  chat_id             INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  identity_id         INTEGER NOT NULL REFERENCES identities(id) ON DELETE CASCADE,
  role                TEXT CHECK(role IN ('member','owner','unknown')) DEFAULT 'member',
  sort_key            INTEGER NOT NULL DEFAULT 0,  -- 0..N stable ordering
  PRIMARY KEY (chat_id, identity_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_participants_proj_order ON chat_participants_proj(chat_id, sort_key);

/* =========================
   3) MESSAGES (Aggregate Root)
   ========================= */
/*
  Message PK is the Apple message GUID (string). We also keep an integer surrogate.
  We keep denormalized columns for UI + state (read flags, delivery).
*/

CREATE TABLE IF NOT EXISTS messages (
  id                      INTEGER PRIMARY KEY,
  guid                    TEXT NOT NULL UNIQUE,    -- import.messages.guid
  chat_id                 INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_identity_id      INTEGER REFERENCES identities(id) ON DELETE SET NULL,
  is_from_me              INTEGER NOT NULL CHECK(is_from_me IN (0,1)),
  sent_at_utc             TEXT,                    -- from import.messages.date_utc
  delivered_at_utc        TEXT,
  read_at_utc             TEXT,
  status                  TEXT CHECK(status IN ('unknown','sent','delivered','read','failed')) DEFAULT 'unknown',
  text                    TEXT,                    -- plain text (decoded where possible)
  has_attachments         INTEGER NOT NULL DEFAULT 0 CHECK(has_attachments IN (0,1)),
  reply_to_guid           TEXT,                    -- target message guid for replies
  system_type             TEXT,                    -- non-null iff system (e.g., 'join','leave','name-change')
  reaction_carrier        INTEGER NOT NULL DEFAULT 0 CHECK(reaction_carrier IN (0,1)),
  balloon_bundle_id       TEXT,                    -- effects
  /* Aggregated reaction summary for quick rendering (counts by kind). */
  reaction_summary_json   TEXT,                    -- e.g., {"love":2,"like":1}
  /* App-local flags */
  is_starred              INTEGER NOT NULL DEFAULT 0 CHECK(is_starred IN (0,1)),
  is_deleted_local        INTEGER NOT NULL DEFAULT 0 CHECK(is_deleted_local IN (0,1)),
  updated_at_utc          TEXT
);

CREATE INDEX IF NOT EXISTS idx_messages_chat_time ON messages(chat_id, sent_at_utc);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_identity_id);
CREATE INDEX IF NOT EXISTS idx_messages_reply ON messages(reply_to_guid);

/* =========================
   4) ATTACHMENTS (projection & cache)
   ========================= */

CREATE TABLE IF NOT EXISTS attachments (
  id                  INTEGER PRIMARY KEY,
  message_guid        TEXT NOT NULL,               -- FK by guid for resilience
  import_attachment_id INTEGER,                    -- import.attachments.id (for provenance)
  local_path          TEXT,                        -- path in app cache if copied
  mime_type           TEXT,
  uti                 TEXT,
  transfer_name       TEXT,
  size_bytes          INTEGER,
  is_sticker          INTEGER NOT NULL DEFAULT 0 CHECK(is_sticker IN (0,1)),
  thumb_path          TEXT,                        -- generated thumbnail path (optional)
  created_at_utc      TEXT
);

CREATE INDEX IF NOT EXISTS idx_attachments_msg ON attachments(message_guid);

/* =========================
   5) REACTIONS (normalized, UI-ready)
   ========================= */

CREATE TABLE IF NOT EXISTS reactions (
  id                      INTEGER PRIMARY KEY,
  message_guid            TEXT NOT NULL,           -- target
  kind                    TEXT NOT NULL CHECK(kind IN ('love','like','dislike','laugh','emphasize','question','unknown')),
  reactor_identity_id     INTEGER REFERENCES identities(id) ON DELETE SET NULL,
  action                  TEXT NOT NULL CHECK(action IN ('add','remove')),
  reacted_at_utc          TEXT
);

CREATE INDEX IF NOT EXISTS idx_reactions_target ON reactions(message_guid);

/* Helpful per-message counts (maintained by projector; denormalized for speed). */
CREATE TABLE IF NOT EXISTS reaction_counts (
  message_guid            TEXT PRIMARY KEY,
  love                    INTEGER NOT NULL DEFAULT 0,
  like                    INTEGER NOT NULL DEFAULT 0,
  dislike                 INTEGER NOT NULL DEFAULT 0,
  laugh                   INTEGER NOT NULL DEFAULT 0,
  emphasize               INTEGER NOT NULL DEFAULT 0,
  question                INTEGER NOT NULL DEFAULT 0
);

/* =========================
   6) READ STATE / BADGES
   ========================= */

CREATE TABLE IF NOT EXISTS read_state (
  chat_id             INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  last_read_at_utc    TEXT,                        -- max read time by local user
  PRIMARY KEY (chat_id)
);

/*
  Optional per-message explicit read/seen markers (useful if multiple windows/sessions).
*/
CREATE TABLE IF NOT EXISTS message_read_marks (
  message_guid        TEXT PRIMARY KEY,            -- target message
  marked_at_utc       TEXT NOT NULL
);

/* =========================
   7) SEARCH (FTS)
   ========================= */
/* External-content FTS5: content table is messages(text). */
CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts USING fts5(
  guid UNINDEXED,
  chat_id UNINDEXED,
  text,
  tokenize='unicode61 remove_diacritics 2'
);

/* Triggers to keep FTS in sync (agents should preserve on schema refactor). */
CREATE TRIGGER IF NOT EXISTS trg_messages_fts_insert
AFTER INSERT ON messages BEGIN
  INSERT INTO messages_fts (rowid, guid, chat_id, text)
  VALUES (new.id, new.guid, new.chat_id, COALESCE(new.text,''));
END;

CREATE TRIGGER IF NOT EXISTS trg_messages_fts_update
AFTER UPDATE OF text ON messages BEGIN
  UPDATE messages_fts SET text = COALESCE(new.text,'') WHERE rowid = new.id;
END;

CREATE TRIGGER IF NOT EXISTS trg_messages_fts_delete
AFTER DELETE ON messages BEGIN
  DELETE FROM messages_fts WHERE rowid = old.id;
END;

/* =========================
   8) DERIVED VIEWS
   ========================= */

CREATE VIEW IF NOT EXISTS v_chat_latest AS
SELECT
  c.id           AS chat_id,
  c.guid         AS chat_guid,
  c.display_name,
  c.last_message_at_utc,
  c.unread_count,
  m.guid         AS last_message_guid,
  m.text         AS last_message_text,
  m.sender_identity_id
FROM chats c
LEFT JOIN messages m
  ON m.chat_id = c.id
 AND m.sent_at_utc = c.last_message_at_utc;

CREATE VIEW IF NOT EXISTS v_message_expanded AS
SELECT
  m.guid,
  m.chat_id,
  m.sent_at_utc,
  m.text,
  m.is_from_me,
  i.display_name AS sender_name,
  rc.love, rc.like, rc.dislike, rc.laugh, rc.emphasize, rc.question
FROM messages m
LEFT JOIN identities i ON i.id = m.sender_identity_id
LEFT JOIN reaction_counts rc ON rc.message_guid = m.guid;

/* =========================
   9) HOUSEKEEPING TRIGGERS
   ========================= */

/* Maintain chat.last_message_* and unread_count when a message is inserted. */
CREATE TRIGGER IF NOT EXISTS trg_messages_after_insert
AFTER INSERT ON messages
BEGIN
  /* last message timestamp + preview */
  UPDATE chats
     SET last_message_at_utc = CASE
           WHEN last_message_at_utc IS NULL OR new.sent_at_utc > last_message_at_utc
           THEN new.sent_at_utc ELSE last_message_at_utc END,
         last_sender_identity_id = CASE
           WHEN last_message_at_utc IS NULL OR new.sent_at_utc >= last_message_at_utc
           THEN new.sender_identity_id ELSE last_sender_identity_id END,
         last_message_preview = CASE
           WHEN last_message_at_utc IS NULL OR new.sent_at_utc >= last_message_at_utc
           THEN substr(COALESCE(new.text,''), 1, 120) ELSE last_message_preview END
   WHERE id = new.chat_id;

  /* unread increment: only if not from me and not already read */
  UPDATE chats
     SET unread_count = unread_count + CASE
         WHEN new.is_from_me = 0 AND (new.read_at_utc IS NULL) THEN 1 ELSE 0 END
   WHERE id = new.chat_id;
END;

/* Decrement unread when a message is marked read. */
CREATE TRIGGER IF NOT EXISTS trg_messages_mark_read
AFTER UPDATE OF read_at_utc ON messages
WHEN new.read_at_utc IS NOT NULL AND old.read_at_utc IS NULL
BEGIN
  UPDATE chats
     SET unread_count = MAX(unread_count - 1, 0)
   WHERE id = new.chat_id;
END;

/* Keep reaction_counts and messages.reaction_summary_json in sync. */
CREATE TRIGGER IF NOT EXISTS trg_reactions_after_change
AFTER INSERT ON reactions
BEGIN
  INSERT INTO reaction_counts(message_guid, love, like, dislike, laugh, emphasize, question)
  VALUES (new.message_guid, 0,0,0,0,0,0)
  ON CONFLICT(message_guid) DO NOTHING;

  UPDATE reaction_counts
     SET
       love      = love      + CASE WHEN new.kind='love'      AND new.action='add' THEN 1 WHEN new.kind='love'      AND new.action='remove' THEN -1 ELSE 0 END,
       like      = like      + CASE WHEN new.kind='like'      AND new.action='add' THEN 1 WHEN new.kind='like'      AND new.action='remove' THEN -1 ELSE 0 END,
       dislike   = dislike   + CASE WHEN new.kind='dislike'   AND new.action='add' THEN 1 WHEN new.kind='dislike'   AND new.action='remove' THEN -1 ELSE 0 END,
       laugh     = laugh     + CASE WHEN new.kind='laugh'     AND new.action='add' THEN 1 WHEN new.kind='laugh'     AND new.action='remove' THEN -1 ELSE 0 END,
       emphasize = emphasize + CASE WHEN new.kind='emphasize' AND new.action='add' THEN 1 WHEN new.kind='emphasize' AND new.action='remove' THEN -1 ELSE 0 END,
       question  = question  + CASE WHEN new.kind='question'  AND new.action='add' THEN 1 WHEN new.kind='question'  AND new.action='remove' THEN -1 ELSE 0 END;

  UPDATE messages
     SET reaction_summary_json = (
       SELECT json_object(
         'love',      love,
         'like',      like,
         'dislike',   dislike,
         'laugh',     laugh,
         'emphasize', emphasize,
         'question',  question
       )
       FROM reaction_counts WHERE message_guid = NEW.message_guid
     ),
         updated_at_utc = strftime('%Y-%m-%dT%H:%M:%fZ','now')
   WHERE guid = NEW.message_guid;
END;