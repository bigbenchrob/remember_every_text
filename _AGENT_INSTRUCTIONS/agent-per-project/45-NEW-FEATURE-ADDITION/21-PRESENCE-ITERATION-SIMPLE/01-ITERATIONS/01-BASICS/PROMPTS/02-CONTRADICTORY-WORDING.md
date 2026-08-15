The iteration laboratory now has one controlling premise:

This work is redesigning Presence from first principles through implementation.

The earlier 43-PRESENCE architecture is historical design material only. It is not authoritative for this work.

A contradiction remains in:

45-NEW-FEATURE-ADDITION/21-PRESENCE-ITERATION-SIMPLE/00-START-HERE.md

That document currently says or implies that the earlier Presence architecture remains authoritative.

Correct that contradiction now.

This is a documentation-only task.

Do not modify application code.

Do not begin Iteration 1 implementation.

Do not revise the historical 43-PRESENCE documents.

---

## Required correction

Update the root orientation documents in:

45-NEW-FEATURE-ADDITION/21-PRESENCE-ITERATION-SIMPLE/

so they consistently establish:

- the previous Presence architecture is historical design material;
- it may be consulted for ideas, warnings, and vocabulary;
- it has no authority over the iterative implementation;
- no earlier concept, name, boundary, or invariant is guaranteed to survive;
- working implementation and human comprehensibility are the current design authority;
- the implementation process is now the design process;
- divergence from the previous architecture is evidence to examine, not an error to correct;
- each iteration may replace the previous implementation completely.

Remove or rewrite any statement that says or implies:

- the earlier Presence architecture remains authoritative;
- iterations must faithfully realize it;
- canonical Presence terminology must be preserved;
- earlier invariants must be partially implemented once touched;
- divergence requires justification or correction.

---

## Iteration 1 model

Ensure the orientation documents describe the first iteration only as:

one Journey
contains three ordered Steps

each Step is a Tell
containing one statement

Next
advances to the following Tell

after the third Tell
Journey is Done

Do not introduce:

- Episode;
- Inform;
- Await;
- Coordinator;
- Renderer;
- Provenance;
- identity objects;
- persistence;
- extensibility;
- generic protocols;
- future Step types.

---

## Terminology

State explicitly that:

- Tell, Step, Wait, Ask, Next, and Done are valid candidate terms;
- previous terms have no privileged status;
- names may change between iterations;
- the clearest current name should be used.

---

## Consistency review

Inspect all root orientation and rule documents in the iteration folder.

Correct any remaining sentence that conflicts with the fresh-start premise.

Do not broaden the documents beyond what is required to remove contradictions.

---

## Report

After editing:

1. List every document modified.
2. Quote the contradictory wording that was removed or replaced.
3. Summarize the controlling premise now stated consistently.
4. Confirm that the 43-PRESENCE historical documents were not modified.
5. Confirm that no implementation work began.
