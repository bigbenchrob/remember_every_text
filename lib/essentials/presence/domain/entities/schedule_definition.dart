import 'trip.dart';

final class ScheduleTripDefinition {
  const ScheduleTripDefinition({
    required this.occurrenceId,
    required this.position,
    required this.trip,
  });

  final int occurrenceId;
  final int position;
  final TripDefinition trip;
}

final class ScheduleDefinition {
  ScheduleDefinition({
    required this.id,
    required this.name,
    required List<ScheduleTripDefinition> trips,
  }) : trips = List<ScheduleTripDefinition>.unmodifiable(trips) {
    if (trips.isEmpty) {
      throw ArgumentError.value(trips, 'trips', 'A Schedule requires a Trip.');
    }
  }

  final int id;
  final String name;
  final List<ScheduleTripDefinition> trips;
}
