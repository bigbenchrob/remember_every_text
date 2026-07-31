We are ready to design the canonical Presence Episode Model.

Read:

- \_AGENT_INSTRUCTIONS/agent-per-project/43-PRESENCE/00-PRESENCE.md
- \_AGENT_INSTRUCTIONS/agent-per-project/43-PRESENCE/10-EPISODE-MODEL.md
- the local README for 43-PRESENCE
- any project architectural documents needed to understand established terminology and documentation conventions

This is an analysis task only.

Do not modify files.
Do not write Dart code.
Do not propose widgets, Riverpod providers, database schemas, or implementation plans.

The purpose of this analysis is to determine the smallest durable vocabulary of Presence Episodes that can support onboarding, archive ingestion, database maintenance, and future long-running feature work without allowing every feature to invent custom interaction machinery.

Begin from this candidate two-level model:

Technical episode families:

- Inform
- Ask
- Direct
- Work
- Wait
- Resolve

Possible semantic purposes beneath them:

Inform:

- welcome
- explanation
- transition
- completion

Ask:

- confirmation
- choice
- input

Direct:

- external action

Work:

- indeterminate
- measurable
- phased
- ambient

Wait:

- passive wait
- user-dependent wait
- restart or return

Resolve:

- recoverable problem
- decision required during active work

Do not accept this model uncritically. Test whether:

1. The six families are genuinely distinct.
2. Any can be combined without creating ambiguity.
3. Any important category is missing.
4. Semantic purpose should be a field, subtype, or some other constrained concept.
5. “External action” belongs in Direct, Ask, or Wait.
6. A decision discovered during active work requires a distinct Episode family or is simply an Ask with resumable Journey state.
7. Completion is best represented as Inform or deserves stronger semantics.
8. Ambient work is an Episode variant while Moments remain subordinate transient content.
9. The model prevents feature-specific custom screens from bypassing Presence.
10. The model can remain stable even if rendering changes substantially.

For each proposed Episode family, identify:

- its purpose
- whether user input is permitted
- what typed result it may return
- whether it can begin or continue operational work
- what durable state is required
- how completion is determined
- how it behaves across application closure or restart
- common misuse risks

Also propose the common fields that every Episode should carry. Consider, without assuming they are all necessary:

- stable episode identity
- Journey identity
- semantic purpose
- primary message
- supporting explanation
- available actions
- expected user responsibility
- resumability
- operational evidence or progress reference
- minimum presentation duration
- accessibility or announcement semantics

Keep presentation details out of the model unless they are semantically necessary.

Then test the proposed model against these scenarios:

1. “Welcome to MessageLens.”
2. Explain Full Disk Access.
3. Open System Settings and ask the user to return.
4. Relaunch and verify permission.
5. Ask the user to name an archive.
6. Scan an archive with no reliable percentage.
7. Import messages with truthful measurable progress.
8. Show fading meaningful message excerpts during import.
9. Detect that the external drive was disconnected.
10. Discover two candidate Messages databases during an active import.
11. Report that 42,614 messages were added and the history now reaches 2011.
12. Report that nothing needed to be added.

For every scenario, show:

- Episode family
- semantic purpose
- feature-supplied facts/content
- Presence-owned behaviour
- typed result, if any
- durable state needed for resumption

Conclude with:

1. Your recommended canonical Episode vocabulary.
2. Any unresolved design questions that must be decided before writing 10-EPISODE-MODEL.md.
3. A proposed document outline.
4. The strongest architectural invariants the final document should state.

Do not edit the repository.
