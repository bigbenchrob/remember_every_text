import 'package:flutter/foundation.dart';

import '../../../domain/sealed_unions/handle_import_decision.dart';
import '../importers/handle_importer.dart';

class HandleImportExecutionOrchestrator {
  HandleImportExecutionOrchestrator({required HandleImporter importer})
    : _importNewHandles = importer.importNewHandles;

  @visibleForTesting
  HandleImportExecutionOrchestrator.withImportCallback({
    required Future<HandleImportResult> Function() importNewHandles,
  }) : _importNewHandles = importNewHandles;

  final Future<HandleImportResult> Function() _importNewHandles;
  bool _executionInFlight = false;

  Future<HandleImportResult?> runForDecision(
    HandleImportDecision decision,
  ) async {
    return switch (decision) {
      HandleImportDecisionDoNothing() => null,
      HandleImportDecisionBlockAndReportLedgerAhead() => null,
      HandleImportDecisionConsiderIncrementalImport() => _runHandleImport(),
    };
  }

  Future<HandleImportResult?> _runHandleImport() async {
    if (_executionInFlight) {
      debugPrint('Shadow handle import skipped: execution in flight.');
      return null;
    }

    _executionInFlight = true;
    try {
      return await _importNewHandles();
    } finally {
      _executionInFlight = false;
    }
  }
}
