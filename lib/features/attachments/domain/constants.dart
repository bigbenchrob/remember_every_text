/// High-level availability state. Extend as your use cases demand.
enum AttachmentStatus {
  pending, // referenced but not yet fetched/resolved
  downloading, // in-progress
  available, // ready to use
  cloudOnly, // known in chat.db but no local file (iCloud evicted)
  missing, // expected but not found
  failed, // failed to fetch/prepare
}
