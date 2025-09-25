# Architecture Rules (Authoritative)

## Aggregates

- There are exactly two aggregates in the Messaging bounded context:
  - Chat (aggregate root)
  - Message (aggregate root)
- Do NOT create a Contact aggregate. Contacts are external reference data / projections only.
- A Message belongs to exactly one Chat.

## Layering (DDD)

- Domain layer MUST NOT import from infrastructure or presentation.
- Application layer (use-cases) depends on domain only; it may depend on repositories as interfaces.
- Infrastructure provides implementations (Drift/sqflite, Rust FFI, etc.)
- Repositories expose domain models only (no Drift row classes crossing the boundary).

## IDs & Invariants (essentials)

- ChatId is stable; participant set contains unique handles.
- Message content is immutable post-ingest; edits are revisions/events.
- Reactions/attachments are subordinate to Message (not aggregates).

## Data Flow

- Source (macOS chat.db/AddressBook) → import.db (sqflite) → ETL → working.db (Drift) → repositories → application → UI.
- ETL is deterministic and idempotent; re-running yields the same working state (modulo source changes).

## ADRs

- Any new aggregate, cross-boundary dependency, or schema-breaking change requires an ADR in `docs/adr/`.
