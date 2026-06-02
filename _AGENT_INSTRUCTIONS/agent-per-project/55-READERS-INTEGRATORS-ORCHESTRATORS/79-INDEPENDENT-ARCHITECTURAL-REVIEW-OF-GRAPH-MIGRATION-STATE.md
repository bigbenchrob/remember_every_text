79 - Independent Architectural Review of Graph Migration State

Purpose

This document records an independent architectural assessment of the source-scoped graph migration after review of:

- 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
- 71-LEGACY-DEPENDENCY-MATRIX.md
- 72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md
- 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
- 74-OVERLAY-IDENTITY-KEY-AUDIT.md
- 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
- 76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md
- 77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md
- 78-GRAPH-MIGRATION-PAUSE-AND-REMAINING-WORK.md

The goal is not to redefine the architecture.

The goal is to assess:

- what appears genuinely complete
- what remains risky
- where effort should be concentrated
- what architectural mistakes should be avoided during the final migration phase

⸻

Executive Assessment

The migration appears to have crossed an important threshold.

The project is no longer primarily engaged in architectural invention.

The major architectural questions now appear to have stable answers:

- source-scoped identity
- graph projection
- message evidence convergence
- conversation-first navigation
- overlay separation
- graph-oriented display identity

The remaining work is predominantly:

- production ownership
- lifecycle convergence
- archive/recovery identity
- overlay identity finalization
- disciplined legacy retirement

This is a significantly narrower problem than the project faced during earlier phases.

The architecture should now be evaluated less by new graph capabilities and more by reduction of legacy ownership and compatibility bridges.

⸻

Areas That Appear Architecturally Settled

Source-Scoped Identity

This appears to be the most important architectural success of the migration.

The project now possesses a coherent answer to:

What is the identity of a source-derived occurrence?

The separation between:

identity

and

meaning

appears well understood.

The architecture correctly treats:

- deduplication
- contact matching
- semantic grouping
- duplicate detection

as higher-level concerns rather than identity concerns.

This foundation appears sound.

⸻

Graph Projection

The graph is no longer a proof-of-concept.

It appears to have become the accepted working model of the application.

The remaining discussion is no longer:

Should the graph exist?

but:

How does the graph become the sole production spine?

This is a sign that the projection architecture has largely succeeded.

⸻

Message Evidence Spine

The Message Evidence Spine appears to be the strongest architectural convergence achieved during the migration.

The project no longer appears to possess separate message architectures for:

- contacts
- conversations
- search
- handles
- recovered messages

Instead, those systems now appear to be:

different evidence selectors

feeding:

one evidence presentation architecture

This is likely the largest long-term simplification achieved by the migration.

The invariant:

Pagination is not timeline navigation.

should remain aggressively protected.

⸻

Conversation-First Navigation

The graph work appears to have produced a genuine product insight rather than merely a database refactor.

Conversations now appear to function as the primary navigational entity.

Contacts, handles, search, and recovery appear increasingly to function as lenses over the communication graph.

This feels like a product-level discovery rather than an implementation detail.

⸻

Overlay Separation

The separation between:

source facts
graph facts
user intent

appears sound.

This boundary should remain rigid.

The project should continue treating overlay state as:

read-time augmentation

rather than:

projection input

Any erosion of this boundary would reduce graph reproducibility.

⸻

Primary Remaining Architectural Concern

Lifecycle Ownership

The largest remaining architectural concern is lifecycle.

The current architecture appears approximately:

Graph UI
✓
Graph Read Models
✓
Graph Identity
✓
Graph Evidence
✓
Graph Lifecycle
partially complete

The remaining question is no longer:

Can the graph represent the application?

The remaining question is:

Can the graph own the application?

Specifically:

- startup
- onboarding
- readiness
- reset
- rebuild
- incremental updates
- repair
- failure recovery

should increasingly become graph-owned concerns.

Lifecycle should be treated as the primary remaining architectural work item.

⸻

Secondary Architectural Concern

Recovery and Archive Identity

Recovered evidence has become more important than it initially appeared.

Earlier in the migration it was a niche subsystem.

It is now effectively the last significant evidence domain whose storage ownership remains legacy.

The recovered-message work appears unusually disciplined:

- repository boundary established
- parity audit performed
- graph implementation created but not wired
- real-data comparison performed

This is exactly the correct migration pattern.

The project should continue resisting pressure to cut over recovered evidence until parity explanations are complete.

The important observation is:

Every parity difference now appears explainable.

That is a stronger signal than perfect count equality.

⸻

Overlay Identity Risks

The overlay audit was an important addition to the migration effort.

A recurring risk in graph migrations is that:

source identity

and

graph identity

receive attention while:

user intent identity

is overlooked.

The project should continue treating:

- favourites
- tags
- saved messages
- manual links
- dismissals
- archive records

as first-class migration concerns.

User intent survives longer than implementation details.

Protecting user intent is therefore more important than preserving legacy schema shape.

⸻

Areas Where Caution Is Recommended

Do Not Let Compatibility Bridges Become Permanent

The project now contains several explicit compatibility bridges.

This is acceptable.

What should be avoided is:

temporary bridge
→ widely reused
→ undocumented dependency
→ permanent architecture

Every compatibility bridge should continue to have:

- an owner
- a purpose
- a removal condition

⸻

Do Not Expand Features Faster Than Ownership Converges

The architecture now appears capable of supporting substantial new functionality.

However, the greatest value may come from:

- lifecycle convergence
- archive/recovery completion
- overlay finalization
- legacy retirement

rather than feature expansion.

The project should bias toward consolidation.

⸻

Do Not Use Legacy Databases as Implicit Ground Truth

Several recent audits revealed a useful lesson.

Legacy storage and graph storage may differ because:

- graph topology improved
- graph classification improved
- user actions occurred after legacy snapshots were generated

Therefore:

difference

should not automatically be interpreted as:

graph defect

The correct question is:

Can the difference be explained?

not:

Do the counts match?

⸻

Suggested Reframing of Success

Earlier in the migration success was measured by:

new graph capability

Examples:

- graph conversations
- graph evidence
- graph search
- graph identity

Future success should increasingly be measured by:

reduction in legacy ownership

Examples:

- fewer lifecycle dependencies
- fewer compatibility bridges
- fewer legacy readiness gates
- fewer archive/recovery blockers
- fewer reasons to keep working.db alive

This is the natural final phase of a successful migration.

⸻

Recommended Near-Term Priorities

1. Complete graph lifecycle ownership.
2. Continue archive/recovery identity work conservatively.
3. Finalize overlay identity migration strategy.
4. Re-run dependency inventories periodically.
5. Retire legacy systems only after blocker closure.
6. Defer major feature expansion until ownership convergence stabilizes.

⸻

Final Assessment

The graph architecture appears to have succeeded.

The remaining work is not architectural proof.

The remaining work is operational ownership.

The project should now focus on making:

source-scoped import ledger
→ working graph
→ evidence scopes
→ shared evidence presentation
→ overlay intent

the sole production reality of the application.

The remaining challenge is not whether the architecture is capable.

The remaining challenge is ensuring that every lifecycle, recovery, archive, and user-intent pathway ultimately belongs to that architecture rather than to legacy compatibility systems.

---

Addendum - 2026-06-02 Review Against Documents 70-78

This document should be read as an independent review snapshot, not as the
latest execution-state authority.

After comparison with Documents 70-78, the overall assessment remains
directionally correct:

- the graph architecture has succeeded
- remaining work is production ownership rather than architectural proof
- lifecycle convergence is the highest-leverage remaining work
- archive/recovery identity remains the highest-risk data-integrity area
- compatibility bridges must stay named, bounded, and removable
- success should now be measured by reduction of legacy ownership

However, several observations are now stale or should be interpreted in light
of later implementation work:

1. Recovered-message presentation is no longer merely a graph candidate.

   Production recovered deleted/no-handle message views now route through
   graph-backed recovered/orphan evidence and the shared Message Evidence
   Spine. The retained legacy recovered repository and parity diagnostic were
   used as cutover gates and then retired from production presentation.

2. Recovered-message parity explanations are substantially complete.

   The important remaining recovery/archive risk is not ordinary recovered
   message presentation. It is broader archive/recovery identity: preserving
   archived attachment reachability, historical MessageLens archive imports,
   recovered Messages folder imports, and any retained legacy storage until
   source-scoped identity rules are explicit.

3. Graph lifecycle is more advanced than this review implies, but not done.

   Graph readiness, graph build control, onboarding readiness, reset handling,
   live `chat.db` monitoring, graph-first live update behavior, and graph-aware
   diagnostics are now substantially implemented. The remaining lifecycle goal
   is to make source-scoped import/projection the sole production lifecycle
   owner and retire legacy import/projection compatibility once blockers close.

4. Search, contact identity, and message evidence recommendations are largely
   satisfied for ordinary app-facing reads.

   Remaining risk is future drift and compatibility cleanup, not a broad
   unsolved ordinary-read migration.

5. No new planning domain is introduced by this review.

   The review reinforces the existing planning structure:

   - `70` for roadmap
   - `71` for dependency classification
   - `72` for choke points and blockers
   - `73` for execution checklist
   - `74` for overlay identity
   - `75` and `76` for archive/recovery identity
   - `77` for recovered parity history
   - `78` for current pause summary and remaining work

Recommended interpretation:

Use this document as a useful independent architectural validation, but use
Documents 71, 73, 77, and 78 for current implementation state.
