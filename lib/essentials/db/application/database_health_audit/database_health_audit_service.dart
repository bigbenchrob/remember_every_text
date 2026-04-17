import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../onboarding/application/fda_checker.dart';
import '../../../services/startup_flags_service.dart';
import '../../feature_level_providers.dart';
import 'database_health_audit_models.dart';
import 'database_health_audit_queries.dart';

part 'database_health_audit_service.g.dart';

const _databaseHealthSchemaVersion = '1.0.0';
const _databaseHealthAuditVersion = 'phase1';
const _messageLensName = 'MessageLens';
const _messageLensBundleId = 'com.bigbenchsoftware.MessageLens';
const _defaultBuildName = String.fromEnvironment(
  'FLUTTER_BUILD_NAME',
  defaultValue: '0.1.3',
);
const _defaultBuildNumber = String.fromEnvironment(
  'FLUTTER_BUILD_NUMBER',
  defaultValue: '4',
);

@Riverpod(keepAlive: true)
Future<DatabaseHealthAuditService> databaseHealthAuditService(Ref ref) async {
  final importDb = await ref.read(sqfliteImportDatabaseProvider.future);
  final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.read(overlayDatabaseProvider.future);

  return DatabaseHealthAuditService(
    queryLayers: <DatabaseHealthQueryLayer>[
      ImportDatabaseHealthQueryLayer(
        database: importDb,
        databasePath: path.join(databaseDirectoryPath, 'macos_import.db'),
      ),
      WorkingDatabaseHealthQueryLayer(
        database: workingDb,
        databasePath: path.join(databaseDirectoryPath, 'working.db'),
      ),
      OverlayDatabaseHealthQueryLayer(
        database: overlayDb,
        databasePath: path.join(databaseDirectoryPath, 'user_overlays.db'),
      ),
    ],
  );
}

class DatabaseHealthAuditService {
  DatabaseHealthAuditService({
    required List<DatabaseHealthQueryLayer> queryLayers,
  }) : _queryLayers = queryLayers;

  final List<DatabaseHealthQueryLayer> _queryLayers;

  Future<DatabaseHealthReport> buildPhase1Report() async {
    final errors = <HealthReportError>[];
    final databases = <AuditedDatabaseInfo>[];
    final tableInventory = <TableInventoryEntry>[];
    final relationshipChecks = <RelationshipCheckResult>[];
    final invariantChecks = <InvariantCheckResult>[];

    for (final layer in _queryLayers) {
      databases.add(await _buildDatabaseInfo(layer, errors));
      tableInventory.addAll(await _buildTableInventory(layer, errors));
      relationshipChecks.addAll(await _buildRelationshipChecks(layer, errors));
      invariantChecks.addAll(await _buildInvariantChecks(layer, errors));
    }

    final summary = _buildSummary(
      tableInventory: tableInventory,
      relationshipChecks: relationshipChecks,
      invariantChecks: invariantChecks,
      errors: errors,
    );

    return DatabaseHealthReport(
      schemaVersion: _databaseHealthSchemaVersion,
      generatedAt: DateTime.now().toUtc().toIso8601String(),
      auditVersion: _databaseHealthAuditVersion,
      app: _buildAppInfo(),
      environment: _buildEnvironmentInfo(),
      databases: databases,
      tableInventory: tableInventory,
      relationshipChecks: relationshipChecks,
      invariantChecks: invariantChecks,
      summary: summary,
      errors: errors,
    );
  }

  Future<DatabaseHealthAuditOutput> writePhase1Report({
    required String outputDirectoryPath,
  }) async {
    final report = await buildPhase1Report();
    final directory = Directory(outputDirectoryPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final reportPath = path.join(outputDirectoryPath, 'database_health.json');
    const encoder = JsonEncoder.withIndent('  ');
    await File(
      reportPath,
    ).writeAsString('${encoder.convert(report.toJson())}\n');

    return DatabaseHealthAuditOutput(reportPath: reportPath, report: report);
  }

  DatabaseHealthAppInfo _buildAppInfo() {
    return const DatabaseHealthAppInfo(
      name: _messageLensName,
      bundleId: _messageLensBundleId,
      version: _defaultBuildName,
      buildNumber: _defaultBuildNumber,
      buildChannel: kReleaseMode
          ? 'release'
          : kProfileMode
          ? 'profile'
          : 'debug',
    );
  }

  DatabaseHealthEnvironmentInfo _buildEnvironmentInfo() {
    final startupFlags = StartupFlagsService.instance.cachedFlags;
    final timezone = Platform.environment['TZ'] ?? DateTime.now().timeZoneName;

    return DatabaseHealthEnvironmentInfo(
      platform: Platform.operatingSystem,
      platformVersion: Platform.operatingSystemVersion,
      timezone: timezone,
      hasFullDiskAccess: const FdaChecker().canReadMessagesDatabase(),
      startupFlags: <String, dynamic>{
        'option_launch_reset_requested':
            startupFlags.optionLaunchResetRequested,
      },
      diagnosticNotes: const <String>[
        'Phase 1 audits aggregate structure only; no row-level samples are exported.',
        'TODO: enrich build metadata from a dedicated runtime package-info source.',
        'Cross-database overlay relationship diagnostics are intentionally deferred to a later audit phase.',
      ],
    );
  }

  Future<AuditedDatabaseInfo> _buildDatabaseInfo(
    DatabaseHealthQueryLayer layer,
    List<HealthReportError> errors,
  ) async {
    try {
      final exists = await layer.databaseFileExists();
      final opened = await layer.ping();
      final schemaUserVersion = await layer.schemaUserVersion();

      return AuditedDatabaseInfo(
        databaseKey: layer.databaseKey,
        role: layer.role,
        accessible: exists,
        readOnlyOpenSucceeded: opened,
        schemaUserVersion: schemaUserVersion,
      );
    } catch (error) {
      final message = error.toString();
      errors.add(
        HealthReportError(
          scope: DatabaseHealthErrorScope.databaseOpen,
          databaseKey: layer.databaseKey,
          message: message,
        ),
      );
      return AuditedDatabaseInfo(
        databaseKey: layer.databaseKey,
        role: layer.role,
        accessible: false,
        readOnlyOpenSucceeded: false,
        error: message,
      );
    }
  }

  Future<List<TableInventoryEntry>> _buildTableInventory(
    DatabaseHealthQueryLayer layer,
    List<HealthReportError> errors,
  ) async {
    final specs =
        _tableSpecsByDatabase[layer.databaseKey] ?? const <AuditTableSpec>[];

    try {
      final actualTables = await layer.listTables();
      final actualSet = actualTables.toSet();
      final expectedNames = specs.map((spec) => spec.tableName).toSet();
      final allTableNames = <String>[
        ...specs.map((spec) => spec.tableName),
        ...actualTables.where((table) => !expectedNames.contains(table)),
      ];

      final entries = <TableInventoryEntry>[];
      for (final tableName in allTableNames) {
        final spec = specs
            .where((candidate) => candidate.tableName == tableName)
            .firstOrNull;
        final exists = actualSet.contains(tableName);
        if (!exists) {
          entries.add(
            TableInventoryEntry(
              databaseKey: layer.databaseKey,
              tableName: tableName,
              exists: false,
              notes: <String>[...?spec?.notes, 'Expected table is missing.'],
            ),
          );
          continue;
        }

        final rowCount = await layer.countRows(tableName);
        final primaryKey = await layer.primaryKeyInfo(tableName);
        final importantColumns = <DatabaseHealthImportantColumnSummary>[];
        for (final columnSpec
            in spec?.importantColumns ?? const <AuditImportantColumnSpec>[]) {
          final summary = await layer.summarizeImportantColumn(
            tableName: tableName,
            spec: columnSpec,
          );
          if (summary != null) {
            importantColumns.add(summary);
          }
        }

        final notes = <String>[
          ...?spec?.notes,
          if (!expectedNames.contains(tableName))
            'Table was discovered via sqlite_master and is not yet curated in the Phase 1 spec.',
          if (rowCount == 0) 'Table is empty.',
        ];

        entries.add(
          TableInventoryEntry(
            databaseKey: layer.databaseKey,
            tableName: tableName,
            exists: true,
            rowCount: rowCount,
            primaryKey: primaryKey,
            importantColumns: importantColumns,
            notes: notes,
          ),
        );
      }

      return entries;
    } catch (error) {
      errors.add(
        HealthReportError(
          scope: DatabaseHealthErrorScope.tableInventory,
          databaseKey: layer.databaseKey,
          message: error.toString(),
        ),
      );
      return <TableInventoryEntry>[];
    }
  }

  Future<List<RelationshipCheckResult>> _buildRelationshipChecks(
    DatabaseHealthQueryLayer layer,
    List<HealthReportError> errors,
  ) async {
    final specs =
        _relationshipSpecsByDatabase[layer.databaseKey] ??
        const <_RelationshipCheckSpec>[];
    final results = <RelationshipCheckResult>[];

    for (final spec in specs) {
      try {
        results.add(await _evaluateRelationshipCheck(layer, spec));
      } catch (error) {
        errors.add(
          HealthReportError(
            scope: DatabaseHealthErrorScope.relationshipCheck,
            databaseKey: layer.databaseKey,
            checkKey: spec.checkKey,
            message: error.toString(),
          ),
        );
        results.add(
          RelationshipCheckResult(
            checkKey: spec.checkKey,
            databaseKey: layer.databaseKey,
            relationshipType: spec.relationshipType,
            parentTable: spec.parentTable,
            childTable: spec.childTable,
            joinExpressionDescription: spec.joinExpressionDescription,
            status: DatabaseHealthStatus.error,
            notes: spec.notes,
            error: error.toString(),
          ),
        );
      }
    }

    return results;
  }

  Future<RelationshipCheckResult> _evaluateRelationshipCheck(
    DatabaseHealthQueryLayer layer,
    _RelationshipCheckSpec spec,
  ) async {
    final parentRowCount = await layer.countRows(spec.parentTable);
    final childRowCount = await layer.countRows(spec.childTable);
    final matchedRowCount = await _countQuery(layer, '''
      SELECT COUNT(*) AS c
      FROM ${_quoted(spec.parentTable)} AS p
      WHERE EXISTS (
        SELECT 1
        FROM ${_quoted(spec.childTable)} AS c
        WHERE ${spec.parentAliasPredicate}
      )
      ''');
    final unmatchedParentRowCount = await _countQuery(layer, '''
      SELECT COUNT(*) AS c
      FROM ${_quoted(spec.parentTable)} AS p
      WHERE NOT EXISTS (
        SELECT 1
        FROM ${_quoted(spec.childTable)} AS c
        WHERE ${spec.parentAliasPredicate}
      )
      ''');
    final unmatchedChildRowCount = await _countQuery(layer, '''
      SELECT COUNT(*) AS c
      FROM ${_quoted(spec.childTable)} AS c
      WHERE NOT EXISTS (
        SELECT 1
        FROM ${_quoted(spec.parentTable)} AS p
        WHERE ${spec.childAliasPredicate}
      )
      ''');

    final status = _statusFromRelationshipCounts(
      matchedRowCount: matchedRowCount,
      unmatchedParentRowCount: unmatchedParentRowCount,
      unmatchedChildRowCount: unmatchedChildRowCount,
      parentRowCount: parentRowCount,
      childRowCount: childRowCount,
    );

    return RelationshipCheckResult(
      checkKey: spec.checkKey,
      databaseKey: layer.databaseKey,
      relationshipType: spec.relationshipType,
      parentTable: spec.parentTable,
      childTable: spec.childTable,
      joinExpressionDescription: spec.joinExpressionDescription,
      parentRowCount: parentRowCount,
      childRowCount: childRowCount,
      matchedRowCount: matchedRowCount,
      unmatchedParentRowCount: unmatchedParentRowCount,
      unmatchedChildRowCount: unmatchedChildRowCount,
      matchedPercentage: _percentageOrNull(matchedRowCount, parentRowCount),
      unmatchedParentPercentage: _percentageOrNull(
        unmatchedParentRowCount,
        parentRowCount,
      ),
      unmatchedChildPercentage: _percentageOrNull(
        unmatchedChildRowCount,
        childRowCount,
      ),
      status: status,
      notes: spec.notes,
    );
  }

  Future<List<InvariantCheckResult>> _buildInvariantChecks(
    DatabaseHealthQueryLayer layer,
    List<HealthReportError> errors,
  ) async {
    final specs =
        _invariantSpecsByDatabase[layer.databaseKey] ??
        const <_InvariantCheckSpec>[];
    final results = <InvariantCheckResult>[];

    for (final spec in specs) {
      try {
        final evaluatedRowCount = await _countQuery(
          layer,
          spec.evaluatedRowCountSql,
        );
        final violationCount = await _countQuery(layer, spec.violationCountSql);
        results.add(
          InvariantCheckResult(
            checkKey: spec.checkKey,
            severity: spec.severity,
            description: spec.description,
            status: _statusFromInvariantCounts(
              violationCount: violationCount,
              evaluatedRowCount: evaluatedRowCount,
            ),
            violationCount: violationCount,
            evaluatedRowCount: evaluatedRowCount,
            notes: spec.notes,
          ),
        );
      } catch (error) {
        errors.add(
          HealthReportError(
            scope: DatabaseHealthErrorScope.invariantCheck,
            databaseKey: layer.databaseKey,
            checkKey: spec.checkKey,
            message: error.toString(),
          ),
        );
        results.add(
          InvariantCheckResult(
            checkKey: spec.checkKey,
            severity: spec.severity,
            description: spec.description,
            status: DatabaseHealthStatus.error,
            notes: spec.notes,
            error: error.toString(),
          ),
        );
      }
    }

    return results;
  }

  HealthReportSummary _buildSummary({
    required List<TableInventoryEntry> tableInventory,
    required List<RelationshipCheckResult> relationshipChecks,
    required List<InvariantCheckResult> invariantChecks,
    required List<HealthReportError> errors,
  }) {
    final allStatuses = <DatabaseHealthStatus>[
      ...relationshipChecks.map((check) => check.status),
      ...invariantChecks.map((check) => check.status),
      if (errors.isNotEmpty) DatabaseHealthStatus.error,
      if (tableInventory.any((entry) => !entry.exists))
        DatabaseHealthStatus.fail,
      if (tableInventory.any(
        (entry) => entry.exists && (entry.rowCount ?? 0) == 0,
      ))
        DatabaseHealthStatus.warning,
    ];

    final headlineFindings = <String>[
      ...tableInventory
          .where((entry) => !entry.exists)
          .map((entry) => '${entry.databaseKey}.${entry.tableName} is missing'),
      ...tableInventory
          .where((entry) => entry.exists && (entry.rowCount ?? 0) == 0)
          .map((entry) => '${entry.databaseKey}.${entry.tableName} is empty'),
      ...relationshipChecks
          .where((check) => check.status != DatabaseHealthStatus.pass)
          .take(5)
          .map(_headlineForRelationshipCheck),
      ...invariantChecks
          .where(
            (check) =>
                check.status != DatabaseHealthStatus.pass &&
                check.status != DatabaseHealthStatus.notApplicable,
          )
          .take(5)
          .map(_headlineForInvariantCheck),
      ...invariantChecks
          .where((check) => check.status == DatabaseHealthStatus.notApplicable)
          .take(2)
          .map((check) => '${check.checkKey}: phase1 not applicable'),
      ...errors.take(5).map((error) => '${error.scope.name}: ${error.message}'),
    ];

    final passCount = _countStatus(allStatuses, DatabaseHealthStatus.pass);
    final warningCount = _countStatus(
      allStatuses,
      DatabaseHealthStatus.warning,
    );
    final failCount = _countStatus(allStatuses, DatabaseHealthStatus.fail);
    final errorCount = _countStatus(allStatuses, DatabaseHealthStatus.error);

    return HealthReportSummary(
      overallStatus: _overallStatus(allStatuses),
      tableCount: tableInventory.length,
      relationshipCheckCount: relationshipChecks.length,
      invariantCheckCount: invariantChecks.length,
      passCount: passCount,
      warningCount: warningCount,
      failCount: failCount,
      errorCount: errorCount,
      headlineFindings: headlineFindings.take(12).toList(),
    );
  }
}

class _RelationshipCheckSpec {
  const _RelationshipCheckSpec({
    required this.checkKey,
    required this.relationshipType,
    required this.parentTable,
    required this.childTable,
    required this.parentAliasPredicate,
    required this.childAliasPredicate,
    required this.joinExpressionDescription,
    this.notes = const <String>[],
  });

  final String checkKey;
  final DatabaseHealthRelationshipType relationshipType;
  final String parentTable;
  final String childTable;
  final String parentAliasPredicate;
  final String childAliasPredicate;
  final String joinExpressionDescription;
  final List<String> notes;
}

class _InvariantCheckSpec {
  const _InvariantCheckSpec({
    required this.checkKey,
    required this.severity,
    required this.description,
    required this.evaluatedRowCountSql,
    required this.violationCountSql,
    this.notes = const <String>[],
  });

  final String checkKey;
  final DatabaseHealthSeverity severity;
  final String description;
  final String evaluatedRowCountSql;
  final String violationCountSql;
  final List<String> notes;
}

Future<int> _countQuery(DatabaseHealthQueryLayer layer, String sql) async {
  final rows = await layer.query(sql);
  final value = rows.first['c'];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.parse(value.toString());
}

DatabaseHealthStatus _statusFromRelationshipCounts({
  required int matchedRowCount,
  required int unmatchedParentRowCount,
  required int unmatchedChildRowCount,
  required int parentRowCount,
  required int childRowCount,
}) {
  if (unmatchedParentRowCount == 0 && unmatchedChildRowCount == 0) {
    return DatabaseHealthStatus.pass;
  }
  if (matchedRowCount == 0 && (parentRowCount > 0 || childRowCount > 0)) {
    return DatabaseHealthStatus.fail;
  }
  return DatabaseHealthStatus.warning;
}

DatabaseHealthStatus _statusFromInvariantCounts({
  required int violationCount,
  required int evaluatedRowCount,
}) {
  if (evaluatedRowCount == 0) {
    return DatabaseHealthStatus.notApplicable;
  }
  if (violationCount == 0) {
    return DatabaseHealthStatus.pass;
  }
  if (violationCount == evaluatedRowCount) {
    return DatabaseHealthStatus.fail;
  }
  return DatabaseHealthStatus.warning;
}

DatabaseHealthStatus _overallStatus(List<DatabaseHealthStatus> statuses) {
  if (statuses.contains(DatabaseHealthStatus.error)) {
    return DatabaseHealthStatus.error;
  }
  if (statuses.contains(DatabaseHealthStatus.fail)) {
    return DatabaseHealthStatus.fail;
  }
  if (statuses.contains(DatabaseHealthStatus.warning)) {
    return DatabaseHealthStatus.warning;
  }
  if (statuses.contains(DatabaseHealthStatus.pass)) {
    return DatabaseHealthStatus.pass;
  }
  return DatabaseHealthStatus.notApplicable;
}

int _countStatus(
  List<DatabaseHealthStatus> statuses,
  DatabaseHealthStatus status,
) {
  return statuses.where((value) => value == status).length;
}

double? _percentageOrNull(int numerator, int denominator) {
  if (denominator == 0) {
    return null;
  }
  return ((numerator / denominator) * 1000).round() / 10.0;
}

String _headlineForRelationshipCheck(RelationshipCheckResult check) {
  final parentCount = check.parentRowCount ?? 0;
  final childCount = check.childRowCount ?? 0;
  final unmatchedParents = check.unmatchedParentRowCount ?? 0;
  final unmatchedChildren = check.unmatchedChildRowCount ?? 0;
  final parentRate = _formatPercentage(check.unmatchedParentPercentage);
  final childRate = _formatPercentage(check.unmatchedChildPercentage);

  final segments = <String>[];
  if (parentCount > 0 && unmatchedParents > 0) {
    segments.add('$unmatchedParents/$parentCount parent unmatched$parentRate');
  }
  if (childCount > 0 && unmatchedChildren > 0) {
    segments.add('$unmatchedChildren/$childCount child unmatched$childRate');
  }
  if (segments.isEmpty) {
    final matched = check.matchedRowCount ?? 0;
    final matchedRate = _formatPercentage(check.matchedPercentage);
    segments.add('$matched matched$matchedRate');
  }

  return '${check.checkKey}: ${segments.join(', ')}';
}

String _headlineForInvariantCheck(InvariantCheckResult check) {
  final violations = check.violationCount ?? 0;
  final evaluated = check.evaluatedRowCount ?? 0;
  final rate = _formatPercentage(_percentageOrNull(violations, evaluated));
  if (evaluated > 0) {
    return '${check.checkKey}: $violations/$evaluated violations$rate';
  }
  return '${check.checkKey}: $violations violations';
}

String _formatPercentage(double? value) {
  if (value == null) {
    return '';
  }
  return ' (${value.toStringAsFixed(1)}%)';
}

String _quoted(String value) {
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

const Map<String, List<AuditTableSpec>>
_tableSpecsByDatabase = <String, List<AuditTableSpec>>{
  'import': <AuditTableSpec>[
    AuditTableSpec(tableName: 'schema_migrations'),
    AuditTableSpec(tableName: 'import_batches'),
    AuditTableSpec(tableName: 'source_files'),
    AuditTableSpec(tableName: 'import_logs'),
    AuditTableSpec(tableName: 'contacts'),
    AuditTableSpec(
      tableName: 'contact_phone_email',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('kind'),
        AuditImportantColumnSpec(
          'label',
          omittedForPrivacy: true,
          notes: <String>[
            'Potentially user-authored contact label intentionally omitted.',
          ],
        ),
      ],
    ),
    AuditTableSpec(
      tableName: 'handles',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('service'),
        AuditImportantColumnSpec('normalized_identifier'),
      ],
    ),
    AuditTableSpec(
      tableName: 'chats',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec(
          'display_name',
          omittedForPrivacy: true,
          notes: <String>['Chat display names are intentionally omitted.'],
        ),
      ],
    ),
    AuditTableSpec(tableName: 'chat_to_handle'),
    AuditTableSpec(
      tableName: 'messages',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('chat_id'),
        AuditImportantColumnSpec('sender_handle_id'),
        AuditImportantColumnSpec(
          'text',
          omittedForPrivacy: true,
          notes: <String>['Sensitive content field intentionally omitted.'],
        ),
        AuditImportantColumnSpec(
          'attributed_body_blob',
          omittedForPrivacy: true,
          notes: <String>['Sensitive content field intentionally omitted.'],
        ),
      ],
    ),
    AuditTableSpec(
      tableName: 'recovered_unlinked_messages',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('sender_handle_id'),
        AuditImportantColumnSpec(
          'text',
          omittedForPrivacy: true,
          notes: <String>['Sensitive content field intentionally omitted.'],
        ),
      ],
    ),
    AuditTableSpec(tableName: 'chat_to_message'),
    AuditTableSpec(
      tableName: 'attachments',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('local_path'),
        AuditImportantColumnSpec(
          'transfer_name',
          omittedForPrivacy: true,
          notes: <String>['Attachment filenames are intentionally omitted.'],
        ),
        AuditImportantColumnSpec('mime_type'),
      ],
    ),
    AuditTableSpec(tableName: 'message_attachments'),
    AuditTableSpec(tableName: 'recovered_unlinked_message_attachments'),
    AuditTableSpec(
      tableName: 'reactions',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('target_message_guid'),
        AuditImportantColumnSpec('reactor_handle_id'),
        AuditImportantColumnSpec('kind'),
      ],
    ),
    AuditTableSpec(
      tableName: 'message_links',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('message_id'),
        AuditImportantColumnSpec(
          'url',
          omittedForPrivacy: true,
          notes: <String>['URLs are intentionally omitted.'],
        ),
      ],
    ),
    AuditTableSpec(tableName: 'contact_to_chat_handle'),
    AuditTableSpec(
      tableName: 'contacts_new',
      notes: <String>[
        'Scratch import table; empty is normal outside active contact refresh work.',
      ],
    ),
  ],
  'working': <AuditTableSpec>[
    AuditTableSpec(tableName: 'schema_migrations'),
    AuditTableSpec(tableName: 'projection_state'),
    AuditTableSpec(tableName: 'app_settings'),
    AuditTableSpec(tableName: 'handles_canonical'),
    AuditTableSpec(tableName: 'participants'),
    AuditTableSpec(tableName: 'handle_to_participant'),
    AuditTableSpec(tableName: 'handles_canonical_to_alias'),
    AuditTableSpec(tableName: 'chat_to_handle'),
    AuditTableSpec(tableName: 'chats'),
    AuditTableSpec(
      tableName: 'messages',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('chat_id'),
        AuditImportantColumnSpec('sender_handle_id'),
        AuditImportantColumnSpec(
          'text',
          omittedForPrivacy: true,
          notes: <String>['Sensitive content field intentionally omitted.'],
        ),
        AuditImportantColumnSpec('semantic_kind'),
        AuditImportantColumnSpec('has_attachments'),
      ],
    ),
    AuditTableSpec(
      tableName: 'recovered_unlinked_messages',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('guid'),
        AuditImportantColumnSpec('sender_handle_id'),
        AuditImportantColumnSpec(
          'text',
          omittedForPrivacy: true,
          notes: <String>['Sensitive content field intentionally omitted.'],
        ),
        AuditImportantColumnSpec('has_attachments'),
      ],
    ),
    AuditTableSpec(tableName: 'global_message_index'),
    AuditTableSpec(tableName: 'message_index'),
    AuditTableSpec(tableName: 'contact_message_index'),
    AuditTableSpec(
      tableName: 'attachments',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('message_guid'),
        AuditImportantColumnSpec('import_attachment_id'),
        AuditImportantColumnSpec('local_path'),
        AuditImportantColumnSpec(
          'transfer_name',
          omittedForPrivacy: true,
          notes: <String>['Attachment filenames are intentionally omitted.'],
        ),
        AuditImportantColumnSpec('mime_type'),
      ],
    ),
    AuditTableSpec(
      tableName: 'recovered_unlinked_attachments',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('message_guid'),
        AuditImportantColumnSpec('import_attachment_id'),
        AuditImportantColumnSpec('local_path'),
      ],
    ),
    AuditTableSpec(
      tableName: 'reactions',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('message_guid'),
        AuditImportantColumnSpec('carrier_message_id'),
        AuditImportantColumnSpec('target_message_guid'),
        AuditImportantColumnSpec('kind'),
      ],
    ),
    AuditTableSpec(tableName: 'reaction_counts'),
    AuditTableSpec(tableName: 'read_state'),
    AuditTableSpec(tableName: 'message_read_marks'),
    AuditTableSpec(tableName: 'supabase_sync_state'),
    AuditTableSpec(tableName: 'supabase_sync_logs'),
  ],
  'overlay': <AuditTableSpec>[
    AuditTableSpec(tableName: 'participant_overrides'),
    AuditTableSpec(tableName: 'chat_overrides'),
    AuditTableSpec(
      tableName: 'message_annotations',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('message_id'),
        AuditImportantColumnSpec(
          'user_notes',
          omittedForPrivacy: true,
          notes: <String>['User-authored notes are intentionally omitted.'],
        ),
      ],
    ),
    AuditTableSpec(tableName: 'message_user_flags'),
    AuditTableSpec(tableName: 'message_user_tags'),
    AuditTableSpec(tableName: 'handle_to_participant_overrides'),
    AuditTableSpec(tableName: 'virtual_participants'),
    AuditTableSpec(tableName: 'overlay_settings'),
    AuditTableSpec(tableName: 'favorite_contacts'),
    AuditTableSpec(tableName: 'dismissed_handles'),
    AuditTableSpec(tableName: 'handle_visibility_overrides'),
    AuditTableSpec(
      tableName: 'archived_attachments',
      importantColumns: <AuditImportantColumnSpec>[
        AuditImportantColumnSpec('message_guid'),
        AuditImportantColumnSpec('import_attachment_id'),
        AuditImportantColumnSpec(
          'archive_relative_path',
          omittedForPrivacy: true,
          notes: <String>['Archive path is intentionally omitted.'],
        ),
        AuditImportantColumnSpec(
          'original_local_path',
          omittedForPrivacy: true,
          notes: <String>['Original attachment path is intentionally omitted.'],
        ),
      ],
    ),
  ],
};

const Map<String, List<_RelationshipCheckSpec>>
_relationshipSpecsByDatabase = <String, List<_RelationshipCheckSpec>>{
  'import': <_RelationshipCheckSpec>[
    _RelationshipCheckSpec(
      checkKey: 'messages_to_chat_to_message',
      relationshipType: DatabaseHealthRelationshipType.joinTableCoverage,
      parentTable: 'messages',
      childTable: 'chat_to_message',
      parentAliasPredicate: 'c.message_id = p.id',
      childAliasPredicate: 'p.id = c.message_id',
      joinExpressionDescription: 'messages.id = chat_to_message.message_id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_message_to_chats',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_message',
      childTable: 'chats',
      parentAliasPredicate: 'c.id = p.chat_id',
      childAliasPredicate: 'p.chat_id = c.id',
      joinExpressionDescription: 'chat_to_message.chat_id = chats.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_message_to_messages',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_message',
      childTable: 'messages',
      parentAliasPredicate: 'c.id = p.message_id',
      childAliasPredicate: 'p.message_id = c.id',
      joinExpressionDescription: 'chat_to_message.message_id = messages.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_handle_to_chats',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_handle',
      childTable: 'chats',
      parentAliasPredicate: 'c.id = p.chat_id',
      childAliasPredicate: 'p.chat_id = c.id',
      joinExpressionDescription: 'chat_to_handle.chat_id = chats.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_handle_to_handles',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_handle',
      childTable: 'handles',
      parentAliasPredicate: 'c.id = p.handle_id',
      childAliasPredicate: 'p.handle_id = c.id',
      joinExpressionDescription: 'chat_to_handle.handle_id = handles.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'message_attachments_to_messages',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'message_attachments',
      childTable: 'messages',
      parentAliasPredicate: 'c.id = p.message_id',
      childAliasPredicate: 'p.message_id = c.id',
      joinExpressionDescription: 'message_attachments.message_id = messages.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'message_attachments_to_attachments',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'message_attachments',
      childTable: 'attachments',
      parentAliasPredicate: 'c.id = p.attachment_id',
      childAliasPredicate: 'p.attachment_id = c.id',
      joinExpressionDescription:
          'message_attachments.attachment_id = attachments.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'recovered_unlinked_message_attachments_to_messages',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'recovered_unlinked_message_attachments',
      childTable: 'recovered_unlinked_messages',
      parentAliasPredicate: 'c.id = p.message_id',
      childAliasPredicate: 'p.message_id = c.id',
      joinExpressionDescription:
          'recovered_unlinked_message_attachments.message_id = recovered_unlinked_messages.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'contact_phone_email_to_contacts',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'contact_phone_email',
      childTable: 'contacts',
      parentAliasPredicate: 'c.Z_PK = p.ZOWNER',
      childAliasPredicate: 'p.ZOWNER = c.Z_PK',
      joinExpressionDescription: 'contact_phone_email.ZOWNER = contacts.Z_PK',
    ),
    _RelationshipCheckSpec(
      checkKey: 'contact_to_chat_handle_to_contacts',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'contact_to_chat_handle',
      childTable: 'contacts',
      parentAliasPredicate: 'c.Z_PK = p.contact_Z_PK',
      childAliasPredicate: 'p.contact_Z_PK = c.Z_PK',
      joinExpressionDescription:
          'contact_to_chat_handle.contact_Z_PK = contacts.Z_PK',
    ),
    _RelationshipCheckSpec(
      checkKey: 'contact_to_chat_handle_to_handles',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'contact_to_chat_handle',
      childTable: 'handles',
      parentAliasPredicate: 'c.id = p.chat_handle_id',
      childAliasPredicate: 'p.chat_handle_id = c.id',
      joinExpressionDescription:
          'contact_to_chat_handle.chat_handle_id = handles.id',
    ),
  ],
  'working': <_RelationshipCheckSpec>[
    _RelationshipCheckSpec(
      checkKey: 'messages_to_chats',
      relationshipType: DatabaseHealthRelationshipType.oneToManyExpected,
      parentTable: 'messages',
      childTable: 'chats',
      parentAliasPredicate: 'c.id = p.chat_id',
      childAliasPredicate: 'p.chat_id = c.id',
      joinExpressionDescription: 'messages.chat_id = chats.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_handle_to_chats',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_handle',
      childTable: 'chats',
      parentAliasPredicate: 'c.id = p.chat_id',
      childAliasPredicate: 'p.chat_id = c.id',
      joinExpressionDescription: 'chat_to_handle.chat_id = chats.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'chat_to_handle_to_handles_canonical',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'chat_to_handle',
      childTable: 'handles_canonical',
      parentAliasPredicate: 'c.id = p.handle_id',
      childAliasPredicate: 'p.handle_id = c.id',
      joinExpressionDescription:
          'chat_to_handle.handle_id = handles_canonical.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'handle_to_participant_to_handles_canonical',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'handle_to_participant',
      childTable: 'handles_canonical',
      parentAliasPredicate: 'c.id = p.handle_id',
      childAliasPredicate: 'p.handle_id = c.id',
      joinExpressionDescription:
          'handle_to_participant.handle_id = handles_canonical.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'handle_to_participant_to_participants',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'handle_to_participant',
      childTable: 'participants',
      parentAliasPredicate: 'c.id = p.participant_id',
      childAliasPredicate: 'p.participant_id = c.id',
      joinExpressionDescription:
          'handle_to_participant.participant_id = participants.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'attachments_to_messages_by_guid',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'attachments',
      childTable: 'messages',
      parentAliasPredicate: 'c.guid = p.message_guid',
      childAliasPredicate: 'p.message_guid = c.guid',
      joinExpressionDescription: 'attachments.message_guid = messages.guid',
    ),
    _RelationshipCheckSpec(
      checkKey: 'recovered_unlinked_attachments_to_messages_by_guid',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'recovered_unlinked_attachments',
      childTable: 'recovered_unlinked_messages',
      parentAliasPredicate: 'c.guid = p.message_guid',
      childAliasPredicate: 'p.message_guid = c.guid',
      joinExpressionDescription:
          'recovered_unlinked_attachments.message_guid = recovered_unlinked_messages.guid',
    ),
    _RelationshipCheckSpec(
      checkKey: 'global_message_index_to_messages',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'global_message_index',
      childTable: 'messages',
      parentAliasPredicate: 'c.id = p.message_id',
      childAliasPredicate: 'p.message_id = c.id',
      joinExpressionDescription:
          'global_message_index.message_id = messages.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'message_index_to_messages',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'message_index',
      childTable: 'messages',
      parentAliasPredicate: 'c.id = p.message_id',
      childAliasPredicate: 'p.message_id = c.id',
      joinExpressionDescription: 'message_index.message_id = messages.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'contact_message_index_to_messages',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'contact_message_index',
      childTable: 'messages',
      parentAliasPredicate: 'c.id = p.message_id',
      childAliasPredicate: 'p.message_id = c.id',
      joinExpressionDescription:
          'contact_message_index.message_id = messages.id',
    ),
    _RelationshipCheckSpec(
      checkKey: 'reactions_carrier_message_to_messages',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'reactions',
      childTable: 'messages',
      parentAliasPredicate: 'c.id = p.carrier_message_id',
      childAliasPredicate: 'p.carrier_message_id = c.id',
      joinExpressionDescription: 'reactions.carrier_message_id = messages.id',
      notes: <String>[
        'Null carrier_message_id rows are treated as unmatched in Phase 1.',
      ],
    ),
    _RelationshipCheckSpec(
      checkKey: 'reactions_message_guid_to_messages',
      relationshipType: DatabaseHealthRelationshipType.existenceCheck,
      parentTable: 'reactions',
      childTable: 'messages',
      parentAliasPredicate: 'c.guid = p.message_guid',
      childAliasPredicate: 'p.message_guid = c.guid',
      joinExpressionDescription: 'reactions.message_guid = messages.guid',
    ),
  ],
};

const Map<String, List<_InvariantCheckSpec>>
_invariantSpecsByDatabase = <String, List<_InvariantCheckSpec>>{
  'import': <_InvariantCheckSpec>[
    _InvariantCheckSpec(
      checkKey: 'messages_should_have_chat_linkage',
      severity: DatabaseHealthSeverity.high,
      description:
          'Every imported message should have at least one chat_to_message row.',
      evaluatedRowCountSql: 'SELECT COUNT(*) AS c FROM "messages"',
      violationCountSql: '''
            SELECT COUNT(*) AS c
            FROM "messages" AS m
            WHERE NOT EXISTS (
              SELECT 1
              FROM "chat_to_message" AS ctm
              WHERE ctm.message_id = m.id
            )
          ''',
    ),
    _InvariantCheckSpec(
      checkKey: 'message_attachments_should_reference_existing_rows',
      severity: DatabaseHealthSeverity.high,
      description:
          'Every message_attachments row should reference both a message and an attachment.',
      evaluatedRowCountSql: 'SELECT COUNT(*) AS c FROM "message_attachments"',
      violationCountSql: '''
            SELECT COUNT(*) AS c
            FROM "message_attachments" AS ma
            WHERE NOT EXISTS (
              SELECT 1 FROM "messages" AS m WHERE m.id = ma.message_id
            )
            OR NOT EXISTS (
              SELECT 1 FROM "attachments" AS a WHERE a.id = ma.attachment_id
            )
          ''',
    ),
  ],
  'working': <_InvariantCheckSpec>[
    _InvariantCheckSpec(
      checkKey: 'working_messages_should_have_chat_linkage',
      severity: DatabaseHealthSeverity.high,
      description:
          'Every working message intended for timeline display should map to an existing chat.',
      evaluatedRowCountSql: 'SELECT COUNT(*) AS c FROM "messages"',
      violationCountSql: '''
            SELECT COUNT(*) AS c
            FROM "messages" AS m
            WHERE NOT EXISTS (
              SELECT 1 FROM "chats" AS c WHERE c.id = m.chat_id
            )
          ''',
    ),
    _InvariantCheckSpec(
      checkKey: 'attachments_should_map_to_import_attachment_id',
      severity: DatabaseHealthSeverity.medium,
      description:
          'Projected attachments should preserve import_attachment_id for traceability.',
      evaluatedRowCountSql: 'SELECT COUNT(*) AS c FROM "attachments"',
      violationCountSql: '''
            SELECT COUNT(*) AS c
            FROM "attachments"
            WHERE import_attachment_id IS NULL
          ''',
      notes: <String>[
        'TODO: confirm whether any legacy recovery path intentionally permits null import_attachment_id.',
      ],
    ),
    _InvariantCheckSpec(
      checkKey: 'global_message_index_should_cover_messages',
      severity: DatabaseHealthSeverity.high,
      description:
          'Every working message should appear in global_message_index exactly once.',
      evaluatedRowCountSql: 'SELECT COUNT(*) AS c FROM "messages"',
      violationCountSql: '''
            SELECT COUNT(*) AS c
            FROM "messages" AS m
            WHERE NOT EXISTS (
              SELECT 1
              FROM "global_message_index" AS gmi
              WHERE gmi.message_id = m.id
            )
          ''',
    ),
    _InvariantCheckSpec(
      checkKey: 'projection_state_singleton_should_exist',
      severity: DatabaseHealthSeverity.critical,
      description:
          'working.projection_state should contain the singleton row with id = 1.',
      evaluatedRowCountSql: 'SELECT 1 AS c',
      violationCountSql: '''
            SELECT CASE
              WHEN EXISTS (
                SELECT 1 FROM "projection_state" WHERE id = 1
              ) THEN 0
              ELSE 1
            END AS c
          ''',
    ),
  ],
  'overlay': <_InvariantCheckSpec>[
    _InvariantCheckSpec(
      checkKey: 'overlay_cross_database_relationship_checks_deferred',
      severity: DatabaseHealthSeverity.low,
      description:
          'Cross-database overlay-to-working relationship checks are intentionally deferred in Phase 1.',
      evaluatedRowCountSql: 'SELECT 0 AS c',
      violationCountSql: 'SELECT 0 AS c',
      notes: <String>[
        'Phase 1 inventories overlay tables but does not execute cross-database relationship checks.',
      ],
    ),
  ],
};
