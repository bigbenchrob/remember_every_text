import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_spec.freezed.dart';

@freezed
abstract class SettingsSpec with _$SettingsSpec {
  const factory SettingsSpec.contactShortNames() = _SettingsContactShortNames;

  const SettingsSpec._();
}
