### Agreed. There isno reason to touch anything on WD_ELEMENTS. It has ~1.5 TiB free; external storage is not the problem. The cleanup should be exclusively about reclaiming internal SSD space, and I’d start with the least consequential material.
I would also leave the active MessageLens build/tooling alone until we’re finished with the current validation. Give Codex this:
Proceed with a conservative cleanup of the Mac’s internal SSD only, based on the completed disk-space audit.
The purpose is to recover comfortable working space without creating another development/environment problem.
# Absolute boundary
### Do NOT delete, move, modify, deduplicate, or otherwise touchanything on /Volumes/WD_ELEMENTS.
External capacity is not a concern.
In particular, do not touch:
* DO_NOT_LOSE;
* frozen snapshots;
* onboarding profiling roots;
* Feature 26 staging clones;
* Complete Erase validation clone;
* historical archives;
* any other external file or directory.

⠀Do not even attempt to determine whether those are redundant during this cleanup.
# Also leave MessageLens itself alone for now
### We are actively validating the current MessageLens debug build.
### Do NOT touch:
* active MessageLens repository;
* MessageLens build/;
* MessageLens .dart_tool/;
* MessageLens Rust target/;
* current debug .app;
* registered git worktrees;
* /Users/rob/Library/Application Support/com.bigbenchsoftware.MessageLens;
* any MessageLens development archive;
* Apple Messages;
* Apple Contacts.

⠀We can clean MessageLens-generated artifacts after current validation is finished.
# First-pass cleanup
### Delete only the previously auditedSAFE TO DELETE — rebuildable/cache internal material below, subject to application-running checks.
### 1\. Fusion 360 logs — approximately 7 GiB
### Highest priority.
### Confirm Fusion 360 is not running.
### Delete only the audited Fusion diagnostic/log files, including the approximately 6.47 GiB log previously identified.
### Do not delete Fusion projects, designs, preferences, libraries, or user data.
### 2\. Generated artifacts from OTHER Flutter/Rust projects — approximately 7.79 GiB
### Delete only generated/rebuildable artifacts previously identified in projects other than the active MessageLens repository.
### Examples where actually audited:
* build/;
* .dart_tool/;
* Rust target/.

⠀Do not delete:
* source;
* assets;
* git repositories;
* configuration;
* lockfiles;
* project documentation.

⠀Verify each target is a generated directory before deletion.
### 3\. Xcode DerivedData and DeviceSupport — approximately 4.15 GiB
### Only if Xcode is not running.
### Delete the audited:
* DerivedData;
* DeviceSupport cache.

⠀Do not delete:
* Xcode projects;
* source;
* signing identities;
* certificates;
* provisioning profiles;
* Archives unless separately authorized.

⠀4. Chrome on-device model — approximately 3.98 GiB
### Only if Chrome is not running.
### Delete only the audited downloadable on-device model data.
### Do not touch the Chrome profile, bookmarks, history, passwords, extensions, or ordinary user data.
# 5\. Flutter SDK
## bin/cache
### — approximately 3.27 GiB
### Delete the Flutter SDK’s rebuildable/downloadablebin/cache.
Do not delete the Flutter SDK itself.
Expect the next Flutter command to reacquire/rebuild required artifacts.
### 6\. Gradle cache — approximately 2.82 GiB
### Only if no Gradle/Android build is running.
### Delete the audited~/.gradle rebuildable cache material.
Do not touch Android projects or Android SDK.
### 7\. Dart/pub cache — approximately 2.02 GiB
### Delete the audited~/.pub-cache.
Packages can be reacquired.
### 8\. Smaller unequivocal download caches
### Delete the previously audited safe internal caches where their owning applications are not running:
* Google Updater crx_cache — approximately 730 MiB;
* npm/Cargo download caches — approximately 565 MiB;
* ordinary small ~/Library/Caches items previously classified safe.

⠀Do not broaden this into generic ~/Library cleanup.
# Defer these
### Do NOT touch during this pass:
* Code Insiders User/workspaceStorage;
* VS Code workspace/session/history state;
* CoreSimulator device state;
* Android SDK;
* personal Desktop/Documents files;
* 3D PRINTING;
* dashcam files;
* AWSCode;
* Old_Messages;
* PDFs;
* Codex runtimes while this Codex session is active;
* any item classified REVIEW, KEEP, or DO NOT TOUCH.

⠀Deletion discipline
### Before deleting each category:
1. verify the exact path;
2. record its current size;
3. verify it matches the audited type;
4. check whether its owning application/process is running where relevant;
5. skip rather than force deletion if uncertain.

⠀Do not use broad cleanup utilities.
Do not delete parent directories merely because known cache children live beneath them.
Do not use wildcard deletion whose expansion has not first been inspected.
# After cleanup
### Report:
* exact paths/categories removed;
* pre-delete size of each;
* anything deferred and why;
* total space actually recovered;
* final internal-volume df -h result.

⠀Then STOP.
Do not proceed to a second cleanup pass automatically.
Do not resume Feature 28 or Complete Erase work automatically.
The user will decide whether the recovered space is sufficient.
Acceptance standard:
Recover a substantial amount of internal SSD space using only unquestionably rebuildable/downloadable material, while leaving MessageLens, personal data, development source, and the entire external WD_ELEMENTS drive untouched.
That should recover roughly 30 GiB without touching MessageLens itself, Codex’s current runtime, questionable VS Code state, personal files, or a single byte on the external drive. If that gets the internal SSD back into a comfortable range, I’d stop there rather than chasing every last cache.
