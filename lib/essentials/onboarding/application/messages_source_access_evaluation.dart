import 'full_disk_access.dart';

/// Holds one process-local source observation across adjacent Boolean Tests.
///
/// The readable Test starts a fresh evaluation. The access-denied projection
/// then consumes that same observation so one routing decision cannot combine
/// facts from two different source probes. A restarted process evaluates
/// afresh because no observation is retained durably.
final class MessagesSourceAccessEvaluation {
  MessagesSourceAccessEvaluation({required FullDiskAccess fullDiskAccess})
    : _fullDiskAccess = fullDiskAccess;

  final FullDiskAccess _fullDiskAccess;
  MessagesSourceAccessResult? _latestResult;

  MessagesSourceAccessResult evaluateFresh() {
    final result = _fullDiskAccess.inspectMessagesSourceAccess();
    _latestResult = result;
    return result;
  }

  MessagesSourceAccessResult latestOrEvaluateFresh() {
    return _latestResult ?? evaluateFresh();
  }
}
