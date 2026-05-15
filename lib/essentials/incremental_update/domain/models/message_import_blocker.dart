enum MessageImportBlocker {
  handlesNotReady,
  chatsNotReady;

  String get description {
    return switch (this) {
      MessageImportBlocker.handlesNotReady =>
        'Handle import prerequisites are not ready.',
      MessageImportBlocker.chatsNotReady =>
        'Chat import prerequisites are not ready.',
    };
  }
}
