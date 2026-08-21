import '../domain/messages_lineage_admission.dart';
import '../domain/messages_lineage_anchor.dart';
import 'messages_lineage_admission_authority.dart';
import 'messages_lineage_anchor_repository.dart';

final class MessagesLineageAdmissionService
    implements MessagesLineageAdmissionAuthority {
  const MessagesLineageAdmissionService({
    required MessagesLineageAnchorRepository anchorRepository,
    required String authoritativeCurrentMessagesDatabasePath,
  }) : _anchorRepository = anchorRepository,
       _authoritativeCurrentMessagesDatabasePath =
           authoritativeCurrentMessagesDatabasePath;

  static const int _rowIdBandCount = 4;

  final MessagesLineageAnchorRepository _anchorRepository;
  final String _authoritativeCurrentMessagesDatabasePath;

  @override
  Future<MessagesLineageAdmission> verifyMacMessagesCandidate({
    required String candidateChatDatabasePath,
  }) async {
    final candidate = await _anchorRepository.readMacMessagesDatabase(
      databasePath: candidateChatDatabasePath,
    );
    return _compareWithCurrent(candidate);
  }

  @override
  Future<MessagesLineageAdmission> verifyMessageLensCandidate({
    required String candidateImportLedgerPath,
  }) async {
    final candidate = await _anchorRepository.readMessageLensImportLedger(
      databasePath: candidateImportLedgerPath,
    );
    return _compareWithCurrent(candidate);
  }

  Future<MessagesLineageAdmission> _compareWithCurrent(
    MessagesLineageAnchorEvidence candidate,
  ) async {
    final current = await _anchorRepository.readMacMessagesDatabase(
      databasePath: _authoritativeCurrentMessagesDatabasePath,
    );
    final evidence = compareExactly(candidate: candidate, current: current);
    return MessagesLineageAdmission.fromEvidence(evidence);
  }

  static MessagesLineageEvidence compareExactly({
    required MessagesLineageAnchorEvidence candidate,
    required MessagesLineageAnchorEvidence current,
  }) {
    if (candidate.anchors.isEmpty) {
      return _emptyEvidence(candidate: candidate, current: current);
    }

    final currentGuidByRowId = <int, String>{
      for (final anchor in current.anchors)
        anchor.originalMessagesRowId: anchor.messageGuid,
    };
    final minimumCandidateRowId = candidate.anchors.first.originalMessagesRowId;
    final maximumCandidateRowId = candidate.anchors.last.originalMessagesRowId;

    var currentRowsInCandidateRangeCount = 0;
    for (final anchor in current.anchors) {
      if (anchor.originalMessagesRowId >= minimumCandidateRowId &&
          anchor.originalMessagesRowId <= maximumCandidateRowId) {
        currentRowsInCandidateRangeCount += 1;
      }
    }

    var comparableCount = 0;
    var matchingCount = 0;
    var contradictionCount = 0;
    var missingCurrentRowCount = 0;
    var unusableCurrentGuidCount = 0;
    final matchingBands = <int>{};

    for (final candidateAnchor in candidate.anchors) {
      final currentGuid =
          currentGuidByRowId[candidateAnchor.originalMessagesRowId];
      if (currentGuid == null) {
        if (current.blankGuidRowIds.contains(
          candidateAnchor.originalMessagesRowId,
        )) {
          unusableCurrentGuidCount += 1;
          continue;
        }
        missingCurrentRowCount += 1;
        continue;
      }

      comparableCount += 1;
      if (currentGuid == candidateAnchor.messageGuid) {
        matchingCount += 1;
        matchingBands.add(
          _rowIdBand(
            rowId: candidateAnchor.originalMessagesRowId,
            minimumRowId: minimumCandidateRowId,
            maximumRowId: maximumCandidateRowId,
          ),
        );
      } else {
        contradictionCount += 1;
      }
    }

    return MessagesLineageEvidence(
      candidateRecordCount: candidate.observedRecordCount,
      usableCandidateIdentityCount: candidate.anchors.length,
      blankCandidateGuidCount: candidate.blankGuidCount,
      inconsistentCandidateIdentityCount: candidate.inconsistentIdentityCount,
      duplicateCandidateRowIdCount: candidate.duplicateRowIdCount,
      currentRowsInCandidateRangeCount: currentRowsInCandidateRangeCount,
      comparableCount: comparableCount,
      matchingCount: matchingCount,
      contradictionCount: contradictionCount,
      missingCurrentRowCount: missingCurrentRowCount,
      unusableCurrentGuidCount: unusableCurrentGuidCount,
      matchingRowIdBandCount: matchingBands.length,
      candidateSourceShapeIsCoherent: candidate.sourceShapeIsCoherent,
      currentSourceShapeIsCoherent: current.sourceShapeIsCoherent,
    );
  }

  static MessagesLineageEvidence _emptyEvidence({
    required MessagesLineageAnchorEvidence candidate,
    required MessagesLineageAnchorEvidence current,
  }) {
    return MessagesLineageEvidence(
      candidateRecordCount: candidate.observedRecordCount,
      usableCandidateIdentityCount: 0,
      blankCandidateGuidCount: candidate.blankGuidCount,
      inconsistentCandidateIdentityCount: candidate.inconsistentIdentityCount,
      duplicateCandidateRowIdCount: candidate.duplicateRowIdCount,
      currentRowsInCandidateRangeCount: 0,
      comparableCount: 0,
      matchingCount: 0,
      contradictionCount: 0,
      missingCurrentRowCount: 0,
      unusableCurrentGuidCount: current.blankGuidCount,
      matchingRowIdBandCount: 0,
      candidateSourceShapeIsCoherent: candidate.sourceShapeIsCoherent,
      currentSourceShapeIsCoherent: current.sourceShapeIsCoherent,
    );
  }

  static int _rowIdBand({
    required int rowId,
    required int minimumRowId,
    required int maximumRowId,
  }) {
    final span = maximumRowId - minimumRowId + 1;
    final band = ((rowId - minimumRowId) * _rowIdBandCount) ~/ span;
    return band.clamp(0, _rowIdBandCount - 1);
  }
}
