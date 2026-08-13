> Add a **development-only disposable Contacts source test seam** so we can exercise the real Contacts-unavailable onboarding route without modifying Apple’s live Address Book database.
>
> Do not change production Contacts behavior.
>
> Do not change Presence routing, `Trip`, `PresenceScheduler`, checkpoint semantics, or the `ContactsSourceReadinessStep` contract.
>
> The goal is only to let the development experiment substitute a safe disposable Contacts source condition.
>
> ---
>
> ## Current problem
>
> The real Address Book database currently used by MessageLens is:
>
> ```text
> /Users/rob/Library/Application Support/AddressBook/Sources/9A4E34C0-AB9D-4BB4-A1E2-53FF53475A40/AddressBook-v22.abcddb
> ```
>
> `lsof` shows that both `Messages` and `contactsd` keep many live file descriptors open to it.
>
> We therefore do **not** want to rename, move, corrupt, or otherwise interfere with that live Apple-managed database merely to test the Presence remediation branch.
>
> ---
>
> ## Desired test seam
>
> Preserve the production chain:
>
> ```text
> ContactsSourceReadinessStep
>     -> ContactsSourceReadinessAuthority
>     -> ContactsSourceReadinessPresenceAdapter
>     -> AddressBookFolderRepository
> ```
>
> But allow the **development Presence experiment only** to supply a controlled disposable source condition.
>
> Prefer the smallest seam already available in the repository/provider architecture.
>
> Do not put a fake Boolean directly into `ContactsSourceReadinessStep`.
>
> We want to exercise as much of the real boundary as practical while controlling only the external source condition.
>
> ---
>
> ## Preferred approach
>
> First inspect the existing Address Book repository/path-finder/provider boundaries and determine the narrowest safe substitution point.
>
> Prefer, in order:
>
> 1. a development-only alternate Address Book root/candidate source consumed by the existing repository;
> 2. an existing injectable path-finder/source-reader boundary;
> 3. a development-only repository adapter backed by a disposable copied database;
> 4. only if none of those fit cleanly, a development-only readiness-authority implementation.
>
> Use the earliest seam that lets the real discovery/query behavior remain intact.
>
> Do not create a broad new testing framework.
>
> ---
>
> ## Disposable test states
>
> We need to be able to produce at least:
>
> ```text
> Contacts available
> Contacts unavailable
> ```
>
> Ideally, the unavailable state should arise naturally because the disposable source:
>
> - does not contain a viable Address Book database; or
> - points at a deliberately missing candidate;
>
> rather than because a Boolean has simply been hard-coded.
>
> If practical, create a disposable test directory under the development archive or another clearly development-owned temporary location.
>
> Do not use or mutate:
>
> ```text
> ~/Library/Application Support/AddressBook
> ```
>
> for the unavailable test.
>
> ---
>
> ## Available-state option
>
> If useful, create a **read-only copy** of the current viable Address Book database for the disposable available case.
>
> Do not copy or expose more Apple-managed data than necessary.
>
> If the existing repository requires surrounding directory structure or related SQLite files, inspect and reproduce only what is actually required.
>
> The test copy is development/test material, not a new application data source.
>
> ---
>
> ## Development-host control
>
> Add the smallest clear development-only control needed to switch the Presence experiment between:
>
> ```text
> Real Contacts source
> Disposable unavailable source
> ```
>
> Optionally include:
>
> ```text
> Disposable available source
> ```
>
> if it naturally falls out of the same seam.
>
> Keep this control unmistakably development-only.
>
> Do not persist it as user intent or Presence definition data.
>
> Do not add it to production UI.
>
> ---
>
> ## Manual experiment we want
>
> With Messages source readable:
>
> ```text
> Run Again
> -> Messages readiness passes
> -> Contacts readiness checks disposable unavailable source
> -> Contacts remediation appears
> ```
>
> Verify that **FDA remediation does not appear**.
>
> Then:
>
> ```text
> restart while in Contacts guidance
> -> resume Contacts guidance at Step 1
> ```
>
> Next:
>
> ```text
> complete guidance
> -> checkpoint Contacts test
> -> restart
> -> resume Contacts test
> -> fresh check still sees unavailable source
> -> route back to guidance
> ```
>
> Finally switch the development test source back to a viable source and continue:
>
> ```text
> guidance
> -> fresh Contacts test
> -> available
> -> combined Messages + Contacts confirmation
> ```
>
> This should prove the retry loop and recovery using the real Schedule.
>
> ---
>
> ## Important architectural constraint
>
> The test seam must remain **outside Presence semantics**.
>
> Presence should still see only:
>
> ```text
> ContactsSourceReadinessAuthority
>     -> true / false
> ```
>
> `ContactsSourceReadinessStep` must not learn:
>
> - whether the source is real or disposable;
> - which path is being used;
> - whether this is a test;
> - why readiness failed.
>
> `Trip` and Scheduler must remain entirely unchanged.
>
> ---
>
> ## Tests
>
> Add focused coverage proving:
>
> - production Contacts provider composition remains unchanged;
> - disposable unavailable source produces `false`;
> - disposable viable source produces `true`, if implemented;
> - each retry performs a fresh read rather than using cached readiness;
> - switching the development source between retries changes the observed result;
> - Contacts remediation loop uses ordinary routing;
> - no FDA route is entered for Contacts-only failure;
> - no Apple Address Book source is modified by the test seam.
>
> Run the existing Contacts/Presence tests, architecture tripwires, analyzer, formatting, and `git diff --check`.
>
> ---
>
> ## Documentation
>
> Update:
>
> `07-CONTACTS-SOURCE-READINESS-IMPLEMENTATION.md`
>
> or create a short companion:
>
> `08-DISPOSABLE-CONTACTS-SOURCE-TEST-SEAM.md`
>
> Record:
>
> - why the live Apple database was not manipulated;
> - the chosen injection point;
> - disposable source location/shape;
> - development-host control;
> - exact manual test procedure;
> - confirmation that production composition is unchanged;
> - confirmation that Presence is unaware of the test source.
>
> ---
>
> ## Hard constraints
>
> Do not:
>
> - rename/move/delete the live Address Book database;
> - kill or manipulate `contactsd`;
> - modify Apple Contacts data;
> - change production Contacts source discovery;
> - add a fake Boolean inside the Step;
> - add generic simulation infrastructure;
> - add test state to `presence.db`;
> - change Trip or Scheduler.
>
> If the existing source infrastructure cannot accept a disposable source cleanly, stop and explain the narrowest alternative rather than forcing it.
>
> ---
>
> ## Success criterion
>
> We should be able to safely demonstrate:
>
> ```text
> real Messages source readable
> +
> disposable Contacts source unavailable
>     -> Contacts guidance
>     -> retry loop
>
> switch disposable condition to available
>     -> fresh test succeeds
>     -> combined confirmation
> ```
>
> without touching the live Apple Address Book database and without Presence knowing that a test seam exists.

This gives us the failure/recovery test we want without playing filesystem games with `contactsd`.
