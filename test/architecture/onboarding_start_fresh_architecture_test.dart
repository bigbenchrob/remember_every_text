import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Start Fresh is typed, authorized, and verified', () {
    final service = File(
      'lib/essentials/onboarding/application/start_fresh_service.dart',
    ).readAsStringSync();
    final provider = File(
      'lib/essentials/onboarding/application/start_fresh_service_provider.dart',
    ).readAsStringSync();

    expect(service, contains('MessageLensInstallationState'));
    expect(service, contains('ArchiveMutationCapability'));
    expect(service, contains('resetDerivedDataForStartFresh'));
    expect(service, contains('MessageLensInstallationStateKind.virgin'));
    expect(provider, contains('ArchiveMutationOperation.startFresh'));
  });

  test('Start Fresh targets only canonical derived database base names', () {
    final resetService = File(
      'lib/essentials/onboarding/application/message_data_reset_service.dart',
    ).readAsStringSync();
    final fileStore = File(
      'lib/essentials/onboarding/infrastructure/persistence/'
      'filesystem_derived_message_data_file_store.dart',
    ).readAsStringSync();

    expect(resetService, contains('AppDatabaseFile.sourceScopedImport'));
    expect(resetService, contains('AppDatabaseFile.conversationGraph'));
    expect(resetService, isNot(contains('attachment_archive')));
    expect(fileStore, contains('_validatedDatabaseBaseName'));
    expect(fileStore, isNot(contains('delete(recursive: true)')));
  });

  test('startup has no reachable reset no-op or destructive old label', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, contains('startFreshServiceProvider'));
    expect(mainSource, contains("This MessageLens setup wasn't completed"));
    expect(mainSource, isNot(contains('Delete MessageLens App Data')));
    expect(mainSource, isNot(contains("logger.warn('Delete requested'")));
  });

  test('operation policy blocks database reopen during Start Fresh', () {
    final operationPolicy = File(
      'lib/essentials/archive_environment/domain/'
      'archive_mutation_operation.dart',
    ).readAsStringSync();

    expect(operationPolicy, contains('ArchiveMutationOperation.startFresh'));
    expect(operationPolicy, contains('blocksDatabaseReopen'));
  });

  test('advanced Start Fresh owns presentation before mutation', () {
    final actionProvider = File(
      'lib/essentials/onboarding/application/'
      'advanced_start_fresh_action_provider.dart',
    ).readAsStringSync();
    final action = File(
      'lib/essentials/onboarding/application/advanced_start_fresh_action.dart',
    ).readAsStringSync();
    final shell = File(
      'lib/essentials/navigation/presentation/view/macos_app_shell.dart',
    ).readAsStringSync();

    expect(actionProvider, contains('@Riverpod(keepAlive: true)'));
    expect(action, contains('presentation.beginPreparing()'));
    expect(action, contains('await waitForPresentationFrame()'));
    expect(shell, contains('AdvancedStartFreshOverlayHost'));
  });

  test('Start Fresh reuses the executable Onboarding Presence composition', () {
    final provider = File(
      'lib/essentials/onboarding/application/start_fresh_service_provider.dart',
    ).readAsStringSync();

    expect(
      provider,
      contains('requiredSourcesReadinessRepositoryProvider.future'),
    );
    expect(
      provider,
      isNot(contains('presenceScheduleMaintenanceRepositoryProvider.future')),
    );
  });
}
