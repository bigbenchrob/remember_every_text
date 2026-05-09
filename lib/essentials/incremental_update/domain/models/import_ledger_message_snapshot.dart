import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_ledger_message_snapshot.freezed.dart';

@freezed
abstract class ImportLedgerMessageSnapshot with _$ImportLedgerMessageSnapshot {
  const factory ImportLedgerMessageSnapshot({
    required int maxRowId,
    required int totalMessageCount,
  }) = _ImportLedgerMessageSnapshot;

  const ImportLedgerMessageSnapshot._();
}
