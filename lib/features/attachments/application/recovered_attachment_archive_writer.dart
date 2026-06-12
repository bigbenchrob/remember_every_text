import 'cross_snapshot_mapping.dart';

abstract interface class RecoveredAttachmentArchiveWriter {
  /// Archives the mapped file and returns its size when newly archived.
  ///
  /// Returns null when the mapped file was already archived.
  Future<int?> archive(MappedAttachmentRecord record);
}
