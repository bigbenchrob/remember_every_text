/// Outcome of the bounded pre-source-scoped tester-install inspection.
enum LegacyTesterInstallInspectionKind {
  legacyTesterInstall,
  notLegacy,
  inspectionFailed,
}

/// Read-only evidence result used only to decide restricted startup routing.
final class LegacyTesterInstallInspection {
  const LegacyTesterInstallInspection._({
    required this.kind,
    required this.reason,
  });

  const LegacyTesterInstallInspection.legacyTesterInstall()
    : this._(
        kind: LegacyTesterInstallInspectionKind.legacyTesterInstall,
        reason:
            'The exact pre-source-scoped tester database generation exists.',
      );

  const LegacyTesterInstallInspection.notLegacy(String reason)
    : this._(kind: LegacyTesterInstallInspectionKind.notLegacy, reason: reason);

  const LegacyTesterInstallInspection.failed(String reason)
    : this._(
        kind: LegacyTesterInstallInspectionKind.inspectionFailed,
        reason: reason,
      );

  final LegacyTesterInstallInspectionKind kind;
  final String reason;

  bool get provesLegacyTesterInstall =>
      kind == LegacyTesterInstallInspectionKind.legacyTesterInstall;
}
