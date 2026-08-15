# Presence Iteration Laboratory

## Purpose

This folder redesigns Presence from first principles through implementation.

The earlier `43-PRESENCE` architecture is historical design material. It may
offer ideas, warnings, and vocabulary, but it has no authority over this work.

No earlier concept, name, responsibility boundary, or invariant is guaranteed
to survive.

Working implementation and human comprehensibility are the current design
authority. The implementation process is now the design process.

Divergence from the earlier architecture is evidence to examine, not an error
to correct.

---

## Philosophy

We are not trying to build onboarding.

We are not trying to build archive ingestion.

We are not trying to build the final Presence engine.

We are trying to build the smallest truthful implementation.

Every iteration should be understandable in a single sitting.

## First Iteration

The first iteration contains one Journey with three ordered Steps.

Each Step is a Tell containing one statement.

Next advances to the following Tell.

After the third Tell, the Journey is Done.

It introduces no other interaction or implementation concepts.

---

## Success

An iteration succeeds when:

- it compiles;
- it is easy to explain;
- every class has one obvious responsibility;
- no concept exists "because we will need it later."

It is acceptable—even desirable—for an iteration to be discarded once it has taught us something.

Git preserves history.

Working code should contain only current ideas.

---

## Folder Structure

Each iteration receives its own folder.

Each iteration contains:

- prompts
- responses
- notes
- implementation
- observations

When an iteration is complete we either:

- promote it to the next iteration, or
- discard it completely.

Nothing is kept "just in case."

Each iteration may replace the previous implementation completely.
