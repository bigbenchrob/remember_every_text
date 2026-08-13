import '../../presence/domain/services/test_agent.dart';
import 'full_disk_access.dart';

/// Establishes whether MessageLens can truthfully read its Messages source.
final class MessagesSourceReadinessTestAgent implements TestAgent {
  const MessagesSourceReadinessTestAgent({
    required FullDiskAccess fullDiskAccess,
  }) : _fullDiskAccess = fullDiskAccess;

  final FullDiskAccess _fullDiskAccess;

  @override
  Future<bool> evaluate() async {
    return _fullDiskAccess.canReadMessagesDatabase();
  }
}
