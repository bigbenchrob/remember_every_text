/// Where the resolved file was found.
enum AttachmentProvenance {
  /// Resolved from the current ~/Library/Messages/Attachments path.
  messagesLive,

  /// Resolved from the MessageLens attachment archive.
  archived,

  /// Recovered from a user-supplied backup (e.g. Time Machine).
  importedHistorical,
}
