import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart'
    show dbMaintenanceLockProvider;
import '../../../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../../../../essentials/onboarding/feature_level_providers.dart'
    show
        onboardingFullDiskAccessProvider,
        onboardingMessagesDatabasePathProvider;
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../message_history_coverage_repository_provider.dart';
import '../entities/message_history_coverage_report.dart';
import '../entities/message_history_coverage_report_logic.dart';

part 'message_history_coverage_settings_resolver.g.dart';

const _messageHistoryCoverageOverviewBody =
    "MessageLens compares the messages stored in your Mac's Messages database (chat.db) with the messages it has imported and organized.\n\n"
    'This report shows whether everything on this Mac has been accounted for.';

const _messageHistoryCoverageHowToReadBody =
    'Messages on this Mac are grouped into:\n\n'
    '• Messages visible in your chat timelines\n'
    '• Messages recovered but not linked to a conversation\n'
    '• Messages that could not be accounted for\n\n'
    'If no messages are missing, then MessageLens has successfully accounted for everything available on this Mac.';

const _messageHistoryCoverageOlderMessagesBody =
    'This report only reflects the messages stored on this Mac.\n\n'
    'If you expected to see older messages, they may exist on another device or in iCloud but are not present here.';

@riverpod
Future<MessageHistoryCoverageReport> messageHistoryCoverageReport(
  MessageHistoryCoverageReportRef ref,
) async {
  if (ref.watch(dbMaintenanceLockProvider)) {
    return MessageHistoryCoverageReport.temporarilyUnavailable(
      generatedAt: DateTime.now().toUtc(),
      detail:
          'Message History Coverage is temporarily unavailable while MessageLens updates its data.',
    );
  }

  final chatDbPath = ref.read(onboardingMessagesDatabasePathProvider);
  if (!ref.read(onboardingFullDiskAccessProvider)) {
    return MessageHistoryCoverageReport.failed(
      generatedAt: DateTime.now().toUtc(),
      detail:
          'MessageLens cannot currently read the Messages database on this Mac. Check Full Disk Access and try again.',
    );
  }

  try {
    final repository = await ref.read(
      messageHistoryCoverageRepositoryProvider.future,
    );
    final evidence = await repository.readEvidence(
      chatDatabasePath: chatDbPath,
    );
    if (ref.read(dbMaintenanceLockProvider)) {
      return MessageHistoryCoverageReport.temporarilyUnavailable(
        generatedAt: DateTime.now().toUtc(),
        detail:
            'Message History Coverage became unavailable while MessageLens began updating its data.',
      );
    }

    return reconcileMessageHistoryCoverage(
      evidence: evidence,
      generatedAt: DateTime.now().toUtc(),
    );
  } catch (error, stackTrace) {
    if (ref.read(dbMaintenanceLockProvider)) {
      return MessageHistoryCoverageReport.temporarilyUnavailable(
        generatedAt: DateTime.now().toUtc(),
        detail:
            'Message History Coverage is temporarily unavailable while MessageLens updates its data.',
      );
    }
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'MessageHistoryCoverage: reconciliation failed',
          source: 'MessageHistoryCoverageSettingsResolver',
          context: <String, Object?>{
            'error': error.toString(),
            'stackTrace': stackTrace.toString(),
          },
        );
    return MessageHistoryCoverageReport.failed(
      generatedAt: DateTime.now().toUtc(),
      detail:
          'MessageLens could not safely reconcile current message history: $error',
    );
  }
}

@riverpod
class MessageHistoryCoverageSettingsResolver
    extends _$MessageHistoryCoverageSettingsResolver {
  @override
  void build() {}

  StaticFeatureInfoSidebarCassettePayload resolveOverview({
    required int cassetteIndex,
  }) {
    return const StaticFeatureInfoSidebarCassettePayload(
      title: 'Message History Coverage',
      bodyText: _messageHistoryCoverageOverviewBody,
    );
  }

  StaticFeatureInfoSidebarCassettePayload resolveHowToRead({
    required int cassetteIndex,
  }) {
    return const StaticFeatureInfoSidebarCassettePayload(
      title: 'How to read this report',
      bodyText: _messageHistoryCoverageHowToReadBody,
      topSpacing: 10,
    );
  }

  StaticFeatureInfoSidebarCassettePayload resolveOlderMessagesNote({
    required int cassetteIndex,
  }) {
    return const StaticFeatureInfoSidebarCassettePayload(
      title: 'About older messages',
      bodyText: _messageHistoryCoverageOlderMessagesBody,
      topSpacing: 16,
    );
  }
}
