import '../domain/archive_marker.dart';

/// Persistence port for the identity marker at one archive root.
abstract interface class ArchiveMarkerStore {
  Future<ArchiveMarker?> read();

  Future<bool> canCreateInitialMarker();

  Future<void> createInitialMarker(ArchiveMarker marker);
}
