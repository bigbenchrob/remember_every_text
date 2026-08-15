# Inaccurate Full Disk Access Test Investigation

## Status

Investigation complete. No FDA behavior, Presence route, Schedule definition,
or result semantics were changed.

The corrective implementation is recorded in
[04-TRUTHFUL-MESSAGES-SOURCE-READINESS-IMPLEMENTATION.md](04-TRUTHFUL-MESSAGES-SOURCE-READINESS-IMPLEMENTATION.md).

The observed result is real, but the current method's name overstates what it
establishes. It does not inspect the Full Disk Access setting and does not prove
that MessageLens can perform its required SQLite source operation. It proves
only that the current process can open one particular file for reading at that
moment.

## Runtime Path

The development Presence experiment follows this concrete path:

```text
FdaTestStep
    -> FdaTestingAuthority
    -> FullDiskAccessPresenceAdapter
    -> MacosFullDiskAccess.canReadMessagesDatabase()
```

`realFdaPresenceAuthorityProvider` watches the public onboarding
`fullDiskAccessProvider`. That provider constructs `MacosFullDiskAccess`.
There is no runtime provider override between them.

The adapter performs no interpretation or caching. Its
`hasFullDiskAccess()` method directly returns the result of
`canReadMessagesDatabase()`.

Repository searches found no fake, alternate implementation, cached FDA value,
or development override in this path. FDA fakes and overrides exist only in
tests or in the separate onboarding diagnostics controls; neither supplies the
Presence adapter used by the running experiment.

## Exact Probe

On this Mac, the path is:

```text
/Users/rob/Library/Messages/chat.db
```

`MacosFullDiskAccess.canReadMessagesDatabase()` performs these operations:

```text
File(path).existsSync()
File(path).openSync(mode: FileMode.read)
closeSync()
```

It does not:

- open SQLite;
- read a SQLite page;
- inspect the database schema;
- query the `message` table;
- verify access to attachments or Address Book data;
- query macOS Full Disk Access state.

The method returns `true` if the file exists and the read-only file descriptor
can be opened and closed without an exception. It returns `false` if the file
does not exist or the open throws. An open failure is reported asynchronously
through the onboarding logger callback.

The Presence result therefore means:

> This process could open this `chat.db` file for reading now.

It does not mean:

> System Settings records Full Disk Access as enabled for MessageLens
> Development.

## Why It Returned True

The immediate, proven reason is that `File.openSync` did not throw in the
running MessageLens Development process. The probe returned that fact exactly.

The precise macOS authority that permitted the open cannot be established from
inside the application. macOS provides no supported general API for querying
TCC's Full Disk Access decision, and the user's TCC database was itself
unavailable to this investigation.

Two concrete properties of the development environment can explain why the
effective file access and the visible switch disagree:

1. **Responsible-process attribution.** The Debug application is launched by
   the Flutter daemon hosted by VS Code Insiders. macOS privacy decisions can
   depend on the responsible code or launch chain, not only on the child
   process whose window is visible.
2. **File-specific inferred consent.** `chat.db` carries a `com.apple.macl`
   extended attribute. macOS may use this attribute for file-specific user
   consent that is not represented by the Full Disk Access list.

The Debug artifact is also ad hoc signed:

```text
bundle identifier: com.bigbenchsoftware.MessageLens.development
signature: ad hoc
team identifier: absent
designated requirement: absent
```

Apple specifically warns that ad hoc development signing makes privacy identity
unstable. This does not itself grant access, but it prevents the development
artifact from being treated as a clean, stable test subject across builds.

These are supported explanations, not a proven choice between two causes. The
investigation must not claim that macOS generally permits this operation when
Full Disk Access is disabled. The same read was denied when attempted from the
Codex shell process. Access is specific to the effective authority of the
process performing it.

Apple's relevant guidance is recorded in:

- [Accessing files from the macOS App Sandbox](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox)
- [On File System Permissions](https://developer.apple.com/forums/tags/files-and-storage)
- [Ad hoc signing and TCC identity](https://developer.apple.com/forums/thread/125438)
- [`com.apple.macl` and inferred access](https://developer.apple.com/forums/thread/124121?answerId=391281022)
- [Reliable test for Full Disk Access?](https://developer.apple.com/forums/thread/114452)

## Production Consequence

Production onboarding currently uses the same
`fullDiskAccessProvider.canReadMessagesDatabase()` method. It therefore asks the
same narrow question and would classify any production process able to open
that file descriptor as FDA-present.

The installed production artifact is independently launched and has a stable
Developer ID signature and production bundle identifier. Its macOS privacy
identity is therefore materially different from the VS Code-launched, ad hoc
Debug artifact. The development observation cannot predict whether the
production process will receive access, but the semantic weakness in the probe
is shared by both paths.

## Comparison With The Required Operation

Source ingestion opens the Messages database through SQLite in read-only mode,
enables `PRAGMA query_only`, and issues actual queries. The existing
`SqliteChatDbSourceProbeReader` already performs that class of operation by
opening `chat.db` read-only and executing:

```sql
SELECT MAX(ROWID) AS max_rowid FROM message;
```

This is materially stronger than acquiring and closing a plain file descriptor.
It proves that the process can open SQLite, read database pages, resolve the
expected schema, and read the protected source table.

## Smallest Truthful Future Probe

The smallest truthful question is not:

> Is the Full Disk Access switch on?

There is no supported general API that can answer that question reliably.

The useful factual question is:

> Can this process perform the protected Messages source read that MessageLens
> currently requires?

A future correction should use the same read-only SQLite boundary as source
ingestion and execute one minimal schema-specific query, such as:

```sql
SELECT MAX(ROWID) FROM message;
```

That probe should report Messages-source readability rather than claiming to
read the System Settings switch. It should retain explicit failure information
instead of reducing all failures to an unexplained Boolean.

This still proves only access to `chat.db`. Address Book databases, attachment
source files, and protected directories are separate operational facts and may
eventually require their own readiness evidence.

For clean FDA experiments, MessageLens Development should also be launched
independently with a stable Apple Development signature rather than using an ad
hoc VS Code build. That improves TCC identity stability but does not replace the
source-read probe.

## Findings

| Question | Finding |
| --- | --- |
| Concrete runtime implementation | `MacosFullDiskAccess` |
| Provider override or fake | None in the running Presence path |
| Cached result | None |
| Path | `/Users/rob/Library/Messages/chat.db` |
| Operation | Existence check, plain read-only file open, immediate close |
| SQLite operation | None |
| True condition | The current process opened the file descriptor without throwing |
| False condition | Missing file or an exception while opening it |
| Exact alternate macOS authority | Not observable conclusively; responsible-process attribution and file-specific `com.apple.macl` consent are evidenced possibilities |
| Production code path | Uses the same narrow probe |
| Smallest truthful replacement | Read-only SQLite open plus a minimal query against the required `message` table |

## Scope Outcome

No implementation fix was made. The temporary diagnostic used during the
investigation was removed. Presence successfully exposed that the existing
onboarding fact provider measures effective single-file openability rather than
the operational database-read capability its FDA language implies.
