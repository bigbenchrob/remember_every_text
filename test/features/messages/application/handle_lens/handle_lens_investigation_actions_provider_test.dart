import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/identity/live_chat_graph_identity.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_preference_store.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_preference_store_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_source_presentation.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_source_presentation_provider.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/handles/domain/utilities/handle_normalizer.dart';
import 'package:remember_this_text/features/messages/application/handle_lens/handle_lens_investigation_actions_provider.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'successful dismissal advances the investigation and retires center evidence',
    () async {
      final handleId = canonicalLiveChatGraphId(42);
      const endpoint = '74720';
      final overlayDb = OverlayDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          sidebarFlowPreferenceStoreProvider.overrideWith((ref) async {
            return _InMemorySidebarFlowPreferenceStore();
          }),
          handleSourcePresentationProvider(handleId: handleId).overrideWith(
            (ref) async => HandleSourcePresentation(
              canonicalHandleId: handleId,
              primaryDisplayLabel: endpoint,
              rawEndpoint: endpoint,
              statusLabel: 'Unfamiliar source',
              messageCount: 10,
            ),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await overlayDb.close();
      });
      final flowSubscription = container.listen(
        sidebarFlowProvider,
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(flowSubscription.close);

      container
          .read(sidebarFlowProvider.notifier)
          .openStrayHandleLens(handleId: handleId);
      final originatingInvestigationId = container
          .read(sidebarFlowProvider)
          .selectedHandleEvidenceInvestigationId;

      final failure = await container
          .read(handleLensInvestigationActionsProvider.notifier)
          .dismissCurrentSource(handleId: handleId);

      expect(failure, isNull);
      expect(
        await overlayDb.getAllDismissedHandles(),
        contains(normalizeHandleIdentifier(endpoint)),
      );
      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.selectedHandleEvidenceId, handleId);
      expect(
        flowState.selectedHandleEvidenceInvestigationId,
        originatingInvestigationId,
      );
      expect(
        flowState.strayHandleInvestigationId,
        isNot(originatingInvestigationId),
      );
      expect(flowState.effectiveSelectedHandleEvidenceId, isNull);
      expect(
        flowState.projectedCenterSpec,
        equals(
          ViewSpec.messages(
            MessagesSpec.handleInvestigation(
              investigationId: flowState.strayHandleInvestigationId!,
              investigation: StrayHandleInvestigation.identifySources,
              target: const HandleInvestigationTarget.idle(),
            ),
          ),
        ),
      );
    },
  );
}

final class _InMemorySidebarFlowPreferenceStore
    implements SidebarFlowPreferenceStore {
  String? _contactContextPreference;
  String? _navigationPreference;

  @override
  Future<String?> readContactContextPreference() async {
    return _contactContextPreference;
  }

  @override
  Future<String?> readNavigationPreference() async {
    return _navigationPreference;
  }

  @override
  Future<void> writeContactContextPreference(String value) async {
    _contactContextPreference = value;
  }

  @override
  Future<void> writeNavigationPreference(String value) async {
    _navigationPreference = value;
  }
}
