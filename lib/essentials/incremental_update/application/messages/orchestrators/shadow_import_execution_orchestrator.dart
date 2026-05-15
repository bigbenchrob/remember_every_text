import 'package:flutter/foundation.dart';

import '../../../domain/sealed_unions/import_decision.dart';
import '../executors/shadow_message_importer.dart';

class ShadowImportExecutionOrchestrator {
  ShadowImportExecutionOrchestrator({required ShadowMessageImporter importer})
    : _importNewMessages = importer.importNewMessages;

  @visibleForTesting
  ShadowImportExecutionOrchestrator.withImportCallback({
    required Future<ShadowMessageImportResult> Function() importNewMessages,
  }) : _importNewMessages = importNewMessages;

  final Future<ShadowMessageImportResult> Function() _importNewMessages;
  bool _executionInFlight = false;

  Future<ShadowMessageImportResult?> runForDecision(
    ImportDecision decision,
  ) async {
    return switch (decision) {
      ImportDecisionDoNothing() => null,
      ImportDecisionBlockAndReportLedgerAhead() => null,
      ImportDecisionConsiderIncrementalImport() => _runIncrementalImport(),
    };
  }

  Future<ShadowMessageImportResult?> _runIncrementalImport() async {
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
