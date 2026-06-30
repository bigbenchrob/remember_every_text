import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/features/attachments/application/attachment_recovery_hint_storage.dart';
import 'package:remember_this_text/features/attachments/application/attachment_recovery_metadata_merge.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_recovery_metadata.dart';

void main() {
  group('attachment recovery hint storage', () {
    test('uses the archive compatibility key as storage identity', () {
      final key = attachmentRecoveryHintSettingKey(
        archiveKey: const ArchiveCompatibilityKey(
          messageGuid: 'message-guid',
          importAttachmentId: 42,
        ),
      );

      expect(key, 'attachment_recovery_hint::message-guid::42');
    });

    test('round-trips recovery metadata through JSON storage', () {
      final metadata = AttachmentRecoveryMetadata(
        lastRecoveryAttemptAt: DateTime.utc(2026, 6, 19, 10),
        nextRecoveryAttemptAt: DateTime.utc(2026, 6, 20, 10),
        recoveryAttemptCount: 4,
        recoveryPriority: 8,
        userInterestRaisedAt: DateTime.utc(2026, 6, 18, 10),
        lastRecoveryErrorSummary: 'file not found',
        isNonRecoverable: true,
      );

      final encoded = encodeAttachmentRecoveryHint(metadata);
      final decoded = decodeAttachmentRecoveryHint(encoded);

      expect(decoded, metadata);
    });

    test('invalid recovery hint payloads decode to null', () {
      expect(decodeAttachmentRecoveryHint(null), isNull);
      expect(decodeAttachmentRecoveryHint(''), isNull);
      expect(decodeAttachmentRecoveryHint('not json'), isNull);
      expect(decodeAttachmentRecoveryHint('[1, 2, 3]'), isNull);
    });
  });

  group('attachment recovery metadata merge', () {
    test('returns base metadata when no persisted hint exists', () {
      const base = AttachmentRecoveryMetadata(recoveryPriority: 1);

      expect(
        mergeAttachmentRecoveryMetadata(base: base, persistedHint: null),
        base,
      );
    });

    test(
      'preserves resolver facts while carrying user-interest hint forward',
      () {
        final base = AttachmentRecoveryMetadata(
          lastRecoveryAttemptAt: DateTime.utc(2026, 6, 19, 10),
          recoveryAttemptCount: 2,
          recoveryPriority: 1,
          lastRecoveryErrorSummary: 'source unavailable',
        );
        final persisted = AttachmentRecoveryMetadata(
          lastRecoveryAttemptAt: DateTime.utc(2026, 6, 18, 10),
          nextRecoveryAttemptAt: DateTime.utc(2026, 6, 20, 10),
          recoveryAttemptCount: 5,
          recoveryPriority: 10,
          userInterestRaisedAt: DateTime.utc(2026, 6, 17, 10),
          lastRecoveryErrorSummary: 'older error',
        );

        final merged = mergeAttachmentRecoveryMetadata(
          base: base,
          persistedHint: persisted,
        );

        expect(merged.lastRecoveryAttemptAt, base.lastRecoveryAttemptAt);
        expect(merged.nextRecoveryAttemptAt, persisted.nextRecoveryAttemptAt);
        expect(merged.recoveryAttemptCount, 5);
        expect(merged.recoveryPriority, 10);
        expect(merged.userInterestRaisedAt, persisted.userInterestRaisedAt);
        expect(merged.lastRecoveryErrorSummary, base.lastRecoveryErrorSummary);
        expect(merged.isNonRecoverable, isFalse);
      },
    );

    test('non-recoverable state wins from either side', () {
      const base = AttachmentRecoveryMetadata(isNonRecoverable: true);
      const persisted = AttachmentRecoveryMetadata(isNonRecoverable: false);
      const persistedNonRecoverable = AttachmentRecoveryMetadata(
        isNonRecoverable: true,
      );

      expect(
        mergeAttachmentRecoveryMetadata(
          base: base,
          persistedHint: persisted,
        ).isNonRecoverable,
        isTrue,
      );
      expect(
        mergeAttachmentRecoveryMetadata(
          base: persisted,
          persistedHint: persistedNonRecoverable,
        ).isNonRecoverable,
        isTrue,
      );
    });
  });
}
