# Truthful Messages Source Readiness Implementation

## Status

Implemented as a development-only Presence onboarding experiment. Production
onboarding is unchanged.

MessageLens no longer treats an ordinary read-only file open as proof that it
can use the protected Messages source. It now asks the operational question it
actually needs answered:

> Can this process perform the protected Messages database read required by
> MessageLens?

This remains evidence about effective source access. It is not an inspection
of the Full Disk Access switch in System Settings.

## Previous Weak Probe

The previous `MacosFullDiskAccess.canReadMessagesDatabase()` implementation
checked that `~/Library/Messages/chat.db` existed, opened it as a plain
read-only file, and immediately closed it. A readable non-SQLite file could
therefore pass even though MessageLens could not query the source schema.

The earlier investigation is preserved in
[03-INACCURATE-FDA-TEST-INVESTIGATION.md](03-INACCURATE-FDA-TEST-INVESTIGATION.md).

## Corrected Specialist Boundary

Onboarding still owns the macOS protected-source specialist. Its provider now
consumes the existing Conversation Graph source-probe boundary rather than
introducing a second SQLite implementation:

```text
fullDiskAccessProvider
    -> ChatDbSourceProbeReader.readMaxRowId(path)
    -> SqliteChatDbSourceProbeReader
```

The source reader:

1. verifies that the expected source path exists;
2. opens SQLite with `OpenMode.readOnly`;
3. applies `PRAGMA query_only = ON`;
4. passes the SQL through the read-only SQL guard;
5. executes:

```sql
SELECT MAX(ROWID) AS max_rowid FROM message;
```

Success proves that the process opened the database through SQLite, resolved
the expected `message` table, and completed a real protected-source read. The
probe never opens a writable SQLite connection.

The specialist retains typed diagnostic distinctions for:

- missing database;
- failed read-only SQLite open;
- unavailable expected schema;
- failed query or result validation.

The ordinary `FullDiskAccess` application contract and Presence routing still
receive only the Boolean operational result. The logging boundary retains the
typed failure for diagnosis.

## Naming Correction

The permanent Presence capability is now named:

```text
MessagesSourceReadinessAuthority
    canReadMessagesDatabase()
```

This states exactly what the authority knows. It replaced
`FdaTestingAuthority.hasFullDiskAccess()`, which implied knowledge of a macOS
privacy-switch state that the application cannot query reliably.

`FdaTestStep` remains as the current workflow subtype because its unreadable
branch still leads to Full Disk Access remediation. Its persisted
`present`/`absent` arm column names remain unchanged for schema compatibility;
the runtime condition attached to those arms is now explicitly source
readability. Generated topology labels say `Readable` and `Unreadable`.

`FullDiskAccess` and `MacosFullDiskAccess` retain their established names
because that onboarding-owned service still combines the truthful readiness
check with the Full Disk Access Settings action. The operational method was
already named `canReadMessagesDatabase()`; no broad service rename was needed
for this slice.

## Onboarding Composition Path

The onboarding-owned integration path is:

```text
FdaTestStep
    -> MessagesSourceReadinessAuthority
    -> FullDiskAccessPresenceAdapter
    -> MacosFullDiskAccess
    -> ChatDbSourceProbeReader
```

There is no cached readiness result. Each Step completion performs a fresh
source read. Focused provider coverage replaces only the source reader with a
recording test boundary and proves that the real provider composition calls it
again for every readiness request. The development host is currently the first
consumer of this composition; it does not own the adapter or workflow meaning.

## Copy And Five-Trip Assessment

The five-Trip structure remains. Each Trip still represents a useful semantic
and restart boundary:

1. introduce MessageLens and the source-readiness check;
2. determine initial source readiness;
3. explain and open Full Disk Access remediation when needed;
4. resume and verify source readiness after returning;
5. confirm the already-established operational fact.

The first Trip no longer has four Tell Steps. It now says only:

```text
Welcome to MessageLens.

I'll make sure I can read the local Messages and Contacts information I need.
```

Full Disk Access is introduced only on the unreadable route, where the user
needs that exact System Settings term for the next action. The confirmation
Trip remains useful while this experiment ends at source readiness. When the
next onboarding concern exists, its opening Tell may absorb that confirmation;
doing so now would invent a concern outside this slice.

The revised fixture uses a new Schedule identity and new Trip, occurrence, and
Step identities. Existing persisted definitions and run history are therefore
not silently rewritten.

## Restart Semantics

The established checkpoint remains unchanged:

```text
guidance
    -> open System Settings
    -> enter verification Trip
    -> restart if required
    -> resume at verification Trip Step 1
    -> perform a fresh source-read test
```

No readiness Boolean, restart flag, current-Step position, polling mechanism,
or automatic retry state was added. Trip and Scheduler remain unchanged.

## Verification Status

Automated coverage proves that:

- a plain readable file fails;
- a read-only SQLite source with the expected `message` table succeeds;
- the probe does not modify the source file;
- source-read success selects the readable branch;
- a SQLite query failure selects remediation;
- the real development provider path performs fresh, uncached reads;
- restart resumes at the verification Trip;
- topology remains definition-derived.

### Manual FDA-off result

On August 10, 2026, the experiment was launched fresh from VS Code with the
visible `MessageLens Development.app` Full Disk Access entry turned off. The
real source-readiness Step selected the readable route:

```text
Trip 202
    -> Readable: Trip 205
```

The durable execution trace proves that this was a new test rather than a
restored decision. Schedule run 10 started at 06:32:03, Step occurrence 24 ran
at 06:32:18, and the resulting route decision recorded Trip definition 205 and
Trip occurrence 5105.

This result does not mean the visible FDA switch was read incorrectly. It means
the running process actually completed the protected SQLite query despite that
entry being off. Process inspection showed this launch chain:

```text
VS Code Insiders plugin host
    -> Flutter debug adapter
    -> flutter run
    -> MessageLens Development.app
```

The Debug artifact was ad hoc signed with no Team identifier, and `chat.db`
carried a `com.apple.macl` extended attribute. Either responsible-process
privacy attribution or file-specific inferred consent may account for the
effective access. The user TCC database was itself protected, so this pass
could not distinguish conclusively between those mechanisms.

The operational result is therefore truthful for this process. It is not a
controlled test of how an independently launched MessageLens identity behaves
when FDA is absent. Testing the unreadable remediation route without a fake
requires a directly launched development artifact with a stable signing
identity and no privileged launcher in its responsible-process chain.

## Controlled Standalone Test Artifact

The controlled manual experiment uses a separate application identity:

```text
Display name: MessageLens FDA Experiment
Bundle identifier: com.bigbenchsoftware.MessageLens.fdaexperiment
Build identity: fdaExperiment
Archive environment: development
```

`fdaExperiment` is an exact admitted build identity. It cannot claim the normal
development application name or bundle identifier, and a normal development
build identity cannot claim the experiment application identity. Native and
Dart admission both enforce that distinction.

The experiment embeds this machine's existing development root in its own
launch environment:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
```

Native bootstrap and Dart admission therefore continue to resolve and compare
the same canonical development root. The artifact cannot fall back silently
to a new Application Support archive when the external volume is unavailable.
It also shares the development archive's process lock, so normal development
MessageLens and the FDA experiment cannot use that archive concurrently.

The one-off build is produced by:

```bash
./tool/build_fda_experiment.sh
```

The script builds ordinary Debug code in an isolated directory, copies that
product, applies only the experiment bundle metadata to the copy, removes the
temporary ordinary development product, and signs the experiment with the
installed Apple Development identity. It does not alter the Xcode project
settings used by production, Debug, Profile, or Release builds. It does not
launch the application or change TCC/Full Disk Access state.

Completed automated verification:

- 29 focused source-readiness, provider, routing, restart, and topology tests;
- 55 complete Presence subsystem and experimental-client tests;
- 354 architecture tripwires;
- clean `flutter analyze`;
- successful macOS Debug build;
- clean formatting and `git diff --check`.

## Controlled Manual FDA Restart Validation

On August 10, 2026, the standalone experiment artifact was launched directly,
outside VS Code and `flutter run`, with this identity:

```text
Display name: MessageLens FDA Experiment
Bundle identifier: com.bigbenchsoftware.MessageLens.fdaexperiment
Signing identity: Apple Development: Rob Campbell (ZQ7EL9CA37)
```

Full Disk Access was initially absent for that fresh TCC identity. The real
source-readiness test failed, the remediation route explained the required
access, and the Settings-opening Step opened the Full Disk Access pane. After
the user granted access and restarted the app, Presence resumed at verification
Trip occurrence `5104`. The first text shown was:

> Welcome back. I’ll check whether MessageLens can now read the protected
> Messages database.

The following readiness Step performed a fresh SQLite read and succeeded. The
Schedule then routed to Trip occurrence `5105` and presented:

> MessageLens can read the protected Messages source. I’m ready to continue.

This manually validates the intended restart seam:

```text
guidance
    -> open Settings
    -> checkpoint verification Trip
    -> process restart
    -> resume at verification Step 1
    -> test the current external fact
    -> continue along the success route
```

The result required no restart flag, persisted readiness Boolean, current-Step
checkpoint, retry object, trace replay for state, FDA-specific Trip logic, or
FDA-specific Scheduler logic. The durable Trip occurrence remained the sole
execution checkpoint.

Detailed evidence and the initial-presentation diagnosis are preserved in
[05-MANUAL-FDA-RESTART-VALIDATION.md](05-MANUAL-FDA-RESTART-VALIDATION.md).

## Initial Presentation Diagnosis

The experiment initially appeared to show stale confirmation copy from an
earlier run. The persisted database and execution trace show that this was not
a renderer or provider mismatch.

The normal development app and the isolated FDA experiment intentionally use
the same admitted development archive, including the same `presence.db`.
Before the isolated app launched, Schedule 5 run 10 was still active at Trip
occurrence `5105`, whose only Step is the readable-source confirmation. At
07:46:26 the isolated process loaded that same checkpoint and recorded another
`trip_started` observation for occurrence `5105`. The host therefore rendered
the exact Trip and Step reconstructed from the database.

Run 10 completed at 07:46:44. `Run Again` then created run 11 at 07:46:46 with
current Trip occurrence `5101`, after which the host rendered the new run from
its beginning. The later process restart loaded run 11 at occurrence `5104`
and rendered verification Step `5401`, matching the checkpoint exactly.

The fresh bundle identifier created a fresh macOS privacy identity; it did not
create a fresh Presence execution store. Presence run state is scoped to the
admitted development archive and Schedule identity, not to the executable that
opens that archive. No application correction was made because the database,
repository, provider, Scheduler, and host remained in agreement throughout.
Resetting the database, filtering runs by bundle identifier, or adding launch
state would make that authority less truthful rather than more truthful.

The controlled experiment therefore required no change to the Schedule model,
Trip, Step routing contract, Scheduler, or `ScheduleRun` checkpoint semantics.
This is real-world validation of those boundaries, not only a synthetic test
result.

## What the specialist now knows

The specialist knows whether the current process completed one truthful,
read-only query against the protected Messages source. It retains the concrete
failure category when that operation fails. It does not know whether a visible
System Settings switch is on.

## What the Step knows

The Step knows only the Boolean source-readiness answer and the two configured
Trip destinations. It does not know the path, SQL, SQLite failure category, or
macOS permission mechanism.

## What the user needs to be told

When the source is readable, the user needs no Full Disk Access explanation.
When it is unreadable, the user needs to know that MessageLens requires access
to Messages and Contacts data, that macOS exposes the relevant remedy as Full
Disk Access, and how to open that System Settings pane.
