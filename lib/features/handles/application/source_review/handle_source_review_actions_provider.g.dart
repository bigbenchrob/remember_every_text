// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_source_review_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handleSourceReviewActionsHash() =>
    r'3a82e7172d6af88638b8922b6e09ece9ab453f2a';

/// Handles-owned workflows for reviewing one canonical source.
///
/// Messages owns the complete handle-lens ViewSpec presentation. Handles owns
/// the meaning and ordering of these source-review workflows. Contact creation
/// and linking remain Contacts-owned primitives delegated to from this facade.
///
/// Copied from [HandleSourceReviewActions].
@ProviderFor(HandleSourceReviewActions)
final handleSourceReviewActionsProvider =
    AutoDisposeAsyncNotifierProvider<HandleSourceReviewActions, void>.internal(
      HandleSourceReviewActions.new,
      name: r'handleSourceReviewActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handleSourceReviewActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HandleSourceReviewActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
