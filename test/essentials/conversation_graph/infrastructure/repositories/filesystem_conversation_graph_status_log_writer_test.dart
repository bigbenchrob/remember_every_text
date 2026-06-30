import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/conversation_graph/domain/status/conversation_graph_status.dart';
import 'package:remember_this_text/essentials/conversation_graph/infrastructure/repositories/filesystem_conversation_graph_status_log_writer.dart';

void main() {
  test(
    'writes conversation graph status logs into the logs directory',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'conversation_graph_status_log_writer_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final logsDirectory = Directory(path.join(tempDirectory.path, '_LOGS'));
      final writer = FilesystemConversationGraphStatusLogWriter(
        logsDirectory: logsDirectory,
      );

      final filePath = await writer.writeRun(before: _status());

      expect(path.isWithin(logsDirectory.path, filePath), isTrue);
      expect(File(filePath).readAsStringSync(), contains('source_messages: 1'));
    },
  );

  test('rejects symlinked conversation graph log directory', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'conversation_graph_status_log_writer_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final outsideDirectory = Directory(path.join(tempDirectory.path, 'outside'))
      ..createSync();
    final logsLink = Link(path.join(tempDirectory.path, '_LOGS'));
    await logsLink.create(outsideDirectory.path);
    final writer = FilesystemConversationGraphStatusLogWriter(
      logsDirectory: Directory(logsLink.path),
    );

    await expectLater(writer.writeRun(before: _status()), throwsStateError);
    expect(outsideDirectory.listSync(), isEmpty);
  });
}

ConversationGraphStatus _status() {
  return const ConversationGraphStatus(
    chatDbPath: '/tmp/chat.db',
    importLedgerDatabaseLabel: 'import',
    graphDatabaseLabel: 'graph',
    sourceId: 1,
    sourceMessageCount: 1,
    sourceMaxRowId: 1,
    ledgerMessageCount: 1,
    ledgerMaxSourceRowId: 1,
    ledgerMessagesNeedingEnrichment: 0,
    ledgerMessagesStillWithoutText: 0,
    graphMessageCount: 1,
    associatedMessageEdgeCount: 0,
    sourceChatCount: 0,
    importChatCount: 0,
    graphChatCount: 0,
    sourceHandleCount: 0,
    importHandleCount: 0,
    graphHandleCount: 0,
    importTopologyEdgeCount: 0,
    graphTopologyEdgeCount: 0,
    duplicateGraphTopologyEdgeCount: 0,
    importChatToHandleEdgeCount: 0,
    graphChatToHandleEdgeCount: 0,
    duplicateGraphChatToHandleEdgeCount: 0,
    sourceAttachmentCount: 0,
    importAttachmentCount: 0,
    graphAttachmentCount: 0,
    importMessageToAttachmentEdgeCount: 0,
    graphMessageToAttachmentEdgeCount: 0,
    duplicateGraphMessageToAttachmentEdgeCount: 0,
  );
}
