import '../entities/journey.dart';

abstract interface class JourneyRepository {
  Future<Journey> loadJourney(int id);
}
