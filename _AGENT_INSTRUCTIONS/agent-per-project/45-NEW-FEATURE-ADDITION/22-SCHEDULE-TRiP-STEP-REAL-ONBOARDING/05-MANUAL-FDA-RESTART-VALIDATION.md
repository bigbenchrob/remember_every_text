# Manual FDA Restart Validation

## Purpose

This record preserves the controlled manual validation of the real Messages
source-readiness onboarding route. It also explains why the first presentation
shown by the isolated app looked stale even though the runtime was correctly
following its durable checkpoint.

## Experimental Identity

```text
Display name: MessageLens FDA Experiment
Bundle identifier: com.bigbenchsoftware.MessageLens.fdaexperiment
Signing identity: Apple Development: Rob Campbell (ZQ7EL9CA37)
Launch method: direct launch outside VS Code and flutter run
Archive environment: development
```

The bundle identifier supplied a fresh TCC/privacy identity. The artifact still
used the established development archive:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
```

That archive includes the development `presence.db`. The experiment and the
normal development app therefore see the same Presence definitions, runs, and
append-only execution traces, while the archive process lock prevents them
from using it concurrently.

## Observed FDA Route

Full Disk Access was initially absent for the experiment identity.

```text
initial source-readiness test
    -> unreadable
    -> remediation guidance
    -> open Full Disk Access settings
    -> checkpoint verification Trip
    -> grant FDA manually
    -> restart process
    -> resume at verification Step 1
    -> fresh source-readiness test
    -> readable
    -> confirmation
```

The first presentation after restart was:

> Welcome back. I’ll check whether MessageLens can now read the protected
> Messages database.

The next Step executed the real read-only SQLite source probe. It succeeded and
the final presentation stated:

> MessageLens can read the protected Messages source. I’m ready to continue.

No restart flag, readiness Boolean, current-Step checkpoint, retry object, or
trace replay participated in this route. Restart recovery used only the
persisted current Trip occurrence.

## Persisted Evidence

Schedule 5 is:

```text
truthful_messages_source_readiness_onboarding_experiment
```

The controlled run was run 11. Its relevant checkpoints were:

```text
07:47:10  remediation Trip 203 completed
07:47:10  route selected verification occurrence 5104
07:47:31  relaunched process recorded verification Trip 204 started
07:47:55  verification orientation Step 5401 completed
07:47:58  fresh readiness Step 5402 completed
07:47:58  route selected confirmation occurrence 5105
```

The duplicate `trip_started` observation for occurrence `5104` is consistent
with reconstruction after process restart. It does not determine state; the
stored `schedule_runs.current_trip_occurrence_id` does.

## Initial Presentation Anomaly

On the isolated app's first launch, the UI showed confirmation copy implying
that the Messages source was already readable. That presentation was initially
suspected to be stale UI state.

The database trace identifies a more precise cause. Schedule 5 run 10 had been
created earlier by the normal debug app and remained active at confirmation
occurrence `5105`. Because both applications intentionally use the same
development `presence.db`, the experiment app loaded run 10 rather than
inventing another run.

The observed sequence was:

```text
06:32:18  run 10 routed to confirmation occurrence 5105
07:46:26  isolated app launched and reconstructed occurrence 5105
07:46:44  confirmation Step completed; run 10 completed
07:46:46  Run Again created run 11 at occurrence 5101
```

The runtime chain remained aligned:

```text
presence.db run 10 / occurrence 5105
    -> repository reconstructed Trip 205
    -> Scheduler installed Trip 205
    -> provider returned that Scheduler
    -> host rendered Step 5501
```

While `Run Again` is awaiting its database transaction, the host may continue
to show the completed run with its button changed to `Starting...`. Once the
operation resolves, the same Scheduler contains the new run and the host
rebuilds from it. The trace proves that run 11 began at occurrence `5101`; no
old presentation survived the completed operation. This short in-flight state
did not cause the first-launch observation.

This was old experimental progress, but it was not an old completed run, an
older fixture identity, cached provider state, retained renderer state, or a
mismatch between the active run and displayed domain object. It was the one
active checkpoint for that Schedule in the shared development archive.

## Architectural Result

A fresh application privacy identity and a fresh Presence run are independent
concerns. The experiment intentionally changed only the former.

No corrective code was warranted. Scoping runs to bundle identity, clearing
history, resetting the database, or introducing a launch flag would conflict
with the established database authority. When a genuinely fresh run was
needed, the existing explicit `Run Again` operation created it and preserved
the prior run and trace.

The real FDA experiment required no change to:

- the Schedule model;
- Trip;
- the Step routing contract;
- the Scheduler;
- `ScheduleRun` checkpoint semantics.

The manual result validates the existing architecture under a real macOS
privacy grant, process restart, fresh external source probe, and durable
resume.
