import '../domain/legacy_tester_install_inspection.dart';
import '../domain/native_archive_claim.dart';

/// Proves or rejects the one supported legacy tester database generation.
abstract interface class LegacyTesterInstallInspector {
  Future<LegacyTesterInstallInspection> inspect(NativeArchiveClaim claim);
}

/// Fail-closed default for compositions that do not install the inspector.
final class RejectingLegacyTesterInstallInspector
    implements LegacyTesterInstallInspector {
  const RejectingLegacyTesterInstallInspector();

  @override
  Future<LegacyTesterInstallInspection> inspect(
    NativeArchiveClaim claim,
  ) async {
    return const LegacyTesterInstallInspection.notLegacy(
      'No legacy tester inspector is installed in this composition.',
    );
  }
}
