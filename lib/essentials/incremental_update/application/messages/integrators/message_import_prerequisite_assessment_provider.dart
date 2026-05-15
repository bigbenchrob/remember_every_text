import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/message_import_prerequisite_assessment.dart';
import '../../chats/integrators/chat_sync_state_provider.dart';
import '../../handles/integrators/handle_sync_state_provider.dart';
import 'message_import_prerequisite_assessment_integrator.dart';

part 'message_import_prerequisite_assessment_provider.g.dart';

@riverpod
Future<MessageImportPrerequisiteAssessment> messageImportPrerequisiteAssessment(
  Ref ref,
) async {
  final handleSyncState = await ref.watch(handleSyncStateProvider.future);
  final chatSyncState = await ref.watch(chatSyncStateProvider.future);

  return const MessageImportPrerequisiteAssessmentIntegrator().integrate(
    handleSyncState: handleSyncState,
    chatSyncState: chatSyncState,
  );
}
