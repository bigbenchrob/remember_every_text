import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import '../../../../essentials/conversation_graph/feature_level_providers.dart'
    show conversationSignatureReaderProvider, conversationSignaturesProvider;
import '../../../contacts/feature_level_providers.dart'
    show ConversationDisplayIdentity, displayIdentityResolverProvider;
import '../../domain/conversation_tags/conversation_tag_display.dart';
import '../conversation_tags/conversation_tags_provider.dart';

part 'conversation_signature_display_provider.g.dart';

enum ConversationSignatureFilter { all, groups, oneToOne, highActivity }

enum ConversationSignatureSort {
  byDateOfCreation,
  mostRecentlyUpdated,
  mostTotalMessages,
  startedMostRecently,
  longestRunning,
  dormant,
}

class ConversationSignatureDisplayModel {
  const ConversationSignatureDisplayModel({
    required this.conversationId,
    required this.title,
    required this.participantLabels,
    required this.participantCount,
    required this.isGroup,
    required this.messageCount,
    required this.attachmentCount,
    required this.firstMessageAtUtc,
    required this.lastMessageAtUtc,
    required this.lastMessageText,
    required this.activityMonths,
    this.tags = const <ConversationTagDisplay>[],
  });

  final int conversationId;
  final String title;
  final List<String> participantLabels;
  final int participantCount;
  final bool isGroup;
  final int messageCount;
  final int attachmentCount;
  final String? firstMessageAtUtc;
  final String? lastMessageAtUtc;
  final String? lastMessageText;
  final List<ConversationSignatureMonth> activityMonths;
  final List<ConversationTagDisplay> tags;
}

@immutable
class ConversationSignatureDisplayByIdsRequest {
  ConversationSignatureDisplayByIdsRequest({
    required Iterable<int> conversationIds,
  }) : conversationIds = List<int>.unmodifiable(conversationIds);

  final List<int> conversationIds;

  static const _equality = ListEquality<int>();

  @override
  bool operator ==(Object other) {
    return other is ConversationSignatureDisplayByIdsRequest &&
        _equality.equals(other.conversationIds, conversationIds);
  }

  @override
  int get hashCode => _equality.hash(conversationIds);
}

@immutable
class ConversationSignatureSelectedTagsRequest {
  ConversationSignatureSelectedTagsRequest({required Iterable<int> tagIds})
    : tagIds = List<int>.unmodifiable(tagIds);

  const ConversationSignatureSelectedTagsRequest.empty()
    : tagIds = const <int>[];

  final List<int> tagIds;

  static const _equality = ListEquality<int>();

  @override
  bool operator ==(Object other) {
    return other is ConversationSignatureSelectedTagsRequest &&
        _equality.equals(other.tagIds, tagIds);
  }

  @override
  int get hashCode => _equality.hash(tagIds);
}

@riverpod
Future<List<ConversationSignatureDisplayModel>> conversationSignatureDisplay(
  Ref ref, {
  int limit = 500,
  String searchQuery = '',
  ConversationSignatureSelectedTagsRequest selectedTags =
      const ConversationSignatureSelectedTagsRequest.empty(),
  ConversationSignatureFilter filter = ConversationSignatureFilter.all,
  ConversationSignatureSort sort =
      ConversationSignatureSort.mostRecentlyUpdated,
  List<int> excludedFavouriteConversationIds = const <int>[],
}) async {
  final signatures = await ref.watch(
    conversationSignaturesProvider(limit: limit).future,
  );
  final identityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );
  final excludedFavouriteIds = excludedFavouriteConversationIds.toSet();
  final tagsByConversationId = await ref.watch(
    conversationTagsByConversationIdsProvider(
      request: ConversationTagsByConversationIdsRequest(
        conversationIds: signatures.map((signature) {
          return signature.conversationId;
        }),
      ),
    ).future,
  );

  final displayModels = [
    for (final signature in signatures)
      _toDisplayModel(
        signature,
        identityResolver.resolveConversationFromHandles(
          conversationId: signature.conversationId,
          handles: signature.participantLabels,
        ),
        tags:
            tagsByConversationId[signature.conversationId] ??
            const <ConversationTagDisplay>[],
      ),
  ];

  final normalizedQuery = searchQuery.trim().toLowerCase();
  final selectedTagIds = selectedTags.tagIds.toSet();
  final filtered = displayModels.where((signature) {
    return !excludedFavouriteIds.contains(signature.conversationId) &&
        _matchesSearch(signature, normalizedQuery) &&
        _matchesSelectedTags(signature, selectedTagIds) &&
        _matchesFilter(signature, filter);
  }).toList();

  filtered.sort((a, b) => _compareSignatures(a, b, sort));
  return filtered;
}

@riverpod
Future<List<ConversationSignatureDisplayModel>>
conversationSignatureDisplayByIds(
  Ref ref, {
  required ConversationSignatureDisplayByIdsRequest request,
}) async {
  return _readDisplayModelsByIds(ref, request.conversationIds);
}

@riverpod
Future<List<ConversationSignatureDisplayModel>>
favouriteConversationSignatureDisplay(
  Ref ref, {
  required List<int> conversationIds,
}) async {
  return _readDisplayModelsByIds(ref, conversationIds);
}

Future<List<ConversationSignatureDisplayModel>> _readDisplayModelsByIds(
  Ref ref,
  List<int> conversationIds,
) async {
  if (conversationIds.isEmpty) {
    return const <ConversationSignatureDisplayModel>[];
  }

  final reader = await ref.watch(conversationSignatureReaderProvider.future);
  final signatures = await reader.readSignaturesByIds(
    conversationIds: conversationIds,
  );
  final identityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );
  final tagsByConversationId = await ref.watch(
    conversationTagsByConversationIdsProvider(
      request: ConversationTagsByConversationIdsRequest(
        conversationIds: signatures.map((signature) {
          return signature.conversationId;
        }),
      ),
    ).future,
  );
  final displayModelsById = {
    for (final signature in signatures)
      signature.conversationId: _toDisplayModel(
        signature,
        identityResolver.resolveConversationFromHandles(
          conversationId: signature.conversationId,
          handles: signature.participantLabels,
        ),
        tags:
            tagsByConversationId[signature.conversationId] ??
            const <ConversationTagDisplay>[],
      ),
  };

  return [
    for (final conversationId in conversationIds)
      if (displayModelsById[conversationId] != null)
        displayModelsById[conversationId]!,
  ];
}

ConversationSignatureDisplayModel _toDisplayModel(
  ConversationSignature signature,
  ConversationDisplayIdentity displayIdentity, {
  List<ConversationTagDisplay> tags = const <ConversationTagDisplay>[],
}) {
  return ConversationSignatureDisplayModel(
    conversationId: signature.conversationId,
    title: displayIdentity.title,
    participantLabels: displayIdentity.participantLabels,
    participantCount: signature.participantCount,
    isGroup: signature.isGroup,
    messageCount: signature.messageCount,
    attachmentCount: signature.attachmentCount,
    firstMessageAtUtc: signature.firstMessageAtUtc,
    lastMessageAtUtc: signature.lastMessageAtUtc,
    lastMessageText: signature.lastMessageText,
    activityMonths: signature.activityMonths,
    tags: tags,
  );
}

String conversationSignatureFilterLabel(ConversationSignatureFilter filter) {
  return switch (filter) {
    ConversationSignatureFilter.all => 'All',
    ConversationSignatureFilter.groups => 'Groups',
    ConversationSignatureFilter.oneToOne => 'One-to-one',
    ConversationSignatureFilter.highActivity => 'High activity',
  };
}

String conversationSignatureSortLabel(ConversationSignatureSort sort) {
  return switch (sort) {
    ConversationSignatureSort.mostRecentlyUpdated => 'Most recently updated',
    ConversationSignatureSort.mostTotalMessages => 'Most total messages',
    ConversationSignatureSort.byDateOfCreation => 'By date of creation',
    ConversationSignatureSort.startedMostRecently => 'Started most recently',
    ConversationSignatureSort.longestRunning => 'Longest first-to-last span',
    ConversationSignatureSort.dormant => 'Dormant',
  };
}

bool _matchesSearch(
  ConversationSignatureDisplayModel signature,
  String normalizedQuery,
) {
  if (normalizedQuery.isEmpty) {
    return true;
  }

  final searchableText = [
    signature.title,
    ...signature.participantLabels,
    signature.lastMessageText ?? '',
  ].join(' ').toLowerCase();
  return searchableText.contains(normalizedQuery);
}

bool _matchesSelectedTags(
  ConversationSignatureDisplayModel signature,
  Set<int> selectedTagIds,
) {
  if (selectedTagIds.isEmpty) {
    return true;
  }

  final signatureTagIds = signature.tags.map((tag) => tag.id).toSet();
  return selectedTagIds.every(signatureTagIds.contains);
}

bool _matchesFilter(
  ConversationSignatureDisplayModel signature,
  ConversationSignatureFilter filter,
) {
  return switch (filter) {
    ConversationSignatureFilter.all => true,
    ConversationSignatureFilter.groups => signature.participantCount > 1,
    ConversationSignatureFilter.oneToOne => signature.participantCount <= 1,
    ConversationSignatureFilter.highActivity => signature.messageCount >= 1000,
  };
}

int _compareSignatures(
  ConversationSignatureDisplayModel a,
  ConversationSignatureDisplayModel b,
  ConversationSignatureSort sort,
) {
  final primary = switch (sort) {
    ConversationSignatureSort.mostRecentlyUpdated => _compareNullableUtcDesc(
      a.lastMessageAtUtc,
      b.lastMessageAtUtc,
    ),
    ConversationSignatureSort.mostTotalMessages => b.messageCount.compareTo(
      a.messageCount,
    ),
    ConversationSignatureSort.byDateOfCreation => _compareNullableUtcAsc(
      a.firstMessageAtUtc,
      b.firstMessageAtUtc,
    ),
    ConversationSignatureSort.startedMostRecently => _compareNullableUtcDesc(
      a.firstMessageAtUtc,
      b.firstMessageAtUtc,
    ),
    ConversationSignatureSort.longestRunning => _conversationSpanDays(
      b,
    ).compareTo(_conversationSpanDays(a)),
    ConversationSignatureSort.dormant => _compareNullableUtcAsc(
      a.lastMessageAtUtc,
      b.lastMessageAtUtc,
    ),
  };
  if (primary != 0) {
    return primary;
  }
  final secondary = _compareNullableUtcDesc(
    a.lastMessageAtUtc,
    b.lastMessageAtUtc,
  );
  if (secondary != 0) {
    return secondary;
  }
  return a.title.toLowerCase().compareTo(b.title.toLowerCase());
}

int _compareNullableUtcDesc(String? aValue, String? bValue) {
  final a = _parseUtc(aValue);
  final b = _parseUtc(bValue);
  if (a == null && b == null) {
    return 0;
  }
  if (a == null) {
    return 1;
  }
  if (b == null) {
    return -1;
  }
  return b.compareTo(a);
}

int _compareNullableUtcAsc(String? aValue, String? bValue) {
  final a = _parseUtc(aValue);
  final b = _parseUtc(bValue);
  if (a == null && b == null) {
    return 0;
  }
  if (a == null) {
    return 1;
  }
  if (b == null) {
    return -1;
  }
  return a.compareTo(b);
}

int _conversationSpanDays(ConversationSignatureDisplayModel signature) {
  final first = _parseUtc(signature.firstMessageAtUtc);
  final last = _parseUtc(signature.lastMessageAtUtc);
  if (first == null || last == null) {
    return 0;
  }
  return last.difference(first).inDays;
}

DateTime? _parseUtc(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}
