# Journey

This document is an AI-readable transcription of `Journey.ooutline`.

It is a working conceptual outline, not canonical architecture. Items described
as alternatives, concerns, or questions remain unsettled. The original
OmniOutliner document remains the visual source.

## Major Divisions

### Data

- Database: `JourneyDefinitionStore`
- Repository: `DriftJourneyRepository`

### Data-Class Entities

- Journey: `journey.dart`
- Step: `step.dart`
  - A Step type maps to the widget that presents that Step type.

### Presentation View

- Journey frame: what the page sees.
- Step advancement:
  - Explicit control, such as a Next button.
  - Automatic step advancement:
    - timed;
    - triggered by background events.
- Current Step widget:
  - selected through the relationship between a Step type and its presentation
    widget.

### Presentation View Model

The original outline records three possible approaches and observations about
their tradeoffs. It does not select one as final.

#### Stateful Widget

- A StatefulWidget can own presentation state directly.
- Working concern: this may become complicated quickly for a Journey containing
  multiple Steps.

#### View Model With Providers

- A provider-backed view model could own presentation state.
- Working concern: this may also become complicated quickly.

#### Modular Step View/View-Model Components

- Each Step component is independent and does not know or care about other
  Steps.
- A Step component reports its relevant state upward, for example:
  - "I'm waiting."
  - "I'm done."
- Open question from the original outline: does a Step component need anything
  from the master Journey presentation, or does the master merely load the Step
  and receive waiting/finished reports?

## Current Implementation Context

The current PRESENCE-ITERATION-SIMPLE laboratory deliberately begins with the
smallest option: a page-local StatefulWidget owns `JourneyProgress`. That
choice proves the present three-Step Tell Journey without resolving the broader
presentation-view-model alternatives recorded above.
