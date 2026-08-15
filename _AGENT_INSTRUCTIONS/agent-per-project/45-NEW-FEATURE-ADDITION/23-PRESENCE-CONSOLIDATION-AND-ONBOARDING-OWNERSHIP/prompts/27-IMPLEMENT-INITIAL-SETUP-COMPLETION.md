This audit is very clean, and I agree with its recommendation.

The completion screen currently answers the wrong question. It tells the user **how the pipeline behaved**—Imported, Projected, Text enriched—when what they actually need to know is simply **“Did it work, and can I use MessageLens now?”** 28\-INITIAL\-SETUP\-COMPLETION\-SURFACE\-AUDIT.md

Codex’s analysis of the metrics is especially persuasive. “Projected” is an internal architectural concept, and “Text enriched” is deliberately a subset, so perfectly healthy numbers can look alarming or inconsistent to someone who doesn’t know the implementation. 28\-INITIAL\-SETUP\-COMPLETION\-SURFACE\-AUDIT.md

The proposed replacement is also safely bounded:

```text
MessageLens is ready

Your local browsing data is prepared.

Get Started
```

That says exactly what the successful build establishes without implying that every attachment has been archived or that every source payload can forever be reconstructed. [oai_citation:2‡28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md](sediment://file_00000000424481fdbaf03f42b3c808ef)

And **Get Started** is worth keeping: it has no data-integrity role, but it provides a deliberate human transition out of the blocking setup experience. 28\-INITIAL\-SETUP\-COMPLETION\-SURFACE\-AUDIT.md

So the next implementation slice is straightforward.

Implement the single bounded completion-surface slice recommended by:

`28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md`

The goal is:

> Replace the diagnostic primary completion body with a calm, result-oriented readiness handoff.

Do not change the build operation.

Do not change completion persistence.

Do not change `Get Started` / `Done` behavior.

Do not change failure/recovery.

Do not change attachment archival.

---

## 1. Replace the completion heading

Change the shared completion surface heading from:

```text
Import Complete!
```

to:

```text
MessageLens is ready
```

This is the preferred result-oriented wording from Audit 28.

It is truthful after successful initial setup and direct reimport because the local browsing stores have been successfully built.

Do not use wording that implies archival completeness, such as:

```text
All your messages are safely copied
Everything has been archived
Your complete Messages history is preserved
```

---

## 2. Add one short readiness sentence

Add the supporting sentence:

```text
Your local browsing data is prepared.
```

Use this exact wording unless current typography or grammatical conventions reveal a concrete reason for a tiny wording adjustment.

The purpose is to connect successful pipeline completion to the human result.

Do not explain:

- source import;
- Conversation Graph projection;
- enrichment;
- joins;
- database names;
- attachment archival;
- future background updates.

---

## 3. Remove the three primary metric chips

Remove these from the ordinary completion surface:

```text
Imported
Projected
Text enriched
```

Do not replace them with another metric.

Do not invent a “messages prepared” aggregate count.

The final `ConversationGraphBuildReport` may remain available to diagnostics, logs, tests, or future secondary disclosure.

This slice removes only their **primary user-facing presentation**.

---

## 4. Retain the success icon

Keep the existing success icon and general completion layout unless removal of the metric row requires a small spacing adjustment.

Do not redesign the entire card.

The completion hierarchy should become conceptually:

```text
success icon

MessageLens is ready

Your local browsing data is prepared.

Get Started
```

or for direct reimport:

```text
success icon

MessageLens is ready

Your local browsing data is prepared.

Done
```

---

## 5. Preserve Get Started / Done distinction

Keep:

```text
first run
    -> Get Started

direct reimport
    -> Done
```

Do not change what either action does.

`Get Started` remains a human acknowledgement, not a durable commit.

The completed databases remain the durable readiness authority.

---

## 6. Completion remains transient

Do not add persistence for:

- completion acknowledgement;
- completion screen seen;
- final report;
- success UI state.

If the app closes while the completion surface is visible, the next launch should continue to derive readiness from the populated databases and open normally.

Do not replay the completion screen.

---

## 7. Preserve attachment-preservation truth

Cross-check the completion copy against:

`27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`

and the permanent attachment-preservation invariant.

The new completion surface must not imply:

- every attachment payload was available;
- every attachment has been archived;
- cloud-evicted payloads are preserved;
- all source data is now reconstructible;
- Apple Messages source data may safely be discarded.

`Your local browsing data is prepared.` is intentionally about MessageLens's browsing representation, not preservation completeness.

---

## 8. Do not delete diagnostic report data

Removing metric chips from the completion surface does **not** mean deleting or weakening:

- `ConversationGraphBuildReport`;
- import counts;
- projection counts;
- enrichment counts;
- stage timings;
- logs.

Those remain useful diagnostic evidence.

Do not redesign diagnostics in this slice.

---

## 9. First-run and direct-reimport sharing

Continue using the existing shared completion component.

Do not create separate completion widgets for first run and reimport.

The existing action-label distinction is sufficient:

```text
Get Started
Done
```

No additional reimport-specific completion prose is required in this slice.

---

## 10. Focused presentation tests

Add/update widget tests proving:

### First-run completion

Visible:

```text
MessageLens is ready
Your local browsing data is prepared.
Get Started
```

Also prove the success icon remains.

### Direct reimport completion

Visible:

```text
MessageLens is ready
Your local browsing data is prepared.
Done
```

### Diagnostic metrics absent

Prove these labels do not appear in primary completion UI:

```text
Imported
Projected
Text enriched
```

### Attachment claims absent

Prove the completion surface contains no wording equivalent to:

```text
all attachments archived
everything preserved
all messages copied permanently
```

Do not create brittle tests against arbitrary words elsewhere in the app; scope them to the completion widget.

### Existing handoff behavior

Press `Get Started` / `Done` and prove existing dismissal behavior remains unchanged.

---

## 11. Lifecycle tests remain unchanged

Do not modify successful build semantics merely to satisfy presentation tests.

Existing tests should continue to prove:

```text
controller succeeds
-> Gate complete/reimportComplete
-> completion overlay
-> dismissal
-> ordinary app
```

The report remains available even though its counters are no longer shown.

---

## 12. Documentation

Create:

`29-CALM-INITIAL-SETUP-COMPLETION-HANDOFF-IMPLEMENTATION.md`

Record:

1. previous completion presentation;
2. final heading;
3. final supporting copy;
4. metric chips removed;
5. why metrics remain diagnostic;
6. Get Started / Done behavior preserved;
7. completion durability unchanged;
8. attachment-preservation boundary;
9. tests;
10. deviations from Audit 28.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not rewrite Audit 28.

---

## 13. Verification

Run:

- focused completion-widget tests;
- Onboarding overlay tests;
- OnboardingGate completion/dismiss tests;
- relevant Conversation Graph build-controller tests;
- complete Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against the production archive.

---

# Hard constraints

Do not:

- change build semantics;
- change `ConversationGraphBuildReport`;
- remove diagnostic data;
- change completion persistence;
- add durable acknowledgement state;
- change Get Started / Done behavior;
- redesign failure/recovery;
- change attachment archival;
- add archival-completeness claims;
- modify Presence;
- add new metrics;
- create a new completion architecture.

If implementation appears to require any of those, stop and explain why.

---

# Success criterion

After a successful setup, the completion surface should answer only the questions the human actually has:

```text
Did it work?
    Yes.

Can I use MessageLens now?
    Yes.

What do I do next?
    Get Started.
```

It should no longer ask the user to interpret MessageLens’s import, enrichment, and graph-projection internals.

Stop after this slice and report before beginning any failure/recovery presentation work.

After that, the **failure/recovery surface** is the obvious next audit, because that is now the remaining place where raw errors and internal pipeline assumptions can still leak into an otherwise increasingly calm onboarding experience.
