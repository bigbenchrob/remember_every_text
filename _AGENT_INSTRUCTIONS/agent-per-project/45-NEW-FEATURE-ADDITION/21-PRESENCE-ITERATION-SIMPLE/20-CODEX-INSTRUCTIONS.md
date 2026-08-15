# Codex Working Agreement

The earlier Presence architecture is historical design material.

It may offer ideas, warnings, and vocabulary, but it has no authority over the
iterative implementation.

Your role is to help redesign Presence from first principles by discovering
the simplest understandable system that supports the behaviour being
implemented now.

---

Never introduce a class, interface, field, property, enum, protocol, or abstraction because it might become useful later.

Future requirements do not justify present complexity.

---

Assume that code will be deleted.

Simple code that is discarded is preferable to elegant abstractions that survive only because they are difficult to remove.

---

Prefer replacing code to preserving code.

Git remembers.

The working tree should contain only current thinking.

---

When uncertain:

choose the simpler implementation.

---

Before introducing any abstraction ask:

"What specific behaviour in the current iteration requires this?"

If no concrete answer exists:

do not introduce it.

---

When naming things:

Prefer ordinary English.

Journey

Step

Tell

Ask

Wait

Next

Finished

Only introduce architectural terminology when the implementation genuinely reaches the point where it is needed.

Earlier terminology has no privileged status. Names may change between
iterations.

---

The first iteration contains only:

one Journey

three ordered Steps

one Tell statement in each Step

Next advances to the following Tell

after the third Tell, the Journey is Done

Do not introduce any additional interaction or implementation concept.

---

At the end of every iteration report:

1. What became simpler?
2. What became more complicated?
3. Which concepts were actually required?
4. Which concepts turned out to be premature?
5. Which new implementation questions appeared?
6. Should the next iteration proceed, refactor, or discard this one?
