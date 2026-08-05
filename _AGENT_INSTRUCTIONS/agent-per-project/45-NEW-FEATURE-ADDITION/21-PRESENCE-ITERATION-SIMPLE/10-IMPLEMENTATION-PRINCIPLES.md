# Implementation Principles

These principles override convenience.

## Principle 1

Nothing belongs in a class unless the immediately next implementation task requires it.

Not:

"We'll need that later."

Not:

"The architecture mentions it."

Only:

"The current iteration cannot function without it."

---

## Principle 2

Every abstraction must earn its existence.

The second implementation requiring a concept is usually a better justification than the first.

Prefer duplication over premature abstraction.

---

## Principle 3

Prefer simple nouns.

Journey

Step

Tell

Ask

Wait

Current Step

Finished

`Tell`, `Step`, `Wait`, `Ask`, `Next`, and `Done` are valid candidate terms.

Earlier terminology has no privileged status. Names may change between
iterations, and the clearest current name should be used.

---

## Principle 4

Every object should answer one question.

Journey

"Which Step is current, or is the Journey Done?"

Step

"What Tell does this Step contain?"

If an object answers several unrelated questions, stop and refactor.

---

## Principle 5

Every implementation concept is disposable.

When an iteration reveals a simpler model, replace the old code rather than
preserving its structure for possible future use.

---

## Principle 6

Every implementation should be explainable to another developer without reference to the architecture documents.

If explanation requires discussing five interacting objects, the iteration is probably too complicated.

---

## Principle 7

The earlier Presence architecture is historical design material, not an
implementation constraint.

It may suggest possibilities, but it cannot force a concept, name, boundary,
or invariant into an iteration.

Working implementation and human comprehensibility guide the design. Each
iteration may replace the previous implementation completely.
