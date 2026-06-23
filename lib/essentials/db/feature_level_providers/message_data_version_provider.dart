import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_data_version_provider.g.dart';

/// A signal provider that message-related providers can watch to know when
/// graph-backed message data has changed.
///
/// ## Purpose
///
/// Drift's reactive streams (`watch()`) automatically update when data changes,
/// but many message providers use one-time queries (`get()`) for performance.
/// Those providers need an external signal to know when to re-query.
///
/// ## How it works
///
/// 1. Message providers (e.g., `contactMessagesOrdinalProvider`) watch this
/// 2. After graph build/projection completes, the graph lifecycle increments
///    this provider through `MessageDataVersion.bump()`
/// 3. The version change cascades to all watching providers, triggering rebuilds
///
/// ## Usage
///
/// In a provider that needs to refresh when new messages arrive:
/// ```dart
/// @riverpod
/// Future<MessageEvidenceSkeleton> contactMessageSkeleton(
///   Ref ref, {
///   required int contactId,
/// }) async {
///   // Watch the signal - rebuilds when the version changes.
///   ref.watch(messageDataVersionProvider);
///
///   // Fetch the graph-backed skeleton for this contact.
/// }
/// ```
///
/// To trigger a refresh (in ChatDbChangeMonitor):
/// ```dart
/// ref.read(messageDataVersionProvider.notifier).bump();
/// ```
@Riverpod(keepAlive: true)
class MessageDataVersion extends _$MessageDataVersion {
  @override
  int build() => 0;

  /// Increment to signal that message data has changed.
  /// This causes all watching providers to rebuild.
  void bump() {
    state = state + 1;
  }
}
