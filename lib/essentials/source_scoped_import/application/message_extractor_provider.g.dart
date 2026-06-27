// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_extractor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceScopedMessageExtractorHash() =>
    r'9c497d7fdc8f6044fe181ef36976d7b4ba4d58c3';

/// Provides the Rust-backed attributed-body extractor used by source-scoped
/// message enrichment and archive import.
///
/// Copied from [sourceScopedMessageExtractor].
@ProviderFor(sourceScopedMessageExtractor)
final sourceScopedMessageExtractorProvider =
    AutoDisposeProvider<MessageExtractorPort>.internal(
      sourceScopedMessageExtractor,
      name: r'sourceScopedMessageExtractorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sourceScopedMessageExtractorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SourceScopedMessageExtractorRef =
    AutoDisposeProviderRef<MessageExtractorPort>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
