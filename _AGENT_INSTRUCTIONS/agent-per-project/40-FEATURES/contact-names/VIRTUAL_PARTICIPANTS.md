# Virtual Participants

> Current conformance note (2026-06-05): virtual participants are overlay-owned user intent. They participate in display identity resolution, but graph/import projection must not write, mirror, or derive them into working tables as user-authored facts.

## What are they?
**Virtual Participants** are contacts that exist **only** inside MessageLens. They are not synced to or from your macOS Contacts (Address Book).

## Why do they exist?
They allow you to manually create a "person" and assign them to a phone number or email address (handle) without having to add that person to your system-wide macOS Contacts app.

For example, if you have a chat with a number `+1-555-0123` that isn't in your contacts, you can create a Virtual Participant named "Plumber" inside the app. The app will show "Plumber" for that chat, but your actual Mac Contacts app remains untouched.

## Technical Details
*   **Storage:** They are stored in `user_overlays.db`, not in `working_ss.db` or retired `working.db`. This ensures they persist across graph rebuilds and source imports.
*   **ID Range:** To prevent their IDs from clashing with real contacts imported from macOS, Virtual Participants are assigned IDs starting at **1,000,000,000** (1 billion).
    *   *Real Contacts:* IDs `1` to `999,999,999`
    *   *Virtual Contacts:* IDs `1,000,000,000+`
*   **Data:** Their app-facing identity is `displayName`, plus optional notes and audit timestamps. Do not use short-name or nickname fields as current display precedence inputs.

## Comparison

| Feature | Real Participant | Virtual Participant |
| :--- | :--- | :--- |
| **Source** | macOS Address Book | Created manually in-app |
| **Storage** | `working_ss.db` graph projection | `user_overlays.db` (mutable) |
| **IDs** | Low numbers (e.g., 1, 42, 500) | High numbers (1,000,000,000+) |
| **Persistence** | Overwritten on every import | Persists across imports |

## Display Identity Rule

Virtual participant names feed the same display identity resolver as imported contacts. Widgets should not special-case virtual participant labels, inspect overlay rows directly, or fall back to raw handles when a virtual identity has been assigned.
