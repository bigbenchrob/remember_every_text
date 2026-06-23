// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$externalUriOpenerHash() => r'd4e46cc07581eb02e9f8455eee01dc33394668d7';

/// See also [externalUriOpener].
@ProviderFor(externalUriOpener)
final externalUriOpenerProvider =
    AutoDisposeProvider<ExternalUriOpener>.internal(
      externalUriOpener,
      name: r'externalUriOpenerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$externalUriOpenerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExternalUriOpenerRef = AutoDisposeProviderRef<ExternalUriOpener>;
String _$linkPreviewMetadataReaderHash() =>
    r'df96c39d146dd71b4e18a76bcd8d65c78ae7f4bb';

/// See also [linkPreviewMetadataReader].
@ProviderFor(linkPreviewMetadataReader)
final linkPreviewMetadataReaderProvider =
    AutoDisposeProvider<LinkPreviewMetadataReader>.internal(
      linkPreviewMetadataReader,
      name: r'linkPreviewMetadataReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$linkPreviewMetadataReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LinkPreviewMetadataReaderRef =
    AutoDisposeProviderRef<LinkPreviewMetadataReader>;
String _$linkPreviewMetadataHash() =>
    r'5a0bc714af6e8b2ed6b2c879847351f68800b236';

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

/// See also [linkPreviewMetadata].
@ProviderFor(linkPreviewMetadata)
const linkPreviewMetadataProvider = LinkPreviewMetadataFamily();

/// See also [linkPreviewMetadata].
class LinkPreviewMetadataFamily
    extends Family<AsyncValue<NativeLinkMetadata?>> {
  /// See also [linkPreviewMetadata].
  const LinkPreviewMetadataFamily();

  /// See also [linkPreviewMetadata].
  LinkPreviewMetadataProvider call(String url) {
    return LinkPreviewMetadataProvider(url);
  }

  @override
  LinkPreviewMetadataProvider getProviderOverride(
    covariant LinkPreviewMetadataProvider provider,
  ) {
    return call(provider.url);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'linkPreviewMetadataProvider';
}

/// See also [linkPreviewMetadata].
class LinkPreviewMetadataProvider
    extends AutoDisposeFutureProvider<NativeLinkMetadata?> {
  /// See also [linkPreviewMetadata].
  LinkPreviewMetadataProvider(String url)
    : this._internal(
        (ref) => linkPreviewMetadata(ref as LinkPreviewMetadataRef, url),
        from: linkPreviewMetadataProvider,
        name: r'linkPreviewMetadataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$linkPreviewMetadataHash,
        dependencies: LinkPreviewMetadataFamily._dependencies,
        allTransitiveDependencies:
            LinkPreviewMetadataFamily._allTransitiveDependencies,
        url: url,
      );

  LinkPreviewMetadataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
  }) : super.internal();

  final String url;

  @override
  Override overrideWith(
    FutureOr<NativeLinkMetadata?> Function(LinkPreviewMetadataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LinkPreviewMetadataProvider._internal(
        (ref) => create(ref as LinkPreviewMetadataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<NativeLinkMetadata?> createElement() {
    return _LinkPreviewMetadataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LinkPreviewMetadataProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LinkPreviewMetadataRef
    on AutoDisposeFutureProviderRef<NativeLinkMetadata?> {
  /// The parameter `url` of this provider.
  String get url;
}

class _LinkPreviewMetadataProviderElement
    extends AutoDisposeFutureProviderElement<NativeLinkMetadata?>
    with LinkPreviewMetadataRef {
  _LinkPreviewMetadataProviderElement(super.provider);

  @override
  String get url => (origin as LinkPreviewMetadataProvider).url;
}

String _$externalLinkActionsHash() =>
    r'df1c7bb94ef65407ddf0dcfe4c38155560c5989f';

/// See also [ExternalLinkActions].
@ProviderFor(ExternalLinkActions)
final externalLinkActionsProvider =
    AutoDisposeAsyncNotifierProvider<ExternalLinkActions, void>.internal(
      ExternalLinkActions.new,
      name: r'externalLinkActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$externalLinkActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExternalLinkActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
