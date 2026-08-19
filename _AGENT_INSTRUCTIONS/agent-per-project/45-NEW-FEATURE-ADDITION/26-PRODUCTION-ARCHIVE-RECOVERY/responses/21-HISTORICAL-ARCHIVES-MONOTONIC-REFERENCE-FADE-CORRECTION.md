# Historical Archives Monotonic Reference Fade Correction

## Observed Defect

Manual review found that the gentle Historical Archives reference appeared to
fade in, drop to lower intensity, return to full intensity, and then fade out.
The animation strength itself was correctly ordered. The visual reversal came
from interpolating an opaque ordinary cartouche background toward a mostly
transparent orange endpoint.

At intermediate frames, `BoxDecoration.lerp` produced a more opaque orange
mixture than the intended low-alpha endpoint. Reversing that interpolation
during fade-out produced a second visual peak.

## Correction

The tile now derives each frame directly from the single reference-strength
value. The orange tint is alpha-composited over the ordinary cartouche
background, and the orange border is alpha-composited over the ordinary border.
The rendered background remains opaque throughout the sequence, while the
border progresses directly from its ordinary color to its reference color.

The resulting progression is monotonic:

```text
ordinary
-> increasingly visible correspondence tint
-> steady maximum tint
-> decreasingly visible correspondence tint
-> ordinary
```

The 750 ms fade-in, one-second hold, two-second fade-out, reference occurrence,
presentation-session guards, reduced-motion behavior, modal semantics, and
archive behavior are unchanged.

## Regression Coverage

Focused widget coverage now proves that:

- sampled fade-in and fade-out frames remain less intense than maximum
  correspondence;
- animated backgrounds remain fully opaque;
- maximum appearance remains the intended light orange tint;
- the final appearance is exactly ordinary cartouche chrome; and
- the existing occurrence and reduced-motion behavior still passes.

Verification completed with 10 focused widget tests, 100 Settings tests, 374
architecture tripwires, a clean `flutter analyze`, formatting, and
`git diff --check`.
