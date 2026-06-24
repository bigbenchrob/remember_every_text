class MessageOverlayState {
  const MessageOverlayState({
    required this.messageSsId,
    required this.isSaved,
    required this.isStarred,
    required this.isArchived,
    required this.tags,
    this.userNotes,
    this.priority,
    this.remindAtUtc,
    this.hasGraphNativeOverlay = false,
    this.usedRowidAnnotationFallback = false,
    this.usedGuidFallback = false,
    this.skippedGuidFallbackBecauseAmbiguous = false,
  });

  const MessageOverlayState.empty({required int messageSsId})
    : this(
        messageSsId: messageSsId,
        isSaved: false,
        isStarred: false,
        isArchived: false,
        tags: const <String>[],
      );

  final int messageSsId;
  final bool isSaved;
  final bool isStarred;
  final bool isArchived;
  final List<String> tags;
  final String? userNotes;
  final int? priority;
  final String? remindAtUtc;

  /// True when user intent was found on the graph-native overlay tables.
  final bool hasGraphNativeOverlay;

  /// True when rowid-keyed message annotations were used as compatibility data.
  final bool usedRowidAnnotationFallback;

  /// True when GUID-keyed saved/tag rows were used as compatibility data.
  final bool usedGuidFallback;

  /// True when GUID-keyed rows existed but were intentionally not applied
  /// because the GUID is no longer a unique graph message identity.
  final bool skippedGuidFallbackBecauseAmbiguous;

  bool get hasUserIntent {
    return isSaved ||
        isStarred ||
        isArchived ||
        tags.isNotEmpty ||
        (userNotes?.isNotEmpty ?? false) ||
        priority != null ||
        remindAtUtc != null;
  }

  MessageOverlayState copyWith({
    bool? isSaved,
    bool? isStarred,
    bool? isArchived,
    List<String>? tags,
    String? userNotes,
    int? priority,
    String? remindAtUtc,
    bool? hasGraphNativeOverlay,
    bool? usedRowidAnnotationFallback,
    bool? usedGuidFallback,
    bool? skippedGuidFallbackBecauseAmbiguous,
  }) {
    return MessageOverlayState(
      messageSsId: messageSsId,
      isSaved: isSaved ?? this.isSaved,
      isStarred: isStarred ?? this.isStarred,
      isArchived: isArchived ?? this.isArchived,
      tags: tags ?? this.tags,
      userNotes: userNotes ?? this.userNotes,
      priority: priority ?? this.priority,
      remindAtUtc: remindAtUtc ?? this.remindAtUtc,
      hasGraphNativeOverlay:
          hasGraphNativeOverlay ?? this.hasGraphNativeOverlay,
      usedRowidAnnotationFallback:
          usedRowidAnnotationFallback ?? this.usedRowidAnnotationFallback,
      usedGuidFallback: usedGuidFallback ?? this.usedGuidFallback,
      skippedGuidFallbackBecauseAmbiguous:
          skippedGuidFallbackBecauseAmbiguous ??
          this.skippedGuidFallbackBecauseAmbiguous,
    );
  }
}
