I would like you to review both:

- 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
- 71-LEGACY-DEPENDENCY-MATRIX.md

and evaluate the migration plan in light of the current codebase state.

In particular, please consider the following observations and determine whether they are valid, partially valid, or incorrect.

Observation 1: Lifecycle Is Now the Primary Risk

The roadmap suggests that the migration has moved beyond proving graph viability and is now primarily about productionization.

The dependency matrix appears to support this.

Most message evidence presentation surfaces are already graph-backed through the Message Evidence Spine, while many remaining dependencies are concentrated in:

- onboarding
- readiness
- reset
- incremental update
- import
- migration
- change monitoring

Please assess whether lifecycle convergence is now the dominant architectural risk.

⸻

Observation 2: Search May Be the Highest-Leverage Remaining Migration

The dependency matrix identifies Search as the highest-risk remaining ordinary user-facing read.

The reasoning is that search is not merely a read model:

search
→ selects message identity
→ determines evidence scope
→ determines what the user investigates

If search still originates from legacy identity while evidence rendering is graph-native, a split-brain architecture remains.

Please evaluate:

- whether this concern is accurate
- whether Search should be considered a critical-path migration
- whether Search should move ahead of some currently planned migration work

⸻

Observation 3: Some Remaining Dependencies Are Compatibility Bridges

The matrix identifies several graph-facing repositories that still rely on legacy identity or alias resolution behavior.

Examples include:

- contact identity bridges
- handle alias bridges
- compatibility mappings between legacy participant identity and graph scopes

Please identify:

- all known bridge dependencies
- whether they are intentional
- whether any can be removed immediately
- whether some should remain until graph-native identity is fully established

⸻

Observation 4: Architectural Choke Points

The dependency matrix currently classifies dependencies as:

- ordinary reads
- lifecycle
- recovery/archive
- diagnostics
- deletion candidates

I suspect there is another useful category:

Architectural Choke Points

Meaning:

A relatively small subsystem whose migration unlocks removal of many downstream legacy dependencies.

Potential examples:

- SearchService
- Display Identity Resolver
- Contact Identity Layer
- Graph Readiness Provider
- ChatDb Change Monitor
- ConversationGraphBuildService

Please identify any architectural choke points and estimate the leverage of migrating each one.

⸻

Observation 5: Possible Reordering of Remaining Work

The roadmap currently recommends:

stabilize
→ productionize graph lifecycle
→ migrate remaining read surfaces
→ normalize identity
→ migrate recovery/archive
→ retire legacy import/projection

However, the dependency matrix suggests a possible alternative:

stabilize
→ graph-native search
→ graph-native contact identity
→ graph lifecycle productionization
→ remaining read migrations
→ archive/recovery
→ retirement

The rationale is that Search and Contact Identity may be leverage points whose migration removes or simplifies many downstream dependencies before lifecycle work is completed.

Please evaluate both sequences.

If you disagree, explain why.

If you agree, propose an updated migration order with reasoning.

⸻

Deliverable

Provide:

1. A critique of the roadmap and dependency matrix together.
2. Identification of any missing dependency categories.
3. Identification of architectural choke points.
4. Recommended migration ordering.
5. Any additional risks that are not currently represented in the roadmap or matrix.

Do not modify code.

This is an architectural review only.
