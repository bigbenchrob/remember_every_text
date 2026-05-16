import 'package:flutter/foundation.dart';

import '../../../domain/sealed_unions/chat_import_decision.dart';
import '../importers/chat_importer.dart';

class ChatImportExecutionOrchestrator {
  ChatImportExecutionOrchestrator({required ChatImporter importer})
    : _importNewChats = importer.importNewChats;

  @visibleForTesting
  ChatImportExecutionOrchestrator.withImportCallback({
    required Future<ChatImportResult> Function() importNewChats,
  }) : _importNewChats = importNewChats;

  final Future<ChatImportResult> Function() _importNewChats;
  bool _executionInFlight = false;

  Future<ChatImportResult?> runForDecision(ChatImportDecision decision) async {
    return switch (decision) {
      ChatImportDecisionDoNothing() => null,
      ChatImportDecisionBlockAndReportLedgerAhead() => null,
      ChatImportDecisionConsiderIncrementalImport() => _runChatImport(),
    };
  }

  Future<ChatImportResult?> _runChatImport() async {
    if (_executionInFlight) {
      debugPrint('Shadow chat import skipped: execution in flight.');
      return null;
    }

    _executionInFlight = true;
    try {
      return await _importNewChats();
    } finally {
      _executionInFlight = false;
    }
  }
}
