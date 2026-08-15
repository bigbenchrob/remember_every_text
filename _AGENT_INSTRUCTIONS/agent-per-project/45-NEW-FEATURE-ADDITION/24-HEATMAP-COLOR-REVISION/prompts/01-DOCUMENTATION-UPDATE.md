Codex Prompt — Update Heatmap Documentation for Perceptual Ordering

Please update the MessageLens heatmap documentation/comments so that they accurately describe the design rationale we have now settled on.

The important clarification is that the heatmap is not intended to be globally monotonic in physical lightness from the lowest nonzero count to the highest count.

It deliberately has two perceptual regimes.

1. Sparse activity: neutral encoding

The low-count region represents months where messaging occurred, but only sparsely:

- 0 = empty
- 1–3 = literal dots
- 4–10 = #E8E8E8
- 11–30 = #CFCFCF
- 31–50 = #A5A5A5

The grey ramp communicates:

activity exists, but it is sparse.

Within this region, increasing darkness represents increasing activity.

2. Sustained activity: chromatic encoding

At 51+, the heatmap deliberately crosses a semantic boundary.

The transition:

#A5A5A5 → #FDE725

is not a luminance error that should be corrected.

Although the yellow is physically lighter than the preceding dark grey, its sudden appearance as a strong chromatic colour perceptually signals:

something is happening; this month has entered a different level of activity.

This transition feels like an increase in magnitude because the emergence of colour itself carries information.

The active range then proceeds:

- 51–100: #FDE725
- 101–300: #AADC32
- 301–1K: #5CC863
- 1K–3K: #28AE80
- 3K–10K: #2C728E
- 10K+: #472D7B

Within this chromatic region, increasing activity should have a clear monotonic perceptual ordering:

yellow → yellow-green → green → teal → blue → deep purple

with the colours becoming progressively darker/stronger as message volume rises.

Correct design terminology

Please avoid documenting the governing rule simply as:

“lightness must decrease monotonically as message count increases”

because that incorrectly describes the intentional grey→yellow transition.

The better rule is:

Message totals must have a monotonic perceptual ordering.

More specifically:

- within the sparse grey regime, increasing darkness conveys increasing activity;
- crossing from grey into colour deliberately signals entry into sustained activity;
- within the active chromatic regime, increasing magnitude is reinforced by progressively darker perceptual intensity.

The complete visual grammar is therefore:

nothing → traces → sparse activity → sustained activity begins → increasingly intense activity

This distinction is important enough to document explicitly so that a future maintainer does not run the palette through a luminance check, notice that #FDE725 is lighter than #A5A5A5, and “fix” an intentional and useful perceptual boundary.

Logarithmic rationale

Please also preserve the reason for the bin spacing.

The thresholds are approximately logarithmic because message activity is meaningfully understood multiplicatively:

- the difference between 10 and 100 messages is more comparable to the difference between 100 and 1,000 than to the difference between 100 and 200.

However, the implementation uses explicit discrete bins. There is no requirement to calculate a logarithm at runtime.

The logarithmic model is a design rationale for the thresholds, not necessarily an algorithm.

Documentation goal

Update the most appropriate source comments and project documentation so that a future developer can understand:

1. why the low end is grey;
2. why colour deliberately begins abruptly at 51 messages;
3. why the grey→yellow transition is perceptually correct despite increasing luminance;
4. why the active colours form one ordered yellow→green→teal→blue→purple scale;
5. why orange/red high-end tiers were rejected;
6. why the thresholds are approximately logarithmic;
7. that the key invariant is monotonic perceived magnitude, not globally monotonic numerical luminance.

Keep the documentation concise enough to remain useful to maintainers, but preserve this rationale rather than reducing it to a list of colour constants.

Please make documentation/comment changes only where they naturally belong, avoid duplicating the same explanation in many files, and preserve unrelated worktree changes.
