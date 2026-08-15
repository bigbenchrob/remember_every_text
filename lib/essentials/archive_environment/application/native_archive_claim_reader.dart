import '../domain/native_archive_claim.dart';

/// Native bootstrap port supplying the immutable process/archive claim.
abstract interface class NativeArchiveClaimReader {
  Future<NativeArchiveClaim> read();
}
