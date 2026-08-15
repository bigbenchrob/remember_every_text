# Onboarding Story

This document records the current first-run user experience only. It begins
with application launch and ends when the first import begins.

## The Story

Application launches.

On a Mac that still requires setup, MessageLens opens its Environment
Readiness panel. The panel explains that MessageLens is checking the local
permissions and data sources needed before import. A list of checks shows the
user where setup currently stands:

- Full Disk Access;
- Messages Database;
- Contacts Database;
- Import Readiness.

If Full Disk Access is unavailable, the panel explains why MessageLens needs
it and offers **Open System Settings**. The user grants access, reopens
MessageLens when macOS requires it, and returns to the readiness checks.

If the local Messages history is missing or appears not to have synchronized,
the panel asks the user to open Messages, confirm the expected Apple Account
and local history, wait for synchronization if necessary, and then choose
**Re-check**.

If Contacts data is unavailable, the panel explains that Contacts provides
names and relationship context, asks the user to confirm that the data is
present locally, and offers **Re-check**.

When the required permissions and local sources are available, the active
check becomes **Import Readiness**. The detail panel says **Ready To Import**,
explains that MessageLens will copy local Messages and Contacts data into its
own app databases, and offers **Import My Messages**.

The user chooses **Import My Messages**.

The first import begins.
