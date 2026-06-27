import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart' show overlayDatabaseProvider;
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../infrastructure/persistence/overlay_sidebar_flow_preference_store.dart';
import 'sidebar_flow_preference_store.dart';

part 'sidebar_flow_preference_store_provider.g.dart';

@riverpod
Future<SidebarFlowPreferenceStore> sidebarFlowPreferenceStore(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  final logger = ref.read(appLoggerProvider.notifier);
  return OverlaySidebarFlowPreferenceStore(
    overlayDatabase: overlayDatabase,
    onReadFailure: (settingKey, error, stackTrace) {
      logger.warn(
        'SidebarFlowPreferenceStore: ignored unreadable persisted sidebar preference',
        source: 'OverlaySidebarFlowPreferenceStore',
        context: <String, Object?>{
          'settingKey': settingKey,
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
    },
    onWriteFailure: (settingKey, settingValue, error, stackTrace) {
      logger.warn(
        'SidebarFlowPreferenceStore: failed to persist sidebar preference',
        source: 'OverlaySidebarFlowPreferenceStore',
        context: <String, Object?>{
          'settingKey': settingKey,
          'settingValue': settingValue,
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
    },
  );
}
