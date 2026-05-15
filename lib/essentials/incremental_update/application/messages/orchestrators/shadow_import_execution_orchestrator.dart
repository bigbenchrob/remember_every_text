import 'package:flutter/foundation.dart';

import '../../../domain/sealed_unions/import_decision.dart';
import '../executors/message_importer.dart';

class ShadowImportExecutionOrchestrator {
  ShadowImportExecutionOrchestrator({required MessageImporter importer})
    : _importNewMessages = importer.importNewMessages;

  @visibleForTesting
  ShadowImportExecutionOrchestrator.withImportCallback({
    required Future<MessageImportResult> Function() importNewMessages,
  }) : _importNewMessages = importNewMessages;

  final Future<MessageImportResult> Function() _importNewMessages;
  bool _executionInFlight = false;

  Future<MessageImportResult?> runForDecision(ImportDecision decision) async {
    return switch (decision) {
      ImportDecisionDoNothing() => null,
      ImportDecisionBlockAndReportLedgerAhead() => null,
      ImportDecisionConsiderIncrementalImport() => _runIncrementalImport(),
    };
  }

  Future<MessageImportResult?> _runIncrementalImport() async {
    if (_executionInFlight) {
      debugPrint('Shadow message import skipped: execution in flight.');
      return null;
    }

    _executionInFlight = true;
    try {
      return await _importNewMessages();
    } finally {
      _executionInFlight = false;
    }
  }
}
