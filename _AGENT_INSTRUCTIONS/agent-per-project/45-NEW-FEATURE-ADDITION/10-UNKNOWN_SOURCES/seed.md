I think we've discovered that the current "Unfamiliar Sources" page is trying to serve two different user intentions.

One is:

    "Who is this unfamiliar person or business?"

The other is:

    "Which obvious machine-generated or spam sources should I manage or ignore?"

The per-row × button is making me question whether these two categories belong in the same view at all.

Rather than immediately redesigning the UI, I'd like you to investigate the current architecture and recommend the best information architecture.

Specifically:

1. Trace how the current feature works:
   - where the source list comes from;
   - where the SPAM classification comes from;
   - what the × button actually does;
   - how suppression is stored.

2. Determine whether the current model already distinguishes:
   - unfamiliar people;
   - businesses;
   - short codes;
   - machine-generated senders;
   - user-suppressed sources;
   - other relevant source types.

3. Recommend whether these should remain one mixed view or become separate investigation lenses.

I have a suspicion that "discover unfamiliar people" and "manage obvious spam" are fundamentally different user tasks, and that separating them may eliminate both the row-clipping problem and the need for the per-row × button.

Please do not implement anything yet.

I'd like an architectural analysis and a recommended staged plan first.
