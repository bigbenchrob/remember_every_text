final class ScheduleMermaidFacts {
  const ScheduleMermaidFacts({
    required this.tripCount,
    required this.defaultEdgeCount,
    required this.explicitEdgeCount,
    required this.conditionalAlternativeCount,
    required this.backwardEdgeCount,
    required this.selfDestinationCount,
  });

  final int tripCount;
  final int defaultEdgeCount;
  final int explicitEdgeCount;
  final int conditionalAlternativeCount;
  final int backwardEdgeCount;
  final int selfDestinationCount;
}

final class ScheduleMermaidDocument {
  const ScheduleMermaidDocument({
    required this.scheduleDefinitionId,
    required this.scheduleName,
    required this.battingOrder,
    required this.mermaid,
    required this.markdown,
    required this.facts,
  });

  final int scheduleDefinitionId;
  final String scheduleName;
  final List<int> battingOrder;
  final String mermaid;
  final String markdown;
  final ScheduleMermaidFacts facts;
}
