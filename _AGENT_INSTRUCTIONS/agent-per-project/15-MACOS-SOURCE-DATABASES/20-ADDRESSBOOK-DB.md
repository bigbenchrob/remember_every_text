---
tier: project
scope: macos-source-databases
owner: agent-per-project
last_reviewed: 2026-05-15
source_of_truth: source-code-usage
links:
  - ./00-overview.md
  - ../10-DATABASES/03-db-address-book.md
  - ../10-DATABASES/06-addressbook-path-resolution.md
  - ../10-DATABASES/11-contact-to-chat-linking.md
tests: []
---

# AddressBook Source Contract

`AddressBook-v22.abcddb` is an Apple-owned SQLite source database. MessageLens reads it to import contact metadata and contact-channel identifiers used for handle/contact matching.

This document is intentionally not an exhaustive AddressBook schema catalog. It records the app-relevant semantic access surface for readers/importers.

## Location Contract

The active database is inside:

`~/Library/Application Support/AddressBook/Sources/<UUID>/AddressBook-v22.abcddb`

Never hardcode the top-level AddressBook path. Use the documented folder-resolution provider chain so importers target the active `Sources/<UUID>` bundle rather than stale historical bundles. See `../10-DATABASES/06-addressbook-path-resolution.md`.

## Contract Rules

- Treat AddressBook as read-only external source data.
- Do not infer columns from MessageLens import/working tables.
- Preserve AddressBook `Z_PK` as source-local contact provenance.
- Contact/channel matching is source metadata, not final app identity by itself.
- Multi-source/archive work must keep AddressBook source identity separate from chat.db source identity.

## App-Relevant Tables

| Source table | App relevance |
| --- | --- |
| `ZABCDRECORD` | Primary contact/person/organization records. |
| `ZABCDPHONENUMBER` | Phone identifiers associated with contacts. |
| `ZABCDEMAILADDRESS` | Email identifiers associated with contacts. |
| `ZABCDEINTERNALMETADATA` | Provider/internal metadata used for diagnostics and dedupe reasoning when needed. |
| `ZABCDCONTACTINDEX` | Search/index metadata used by health checks when needed. |

## `ZABCDRECORD`

App-relevant fields already used or likely to be used include:

| Field | Meaning for MessageLens |
| --- | --- |
| `Z_PK` | Source-local AddressBook contact id. Preserved into import/working projection for traceability. |
| `ZFIRSTNAME` | Contact first name. |
| `ZLASTNAME` | Contact last name. |
| `ZORGANIZATION` | Organization name / organization contact signal. |
| organization/person flags when present | Used to distinguish people from organizations when source data provides it. |
| image/photo metadata when present | Candidate source for contact image behavior, but must be verified before importer use. |

Do not assume AddressBook contacts are complete, current, deduplicated, or user-approved display identity. Overlay/user intent can override presentation later.

## `ZABCDPHONENUMBER`

App-relevant fields include:

| Field | Meaning for MessageLens |
| --- | --- |
| `ZOWNER` | Source-local owner contact id, expected to reference `ZABCDRECORD.Z_PK`. |
| `ZFULLNUMBER` | Phone identifier when present. |
| `ZVALUE` | Fallback phone value when `ZFULLNUMBER` is absent. |
| label/type fields when present | Source label hints such as mobile/home/work when verified. |

Phone values must be normalized by importer/matching logic. Do not treat raw phone strings as canonical app identity.

## `ZABCDEMAILADDRESS`

App-relevant fields include:

| Field | Meaning for MessageLens |
| --- | --- |
| `ZOWNER` | Source-local owner contact id, expected to reference `ZABCDRECORD.Z_PK`. |
| email value fields | Raw email identifier; verify exact source field before use. |
| label/type fields when present | Source label hints such as home/work when verified. |

Email values must be normalized by importer/matching logic. Do not treat raw email strings as canonical app identity.

## Metadata / Index Tables

`ZABCDEINTERNALMETADATA` and `ZABCDCONTACTINDEX` are not general-purpose app data sources. Use them only when a specific importer, health check, or diagnostic requires observed fields from those tables.

## Importer Guidance

Before adding or changing an AddressBook reader/importer:

1. Resolve the active AddressBook database through the documented provider chain.
2. Verify the source table and field name in the active source database.
3. Preserve `Z_PK` / source owner ids as provenance.
4. Keep raw contact/channel values separate from canonical app identity.
5. Add focused tests or fixtures for any newly consumed source fields.

AddressBook import should provide contact metadata and handle-matching evidence. It should not directly decide final participant identity, chat membership, or user-facing display overrides.
