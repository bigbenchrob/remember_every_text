# truthful_messages_source_readiness_onboarding_experiment

> GENERATED FROM PRESENCE DEFINITIONS  
> DO NOT EDIT AS ROUTING AUTHORITY

Schedule identity: `5`

Batting order: `201 -> 202 -> 203 -> 204 -> 205`

## Topology Facts

- Trips: 5
- Default edges: 5
- Explicit edges: 2
- Conditional alternatives: 4
- Backward edges: 1
- Self-destinations: 0

## Generated Mermaid

```mermaid
flowchart TD

    T201["Trip 201<br/>introduce_message_lens_source_readiness<br/>2 Steps: Tell &amp;rarr; Tell"]
    T202{"Trip 202<br/>determine_initial_messages_source_readiness<br/>Messages source readiness test"}
    T203["Trip 203<br/>guide_unreadable_messages_source<br/>3 Steps: Tell &amp;rarr; Tell &amp;rarr; Open FDA Settings"]
    T204{"Trip 204<br/>verify_messages_source_readiness<br/>2 Steps: Tell &amp;rarr; Messages source readiness test"}
    T205["Trip 205<br/>confirm_messages_source_readable<br/>Tell: MessageLens can read the protected Messages source. I’m ready to continue."]
    Complete["Schedule complete"]

    T201 -->|"default"| T202
    T202 -->|"Readable: Trip 205"| T205
    T202 -->|"Unreadable: default"| T203
    T203 -->|"default"| T204
    T204 -->|"Readable: default"| T205
    T204 -->|"Unreadable: Trip 203"| T203
    T205 -->|"default"| Complete
```
