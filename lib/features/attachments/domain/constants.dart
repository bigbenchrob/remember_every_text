/// High-level availability state. Extend as your use cases demand.
enum AttachmentStatus {
  pending, // referenced but not yet fetched/resolved
  downloading, // in-progress
  available, // ready to use
  missing, // expected but not found
  failed, // failed to fetch/prepare
}
