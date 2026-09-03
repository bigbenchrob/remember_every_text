import 'dart:convert';

import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/onboarding_operation_snapshot_store.dart';
import '../../domain/onboarding_operation_snapshot.dart';

final class OverlayOnboardingOperationSnapshotStore
    implements OnboardingOperationSnapshotStore {
  OverlayOnboardingOperationSnapshotStore({
    required Future<OverlayDatabase> overlayDatabase,
  }) : _overlayDatabase = overlayDatabase;

  static const String settingKey = onboardingOperationSnapshotSettingKey;

  final Future<OverlayDatabase> _overlayDatabase;

  @override
  Future<OnboardingOperationSnapshot?> load() async {
    final database = await _overlayDatabase;
    final raw = await database.readOverlaySetting(settingKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Invalid onboarding operation snapshot.');
    }
    return OnboardingOperationSnapshot.fromJson(decoded);
  }

  @override
  Future<void> save(OnboardingOperationSnapshot snapshot) async {
    final database = await _overlayDatabase;
    await database.writeOverlaySetting(
      settingKey: settingKey,
      settingValue: jsonEncode(snapshot.toJson()),
    );
  }
}
