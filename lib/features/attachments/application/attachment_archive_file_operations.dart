/// Filesystem operations needed by attachment archive settings.
///
/// The application layer owns when these operations are requested. The
/// infrastructure implementation owns native file picking and directory IO.
abstract class AttachmentArchiveFileOperations {
  Future<void> resetArchiveDirectory(String archiveDirectoryPath);

  Future<int?> exportArchiveDirectory(String archiveDirectoryPath);
}
