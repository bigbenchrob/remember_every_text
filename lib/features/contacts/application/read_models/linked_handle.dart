class LinkedHandle {
  const LinkedHandle({
    required this.handleId,
    required this.displayValue,
    required this.service,
    required this.isOverrideLink,
  });

  final int handleId;
  final String displayValue;
  final String service;

  /// Whether this link came from an overlay override rather than
  /// graph-projected AddressBook topology.
  final bool isOverrideLink;

  LinkedHandle copyWith({
    int? handleId,
    String? displayValue,
    String? service,
    bool? isOverrideLink,
  }) {
    return LinkedHandle(
      handleId: handleId ?? this.handleId,
      displayValue: displayValue ?? this.displayValue,
      service: service ?? this.service,
      isOverrideLink: isOverrideLink ?? this.isOverrideLink,
    );
  }
}
