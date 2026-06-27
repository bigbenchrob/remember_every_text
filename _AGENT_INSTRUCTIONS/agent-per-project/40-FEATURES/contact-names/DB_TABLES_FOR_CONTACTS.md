# Contact Display Identity Storage

> Current conformance note (2026-06-05): display identity is semantic, not relational. The resolver answers "what should the user see?", not "which database row owns this label?" User-authored names live only in overlay storage and win everywhere.

## 1. Canonical Display Precedence

Every contact, participant, conversation title, sender label, and handle fallback should use the same precedence:

1. User-edited display name from the app's single name-override path.
2. App-known contact identity from graph/contact read models.
3. Imported AddressBook display name.
4. Stable participant/conversation label derived from known participants.
5. Raw phone/email/handle only when no known identity exists, or when the UI is explicitly showing a handle scope.

Handles remain useful metadata. They must not become the primary label for a known person outside explicit handle-scoped controls.

## 2. Graph Projection: `working_ss.db`

The source-scoped graph is the current app-facing read spine for ordinary contacts, conversations, handles, and message evidence.

Relevant graph data:

- `working_ss.contacts`: imported contact identity projected from AddressBook.
- `working_ss.handles`: source-scoped handle identities.
- canonical handle alias tables: normalized traversal endpoints for equivalent handle variants.
- `working_ss.contact_to_handle`: contact/handle graph linkage.
- `working_ss.chat_to_handle`: conversation participant topology.

Graph projection is rebuilt from source facts. It is not the home of user-authored names.

## 3. User Overrides: `user_overlays.db`

Overlay storage owns user intent and must survive graph rebuilds.

The contact hero-card pencil is the only app-facing entry point for an existing contact's user-edited display name. That override is sparse: clearing it returns the contact to the graph/imported fallback name.

Do not add a second display-name override column. Do not write user-authored names into `working_ss.db` or retired `working.db`.

## 4. Virtual Contacts

Virtual contacts are user-created identities stored in overlay storage. Their app-facing name is their display name.

If legacy compatibility columns such as `short_name`, `name_mode`, or `nickname` remain in old tables, they are not display precedence inputs. Do not restore short-name or nickname as app-facing identity concepts.

## 5. Legacy Compatibility

Retired `working.db.participants` and `working.db.handles_canonical` may remain useful historical cleanup inputs while recovery/archive paths still need old-file interpretation, but they are not the production naming authority for ordinary graph-backed surfaces.

If a retired cleanup path must bridge into the graph era, it should resolve display names through the shared display identity resolver rather than reading retired participant columns directly.
