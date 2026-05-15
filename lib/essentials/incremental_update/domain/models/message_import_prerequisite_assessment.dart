import 'package:freezed_annotation/freezed_annotation.dart';

import 'message_import_blocker.dart';

part 'message_import_prerequisite_assessment.freezed.dart';

@freezed
abstract class MessageImportPrerequisiteAssessment
    with _$MessageImportPrerequisiteAssessment {
  const factory MessageImportPrerequisiteAssessment({
    required List<MessageImportBlocker> blockers,
  }) = _MessageImportPrerequisiteAssessment;

  const MessageImportPrerequisiteAssessment._();

  bool get isSatisfied => blockers.isEmpty;
  bool get isBlocked => blockers.isNotEmpty;
}
