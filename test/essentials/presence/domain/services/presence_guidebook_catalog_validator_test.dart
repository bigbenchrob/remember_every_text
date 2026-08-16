import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_option.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/choice_value.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/presence_guidebook_catalog.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/test_agent_id.dart';
import 'package:remember_this_text/essentials/presence/domain/entities/trip_definition_id.dart';
import 'package:remember_this_text/essentials/presence/domain/services/presence_guidebook_catalog_validator.dart';

void main() {
  const validator = PresenceGuidebookCatalogValidator();

  test('accepts one coherent pure guidebook', () {
    expect(() => validator.validate(_validCatalog()), returnsNormally);
  });

  test('rejects duplicate Schedule identity', () {
    final schedule = _validCatalog().schedules.single;
    final catalog = PresenceGuidebookCatalog(
      schedules: <PresenceGuidebookSchedule>[
        schedule,
        PresenceGuidebookSchedule(
          id: schedule.id,
          name: 'another_schedule',
          trips: schedule.trips,
        ),
      ],
    );

    expect(() => validator.validate(catalog), throwsArgumentError);
  });

  test('rejects duplicate Schedule Trip position', () {
    final catalog = _catalogWithTrips(<PresenceGuidebookTripOccurrence>[
      _occurrence(occurrenceId: 1, position: 0, trip: _tellTrip(1, 11)),
      _occurrence(occurrenceId: 2, position: 0, trip: _tellTrip(2, 12)),
    ]);

    expect(() => validator.validate(catalog), throwsArgumentError);
  });

  test('rejects a destination outside its Schedule', () {
    final catalog = _catalogWithTrips(<PresenceGuidebookTripOccurrence>[
      _occurrence(
        occurrenceId: 1,
        position: 0,
        trip: PresenceGuidebookTrip(
          id: const TripDefinitionId(1),
          name: 'trip_1',
          steps: const <PresenceGuidebookStep>[
            PresenceGuidebookFixedDestinationStep(
              id: 11,
              name: 'route_elsewhere',
              destinationTripDefinitionId: TripDefinitionId(999),
            ),
          ],
        ),
      ),
    ]);

    expect(() => validator.validate(catalog), throwsArgumentError);
  });

  test('rejects conflicting subtypes for one canonical Step identity', () {
    final catalog = _catalogWithTrips(<PresenceGuidebookTripOccurrence>[
      _occurrence(occurrenceId: 1, position: 0, trip: _tellTrip(1, 11)),
      _occurrence(
        occurrenceId: 2,
        position: 1,
        trip: PresenceGuidebookTrip(
          id: const TripDefinitionId(2),
          name: 'trip_2',
          steps: <PresenceGuidebookStep>[
            PresenceGuidebookTestStep(
              id: 11,
              name: 'step_11',
              testAgentId: TestAgentId('test.agent'),
              trueDestinationTripDefinitionId: const TripDefinitionId(1),
              falseDestinationTripDefinitionId: null,
            ),
          ],
        ),
      ),
    ]);

    expect(() => validator.validate(catalog), throwsArgumentError);
  });

  test('rejects a Trip without Steps', () {
    final catalog = _catalogWithTrips(<PresenceGuidebookTripOccurrence>[
      _occurrence(
        occurrenceId: 1,
        position: 0,
        trip: PresenceGuidebookTrip(
          id: const TripDefinitionId(1),
          name: 'empty_trip',
          steps: const <PresenceGuidebookStep>[],
        ),
      ),
    ]);

    expect(() => validator.validate(catalog), throwsArgumentError);
  });

  test('rejects a Schedule without Trips', () {
    final catalog = PresenceGuidebookCatalog(
      schedules: <PresenceGuidebookSchedule>[
        PresenceGuidebookSchedule(
          id: 1,
          name: 'empty_schedule',
          trips: const <PresenceGuidebookTripOccurrence>[],
        ),
      ],
    );

    expect(() => validator.validate(catalog), throwsArgumentError);
  });

  test('rejects a Choice with fewer than two options', () {
    final catalog = _choiceCatalog(<ChoiceOption>[
      ChoiceOption(
        value: ChoiceValue('one'),
        label: 'One',
        destinationTripDefinitionId: const TripDefinitionId(1),
      ),
    ]);

    expect(() => validator.validate(catalog), throwsArgumentError);
  });

  test('rejects duplicate Choice values', () {
    final catalog = _choiceCatalog(<ChoiceOption>[
      ChoiceOption(
        value: ChoiceValue('same'),
        label: 'One',
        destinationTripDefinitionId: const TripDefinitionId(1),
      ),
      ChoiceOption(
        value: ChoiceValue('same'),
        label: 'Two',
        destinationTripDefinitionId: const TripDefinitionId(1),
      ),
    ]);

    expect(() => validator.validate(catalog), throwsArgumentError);
  });

  test('rejects an invalid Choice destination', () {
    final catalog = _choiceCatalog(<ChoiceOption>[
      ChoiceOption(
        value: ChoiceValue('one'),
        label: 'One',
        destinationTripDefinitionId: const TripDefinitionId(1),
      ),
      ChoiceOption(
        value: ChoiceValue('missing'),
        label: 'Missing',
        destinationTripDefinitionId: const TripDefinitionId(999),
      ),
    ]);

    expect(() => validator.validate(catalog), throwsArgumentError);
  });
}

PresenceGuidebookCatalog _validCatalog() {
  return _catalogWithTrips(<PresenceGuidebookTripOccurrence>[
    _occurrence(occurrenceId: 1, position: 0, trip: _tellTrip(1, 11)),
  ]);
}

PresenceGuidebookCatalog _choiceCatalog(List<ChoiceOption> options) {
  return _catalogWithTrips(<PresenceGuidebookTripOccurrence>[
    _occurrence(
      occurrenceId: 1,
      position: 0,
      trip: PresenceGuidebookTrip(
        id: const TripDefinitionId(1),
        name: 'trip_1',
        steps: <PresenceGuidebookStep>[
          PresenceGuidebookChoiceStep(
            id: 11,
            name: 'choice_11',
            options: options,
          ),
        ],
      ),
    ),
  ]);
}

PresenceGuidebookCatalog _catalogWithTrips(
  List<PresenceGuidebookTripOccurrence> trips,
) {
  return PresenceGuidebookCatalog(
    schedules: <PresenceGuidebookSchedule>[
      PresenceGuidebookSchedule(id: 1, name: 'schedule_1', trips: trips),
    ],
  );
}

PresenceGuidebookTripOccurrence _occurrence({
  required int occurrenceId,
  required int position,
  required PresenceGuidebookTrip trip,
}) {
  return PresenceGuidebookTripOccurrence(
    occurrenceId: occurrenceId,
    position: position,
    trip: trip,
  );
}

PresenceGuidebookTrip _tellTrip(int tripId, int stepId) {
  return PresenceGuidebookTrip(
    id: TripDefinitionId(tripId),
    name: 'trip_$tripId',
    steps: <PresenceGuidebookStep>[
      PresenceGuidebookTellStep(
        id: stepId,
        name: 'step_$stepId',
        text: 'Tell $stepId',
      ),
    ],
  );
}
