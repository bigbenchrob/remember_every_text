Yes. I’d make this a **small safety-documentation slice with explicit tripwires**, not a broad cleanup.

Create and document a **hard architectural invariant** protecting the MessageLens archived attachment payload store.

This is a safety/documentation slice first.

Do not redesign attachment archival.

Do not move files.

Do not change archive format.

Do not alter import/reset/recovery behavior unless a missing safety tripwire can be added without changing semantics.

The governing correction is:

> **Archived attachment payloads are preservation data, not disposable derived data.**

Apple may evict attachment payloads from local Messages storage after MessageLens has archived them. Therefore the MessageLens archive may become the only locally available copy of a payload that was once present in Messages.

That means the archive must never be treated as a cache or as rebuildable derived state.

---

## 1. Establish the core invariant

Create a short permanent safety document under the most appropriate architectural/documentation home.

Suggested title:

`ATTACHMENT-PRESERVATION-INVARIANT.md`

Use ordinary language first, then architectural terminology.

State prominently:

> **Attachment Preservation Invariant**
>
> MessageLens archived attachment payloads are preservation data.
>
> No onboarding, reset, reimport, recovery, migration, cleanup, rebuild, test, or derived-data reset operation may delete, truncate, replace, recreate, relocate, or otherwise mutate archived attachment payloads as a side effect.
>
> Any operation that intentionally changes or removes archived attachment payloads must be explicit, preservation-aware, separately authorized, and outside ordinary rebuild/reset semantics.

---

## 2. Define the disposable-data rule

Record the companion rule:

> **Disposable-data rule**
>
> A store may be treated as disposable/rebuildable only when MessageLens can deterministically reconstruct it from authoritative data that is still available at the time of rebuild.

Then distinguish the current categories clearly:

```text
AUTHORITATIVE / REPROBEABLE SOURCES
    Messages chat.db
    Contacts databases
    currently available source attachment references/payloads

REBUILDABLE DERIVED STORES
    source-scoped import database
    Conversation Graph / working database
    indexes / projections derived from still-available source facts

PRESERVATION DATA
    MessageLens archived attachment payloads
```

Be careful with wording around Messages attachments:

- metadata/reference information may be reprobeable;
- the binary payload is not guaranteed to remain locally available;
- an archived payload must therefore never be assumed reconstructible from `chat.db` or local Messages storage.

---

## 3. Record why this matters

Document the real failure mode:

```text
Message attachment exists locally
    -> MessageLens archives payload

later:
    Apple evicts local payload
    -> Messages retains only cloud/download availability

therefore:
    MessageLens archive may now be the only local preserved copy
```

Do not claim more than the code/current evidence establishes.

The architectural conclusion is enough:

> Successful archival can convert a payload from “reconstructible from local source” into “preservation copy whose source may later disappear.”

---

## 4. Define reset semantics precisely

Update documentation language around:

```text
reset derived data
fresh start
reimport
automatic recovery
cleanup
```

so these phrases explicitly mean:

> remove only enumerated rebuildable derived stores.

They must **not** imply:

```text
delete the whole MessageLens data directory
recreate all app-owned data
clear every generated file
start from an empty folder
```

unless a future explicit destructive operation is designed and separately authorized.

Prefer the phrase:

```text
reset rebuildable derived stores
```

when precision matters.

---

## 5. Audit `MessageDataResetService`

Read the current implementation and document exactly what it is permitted to delete.

Verify that the current service preserves:

- attachment archive payloads;
- user overlays;
- preferences;
- any other preservation/user-authored stores that are intentionally out of scope.

If current behavior already preserves the archive, record that as evidence.

Do not broaden the reset implementation.

If deletion targets are explicit, document the allow-list.

If deletion is based on broad directory deletion or pattern matching that could conceivably include the archive, stop and report before changing code.

---

## 6. Audit related destructive paths

Inspect current code paths for:

- first-run reset;
- reimport;
- automatic recovery;
- explicit Reset Message Data;
- migration cleanup;
- retired-database cleanup;
- test cleanup helpers;
- any “delete data folder” or recursive cleanup helper.

For each, classify:

```text
explicitly safe
safe because it delegates to an explicit allow-list
potentially broad / requires follow-up
not relevant to archive
```

Do not redesign them in this slice.

If any current production path can delete archive payloads indirectly, stop and report immediately.

---

## 7. Add architecture/safety tripwires where practical

Add the smallest tests that make accidental future regression difficult.

Prefer tests such as:

### Reset preserves archive path

Construct a temporary production-shaped data folder containing:

```text
rebuildable import DB
rebuildable graph DB
attachment archive payload
```

Run the real derived-data reset.

Prove:

```text
import DB removed
graph DB removed
attachment archive payload still exists unchanged
```

If practical, verify file contents remain unchanged, not merely directory existence.

### Recovery preserves archive

If automatic recovery delegates to the same reset service, prove its path cannot broaden deletion scope.

### Reimport preserves archive

Prove reimport preparation removes only rebuildable stores and leaves archived payloads untouched.

### Explicit deletion allow-list

If current implementation exposes a concrete set of reset targets, assert that the attachment archive root is not among them.

Do not add brittle tests tied unnecessarily to absolute paths.

---

## 8. Add an architectural tripwire against broad deletion

Inspect whether production reset/cleanup code uses dangerous broad operations such as:

```text
delete(dataFolder, recursive: true)
delete(parentDirectory, recursive: true)
glob-delete everything except...
```

If it does not, add a simple architecture test preventing such broad deletion in the reset/recovery boundary if consistent with existing tripwire style.

If the current project architecture tests are textual/import-based and this would be awkward or brittle, document the limitation rather than inventing a complicated static analyzer.

The governing rule is:

> Destructive reset should identify what is safe to delete, not identify what is precious to spare.

In other words:

```text
ALLOW-LIST deletion
    preferred

DENY-LIST preservation
    insufficient
```

---

## 9. Preserve separation from attachment archival behavior

Do not change:

- attachment discovery;
- archive naming;
- archive deduplication;
- iCloud retrieval behavior;
- archival scheduling;
- archival pause/cancel semantics;
- archive metadata schema.

This slice establishes protection, not new archival functionality.

---

## 10. Cross-reference the invariant

Update relevant current docs so anyone working on reset/recovery sees the warning before editing code.

At minimum cross-reference from documents covering:

- onboarding reset/reimport;
- import/graph-build lifecycle;
- recovery;
- data-folder ownership;
- attachment archival.

Do not duplicate the full invariant everywhere.

Use a short warning such as:

> **Safety:** archived attachment payloads are preservation data and are outside all rebuild/reset semantics. See `ATTACHMENT-PRESERVATION-INVARIANT.md`.

---

## 11. Add the rule to developer guidance if appropriate

If there is a high-level developer or architecture rules document that future Codex sessions reliably read, add a concise hard rule there:

```text
Never treat the attachment archive as derived/rebuildable data.
Never delete it as part of onboarding, reset, reimport, recovery, migration cleanup, or tests.
```

Keep the detailed rationale in the dedicated invariant document.

---

## 12. Terminology cleanup

Search current active documentation for statements equivalent to:

```text
all MessageLens data is rebuildable
derived data can always be recreated from source
reset wipes MessageLens data and rebuilds it
```

Correct only currently authoritative docs where that wording is materially unsafe.

Do not rewrite historical records merely because their language is imprecise.

Prefer:

```text
rebuildable derived stores
```

over:

```text
MessageLens data
```

when discussing deletion/reset.

---

## 13. Documentation output

Create:

`ATTACHMENT-PRESERVATION-INVARIANT.md`

and, if this work package uses numbered records, also create:

`27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md`

or use the project’s normal convention if one document is sufficient.

Record:

1. hard invariant;
2. disposable-data rule;
3. source / derived / preservation classification;
4. attachment-eviction rationale;
5. reset allow-list principle;
6. current destructive-path audit;
7. safety tests/tripwires added;
8. any unresolved risk;
9. confirmation that no archive behavior changed.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`
- relevant onboarding/reset/recovery docs
- high-level developer guidance if appropriate.

---

## 14. Verification

Run:

- focused reset-preserves-archive tests;
- reimport/recovery preservation tests where applicable;
- relevant attachment archive tests;
- Onboarding reset tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`.

No macOS launch is required.

A build is optional unless code/test changes touch compiled production paths.

---

# Hard constraints

Do not:

- delete or move real archive files;
- run destructive tests against the production data folder;
- change archive root;
- change archival format;
- change archive naming;
- change attachment import semantics;
- add archive cleanup;
- add retention policy;
- add schema;
- broaden reset;
- treat local Messages attachment availability as guaranteed;
- assume archived payloads can be reconstructed.

If any current production reset/recovery/migration path appears capable of deleting the attachment archive, **stop immediately and report the risk before making unrelated changes.**

---

# Success criterion

After this slice, a future developer or Codex session encountering:

```text
reset
reimport
recovery
fresh start
migration cleanup
```

should be unable to reasonably conclude:

> “We can just delete the MessageLens data folder and rebuild everything.”

Instead, the architecture should make this distinction unavoidable:

```text
REBUILDABLE
    import / graph stores

PRESERVE LIKE GOLD
    archived attachment payloads
```

The attachment archive must be treated as a protected preservation repository, never as a cache.

This is worth formalizing now. A safety invariant written while everyone remembers _why_ it exists is much more valuable than discovering the distinction again after some future “helpful cleanup” has done damage.
