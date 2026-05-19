import 'package:flutter/foundation.dart';

import '../../../domain/sealed_unions/chat_message_join_import_decision.dart';
import '../importers/chat_message_join_importer.dart';

class ChatMessageJoinImportExecutionOrchestrator {
  ChatMessageJoinImportExecutionOrchestrator({
    required ChatMessageJoinImporter importer,
  }) : _importNewChatMessageJoins = importer.importNewChatMessageJoins;

  @visibleForTesting
  ChatMessageJoinImportExecutionOrchestrator.withImportCallback({
    required Future<ChatMessageJoinImportResult> Function()
    importNewChatMessageJoins,
  }) : _importNewChatMessageJoins = importNewChatMessageJoins;

  final Future<ChatMessageJoinImportResult> Function()
  _importNewChatMessageJoins;
  bool _executionInFlight = false;

  Future<ChatMessageJoinImportResult?> runForDecision(
    ChatMessageJoinImportDecision decision,
  ) async {
    return switch (decision) {
      ChatMessageJoinImportDecisionDoNothing() => null,
      ChatMessageJoinImportDecisionBlockAndReportLedgerAhead() => null,
      ChatMessageJoinImportDecisionConsiderTopologyImport() =>
        _runChatMessageJoinImport(),
    };
  }

  Future<ChatMessageJoinImportResult?> _runChatMessageJoinImport() async {
    if (_executionInFlight) {
      debugPrint(
        'Shadow chat_message_join import skipped: execution in flight.',
      );
      return null;
    }

    _executionInFlight = true;
    try {
      return await _importNewChatMessageJoins();
    } finally {
      _executionInFlight = false;
    }
  }
}
