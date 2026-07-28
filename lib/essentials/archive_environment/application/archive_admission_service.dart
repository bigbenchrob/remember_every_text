import 'package:uuid/uuid.dart';

import '../domain/archive_access_authority.dart';
import '../domain/archive_admission_exception.dart';
import '../domain/archive_environment.dart';
import '../domain/archive_identity_validator.dart';
import '../domain/archive_instance_id.dart';
import '../domain/archive_marker.dart';
import '../domain/native_archive_claim.dart';
import 'archive_marker_store.dart';

/// Admits one native process claim to one marked archive.
final class ArchiveAdmissionService {
  ArchiveAdmissionService({
    required this.validator,
    required this.markerStore,
    Uuid uuid = const Uuid(),
    DateTime Function()? currentTime,
  }) : _uuid = uuid,
       _currentTime = currentTime ?? DateTime.now;

  final ArchiveIdentityValidator validator;
  final ArchiveMarkerStore markerStore;
  final Uuid _uuid;
  final DateTime Function() _currentTime;

  Future<ArchiveAccessAuthority> admit(NativeArchiveClaim claim) async {
    validator.validateClaim(claim);

    final marker =
        await markerStore.read() ?? await _createInitialMarker(claim);

    final identity = validator.validate(claim: claim, marker: marker);
    return ArchiveAccessAuthority(identity: identity);
  }

  Future<ArchiveMarker> _createInitialMarker(NativeArchiveClaim claim) async {
    if (claim.environment == ArchiveEnvironment.production) {
      throw const ArchiveAdmissionException(
        ArchiveAdmissionFailure.missingMarker,
        'Production refuses an unmarked archive outside explicit adoption.',
      );
    }

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
