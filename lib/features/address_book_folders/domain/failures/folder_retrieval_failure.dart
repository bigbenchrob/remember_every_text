class FolderRetrievalFailure implements Exception {
  const FolderRetrievalFailure({required this.message});

  final String message;

  String get error => message;

  @override
  String toString() {
    return 'FolderRetrievalFailure(message: $message)';
  }
}
