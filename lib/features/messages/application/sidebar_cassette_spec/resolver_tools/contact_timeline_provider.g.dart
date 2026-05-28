// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactTimelineHash() => r'772435b39543b84f06c9b4af615dd3ad8084e6f4';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provides calendar heatmap timeline data for a contact's message history
/// across all their chats/handles.
///
/// This is a resolver tool: a data-fetching provider used by resolvers and
/// widget builders. It queries date bounds from `contact_message_index` then
/// delegates computation to [calculateContactCalendarHeatmapTimeline].
///
/// Copied from [contactTimeline].
@ProviderFor(contactTimeline)
const contactTimelineProvider = ContactTimelineFamily();

/// Provides calendar heatmap timeline data for a contact's message history
/// across all their chats/handles.
///
/// This is a resolver tool: a data-fetching provider used by resolvers and
/// widget builders. It queries date bounds from `contact_message_index` then
/// delegates computation to [calculateContactCalendarHeatmapTimeline].
///
/// Copied from [contactTimeline].
class ContactTimelineFamily
    extends Family<AsyncValue<CalendarHeatmapTimelineData?>> {
  /// Provides calendar heatmap timeline data for a contact's message history
  /// across all their chats/handles.
  ///
  /// This is a resolver tool: a data-fetching provider used by resolvers and
  /// widget builders. It queries date bounds from `contact_message_index` then
  /// delegates computation to [calculateContactCalendarHeatmapTimeline].
  ///
  /// Copied from [contactTimeline].
  const ContactTimelineFamily();

  /// Provides calendar heatmap timeline data for a contact's message history
  /// across all their chats/handles.
  ///
  /// This is a resolver tool: a data-fetching provider used by resolvers and
  /// widget builders. It queries date bounds from `contact_message_index` then
  /// delegates computation to [calculateContactCalendarHeatmapTimeline].
  ///
  /// Copied from [contactTimeline].
  ContactTimelineProvider call({required int contactId, int? filterHandleId}) {
    return ContactTimelineProvider(
      contactId: contactId,
      filterHandleId: filterHandleId,
    );
  }

  @override
  ContactTimelineProvider getProviderOverride(
    covariant ContactTimelineProvider provider,
  ) {
    return call(
      contactId: provider.contactId,
      filterHandleId: provider.filterHandleId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactTimelineProvider';
}

/// Provides calendar heatmap timeline data for a contact's message history
/// across all their chats/handles.
///
/// This is a resolver tool: a data-fetching provider used by resolvers and
/// widget builders. It queries date bounds from `contact_message_index` then
/// delegates computation to [calculateContactCalendarHeatmapTimeline].
///
/// Copied from [contactTimeline].
class ContactTimelineProvider
    extends AutoDisposeFutureProvider<CalendarHeatmapTimelineData?> {
  /// Provides calendar heatmap timeline data for a contact's message history
  /// across all their chats/handles.
  ///
  /// This is a resolver tool: a data-fetching provider used by resolvers and
  /// widget builders. It queries date bounds from `contact_message_index` then
  /// delegates computation to [calculateContactCalendarHeatmapTimeline].
  ///
  /// Copied from [contactTimeline].
  ContactTimelineProvider({required int contactId, int? filterHandleId})
    : this._internal(
        (ref) => contactTimeline(
          ref as ContactTimelineRef,
          contactId: contactId,
          filterHandleId: filterHandleId,
        ),
        from: contactTimelineProvider,
        name: r'contactTimelineProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactTimelineHash,
        dependencies: ContactTimelineFamily._dependencies,
        allTransitiveDependencies:
            ContactTimelineFamily._allTransitiveDependencies,
        contactId: contactId,
        filterHandleId: filterHandleId,
      );

  ContactTimelineProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.filterHandleId,
  }) : super.internal();

  final int contactId;
  final int? filterHandleId;

  @override
  Override overrideWith(
    FutureOr<CalendarHeatmapTimelineData?> Function(ContactTimelineRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactTimelineProvider._internal(
        (ref) => create(ref as ContactTimelineRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        filterHandleId: filterHandleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CalendarHeatmapTimelineData?>
  createElement() {
    return _ContactTimelineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactTimelineProvider &&
        other.contactId == contactId &&
        other.filterHandleId == filterHandleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, filterHandleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactTimelineRef
    on AutoDisposeFutureProviderRef<CalendarHeatmapTimelineData?> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `filterHandleId` of this provider.
  int? get filterHandleId;
}

class _ContactTimelineProviderElement
    extends AutoDisposeFutureProviderElement<CalendarHeatmapTimelineData?>
    with ContactTimelineRef {
  _ContactTimelineProviderElement(super.provider);

  @override
  int get contactId => (origin as ContactTimelineProvider).contactId;
  @override
  int? get filterHandleId => (origin as ContactTimelineProvider).filterHandleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
