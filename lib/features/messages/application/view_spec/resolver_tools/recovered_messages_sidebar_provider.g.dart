// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovered_messages_sidebar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recoveredMessagesSidebarHash() =>
    r'5a2c261cdd4034597b3adda3a71511b5dce65bef';

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

/// See also [recoveredMessagesSidebar].
@ProviderFor(recoveredMessagesSidebar)
const recoveredMessagesSidebarProvider = RecoveredMessagesSidebarFamily();

/// See also [recoveredMessagesSidebar].
class RecoveredMessagesSidebarFamily extends Family<Widget> {
  /// See also [recoveredMessagesSidebar].
  const RecoveredMessagesSidebarFamily();

  /// See also [recoveredMessagesSidebar].
  RecoveredMessagesSidebarProvider call({
    int? contactId,
    DateTime? scrollToDate,
    bool onlyNoHandleFromMe = false,
  }) {
    return RecoveredMessagesSidebarProvider(
      contactId: contactId,
      scrollToDate: scrollToDate,
      onlyNoHandleFromMe: onlyNoHandleFromMe,
    );
  }

  @override
  RecoveredMessagesSidebarProvider getProviderOverride(
    covariant RecoveredMessagesSidebarProvider provider,
  ) {
    return call(
      contactId: provider.contactId,
      scrollToDate: provider.scrollToDate,
      onlyNoHandleFromMe: provider.onlyNoHandleFromMe,
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
  String? get name => r'recoveredMessagesSidebarProvider';
}

/// See also [recoveredMessagesSidebar].
class RecoveredMessagesSidebarProvider extends AutoDisposeProvider<Widget> {
  /// See also [recoveredMessagesSidebar].
  RecoveredMessagesSidebarProvider({
    int? contactId,
    DateTime? scrollToDate,
    bool onlyNoHandleFromMe = false,
  }) : this._internal(
         (ref) => recoveredMessagesSidebar(
           ref as RecoveredMessagesSidebarRef,
           contactId: contactId,
           scrollToDate: scrollToDate,
           onlyNoHandleFromMe: onlyNoHandleFromMe,
         ),
         from: recoveredMessagesSidebarProvider,
         name: r'recoveredMessagesSidebarProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$recoveredMessagesSidebarHash,
         dependencies: RecoveredMessagesSidebarFamily._dependencies,
         allTransitiveDependencies:
             RecoveredMessagesSidebarFamily._allTransitiveDependencies,
         contactId: contactId,
         scrollToDate: scrollToDate,
         onlyNoHandleFromMe: onlyNoHandleFromMe,
       );

  RecoveredMessagesSidebarProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.scrollToDate,
    required this.onlyNoHandleFromMe,
  }) : super.internal();

  final int? contactId;
  final DateTime? scrollToDate;
  final bool onlyNoHandleFromMe;

  @override
  Override overrideWith(
    Widget Function(RecoveredMessagesSidebarRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecoveredMessagesSidebarProvider._internal(
        (ref) => create(ref as RecoveredMessagesSidebarRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        scrollToDate: scrollToDate,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Widget> createElement() {
    return _RecoveredMessagesSidebarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecoveredMessagesSidebarProvider &&
        other.contactId == contactId &&
        other.scrollToDate == scrollToDate &&
        other.onlyNoHandleFromMe == onlyNoHandleFromMe;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, scrollToDate.hashCode);
    hash = _SystemHash.combine(hash, onlyNoHandleFromMe.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecoveredMessagesSidebarRef on AutoDisposeProviderRef<Widget> {
  /// The parameter `contactId` of this provider.
  int? get contactId;

  /// The parameter `scrollToDate` of this provider.
  DateTime? get scrollToDate;

  /// The parameter `onlyNoHandleFromMe` of this provider.
  bool get onlyNoHandleFromMe;
}

class _RecoveredMessagesSidebarProviderElement
    extends AutoDisposeProviderElement<Widget>
    with RecoveredMessagesSidebarRef {
  _RecoveredMessagesSidebarProviderElement(super.provider);

  @override
  int? get contactId => (origin as RecoveredMessagesSidebarProvider).contactId;
  @override
  DateTime? get scrollToDate =>
      (origin as RecoveredMessagesSidebarProvider).scrollToDate;
  @override
  bool get onlyNoHandleFromMe =>
      (origin as RecoveredMessagesSidebarProvider).onlyNoHandleFromMe;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
