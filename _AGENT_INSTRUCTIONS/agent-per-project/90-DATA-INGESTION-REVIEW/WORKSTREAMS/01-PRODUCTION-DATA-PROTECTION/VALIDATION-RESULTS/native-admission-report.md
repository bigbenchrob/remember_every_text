# Native Admission Report

Date: 2026-07-27

The macOS Debug test target built as `MessageLens Development.app`. Seven native
tests cover:

- development claim and canonical development root;
- build/environment mismatch rejection;
- invalid production signature rejection;
- distinct production/development lock locations;
- duplicate lock-owner rejection;
- stale lock-file behavior;
- prevention of a contended claimant becoming primary.

The test target used development identity and did not launch the production
application or access the production archive.
