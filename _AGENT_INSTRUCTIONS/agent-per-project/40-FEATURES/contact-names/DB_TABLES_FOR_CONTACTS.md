# Contact Name Data Storage Analysis

> Current conformance note (2026-04-21): this document reflects the current overlay/working split for participant naming. The old recommendation to add a generic `displayName` override column is superseded; `participant_overrides.display_name_override` already exists and is the current full-name override field.

## 1. Primary Storage: `working.db` (Projection)
This database stores the "source of truth" data projected from macOS AddressBook and Messages. It is generally treated as **read-only** by the UI, as it is overwritten during imports.

### Table: `participants` (`WorkingParticipants`)
*   **Purpose:** Stores contact details imported from the system AddressBook.
*   **Key Columns:**
    *   `id` (PK): Matches the AddressBook `Z_PK`.
    *   `originalName`: The raw name from the source.
    *   `displayName`: The calculated display name (e.g., combined First + Last).
    *   `shortName`: A derived short version (e.g., "Rob B.").
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
    *   `nameMode`: Nullable; when null the participant inherits global naming defaults, otherwise the stored enum value drives display.
    *   `nickname`: User-provided short form name. If present it is used for every “short name” lookup; otherwise the UI falls back to the working projection’s auto-derived short name so users still get initials without extra setup.
    *   `displayNameOverride`: Optional full display name override (e.g. “Dad (Mobile)”).
    *   `createdAtUtc` / `updatedAtUtc`: ISO8601 audit fields maintained by `insertOnConflictUpdate` helpers.

### Table: `virtual_participants` (`VirtualParticipants`)
*   **Purpose:** Contacts created manually by the user (not in AddressBook).
*   **Key Columns:**
    *   `displayName`: Full name set by the user.
    *   `shortName`: Short name set by the user.

## 3. Drift Functions for Editing & Persisting

These functions are located in `OverlayDatabase` (`lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`).

### Existing Functions (for naming overrides)

*   **`setParticipantNickname(int participantId, String? nickname)`**
    *   **Action:** Inserts or updates `participant_overrides` with the user’s preferred short name.
    *   **Logic:** Uses `insertOnConflictUpdate` so timestamps stay current and null clears the nickname.
*   **`setParticipantDisplayNameOverride(int participantId, String? displayName)`**
    *   **Action:** Persists a full-name override while keeping the row sparse when cleared.
*   **`setParticipantNameMode(int participantId, ParticipantNameMode? mode)`**
    *   **Action:** Controls whether a participant follows global name rules or a custom mode.
*   **`getAllNicknamesByKey()`**
    *   **Action:** Retrieves all stored nicknames for fast overlay/working merge.
    *   **Return:** `Map<String, String>` (Key: `participant:<id>`, Value: `nickname`).

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
