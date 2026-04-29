# \_AGENT_INSTRUCTIONS

This directory holds all AI and agent-related documentation.

## Structure

\_AGENT_INSTRUCTIONS/
├─ agent-instructions-shared/ # Submodule: reusable global rules (DDD, Riverpod, linting)
├─ agent-per-project/ # Local notes specific to this project

## Updating the shared rules

Only use this flow when the change truly belongs in the shared instruction library across multiple repos.

If the note is specific to this project, keep it in `AGENTS.md`, `.github/copilot-instructions.md`, or `agent-per-project/` instead of editing the submodule.

When you do need to change the shared rules, finish the full two-repo workflow before switching branches or ending work:

```bash
cd _AGENT_INSTRUCTIONS/agent-instructions-shared
git switch main
git status
git add <files>
git commit -m "Describe shared instruction change"

cd ../../
git add _AGENT_INSTRUCTIONS/agent-instructions-shared
git commit -m "Update shared agent instructions pointer"
git status
```

If `git status` in the parent repo shows only `_AGENT_INSTRUCTIONS/agent-instructions-shared` as modified, the submodule workflow is incomplete. Commit the submodule change and then commit the updated pointer in the parent repo, or reset the submodule back to the commit recorded by the parent branch before switching branches.

## Local-only notes

Everything in `agent-per-project/` stays project-specific and should never be pushed to the shared repo.
