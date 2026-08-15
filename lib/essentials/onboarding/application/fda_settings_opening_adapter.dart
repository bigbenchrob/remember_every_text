import '../../presence/domain/services/fda_settings_opening_authority.dart';
import 'full_disk_access.dart';

/// Adapts onboarding's FDA service to the transitional Presence action port.
final class FdaSettingsOpeningAdapter implements FdaSettingsOpeningAuthority {
  const FdaSettingsOpeningAdapter({required FullDiskAccess fullDiskAccess})
    : _fullDiskAccess = fullDiskAccess;

  final FullDiskAccess _fullDiskAccess;

  @override
  Future<void> openSettings() => _fullDiskAccess.openSettings();
}
