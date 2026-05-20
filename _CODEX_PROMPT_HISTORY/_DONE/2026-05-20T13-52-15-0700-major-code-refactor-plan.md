---
created_at: 2026-05-20T13:52:15-07:00
title: "MAJOR CODE REFACTOR PLAN"
tags: []
source: codex_prompt_history.html
---

# MAJOR CODE REFACTOR PLAN

## Prompt

```text
Now that the r-i-o and SS architecture has proven itself to my satisfaction, we will embark on a careful and incremental  codebase refactor that incorporates this architecture into the legacy code. The first step should be to create a document that lays out the principles of how this refactor should be pursued. Here is an initial plan: 

Yes. This should be formalized before more migration work.

I’d create:

_AGENT_INSTRUCTIONS/agent-per-project/55-READERS-INTEGRATORS-ORCHESTRATORS/66-SS-MIGRATION-STRATEGY.md

Core rule:

Do not build lib/new/.
Do not create feature_ss folders.
Add new architecture spines beside legacy essentials.
Add SS implementations inside existing feature folders behind provider switches.

Best next step: ask Codex to create that doc only.

Use this:

Create a short architecture document:
_AGENT_INSTRUCTIONS/agent-per-project/55-READERS-INTEGRATORS-ORCHESTRATORS/66-SS-MIGRATION-STRATEGY.md
Purpose:
Formalize how the source-scoped architecture should migrate into the existing app without creating a parallel “new app” tree.
Key rules to document:
1. Do NOT create lib/new/.
2. Do NOT create parallel feature folders like:
   - search_ss/
   - contacts_ss/
   - messages_ss/
3. Add new architecture spines beside legacy essentials, for example:
   - essentials/db_importers/              legacy
   - essentials/source_scoped_import/      new import spine
   - essentials/db/                        legacy
   - essentials/conversation_graph/        new working graph spine
4. Existing features remain existing features:
   - features/search/
   - features/contacts/
   - features/conversations/
5. Where a legacy feature needs SS behavior, add implementation variants inside the existing feature folder, for example:
   features/search/application/
     search_provider.dart
     legacy/
     ss/
6. Public providers should be the switch points.
   Feature callers should depend on stable public providers, not directly on legacy or SS implementations.
7. The migration model is:
   one app,
   progressively replaced data spines,
   provider-level switches,
   feature-by-feature adoption.
8. SS graph principles:
   - ss_id is canonical working-row identity
   - import_ss = source facts/provenance
   - working_ss = lean app graph
   - working graph relationships use ss_id endpoints
   - GUIDs are metadata/bridge fields, not identity
Keep the document concise and directive.
No code changes.
Report only the file added.
```
