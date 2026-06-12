// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_resolver_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentResolverHash() =>
    r'6bed2d5aefc33336610727d66fc560ed077c8441';

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

/// Resolves an attachment file through the app's source-policy boundary.
///
/// Archive disabled:
/// - render directly from the live Messages path when present
/// - otherwise report unresolved availability
///
/// Archive enabled:
/// - render only from the MessageLens archive
/// - if a live file exists but the archive is missing, trigger archive ingestion
///   and report a pending archive state
///
/// Copied from [attachmentResolver].
@ProviderFor(attachmentResolver)
const attachmentResolverProvider = AttachmentResolverFamily();

/// Resolves an attachment file through the app's source-policy boundary.
///
/// Archive disabled:
/// - render directly from the live Messages path when present
/// - otherwise report unresolved availability
///
/// Archive enabled:
/// - render only from the MessageLens archive
/// - if a live file exists but the archive is missing, trigger archive ingestion
///   and report a pending archive state
///
/// Copied from [attachmentResolver].
class AttachmentResolverFamily extends Family<AsyncValue<ResolvedAttachment>> {
  /// Resolves an attachment file through the app's source-policy boundary.
  ///
  /// Archive disabled:
  /// - render directly from the live Messages path when present
  /// - otherwise report unresolved availability
  ///
  /// Archive enabled:
  /// - render only from the MessageLens archive
  /// - if a live file exists but the archive is missing, trigger archive ingestion
  ///   and report a pending archive state
  ///
  /// Copied from [attachmentResolver].
  const AttachmentResolverFamily();

  /// Resolves an attachment file through the app's source-policy boundary.
  ///
  /// Archive disabled:
  /// - render directly from the live Messages path when present
  /// - otherwise report unresolved availability
  ///
  /// Archive enabled:
  /// - render only from the MessageLens archive
  /// - if a live file exists but the archive is missing, trigger archive ingestion
  ///   and report a pending archive state
  ///
  /// Copied from [attachmentResolver].
  AttachmentResolverProvider call(
    AttachmentInfo attachmentInfo, {
    required String messageGuid,
    required int? importAttachmentId,
  }) {
    return AttachmentResolverProvider(
      attachmentInfo,
      messageGuid: messageGuid,
      importAttachmentId: importAttachmentId,
    );
  }

  @override
  AttachmentResolverProvider getProviderOverride(
    covariant AttachmentResolverProvider provider,
  ) {
    return call(
      provider.attachmentInfo,
      messageGuid: provider.messageGuid,
      importAttachmentId: provider.importAttachmentId,
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
  String? get name => r'attachmentResolverProvider';
}

/// Resolves an attachment file through the app's source-policy boundary.
///
/// Archive disabled:
/// - render directly from the live Messages path when present
/// - otherwise report unresolved availability
///
/// Archive enabled:
/// - render only from the MessageLens archive
/// - if a live file exists but the archive is missing, trigger archive ingestion
///   and report a pending archive state
///
/// Copied from [attachmentResolver].
class AttachmentResolverProvider
    extends AutoDisposeFutureProvider<ResolvedAttachment> {
  /// Resolves an attachment file through the app's source-policy boundary.
  ///
  /// Archive disabled:
  /// - render directly from the live Messages path when present
  /// - otherwise report unresolved availability
  ///
  /// Archive enabled:
  /// - render only from the MessageLens archive
  /// - if a live file exists but the archive is missing, trigger archive ingestion
  ///   and report a pending archive state
  ///
  /// Copied from [attachmentResolver].
  AttachmentResolverProvider(
    AttachmentInfo attachmentInfo, {
    required String messageGuid,
    required int? importAttachmentId,
  }) : this._internal(
         (ref) => attachmentResolver(
           ref as AttachmentResolverRef,
           attachmentInfo,
           messageGuid: messageGuid,
           importAttachmentId: importAttachmentId,
         ),
         from: attachmentResolverProvider,
         name: r'attachmentResolverProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$attachmentResolverHash,
         dependencies: AttachmentResolverFamily._dependencies,
         allTransitiveDependencies:
             AttachmentResolverFamily._allTransitiveDependencies,
         attachmentInfo: attachmentInfo,
         messageGuid: messageGuid,
         importAttachmentId: importAttachmentId,
       );

  AttachmentResolverProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.attachmentInfo,
    required this.messageGuid,
    required this.importAttachmentId,
  }) : super.internal();

  final AttachmentInfo attachmentInfo;
  final String messageGuid;
  final int? importAttachmentId;

  @override
  Override overrideWith(
    FutureOr<ResolvedAttachment> Function(AttachmentResolverRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttachmentResolverProvider._internal(
        (ref) => create(ref as AttachmentResolverRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        attachmentInfo: attachmentInfo,
        messageGuid: messageGuid,
        importAttachmentId: importAttachmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ResolvedAttachment> createElement() {
    return _AttachmentResolverProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachmentResolverProvider &&
        other.attachmentInfo == attachmentInfo &&
        other.messageGuid == messageGuid &&
        other.importAttachmentId == importAttachmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, attachmentInfo.hashCode);
    hash = _SystemHash.combine(hash, messageGuid.hashCode);
    hash = _SystemHash.combine(hash, importAttachmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AttachmentResolverRef
    on AutoDisposeFutureProviderRef<ResolvedAttachment> {
  /// The parameter `attachmentInfo` of this provider.
  AttachmentInfo get attachmentInfo;

  /// The parameter `messageGuid` of this provider.
  String get messageGuid;

  /// The parameter `importAttachmentId` of this provider.
  int? get importAttachmentId;
}

class _AttachmentResolverProviderElement
    extends AutoDisposeFutureProviderElement<ResolvedAttachment>
    with AttachmentResolverRef {
  _AttachmentResolverProviderElement(super.provider);

  @override
  AttachmentInfo get attachmentInfo =>
      (origin as AttachmentResolverProvider).attachmentInfo;
  @override
  String get messageGuid => (origin as AttachmentResolverProvider).messageGuid;
  @override
  int? get importAttachmentId =>
      (origin as AttachmentResolverProvider).importAttachmentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
