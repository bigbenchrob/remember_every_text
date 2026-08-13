PATH TO FLUTTER MACOS APP: /Users/rob/Development/FlutterProjects/trips_and_steps

git remote add origin https://github.com/bigbenchrob/TripsAndSteps.git

---

We are starting a new Flutter companion app from scratch.

Work autonomously for this initial setup pass.

The goal is to leave behind a clean, buildable, documented application skeleton that is ready for deliberate feature work tomorrow.

Do not invent product features.

Do not over-architect.

Do not create speculative abstractions “for later.”

⸻

First task: inspect before creating

Before changing anything:

1. Inspect the parent development directory and nearby Flutter projects for conventions worth matching.
2. Inspect the current MessageLens project only for:
   - Flutter/Dart version;
   - linting/analyzer configuration;
   - package-management conventions;
   - Riverpod/code-generation conventions if relevant;
   - macOS/iOS project conventions;
   - naming/style patterns that are clearly reusable.
3. Do not copy MessageLens feature architecture wholesale.

This is a new app and should begin smaller.

⸻

Create the application

Create a new Flutter app in the designated folder.

If the folder/name has already been supplied in the surrounding task context, use it exactly.

If no final app name is available, stop before creating the project and document what name is required rather than inventing one.

Target the platforms actually intended for this companion app.

If the intended target is clearly macOS + iPad/iOS from existing project context, configure those and avoid adding unnecessary platform support.

⸻

Baseline technical setup

Establish only the foundations that have already earned their place:

- clean Flutter project;
- current compatible Dart/Flutter SDK constraints;
- analyzer/lint configuration;
- Riverpod only if this app is intended to use the same state-management approach;
- code generation only if required by packages actually introduced;
- sensible lib/ structure;
- basic app theme;
- one simple launch screen proving the app runs;
- deterministic tests for the initial shell.

Do not add:

- navigation frameworks unless more than one real screen exists;
- database packages unless a concrete storage requirement is already known;
- networking stacks unless a concrete protocol is already known;
- service locators;
- repositories with no data source;
- generic managers/controllers/coordinators;
- plugin systems;
- feature flags;
- telemetry;
- analytics;
- authentication;
- sync machinery;
- speculative domain models.

⸻

Project structure

Keep the initial structure intentionally small.

Something like:

lib/
main.dart
app/
app.dart
theme/
features/

is enough unless the actual requirements force more.

Do not create empty architecture directories merely to resemble a mature project.

Empty folders do not count as architecture.

⸻

Application identity

Set:

- bundle/application identifiers;
- display name;
- package name;
- macOS/iOS minimum deployment targets;

only where those values are known from the task/project context.

If any identity value is genuinely unknown and cannot be derived safely, document it as an open item rather than inventing it.

⸻

Developer ergonomics

Add:

- a concise README explaining what exists now;
- exact commands for:
  - dependency install;
  - code generation if applicable;
  - tests;
  - analyzer;
  - running on macOS;
  - running on iOS/iPad simulator if configured;
- .gitignore sanity check;
- formatting consistency;
- any VS Code settings only if they are project-level and genuinely useful.

Do not add large process documents.

⸻

Git

If this is a new repository:

- initialize Git if appropriate;
- make one clean initial commit only if doing so is consistent with the surrounding workflow and you have explicit authority to commit.

If you do not have explicit authority to commit, leave the working tree uncommitted and report the exact changes.

Never rewrite or disturb unrelated repositories.

⸻

Build verification

Before finishing, verify as much as the environment permits:

- flutter pub get
- formatting
- analyzer
- unit/widget tests
- macOS debug build
- iOS build or simulator build if the environment supports it

Record any platform-specific warnings separately from actual failures.

Do not suppress warnings merely to produce a green report.

⸻

Documentation deliverable

Create a setup report in the new project, e.g.:

docs/00-INITIAL-SETUP.md

or another appropriately simple location.

Document:

- what was created;
- project identity;
- target platforms;
- dependencies added and why each exists;
- folder structure;
- state-management choice;
- theme/bootstrap choices;
- tests;
- build verification;
- unresolved setup questions;
- things deliberately not added.

Include a short section:

Tomorrow’s obvious next step

but keep it factual. Do not design the product roadmap.

⸻

Autonomous-working rule

Work through setup problems yourself where they are mechanical:

- package conflicts;
- generated files;
- build settings;
- lint errors;
- straightforward platform configuration.

Do not stop for confirmation over routine setup decisions.

Stop only when:

- a decision would materially define product behavior;
- a required identity/name is unknown;
- credentials/signing secrets are required;
- destructive changes outside the new project would be necessary.

⸻

Core principle

This app should finish tonight looking smaller than you think it eventually needs to be.

Tomorrow we should be able to understand the entire codebase in a few minutes.

Do not create scaffolding for hypothetical future complexity.

The success criterion is:

A new developer can open the project, run it, understand every file, and begin implementing the first real feature without first deleting speculative architecture.
