# Architecture Review (Required)

Every PR in this refactor must include this section and answer each item
concretely. If any answer is vague or cannot be supported from the diff, the PR
is not ready.

## Semantic Ownership

- Semantic owner of the affected behavior:
- Competing writers removed or avoided:

## Boundary Purity

- Confirm that no `Widget`, widget subtree, `WidgetBuilder`, render callback,
  closure capturing UI state, `BuildContext`, `Ref`, controller, notifier,
  focus object, scroll object, or equivalent runtime behavior crosses a
  coordination boundary:

## Payload Integrity

- Transported payload types introduced or changed:
- Why they are inert and purely semantic:

## Render-Edge Discipline

- Where the widget tree is built:
- How rendering is derived from payload plus current state:

## Import and Layer Boundaries

- Confirm resolver/spec/application layers do not import widget or presentation
  layers illegally:

## Legacy Escape Paths

- Confirm this PR removes or avoids `featureComplex`,
  `_syncProjectedCenterPanel`, `_schedulePanelClearIfNoProjectedCenter`, and
  `reconcileSidebarPanels` where applicable:

## Right Panel Derivation (if applicable)

- Confirm no independent right-panel state persists:

## Recovered Timeline Integrity (if applicable)

- Confirm no recovered-only pipeline was introduced or preserved outside the
  scope definition:

## Temporary Exceptions

- `No temporary exceptions introduced`

or

- Exact exception entries added to `TEMPORARY_EXCEPTIONS.md`:

## Structural Improvement Evidence

- Measurable architectural improvement delivered by this PR:

## Regression Prevention

- Test, static check, assertion, or grep-able invariant that will fail if this
  improvement regresses:
