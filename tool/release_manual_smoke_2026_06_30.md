# MessageLens Manual Release Smoke Run - 2026-06-30

Date: 2026-06-30
Branch: Ftr.convo-topol
Commit: 7776ef87
Version: 0.2.0+18
Tester:

## Automated Verification

- [x] `tool/release_smoke.sh` passed on 2026-06-30.
- [x] `flutter build macos` passed on 2026-06-30.
- [x] Build artifact: `build/macos/Build/Products/Release/MessageLens.app`.
- [x] Built artifact bundle id verified as `com.bigbenchsoftware.MessageLens`.
- [x] Built artifact team id verified as `FQHT2QP3NE`.
- [x] Production `lib/` scan found retired DB references only in reset cleanup, database health diagnostics, and central filename constants.
- [ ] Manual real-data smoke completed.

Notes:

- Build emitted existing Xcode/device and `volume_controller` `PrivacyInfo.xcprivacy` warnings only.
- `codesign -dvvv` reported `Authority=(unavailable)` for the local build artifact. Run the production notarization/distribution path before handoff if a fully signed external release artifact is required.

## Startup And Readiness

- [ ] Launch MessageLens from a closed app state.
- [ ] App opens without a developer panel or manual import requirement.
- [ ] Readiness/status surface reports Messages access available.
- [ ] Readiness/status surface reports AddressBook access available.
- [ ] Readiness/status surface reports imported message data ready.
- [ ] Readiness/status surface reports conversation browsing data ready.
- [ ] Readiness/status surface reports overlay/user settings available.
- [ ] Readiness/status surface reports attachment archive directory available.
- [ ] Retired `macos_import.db` / `working.db` presence does not affect readiness.

Notes:

## Ordinary Browsing

- [ ] Conversations top menu loads conversation signatures.
- [ ] Selecting a conversation opens message evidence.
- [ ] Favourites display consistently where present.
- [ ] Contacts top menu loads the contact picker/sidebar.
- [ ] Known multi-handle contact opens All Messages.
- [ ] Contact heatmap coordinates with the full message range.
- [ ] By Conversation loads that contact's conversations.
- [ ] Specific-handle filter scopes heatmap and message evidence correctly.

Notes:

## Search

- [ ] Contact-scope search finds a known recent term.
- [ ] Matching terms highlight visibly.
- [ ] Match navigation scrolls to the selected match.
- [ ] Conversation-scope search scopes to matching evidence.
- [ ] Header reports match counts clearly.
- [ ] Global/search-all opens results through the shared message evidence surface.

Notes:

## Live Updates

- [ ] Plain text message appears without pressing manual import.
- [ ] Viewport does not jump when scrolled away from the end.
- [ ] New-message indicator appears when new evidence is waiting.
- [ ] Message with attachment appears after the automatic update cycle.
- [ ] Attachment evidence renders or shows a calm unavailable/pending state.

Notes:

## Attachments And Archive

- [ ] Known archived image preview renders.
- [ ] Known video attachment renders or opens correctly.
- [ ] Known URL/plugin payload preview renders once.
- [ ] Missing/unavailable attachments remain visible as evidence.
- [ ] Graph/status health explains attachment archive readiness without a release-blocking unexplained issue.

Notes:

## Historical Archives

- [ ] Historical Archives opens without developer-only controls in normal mode.
- [ ] Choosing a known historical Messages folder preflights counts and range.
- [ ] Dry run estimates are clear.
- [ ] Safe test import surfaces archive messages through normal evidence views.
- [ ] Removing the imported archive source is idempotent and does not disturb live evidence.

Notes:

## Recovery And Diagnostics

- [ ] Unfamiliar/recovered message surfaces render through shared message evidence.
- [ ] Diagnostic/status panels do not spin indefinitely.
- [ ] Report language explains warnings without graph-migration knowledge.

Notes:

## Build Readiness

- [x] `tool/release_smoke.sh` passes.
- [x] Additional focused tests for touched release areas are included in the release smoke script.
- [x] `flutter build macos` passes for this release-candidate build.
- [x] Bundle id and signing team preserve Full Disk Access continuity inputs.
- [ ] Production signing authority verified through the notarized distribution path.

Notes:

## Outcome

- [ ] Pass
- [ ] Pass with non-blocking notes
- [ ] Blocked

Blocking issues:
