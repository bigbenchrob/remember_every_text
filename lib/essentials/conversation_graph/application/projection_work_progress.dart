const graphProjectionProgressObservationStride = 250;

final class GraphProjectionWorkProgress {
  const GraphProjectionWorkProgress({
    required this.completedWorkCount,
    required this.totalWorkCount,
  }) : assert(completedWorkCount >= 0),
       assert(totalWorkCount >= 0),
       assert(completedWorkCount <= totalWorkCount);

  final int completedWorkCount;
  final int totalWorkCount;
}

typedef GraphProjectionWorkObserver =
    void Function(GraphProjectionWorkProgress progress);

bool shouldPublishGraphProjectionProgress({
  required int completedWorkCount,
  required int totalWorkCount,
}) {
  return completedWorkCount == totalWorkCount ||
      completedWorkCount % graphProjectionProgressObservationStride == 0;
}
