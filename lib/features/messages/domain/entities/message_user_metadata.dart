class MessageUserMetadata {
  const MessageUserMetadata({
    required this.messageGuid,
    required this.isSaved,
    required this.tags,
  });

  const MessageUserMetadata.empty({required this.messageGuid})
    : isSaved = false,
      tags = const <String>[];

  final String messageGuid;
  final bool isSaved;
  final List<String> tags;

  bool get hasUserMetadata {
    return isSaved || tags.isNotEmpty;
  }

  MessageUserMetadata copyWith({bool? isSaved, List<String>? tags}) {
    return MessageUserMetadata(
      messageGuid: messageGuid,
      isSaved: isSaved ?? this.isSaved,
      tags: tags ?? this.tags,
    );
  }
}
