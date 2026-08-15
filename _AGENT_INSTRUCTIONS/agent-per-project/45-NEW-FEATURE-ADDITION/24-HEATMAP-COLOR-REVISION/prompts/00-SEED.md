Codex Prompt — Rework MessageLens Heatmap Colour Encoding

Please review and improve the colour encoding used by the MessageLens calendar heatmap.

This is not primarily a cosmetic redesign. The current implementation has exposed a perceptual problem in how monthly message totals are represented, and I want the implementation to reflect a coherent visualization principle rather than simply substituting a different collection of colours.

Background and rationale

The heatmap represents message volume per calendar month. Each month is a fixed-size cell, and colour/intensity allows the user to see the shape of their messaging history over many years at a glance.

The current implementation was built approximately as a series of separate colour tiers:

- 1–3 messages: individual dots
- 4–50 messages: grey intensities
- 51–200 messages: yellow intensities
- 201–2,000 messages: green intensities
- 2,001–8,000 messages: blue intensities
- 8,001–30,000 messages: orange → purple
- 30,000+: dark purple → red

In practice, the beginning of this scale works surprisingly well:

light grey → darker grey → yellow → darker/yellower shades → green → dark green

It feels naturally like increasing activity.

The problem appears when the scale crosses into another hue family.

For example, a light blue cell formally represents more messages than a dark green cell, but perceptually the light blue can very easily look less intense. The numerical ordering and the visual ordering have diverged.

The later proposed transitions create still more problems:

- orange is already associated with relatively modest activity earlier in the scale, so introducing orange again for extremely high activity destroys the ordered meaning of hue;
- purple followed by another purple tier makes the boundary unclear;
- purple → red does not inherently read as monotonically increasing magnitude and risks giving red an unintended warning/error meaning.

The underlying problem is that the existing design is effectively several independent light→dark colour scales placed end to end. Human perception does not automatically interpret a change of hue as an increase in a scalar quantity.

Visualization principle

This heatmap represents one ordered scalar variable: monthly message count.

It should therefore behave as a sequential colour map.

The primary visual encoding of increasing magnitude should be monotonic perceptual lightness. Hue may change as activity increases, but a higher message-count category must never appear perceptually lighter/weaker than the category immediately below it.

For the active portion of the scale, use the general perceptual progression associated with palettes such as reversed Viridis / Yellow-Green-Blue sequential schemes:

yellow → yellow-green → green → teal → blue → indigo/deep purple

while simultaneously becoming progressively darker.

Do not implement this as independent yellow, green, blue, orange, purple and red ramps.

The desired visual rule is:

As monthly message activity increases, every successive heatmap state must feel visually stronger than the one before it. Hue is secondary; perceptual lightness carries the ordering.

Why logarithmic spacing is appropriate

The data spans several orders of magnitude.

The meaningful perceptual difference between:

- 10 and 100 messages

is much closer to the difference between:

- 100 and 1,000 messages

than it is to the difference between:

- 100 and 200 messages.

So the heatmap should think about message activity multiplicatively rather than additively.

This suggests logarithmically spaced categories.

Whether the internal implementation uses natural log or log10 is unimportant after normalization; they differ only by a constant scale factor. For design and debugging, however, base-10 / decade-like reasoning is easiest for humans to understand.

I do not necessarily want a continuously interpolated colour for every possible message count. At the current 14 px cell size, discrete categories are probably clearer and easier to interpret.

The goal is therefore:

Discrete, human-readable bins whose thresholds approximate a logarithmic progression.

Preserve the special sparse states

The existing treatment of extremely low activity is useful and should remain conceptually separate from the coloured heat scale.

Proposed structure:

No activity

- 0: empty/unfilled month

Trace activity

- 1–3: individual dots

This communicates something qualitatively useful: there were literally only one, two, or three messages.

Sparse activity

Use neutral greys:

- 4–10
- 11–30
- 31–50

This communicates presence without visually competing with months containing sustained conversation.

Active message volume

Colour begins at approximately 51 messages:

- 51–100
- 101–300
- 301–1K
- 1K–3K
- 3K–10K
- 10K+

These boundaries are deliberately approximate logarithmic steps rather than equal numeric intervals.

Please inspect the actual distribution of values and existing behaviour before treating these exact thresholds as immutable, but preserve the underlying design principle. If the real dataset strongly supports a small adjustment, document the reason rather than silently changing the scheme.

Starting palette

Use these as starting/reference values rather than unquestionable constants:

- 4–10: #E8E8E8
- 11–30: #CFCFCF
- 31–50: #A5A5A5
- 51–100: #FDE725
- 101–300: #AADC32
- 301–1K: #5CC863
- 1K–3K: #28AE80
- 3K–10K: #2C728E
- 10K+: #472D7B

The active colours are intentionally similar to a reversed-Viridis progression:

yellow → green → teal → blue → purple

The important requirement is not exact hexadecimal fidelity. It is perceptual ordering.

If slight adjustments are needed for MessageLens light/dark appearance, contrast, or accessibility, make those adjustments as a coherent palette rather than tweaking individual colours independently.

Do not add a red high-end tier merely to create another category. Deep purple can represent the highest activity indefinitely.

Legend

The legend should reflect the actual encoding directly.

Preferred labels:

- 1–3
- 4–10
- 11–30
- 31–50
- 51–100
- 101–300
- 301–1K
- 1K–3K
- 3K–10K
- 10K+

Avoid unnecessary pseudo-precision. The purpose of the heatmap is rapid visual orientation across time, not reading exact monthly totals from the legend.

Exact counts can continue to be available through whatever tooltip/interaction mechanism already exists.

Selection state

A selected month must not change to a different heatmap fill colour, because doing so would temporarily destroy the meaning of the intensity encoding.

Indicate selection independently, for example with an appropriate:

- border;
- stroke;
- inset outline;
- focus treatment;
- or equivalent existing MessageLens selection affordance.

The fill colour should continue to mean only one thing:

message volume.

Code/documentation cleanup

Please find the existing implementation and comments describing the old tier system.

Replace comments such as:

- “yellow intensities”
- “green intensities”
- “blue intensities”
- “orange → purple”
- “dark purple → red”

with documentation of the actual visualization model.

The code should make clear that:

1. 0 is an empty month.
2. 1–3 are literal sparse-message dot states.
3. 4–50 use neutral greys.
4. 51+ uses logarithmically spaced categories.
5. The active colours form one sequential perceptual scale.
6. Increasing counts must correspond to monotonically increasing visual intensity.

Please avoid scattering raw colour literals throughout the widget if the architecture already provides, or would cleanly support, a centralized heatmap palette/scale definition.

Before modifying code

First inspect:

- the current heatmap widget;
- where its thresholds are defined;
- where colours are defined;
- legend generation;
- selected-month rendering;
- light/dark mode handling;
- tests covering the heatmap;
- any other heatmaps or timeline visualizations that may share this encoding.

Determine whether this colour system is intentionally shared elsewhere before changing common abstractions.

Do not casually alter another visualization merely because it happens to reuse a helper.

Implementation goal

Make the smallest coherent architectural change necessary so that the heatmap has a single understandable visual grammar:

none → trace → sparse → increasingly active

with the active region progressing approximately:

yellow → green → teal → blue → deep purple

and never visually appearing to decrease as the numerical value increases.

Validation

Please add or update appropriate tests for the mapping between message counts and visual categories.

At minimum, test important boundaries:

- 0
- 1
- 3
- 4
- 10
- 11
- 30
- 31
- 50
- 51
- 100
- 101
- 300
- 301
- 1,000
- 1,001
- 3,000
- 3,001
- 10,000
- 10,000

Tests should verify semantic category selection rather than unnecessarily coupling themselves to incidental widget internals.

Also verify that selection does not replace the message-intensity fill encoding.

Visual review

After implementation, please provide a concise summary containing:

1. what the old mapping did;
2. what changed;
3. where the palette and thresholds now live;
4. any threshold changes you made from the proposal above and why;
5. any dark-mode/accessibility considerations;
6. tests added or changed;
7. files modified.

If the repository has an established screenshot/golden-test mechanism for this widget, use it where appropriate. Do not introduce an elaborate new visual-testing infrastructure solely for this task.

Scope discipline

This task is about the information encoding of the calendar heatmap, not a general redesign of the surrounding panel.

Please do not opportunistically change typography, layout, explanatory copy, spacing, navigation behaviour, or unrelated timeline components unless a very small change is directly necessary to support the new scale.

The desired result is that a user can look across fourteen years of tiny squares and intuitively read:

almost nothing → a little → moderate → a lot → enormous

without needing to consciously decode which hue family happens to come next.
