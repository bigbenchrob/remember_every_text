---
tier: project
scope: feature-package
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: canonical
status: implemented
links:
  - ./prompts/00-SEED.md
  - ./prompts/01-DOCUMENTATION-UPDATE.md
  - ../../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
tests:
  - test/config/theme/widgets/heatmap/activity_heatmap_color_scale_test.dart
  - test/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget_test.dart
---

# Heatmap Colour Encoding

MessageLens calendar heatmaps encode one ordered scalar value: messages per
calendar month. The implemented scale uses explicit, approximately logarithmic
bins and two deliberate perceptual regimes.

The governing invariant is **monotonic perceived magnitude**, not globally
monotonic physical luminance.

## Visual Grammar

```text
nothing → traces → sparse activity → sustained activity begins
        → increasingly intense activity
```

| Meaning | Monthly messages | Encoding |
| --- | ---: | --- |
| No activity | 0 | Empty month |
| Trace activity | 1–3 | One to three literal dots |
| Sparse activity | 4–10 | `#E8E8E8` |
| Sparse activity | 11–30 | `#CFCFCF` |
| Sparse activity | 31–50 | `#A5A5A5` |
| Sustained activity | 51–100 | `#FDE725` |
| Increasing activity | 101–300 | `#AADC32` |
| Increasing activity | 301–1K | `#5CC863` |
| Increasing activity | 1K–3K | `#28AE80` |
| Increasing activity | 3K–10K | `#2C728E` |
| Highest activity | 10K+ | `#472D7B` |

## Why The Scale Has Two Regimes

The neutral grey ramp says that messaging exists but remains sparse. Within
this regime, increasing darkness conveys increasing activity without competing
with months containing sustained conversation.

At 51 messages the scale crosses a semantic boundary from dark grey
`#A5A5A5` to bright yellow `#FDE725`. The yellow is physically lighter, but this
is intentional. The abrupt appearance of strong chromatic colour carries the
new information: sustained activity has begun. A future luminance audit must
not "correct" this boundary as though the two regimes were one uninterrupted
lightness ramp.

Within the chromatic regime, the palette is one ordered sequential scale:

```text
yellow → yellow-green → green → teal → blue → deep purple
```

Each successive active category becomes perceptually darker and stronger.
Independent light-to-dark hue ramps were rejected because a new light hue can
look weaker than the darker category below it. Orange and red high-end tiers
were also rejected: orange would reuse a hue without ordered meaning, while red
would introduce warning/error semantics and would not inherently read as more
activity than purple. Deep purple therefore remains the open-ended maximum.

## Why The Bins Are Approximately Logarithmic

Monthly message totals span several orders of magnitude and are more useful to
compare multiplicatively than additively. The difference between 10 and 100 is
closer in meaning to the difference between 100 and 1,000 than to the
difference between 100 and 200.

The implementation expresses that rationale as discrete, human-readable
thresholds. It does not calculate logarithms at runtime. Explicit bins keep the
14 px cells and legend stable, testable, and easy to interpret.

## Implementation Boundaries

- `MonthIntensity.fromMessageCount` owns semantic bin classification.
- `activityHeatmapColorForMessageCount` is the centralized palette boundary
  shared by calendar heatmaps and Conversation activity glyphs.
- The legend must enumerate the actual bins directly.
- Selection is an independent outline and must never replace the activity fill.
- Exact counts remain available through month interaction or tooltip text.

Any future palette adjustment must preserve both perceptual regimes and treat
the active colours as one coherent scale rather than tuning hues independently.
