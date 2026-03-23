// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_timeline_display_version_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactTimelineHasPendingMessagesHash() =>
    r'0e3ef6b647fb6a5008385ecce000e85e007d24b9';

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

/// See also [contactTimelineHasPendingMessages].
@ProviderFor(contactTimelineHasPendingMessages)
const contactTimelineHasPendingMessagesProvider =
    ContactTimelineHasPendingMessagesFamily();

/// See also [contactTimelineHasPendingMessages].
class ContactTimelineHasPendingMessagesFamily extends Family<bool> {
  /// See also [contactTimelineHasPendingMessages].
  const ContactTimelineHasPendingMessagesFamily();

  /// See also [contactTimelineHasPendingMessages].
  ContactTimelineHasPendingMessagesProvider call({
    required MessageTimelineScope scope,
  }) {
    return ContactTimelineHasPendingMessagesProvider(scope: scope);
  }

  @override
  ContactTimelineHasPendingMessagesProvider getProviderOverride(
    covariant ContactTimelineHasPendingMessagesProvider provider,
  ) {
    return call(scope: provider.scope);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactTimelineHasPendingMessagesProvider';
}

/// See also [contactTimelineHasPendingMessages].
class ContactTimelineHasPendingMessagesProvider
    extends AutoDisposeProvider<bool> {
  /// See also [contactTimelineHasPendingMessages].
  ContactTimelineHasPendingMessagesProvider({
    required MessageTimelineScope scope,
  }) : this._internal(
         (ref) => contactTimelineHasPendingMessages(
           ref as ContactTimelineHasPendingMessagesRef,
           scope: scope,
         ),
         from: contactTimelineHasPendingMessagesProvider,
         name: r'contactTimelineHasPendingMessagesProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$contactTimelineHasPendingMessagesHash,
         dependencies: ContactTimelineHasPendingMessagesFamily._dependencies,
         allTransitiveDependencies:
             ContactTimelineHasPendingMessagesFamily._allTransitiveDependencies,
         scope: scope,
       );

  ContactTimelineHasPendingMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final MessageTimelineScope scope;

  @override
  Override overrideWith(
    bool Function(ContactTimelineHasPendingMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactTimelineHasPendingMessagesProvider._internal(
        (ref) => create(ref as ContactTimelineHasPendingMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _ContactTimelineHasPendingMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactTimelineHasPendingMessagesProvider &&
        other.scope == scope;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactTimelineHasPendingMessagesRef on AutoDisposeProviderRef<bool> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;
}

class _ContactTimelineHasPendingMessagesProviderElement
    extends AutoDisposeProviderElement<bool>
    with ContactTimelineHasPendingMessagesRef {
  _ContactTimelineHasPendingMessagesProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as ContactTimelineHasPendingMessagesProvider).scope;
}

String _$pendingContactTimelineMessageIdsHash() =>
    r'fa21445c5a57f561c6b7929f610cf608b5ca8453';

/// See also [pendingContactTimelineMessageIds].
@ProviderFor(pendingContactTimelineMessageIds)
const pendingContactTimelineMessageIdsProvider =
    PendingContactTimelineMessageIdsFamily();

/// See also [pendingContactTimelineMessageIds].
class PendingContactTimelineMessageIdsFamily
    extends Family<AsyncValue<List<int>>> {
  /// See also [pendingContactTimelineMessageIds].
  const PendingContactTimelineMessageIdsFamily();

  /// See also [pendingContactTimelineMessageIds].
  PendingContactTimelineMessageIdsProvider call({
    required MessageTimelineScope scope,
  }) {
    return PendingContactTimelineMessageIdsProvider(scope: scope);
  }

  @override
  PendingContactTimelineMessageIdsProvider getProviderOverride(
    covariant PendingContactTimelineMessageIdsProvider provider,
  ) {
    return call(scope: provider.scope);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pendingContactTimelineMessageIdsProvider';
}

/// See also [pendingContactTimelineMessageIds].
class PendingContactTimelineMessageIdsProvider
    extends AutoDisposeFutureProvider<List<int>> {
  /// See also [pendingContactTimelineMessageIds].
  PendingContactTimelineMessageIdsProvider({
    required MessageTimelineScope scope,
  }) : this._internal(
         (ref) => pendingContactTimelineMessageIds(
           ref as PendingContactTimelineMessageIdsRef,
           scope: scope,
         ),
         from: pendingContactTimelineMessageIdsProvider,
         name: r'pendingContactTimelineMessageIdsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$pendingContactTimelineMessageIdsHash,
         dependencies: PendingContactTimelineMessageIdsFamily._dependencies,
         allTransitiveDependencies:
             PendingContactTimelineMessageIdsFamily._allTransitiveDependencies,
         scope: scope,
       );

  PendingContactTimelineMessageIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final MessageTimelineScope scope;

  @override
  Override overrideWith(
    FutureOr<List<int>> Function(PendingContactTimelineMessageIdsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PendingContactTimelineMessageIdsProvider._internal(
        (ref) => create(ref as PendingContactTimelineMessageIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<int>> createElement() {
    return _PendingContactTimelineMessageIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PendingContactTimelineMessageIdsProvider &&
        other.scope == scope;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PendingContactTimelineMessageIdsRef
    on AutoDisposeFutureProviderRef<List<int>> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;
}

class _PendingContactTimelineMessageIdsProviderElement
    extends AutoDisposeFutureProviderElement<List<int>>
    with PendingContactTimelineMessageIdsRef {
  _PendingContactTimelineMessageIdsProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as PendingContactTimelineMessageIdsProvider).scope;
}

String _$contactTimelineDisplayVersionHash() =>
    r'5b6d7999832b5b819760594d829b52c15f522dac';

abstract class _$ContactTimelineDisplayVersion
    extends BuildlessAutoDisposeNotifier<int> {
  late final MessageTimelineScope scope;

  int build({required MessageTimelineScope scope});
}

/// See also [ContactTimelineDisplayVersion].
@ProviderFor(ContactTimelineDisplayVersion)
const contactTimelineDisplayVersionProvider =
    ContactTimelineDisplayVersionFamily();

/// See also [ContactTimelineDisplayVersion].
class ContactTimelineDisplayVersionFamily extends Family<int> {
  /// See also [ContactTimelineDisplayVersion].
  const ContactTimelineDisplayVersionFamily();

  /// See also [ContactTimelineDisplayVersion].
  ContactTimelineDisplayVersionProvider call({
    required MessageTimelineScope scope,
  }) {
    return ContactTimelineDisplayVersionProvider(scope: scope);
  }

  @override
  ContactTimelineDisplayVersionProvider getProviderOverride(
    covariant ContactTimelineDisplayVersionProvider provider,
  ) {
    return call(scope: provider.scope);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactTimelineDisplayVersionProvider';
}

/// See also [ContactTimelineDisplayVersion].
class ContactTimelineDisplayVersionProvider
    extends
        AutoDisposeNotifierProviderImpl<ContactTimelineDisplayVersion, int> {
  /// See also [ContactTimelineDisplayVersion].
  ContactTimelineDisplayVersionProvider({required MessageTimelineScope scope})
    : this._internal(
        () => ContactTimelineDisplayVersion()..scope = scope,
        from: contactTimelineDisplayVersionProvider,
        name: r'contactTimelineDisplayVersionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactTimelineDisplayVersionHash,
        dependencies: ContactTimelineDisplayVersionFamily._dependencies,
        allTransitiveDependencies:
            ContactTimelineDisplayVersionFamily._allTransitiveDependencies,
        scope: scope,
      );

  ContactTimelineDisplayVersionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final MessageTimelineScope scope;

  @override
  int runNotifierBuild(covariant ContactTimelineDisplayVersion notifier) {
    return notifier.build(scope: scope);
  }

  @override
  Override overrideWith(ContactTimelineDisplayVersion Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContactTimelineDisplayVersionProvider._internal(
        () => create()..scope = scope,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ContactTimelineDisplayVersion, int>
  createElement() {
    return _ContactTimelineDisplayVersionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactTimelineDisplayVersionProvider &&
        other.scope == scope;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactTimelineDisplayVersionRef on AutoDisposeNotifierProviderRef<int> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;
}

class _ContactTimelineDisplayVersionProviderElement
    extends
        AutoDisposeNotifierProviderElement<ContactTimelineDisplayVersion, int>
    with ContactTimelineDisplayVersionRef {
  _ContactTimelineDisplayVersionProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as ContactTimelineDisplayVersionProvider).scope;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
