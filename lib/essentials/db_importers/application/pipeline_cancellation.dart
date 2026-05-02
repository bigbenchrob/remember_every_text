const dbPipelineCancelledMessage = 'Canceled by user.';

final class DbPipelineCancelledException implements Exception {
  const DbPipelineCancelledException([
    this.message = dbPipelineCancelledMessage,
  ]);

  final String message;

  @override
  String toString() {
    return message;
  }
}
