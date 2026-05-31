import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import '../../../../../essentials/conversation_graph/application/conversation_signatures/conversation_signature_provider.dart';
import '../../../../contacts/feature_level_providers.dart';

part 'conversation_signature_display_provider.g.dart';

enum ConversationSignatureFilter {
  recent,
  groups,
  oneToOne,
  highActivity,
  dormantRevived,
}

enum ConversationSignatureSort {
  recent,
  largest,
  longestRunning,
  mostActiveRecently,
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

@riverpod
Future<List<ConversationSignatureDisplayModel>> conversationSignatureDisplay(
  Ref ref, {
  int limit = 500,
  String searchQuery = '',
  ConversationSignatureFilter filter = ConversationSignatureFilter.recent,
  ConversationSignatureSort sort = ConversationSignatureSort.recent,
  List<int> excludedFavouriteConversationIds = const <int>[],
}) async {
  final signatures = await ref.watch(
    conversationSignaturesProvider(limit: limit).future,
  );
  final identityResolver = await ref.watch(
    displayIdentityResolverProvider.future,
  );
  final excludedFavouriteIds = excludedFavouriteConversationIds.toSet();

  final displayModels = [
    for (final signature in signatures)
      _toDisplayModel(
        signature,
        identityResolver.resolveConversationFromHandles(
          conversationId: signature.conversationId,
          handles: signature.participantLabels,
        ),
      ),
  ];

  final normalizedQuery = searchQuery.trim().toLowerCase();
  final filtered = displayModels.where((signature) {
    return !excludedFavouriteIds.contains(signature.conversationId) &&
        _matchesSearch(signature, normalizedQuery) &&
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
  final displayModelsById = {
    for (final signature in signatures)
      signature.conversationId: _toDisplayModel(
        signature,
        identityResolver.resolveConversationFromHandles(
          conversationId: signature.conversationId,
          handles: signature.participantLabels,
        ),
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
  ConversationDisplayIdentity displayIdentity,
) {
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
  );
}

String conversationSignatureFilterLabel(ConversationSignatureFilter filter) {
  return switch (filter) {
    ConversationSignatureFilter.recent => 'Recent',
    ConversationSignatureFilter.groups => 'Groups',
    ConversationSignatureFilter.oneToOne => 'One-to-one',
    ConversationSignatureFilter.highActivity => 'High activity',
    ConversationSignatureFilter.dormantRevived => 'Dormant/revived',
  };
}

String conversationSignatureSortLabel(ConversationSignatureSort sort) {
  return switch (sort) {
    ConversationSignatureSort.recent => 'Recent',
    ConversationSignatureSort.largest => 'Largest',
    ConversationSignatureSort.longestRunning => 'Longest-running',
    ConversationSignatureSort.mostActiveRecently => 'Most active recently',
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

bool _matchesFilter(
  ConversationSignatureDisplayModel signature,
  ConversationSignatureFilter filter,
) {
  return switch (filter) {
    ConversationSignatureFilter.recent => true,
    ConversationSignatureFilter.groups => signature.participantCount > 1,
    ConversationSignatureFilter.oneToOne => signature.participantCount <= 1,
    ConversationSignatureFilter.highActivity => signature.messageCount >= 1000,
    ConversationSignatureFilter.dormantRevived => _isDormantOrRevived(
      signature,
    ),
  };
}

bool _isDormantOrRevived(ConversationSignatureDisplayModel signature) {
  final first = _parseUtc(signature.firstMessageAtUtc);
  final last = _parseUtc(signature.lastMessageAtUtc);
  if (first == null || last == null) {
    return false;
  }
  final now = DateTime.now().toUtc();
  return last.difference(first).inDays >= 365 &&
      now.difference(last).inDays <= 120;
}

int _compareSignatures(
  ConversationSignatureDisplayModel a,
  ConversationSignatureDisplayModel b,
  ConversationSignatureSort sort,
) {
  final primary = switch (sort) {
    ConversationSignatureSort.recent => _compareNullableUtcDesc(
      a.lastMessageAtUtc,
      b.lastMessageAtUtc,
    ),
    ConversationSignatureSort.largest => b.messageCount.compareTo(
      a.messageCount,
    ),
    ConversationSignatureSort.longestRunning => _conversationSpanDays(
      b,
    ).compareTo(_conversationSpanDays(a)),
    ConversationSignatureSort.mostActiveRecently => _recentTraceActivity(
      b,
    ).compareTo(_recentTraceActivity(a)),
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

int _conversationSpanDays(ConversationSignatureDisplayModel signature) {
  final first = _parseUtc(signature.firstMessageAtUtc);
  final last = _parseUtc(signature.lastMessageAtUtc);
  if (first == null || last == null) {
    return 0;
  }
  return last.difference(first).inDays;
}

int _recentTraceActivity(ConversationSignatureDisplayModel signature) {
  final months = signature.activityMonths;
  final start = months.length <= 4 ? 0 : months.length - 4;
  return months
      .skip(start)
      .fold<int>(0, (sum, month) => sum + month.messageCount);
}

DateTime? _parseUtc(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}
