# Unified Message Evidence Presentation

## Purpose

The sidebar route may differ, but message evidence should read as one coherent center-panel surface.

Contact heatmap navigation, contact-by-conversation navigation, Conversations navigation, and future search/theme routes should produce message display specs and context labels. Once the center panel renders evidence, it should use shared message presentation primitives.

## Unified Now

- `MessageEvidenceHeader` is the shared center-panel evidence header.
- `MessageEvidenceFadeOverlay` is the shared scroll-collision fade under the header.
- Conversation messages now use the same shared message tile language as timeline messages for the primary text bubble.
- Contact/global timeline headers now use the shared evidence header data shape.

## Boundaries

- Sidebar/navigation remains outside the evidence surface.
- Message specs and existing providers remain authoritative.
- Widgets render typed display data and slots; they do not query databases or derive navigation state.
- Source-specific differences are passed as data/configuration, not encoded as separate header systems.

## Future Work

- Fully converge conversation and contact message hydration into one typed evidence-row read model where practical.
- Add restrained multi-speaker presentation only after the shared evidence surface is stable.
- Consider participant indentation, initials, or quiet hue variation as semantic overlays, not as separate rendering paths.
- Preserve evidence actions, attachment display, and search/month indicators as shared slots rather than mode-specific chrome.
