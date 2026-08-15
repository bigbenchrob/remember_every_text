# Artifact Identity Report

Date: 2026-07-27

- Debug build artifact:
  `build/macos/Build/Products/Debug/MessageLens Development.app`.
- Development artifact passed `verify_macos_archive_identity.sh` as
  development.
- Five verifier tests cover matching production metadata, development artifact
  rejection by production packaging, matching development metadata, packaging
  integration, and production-only recursive signature verification.
- `tool/build_and_notarize.sh` invokes the verifier with production metadata
  before packaging.

A final signed/notarized production artifact has not been created or adopted in
this workstream phase.
