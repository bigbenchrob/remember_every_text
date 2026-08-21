import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages_lineage_admission_service.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages_lineage_anchor_repository.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/messages_lineage_anchor.dart';

void main() {
  group('MessagesLineageAdmissionService', () {
    test('admits sufficient exact matches from either candidate arm', () async {
      final repository = _AnchorRepository(
        current: _anchors(80),
        rawCandidate: _anchors(80),
        messageLensCandidate: _anchors(80),
      );
      final service = MessagesLineageAdmissionService(
        anchorRepository: repository,
        authoritativeCurrentMessagesDatabasePath: '/current/chat.db',
      );

      expect(
        await service.verifyMacMessagesCandidate(
          candidateChatDatabasePath: '/raw/chat.db',
        ),
        isA<SameMessagesLineageAdmission>(),
      );
      expect(
        await service.verifyMessageLensCandidate(
          candidateImportLedgerPath: '/archive/macos_import_ss.db',
        ),
        isA<SameMessagesLineageAdmission>(),
      );
      expect(repository.currentPaths, ['/current/chat.db', '/current/chat.db']);
    });

    test('one same-ROWID different-GUID fact is contradictory', () {
      final evidence = MessagesLineageAdmissionService.compareExactly(
        candidate: _anchors(80),
        current: _anchors(
          80,
          guidForRowId: (id) => id == 40 ? 'other' : 'g$id',
        ),
      );

      expect(
        MessagesLineageAdmission.fromEvidence(evidence),
        isA<ContradictoryMessagesLineageAdmission>(),
      );
      expect(evidence.contradictionCount, 1);
    });

    test('shared GUID at a different ROWID does not prove lineage', () {
      final current = _anchors(80, guidForRowId: (id) => 'g${id + 1000}');
      final evidence = MessagesLineageAdmissionService.compareExactly(
        candidate: _anchors(80),
        current: current,
      );

      expect(
        MessagesLineageAdmission.fromEvidence(evidence),
        isA<ContradictoryMessagesLineageAdmission>(),
      );
    });

    test('small exact source remains insufficient under shared policy', () {
      final evidence = MessagesLineageAdmissionService.compareExactly(
        candidate: _anchors(63),
        current: _anchors(63),
      );

      expect(
        MessagesLineageAdmission.fromEvidence(evidence),
        isA<InsufficientMessagesLineageAdmission>(),
      );
    });

    test('8,882-anchor exact comparison remains sub-perceptual', () {
      final candidate = _anchors(8882);
      final current = _anchors(8882);
      final stopwatch = Stopwatch()..start();

      final evidence = MessagesLineageAdmissionService.compareExactly(
        candidate: candidate,
        current: current,
      );
      stopwatch.stop();

      expect(evidence.matchingCount, 8882);
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 100)));
    });
  });
}

MessagesLineageAnchorEvidence _anchors(
  int count, {
  String Function(int rowId)? guidForRowId,
}) {
  return MessagesLineageAnchorEvidence(
    anchors: [
      for (var id = 1; id <= count; id++)
        MessagesLineageAnchor(
          originalMessagesRowId: id,
          messageGuid: guidForRowId?.call(id) ?? 'g$id',
        ),
    ],
    blankGuidRowIds: const {},
    observedRecordCount: count,
    blankGuidCount: 0,
    inconsistentIdentityCount: 0,
    duplicateRowIdCount: 0,
    sourceShapeIsCoherent: true,
  );
}

final class _AnchorRepository implements MessagesLineageAnchorRepository {
  _AnchorRepository({
    required this.current,
    required this.rawCandidate,
    required this.messageLensCandidate,
  });

  final MessagesLineageAnchorEvidence current;
  final MessagesLineageAnchorEvidence rawCandidate;
  final MessagesLineageAnchorEvidence messageLensCandidate;
  final currentPaths = <String>[];

  @override
  Future<MessagesLineageAnchorEvidence> readMacMessagesDatabase({
    required String databasePath,
  }) async {
    if (databasePath == '/current/chat.db') {
      currentPaths.add(databasePath);
      return current;
    }
    return rawCandidate;
  }

  @override
  Future<MessagesLineageAnchorEvidence> readMessageLensImportLedger({
    required String databasePath,
  }) async => messageLensCandidate;
}
