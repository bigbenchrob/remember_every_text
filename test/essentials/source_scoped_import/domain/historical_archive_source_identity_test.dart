import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/historical_archive_source_identity.dart';

void main() {
  group('HistoricalArchiveSourceIdentity', () {
    test('normalizes equivalent absolute chat db paths deterministically', () {
      final direct = HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
        '/Volumes/Archive/Messages/chat.db',
      );
      final equivalent =
          HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
            '/Volumes/Archive/Other/../Messages/./chat.db',
          );

      expect(equivalent, direct);
      expect(equivalent.hashCode, direct.hashCode);
      expect(
        direct.value,
        'historical-messages-archive:/Volumes/Archive/Messages/chat.db',
      );
    });

    test('keeps different canonical paths as distinct source identities', () {
      final first = HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
        '/Volumes/First/Messages/chat.db',
      );
      final second = HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
        '/Volumes/Second/Messages/chat.db',
      );

      expect(first, isNot(second));
    });

    test('round trips persisted identity without filesystem access', () {
      const persisted =
          'historical-messages-archive:/Volumes/Offline/Messages/chat.db';

      final identity = HistoricalArchiveSourceIdentity.fromPersistedValue(
        persisted,
      );

      expect(identity.value, persisted);
      expect(identity.canonicalSourcePath, '/Volumes/Offline/Messages/chat.db');
    });

    test('rejects unsupported or noncanonical persisted values', () {
      expect(
        () => HistoricalArchiveSourceIdentity.fromPersistedValue(
          'other-source:/Volumes/Archive/chat.db',
        ),
        throwsFormatException,
      );
      expect(
        () => HistoricalArchiveSourceIdentity.fromPersistedValue(
          'historical-messages-archive:/Volumes/Archive/../Archive/chat.db',
        ),
        throwsFormatException,
      );
    });

    test('reselecting the same canonical path reuses identity', () {
      final beforeRemoval =
          HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
            '/Volumes/Archive/Messages/chat.db',
          );
      final afterRemoval =
          HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
            '/Volumes/Archive/Messages/chat.db',
          );

      expect(afterRemoval, beforeRemoval);
    });

    test('MessageLens recovery key is not a durable source identity', () {
      expect(
        () => HistoricalArchiveSourceIdentity.fromPersistedValue(
          'message-lens-recovery-archive:'
          '123e4567-e89b-42d3-a456-426614174000',
        ),
        throwsFormatException,
      );
    });
  });
}
