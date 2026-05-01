import '../../../../../core/util/date_converter.dart';
import '../../../db/shared/handle_identifier_utils.dart';
import '../../domain/base_table_importer.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';
import 'identifier_utils.dart';

class HandlesImporter extends BaseTableImporter with RowProgressReporter {
  HandlesImporter();

  @override
  String get name => 'handles';

  @override
  List<String> get dependsOn => const <String>['clear_ledger'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'handles-not-empty',
      'Handles table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final chatSourceId = ctx.chatSourceId;
    if (chatSourceId == null) {
      throw Exception(
        'HandlesImporter requires chatSourceId on the import context',
      );
    }

    final minRowId = ctx.previousMaxHandleRowId;
    final maxRowId = ctx.sourceMaxHandleRowIdAtBatchStart;
    String? whereClause;
    final whereArgs = <Object>[];
    if (minRowId != null) {
      whereClause = 'ROWID > ?';
      whereArgs.add(minRowId);
    }
    if (maxRowId != null) {
      whereClause = whereClause == null
          ? 'ROWID <= ?'
          : '$whereClause AND ROWID <= ?';
      whereArgs.add(maxRowId);
    }

    final rows = await ctx.messagesDb.query(
      'handle',
      where: whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'ROWID ASC',
    );

    if (rows.isEmpty) {
      ctx.info('HandlesImporter: no new handles detected.');
      ctx.writeScratch('handles.inserted', 0);
      ctx.writeScratch('handles.sourceRowIdToLedgerId', <int, int>{});
      return;
    }

    var processed = 0;
    final sourceRowIdToLedgerId = <int, int>{};
    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final rawIdentifier = stripMeaninglessHandlePrefix(row['id'] as String?);
      final normalizedIdentifier = normalizeIdentifier(rawIdentifier);
      final service = sanitizeHandleService(row['service'] as String?);
      final compoundIdentifier = buildCompoundIdentifier(
        normalizedIdentifier: normalizedIdentifier,
        rawIdentifier: rawIdentifier,
        service: service,
      );
      final country = (row['country'] as String?)?.trim();
      final lastSeen =
          DateConverter.toIntSafe(row['last_read_date']) ??
          DateConverter.toIntSafe(row['last_use']);
      final lastSeenUtc = DateConverter.appleToIsoString(lastSeen);

      final ledgerHandleId = await ctx.importDb.insertHandle(
        sourceRowid: sourceRowId,
        service: service,
        rawIdentifier: rawIdentifier ?? 'unknown',
        normalizedIdentifier: normalizedIdentifier,
        compoundIdentifier: compoundIdentifier,
        country: country,
        lastSeenUtc: lastSeenUtc,
        batchId: ctx.batchId,
        sourceId: chatSourceId,
        firstImportBatchId: ctx.batchId,
        lastImportBatchId: ctx.batchId,
      );

      if (sourceRowId != null) {
        sourceRowIdToLedgerId[sourceRowId] = ledgerHandleId;
      }

      processed += 1;
      if (processed % 200 == 0 || processed == rows.length) {
        ctx.info(
          'HandlesImporter: processed $processed/${rows.length} handles from chat.db',
        );
        reportRowProgress(processed: processed, total: rows.length);
      }
    }

    ctx.writeScratch('handles.inserted', processed);
    ctx.writeScratch('handles.sourceRowIdToLedgerId', sourceRowIdToLedgerId);
    if (rows.isNotEmpty) {
      final lastRowId = rows.last['ROWID'];
      if (lastRowId is int) {
        ctx.writeScratch('handles.lastSourceRowId', lastRowId);
      }
    }
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    await expectTrueOrThrow(
      ok: total > 0,
      errorCode: 'handles-empty',
      message: 'Handles table should contain rows after import.',
    );
  }
}
