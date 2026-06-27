import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  final generatedAt = DateTime.now().toUtc();
  final chatDbPath = ref.read(onboardingMessagesDatabasePathProvider);
  if (!ref.read(onboardingFullDiskAccessProvider)) {
    return MessageHistoryCoverageReport(
      status: MessageHistoryCoverageStatus.unknown,
      chatDbTotalCount: null,
      graphConversationLinkedCount: null,
      graphRecoveredOrphanCount: null,
      earliestMessageDate: null,
      latestMessageDate: null,
      generatedAt: generatedAt,
      detail:
          'MessageLens cannot currently read the Messages database on this Mac. Check Full Disk Access and try again.',
    );
  }

  final repository = await ref.read(
    messageHistoryCoverageRepositoryProvider.future,
  );
  final sourceSummary = repository.readChatDbSummary(chatDbPath);
  if (sourceSummary == null) {
    return MessageHistoryCoverageReport(
      status: MessageHistoryCoverageStatus.unknown,
      chatDbTotalCount: null,
      graphConversationLinkedCount: null,
      graphRecoveredOrphanCount: null,
      earliestMessageDate: null,
      latestMessageDate: null,
      generatedAt: generatedAt,
      detail:
          'MessageLens could not safely read message totals from the local Messages database.',
    );
  }

  try {
    final graphSummary = await repository.readGraphSummary();
    final status = classifyMessageHistoryCoverageReport(
      sourceCount: sourceSummary.totalCount,
      accountedCount: graphSummary.totalAccountedCount,
      earliestMessageDate: sourceSummary.earliestMessageDate,
    );

    return MessageHistoryCoverageReport(
      status: status,
      chatDbTotalCount: sourceSummary.totalCount,
      graphConversationLinkedCount: graphSummary.conversationLinkedCount,
      graphRecoveredOrphanCount: graphSummary.recoveredOrphanCount,
      earliestMessageDate: sourceSummary.earliestMessageDate,
      latestMessageDate: sourceSummary.latestMessageDate,
      generatedAt: generatedAt,
    );
  } catch (error, stackTrace) {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'MessageHistoryCoverage: failed to read graph summary',
          source: 'MessageHistoryCoverageSettingsResolver',
          context: <String, Object?>{
            'error': error.toString(),
            'stackTrace': stackTrace.toString(),
          },
        );
    return MessageHistoryCoverageReport(
      status: MessageHistoryCoverageStatus.unknown,
      chatDbTotalCount: sourceSummary.totalCount,
      graphConversationLinkedCount: null,
      graphRecoveredOrphanCount: null,
      earliestMessageDate: sourceSummary.earliestMessageDate,
      latestMessageDate: sourceSummary.latestMessageDate,
      generatedAt: generatedAt,
      detail:
          'MessageLens could not safely read the conversation graph database: $error',
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
