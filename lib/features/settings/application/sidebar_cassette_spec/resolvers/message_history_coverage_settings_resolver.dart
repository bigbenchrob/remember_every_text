import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../../core/util/date_converter.dart';
import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../../essentials/onboarding/application/fda_checker.dart';
import '../../../../../essentials/onboarding/application/onboarding_environment_report_provider.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../entities/message_history_coverage_report.dart';
import '../entities/message_history_coverage_report_logic.dart';

part 'message_history_coverage_settings_resolver.g.dart';

const _messageHistoryCoverageOverviewBody =
    'MessageLens compares the messages stored in your Mac\'s Messages database (chat.db) with the messages it has imported and organized.\n\n'
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
  if (!const FdaChecker().canReadMessagesDatabase()) {
    return MessageHistoryCoverageReport(
      status: MessageHistoryCoverageStatus.unknown,
      chatDbTotalCount: null,
      workingDbVisibleCount: null,
      workingDbRecoveredCount: null,
      earliestMessageDate: null,
      latestMessageDate: null,
      generatedAt: generatedAt,
      detail:
          'MessageLens cannot currently read the Messages database on this Mac. Check Full Disk Access and try again.',
    );
  }

  final sourceSummary = _readChatDbSummary(chatDbPath);
  if (sourceSummary == null) {
    return MessageHistoryCoverageReport(
      status: MessageHistoryCoverageStatus.unknown,
      chatDbTotalCount: null,
      workingDbVisibleCount: null,
      workingDbRecoveredCount: null,
      earliestMessageDate: null,
      latestMessageDate: null,
      generatedAt: generatedAt,
      detail:
          'MessageLens could not safely read message totals from the local Messages database.',
    );
  }

  try {
    final workingDb = await ref.read(driftWorkingDatabaseProvider.future);
    final visibleCount = await _readVisibleCount(workingDb);
    final recoveredCount = await _readRecoveredCount(workingDb);
    final status = classifyMessageHistoryCoverageReport(
      sourceCount: sourceSummary.totalCount,
      accountedCount: visibleCount + recoveredCount,
      earliestMessageDate: sourceSummary.earliestMessageDate,
    );

    return MessageHistoryCoverageReport(
      status: status,
      chatDbTotalCount: sourceSummary.totalCount,
      workingDbVisibleCount: visibleCount,
      workingDbRecoveredCount: recoveredCount,
      earliestMessageDate: sourceSummary.earliestMessageDate,
      latestMessageDate: sourceSummary.latestMessageDate,
      generatedAt: generatedAt,
    );
  } catch (error) {
    return MessageHistoryCoverageReport(
      status: MessageHistoryCoverageStatus.unknown,
      chatDbTotalCount: sourceSummary.totalCount,
      workingDbVisibleCount: null,
      workingDbRecoveredCount: null,
      earliestMessageDate: sourceSummary.earliestMessageDate,
      latestMessageDate: sourceSummary.latestMessageDate,
      generatedAt: generatedAt,
      detail: 'MessageLens could not safely read the working database: $error',
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

_ChatDbSummary? _readChatDbSummary(String dbPath) {
  final file = File(dbPath);
  if (!file.existsSync()) {
    return null;
  }

  try {
    final database = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    try {
      database.execute('PRAGMA query_only = ON;');
      database.execute('PRAGMA busy_timeout = 3000;');

      final result = database.select('''
        SELECT
          COUNT(*) AS total_count,
          MIN(CASE WHEN date IS NOT NULL AND date != 0 THEN date END) AS first_date,
          MAX(CASE WHEN date IS NOT NULL AND date != 0 THEN date END) AS last_date
        FROM message
      ''');
      if (result.isEmpty) {
        return null;
      }

      final row = result.first;
      final totalCount = _asInt(row['total_count']);
      if (totalCount == null) {
        return null;
      }

      return _ChatDbSummary(
        totalCount: totalCount,
        earliestMessageDate: DateConverter.appleToDateTime(
          row['first_date'],
        )?.toUtc(),
        latestMessageDate: DateConverter.appleToDateTime(
          row['last_date'],
        )?.toUtc(),
      );
    } finally {
      database.dispose();
    }
  } catch (_) {
    return null;
  }
}

Future<int> _readVisibleCount(WorkingDatabase workingDb) async {
  final result = await workingDb
      .customSelect(
        'SELECT COUNT(*) AS total_count FROM global_message_index',
        readsFrom: {workingDb.globalMessageIndex},
      )
      .getSingle();
  return result.read<int?>('total_count') ?? 0;
}

Future<int> _readRecoveredCount(WorkingDatabase workingDb) async {
  final result = await workingDb
      .customSelect(
        'SELECT COUNT(*) AS total_count FROM recovered_unlinked_messages',
        readsFrom: {workingDb.recoveredUnlinkedMessages},
      )
      .getSingle();
  return result.read<int?>('total_count') ?? 0;
}

int? _asInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('$value');
}

final class _ChatDbSummary {
  const _ChatDbSummary({
    required this.totalCount,
    required this.earliestMessageDate,
    required this.latestMessageDate,
  });

  final int totalCount;
  final DateTime? earliestMessageDate;
  final DateTime? latestMessageDate;
}
