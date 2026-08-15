---
tier: project
scope: presence-onboarding-target-ownership
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: proposal
links:
  - ./01-CURRENT-OWNERSHIP-INVENTORY.md
  - ./03-FIRST-MECHANICAL-MOVES.md
  - ./04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md
  - ./09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md
tests: []
---

# Target Ownership Proposal

> **Status:** The generic Boolean Test portion of this proposal has been
> implemented and verified. See the
> [post-Slice-4 consolidation audit](09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md)
> for current architecture and remaining debt.

## Governing Boundary

```text
Presence owns execution grammar.
Onboarding owns onboarding meaning.
Specialists own factual expertise and operations.
The development harness owns observation and substitution controls.
```

Physical persistence does not change that boundary. One `presence.db` may
store definitions and runs for Onboarding, Archive Ingestion, and future
workflows while Presence remains ignorant of what those workflows mean.

## Implemented Composition Boundary

Onboarding now owns its stable opaque Agent IDs, the concrete Messages and
Contacts Test Agents, and the function that contributes their bindings.
Application composition combines those contributions into one immutable
resolver. Presence receives that resolver and cannot discover which workflow
or specialist supplied an Agent.

## Presence

Permanent Presence should know:

- Schedule, Trip, and Step definitions;
- definition composition and occurrences;
- Scheduler execution;
- default and explicit routing;
- Trip-boundary checkpointing and restart;
- Schedule runs;
- append-only execution trace;
- generic persistence and reconstruction mechanisms.

Presence should not know:

- Messages or Contacts readiness;
- Full Disk Access;
- System Settings;
- onboarding copy or blocker order;
- Address Book discovery;
- `chat.db` SQL;
- remediation meaning.

## Onboarding

Permanent Onboarding should own:

- which readiness fact is checked and when;
- onboarding Schedule, Trip, and Step composition;
- all onboarding copy;
- which outcome leads to which remediation;
- which specialist capability is requested;
- onboarding-specific adapters and provider composition;
- eventual production integration with the existing onboarding gate, when
  separately approved.

The current required-sources Schedule now has this physical home. Production
`OnboardingGate` has not yet been replaced by it.

## Specialist Agents

A specialist Agent performs domain-specific work or establishes a fact. It
must remain ignorant of Schedule routing.

Current candidates are:

```text
ChatDbSourceProbeReader
    establishes whether the required protected Messages query succeeds

AddressBookFolderRepository
    establishes whether viable local Contacts sources can be discovered/read

MacosFullDiskAccess
    supplies the existing protected-source check and opens FDA Settings
```

Onboarding may adapt these capabilities. It must not copy their SQL, path,
schema, or platform knowledge.

## Development Harness

The experiment feature should continue to own:

- manual Step completion and `Run Again`;
- source substitution controls;
- generated Mermaid;
- topology projection;
- execution trace display;
- live Schedule visualization;
- provisional Presence presentation.

None of these is runtime authority.

## Remaining Architectural Question

The Boolean-test questions have been resolved by generic `TestStep`, opaque
`TestAgentId`, workflow-owner binding contributions, and immutable resolver
composition. The remaining known domain-neutrality pressure is
`OpenFdaSettingsStep` and its narrow `FdaSettingsOpeningAuthority`. Whether it
becomes a generic operation or another interaction contract is intentionally
outside the completed Boolean-test slices.
