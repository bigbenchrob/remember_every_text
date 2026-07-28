# Static Architecture Report

Date: 2026-07-27

- `flutter analyze`: passed with no issues.
- `test/architecture/forbidden_imports_test.dart`: passed as part of the full
  suite and focused 358-test regression run.
- Persistent providers fail closed without injected archive authority.
- Physical environment roots are confined to native/bootstrap archive
  resolution.
- Protected mutation entry points use the archive mutation coordinator.
- Generated Riverpod code is synchronized.

No production resource was touched.
