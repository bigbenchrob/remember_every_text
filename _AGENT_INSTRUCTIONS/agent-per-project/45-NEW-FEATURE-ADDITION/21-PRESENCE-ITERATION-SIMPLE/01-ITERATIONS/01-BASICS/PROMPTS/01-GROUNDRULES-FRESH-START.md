# Presence Iteration: Complete Design Reset

## Status of Previous Presence Work

The earlier Presence architecture documents are not normative for this work.

They are a record of planning, hypotheses, vocabulary, and possible system shapes developed before implementation.

They may be consulted as historical design material.

They do not constrain:

- naming;
- class structure;
- data models;
- control flow;
- responsibility boundaries;
- persistence;
- interaction types;
- terminology;
- implementation architecture.

No previous Presence concept is guaranteed to survive.

This includes, without limitation:

- Journey;
- Episode;
- Inform;
- Ask;
- Await;
- Work;
- Moment;
- Coordinator;
- Renderer;
- Presentation Policy;
- Completion Authority;
- Provenance;
- Foreground Journey;
- Active Episode.

These are candidate ideas, not canonical entities.

The iterative implementation process is now the design process.

## Fresh-Start Rule

Do not preserve a previous concept merely because it appears in the earlier documentation.

Do not rename a simple implementation concept to match earlier vocabulary.

Do not treat divergence from the earlier architecture as an error.

Use the clearest name for the system being built now.

Examples:

- `Tell` may be used instead of `Inform`.
- `Step` may be used instead of `Episode`.
- `Wait` may be used instead of `Await`.
- A future implementation may prove that none of these abstractions is needed.

The question is not:

> How do we faithfully implement the previous Presence architecture?

The question is:

> What is the simplest understandable system that supports the behaviour we are implementing now?

## Design Authority

Working implementation and human comprehensibility now have priority.

Earlier architectural documents may:

- suggest possibilities;
- provide warnings;
- offer vocabulary;
- help explain a problem.

They may not:

- dictate the model;
- force an abstraction;
- prohibit a simpler term;
- require preservation of an invariant;
- compel implementation of a boundary that has not earned its existence.

If working implementation contradicts an earlier design assumption, record the contradiction and continue evaluating the implementation.

Do not silently bend the implementation to preserve the old model.

## Iteration Rule

Each iteration begins from the smallest possible behaviour.

Only concepts required by that behaviour may be introduced.

No class, field, method, enum, interface, table, service, or abstraction may be added because it is expected to become useful later.

A concept must answer:

> What specific requirement in this iteration fails without it?

If there is no concrete answer, do not add it.

## Naming Rule

Prefer the shortest ordinary word that accurately describes the current behaviour.

Examples:

- Journey
- Step
- Tell
- Ask
- Wait
- Next
- Done

Do not substitute earlier architectural terminology merely for consistency.

Names may change between iterations as understanding improves.

## Deletion Rule

Code and concepts are disposable.

Git preserves the history.

When an iteration reveals a better decomposition:

- replace the old code;
- remove obsolete terminology;
- delete abstractions that no longer help;
- do not retain files “just in case.”

## Scope of the First Iteration

The first iteration proves only this:

- one Journey;
- three ordered Steps;
- one Step kind: Tell;
- each Tell displays one statement;
- the user advances to the next Tell;
- after the third Tell, the Journey reports that it is done.

It does not implement or claim:

- the previous Episode model;
- persistence;
- restart safety;
- provenance;
- concurrency;
- foreground arbitration;
- feature operations;
- Moments;
- questions;
- waiting;
- validation;
- production readiness.

## Review Standard

An iteration succeeds when a human can understand the complete model and control flow in one sitting.

If explaining the iteration requires reconstructing a web of synchronized state, the implementation is too complex.

The goal is not to preserve earlier architecture.

The goal is to discover a better one.
