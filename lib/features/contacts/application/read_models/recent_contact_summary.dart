class RecentContactSummary {
  const RecentContactSummary({
    required this.participantId,
    required this.displayName,
    required this.lastAccessedUtc,
  });

  final int participantId;
  final String displayName;
  final DateTime lastAccessedUtc;
}
