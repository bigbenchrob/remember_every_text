# Conversation Shape Sandbox

This is a disposable standalone HTML/CSS/JS prototype for exploring MessageLens conversation-shape visualization. It is isolated from production Flutter, Drift, Riverpod, app architecture, and databases.

Open `index.html` directly in a browser. No build step, server, dependency install, or network access is required.

## What It Shows

The left pane models the MessageLens sidebar role: navigation, controls, exploration, and conversation-shape recognition. Each conversation row includes a compact signature instead of a plain metadata list.

The right pane models the center panel role: the selected resolved message stream only.

Synthetic deterministic archetypes are generated for:

- Pharmacy thread
- Close friend thread
- Sports team group chat
- Reality TV group
- Family logistics
- Dormant/revived thread
- Attachment-heavy planning thread

## Controls

- **Selected visual mode**: Switches signatures between trace, heatmap, participant rails, hybrid, or pixel mode. Pixel mode represents every month in the shared synthetic timeline as one compact left-to-right row, with color intensity based on message volume for that month.
- **Theme**: Switches between dark and light prototype color schemes.
- **Seed**: Regenerates the same archetypes with deterministic variation. The same seed produces the same data every reload.
- **Palette saturation**: Reduces or increases participant and signature color intensity.
- **Participant color mode**: Turns non-me participant accent colors on or off in message bubbles.
- **Avatar badge**: Shows or hides participant initial badges in the message stream.
- **Indentation step**: Controls horizontal offset between participants in group conversations.
- **Max indentation levels**: Caps how many participant offset levels can appear.
- **Border/accent strength**: Adjusts bubble and selected-row accent visibility.
- **Message density/spacing**: Changes vertical spacing in the resolved message stream.
- **Signature compression**: Compresses or expands the sidebar signature height and timeline bin count.
- **Trace smoothing**: Smooths temporal density traces for broader or sharper activity shapes.
- **Blur amount**: Applies blur to the conversation browser and message stream to test whether structure remains readable.
- **Grayscale mode**: Removes color from the conversation browser and message stream to test recognition without hue.

## Design Questions To Evaluate

- Can the sparse pharmacy thread be recognized without reading the label?
- Does the close friend thread read as long-running and organically irregular?
- Do game-day sports bursts remain distinct under blur and grayscale?
- Does the reality TV thread show a periodic weekly cadence?
- Does the dormant/revived thread visibly separate old activity, silence, and recent revival?
- Are group participants readable without creating a rainbow UI?
