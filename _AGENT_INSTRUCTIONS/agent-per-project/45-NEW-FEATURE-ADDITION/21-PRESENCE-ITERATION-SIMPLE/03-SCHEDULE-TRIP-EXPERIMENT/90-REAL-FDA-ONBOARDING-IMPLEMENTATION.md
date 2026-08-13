# Real Full Disk Access Onboarding Implementation

## Status

Implemented as a development-only Presence experiment.

This slice does not integrate Presence with production onboarding. It does not
change `OnboardingGate`, Environment Readiness, archive admission, database
access policy, production preservation, or the production FDA entry.

## Implemented Boundary

The experiment now uses the existing real onboarding-owned FDA service through
one development-client adapter:

```text
FdaTestStep
    -> FdaTestingAuthority
    -> FullDiskAccessPresenceAdapter
    -> FullDiskAccess.canReadMessagesDatabase()

OpenFdaSettingsStep
    -> FdaSettingsOpeningAuthority
    -> FullDiskAccessPresenceAdapter
    -> FullDiskAccess.openSettings()
```

Presence owns the two narrow contracts and their workflow meaning. The
experimental feature owns the adapter. Onboarding continues to own the actual
macOS FDA implementation.

No generic Agent, action Step, condition engine, or command registry was added.

## Schema Change

`presence.db` advances from schema version 4 to 5.

The base discriminator now accepts:

```text
open_fda_settings
```

The class-table subtype is:

```text
open_fda_settings_step_definitions
    step_definition_id PK/FK -> step_definitions.id
```

No payload column exists because this Step has no persisted configuration.
Migration rebuilds the base Step constraint and creates the subtype table. A
file-backed v4 migration test proves preservation of an existing definition,
active Schedule run, and execution trace.

## New Step

`OpenFdaSettingsStep` asks only its `FdaSettingsOpeningAuthority` to open the
Full Disk Access pane. It returns `null` after the request completes.

If the authority throws:

- the Step does not complete;
- the runtime Trip remains on that Step;
- no Trip checkpoint is written;
- no route to verification is recorded.

The Step does not test FDA and does not claim permission was granted.

## Five-Trip Fixture

The active development fixture is now:

```text
introduce_message_lens
    Tell: Welcome to MessageLens.
    Tell: explain local Messages and Contacts database access
    Tell: explain Full Disk Access and quote Apple
    Tell: explain chat database and Address Book use

determine_initial_fda_state
    FdaTestStep

guide_user_to_grant_fda
    Tell: add or enable MessageLens Development; restart may be required
    OpenFdaSettingsStep

verify_fda_assignment
    Tell: Welcome back; the protected Messages source will be checked
    FdaTestStep

confirm_fda_available
    Tell: the protected Messages source is readable; the FDA slice is complete
```

The new Schedule and Trips use fresh durable identities. This preserves the
earlier synthetic definition, its runs, and its trace rather than rewriting
historical data in place.

## Implemented Copy

The fixture currently presents the following text, in order:

1. `Welcome to MessageLens.`
2. `Before you get started, I need to make sure I can access the databases on
   your Mac that store information about your contacts and messages.`
3. `Apple requires you to give MessageLens what it calls Full Disk Access.`
   This continues with the approved explanation and Apple's quotation:
   `“Full Disk Access allows applications to access data like Mail, Messages,
   Safari, Home, Time Machine backups, and certain administrative settings.”`
4. `I need this access to read your chat database, which stores your messages,
   and your Address Book database, which lets me match those messages with the
   people in your contacts.`
5. `In Full Disk Access, add or enable MessageLens Development. macOS may ask
   you to quit and reopen the app after you make the change.`
6. `Welcome back. I’ll check whether MessageLens can now read the protected
   Messages database.`
7. `MessageLens can now read the protected Messages source. This Full Disk
   Access step is complete.`

The guidance, return orientation, and confirmation wording remain provisional.

## Generated Topology

The persisted definition mechanically generates:

```text
introduce -> determine

determine:
    Present -> confirm
    Absent  -> default guide

guide -> default verify

verify:
    Present -> default confirm
    Absent  -> guide

confirm -> complete
```

The checked generated artifact is:

[`generated/real_fda_onboarding_experiment.md`](generated/real_fda_onboarding_experiment.md)

Neither Mermaid nor the live map contains a separately authored route graph.

## Restart Semantics

The Settings-opening Step is terminal in the guidance Trip. Successful
completion checkpoints the verification Trip before any later FDA test.

On relaunch:

```text
schedule_runs.current_trip_occurrence_id
    -> verify_fda_assignment

fresh runtime Trip
    -> Step 1
    -> "Welcome back..."
    -> real FDA test when the user deliberately continues
```

There is no restart flag, current-Step persistence, trace replay, polling, or
automatic verification.

## Development Host

The fake Present/Absent switch and fake authority are removed from the active
path. The host retains:

- manual Step completion;
- generated Mermaid;
- live Schedule map;
- execution trace;
- explicit `Run Again` after completion.

The Settings Step receives a purposeful `Open System Settings` button label.
Any authority failure is shown without advancing the workflow.

## Manual Experiment

Use the development FDA entry only: `MessageLens Development`.

### FDA already present

1. Start or restart the experiment with `Run Again`.
2. Complete the four introduction Tells.
3. Complete the initial FDA test.
4. Confirm that remediation is skipped and the confirmation Trip appears.

### FDA absent, then granted with restart

1. Disable FDA for `MessageLens Development` only.
2. Complete the introduction and initial test.
3. Complete the guidance Tell.
4. Choose `Open System Settings`.
5. Confirm the live map/checkpoint is `verify_fda_assignment`.
6. Enable FDA for `MessageLens Development`, then quit and relaunch if macOS
   requires it.
7. Confirm the same run resumes with the `Welcome back` Tell at Step 1.
8. Complete that Tell, then complete the real FDA test.
9. Confirm the Schedule reaches `confirm_fda_available`.

### FDA remains absent

Leave development FDA disabled and continue through verification. The ordinary
routes repeat:

```text
guide -> verify -> guide -> verify
```

No retry object or loop state exists.

## Architectural Result

`Trip` did not change. `PresenceScheduler` did not change. Execution trace
remains observational. The real-world restart seam is expressed solely by the
existing Trip checkpoint.

The implementation follows the approved plan without architectural deviation.
The only deliberately provisional material is the guidance and confirmation
copy, which remains easy to revise inside the fixture.

## Verification

Automated verification completed successfully:

- all 52 focused Presence and experimental-client tests passed;
- all 354 architecture tripwires passed;
- `flutter analyze` reported no issues;
- the macOS debug build produced `MessageLens Development.app`;
- code generation and formatting completed successfully;
- `git diff --check` reported no whitespace errors.

The focused coverage includes both real FDA outcomes, the absent-FDA retry
loop, restart from the verification Trip at Step 1, settings-opening failure
without advancement, schema-v4-to-v5 preservation, generated topology, and the
development adapter's delegation to the onboarding-owned service.

The manual FDA scenarios above remain an explicit human experiment. They were
not simulated by changing the production FDA entry during this implementation
pass.

One inherited boundary remains intentionally unchanged: the existing
onboarding-owned settings service considers a completed macOS `open` request a
successful request to open System Settings. This slice preserves that
production behavior and proves that thrown adapter failures cannot advance the
Presence run.
