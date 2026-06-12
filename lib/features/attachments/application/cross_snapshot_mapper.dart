import 'cross_snapshot_mapping.dart';
import 'historical_snapshot_reader.dart';

abstract interface class CrossSnapshotMapper {
  Future<bool> hasCurrentAttachmentSnapshot();

  Future<CrossSnapshotMappingResult?> mapRecords({
    required List<HistoricalAttachmentRecord> historicalRecords,
    void Function(int processed)? onProgress,
    bool Function()? isCancelled,
  });
}
