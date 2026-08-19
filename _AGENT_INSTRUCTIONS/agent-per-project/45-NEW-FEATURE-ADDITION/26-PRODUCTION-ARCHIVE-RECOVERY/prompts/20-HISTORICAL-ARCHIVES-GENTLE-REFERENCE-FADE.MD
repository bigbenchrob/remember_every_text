# Historical Archives Gentle Reference Fade

Work on branch `Ftr.archive-recovery`.

This is a small Historical Archives referential-attention refinement.

Do not change the duplicate modal semantics, hub restoration, source identity,
or any archive execution behavior.

## Manual Review Finding

The current orange referential treatment after dismissing the already-added
modal is too visually forceful. The semantic message is:

> This is the folder I was referring to.

Replace the Historical Archives duplicate-folder orange pulse/linger treatment
with a subtle transient correspondence highlight.

## Desired Lifecycle

```text
ordinary cartouche
-> light orange highlight fades in over about 750 ms
-> highlight remains steady for about 1 second
-> highlight fades completely away over about 2 seconds
-> ordinary unselected cartouche
```

Orange continues to mean correspondence, not warning, error, selection,
urgency, or destructive action. The modal is extending a finger toward the
matching cartouche and quietly saying, "This one."

## Presentation Requirements

- Remove the dark/deep orange treatment, pulse, emphatic glow, scale, and
  bounce from Historical Archives.
- Use a substantially lighter orange background/border treatment while
  preserving full text legibility.
- Return completely to ordinary unselected appearance after the fade.
- Do not modify the All Messages context-sidebar treatment.
- Keep appearance ownership separate from occurrence/session semantics.

## Occurrence And Navigation

Preserve the established occurrence rules. Modal dismissal in the same active
Historical Archives presentation session creates one new referential
occurrence. A new duplicate attempt restarts the sequence. Rebuilds do not
replay it. Older timers and animations cannot clear or interfere with a newer
occurrence. Leaving Historical Archives prevents stale correspondence from
returning.

The occurrence remains process/presentation state only. It is neither durable
source metadata nor source identity.

## Reduced Motion

When reduced motion is requested, show the smallest calm static correspondence
treatment for the same bounded interval, then clear it. Do not run the animated
fade sequence.

## Scope

Do not change duplicate detection, modal wording, hub behavior, selection,
source identity, persistence, mutation authority, database schema, import,
removal, or other archive behavior.

## Documentation Principle

> Referential attention should be the smallest visual change sufficient to
> direct human attention.

Record the fade-in, hold, fade-out, and reduced-motion behavior in the Feature
26 implementation response. Update version and changelog according to project
rules.

## Verification

Run focused Historical Archives sidebar, modal, reference, and reduced-motion
tests; Settings tests as appropriate; architecture tripwires; `flutter analyze`;
formatting; and `git diff --check`.

Commit and push if clean. Stop after this refinement. Do not begin the valid
new-folder import journey.

