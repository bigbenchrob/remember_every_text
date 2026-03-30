---
tier: project
scope: build
owner: agent-per-project
last_reviewed: 2026-03-29
source_of_truth: doc
links:
  - ./01-rust-ffi-dylib-bundling.md
  - ./02-macos-fda-grant-continuity.md
tests: []
---

# Build Considerations

This folder documents platform-specific build requirements, release packaging gotchas, and build phase configurations that are critical for the app to function correctly outside of development.

## Contents

| Doc | Topic |
|-----|-------|
| [`01-rust-ffi-dylib-bundling.md`](01-rust-ffi-dylib-bundling.md) | **🔥 CRITICAL**: How the Rust FFI dylib is bundled into the macOS app and why `flutter_rust_bridge`'s default loader fails in release builds |
| [`02-macos-fda-grant-continuity.md`](02-macos-fda-grant-continuity.md) | **🔥 MUST-READ FOR PRODUCTION BUILDS**: Keep bundle identity and release signing stable so existing macOS Full Disk Access grants carry over to new shipped builds |
| [`03-onboarding-import-debug-handoff.md`](03-onboarding-import-debug-handoff.md) | Current handoff for the environmental readiness flow, legacy import dev panel restoration, incomplete import state, and the next debugging steps for the non-starting Import button |
