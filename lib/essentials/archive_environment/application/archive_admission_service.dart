import 'package:uuid/uuid.dart';

import '../domain/archive_access_authority.dart';
import '../domain/archive_admission_exception.dart';
import '../domain/archive_environment.dart';
import '../domain/archive_identity_validator.dart';
import '../domain/archive_instance_id.dart';
import '../domain/archive_marker.dart';
import '../domain/legacy_tester_install_inspection.dart';
import '../domain/native_archive_claim.dart';
import '../domain/resolved_archive_identity.dart';
import 'archive_marker_store.dart';
import 'legacy_tester_install_inspector.dart';

/// Admits one native process claim to one marked archive.
final class ArchiveAdmissionService {
  ArchiveAdmissionService({
    required this.validator,
    required this.markerStore,
    this.legacyTesterInstallInspector =
        const RejectingLegacyTesterInstallInspector(),
    Uuid uuid = const Uuid(),
    DateTime Function()? currentTime,
  }) : _uuid = uuid,
       _currentTime = currentTime ?? DateTime.now;

  final ArchiveIdentityValidator validator;
  final ArchiveMarkerStore markerStore;
  final LegacyTesterInstallInspector legacyTesterInstallInspector;
  final Uuid _uuid;
  final DateTime Function() _currentTime;

  Future<ArchiveAccessAuthority> admit(NativeArchiveClaim claim) async {
    validator.validateClaim(claim);

    final existingMarker = await markerStore.read();
    if (existingMarker == null &&
        claim.environment == ArchiveEnvironment.production &&
        !await markerStore.canCreateInitialMarker()) {
      final inspection = await legacyTesterInstallInspector.inspect(claim);
      switch (inspection.kind) {
        case LegacyTesterInstallInspectionKind.legacyTesterInstall:
          // This non-persistent identity permits only the compatibility gate
          // and its explicitly authorized legacy-root deletion. It never
          // grants current-store access or ordinary archive mutation.
          return ArchiveAccessAuthority(
            identity: ResolvedArchiveIdentity(
              environment: claim.environment,
              buildIdentity: claim.buildIdentity,
              archiveInstanceId: ArchiveInstanceId(_uuid.v4()),
              canonicalRootPath: claim.canonicalRootPath,
              bundleIdentifier: claim.bundleIdentifier,
              productName: claim.productName,
            ),
            mode: ArchiveAccessMode.legacyTesterInstallDetected,
          );
        case LegacyTesterInstallInspectionKind.notLegacy:
          throw ArchiveAdmissionException(
            ArchiveAdmissionFailure.nonEmptyUnmarkedArchive,
            'Production found an unmarked archive that is not the supported '
            'legacy tester generation: ${inspection.reason}',
          );
        case LegacyTesterInstallInspectionKind.inspectionFailed:
          throw ArchiveAdmissionException(
            ArchiveAdmissionFailure.legacyTesterInspectionFailed,
            inspection.reason,
          );
      }
    }

    final marker = existingMarker ?? await _createInitialMarker(claim);

    final identity = validator.validate(claim: claim, marker: marker);
    return ArchiveAccessAuthority(identity: identity);
  }

  Future<ArchiveMarker> _createInitialMarker(NativeArchiveClaim claim) async {
    if (!await markerStore.canCreateInitialMarker()) {
      throw const ArchiveAdmissionException(
        ArchiveAdmissionFailure.nonEmptyUnmarkedArchive,
        'An initial marker may be created only in an empty archive root.',
      );
    }

    final marker = ArchiveMarker(
      formatVersion: ArchiveMarker.currentFormatVersion,
      environment: claim.environment,
      archiveInstanceId: ArchiveInstanceId(_uuid.v4()),
      createdAtUtc: _currentTime().toUtc(),
    );
    await markerStore.createInitialMarker(marker);
    return marker;
  }
}
