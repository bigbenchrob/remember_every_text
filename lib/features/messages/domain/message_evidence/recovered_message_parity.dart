import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'recovered_message_evidence.dart';

class RecoveredMessageParityReport {
  const RecoveredMessageParityReport({
    required this.legacyCount,
    required this.graphRecoveredCount,
    required this.matchedRecoveredCount,
    required this.legacyNowProjectableCount,
    required this.legacyOnlyCount,
    required this.suppressedLegacyOnlyCount,
    required this.unresolvedLegacyOnlyCount,
    required this.graphOnlyCount,
    required this.attachmentCountMismatchCount,
    required this.guidMismatchCount,
    required this.textMismatchCount,
    required this.legacyOnlySamples,
    required this.graphOnlySamples,
    required this.nowProjectableSamples,
    required this.textMismatchSamples,
  });

  final int legacyCount;
  final int graphRecoveredCount;
  final int matchedRecoveredCount;
  final int legacyNowProjectableCount;
  final int legacyOnlyCount;
  final int suppressedLegacyOnlyCount;
  final int unresolvedLegacyOnlyCount;
  final int graphOnlyCount;
  final int attachmentCountMismatchCount;
  final int guidMismatchCount;
  final int textMismatchCount;
  final List<RecoveredMessageParitySample> legacyOnlySamples;
  final List<RecoveredMessageParitySample> graphOnlySamples;
  final List<RecoveredMessageParitySample> nowProjectableSamples;
  final List<RecoveredMessageTextMismatchSample> textMismatchSamples;

  bool get hasLegacyOnlyRows => legacyOnlyCount > 0;

  bool get hasUnresolvedLegacyOnlyRows => unresolvedLegacyOnlyCount > 0;

  bool get hasEvidenceMismatches =>
      attachmentCountMismatchCount > 0 ||
      guidMismatchCount > 0 ||
      textMismatchCount > 0;

  bool get matchedEvidenceParityPasses => !hasEvidenceMismatches;

  bool get canCutOverWithoutEvidenceLoss =>
      !hasUnresolvedLegacyOnlyRows && !hasEvidenceMismatches;

  bool get requiresCompatibilityRetention => hasUnresolvedLegacyOnlyRows;
}

class RecoveredMessageParitySample {
  const RecoveredMessageParitySample({
    required this.messageId,
    required this.guid,
    required this.sentAt,
    required this.textPreview,
  });

  final int messageId;
  final String guid;
  final DateTime? sentAt;
  final String textPreview;
}

class RecoveredMessageTextMismatchSample {
  const RecoveredMessageTextMismatchSample({
    required this.legacyMessageId,
    required this.graphMessageId,
    required this.guid,
    required this.sentAt,
    required this.legacyTextPreview,
    required this.graphTextPreview,
  });

  final int legacyMessageId;
  final int graphMessageId;
  final String guid;
  final DateTime? sentAt;
  final String legacyTextPreview;
  final String graphTextPreview;
}

RecoveredMessageParityReport compareRecoveredMessageEvidence({
  required List<RecoveredUnlinkedMessageItem> legacyMessages,
  required List<RecoveredUnlinkedMessageItem> graphRecoveredMessages,
  required Set<int> graphProjectableMessageIds,
  required int legacyRecoveredSourceId,
  Set<int> suppressedLegacyMessageIds = const <int>{},
  int sampleLimit = 10,
}) {
  final legacyByGraphId = <int, RecoveredUnlinkedMessageItem>{
    for (final message in legacyMessages)
      SourceScopedRowKey.pack(
        sourceId: legacyRecoveredSourceId,
        sourceRowId: message.id,
      ): message,
  };
  final graphRecoveredById = <int, RecoveredUnlinkedMessageItem>{
    for (final message in graphRecoveredMessages) message.id: message,
  };

  var matchedRecoveredCount = 0;
  var legacyNowProjectableCount = 0;
  var legacyOnlyCount = 0;
  var suppressedLegacyOnlyCount = 0;
  var unresolvedLegacyOnlyCount = 0;
  var attachmentCountMismatchCount = 0;
  var guidMismatchCount = 0;
  var textMismatchCount = 0;
  final legacyOnlySamples = <RecoveredMessageParitySample>[];
  final nowProjectableSamples = <RecoveredMessageParitySample>[];
  final textMismatchSamples = <RecoveredMessageTextMismatchSample>[];

  for (final entry in legacyByGraphId.entries) {
    final graphId = entry.key;
    final legacyMessage = entry.value;
    final graphMessage = graphRecoveredById[graphId];
    if (graphMessage != null) {
      matchedRecoveredCount += 1;
      if (legacyMessage.attachmentCount != graphMessage.attachmentCount) {
        attachmentCountMismatchCount += 1;
      }
      if (legacyMessage.guid.trim() != graphMessage.guid.trim()) {
        guidMismatchCount += 1;
      }
      if (_normalizeText(legacyMessage.text) !=
          _normalizeText(graphMessage.text)) {
        textMismatchCount += 1;
        _addSample(
          textMismatchSamples,
          _textMismatchSampleForMessages(
            legacyMessage: legacyMessage,
            graphMessage: graphMessage,
          ),
          sampleLimit,
        );
      }
      continue;
    }

    if (graphProjectableMessageIds.contains(graphId)) {
      legacyNowProjectableCount += 1;
      _addSample(
        nowProjectableSamples,
        _sampleForMessage(legacyMessage),
        sampleLimit,
      );
      continue;
    }

    legacyOnlyCount += 1;
    if (suppressedLegacyMessageIds.contains(legacyMessage.id)) {
      suppressedLegacyOnlyCount += 1;
      continue;
    }

    unresolvedLegacyOnlyCount += 1;
    _addSample(
      legacyOnlySamples,
      _sampleForMessage(legacyMessage),
      sampleLimit,
    );
  }

  final graphOnlySamples = <RecoveredMessageParitySample>[];
  var graphOnlyCount = 0;
  for (final graphMessage in graphRecoveredMessages) {
    if (legacyByGraphId.containsKey(graphMessage.id)) {
      continue;
    }
    graphOnlyCount += 1;
    _addSample(graphOnlySamples, _sampleForMessage(graphMessage), sampleLimit);
  }

  return RecoveredMessageParityReport(
    legacyCount: legacyMessages.length,
    graphRecoveredCount: graphRecoveredMessages.length,
    matchedRecoveredCount: matchedRecoveredCount,
    legacyNowProjectableCount: legacyNowProjectableCount,
    legacyOnlyCount: legacyOnlyCount,
    suppressedLegacyOnlyCount: suppressedLegacyOnlyCount,
    unresolvedLegacyOnlyCount: unresolvedLegacyOnlyCount,
    graphOnlyCount: graphOnlyCount,
    attachmentCountMismatchCount: attachmentCountMismatchCount,
    guidMismatchCount: guidMismatchCount,
    textMismatchCount: textMismatchCount,
    legacyOnlySamples: legacyOnlySamples,
    graphOnlySamples: graphOnlySamples,
    nowProjectableSamples: nowProjectableSamples,
    textMismatchSamples: textMismatchSamples,
  );
}

String _normalizeText(String value) {
  final trimmed = value.trim();
  if (_isNoPreservedContentFallback(trimmed)) {
    return '<no-preserved-content>';
  }
  return trimmed;
}

bool _isNoPreservedContentFallback(String value) {
  return switch (value) {
    '(Sparse artifact: no preserved text or payload)' ||
    '(No preserved content)' ||
    '(No plain text content; summary metadata preserved)' ||
    '(No plain text content; app or balloon payload preserved)' ||
    '(Associated message carrier without plain text)' ||
    '(No text content)' ||
    '(No plain text content)' => true,
    _ => false,
  };
}

RecoveredMessageParitySample _sampleForMessage(
  RecoveredUnlinkedMessageItem message,
) {
  return RecoveredMessageParitySample(
    messageId: message.id,
    guid: message.guid,
    sentAt: message.sentAt,
    textPreview: _preview(message.text),
  );
}

RecoveredMessageTextMismatchSample _textMismatchSampleForMessages({
  required RecoveredUnlinkedMessageItem legacyMessage,
  required RecoveredUnlinkedMessageItem graphMessage,
}) {
  return RecoveredMessageTextMismatchSample(
    legacyMessageId: legacyMessage.id,
    graphMessageId: graphMessage.id,
    guid: legacyMessage.guid,
    sentAt: legacyMessage.sentAt,
    legacyTextPreview: _preview(legacyMessage.text),
    graphTextPreview: _preview(graphMessage.text),
  );
}

String _preview(String value) {
  final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.length <= 80) {
    return normalized;
  }
  return normalized.substring(0, 80);
}

void _addSample<T>(List<T> samples, T sample, int sampleLimit) {
  if (samples.length >= sampleLimit) {
    return;
  }
  samples.add(sample);
}
