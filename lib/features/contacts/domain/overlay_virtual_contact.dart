class OverlayVirtualContact {
  const OverlayVirtualContact({
    required this.id,
    required this.displayName,
    this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final int id;
  final String displayName;
  final String? notes;
  final String createdAtUtc;
  final String updatedAtUtc;
}
