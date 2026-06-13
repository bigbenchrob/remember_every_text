import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart';
import 'package:remember_this_text/features/settings/feature_level_providers.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/message_history_coverage_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('MessageHistoryCoverageSettingsResolver', () {
    test('returns the overview info payload', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = container
          .read(messageHistoryCoverageSettingsResolverProvider.notifier)
          .resolveOverview(cassetteIndex: 2);

      expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
      expect(payload.title, 'Message History Coverage');
      expect(
        payload.bodyText,
        contains(
          "MessageLens compares the messages stored in your Mac's Messages database (chat.db) with the messages it has imported and organized.",
        ),
      );
      expect(payload.footnote, isNull);
    });

    test('returns the how-to-read info payload', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = container
          .read(messageHistoryCoverageSettingsResolverProvider.notifier)
          .resolveHowToRead(cassetteIndex: 3);

      expect(payload.title, 'How to read this report');
      expect(payload.topSpacing, 10);
      expect(
        payload.bodyText,
        contains('Messages on this Mac are grouped into:'),
      );
      expect(
        payload.bodyText,
        contains('• Messages recovered but not linked to a conversation'),
      );
      expect(payload.footnote, isNull);
    });

    test('returns the older-messages note payload', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final payload = container
          .read(messageHistoryCoverageSettingsResolverProvider.notifier)
          .resolveOlderMessagesNote(cassetteIndex: 4);

      expect(payload.title, 'About older messages');
      expect(payload.topSpacing, 16);
      expect(
        payload.bodyText,
        'This report only reflects the messages stored on this Mac.\n\nIf you expected to see older messages, they may exist on another device or in iCloud but are not present here.',
      );
      expect(payload.footnote, isNull);
    });

    test(
      'reads conversation-linked and recovered counts from the graph',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'message_history_coverage_settings_resolver_test',
        );
        final chatDbPath = '${tempDir.path}/chat.db';
        final graphDb = ConversationGraphDatabase(NativeDatabase.memory());
        final sourceDb = sqlite3.open(chatDbPath);
        try {
          sourceDb.execute('''
          CREATE TABLE message (
            ROWID INTEGER PRIMARY KEY,
            date INTEGER
          )
        ''');
          sourceDb.execute(
            'INSERT INTO message (ROWID, date) VALUES (1, 0), (2, 0), (3, 0)',
          );
          await graphDb.executeSql('''
          INSERT INTO messages (ss_id, guid, is_from_me)
          VALUES
            (8796093022209, 'graph-message-1', 0),
            (8796093022210, 'graph-message-2', 1)
        ''');
          await graphDb.executeSql('''
          INSERT INTO chat_to_message (chat_ss_id, message_ss_id)
          VALUES (8796093022300, 8796093022209)
        ''');

          final container = ProviderContainer(
            overrides: [
              onboardingFullDiskAccessProvider.overrideWith((ref) => true),
              onboardingMessagesDatabasePathProvider.overrideWith(
                (ref) => chatDbPath,
              ),
              messageHistoryCoverageRepositoryProvider.overrideWith(
                (ref) async =>
                    MessageHistoryCoverageRepository(graphDb: graphDb),
              ),
            ],
          );
          addTearDown(container.dispose);

          final report = await container.read(
            messageHistoryCoverageReportProvider.future,
          );

          expect(report.chatDbTotalCount, 3);
          expect(report.graphConversationLinkedCount, 1);
          expect(report.graphRecoveredOrphanCount, 1);
          expect(report.status, MessageHistoryCoverageStatus.incompleteImport);
        } finally {
          sourceDb.dispose();
          await graphDb.close();
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );
  });
}
