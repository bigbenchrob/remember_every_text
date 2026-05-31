# Contact Name Data Storage Analysis

> Current conformance note (2026-05-29): this document reflects the current overlay/working split for participant naming. `participant_overrides.display_name_override` is the only user-authored contact name override. Short-name and nickname concepts are deprecated as app-facing identity fields.

## 1. Primary Storage: `working.db` (Projection)
This database stores the "source of truth" data projected from macOS AddressBook and Messages. It is generally treated as **read-only** by the UI, as it is overwritten during imports.

### Table: `participants` (`WorkingParticipants`)
*   **Purpose:** Stores contact details imported from the system AddressBook.
*   **Key Columns:**
    *   `id` (PK): Matches the AddressBook `Z_PK`.
    *   `originalName`: The raw name from the source.
    *   `displayName`: The calculated display name (e.g., combined First + Last).
    *   `shortName`: Legacy/schema-compatible derived field. It must not participate in current app-facing identity resolution.
    *   `givenName`, `familyName`: Structured name components.
    *   `organization`: Company name.

### Table: `handles_canonical` (`HandlesCanonical`)
*   **Purpose:** Stores raw handles (phone numbers/emails) and their fallback display names when no contact exists.
*   **Key Columns:**
    *   `displayName`: Formatted phone number or email (e.g., "+1 (555) 000-0000").

## 2. User Overrides: `user_overlays.db` (Mutable)
This database stores user-specific customizations that persist across imports. This is where user-modifiable names should live.

### Table: `participant_overrides` (`ParticipantOverrides`)
*   **Purpose:** Stores user edits that override the system data (naming preferences, custom labels).
*   **Key Columns:**
    *   `participantId` (PK): Foreign key to `working.participants.id`.
    *   `displayNameOverride`: Optional full display name override (e.g. “Dad (Mobile)”).
    *   `createdAtUtc` / `updatedAtUtc`: ISO8601 audit fields maintained by `insertOnConflictUpdate` helpers.

`nameMode` and `nickname` are not active identity controls. Do not reintroduce them as display-name precedence inputs.

### Table: `virtual_participants` (`VirtualParticipants`)
*   **Purpose:** Contacts created manually by the user (not in AddressBook).
*   **Key Columns:**
    *   `displayName`: Full name set by the user.
    *   `shortName`: Legacy/schema-compatible field only. The app-facing virtual contact name is `displayName`.

## 3. Drift Functions for Editing & Persisting

These functions are located in `OverlayDatabase` (`lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`).

### Existing Functions (for naming overrides)

*   **`setParticipantDisplayNameOverride(int participantId, String? displayName)`**
    *   **Action:** Persists a full-name override while keeping the row sparse when cleared.

### For Virtual Participants

*   **`createVirtualParticipant({required String displayName, ...})`**
    *   **Action:** Creates a new purely local contact.

## 4. Current Pattern for User-Modifiable Display Names

User-modifiable display names for existing contacts are already implemented through `participant_overrides.display_name_override`.

Current implementation:

1.  **Schema:** `ParticipantOverrides.displayNameOverride` stores the sparse user override.
2.  **Accessor:** `OverlayDatabase.setParticipantDisplayNameOverride(int participantId, String? displayName)` persists or clears the override.
3.  **UI:** contact name editing writes to the overlay DB only.
4.  **Read model:** contacts repositories merge working participants with overlay overrides at read time; overlay values win.

Do not add a second display-name override column or write name overrides into `working.db`.

Do not add or restore a second app-facing short-name/nickname override path. If a physical `short_name` column remains in a legacy table, treat it as compatibility storage only.
