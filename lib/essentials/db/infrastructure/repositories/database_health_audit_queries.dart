import 'dart:io';

import 'package:sqlite3/sqlite3.dart' as sqlite3;

import '../../../source_scoped_import/infrastructure/import_database_provider.dart'
    as source_scoped_import;
import '../../application/database_health_audit/database_health_query_layer.dart';
import '../data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../data_sources/local/overlay/overlay_database.dart';

class ReadOnlySqliteFileHealthQueryLayer extends DatabaseHealthQueryLayer {
  ReadOnlySqliteFileHealthQueryLayer({
    required this.databaseKey,
    required this.role,
    required this.databasePath,
  });

  @override
  final String databaseKey;

  @override
  final String role;

  @override
  final String databasePath;

  @override
  Future<List<Map<String, Object?>>> query(String sql) async {
    if (!File(databasePath).existsSync()) {
      throw StateError('Database file does not exist: $databasePath');
    }

    final db = sqlite3.sqlite3.open(
      databasePath,
      mode: sqlite3.OpenMode.readOnly,
    );
    try {
      final resultSet = db.select(sql);
      return <Map<String, Object?>>[
        for (final row in resultSet)
          <String, Object?>{
            for (var i = 0; i < resultSet.columnNames.length; i++)
              resultSet.columnNames[i]: row[i],
          },
      ];
    } finally {
      db.dispose();
    }
  }
}

class SourceScopedImportDatabaseHealthQueryLayer
    extends DatabaseHealthQueryLayer {
  SourceScopedImportDatabaseHealthQueryLayer({
    required source_scoped_import.ImportDatabase database,
    required this.databasePath,
  }) : _database = database;

  final source_scoped_import.ImportDatabase _database;

  @override
  final String databasePath;

  @override
  String get databaseKey => 'source_scoped_import';

  @override
  String get role => 'source_scoped_import_ledger';

  @override
  Future<List<Map<String, Object?>>> query(String sql) async {
    final rows = await _database.database.rawQuery(sql);
    return rows.map((row) => Map<String, Object?>.from(row)).toList();
  }
}

class ConversationGraphDatabaseHealthQueryLayer
    extends DatabaseHealthQueryLayer {
  ConversationGraphDatabaseHealthQueryLayer({
    required ConversationGraphDatabase database,
    required this.databasePath,
  }) : _database = database;

  final ConversationGraphDatabase _database;

  @override
  final String databasePath;

  @override
  String get databaseKey => 'conversation_graph';

  @override
  String get role => 'application_primary_source_scoped_graph';

  @override
  Future<List<Map<String, Object?>>> query(String sql) {
    return _database.selectRows(sql);
  }
}

class OverlayDatabaseHealthQueryLayer extends DatabaseHealthQueryLayer {
  OverlayDatabaseHealthQueryLayer({
    required OverlayDatabase database,
    required this.databasePath,
  }) : _database = database;

  final OverlayDatabase _database;

  @override
  final String databasePath;

  @override
  String get databaseKey => 'overlay';

  @override
  String get role => 'user_overlays';

  @override
  Future<List<Map<String, Object?>>> query(String sql) async {
    final rows = await _database.customSelect(sql).get();
    return rows.map((row) => Map<String, Object?>.from(row.data)).toList();
  }
}
