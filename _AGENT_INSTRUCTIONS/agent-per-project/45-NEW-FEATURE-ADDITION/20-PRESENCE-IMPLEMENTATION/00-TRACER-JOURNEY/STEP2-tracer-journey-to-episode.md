Implement Stage 2 of the Presence tracer bullet: the pure semantic engine.

Read:

- the complete canonical Presence documentation;
- 45-NEW-FEATURE-ADDITION/20-PRESENCE-IMPLEMENTATION/project-outline.md;
- the completed Stage 1 Presence authority value objects and tests;
- existing project conventions for Freezed domain models and pure-Dart tests.

Stage 1 is complete. Do not revisit or broaden it except for imports or a narrowly necessary correction.

This task must remain entirely free of:

- Flutter;
- Riverpod;
- providers;
- Coordinator logic;
- Renderer contracts;
- widgets;
- persistence;
- feature operations;
- application integration.

The purpose is to prove that immutable Journey truth deterministically derives exactly one truthful Episode.

---

## Architectural goal

Implement a pure relationship:

Tracer Journey state
-> exactly one Presence Episode

The derivation must have:

- no side effects;
- no storage access;
- no rendering knowledge;
- no transition authority;
- no dependency on onboarding or any MessageLens feature;
- no dependence on previously rendered Episode state.

The same Journey state must always derive the same logical Episode identity and semantics.

---

## Permanent Presence models

Under:

lib/essentials/presence/model/

introduce only the minimum reusable models required for this tracer slice.

Likely concepts include:

- JourneyLifecycle;
- PresenceEpisode;
- InformEpisode;
- Ask<T>;
- constrained Inform purpose;
- constrained Ask purpose;
- the minimum common Episode semantics required by the canonical architecture.

Follow the canonical documents rather than this candidate list if terminology differs.

Use Freezed consistently where it is appropriate for immutable data models.

Preserve validation through public validating factories when a value object has invariants. Do not expose generated construction paths that bypass those invariants.

Do not implement:

- Work;
- Await;
- Moments;
- automatic progression;
- Journey controls;
- Renderer output;
- operational evidence.

Do not add speculative placeholders for those concepts.

---

## Tracer-owned Journey meaning

Under:

lib/features/presence_tracer/domain/

implement the tracer client’s immutable Journey state and semantic positions.

The tracer feature, not Presence core, owns:

- tracer copy;
- the sequence of semantic positions;
- the accepted display name;
- the meaning of each position;
- deterministic mapping from tracer state to canonical Presence Episodes.

The minimum sequence is:

1. Ongoing: welcome pending.
2. Ongoing: explanation pending.
3. Ongoing: name required.
4. Completed: completion summary remains to be discharged.
5. Completed: foreground summary discharged, if a state is required to represent that fact.

Do not implement transitions between these states yet. Tests may construct the states directly.

---

## Completion ordering

Preserve the canonical ordering:

typed name has already been accepted
->
Journey lifecycle is Completed
->
Inform / completion is derived

The completion Episode communicates terminal truth.

It must not be responsible for making the Journey Completed.

---

## Episode identity

Define deterministic Episode identity for each logical interaction obligation.

The same logical Journey state must derive the same Episode identity across repeated derivation.

Examples of distinct obligations include:

- welcome;
- explanation;
- name question;
- completion summary.

Do not generate random Episode identity during derivation.

Do not introduce ActivationOccurrence or InteractionOccurrence here. Those belong to activation and Renderer interaction, not pure Episode derivation.

---

## Inform

Implement only the Inform semantics needed by the tracer:

- welcome;
- explanation;
- completion.

The model should contain only canonical semantic information required at this stage, such as:

- Episode identity;
- semantic purpose;
- primary communication;
- optional supporting explanation;
- whether acknowledgement is required.

Do not include layout, widget, timing, color, animation, or navigation instructions.

---

## Ask<T>

Implement the generic semantic model for Ask<T> only as far as needed to preserve the canonical typed contract.

The first tracer use is Ask<String>.

It should express:

- Episode identity;
- input purpose;
- the domain question;
- a typed response contract or minimum structural constraints;
- any supporting explanation;
- the fact that one typed response is required.

Do not use:

- dynamic;
- Map<String, Object?> as an interaction payload;
- generic callback fields;
- widget builders;
- text controllers;
- feature validation services.

Keep draft input out of the semantic model.

---

## Derivation contract

Create a narrow pure contract under:

lib/essentials/presence/contracts/

representing deterministic Episode derivation from Journey state.

Avoid a speculative workflow registry or universal engine.

The tracer implementation may implement that contract from its own feature folder.

The permanent Presence subsystem must not import the tracer feature.

The dependency direction must remain:

presence_tracer
-> Presence model and derivation contract

Presence
-> no feature implementation

---

## Tests

Add focused pure-Dart tests proving:

1. Every valid tracer Journey state derives exactly one Episode.
2. Welcome derives Inform / welcome.
3. Explanation derives Inform / explanation.
4. Pending name derives Ask<String> / input.
5. A Completed Journey with an undischarged summary derives Inform / completion.
6. The completion Episode reflects an already Completed lifecycle.
7. Repeated derivation of the same state yields equal Episode semantics and the same Episode identity.
8. Different logical obligations have different Episode identities.
9. The accepted name appears only where canonically appropriate.
10. Derivation has no dependency on previously derived or rendered state.
11. Presence core imports no tracer feature files.
12. No Work, Await, Moment, Renderer, Coordinator, Riverpod, Flutter, persistence, or application integration enters this stage.

Also add negative tests for any invariants introduced by the new immutable models.

---

## Scope discipline

Do not implement Journey advancement.

Do not implement acknowledgements.

Do not accept a typed response.

Do not increment JourneyRevision.

Do not create Provenance for Renderer interactions.

Do not create ActivationOccurrence or InteractionOccurrence during derivation.

Do not add a store.

Do not begin Stage 3.

This stage answers only:

“Given authoritative Journey state, what Episode is truthful now?”

---

## Completion report

After implementation, report:

1. Every handwritten file created or modified.
2. Every generated Freezed file created.
3. The final model and folder structure.
4. How deterministic Episode identity is derived.
5. How the generic Ask<T> contract remains typed without speculative abstraction.
6. Tests and analyzer results.
7. Any point where the canonical architecture could not be represented cleanly.
8. Confirmation that no Stage 3 or UI work was introduced.
