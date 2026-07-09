# Implementation Debt Register

This register tracks UI decisions that are intentionally deferred during the
WALK-UI process.

This is not a bug list. It records agreed or likely UI changes that should be
revisited after the relevant UI walk section is complete, or after the full UI
walk has produced enough context to batch related implementation work.

| ID | Title | Source review | Related action plan | Reason | Status | Target phase | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| UI-DEBT-001 | Delete Conversations search field | `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/search_input_box.md` | `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/search_input_box_action_plan.md` | The Conversations search field only searches sidebar metadata and does not search full message history. It appears to duplicate stronger workflows elsewhere: Contacts -> Conversations for people, and All Messages for message-content search. | Deferred | After Conversations sidebar walk, or after full UI walk | Do not remove immediately during review unless explicitly approved. Keep recorded for batch implementation. |
| UI-DEBT-002 | Add message source conversation to Working Set | `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/working_set_display_mode.md` | `95-WALK-UI-TREE/10-Messages-Sidebar/Conversations/search_input_box_action_plan.md` | The Working Set concept depends on All Messages being able to mark or collect the conversation associated with a message result. That implementation should be designed when the UI walk reaches All Messages, not during the Conversations sidebar review. | Deferred | `95-WALK-UI-TREE/10-Messages-Sidebar/All-Messages/` | Conversations sidebar may eventually display a Working Set mode, but populating that set from message results belongs to the All Messages review. |
