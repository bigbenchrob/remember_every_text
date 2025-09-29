-- Initial schema for Supabase mirror of working.db
-- Generated on 2025-09-27

-- Recommended extensions
create extension if not exists "uuid-ossp";

-- Shared enum types
create type message_status as enum ('unknown', 'sent', 'delivered', 'read', 'failed');
create type reaction_kind as enum ('love', 'like', 'dislike', 'laugh', 'emphasize', 'question', 'unknown');
create type reaction_action as enum ('add', 'remove');
create type chat_service as enum ('iMessage', 'SMS', 'Unknown');
create type participant_role as enum ('member', 'owner', 'unknown');

-- Identities
create table public.identities (
    id bigserial primary key,
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    normalized_address text,
    service chat_service not null default 'Unknown',
    display_name text,
    contact_ref text,
    avatar_ref text,
    is_system boolean not null default false,
    unique (owner_user_id, service, normalized_address)
);

-- Import handle links
create table public.identity_handle_links (
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    identity_id bigint not null references public.identities(id) on delete cascade,
    import_handle_id bigint not null,
    primary key (owner_user_id, identity_id, import_handle_id)
);

-- Chats
create table public.chats (
    id bigserial primary key,
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    guid text not null,
    service chat_service not null default 'Unknown',
    is_group boolean not null default false,
    user_custom_name text,
    computed_name text,
    display_name text,
    last_message_at_utc timestamptz,
    last_sender_identity_id bigint references public.identities(id) on delete set null,
    last_message_preview text,
    unread_count integer not null default 0,
    pinned boolean not null default false,
    archived boolean not null default false,
    muted_until_utc timestamptz,
    favourite boolean not null default false,
    created_at_utc timestamptz,
    updated_at_utc timestamptz,
    unique (owner_user_id, guid)
);

-- Chat participants projection
create table public.chat_participants_proj (
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    chat_id bigint not null references public.chats(id) on delete cascade,
    identity_id bigint not null references public.identities(id) on delete cascade,
    role participant_role not null default 'member',
    sort_key integer not null default 0,
    primary key (owner_user_id, chat_id, identity_id)
);

-- Messages
create table public.messages (
    id bigserial primary key,
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    guid text not null,
    chat_id bigint not null references public.chats(id) on delete cascade,
    sender_identity_id bigint references public.identities(id) on delete set null,
    is_from_me boolean not null default false,
    sent_at_utc timestamptz,
    delivered_at_utc timestamptz,
    read_at_utc timestamptz,
    status message_status not null default 'unknown',
    text text,
    has_attachments boolean not null default false,
    reply_to_guid text,
    system_type text,
    reaction_carrier boolean not null default false,
    balloon_bundle_id text,
    reaction_summary_json jsonb,
    is_starred boolean not null default false,
    is_deleted_local boolean not null default false,
    updated_at_utc timestamptz,
    unique (owner_user_id, guid)
);

-- Attachments
create table public.attachments (
    id bigserial primary key,
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    message_guid text not null,
    import_attachment_id bigint,
    local_path text,
    mime_type text,
    uti text,
    transfer_name text,
    size_bytes bigint,
    is_sticker boolean not null default false,
    thumb_path text,
    created_at_utc timestamptz,
    constraint fk_attachments_message foreign key (owner_user_id, message_guid)
        references public.messages(owner_user_id, guid) on delete cascade
);

-- Reactions
create table public.reactions (
    id bigserial primary key,
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    message_guid text not null,
    kind reaction_kind not null,
    reactor_identity_id bigint references public.identities(id) on delete set null,
    action reaction_action not null,
    reacted_at_utc timestamptz,
    constraint fk_reactions_message foreign key (owner_user_id, message_guid)
        references public.messages(owner_user_id, guid) on delete cascade
);

-- Reaction counts
create table public.reaction_counts (
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    message_guid text not null,
    love integer not null default 0,
    like integer not null default 0,
    dislike integer not null default 0,
    laugh integer not null default 0,
    emphasize integer not null default 0,
    question integer not null default 0,
    primary key (owner_user_id, message_guid),
    constraint fk_reaction_counts_message foreign key (owner_user_id, message_guid)
        references public.messages(owner_user_id, guid) on delete cascade
);

-- Read state per chat
create table public.read_state (
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    chat_id bigint not null references public.chats(id) on delete cascade,
    last_read_at_utc timestamptz,
    primary key (owner_user_id, chat_id)
);

-- Per-message read marks
create table public.message_read_marks (
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    message_guid text not null,
    marked_at_utc timestamptz not null,
    primary key (owner_user_id, message_guid),
    constraint fk_read_marks_message foreign key (owner_user_id, message_guid)
        references public.messages(owner_user_id, guid) on delete cascade
);

-- Sync bookkeeping for migration service (created in Step 2 of plan)
create table public.supabase_sync_state (
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    table_name text not null,
    last_synced_id bigint,
    last_synced_guid text,
    last_synced_at timestamptz,
    primary key (owner_user_id, table_name)
);

-- Indexes mirroring working.db access patterns
create index idx_chats_sort on public.chats(owner_user_id, pinned desc, last_message_at_utc desc);
create index idx_chats_display on public.chats(owner_user_id, display_name);
create index idx_chat_participants_proj_order on public.chat_participants_proj(owner_user_id, chat_id, sort_key);
create index idx_messages_chat_time on public.messages(owner_user_id, chat_id, sent_at_utc);
create index idx_messages_sender on public.messages(owner_user_id, sender_identity_id);
create index idx_messages_reply on public.messages(owner_user_id, reply_to_guid);
create index idx_attachments_message on public.attachments(owner_user_id, message_guid);
create index idx_reactions_target on public.reactions(owner_user_id, message_guid);

-- Projection metadata mirror (optional)
create table public.projection_state (
    owner_user_id uuid not null references auth.users(id) on delete cascade,
    last_import_batch_id bigint,
    last_projected_at_utc timestamptz,
    primary key (owner_user_id)
);
