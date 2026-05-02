The current modal allows the user to become stuck in a long-running operation with no escape and no reliable indication of progress. This is not acceptable.

Required changes:

1. Add a Cancel Import button to the modal.
   - Must be available during all running states
   - Must release execution gate
   - Must stop or safely unwind the current workflow
2. Add stall detection.
   - Track last progress update timestamp per step
   - If no progress for ~60s, show “taking longer than usual”
   - If no progress for ~2–3 minutes, show “may be stuck” with Cancel option
3. Improve progress signaling for long-running steps.
   - Where possible, surface incremental signals (row counts, phase transitions, etc.)
   - Avoid static indeterminate bars for multi-minute operations
4. Enforce single running step.
   - Only one step may be “Running” at any time
   - All other steps must be Waiting or Succeeded
5. Add watchdog failover.
   - If a step exceeds a hard threshold, transition UI into a “potentially stuck” state
   - Provide explicit user choices: Wait / Cancel / Send Report

Acceptance criteria:

- User is never trapped in a modal without a way to exit
- Long-running steps provide visible forward motion or escalation messaging
- System never appears indefinitely active without explanation
- Forced app quit is no longer required to recover
