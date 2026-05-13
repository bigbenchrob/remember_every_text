import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_migration_delta.freezed.dart';

@freezed
abstract class MessageMigrationDelta with _$MessageMigrationDelta {
  const factory MessageMigrationDelta({
    required int messageIdDelta,
    required int messageCountDelta,
  }) = _MessageMigrationDelta;

  const MessageMigrationDelta._();

  bool get isLedgerAheadOfProjection => messageIdDelta > 0;
  bool get isProjectionAheadOfLedger => messageIdDelta < 0;
  bool get projectionCaughtUp => messageIdDelta == 0;
}
