import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

import '../../../../essentials/archive_environment/domain/archive_environment.dart';
import '../../../../essentials/archive_environment/domain/archive_marker.dart';
import '../../../../essentials/archive_environment/infrastructure/file_system_archive_marker_store.dart';
import '../../../../essentials/db/app_database_files.dart';
import '../../../../essentials/db/application/read_only_sql_guard.dart';
import '../../application/message_lens_attachment_recovery_donor_qualifier.dart';
import '../../domain/entities/message_lens_attachment_recovery_donor.dart';
import 'sqlite_message_lens_attachment_donor_evidence_reader.dart';

/// Recognizes only documented MessageLens data-folder formats needed by
/// attachment recovery. Every SQLite open is read-only and query-only.
final class SqliteMessageLensAttachmentRecoveryDonorQualifier
    implements MessageLensAttachmentRecoveryDonorQualifier {
  const SqliteMessageLensAttachmentRecoveryDonorQualifier({
    required this.currentArchiveRoot,
    required this.currentArchiveInstanceId,
    required this.currentArchiveEnvironment,
  });

  final String currentArchiveRoot;
  final String currentArchiveInstanceId;
  final ArchiveEnvironment currentArchiveEnvironment;

  @override
  Future<MessageLensAttachmentRecoveryDonorQualification> qualify({
    required String folderPath,
  }) async {
    final normalizedFolder = path.normalize(path.absolute(folderPath));
    if (FileSystemEntity.typeSync(normalizedFolder, followLinks: false) !=
        FileSystemEntityType.directory) {
      return const InvalidMessageLensAttachmentRecoveryDonor();
    }
    if (path.equals(normalizedFolder, path.normalize(currentArchiveRoot))) {
      return const IncompatibleMessageLensAttachmentRecoveryDonor(
        detail: 'The active MessageLens data folder cannot be its own donor.',
      );
    }

    final ArchiveMarker? marker;
    try {
      marker = await FileSystemArchiveMarkerStore(
        rootPath: normalizedFolder,
      ).read();
    } catch (error) {
      return IncompatibleMessageLensAttachmentRecoveryDonor(
        detail: 'The MessageLens archive marker could not be read: $error',
      );
    }

    if (marker != null) {
      return _qualifyMarkedArchive(
        normalizedFolder: normalizedFolder,
        marker: marker,
      );
    }
    return _qualifyPreMarkerArchive(normalizedFolder);
  }

  Future<MessageLensAttachmentRecoveryDonorQualification>
  _qualifyMarkedArchive({
    required String normalizedFolder,
    required ArchiveMarker marker,
  }) async {
    if (marker.formatVersion != ArchiveMarker.currentFormatVersion) {
      return IncompatibleMessageLensAttachmentRecoveryDonor(
        detail:
            'Archive marker format ${marker.formatVersion} is not supported.',
      );
    }
    if (marker.archiveInstanceId.value == currentArchiveInstanceId) {
      return const IncompatibleMessageLensAttachmentRecoveryDonor(
        detail: 'The active MessageLens data folder cannot be its own donor.',
      );
    }
    if (currentArchiveEnvironment == ArchiveEnvironment.production &&
        marker.environment != ArchiveEnvironment.production) {
      return const IncompatibleMessageLensAttachmentRecoveryDonor(
        detail:
            'Production MessageLens accepts only production archive donors.',
      );
    }

    final compatibility = await _validateAttachmentEvidence(normalizedFolder);
    if (compatibility != null) {
      return compatibility;
    }
    return SupportedMessageLensAttachmentRecoveryDonor(
      donor: MessageLensAttachmentRecoveryDonor(
        rootPath: normalizedFolder,
        format: MessageLensAttachmentRecoveryDonorFormat.currentMarkerV1,
        archiveInstanceId: marker.archiveInstanceId.value,
      ),
    );
  }

  Future<MessageLensAttachmentRecoveryDonorQualification>
  _qualifyPreMarkerArchive(String normalizedFolder) async {
    final sourceLedgerPath = _databasePath(
      normalizedFolder,
      AppDatabaseFile.sourceScopedImport,
    );
    final overlayPath = _databasePath(
      normalizedFolder,
      AppDatabaseFile.overlay,
    );
    final graphPath = _databasePath(
      normalizedFolder,
      AppDatabaseFile.conversationGraph,
    );
    final payloadRoot = path.join(normalizedFolder, 'attachment_archive');

    final hasHistoricalEnvelope =
        _isRegularFile(sourceLedgerPath) &&
        _isRegularFile(overlayPath) &&
        _isRegularFile(graphPath) &&
        FileSystemEntity.typeSync(payloadRoot, followLinks: false) ==
            FileSystemEntityType.directory;
    if (!hasHistoricalEnvelope) {
      return const InvalidMessageLensAttachmentRecoveryDonor();
    }

    final compatibility = await _validateAttachmentEvidence(normalizedFolder);
    if (compatibility != null) {
      return compatibility;
    }

    try {
      final importVersion = _readUserVersion(sourceLedgerPath);
      final overlayVersion = _readUserVersion(overlayPath);
      final graphVersion = _readGraphVersionAndShape(graphPath);
      final format = _historicalFormatFor(
        importVersion: importVersion,
        overlayVersion: overlayVersion,
        graphVersion: graphVersion,
      );
      if (format == null) {
        return IncompatibleMessageLensAttachmentRecoveryDonor(
          detail:
              'Recognized pre-marker MessageLens databases use an unsupported '
              'schema combination: import $importVersion, overlay '
              '$overlayVersion, graph $graphVersion.',
        );
      }
      return SupportedMessageLensAttachmentRecoveryDonor(
        donor: MessageLensAttachmentRecoveryDonor(
          rootPath: normalizedFolder,
          format: format,
          archiveInstanceId: null,
        ),
      );
    } catch (error) {
      return IncompatibleMessageLensAttachmentRecoveryDonor(
        detail:
            'This historical MessageLens format cannot be inspected safely: '
            '$error',
      );
    }
  }

  Future<MessageLensAttachmentRecoveryDonorQualification?>
  _validateAttachmentEvidence(String normalizedFolder) async {
    final sourceLedgerPath = _databasePath(
      normalizedFolder,
      AppDatabaseFile.sourceScopedImport,
    );
    final overlayPath = _databasePath(
      normalizedFolder,
      AppDatabaseFile.overlay,
    );
    if (!_isRegularFile(sourceLedgerPath) || !_isRegularFile(overlayPath)) {
      return const IncompatibleMessageLensAttachmentRecoveryDonor(
        detail:
            'The folder is a MessageLens archive but does not contain the '
            'supported attachment evidence stores.',
      );
    }

    final reader = SqliteMessageLensAttachmentDonorEvidenceReader(
      donorArchiveRoot: normalizedFolder,
      donorSourceScopedImportDatabasePath: sourceLedgerPath,
      donorOverlayDatabasePath: overlayPath,
    );
    try {
      await reader.validateCompatibility();
      return null;
    } catch (error) {
      return IncompatibleMessageLensAttachmentRecoveryDonor(
        detail: 'This MessageLens archive cannot be inspected safely: $error',
      );
    }
  }

  static MessageLensAttachmentRecoveryDonorFormat? _historicalFormatFor({
    required int importVersion,
    required int overlayVersion,
    required int graphVersion,
  }) {
    return switch ((importVersion, overlayVersion, graphVersion)) {
      (8, 5, 1) => MessageLensAttachmentRecoveryDonorFormat.importSchemaV8,
      (9, 5, 1) => MessageLensAttachmentRecoveryDonorFormat.importSchemaV9,
      (10, 1, 2) => MessageLensAttachmentRecoveryDonorFormat.importSchemaV10,
      _ => null,
    };
  }

  static int _readUserVersion(String databasePath) {
    final database = _openReadOnly(databasePath);
    try {
      _requireHealthyDatabase(database);
      return _readUserVersionValue(database);
    } finally {
      database.dispose();
    }
  }

  static int _readGraphVersionAndShape(String databasePath) {
    final database = _openReadOnly(databasePath);
    try {
      _requireHealthyDatabase(database);
      _requireColumns(database, 'messages', const <String>{'ss_id'});
      _requireColumns(database, 'attachments', const <String>{'ss_id'});
      _requireColumns(database, 'message_to_attachment', const <String>{
        'message_ss_id',
        'attachment_ss_id',
      });
      return _readUserVersionValue(database);
    } finally {
      database.dispose();
    }
  }

  static Database _openReadOnly(String databasePath) {
    final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
    database.execute('PRAGMA query_only = ON;');
    database.execute('PRAGMA busy_timeout = 3000;');
    return database;
  }

  static int _readUserVersionValue(Database database) {
    const sql = 'PRAGMA user_version';
    assertReadOnlySql(sql, boundary: 'MessageLens donor format qualification');
    final value = database.select(sql).single.values.first;
    if (value is! int) {
      throw StateError('Donor database has an invalid schema version.');
    }
    return value;
  }

  static void _requireHealthyDatabase(Database database) {
    const quickCheckSql = 'PRAGMA quick_check';
    const integrityCheckSql = 'PRAGMA integrity_check';
    assertReadOnlySql(
      quickCheckSql,
      boundary: 'MessageLens donor format qualification',
    );
    assertReadOnlySql(
      integrityCheckSql,
      boundary: 'MessageLens donor format qualification',
    );
    final quickCheck = database.select(quickCheckSql).single.values.first;
    final integrityCheck = database
        .select(integrityCheckSql)
        .single
        .values
        .first;
    if (quickCheck != 'ok' || integrityCheck != 'ok') {
      throw StateError('Donor database integrity checks failed.');
    }
  }

  static void _requireColumns(
    Database database,
    String table,
    Set<String> requiredColumns,
  ) {
    const tableSql =
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?";
    assertReadOnlySql(
      tableSql,
      boundary: 'MessageLens donor format qualification',
    );
    final tables = database.select(tableSql, <Object?>[table]);
    if (tables.length != 1) {
      throw StateError('Unsupported donor schema: missing $table.');
    }
    final columnSql = 'PRAGMA table_info("$table")';
    assertReadOnlySql(
      columnSql,
      boundary: 'MessageLens donor format qualification',
    );
    final columns = database
        .select(columnSql)
        .map((row) => row['name'] as String)
        .toSet();
    final missing = requiredColumns.difference(columns);
    if (missing.isNotEmpty) {
      throw StateError(
        'Unsupported donor schema: $table is missing ${missing.join(', ')}.',
      );
    }
  }

  static String _databasePath(String root, AppDatabaseFile databaseFile) {
    return appDatabasePath(databaseFile, databaseDirectory: root);
  }

  static bool _isRegularFile(String candidatePath) {
    return FileSystemEntity.typeSync(candidatePath, followLinks: false) ==
        FileSystemEntityType.file;
  }
}
