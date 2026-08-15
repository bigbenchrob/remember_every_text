import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/identity/live_chat_graph_identity.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_display_name_provider.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_source_presentation_provider.dart';
import 'package:remember_this_text/features/handles/application/read_models/stray_handle_summary.dart';
import 'package:remember_this_text/features/handles/application/read_models/stray_handles_provider.dart';
import 'package:remember_this_text/features/handles/application/read_models/stray_handles_read_repository.dart';
import 'package:remember_this_text/features/handles/domain/entities/stray_handle_endpoint_kind.dart';

void main() {
  test('uses the resolved display name for one canonical source', () async {
    final handleId = canonicalLiveChatGraphId(42);
    final repository = _RecordingStrayHandlesReadRepository(
      source: StrayHandleSummary(
        handleId: handleId,
        handleValue: '+16043078325',
        serviceType: 'SMS',
        totalMessages: 7,
        endpointKind: StrayHandleEndpointKind.phoneNumber,
      ),
    );
    final container = _container(
      repository: repository,
      displayName: 'Known Source',
      handleId: handleId,
    );
    addTearDown(container.dispose);

    final presentation = await container.read(
      handleSourcePresentationProvider(handleId: handleId).future,
    );

    expect(presentation.canonicalHandleId, handleId);
    expect(presentation.primaryDisplayLabel, 'Known Source');
    expect(presentation.rawEndpoint, '+16043078325');
    expect(presentation.statusLabel, 'Unfamiliar source');
    expect(presentation.messageCount, 7);
    expect(repository.readHandleSourceIds, [handleId]);
    expect(repository.activeListReadCount, 0);
  });

  test(
    'falls back to the raw endpoint when no display name resolves',
    () async {
      final handleId = canonicalLiveChatGraphId(43);
      final container = _container(
        repository: _RecordingStrayHandlesReadRepository(
          source: StrayHandleSummary(
            handleId: handleId,
            handleValue: 'unknown@example.com',
            serviceType: 'iMessage',
            totalMessages: 2,
            endpointKind: StrayHandleEndpointKind.emailAddress,
          ),
        ),
        displayName: '   ',
        handleId: handleId,
      );
      addTearDown(container.dispose);

      final presentation = await container.read(
        handleSourcePresentationProvider(handleId: handleId).future,
      );

      expect(presentation.primaryDisplayLabel, 'unknown@example.com');
    },
  );

  test('falls back to the canonical ID when source facts are absent', () async {
    final handleId = canonicalLiveChatGraphId(44);
    final container = _container(
      repository: _RecordingStrayHandlesReadRepository(source: null),
      displayName: '',
      handleId: handleId,
    );
    addTearDown(container.dispose);

    final presentation = await container.read(
      handleSourcePresentationProvider(handleId: handleId).future,
    );

    expect(presentation.primaryDisplayLabel, 'Handle #$handleId');
    expect(presentation.rawEndpoint, isNull);
    expect(presentation.messageCount, 0);
  });
}

ProviderContainer _container({
  required _RecordingStrayHandlesReadRepository repository,
  required String displayName,
  required int handleId,
}) {
  return ProviderContainer(
    overrides: [
      strayHandlesReadRepositoryProvider.overrideWith(
        (ref) async => repository,
      ),
      handleDisplayNameProvider(
        handleId: handleId,
      ).overrideWith((ref) async => displayName),
    ],
  );
}

final class _RecordingStrayHandlesReadRepository
    implements StrayHandlesReadRepository {
  _RecordingStrayHandlesReadRepository({required this.source});

  final StrayHandleSummary? source;
  final List<int> readHandleSourceIds = <int>[];
  int activeListReadCount = 0;

  @override
  Future<StrayHandleSummary?> readHandleSource({required int handleId}) async {
    readHandleSourceIds.add(handleId);
    return source;
  }

  @override
  Future<List<StrayHandleSummary>> readActiveStrayHandles() async {
    activeListReadCount += 1;
    return const <StrayHandleSummary>[];
  }

  @override
  Future<List<StrayHandleSummary>> readDismissedStrayHandles() async {
    return const <StrayHandleSummary>[];
  }
}
