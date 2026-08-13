The real Presence FDA experiment produced an unexpected factual result.

Observed facts:

- macOS System Settings visibly shows MessageLens Development Full Disk Access OFF.
- It was already OFF before the real FDA Presence implementation was added; it was not toggled during the running process.
- The new real FdaTestStep nevertheless returned FDA present and routed directly to confirm_fda_available.

Do not change Presence routing, the Schedule, or FDA behavior yet.

Perform a read-only investigation of the actual FDA-testing path:

FdaTestStep
-> FdaTestingAuthority
-> FullDiskAccessPresenceAdapter
-> FullDiskAccess.canReadMessagesDatabase()
-> MacosFullDiskAccess

Determine precisely:

1. Which concrete FullDiskAccess instance the development Presence adapter receives at runtime.
2. The exact implementation of canReadMessagesDatabase().
3. The exact filesystem path it attempts to open.
4. Whether it actually performs an SQLite/database read or merely succeeds in opening a file handle.
5. Whether macOS permits the operation being used even when FDA is disabled, making this an invalid FDA probe.
6. Whether the development app may be inheriting/accessing the source through some other entitlement, sandbox state, parent process, code-signing identity, or testing path.
7. Whether any provider override, fake, test implementation, cached value, or alternate FullDiskAccess implementation is accidentally being supplied.
8. Whether the current production onboarding FDA check would therefore also classify this environment as FDA-present.

Add temporary diagnostic logging or a focused development probe only if needed to establish the facts, but do not change the result semantics.

Report:

- the exact runtime implementation used;
- exact path tested;
- exact system call / SQLite operation attempted;
- actual result and exception behavior;
- why the method returns true with the FDA switch off;
- the smallest truthful way to test the permission MessageLens actually requires.

No implementation fix yet.

We first want to understand why the existing factual probe disagrees with System Settings.

This is actually a useful discovery. Presence has done its job as a test harness: it has exposed that our supposedly “real” FDA fact provider may not be measuring what we thought it was measuring.
