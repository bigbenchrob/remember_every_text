import 'package:freezed_annotation/freezed_annotation.dart';

part 'environment_readiness_view_spec.freezed.dart';

@freezed
abstract class EnvironmentReadinessSpec with _$EnvironmentReadinessSpec {
  const factory EnvironmentReadinessSpec.readinessPanel() = _ReadinessPanel;
}
