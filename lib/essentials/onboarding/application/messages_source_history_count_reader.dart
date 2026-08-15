abstract interface class MessagesSourceHistoryCountReader {
  int readCount();
}

final class MessagesSourceHistoryCountUnavailableException
    implements Exception {
  const MessagesSourceHistoryCountUnavailableException();

  @override
  String toString() {
    return 'MessagesSourceHistoryCountUnavailableException: '
        'the local Messages row count could not be obtained';
  }
}
