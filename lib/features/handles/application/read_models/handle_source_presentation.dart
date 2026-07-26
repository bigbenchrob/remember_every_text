/// Handles-owned source identity projection consumed by collaborating views.
///
/// Rendering features decide how to present these facts. They do not reconstruct
/// source identity, fallback labels, or source-review meaning themselves.
final class HandleSourcePresentation {
  const HandleSourcePresentation({
    required this.canonicalHandleId,
    required this.primaryDisplayLabel,
    required this.statusLabel,
    required this.messageCount,
    this.rawEndpoint,
  });

  final int canonicalHandleId;
  final String primaryDisplayLabel;
  final String? rawEndpoint;
  final String statusLabel;
  final int messageCount;
}
