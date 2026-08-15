import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart'
    show DisplayIdentityResolver, displayIdentityResolverProvider;
import 'package:remember_this_text/features/messages/application/message_evidence/recovered_message_evidence_provider.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/recovered_message_evidence.dart';
import 'package:remember_this_text/features/messages/presentation/view/recovered_messages_evidence_view.dart';

void main() {
  group('RecoveredMessagesEvidenceView', () {
    testWidgets('renders recovered messages through evidence spine', (
      tester,
    ) async {
      final messages = _buildRecoveredMessages();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            displayIdentityResolverProvider.overrideWith((ref) async {
              return const DisplayIdentityResolver(identitiesByHandleKey: {});
            }),
            recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith(
              (ref) =>
                  Stream<List<RecoveredUnlinkedMessageItem>>.value(messages),
            ),
          ],
          child: const MacosApp(
            home: MacosWindow(
              child: SizedBox(
                width: 960,
                height: 720,
                child: RecoveredMessagesEvidenceView(contactId: 7),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Recovered deleted messages'), findsOneWidget);
      expect(find.text('alpha note'), findsOneWidget);
      expect(find.text('beta archive'), findsOneWidget);
      expect(find.text('receipt.png'), findsOneWidget);
    });

    testWidgets('filters recovered messages through evidence match ids', (
      tester,
    ) async {
      final messages = _buildRecoveredMessages();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            displayIdentityResolverProvider.overrideWith((ref) async {
              return const DisplayIdentityResolver(identitiesByHandleKey: {});
            }),
            recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith(
              (ref) =>
                  Stream<List<RecoveredUnlinkedMessageItem>>.value(messages),
            ),
          ],
          child: const MacosApp(
            home: MacosWindow(
              child: SizedBox(
                width: 960,
                height: 720,
                child: RecoveredMessagesEvidenceView(contactId: 7),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(MacosTextField), 'receipt');
      await tester.pumpAndSettle();

      expect(find.text('alpha note'), findsNothing);
      expect(find.text('beta archive'), findsOneWidget);
      expect(
        find.text('1 of 2 recovered messages match "receipt"'),
        findsOneWidget,
      );
    });

    testWidgets(
      'continues metadata and controls after its shared Track A title',
      (tester) async {
        final messages = _buildRecoveredMessages();
        final matrix = _resolvedRecoveredHeaderMatrix();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              displayIdentityResolverProvider.overrideWith((ref) async {
                return const DisplayIdentityResolver(identitiesByHandleKey: {});
              }),
              recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith(
                (ref) =>
                    Stream<List<RecoveredUnlinkedMessageItem>>.value(messages),
              ),
            ],
            child: MacosApp(
              home: ResolvedTrackLayoutMatrixScope(
                matrix: matrix,
                child: const MacosWindow(
                  child: SizedBox(
                    width: 960,
                    height: 720,
                    child: RecoveredMessagesEvidenceView(contactId: 7),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Recovered deleted messages'), findsOneWidget);
        expect(
          find.text(
            'Recovered deleted-message candidates associated with this contact.',
          ),
          findsOneWidget,
        );
        expect(find.text('Search recovered messages'), findsOneWidget);
        expect(find.byType(TrackCellView), findsOneWidget);
        expect(
          tester.widget<TrackCellView>(find.byType(TrackCellView)).cellId,
          const CellId(
            trackId: TrackId.trackA,
            columnId: TrackColumnId.column2,
          ),
        );
      },
    );
  });
}

ResolvedTrackLayoutMatrix _resolvedRecoveredHeaderMatrix() {
  final matrix = PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: const [TrackId.trackA],
    columnIds: TrackColumnId.values,
    cells: const [
      MatrixCell<TrackOccupant>.occupied(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column1,
        ),
        occupant: FixedHeightTrackOccupant(height: 40),
      ),
      MatrixCell<TrackOccupant>.occupied(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column2,
        ),
        occupant: TextTrackOccupant(
          text: 'Recovered deleted messages',
          style: TextStyle(fontSize: 20),
        ),
      ),
      MatrixCell<TrackOccupant>.empty(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column3,
        ),
      ),
    ],
  );
  return ResolvedTrackLayoutMatrix.resolve(
    matrix: matrix,
    constraints: const PresentationConstraints(
      availableWidth: 960,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    ),
  );
}

List<RecoveredUnlinkedMessageItem> _buildRecoveredMessages() {
  return <RecoveredUnlinkedMessageItem>[
    RecoveredUnlinkedMessageItem(
      id: 10,
      guid: 'recovered-10',
      senderHandleId: null,
      contactName: null,
      rawItemType: null,
      rawAssociatedMessageType: null,
      semanticKind: 'plain-text',
      isSparseArtifact: false,
      isFromMe: false,
      isInferred: false,
      senderLabel: 'Alice',
      service: 'iMessage',
      text: 'alpha note',
      sentAt: DateTime(2024, 1, 10),
      itemType: 'text',
      hasAttachments: false,
      attachmentCount: 0,
      attachments: const <AttachmentInfo>[],
    ),
    RecoveredUnlinkedMessageItem(
      id: 20,
      guid: 'recovered-20',
      senderHandleId: null,
      contactName: null,
      rawItemType: null,
      rawAssociatedMessageType: null,
      semanticKind: 'plain-text',
      isSparseArtifact: false,
      isFromMe: false,
      isInferred: false,
      senderLabel: 'Bob',
      service: 'SMS',
      text: 'beta archive',
      sentAt: DateTime(2024, 2, 20),
      itemType: 'text',
      hasAttachments: true,
      attachmentCount: 1,
      attachments: const <AttachmentInfo>[
        AttachmentInfo(
          id: 501,
          localPath: null,
          mimeType: 'image/png',
          transferName: 'receipt.png',
        ),
      ],
    ),
  ];
}
