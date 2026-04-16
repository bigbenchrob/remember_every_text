import '../../db_importers/domain/entities/db_import_result.dart';
import '../../db_migrate/domain/entities/db_migration_result.dart';

enum OnboardingEnvironmentState {
  permissionBlocked,
  sourceUnavailable,
  sourceSparseOrUnsynced,
  importFailed,
  migrationFailed,
  readyToImport,
  ready,
}

enum OnboardingBlockerKind {
  none,
  fullDiskAccessMissing,
  messagesDatabaseMissing,
  addressBookUnavailable,
  sourceDataSparseOrUnsynced,
  importFailed,
  migrationFailed,
  importDatabaseMissing,
  workingDatabaseMissing,
  importDatabaseEmpty,
  workingDatabaseEmpty,
}

enum OnboardingSyncPlausibility {
  unknown,
  likelySyncedOrLocallyAvailable,
  likelySparseOrUnsynced,
}

enum OnboardingFailureFreshness { unknown, today, older }

class OnboardingDatabaseProbe {
  const OnboardingDatabaseProbe({
    required this.path,
    required this.exists,
    required this.readable,
    this.sizeBytes,
    this.lastModified,
    this.rowCount,
  });

  final String path;
  final bool exists;
  final bool readable;
  final int? sizeBytes;
  final DateTime? lastModified;
  final int? rowCount;

  bool get hasData => (rowCount ?? 0) > 0;
}

class OnboardingEnvironmentReport {
  const OnboardingEnvironmentReport({
    required this.state,
    required this.blockerKind,
    required this.syncPlausibility,
    required this.messagesDatabase,
    required this.addressBookDatabase,
    required this.importDatabase,
    required this.workingDatabase,
    required this.hasFullDiskAccess,
    this.sourceAttachmentCount,
    this.addressBookFailureMessage,
    this.lastImportResult,
    this.lastMigrationResult,
    this.lastImportFailureRecordedAt,
    this.lastMigrationFailureRecordedAt,
    this.usingPersistedImportFailure = false,
    this.usingPersistedMigrationFailure = false,
    this.shouldResetAppDatabasesBeforeImport = false,
    this.resetAppDatabasesReason,
  });

  final OnboardingEnvironmentState state;
  final OnboardingBlockerKind blockerKind;
  final OnboardingSyncPlausibility syncPlausibility;
  final OnboardingDatabaseProbe messagesDatabase;
  final OnboardingDatabaseProbe? addressBookDatabase;
  final OnboardingDatabaseProbe importDatabase;
  final OnboardingDatabaseProbe workingDatabase;
  final bool hasFullDiskAccess;
  final int? sourceAttachmentCount;
  final String? addressBookFailureMessage;
  final DbImportResult? lastImportResult;
  final DbMigrationResult? lastMigrationResult;
  final DateTime? lastImportFailureRecordedAt;
  final DateTime? lastMigrationFailureRecordedAt;
  final bool usingPersistedImportFailure;
  final bool usingPersistedMigrationFailure;
  final bool shouldResetAppDatabasesBeforeImport;
  final String? resetAppDatabasesReason;

  bool get hasPopulatedAppDatabases {
    return importDatabase.hasData && workingDatabase.hasData;
  }

  bool get hasImportFailure {
    return lastImportResult != null && !lastImportResult!.success;
  }

  bool get hasMigrationFailure {
    return lastMigrationResult != null && !lastMigrationResult!.success;
  }

  String? get importFailureMessage {
    if (!hasImportFailure) {
      return null;
    }

    return lastImportResult!.error;
  }

  String? get migrationFailureMessage {
    if (!hasMigrationFailure) {
      return null;
    }

    return lastMigrationResult!.error;
  }

  DateTime? get latestFailureRecordedAt {
    return lastMigrationFailureRecordedAt ?? lastImportFailureRecordedAt;
  }

  OnboardingFailureFreshness importFailureFreshness({DateTime? now}) {
    return _failureFreshness(lastImportFailureRecordedAt, now: now);
  }

  OnboardingFailureFreshness migrationFailureFreshness({DateTime? now}) {
    return _failureFreshness(lastMigrationFailureRecordedAt, now: now);
  }

  OnboardingFailureFreshness _failureFreshness(
    DateTime? timestamp, {
    DateTime? now,
  }) {
    if (timestamp == null) {
      return OnboardingFailureFreshness.unknown;
    }

    final localTimestamp = timestamp.toLocal();
    final localNow = (now ?? DateTime.now()).toLocal();
    final sameDay =
        localTimestamp.year == localNow.year &&
        localTimestamp.month == localNow.month &&
        localTimestamp.day == localNow.day;

    if (sameDay) {
      return OnboardingFailureFreshness.today;
    }

    return OnboardingFailureFreshness.older;
  }
}
