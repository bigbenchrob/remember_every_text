Implemented the Stage 1 Freezed refinement.

**Source files**

- [journey_identity.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/presence/model/journey_identity.dart)
- [journey_revision.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/presence/model/journey_revision.dart)
- [episode_identity.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/presence/model/episode_identity.dart)
- [activation_occurrence.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/presence/model/activation_occurrence.dart)
- [interaction_occurrence.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/presence/model/interaction_occurrence.dart)
- [provenance.dart](/Users/rob/Development/FlutterProjects/remember_every_text/lib/essentials/presence/model/provenance.dart)

Six corresponding `.freezed.dart` files were generated. Tests were updated in [presence_authority_value_objects_test.dart](/Users/rob/Development/FlutterProjects/remember_every_text/test/essentials/presence/model/presence_authority_value_objects_test.dart).

Each atomic value object now uses:

- a public validating factory;
- a library-private `._value` Freezed factory;
- a private constructor for custom diagnostics;
- generated equality and `hashCode`;
- no public `copyWith`, preventing validation bypass;
- no union `map`/`when` API, avoiding Freezed 3’s private-constructor callback issue.

`Provenance` uses a normal Freezed factory and retains generated diagnostics and `copyWith`. No serialization was added. Existing behavior was preserved; `JourneyRevision.next()` was not added because it did not previously exist or have a Stage 1 requirement.

Verification:

- Focused tests: **7 passed**
- Architecture tripwires: **352 passed**
- `flutter analyze`: **No issues found**
- No Stage 2 behavior, providers, UI, persistence, or feature dependencies were introduced.
