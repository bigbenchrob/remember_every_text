You’re right. “Build working messages” is quantifiable and should not be pretending to progress with an indeterminate bar.

For that step, the migrator knows, or can cheaply know:

- total canonical message rows to project
- number inserted/processed so far
- current phase elapsed time

So the modal should show something like:

Build working messages
Status: Running · 2m 13s
Processed: 42,318 / 80,935 messages
[██████████░░░░░░░░░░] 52%

If the current implementation does one giant SQL INSERT INTO ... SELECT ..., then it cannot emit row-by-row progress. But that is a design choice. For long user-visible migrations, the migrator should either:

- process in chunks and report progress after each chunk, or
- split the SQL into measurable phases and report real counts between phases

Tell the agent:

Progress Reporting Correction: Build Working Messages Must Be Determinate

The “Build working messages” migration step is a quantifiable operation and should not use fake/indeterminate progress.

Required behavior:

- Before the step starts, count total source rows to project.
- During the step, report processed/inserted rows.
- Show determinate progress:
  - Processed X / Y messages
  - percentage
  - elapsed time
- Update progress at chunk boundaries.

If the current migrator performs one giant SQL insert/select, refactor only this step to use chunked migration or measurable sub-batches. Do not fake progress.

Acceptance criteria:

- “Build working messages” never shows an indeterminate progress bar.
- The user can tell whether progress is advancing.
- If progress count does not change for 60+ seconds, the stall warning should be based on real lack of progress, not just elapsed time.
- The modal must not imply progress when no records have actually advanced.

This is especially important because a static bar plus “taking longer than usual” makes the user think the app is hung. A real X / Y count would make the state understandable
