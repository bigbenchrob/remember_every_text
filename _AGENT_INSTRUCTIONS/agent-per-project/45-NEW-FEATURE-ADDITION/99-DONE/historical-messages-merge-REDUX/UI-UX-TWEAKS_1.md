What’s working extremely well

- Deterministic phases: The “Waiting → Running → Succeeded/Failed” progression removes all guesswork.
- Clear separation of concerns: Preflight vs Import vs Migration vs Rebuild is visually and conceptually distinct.
- Honest UI: You’re explicitly telling the user nothing has happened yet. That alone fixes half the confusion from before.
- Progress as truth surface: This doubles as a debugging console without being one.

Small improvements that will pay off immediately

1. Add a visible “Execution Gate” indicator
   Right now you mention it in text. Make it explicit:

- Status: Available / Busy / Blocked (by migration, import, reset)
- This prevents “why is the button disabled?” confusion.

2. Surface a “Preflight Complete” state
   Right now everything says “waiting for folder selection.” After selection:

- Show a clear state:
  Preflight complete — ready to import
- This becomes the user’s “go/no-go” moment.

3. Add a “Dry Run Summary” line
   Even before real import:

- “Estimated new messages: X”
- “Estimated duplicates: Y”

This becomes hugely reassuring and matches your earlier diagnostic instincts.

4. Add a lightweight log panel (optional but powerful)
   Not verbose—just a rolling line:

- “Reading archive…”
- “Normalizing 8,882 messages…”
- “Writing to ledger…”
- “Migration started…”

This gives you temporal feedback, not just state.

5. Persist last run summary in sidebar
   Your “Known Archive Sources” section becomes much more powerful if it shows:

- Last import result (success / failed)
- Last counts
- Last run time

That turns this into a reusable, inspectable system—not a one-shot tool.
