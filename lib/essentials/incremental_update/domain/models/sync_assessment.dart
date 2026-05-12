import 'package:freezed_annotation/freezed_annotation.dart';

import '../sealed_unions/sync_state.dart';

part 'sync_assessment.freezed.dart';

@freezed
abstract class SyncAssessment with _$SyncAssessment {
  const factory SyncAssessment({required MessageSyncState syncAssessment}) =
      _SyncAssessment;

  const SyncAssessment._();
}
