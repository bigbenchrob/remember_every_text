/// Read-only payload capability produced only after donor path and integrity
/// validation. Recovery writers consume this capability instead of donor path
/// strings.
abstract interface class VerifiedDonorAttachmentPayload {
  String get archiveRelativePath;

  String get sourceExtension;

  int get expectedSizeBytes;

  String get expectedSha256;

  Stream<List<int>> openRead();
}
