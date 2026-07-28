This version authorizes implementation while giving Codex a broad autonomous lane. It reserves only genuine production contact, irreversible changes, and architectural contradictions for your attention.

Workstream 1 — Production Data Protection

Autonomous Implementation Assignment

Agent Role

For this workstream, you are acting as the implementation engineer responsible for carrying the approved Production Data Protection architecture into the MessageLens codebase.

The investigation and architectural-design phases are complete.

Your primary responsibility is now to implement, test, validate, and document the approved boundary.

Proceed autonomously wherever the existing workstream documents provide a safe and coherent answer.

Do not return to the user merely to report routine progress, request confirmation for ordinary implementation choices, or ask questions that can be resolved through repository inspection, tests, established project conventions, or conservative engineering judgment.

⸻

Authority

You are authorized to implement the Production Data Protection workstream through the non-production implementation and validation stages described in:

90-DATA-INGESTION-REVIEW/
WORKSTREAMS/
01-PRODUCTION-DATA-PROTECTION/
CURRENT-STATE-AUDIT.md
PROPOSAL.md
QUESTIONS.md
IMPLEMENTATION-PLAN.md
VALIDATION.md

Treat these documents as the approved current direction.

The implementation plan is not immutable. If code-level discovery requires a bounded adjustment, make the smallest coherent adjustment, record it in the relevant workstream document, and continue.

Do not reopen settled architectural decisions without concrete contradictory evidence.

⸻

Primary Objective

Establish a mechanically enforced production boundary such that:

An ordinary development or test process cannot resolve, open, or mutate the production MessageLens archive.

The implementation must distinguish and correctly connect:

- build identity;
- archive environment;
- archive instance;
- canonical writable root;
- archive marker;
- native process admission;
- archive access authority;
- operation-specific mutation authority;
- recovery evidence.

Production must retain its current bundle identity, signing identity, Full Disk Access continuity, archive location, and normal synchronization behaviour.

Development and tests must fail closed rather than fall back to production.

⸻

Autonomous Working Mode

Proceed through the implementation plan in coherent slices.

For each slice:

1. Inspect the relevant code and tests.
2. Refine the slice internally if necessary.
3. Implement the smallest complete change.
4. Add or update tests.
5. Run focused tests.
6. Run broader analysis and regression checks where appropriate.
7. Fix failures attributable to the change.
8. Update the workstream documents when implementation reality changes the plan.
9. Record objective evidence.
10. Continue to the next safe slice without waiting for user confirmation.

Use repository conventions and existing ownership boundaries.

Prefer completing a coherent slice over returning with partial commentary.

⸻

Authorized Scope

You may autonomously:

- modify production code;
- modify macOS Runner and Xcode configuration;
- add development-specific bundle and product identities;
- add archive-environment and identity infrastructure;
- add native-to-Dart identity handoff;
- add archive marker models and validation;
- replace global writable-root access with admitted archive authority;
- migrate persistent database, attachment, logging, preference, and window-state paths;
- change editor and development launch configurations;
- add or evolve process-lock and mutation-authority infrastructure;
- route mutating workflows through complete operation admission;
- update tests and architecture tripwires;
- create disposable test archives and fixtures;
- run unit, widget, native, integration, static-analysis, and disposable-runtime validation;
- update implementation, validation, decision, and canonical documentation;
- update changelog and version metadata when warranted;
- make local commits if that is the established repository workflow.

Do not ask permission for routine file creation, refactoring, test additions, naming within the settled architecture, or ordinary fixes required to complete an approved slice.

⸻

Implementation Sequence

Use IMPLEMENTATION-PLAN.md as the controlling sequence.

Proceed autonomously through:

Slice 0 — Baseline And Tripwire Inventory
Slice 1 — Inert Archive Identity Domain
Slice 2 — Native Build Identity And Process Claim
Slice 3 — Dart Admission And Marker Lifecycle
Slice 4 — Complete Persistent-Store Migration
Slice 5 — Test Environment Enforcement
Slice 6 — Complete Operation Authority
Slice 7 — Checkpoint And Recovery Evidence
Slice 8 — Tooling And Production Build Hardening

You may begin Slice 9 planning and prepare its runbook, but you are not authorized to perform production archive adoption.

Slice 10 documentation promotion may proceed for truths already implemented and validated in non-production environments. Do not document unverified production adoption as complete.

⸻

Critical Activation Rule

Do not describe development isolation as active until every app-owned persistent write target derives from admitted development authority.

This includes, at minimum:

- source-scoped import database;
- Conversation graph database;
- overlay database;
- attachment archive;
- pipeline and incident evidence;
- application logs;
- SharedPreferences or equivalent persisted preferences;
- window state;
- background ingestion;
- health and readiness services that may create files;
- reset and maintenance file stores;
- support-bundle evidence.

Database separation alone is not sufficient.

There must be no intermediate state represented as safe while another persistent service can still write production state.

⸻

Production Prohibition

The active MessageLens production archive is not a test target.

Do not:

- launch an incomplete implementation against the production archive;
- create or alter a production archive marker;
- move, rename, rewrite, reset, reconcile, or restore production data;
- run production adoption;
- perform a destructive production experiment;
- use the current production data folder as a disposable fixture;
- infer permission to touch production from the fact that a code path is labelled “release” or “production.”

All runtime implementation tests must use:

- memory databases;
- temporary roots;
- synthetic fixtures;
- disposable archive instances;
- offline copies explicitly prepared for testing;
- a production-clone identity harness that does not resolve the actual production root.

Reading the code or inspecting build artifacts is permitted. Mutating the production archive is not.

⸻

Production Identity Preservation

The following production facts are non-negotiable:

Bundle identifier:
com.bigbenchsoftware.MessageLens
Display name:
MessageLens

The existing production archive location and production signing/FDA continuity must remain intact.

Ordinary Debug and Profile development should use:

Bundle identifier:
com.bigbenchsoftware.MessageLens.development
Display name:
MessageLens Development

Development release-mode testing must remain development identity, not silently inherit production authority.

An unsigned, ad hoc, or locally built artifact must not acquire production archive authority merely by carrying a production-like bundle identifier.

⸻

Fail-Closed Requirements

The implementation must stop before persistent writes when:

- native and Dart identity claims disagree;
- environment, bundle, configuration, root, or marker are incompatible;
- development encounters a production marker;
- test code attempts to resolve Application Support;
- production encounters an unmarked archive outside explicit adoption mode;
- a persistent provider is requested before archive admission;
- a requested path falls outside the admitted archive;
- a protected mutation lacks operation authority;
- production signing requirements are not satisfied;
- a configuration mistake would otherwise fall back to production.

Do not replace a fail-closed condition with a warning.

⸻

Architecture Boundaries

Production Data Protection owns:

- archive-environment identity;
- archive admission;
- archive-scoped process authority;
- canonical persistent-root authority;
- mutation-operation admission;
- recovery-evidence requirements.

It does not absorb business logic belonging to:

- source import;
- Conversation graph;
- onboarding;
- attachments;
- overlays;
- logging;
- navigation;
- health reporting.

Existing domain owners continue to perform their work after receiving valid authority.

Do not create a Production Readiness mega-service.

⸻

Operation Authority

Establish one complete, auditable mutation-admission chain.

Initially prefer conservative exclusive serialization.

Cover at least:

- live source import and graph update;
- full graph build;
- onboarding import and reimport;
- automatic recovery;
- message-data reset;
- historical archive import;
- historical archive removal;
- attachment reconciliation;
- attachment clearing;
- destructive schema or data maintenance.

The same operation owner may re-enter for nested stages.

Every protected public entry point must be represented in a testable inventory. A new or missed entry point must fail an architecture test rather than silently bypass authority.

Ordinary overlay transactions remain independent unless a maintenance operation explicitly requires overlay exclusion.

⸻

Recovery Work

Develop and validate recovery against disposable archives only.

The first acceptable checkpoint model is:

- application stopped;
- complete archive copied;
- archive marker included;
- all active databases included;
- SQLite sidecars handled explicitly;
- overlay and archive-source metadata included;
- complete attachment archive included;
- pipeline and incident evidence included;
- machine-readable inventory, sizes, and hashes;
- database integrity results;
- explicit exclusions;
- restoration into a separate disposable verification root;
- objective comparison after restore.

Do not restore over production during this assignment.

⸻

Testing And Validation

Use VALIDATION.md as the evidence contract.

Run the applicable gates as implementation proceeds rather than postponing all validation until the end.

At minimum, establish evidence for:

- static architecture;
- identity and marker compatibility;
- native process admission;
- persistent write isolation;
- test isolation;
- operation-authority coverage and conflict behaviour;
- checkpoint completeness and restoration;
- development and production artifact identity.

Instrument filesystem and provider access where useful.

The decisive proof for development isolation is not merely that expected development files exist. It is that no app-owned production path appears in the open/write manifest.

Fix regressions caused by the implementation before continuing.

Do not pre-fill successful validation reports.

⸻

Documentation Discipline

Keep the workstream package synchronized with implementation reality.

Update documents when:

- an implementation assumption proves wrong;
- a planned class or seam is replaced by a better bounded mechanism;
- a validation requirement changes;
- a previously unknown persistent writer is discovered;
- a new mutation entry point is found;
- a decision must be superseded.

Do not erase superseded reasoning. Record the correction and the reason.

Promote implemented truths into the canonical documentation owned by:

- databases;
- environment safety;
- build/signing;
- onboarding and archive;
- data import and migration;
- attachment infrastructure;
- operation authority.

Sequence 90 remains the engineering record, not the sole explanation of shipped behaviour.

⸻

Decision Policy

Resolve implementation details autonomously using this priority order:

1. hard invariants in the master plan;
2. settled decisions in QUESTIONS.md;
3. architectural boundary in PROPOSAL.md;
4. sequencing and constraints in IMPLEMENTATION-PLAN.md;
5. evidence requirements in VALIDATION.md;
6. current repository architecture and conventions;
7. the smallest conservative fail-closed implementation.

When several implementations satisfy the architecture, choose the one that:

- changes the fewest ownership boundaries;
- creates the strongest mechanical guarantee;
- is easiest to test;
- minimizes production migration;
- preserves current production identity;
- avoids speculative abstraction.

Record meaningful choices and continue.

⸻

Do Not Return For

Do not pause merely because:

- a class, file, or method name must be chosen;
- tests require ordinary repair;
- generated code must be regenerated;
- documentation needs synchronization;
- an implementation slice touches more files than expected;
- an internal abstraction differs slightly from the proposed name;
- a bounded refactor is needed to remove a bypass;
- a disposable validation fixture must be created;
- an expected lint or compile error must be fixed;
- one safe implementation approach must be selected among several reasonable options.

These are implementation responsibilities.

⸻

Mandatory Stop Conditions

Stop and report only when one of these conditions is reached:

1. The next action would mutate, adopt, move, mark, reset, reconcile, restore, or otherwise alter the real production archive.
2. The next action requires launching an incomplete or unverified build against the real production archive.
3. The production bundle identifier, signing identity, archive location, or FDA continuity would need to change.
4. Repository evidence contradicts a non-negotiable architectural invariant rather than merely an implementation detail.
5. Safe continuation would require deleting or irreversibly rewriting user-authored or production data.
6. A required test can only be performed against production and no disposable equivalent can provide meaningful evidence.
7. Credentials, signing secrets, notarization access, or external authorization unavailable to you are required.
8. The worktree contains unrelated user changes that would be overwritten or cannot safely be preserved.
9. A failed checkpoint rehearsal shows that restoration cannot reproduce a healthy disposable archive and further work risks concealing the defect.
10. Slices 0–8 and Gates 1–8 are complete, and the next step is production adoption authorization.

When stopping, provide:

- what has been completed;
- the exact blocker;
- evidence supporting it;
- the smallest decision or action required from the user;
- the safest next step.

Do not return with a broad status report when only a narrow decision is needed.

⸻

Progress Reporting

Maintain progress and evidence in the workstream files.

Do not interrupt the user after every slice.

Return only:

- at a mandatory stop condition;
- when a genuine unresolved architectural contradiction prevents safe progress;
- or when all authorized non-production implementation and validation work is complete.

At the end of the authorized work, provide one consolidated report containing:

- slices completed;
- code and configuration changed;
- tests run and results;
- validation gates passed or outstanding;
- deviations from the original plan;
- remaining risks;
- exact status of development isolation;
- exact status of production adoption;
- recommended next authorized action.

⸻

Success Condition For This Assignment

This assignment is complete when:

- Slices 0–8 have been implemented as far as repository and local tooling permit;
- Gates 1–8 have been executed or any unavailable external requirement is precisely documented;
- ordinary development cannot resolve or write the production archive;
- tests cannot resolve production storage;
- all app-owned persistent writers consume admitted environment authority;
- protected mutation entry points consume operation authority;
- checkpoint and restore have been proven using a disposable archive;
- production identity and location remain unchanged;
- production adoption has not occurred;
- canonical documentation reflects implemented and validated truths;
- the workstream is ready for a separately authorized production-adoption review.

Begin implementation now with Slice 0 and continue autonomously through the authorized scope.

This should sharply reduce routine returns while preserving a firm wall around the actual production archive.
