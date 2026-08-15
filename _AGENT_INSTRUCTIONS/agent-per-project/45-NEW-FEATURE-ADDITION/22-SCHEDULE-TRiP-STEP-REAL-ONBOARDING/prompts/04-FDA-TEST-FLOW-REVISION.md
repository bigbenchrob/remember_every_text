Yes. And I think the next prompt should do two things together:

1. correct the factual probe;
2. revisit the user-facing copy **only as far as that correction legitimately changes the story**.

The key distinction is now:

```text
fresh install / first-time setup
    → user may genuinely need to grant Full Disk Access

already-configured installation
    → the useful question is simply whether MessageLens can read the protected source
```

So I would not redesign the whole onboarding flow yet. I’d ask Codex to make the probe truthful, then trim the explanatory burden where the real state allows it.

Use this:

> We have completed:
>
> `03-INACCURATE-FDA-TEST-INVESTIGATION.md`
>
> The investigation established that the current FDA probe is too weak.
>
> It currently proves only:
>
> ```text
> this process can open ~/Library/Messages/chat.db as a plain read-only file
> ```
>
> It does **not** prove that MessageLens can perform the SQLite read operation it actually requires. 03\-INACCURATE\-FDA\-TEST\-INVESTIGATION.md
>
> The next slice is to correct that factual boundary and then minimally revise the experimental onboarding copy to match the truth.
>
> Do not redesign Presence architecture.
>
> Do not add new routing.
>
> Do not change Trip or Scheduler.
>
> Do not introduce a generic Agent system.
>
> Do not integrate Presence into production onboarding yet.
>
> ---
>
> ## 1. Replace the weak probe with a truthful source-read probe
>
> The desired factual question is:
>
> > Can this process perform the protected Messages database read that MessageLens actually requires?
>
> Use the same kind of read-only SQLite access already used by source ingestion.
>
> The investigation identified the existing `SqliteChatDbSourceProbeReader` as already performing the relevant class of operation:
>
> ```sql
> SELECT MAX(ROWID) AS max_rowid FROM message;
> ```
>
> 03\-INACCURATE\-FDA\-TEST\-INVESTIGATION.md
>
> Reuse an existing appropriate source-reading boundary if ownership permits.
>
> Prefer reuse over introducing a second nearly identical SQLite probe.
>
> The corrected check should:
>
> - open `~/Library/Messages/chat.db` read-only;
> - ensure writes are impossible;
> - execute a minimal schema-specific query against `message`;
> - return success only if that operation succeeds;
> - preserve useful failure information internally;
> - avoid pretending to query the macOS Full Disk Access switch directly.
>
> Do not use the visible System Settings toggle as application truth.
>
> ---
>
> ## 2. Correct the semantics and naming
>
> Review the naming around:
>
> ```text
> MacosFullDiskAccess.canReadMessagesDatabase()
> FdaTestingAuthority.hasFullDiskAccess()
> FdaTestStep
> ```
>
> The factual layer should not claim more than it knows.
>
> The narrow authority may need to become conceptually something like:
>
> ```text
> MessagesSourceReadinessAuthority
>     canReadMessagesDatabase()
> ```
>
> or another name that accurately describes the operational fact.
>
> However, do **not** rename broadly merely for tidiness.
>
> Distinguish:
>
> ```text
> factual question:
>     can MessageLens read the protected Messages source?
>
> workflow remediation:
>     if not, Full Disk Access is the macOS mechanism the user may need to enable
> ```
>
> A Step may still represent the onboarding decision around FDA remediation if that remains the clearest workflow meaning.
>
> Document any naming change and why it is warranted.
>
> ---
>
> ## 3. Re-run the real Presence FDA experiment against the corrected probe
>
> Preserve the existing five-Trip Schedule initially.
>
> With `MessageLens Development` Full Disk Access OFF:
>
> ```text
> introduce_message_lens
> -> determine_initial_fda_state
> ```
>
> should now route based on the real SQLite read result.
>
> Expected if access is genuinely unavailable:
>
> ```text
> determine_initial_fda_state
> -> guide_user_to_grant_fda
> ```
>
> Do not change the Schedule merely to make that route happen.
>
> The point is to verify the corrected specialist fact.
>
> ---
>
> ## 4. Reassess the onboarding copy after the truthful probe exists
>
> The previous copy was written under the assumption that the workflow must explain Full Disk Access before the first test.
>
> That may now be unnecessarily heavy.
>
> Re-evaluate the first Trip from the user's point of view.
>
> Distinguish two situations:
>
> ### Situation A — source already readable
>
> If MessageLens can already read the required protected source, the user should not be forced through a long explanation of macOS privacy machinery they do not need to act on.
>
> Consider whether the introduction can simply establish:
>
> ```text
> Welcome to MessageLens.
>
> I’ll make sure I can read the local Messages and Contacts information I need.
> ```
>
> followed by the real readiness test.
>
> If the test succeeds, continue without introducing “Full Disk Access.”
>
> ### Situation B — source not readable
>
> Only when remediation is actually required should the user need an explanation such as:
>
> ```text
> MessageLens needs permission to read your Messages and Contacts data.
>
> On macOS, Apple calls this Full Disk Access.
> ```
>
> followed by clear instructions and the Settings action.
>
> This is particularly important for a fresh install, where the user genuinely needs to grant access and therefore must understand enough to act.
>
> Do not conceal the term when the user needs to find that exact System Settings category.
>
> The goal is:
>
> > introduce unfamiliar system terminology only when it becomes necessary for the user's next action.
>
> ---
>
> ## 5. Determine whether the five-Trip structure should shrink
>
> After implementing the corrected factual probe and reviewing the copy, assess whether the current Schedule still needs:
>
> ```text
> 1. introduce_message_lens
> 2. determine_initial_fda_state
> 3. guide_user_to_grant_fda
> 4. verify_fda_assignment
> 5. confirm_fda_available
> ```
>
> Do not collapse Trips merely to reduce the count.
>
> Ask:
>
> - Is each Trip still a meaningful restartable semantic chunk?
> - Does `introduce_message_lens` still need four Tell Steps?
> - Does `confirm_fda_available` still add useful user-facing value?
> - Could confirmation naturally become the opening Tell of the next onboarding concern?
> - Does removing any Trip improve restart semantics or make them worse?
>
> Propose the smallest revision justified by the real user journey.
>
> Do not implement structural Schedule changes until you have documented the reasoning.
>
> ---
>
> ## 6. Important restart constraint
>
> Preserve the proven restart seam:
>
> ```text
> guidance
> -> Open System Settings
> -> checkpoint verification Trip
> -> restart
> -> verification Trip Step 1
> -> fresh real source-read test
> ```
>
> This remains valuable.
>
> Do not add:
>
> - restart flags;
> - saved FDA Boolean;
> - current-Step persistence;
> - polling;
> - automatic retry machinery.
>
> ---
>
> ## 7. Failure semantics
>
> The investigation also concluded that future readiness should retain useful failure information rather than collapsing every problem into an unexplained Boolean. 03\-INACCURATE\-FDA\-TEST\-INVESTIGATION.md
>
> For this slice:
>
> - keep Presence routing simple;
> - do not create a generalized error-result system;
> - but preserve enough diagnostic distinction internally to tell apart cases such as:
>
> ```text
> database missing
> SQLite open denied
> query failed
> expected schema unavailable
> ```
>
> Document what is exposed to the Step and what remains specialist-only.
>
> ---
>
> ## 8. Tests
>
> Add focused tests proving:
>
> - plain file open is no longer sufficient;
> - read-only SQLite open + minimal query is required for success;
> - success routes to the present branch;
> - denied/query failure routes to remediation;
> - no write is possible through the probe;
> - no fake/cache/override is involved in the real development path;
> - Trip and Scheduler remain unchanged;
> - restart still resumes at verification;
> - topology generation remains definition-derived.
>
> Preserve existing migration and Presence tests.
>
> Run:
>
> - focused readiness/source-probe tests;
> - Presence tests;
> - architecture tripwires;
> - `flutter analyze`;
> - macOS debug build;
> - formatting;
> - `git diff --check`.
>
> ---
>
> ## 9. Documentation
>
> Create:
>
> `04-TRUTHFUL-MESSAGES-SOURCE-READINESS-IMPLEMENTATION.md`
>
> Record:
>
> 1. previous weak probe;
> 2. corrected operational question;
> 3. implementation boundary reused or introduced;
> 4. exact SQLite operation;
> 5. naming decisions;
> 6. real manual result with `MessageLens Development` FDA off;
> 7. copy simplification;
> 8. whether the five-Trip Schedule should remain or shrink;
> 9. restart implications;
> 10. anything Presence had to change.
>
> End with:
>
> **What the specialist now knows**
>
> **What the Step knows**
>
> **What the user needs to be told**
>
> ---
>
> ## Success criterion
>
> We should finish able to say:
>
> > “MessageLens does not pretend to know whether a macOS privacy switch is on. It tests whether it can actually perform the protected database read it needs. If it can, onboarding continues quietly. If it cannot, only then does the user receive the Full Disk Access explanation and instructions needed to fix it.”
>
> And once again:
>
> ```text
> Trip remains boring.
> Scheduler remains ignorant.
> ```

I think that is the right next move because it may simplify the **experience** without simplifying the factual model. The system becomes more truthful and, as a side effect, less alarming to the user.
