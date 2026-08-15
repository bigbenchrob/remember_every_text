import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/monitor/chat_db_source_probe_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/feature_level_providers.dart'
    show chatDbSourceProbeReaderProvider;
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/real_messages_source_readiness_test_agent_provider.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/system/macos_full_disk_access.dart';

void main() {
  test('real Agent probes the source on every evaluation', () async {
    final sourceProbe = _RecordingSourceProbeReader();
    final container = ProviderContainer(
      overrides: <Override>[
        chatDbSourceProbeReaderProvider.overrideWithValue(sourceProbe),
      ],
    );
    addTearDown(container.dispose);

    final fullDiskAccess = container.read(fullDiskAccessProvider);
    final agent = container.read(realMessagesSourceReadinessTestAgentProvider);

    expect(fullDiskAccess, isA<MacosFullDiskAccess>());
    expect(await agent.evaluate(), isTrue);
    expect(await agent.evaluate(), isTrue);
    expect(sourceProbe.readInvocationCount, 2);
    expect(sourceProbe.lastPath, endsWith('/Library/Messages/chat.db'));
  });
}

final class _RecordingSourceProbeReader implements ChatDbSourceProbeReader {
  int readInvocationCount = 0;
  String? lastPath;

  @override
  int readMaxRowId(String chatDbPath) {
    readInvocationCount += 1;
    lastPath = chatDbPath;
    return 42;
  }

  @override
  int readImportableMessageCount(String chatDbPath) {
    throw UnsupportedError('The readiness path needs only MAX(ROWID).');
  }
}
