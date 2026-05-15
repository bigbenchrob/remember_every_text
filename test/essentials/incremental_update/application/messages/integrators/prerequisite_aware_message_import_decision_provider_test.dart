import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/incremental_update/application/chats/integrators/chat_sync_state_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/handles/integrators/handle_sync_state_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/import_decision_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/message_import_prerequisite_assessment_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/integrators/prerequisite_aware_message_import_decision_provider.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_import_blocker.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/chat_sync_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/handle_sync_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/prerequisite_aware_message_import_decision.dart';

void main() {
  group('prerequisite-aware message import provider chain', () {
    test('composes satisfied prerequisites with base import decision', () async {
      final container = ProviderContainer(
        overrides: <Override>[
          importDecisionProvider.overrideWith(
            (ref) async => const ImportDecision.considerIncrementalImport(),
          ),
          handleSyncStateProvider.overrideWith(
            (ref) async => const HandleSyncState.sourceAndLedgerCursorsMatch(),
          ),
          chatSyncStateProvider.overrideWith(
            (ref) async => const ChatSyncState.sourceAndLedgerCursorsMatch(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final assessment = await container.read(
        messageImportPrerequisiteAssessmentProvider.future,
      );
      final decision = await container.read(
        prerequisiteAwareMessageImportDecisionProvider.future,
      );

      expect(assessment.isSatisfied, isTrue);
      expect(
        decision,
        const PrerequisiteAwareMessageImportDecision.considerIncrementalImport(),
      );
    });

    test('composes multiple prerequisite blockers without execution', () async {
      final container = ProviderContainer(
        overrides: <Override>[
          importDecisionProvider.overrideWith(
            (ref) async => const ImportDecision.considerIncrementalImport(),
          ),
          handleSyncStateProvider.overrideWith(
            (ref) async => const HandleSyncState.sourceAheadOfLedger(),
          ),
          chatSyncStateProvider.overrideWith(
            (ref) async => const ChatSyncState.sourceAheadOfLedger(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final assessment = await container.read(
        messageImportPrerequisiteAssessmentProvider.future,
      );
      final decision = await container.read(
        prerequisiteAwareMessageImportDecisionProvider.future,
      );

      expect(assessment.blockers, <MessageImportBlocker>[
        MessageImportBlocker.handlesNotReady,
        MessageImportBlocker.chatsNotReady,
      ]);
      expect(
        decision,
        const PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites(
          blockers: <MessageImportBlocker>[
            MessageImportBlocker.handlesNotReady,
            MessageImportBlocker.chatsNotReady,
          ],
        ),
      );
    });
  });
}
