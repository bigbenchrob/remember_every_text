# Machine-Generated Versus Unknown Sources Evaluation

## Conclusion

The current **From unfamiliar sources** page combines three independent
dimensions:

- endpoint form: phone number, email address, business URN, or short code;
- investigation: identify an unresolved source;
- user intent: dismiss or suppress a source.

These dimensions should not be presented as one spam concept.

The feature should evolve into separate investigation lenses. However, the
initial distinction should not be **Human** versus **Machine/Spam**, because the
current data cannot establish that distinction reliably.

## Current Behavior

### Source list

The source list contains canonical sender handles that have no graph contact
link and no manual overlay link. Blacklisted handles are excluded. Dismissed
handles are separated from the active list and appear in the recoverable
Dismissed view.

### SPAM classification

The current `SPAM` classification is misleading.

The read repository calculates a junk score as follows:

- a short code adds 3 points;
- one message adds 2 points;
- two or three messages add 1 point.

The spam-candidate threshold is 3. A non-short-code source can therefore score
at most 2. In practice, the current `SPAM` badge means that the handle
syntactically resembles a short code. It does not establish that the source is
machine-generated, malicious, or unwanted.

This explains sources such as `74720`: its ten-message count is irrelevant to
the badge. Its short-code shape alone gives it the required score.

### Dismiss action

The row `X` does not delete messages or classify the source as spam. It stores
the normalized handle in overlay as dismissed. This removes it from the active
review list and places it in the recoverable Dismissed view.

There is also a separate blacklist and visibility system. Dismissal and
blacklisting currently represent different user intentions and should not be
silently merged.

## What MessageLens Can Establish

MessageLens can reliably establish:

- whether a handle is linked to a known Contact;
- whether it resembles an email address, business URN, full phone number, or
  short code;
- its imported service metadata, message count, and activity dates;
- whether the user linked, dismissed, or blacklisted it.

MessageLens cannot currently establish:

- whether the source is human or automated;
- whether an automated service is legitimate or unwanted;
- whether a source should be considered spam;
- whether every message from one source deserves the same classification.

A bank, delivery service, or authentication short code is machine-generated
but may be important. Machine-generated and spam are not synonyms.

## Recommended Information Architecture

### Identify Sources

Purpose:

> Who is this unresolved person, organization, or endpoint?

This investigation should prioritize full phone numbers, email addresses, and
business identities. Its actions should support creating a Contact, linking to
an existing Contact, and an explicitly named review-dismissal action.

It should not show red `SPAM` badges or unexplained per-row `X` buttons.

### Review Short Codes And Filtered Sources

Purpose:

> Which service-like or previously filtered sources require review?

Short codes should initially receive a neutral structural classification such
as `SHORT CODE`, not `SPAM`. Dismissed sources should remain recoverable.

Later user-confirmed classifications may distinguish useful services,
automated sources, and unwanted sources.

These should be separate lenses within the Handles feature. They do not
necessarily need to become separate top-level Messages destinations.

## Architectural Direction

Keep the following dimensions orthogonal:

- **Source kind:** phone, email, business URN, short code, or other;
- **Identity status:** linked or unresolved;
- **Classification:** unknown, person, business, service, or automated;
- **User disposition:** active, dismissed, unwanted, or blacklisted;
- **Review status:** reviewed or unreviewed.

Imported and graph-derived facts remain in graph storage. User confirmations
and dispositions belong in overlay. Read models merge them at read time.
Widgets should not calculate junk scores or decide what spam means.

This follows the Mechanical Impossibility principle. An Identify Sources read
model should admit only sources compatible with that investigation. The widget
should not receive unrelated sources and then hide, tint, or dismiss them
procedurally.

## Staged Plan

1. Replace the misleading spam heuristic with typed, neutral source-kind
   classification.
2. Give short codes a truthful presentation and focused classification tests.
3. Remove the `SPAM` badge and ambiguous `X` from ordinary source-identification
   rows.
4. Establish separate Identify and Filtered/Service review lenses.
5. Define explicit overlay dispositions before reconciling dismissal with
   blacklist visibility.
6. Add user-confirmed source classification later, treating automation signals
   as suggestions rather than facts.
7. Decide separately whether unwantedness belongs to an entire source or to
   individual messages.

## Relevant Implementation References

- `lib/features/handles/infrastructure/repositories/graph_stray_handles_read_repository.dart`
- `lib/features/handles/application/read_models/stray_handles_provider.dart`
- `lib/features/handles/application/read_models/stray_handle_summary.dart`
- `lib/features/handles/application/sidebar_cassette_spec/widget_builders/stray_handles_review_cassette.dart`
- `lib/features/handles/domain/spec_classes/handles_cassette_spec.dart`
- `lib/features/handles/infrastructure/repositories/overlay_handle_review_store.dart`
- `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`

