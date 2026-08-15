# Disposable Contacts Source Test Seam

## Status

Implemented for the development-only Presence onboarding experiment. Production
Contacts discovery and production onboarding are unchanged.

## Why The Live Source Is Not Used For Failure Testing

The viable Contacts database currently selected on this Mac is Apple-managed:

```text
/Users/rob/Library/Application Support/AddressBook/Sources/9A4E34C0-AB9D-4BB4-A1E2-53FF53475A40/AddressBook-v22.abcddb
```

`contactsd` and other Apple processes keep that database open. Renaming, moving,
or otherwise interfering with it would test filesystem disruption rather than
MessageLens onboarding and could damage live Contacts data.

## Injection Point

The seam is the Address Book `Sources` scan root accepted by
`AddressBookFolderPathsFinder`.

The ordinary production constructor still derives the Apple root through
`PathsHelper`. A separate explicit-root constructor lets the development client
point the same finder and repository at a controlled root. Everything after
that point remains real:

```text
explicit Sources root
    -> AddressBookFolderPathsFinder
    -> AddressBookFolderRepository
    -> candidate validation
    -> read-only SQLite open and query
    -> ContactsSourceReadinessPresenceAdapter
    -> ContactsSourceReadinessAuthority
```

No Boolean is inserted into the Step, Trip, Scheduler, or Schedule definition.

## Disposable Unavailable Source

The unavailable mode points discovery at the deliberately absent path:

```text
<admitted development archive>/
  development-tests/
    contacts-source-readiness/
      missing-sources/
```

The application does not create a database at that path. Ordinary source
discovery therefore finds no viable Address Book candidate and the repository
returns its normal unavailable result.

The test seam never reads, writes, renames, moves, or deletes anything beneath:

```text
~/Library/Application Support/AddressBook
```

## Development Control

The disposable Presence host presents a `Contacts test source` control with:

- `Real Contacts source`;
- `Disposable unavailable`.

The selection is machine-local laboratory configuration. It is stored at:

```text
<admitted development archive>/
  development-tests/
    contacts-source-readiness/
      source-mode.txt
```

This small file exists only so the selected test condition survives the app
restart required by the checkpoint experiment. It is not user intent, Presence
definition data, Schedule-run state, or production configuration. The control
and its composition are reachable only through the current debug-only Presence
experiment host, and the provider refuses a non-development archive.

## Fresh-Read Behavior

The development authority chooses the configured source on every
`canReadContactsSource()` invocation. The chosen adapter then invokes
`AddressBookFolderRepository.getFinalFolderAggregate()` afresh.

Changing the control does not rewrite the active Schedule or replace its
Scheduler. The next ordinary Contacts readiness Step observes the newly
selected external condition.

## Manual Test Procedure

1. Confirm the Messages source is readable.
2. Select `Disposable unavailable` under `Contacts test source`.
3. Select `Run Again` and complete the introduction and Messages readiness
   Trips.
4. Confirm Contacts readiness routes to Contacts guidance and does not enter
   FDA remediation.
5. Restart during Contacts guidance. Confirm guidance resumes at Step 1 and the
   source control remains `Disposable unavailable`.
6. Complete guidance so the Contacts test becomes the durable checkpoint.
7. Restart. Confirm the Contacts test resumes and a fresh check routes back to
   guidance because the disposable root is still unavailable.
8. Select `Real Contacts source`.
9. Complete guidance and the next Contacts test. Confirm the fresh real-source
   read reaches the combined Messages-and-Contacts confirmation.

Return the selector to `Real Contacts source` after the experiment.

## Test Evidence

Focused tests establish that:

- production repository composition still receives the ordinary production
  path finder;
- an explicit empty source root produces unavailable;
- an explicit viable source root produces available through the normal
  repository query path;
- explicit-root discovery ignores candidates outside that root;
- source selection is evaluated afresh for every readiness request;
- the laboratory selection survives construction of a new configuration-store
  instance, modelling restart;
- the ordinary Contacts remediation loop retries and later recovers;
- Contacts-only failure does not invoke the FDA settings authority.

## Preserved Boundaries

Production uses the same `folderPathFinderProvider` ->
`addressBookFolderRepositoryProvider` chain as before. Presence continues to
know only `ContactsSourceReadinessAuthority -> Future<bool>`. No Presence schema,
Step contract, Trip behavior, Scheduler behavior, route, or checkpoint semantic
changed.
