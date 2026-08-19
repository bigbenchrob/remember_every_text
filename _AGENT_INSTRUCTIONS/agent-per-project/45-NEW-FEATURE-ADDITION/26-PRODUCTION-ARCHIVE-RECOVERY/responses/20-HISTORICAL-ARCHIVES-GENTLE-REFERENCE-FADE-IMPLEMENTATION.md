# Historical Archives Gentle Reference Fade Implementation

## Status

Implemented on `Ftr.archive-recovery`.

## Refined Principle

> Referential attention should be the smallest visual change sufficient to
> direct human attention.

Historical Archives still uses orange to say, "This is the thing another
interaction is referring to." Orange remains distinct from blue selection and
does not communicate warning, error, urgency, or destructive action.

## Presentation Lifecycle

After the duplicate-folder modal is dismissed in the same active Historical
Archives presentation session, the matching ordinary cartouche now receives:

1. a 750 ms fade into a light orange correspondence tint;
2. a 1,000 ms steady hold;
3. a 2,000 ms fade back to ordinary chrome; and
4. complete removal of transient reference state after 3,750 ms.

The maximum treatment uses a low-alpha orange background and restrained orange
border. It has no glow, pulse, scale, bounce, or text-color reduction. At the
end of the sequence the decoration is exactly the ordinary unselected
cartouche decoration.

This appearance is local to Historical Archives. The shared All Messages
correspondence appearance and behavior were not changed.

## Occurrence And Session Safety

`referenceOccurrence` is monotonically increasing process/presentation state.
It answers only whether a fresh "look here" event happened. The canonical
source key continues to answer which archive is being referenced.

Provider and widget rebuilds do not replay an occurrence. A newer occurrence
restarts the presentation and supersedes the older one. Reference-clear timers
validate both the occurrence and the Historical Archives presentation session,
so an older timer cannot clear a newer reference and navigation away cannot
resurrect abandoned presentation state.

The occurrence is not persisted and does not participate in source identity.

## Reduced Motion

When reduced motion is requested, Historical Archives immediately presents the
same light static correspondence appearance without running the fade
animation. Workflow ownership still clears the reference after the same
bounded 3,750 ms lifetime.

## Preserved Behavior

The duplicate modal, hub restoration, canonical source identity, blue
selection, folder qualification, source registration, import, removal,
mutation authority, persistence, and database schema are unchanged. No archive
operation is initiated by this presentation refinement.

## Verification

Focused coverage proves:

- the fade reaches intermediate and maximum light treatments on schedule;
- the one-second hold remains steady;
- the two-second fade returns exactly to ordinary chrome;
- text remains at the normal primary color and no blue selection or glow is
  introduced;
- rebuilds do not replay an occurrence;
- a newer occurrence restarts safely;
- clearing or leaving the presentation restores ordinary appearance;
- reduced motion uses a bounded static treatment; and
- duplicate modal, hub, source identity, and archive behavior remain intact.

- focused Historical Archives sidebar, workflow, provider, and panel tests: 53
  passed;
- complete Settings tests: 100 passed;
- architecture tripwires: 374 passed;
- `flutter analyze`: no issues;
- formatting: clean;
- `git diff --check`: clean.
