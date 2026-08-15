# real_fda_onboarding_experiment

> GENERATED FROM PRESENCE DEFINITIONS  
> DO NOT EDIT AS ROUTING AUTHORITY

Schedule identity: `4`

Batting order: `101 -> 102 -> 103 -> 104 -> 105`

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

    T101["Trip 101<br/>introduce_message_lens<br/>4 Steps: Tell &amp;rarr; Tell &amp;rarr; Tell &amp;rarr; Tell"]
    T102{"Trip 102<br/>determine_initial_fda_state<br/>FDA test"}
    T103["Trip 103<br/>guide_user_to_grant_fda<br/>2 Steps: Tell &amp;rarr; Open FDA Settings"]
    T104{"Trip 104<br/>verify_fda_assignment<br/>2 Steps: Tell &amp;rarr; FDA test"}
    T105["Trip 105<br/>confirm_fda_available<br/>Tell: MessageLens can now read the protected Messages source. This Full Disk Access step is complete."]
    Complete["Schedule complete"]

    T101 -->|"default"| T102
    T102 -->|"Present: Trip 105"| T105
    T102 -->|"Absent: default"| T103
    T103 -->|"default"| T104
    T104 -->|"Present: default"| T105
    T104 -->|"Absent: Trip 103"| T103
    T105 -->|"default"| Complete
```
