# required_sources_readiness_onboarding_experiment

> GENERATED FROM PRESENCE DEFINITIONS  
> DO NOT EDIT AS ROUTING AUTHORITY

Schedule identity: `6`

Batting order: `301 -> 302 -> 303 -> 304 -> 305 -> 306 -> 308 -> 309 -> 310 -> 311 -> 307`

## Topology Facts

- Trips: 11
- Default edges: 5
- Explicit edges: 12
- Conditional alternatives: 12
- Backward edges: 4
- Self-destinations: 0

## Generated Mermaid

```mermaid
flowchart TD

    T301["Trip 301<br/>required_sources_introduction<br/>2 Steps: Tell &amp;rarr; Tell"]
    T302{"Trip 302<br/>required_sources_initial_messages_readiness<br/>Test: onboarding.messages-source-readable"}
    T303["Trip 303<br/>required_sources_messages_remediation<br/>3 Steps: Tell &amp;rarr; Tell &amp;rarr; Open FDA Settings"]
    T304{"Trip 304<br/>required_sources_messages_verification<br/>2 Steps: Tell &amp;rarr; Test: onboarding.messages-source-readable"}
    T305{"Trip 305<br/>required_sources_contacts_readiness<br/>Test: onboarding.contacts-source-readable"}
    T306["Trip 306<br/>required_sources_contacts_remediation<br/>3 Steps: Tell &amp;rarr; Tell &amp;rarr; Fixed destination"]
    T308{"Trip 308<br/>determine_messages_source_history_sufficiency<br/>Test: onboarding.messages-source-history-sufficient"}
    T309{"Trip 309<br/>guide_sparse_or_unsynced_messages_source<br/>3 Steps: Tell &amp;rarr; Tell &amp;rarr; Choice"}
    T310{"Trip 310<br/>classify_messages_source_failure<br/>Test: onboarding.messages-source-access-denied"}
    T311["Trip 311<br/>guide_unavailable_messages_source<br/>2 Steps: Tell &amp;rarr; Fixed destination"]
    T307["Trip 307<br/>required_sources_confirmation<br/>Tell: MessageLens can read the local Messages and Contacts information it needs."]
    Complete["Schedule complete"]

    T301 -->|"default"| T302
    T302 -->|"True: Trip 305"| T305
    T302 -->|"False: Trip 310"| T310
    T303 -->|"default"| T304
    T304 -->|"True: default"| T305
    T304 -->|"False: Trip 310"| T310
    T305 -->|"True: Trip 308"| T308
    T305 -->|"False: default"| T306
    T306 -->|"explicit: Trip 305"| T305
    T308 -->|"True: Trip 307"| T307
    T308 -->|"False: Trip 309"| T309
    T309 -->|"Re-check: Trip 308"| T308
    T309 -->|"Import Anyway: Trip 307"| T307
    T310 -->|"True: Trip 303"| T303
    T310 -->|"False: Trip 311"| T311
    T311 -->|"explicit: Trip 302"| T302
    T307 -->|"default"| Complete
```
