// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_graph_readiness_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationGraphReadinessHash() =>
    r'a30509caa811f90a55d766c065a48a16d65f6a4a';

/// See also [conversationGraphReadiness].
@ProviderFor(conversationGraphReadiness)
final conversationGraphReadinessProvider =
    FutureProvider<ConversationGraphReadiness>.internal(
      conversationGraphReadiness,
      name: r'conversationGraphReadinessProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationGraphReadinessHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConversationGraphReadinessRef =
    FutureProviderRef<ConversationGraphReadiness>;
String _$conversationGraphPopulatedHash() =>
    r'482ae19798ce3245ffd28ffc2702b70d5a8aa8f1';

/// See also [ConversationGraphPopulated].
@ProviderFor(ConversationGraphPopulated)
final conversationGraphPopulatedProvider =
    NotifierProvider<ConversationGraphPopulated, bool>.internal(
      ConversationGraphPopulated.new,
      name: r'conversationGraphPopulatedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationGraphPopulatedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConversationGraphPopulated = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
