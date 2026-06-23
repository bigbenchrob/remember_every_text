// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data_version_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageDataVersionHash() =>
    r'67b276f40eb0facb1a1d6222a2afd2bcc43b03be';

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
///
/// Copied from [MessageDataVersion].
@ProviderFor(MessageDataVersion)
final messageDataVersionProvider =
    NotifierProvider<MessageDataVersion, int>.internal(
      MessageDataVersion.new,
      name: r'messageDataVersionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$messageDataVersionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MessageDataVersion = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
