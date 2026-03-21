// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prewarm_contact_messages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$prewarmContactMessagesHash() =>
    r'935ccffa4285d43e8c4efb75af6e327b37409513';

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

/// Warms the contact-scoped sidebar heatmap and center-timeline ordinal state
/// before the user-visible contact transition completes.
///
/// This exists to avoid the first contact selection on a cold launch showing
/// both a lower-sidebar loading gap and a center-panel spinner while those two
/// read-only data paths initialize for the first time.
///
/// Copied from [prewarmContactMessages].
@ProviderFor(prewarmContactMessages)
const prewarmContactMessagesProvider = PrewarmContactMessagesFamily();

/// Warms the contact-scoped sidebar heatmap and center-timeline ordinal state
/// before the user-visible contact transition completes.
///
/// This exists to avoid the first contact selection on a cold launch showing
/// both a lower-sidebar loading gap and a center-panel spinner while those two
/// read-only data paths initialize for the first time.
///
/// Copied from [prewarmContactMessages].
class PrewarmContactMessagesFamily extends Family<AsyncValue<void>> {
  /// Warms the contact-scoped sidebar heatmap and center-timeline ordinal state
  /// before the user-visible contact transition completes.
  ///
  /// This exists to avoid the first contact selection on a cold launch showing
  /// both a lower-sidebar loading gap and a center-panel spinner while those two
  /// read-only data paths initialize for the first time.
  ///
  /// Copied from [prewarmContactMessages].
  const PrewarmContactMessagesFamily();

  /// Warms the contact-scoped sidebar heatmap and center-timeline ordinal state
  /// before the user-visible contact transition completes.
  ///
  /// This exists to avoid the first contact selection on a cold launch showing
  /// both a lower-sidebar loading gap and a center-panel spinner while those two
  /// read-only data paths initialize for the first time.
  ///
  /// Copied from [prewarmContactMessages].
  PrewarmContactMessagesProvider call({required int contactId}) {
    return PrewarmContactMessagesProvider(contactId: contactId);
  }

  @override
  PrewarmContactMessagesProvider getProviderOverride(
    covariant PrewarmContactMessagesProvider provider,
  ) {
    return call(contactId: provider.contactId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'prewarmContactMessagesProvider';
}

/// Warms the contact-scoped sidebar heatmap and center-timeline ordinal state
/// before the user-visible contact transition completes.
///
/// This exists to avoid the first contact selection on a cold launch showing
/// both a lower-sidebar loading gap and a center-panel spinner while those two
/// read-only data paths initialize for the first time.
///
/// Copied from [prewarmContactMessages].
class PrewarmContactMessagesProvider extends AutoDisposeFutureProvider<void> {
  /// Warms the contact-scoped sidebar heatmap and center-timeline ordinal state
  /// before the user-visible contact transition completes.
  ///
  /// This exists to avoid the first contact selection on a cold launch showing
  /// both a lower-sidebar loading gap and a center-panel spinner while those two
  /// read-only data paths initialize for the first time.
  ///
  /// Copied from [prewarmContactMessages].
  PrewarmContactMessagesProvider({required int contactId})
    : this._internal(
        (ref) => prewarmContactMessages(
          ref as PrewarmContactMessagesRef,
          contactId: contactId,
        ),
        from: prewarmContactMessagesProvider,
        name: r'prewarmContactMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$prewarmContactMessagesHash,
        dependencies: PrewarmContactMessagesFamily._dependencies,
        allTransitiveDependencies:
            PrewarmContactMessagesFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  PrewarmContactMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final int contactId;

  @override
  Override overrideWith(
    FutureOr<void> Function(PrewarmContactMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PrewarmContactMessagesProvider._internal(
        (ref) => create(ref as PrewarmContactMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _PrewarmContactMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PrewarmContactMessagesProvider &&
        other.contactId == contactId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PrewarmContactMessagesRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _PrewarmContactMessagesProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with PrewarmContactMessagesRef {
  _PrewarmContactMessagesProviderElement(super.provider);

  @override
  int get contactId => (origin as PrewarmContactMessagesProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
