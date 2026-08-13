Yes. I’d keep this one tightly scoped to creating a clean, independently launched development test subject. No Presence changes unless the experiment itself later proves they’re needed.

Use this:

We have confirmed that the revised Messages source-readiness probe is truthful.

In the current VS Code / flutter run launch environment, MessageLens Development.app can successfully query ~/Library/Messages/chat.db even though its visible Full Disk Access switch is OFF.

The likely reason is the launch/TCC identity environment:

VS Code Insiders
-> Flutter debug adapter
-> flutter run
-> MessageLens Development.app

The app is ad hoc signed and may benefit from responsible-process attribution or file-specific consent.

Therefore the current debug launch is not a clean test of the FDA-denied onboarding branch.

The next task is to prepare a stably signed, directly launchable MessageLens Development build for a controlled manual experiment.

This is still development-only.

Do not modify production MessageLens signing, production FDA state, production archive behavior, Presence routing, Trip, Scheduler, or onboarding integration.

⸻

Goal

Produce a development artifact that can be launched directly from Finder or Terminal, outside VS Code and flutter run, with a stable development identity suitable for macOS TCC testing.

We want to be able to run this experiment:

MessageLens Development
launched directly
stable development signing
FDA OFF
↓
Presence source-readiness test
↓
expected: protected Messages query fails
↓
remediation Trip
↓
Open System Settings
↓
enable FDA
↓
restart if macOS requires it
↓
same Presence run resumes at verification Trip
↓
fresh source-readiness query succeeds

⸻

Read first

Review the current documentation for:

- development vs production app identity;
- build/signing configuration;
- FDA grant continuity;
- external development archive root;
- the current real FDA Presence experiment;
- the inaccurate FDA investigation;
- the truthful source-readiness implementation.

In particular, inspect the actual current macOS build settings and entitlements rather than assuming how Debug is signed.

⸻

First deliverable: current signing/identity report

Before changing anything, document the current development artifact:

- bundle identifier;
- display name;
- executable name;
- signing style;
- signing identity;
- Team ID;
- designated requirement, if any;
- entitlements;
- whether the artifact is sandboxed;
- whether Debug/Profile/Release differ;
- whether current development builds are ad hoc signed;
- whether a stable Apple Development identity is already configured somewhere but not used by flutter run.

Also document the current production identity separately so we can prove it is untouched.

⸻

Second deliverable: smallest stable-development-signing plan

Determine the smallest safe way to create:

MessageLens Development.app

with:

- the existing development bundle identifier;
- the existing development display name;
- a stable Apple Development signature;
- a real Team ID / stable designated requirement;
- the existing development archive root behavior;
- no change to the production bundle ID or production signing configuration.

Prefer existing Xcode/Flutter signing mechanisms over custom scripts if they can express this cleanly.

Do not introduce a broad build-system refactor.

⸻

Third deliverable: implement the development signing path

If the plan is straightforward and safe, implement the minimum required configuration.

The result should allow us to produce a development build outside the VS Code debug-launch chain, for example by a documented command or Xcode build path.

The artifact must remain unmistakably:

MessageLens Development

and must continue to use only the development archive.

Do not install over or replace production MessageLens.

⸻

Direct-launch requirement

Provide an exact manual procedure to:

1. build the stably signed development artifact;
2. verify its code signature;
3. verify its bundle identifier;
4. verify its Team ID / designated requirement;
5. verify it still resolves the development archive root;
6. quit any VS Code-launched MessageLens Development process;
7. launch the signed development app directly, outside VS Code;
8. confirm the running process came from the expected .app bundle.

Do not assume Finder launch is enough if Terminal verification gives better evidence; document both if useful.

⸻

TCC/FDA reset considerations

Investigate whether the existing MessageLens Development FDA entry may still be associated with the previous ad hoc identity and whether macOS TCC will treat the newly stably signed artifact as the same or a new privacy principal.

Do not automatically reset TCC or modify privacy settings.

If a TCC reset or removal/re-addition would be required for a clean experiment, document the exact reason and the narrowest user-controlled procedure.

Do not run tccutil reset automatically.

Do not reset production MessageLens.

⸻

Manual experiment procedure

Once the development artifact is ready, document this exact experiment:

A. Ensure production MessageLens is untouched.
B. Ensure MessageLens Development FDA is OFF.
C. Quit VS Code-launched development app instances.
D. Launch the stably signed development app directly.
E. Start a fresh Presence onboarding run.
F. Advance to the source-readiness test.
G. Observe whether the real SQLite query fails.

If it fails as expected:

-> confirm Presence routes to remediation
-> open System Settings
-> enable FDA for MessageLens Development
-> restart if required
-> relaunch the same directly launched development artifact
-> verify the same ScheduleRun resumes at verification
-> verify the first text is the return orientation
-> run the fresh source-readiness test
-> verify it now succeeds
-> verify the Schedule reaches confirmation

If the source-readiness test still succeeds with FDA OFF:

stop.

Do not change the probe.

Record the effective access result and investigate the remaining TCC/file-consent explanation separately.

⸻

Verification

Verify:

- production bundle ID unchanged;
- production signing unchanged;
- development bundle ID unchanged;
- development archive root unchanged;
- development artifact has stable Apple Development signing;
- direct launch does not depend on VS Code / Flutter debug adapter;
- macOS debug/development build still succeeds;
- Presence tests remain green;
- architecture tripwires remain green;
- flutter analyze clean;
- git diff --check clean.

⸻

Documentation

Create:

05-STABLE-DEVELOPMENT-TCC-TEST-IDENTITY.md

Record:

1. previous VS Code/ad hoc launch identity;
2. why it is unsuitable for controlled TCC testing;
3. current production identity;
4. current development identity;
5. implemented stable development signing configuration;
6. exact build command/path;
7. exact direct-launch procedure;
8. signature verification evidence;
9. development archive verification;
10. TCC/FDA considerations;
11. manual experiment procedure;
12. anything that remains uncertain.

End with:

What changed in build identity

What did not change in Presence

What the manual FDA experiment can now prove

⸻

Hard constraints

Do not:

- modify production signing;
- modify production bundle identity;
- modify production FDA state;
- modify production archive location;
- integrate Presence into production onboarding;
- change Trip;
- change Scheduler;
- change the source-readiness probe;
- add TCC/FDA polling;
- add a generic Agent framework;
- automatically reset TCC;
- automatically toggle privacy settings.

If stable development signing cannot be achieved safely with the current project configuration, stop and document the exact blocker rather than improvising around it.

⸻

Success criterion

We should finish with a development app that is:

MessageLens Development
stable signed identity
directly launchable
development archive only
independent of VS Code launch authority

so that we can finally perform a meaningful real-world test of:

unreadable source
-> remediation
-> grant FDA
-> restart
-> Presence resumes correctly
-> readable source

without changing Presence itself.

That should get us to a genuinely controlled experiment rather than another synthetic one.
