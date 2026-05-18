import 'package:flutter/foundation.dart';

@immutable
final class SourceIdentity {
  const SourceIdentity({required this.sourceId, required this.sourceKind});

  final String sourceId;
  final String sourceKind;
}

const liveChatDbSourceIdentity = SourceIdentity(
  sourceId: 'live-chat-db',
  sourceKind: 'live_chat_db',
);
