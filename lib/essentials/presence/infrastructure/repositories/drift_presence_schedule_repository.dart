import 'package:drift/drift.dart';

import '../../domain/entities/choice_option.dart';
import '../../domain/entities/choice_value.dart';
import '../../domain/entities/execution_trace_event.dart';
import '../../domain/entities/schedule_definition.dart';
import '../../domain/entities/schedule_run.dart';
import '../../domain/entities/step.dart';
import '../../domain/entities/test_agent_id.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_definition_id.dart';
import '../../domain/repositories/presence_schedule_repository.dart';
import '../../domain/services/fda_settings_opening_authority.dart';
import '../../domain/services/test_agent_resolver.dart';
import '../data_sources/local/presence_database.dart';

final class DriftPresenceScheduleRepository
    implements PresenceScheduleRepository {
  const DriftPresenceScheduleRepository({
    required PresenceDatabase database,
    TestAgentResolver testAgentResolver = const _MissingTestAgentResolver(),
    FdaSettingsOpeningAuthority fdaSettingsOpeningAuthority =
        const _UnavailableFdaSettingsOpeningAuthority(),
  }) : _database = database,
       _testAgentResolver = testAgentResolver,
       _fdaSettingsOpeningAuthority = fdaSettingsOpeningAuthority;

  final PresenceDatabase _database;
  final TestAgentResolver _testAgentResolver;
  final FdaSettingsOpeningAuthority _fdaSettingsOpeningAuthority;

  @override
  Future<bool> definitionExists(int scheduleDefinitionId) async {
    final row =
        await (_database.select(_database.scheduleDefinitions)
              ..where((table) => table.id.equals(scheduleDefinitionId)))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Stream<bool> watchLatestRunCompletion(int scheduleDefinitionId) {
    final query = _database.select(_database.scheduleRuns)
      ..where(
        (table) => table.scheduleDefinitionId.equals(scheduleDefinitionId),
      )
      ..orderBy(<OrderClauseGenerator<ScheduleRuns>>[
        (table) => OrderingTerm.desc(table.id),
      ])
      ..limit(1);

    return query.watchSingleOrNull().map((run) {
      return run != null && run.currentTripOccurrenceId == null;
    }).distinct();
  }

  @override
  Future<void> insertDefinition(ScheduleDefinition definition) async {
    _validateDefinition(definition);

    await _database.transaction(() async {
      await _database
          .into(_database.scheduleDefinitions)
          .insert(
            ScheduleDefinitionsCompanion.insert(
              id: Value<int>(definition.id),
              name: definition.name,
            ),
          );

      final insertedTripIds = <TripDefinitionId>{};
      for (final scheduledTrip in definition.trips) {
        final trip = scheduledTrip.trip;
        final existingTrip = await (_database.select(
          _database.tripDefinitions,
        )..where((table) => table.id.equals(trip.id.value))).getSingleOrNull();
        if (existingTrip == null) {
          await _database
              .into(_database.tripDefinitions)
              .insert(
                TripDefinitionsCompanion.insert(
                  id: Value<int>(trip.id.value),
                  name: trip.name,
                ),
              );
          insertedTripIds.add(trip.id);
        } else {
          final loadedTrip = await _loadTrip(trip.id);
          if (!_sameTrip(loadedTrip, trip)) {
            throw StateError('Trip ${trip.id} has conflicting definitions.');
          }
        }
      }

      for (final scheduledTrip in definition.trips) {
        if (insertedTripIds.contains(scheduledTrip.trip.id)) {
          await _insertTripComposition(scheduledTrip.trip);
        }
      }

      for (final scheduledTrip in definition.trips) {
        final trip = scheduledTrip.trip;
        await _database
            .into(_database.scheduleTripOccurrences)
            .insert(
              ScheduleTripOccurrencesCompanion.insert(
                id: Value<int>(scheduledTrip.occurrenceId),
                scheduleDefinitionId: definition.id,
                tripDefinitionId: trip.id.value,
                position: scheduledTrip.position,
              ),
            );
      }
    });
  }

  @override
  Future<void> installOrExtendDefinition(ScheduleDefinition definition) async {
    _validateDefinition(definition);
    if (!await definitionExists(definition.id)) {
      await insertDefinition(definition);
      return;
    }

    final existing = await loadDefinition(definition.id);
    if (_sameScheduleDefinition(existing, definition)) {
      return;
    }
    _validateAdditiveExtension(existing: existing, target: definition);

    await _database.transaction(() async {
      final existingTripIds = existing.trips
          .map((scheduledTrip) => scheduledTrip.trip.id)
          .toSet();
      final addedTrips = definition.trips
          .where(
            (scheduledTrip) => !existingTripIds.contains(scheduledTrip.trip.id),
          )
          .map((scheduledTrip) => scheduledTrip.trip)
          .toList(growable: false);

      for (final trip in addedTrips) {
        final storedTrip = await (_database.select(
          _database.tripDefinitions,
        )..where((table) => table.id.equals(trip.id.value))).getSingleOrNull();
        if (storedTrip == null) {
          await _database
              .into(_database.tripDefinitions)
              .insert(
                TripDefinitionsCompanion.insert(
                  id: Value<int>(trip.id.value),
                  name: trip.name,
                ),
              );
        } else {
          final loadedTrip = await _loadTrip(trip.id);
          if (!_sameTrip(loadedTrip, trip)) {
            throw StateError('Trip ${trip.id} has conflicting definitions.');
          }
        }
      }

      for (final trip in addedTrips) {
        final hasComposition =
            await (_database.select(_database.tripStepOccurrences)
                  ..where(
                    (table) => table.tripDefinitionId.equals(trip.id.value),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (hasComposition == null) {
          await _insertTripComposition(trip);
        }
      }

      await _updateExistingTestRoutes(existing: existing, target: definition);
      await _reconcileScheduleOccurrences(
        existing: existing,
        target: definition,
      );
    });
  }

  void _validateAdditiveExtension({
    required ScheduleDefinition existing,
    required ScheduleDefinition target,
  }) {
    if (existing.id != target.id || existing.name != target.name) {
      throw StateError(
        'Schedule ${existing.id} cannot be replaced by a different identity.',
      );
    }

    final targetByOccurrenceId = <int, ScheduleTripDefinition>{
      for (final scheduledTrip in target.trips)
        scheduledTrip.occurrenceId: scheduledTrip,
    };
    for (final existingTrip in existing.trips) {
      final targetTrip = targetByOccurrenceId[existingTrip.occurrenceId];
      if (targetTrip == null) {
        throw StateError(
          'Schedule ${existing.id} cannot remove occurrence '
          '${existingTrip.occurrenceId}.',
        );
      }
      if (targetTrip.trip.id != existingTrip.trip.id) {
        throw StateError(
          'Schedule occurrence ${existingTrip.occurrenceId} cannot change '
          'from ${existingTrip.trip.id} to ${targetTrip.trip.id}.',
        );
      }
      _validateExistingTripExtension(
        existing: existingTrip.trip,
        target: targetTrip.trip,
      );
    }
  }

  void _validateExistingTripExtension({
    required TripDefinition existing,
    required TripDefinition target,
  }) {
    if (existing.id != target.id ||
        existing.name != target.name ||
        existing.steps.length != target.steps.length) {
      throw StateError('Existing Trip ${existing.id} cannot be redefined.');
    }
    for (var index = 0; index < existing.steps.length; index += 1) {
      final existingStep = existing.steps[index];
      final targetStep = target.steps[index];
      final compatible = switch ((existingStep, targetStep)) {
        (
          TestStep(
            id: final existingId,
            name: final existingName,
            testAgentId: final existingAgentId,
          ),
          TestStep(
            id: final targetId,
            name: final targetName,
            testAgentId: final targetAgentId,
          ),
        ) =>
          existingId == targetId &&
              existingName == targetName &&
              existingAgentId == targetAgentId,
        _ => _sameStep(existingStep, targetStep),
      };
      if (!compatible) {
        throw StateError(
          'Existing Step ${existingStep.id} in Trip ${existing.id} cannot be '
          'redefined.',
        );
      }
    }
  }

  Future<void> _updateExistingTestRoutes({
    required ScheduleDefinition existing,
    required ScheduleDefinition target,
  }) async {
    final targetTrips = <TripDefinitionId, TripDefinition>{
      for (final scheduledTrip in target.trips)
        scheduledTrip.trip.id: scheduledTrip.trip,
    };
    for (final existingScheduledTrip in existing.trips) {
      final targetTrip = targetTrips[existingScheduledTrip.trip.id];
      if (targetTrip == null) {
        throw StateError(
          'Target Schedule omits Trip ${existingScheduledTrip.trip.id}.',
        );
      }
      for (var index = 0; index < targetTrip.steps.length; index += 1) {
        final existingStep = existingScheduledTrip.trip.steps[index];
        final targetStep = targetTrip.steps[index];
        if (existingStep case TestStep() when targetStep is TestStep) {
          if (existingStep.trueDestinationTripDefinitionId !=
                  targetStep.trueDestinationTripDefinitionId ||
              existingStep.falseDestinationTripDefinitionId !=
                  targetStep.falseDestinationTripDefinitionId) {
            await _requireScheduleLocalTripForRouteUpdate(
              scheduleDefinitionId: target.id,
              tripDefinitionId: targetTrip.id,
            );
            final updated =
                await (_database.update(_database.testStepDefinitions)..where(
                      (table) => table.stepDefinitionId.equals(targetStep.id),
                    ))
                    .write(
                      TestStepDefinitionsCompanion(
                        trueDestinationTripDefinitionId: Value<int?>(
                          targetStep.trueDestinationTripDefinitionId?.value,
                        ),
                        falseDestinationTripDefinitionId: Value<int?>(
                          targetStep.falseDestinationTripDefinitionId?.value,
                        ),
                      ),
                    );
            if (updated != 1) {
              throw StateError(
                'Test Step ${targetStep.id} route update was not written.',
              );
            }
          }
        }
      }
    }
  }

  Future<void> _requireScheduleLocalTripForRouteUpdate({
    required int scheduleDefinitionId,
    required TripDefinitionId tripDefinitionId,
  }) async {
    final occurrences =
        await (_database.select(_database.scheduleTripOccurrences)..where(
              (table) => table.tripDefinitionId.equals(tripDefinitionId.value),
            ))
            .get();
    if (occurrences.any(
      (occurrence) => occurrence.scheduleDefinitionId != scheduleDefinitionId,
    )) {
      throw StateError(
        'Trip $tripDefinitionId is shared by another Schedule and its routes '
        'cannot be updated in place.',
      );
    }
  }

  Future<void> _reconcileScheduleOccurrences({
    required ScheduleDefinition existing,
    required ScheduleDefinition target,
  }) async {
    final existingOccurrenceIds = existing.trips
        .map((scheduledTrip) => scheduledTrip.occurrenceId)
        .toSet();
    final maximumPosition = <int>[
      ...existing.trips.map((scheduledTrip) => scheduledTrip.position),
      ...target.trips.map((scheduledTrip) => scheduledTrip.position),
    ].reduce((left, right) => left > right ? left : right);
    final temporaryPositionStart = maximumPosition + 1;

    for (var index = 0; index < existing.trips.length; index += 1) {
      final occurrence = existing.trips[index];
      await (_database.update(_database.scheduleTripOccurrences)..where(
            (table) =>
                table.scheduleDefinitionId.equals(existing.id) &
                table.id.equals(occurrence.occurrenceId),
          ))
          .write(
            ScheduleTripOccurrencesCompanion(
              position: Value<int>(temporaryPositionStart + index),
            ),
          );
    }

    for (final occurrence in target.trips) {
      if (!existingOccurrenceIds.contains(occurrence.occurrenceId)) {
        await _database
            .into(_database.scheduleTripOccurrences)
            .insert(
              ScheduleTripOccurrencesCompanion.insert(
                id: Value<int>(occurrence.occurrenceId),
                scheduleDefinitionId: target.id,
                tripDefinitionId: occurrence.trip.id.value,
                position: occurrence.position,
              ),
            );
      }
    }

    for (final occurrence in target.trips) {
      if (existingOccurrenceIds.contains(occurrence.occurrenceId)) {
        final updated =
            await (_database.update(_database.scheduleTripOccurrences)..where(
                  (table) =>
                      table.scheduleDefinitionId.equals(target.id) &
                      table.id.equals(occurrence.occurrenceId),
                ))
                .write(
                  ScheduleTripOccurrencesCompanion(
                    position: Value<int>(occurrence.position),
                  ),
                );
        if (updated != 1) {
          throw StateError(
            'Schedule occurrence ${occurrence.occurrenceId} position update '
            'was not written.',
          );
        }
      }
    }
  }

  bool _sameScheduleDefinition(
    ScheduleDefinition left,
    ScheduleDefinition right,
  ) {
    if (left.id != right.id ||
        left.name != right.name ||
        left.trips.length != right.trips.length) {
      return false;
    }
    final rightByOccurrenceId = <int, ScheduleTripDefinition>{
      for (final scheduledTrip in right.trips)
        scheduledTrip.occurrenceId: scheduledTrip,
    };
    for (final leftTrip in left.trips) {
      final rightTrip = rightByOccurrenceId[leftTrip.occurrenceId];
      if (rightTrip == null ||
          leftTrip.position != rightTrip.position ||
          !_sameTrip(leftTrip.trip, rightTrip.trip)) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<ScheduleDefinition> loadDefinition(int scheduleDefinitionId) async {
    final schedule =
        await (_database.select(_database.scheduleDefinitions)
              ..where((table) => table.id.equals(scheduleDefinitionId)))
            .getSingleOrNull();
    if (schedule == null) {
      throw StateError('Schedule $scheduleDefinitionId does not exist.');
    }

    final occurrences =
        await (_database.select(_database.scheduleTripOccurrences)
              ..where(
                (table) =>
                    table.scheduleDefinitionId.equals(scheduleDefinitionId),
              )
              ..orderBy(<OrderClauseGenerator<ScheduleTripOccurrences>>[
                (table) => OrderingTerm.asc(table.position),
              ]))
            .get();
    if (occurrences.isEmpty) {
      throw StateError('Schedule $scheduleDefinitionId has no Trips.');
    }

    final trips = <ScheduleTripDefinition>[];
    for (final occurrence in occurrences) {
      trips.add(
        ScheduleTripDefinition(
          occurrenceId: occurrence.id,
          position: occurrence.position,
          trip: await _loadTrip(TripDefinitionId(occurrence.tripDefinitionId)),
        ),
      );
    }
    final definition = ScheduleDefinition(
      id: schedule.id,
      name: schedule.name,
      trips: trips,
    );
    _validateDefinition(definition);
    return definition;
  }

  @override
  Future<ScheduleRun> startOrLoadRun(int scheduleDefinitionId) async {
    await loadDefinition(scheduleDefinitionId);
    return _database.transaction(() async {
      final existing =
          await (_database.select(_database.scheduleRuns)
                ..where(
                  (table) =>
                      table.scheduleDefinitionId.equals(scheduleDefinitionId),
                )
                ..orderBy(<OrderClauseGenerator<ScheduleRuns>>[
                  (table) => OrderingTerm.desc(table.id),
                ])
                ..limit(1))
              .getSingleOrNull();
      if (existing != null) {
        return _loadRun(existing.id);
      }

      final firstOccurrence =
          await (_database.select(_database.scheduleTripOccurrences)
                ..where(
                  (table) =>
                      table.scheduleDefinitionId.equals(scheduleDefinitionId),
                )
                ..orderBy(<OrderClauseGenerator<ScheduleTripOccurrences>>[
                  (table) => OrderingTerm.asc(table.position),
                ])
                ..limit(1))
              .getSingleOrNull();
      if (firstOccurrence == null) {
        throw StateError('Schedule $scheduleDefinitionId has no Trips.');
      }

      final runId = await _database
          .into(_database.scheduleRuns)
          .insert(
            ScheduleRunsCompanion.insert(
              scheduleDefinitionId: scheduleDefinitionId,
              currentTripOccurrenceId: Value<int?>(firstOccurrence.id),
            ),
          );
      await _appendTraceEvent(
        scheduleRunId: runId,
        type: ExecutionTraceEventType.scheduleRunStarted,
      );
      return _loadRun(runId);
    });
  }

  @override
  Future<ScheduleRun> replaceRunFromBeginning(int scheduleDefinitionId) async {
    await loadDefinition(scheduleDefinitionId);
    return _database.transaction(() async {
      final schedule =
          await (_database.select(_database.scheduleDefinitions)
                ..where((table) => table.id.equals(scheduleDefinitionId)))
              .getSingleOrNull();
      if (schedule == null) {
        throw StateError('Schedule $scheduleDefinitionId does not exist.');
      }

      final firstOccurrence =
          await (_database.select(_database.scheduleTripOccurrences)
                ..where(
                  (table) =>
                      table.scheduleDefinitionId.equals(scheduleDefinitionId),
                )
                ..orderBy(<OrderClauseGenerator<ScheduleTripOccurrences>>[
                  (table) => OrderingTerm.asc(table.position),
                ])
                ..limit(1))
              .getSingleOrNull();
      if (firstOccurrence == null) {
        throw StateError('Schedule $scheduleDefinitionId has no Trips.');
      }

      final latest =
          await (_database.select(_database.scheduleRuns)
                ..where(
                  (table) =>
                      table.scheduleDefinitionId.equals(scheduleDefinitionId),
                )
                ..orderBy(<OrderClauseGenerator<ScheduleRuns>>[
                  (table) => OrderingTerm.desc(table.id),
                ])
                ..limit(1))
              .getSingleOrNull();
      if (latest?.currentTripOccurrenceId != null) {
        throw StateError(
          'Schedule $scheduleDefinitionId already has an active run.',
        );
      }

      final runId = await _database
          .into(_database.scheduleRuns)
          .insert(
            ScheduleRunsCompanion.insert(
              scheduleDefinitionId: scheduleDefinitionId,
              currentTripOccurrenceId: Value<int?>(firstOccurrence.id),
            ),
          );
      await _appendTraceEvent(
        scheduleRunId: runId,
        type: ExecutionTraceEventType.scheduleRunStarted,
      );
      return _loadRun(runId);
    });
  }

  @override
  Future<ScheduleRun> loadRun(int scheduleRunId) async {
    await _requireExecutableScheduleForRun(scheduleRunId);
    return _loadRun(scheduleRunId);
  }

  @override
  Future<void> recordTripStarted({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
  }) async {
    await _requireExecutableScheduleForRun(scheduleRunId);
    await _database.transaction(() async {
      await _requireCurrentRun(
        scheduleRunId: scheduleRunId,
        expectedCurrentTripOccurrenceId: expectedCurrentTripOccurrenceId,
      );
      await _appendTraceEvent(
        scheduleRunId: scheduleRunId,
        type: ExecutionTraceEventType.tripStarted,
        tripOccurrenceId: expectedCurrentTripOccurrenceId,
      );
    });
  }

  @override
  Future<void> recordStepStarted({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
    required int stepPosition,
    required int expectedStepDefinitionId,
  }) {
    return _recordStepEvent(
      scheduleRunId: scheduleRunId,
      expectedCurrentTripOccurrenceId: expectedCurrentTripOccurrenceId,
      stepPosition: stepPosition,
      expectedStepDefinitionId: expectedStepDefinitionId,
      type: ExecutionTraceEventType.stepStarted,
    );
  }

  @override
  Future<void> recordStepCompleted({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
    required int stepPosition,
    required int expectedStepDefinitionId,
  }) {
    return _recordStepEvent(
      scheduleRunId: scheduleRunId,
      expectedCurrentTripOccurrenceId: expectedCurrentTripOccurrenceId,
      stepPosition: stepPosition,
      expectedStepDefinitionId: expectedStepDefinitionId,
      type: ExecutionTraceEventType.stepCompleted,
    );
  }

  @override
  Future<ScheduleRun> checkpointTripCompletion({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
    required TripDefinitionId? routingResultTripDefinitionId,
  }) async {
    await _requireExecutableScheduleForRun(scheduleRunId);
    await _database.transaction(() async {
      final run = await (_database.select(
        _database.scheduleRuns,
      )..where((table) => table.id.equals(scheduleRunId))).getSingle();
      if (run.currentTripOccurrenceId != expectedCurrentTripOccurrenceId) {
        throw StateError(
          'Schedule run $scheduleRunId no longer points to occurrence '
          '$expectedCurrentTripOccurrenceId.',
        );
      }

      final currentOccurrence =
          await (_database.select(_database.scheduleTripOccurrences)..where(
                (table) => table.id.equals(expectedCurrentTripOccurrenceId),
              ))
              .getSingle();
      final ScheduleTripOccurrenceRow? nextOccurrence;
      if (routingResultTripDefinitionId == null) {
        nextOccurrence =
            await (_database.select(_database.scheduleTripOccurrences)
                  ..where(
                    (table) =>
                        table.scheduleDefinitionId.equals(
                          run.scheduleDefinitionId,
                        ) &
                        table.position.isBiggerThanValue(
                          currentOccurrence.position,
                        ),
                  )
                  ..orderBy(<OrderClauseGenerator<ScheduleTripOccurrences>>[
                    (table) => OrderingTerm.asc(table.position),
                  ])
                  ..limit(1))
                .getSingleOrNull();
      } else {
        nextOccurrence =
            await (_database.select(_database.scheduleTripOccurrences)..where(
                  (table) =>
                      table.scheduleDefinitionId.equals(
                        run.scheduleDefinitionId,
                      ) &
                      table.tripDefinitionId.equals(
                        routingResultTripDefinitionId.value,
                      ),
                ))
                .getSingleOrNull();
        if (nextOccurrence == null) {
          throw StateError(
            'Trip destination $routingResultTripDefinitionId is absent from '
            'Schedule ${run.scheduleDefinitionId}.',
          );
        }
      }

      await _appendTraceEvent(
        scheduleRunId: scheduleRunId,
        type: ExecutionTraceEventType.tripCompleted,
        tripOccurrenceId: expectedCurrentTripOccurrenceId,
      );
      await _appendTraceEvent(
        scheduleRunId: scheduleRunId,
        type: ExecutionTraceEventType.routeDecision,
        tripOccurrenceId: expectedCurrentTripOccurrenceId,
        routingResultTripDefinitionId: routingResultTripDefinitionId,
        selectedDestinationTripOccurrenceId: nextOccurrence?.id,
      );

      final updated =
          await (_database.update(_database.scheduleRuns)..where(
                (table) =>
                    table.id.equals(scheduleRunId) &
                    table.currentTripOccurrenceId.equals(
                      expectedCurrentTripOccurrenceId,
                    ),
              ))
              .write(
                ScheduleRunsCompanion(
                  currentTripOccurrenceId: Value<int?>(nextOccurrence?.id),
                ),
              );
      if (updated != 1) {
        throw StateError(
          'Schedule run $scheduleRunId checkpoint was not written.',
        );
      }
      if (nextOccurrence == null) {
        await _appendTraceEvent(
          scheduleRunId: scheduleRunId,
          type: ExecutionTraceEventType.scheduleRunCompleted,
        );
      }
    });

    return _loadRun(scheduleRunId);
  }

  @override
  Future<List<ExecutionTraceEvent>> loadExecutionTrace(
    int scheduleRunId,
  ) async {
    final rows =
        await (_database.select(_database.executionTraceEvents)
              ..where((table) => table.scheduleRunId.equals(scheduleRunId))
              ..orderBy(<OrderClauseGenerator<ExecutionTraceEvents>>[
                (table) => OrderingTerm.asc(table.sequence),
              ]))
            .get();
    return rows
        .map(
          (row) => ExecutionTraceEvent(
            id: row.id,
            scheduleRunId: row.scheduleRunId,
            sequence: row.sequence,
            type: _eventTypeFromStorage(row.eventType),
            tripOccurrenceId: row.tripOccurrenceId,
            stepOccurrenceId: row.stepOccurrenceId,
            routingResultTripDefinitionId:
                row.routingResultTripDefinitionId == null
                ? null
                : TripDefinitionId(row.routingResultTripDefinitionId!),
            selectedDestinationTripOccurrenceId:
                row.selectedDestinationTripOccurrenceId,
            occurredAtUtcUs: row.occurredAtUtcUs,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _recordStepEvent({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
    required int stepPosition,
    required int expectedStepDefinitionId,
    required ExecutionTraceEventType type,
  }) async {
    await _requireExecutableScheduleForRun(scheduleRunId);
    await _database.transaction(() async {
      final run = await _requireCurrentRun(
        scheduleRunId: scheduleRunId,
        expectedCurrentTripOccurrenceId: expectedCurrentTripOccurrenceId,
      );
      final tripOccurrence =
          await (_database.select(_database.scheduleTripOccurrences)..where(
                (table) =>
                    table.id.equals(expectedCurrentTripOccurrenceId) &
                    table.scheduleDefinitionId.equals(run.scheduleDefinitionId),
              ))
              .getSingle();
      final stepOccurrence =
          await (_database.select(_database.tripStepOccurrences)..where(
                (table) =>
                    table.tripDefinitionId.equals(
                      tripOccurrence.tripDefinitionId,
                    ) &
                    table.position.equals(stepPosition),
              ))
              .getSingleOrNull();
      if (stepOccurrence == null ||
          stepOccurrence.stepDefinitionId != expectedStepDefinitionId) {
        throw StateError(
          'Step $expectedStepDefinitionId at position $stepPosition does not '
          'belong to Trip occurrence $expectedCurrentTripOccurrenceId.',
        );
      }
      await _appendTraceEvent(
        scheduleRunId: scheduleRunId,
        type: type,
        tripOccurrenceId: expectedCurrentTripOccurrenceId,
        stepOccurrenceId: stepOccurrence.id,
      );
    });
  }

  Future<ScheduleRunRow> _requireCurrentRun({
    required int scheduleRunId,
    required int expectedCurrentTripOccurrenceId,
  }) async {
    final run = await (_database.select(
      _database.scheduleRuns,
    )..where((table) => table.id.equals(scheduleRunId))).getSingle();
    if (run.currentTripOccurrenceId != expectedCurrentTripOccurrenceId) {
      throw StateError(
        'Schedule run $scheduleRunId no longer points to occurrence '
        '$expectedCurrentTripOccurrenceId.',
      );
    }
    return run;
  }

  Future<void> _requireExecutableScheduleForRun(int scheduleRunId) async {
    final run = await (_database.select(
      _database.scheduleRuns,
    )..where((table) => table.id.equals(scheduleRunId))).getSingle();
    await loadDefinition(run.scheduleDefinitionId);
  }

  Future<void> _appendTraceEvent({
    required int scheduleRunId,
    required ExecutionTraceEventType type,
    int? tripOccurrenceId,
    int? stepOccurrenceId,
    TripDefinitionId? routingResultTripDefinitionId,
    int? selectedDestinationTripOccurrenceId,
  }) async {
    final maximumSequence = _database.executionTraceEvents.sequence.max();
    final maximumRow =
        await (_database.selectOnly(_database.executionTraceEvents)
              ..addColumns(<Expression<Object>>[maximumSequence])
              ..where(
                _database.executionTraceEvents.scheduleRunId.equals(
                  scheduleRunId,
                ),
              ))
            .getSingle();
    final sequence = (maximumRow.read(maximumSequence) ?? 0) + 1;
    await _database
        .into(_database.executionTraceEvents)
        .insert(
          ExecutionTraceEventsCompanion.insert(
            scheduleRunId: scheduleRunId,
            sequence: sequence,
            eventType: _eventTypeToStorage(type),
            tripOccurrenceId: Value<int?>(tripOccurrenceId),
            stepOccurrenceId: Value<int?>(stepOccurrenceId),
            routingResultTripDefinitionId: Value<int?>(
              routingResultTripDefinitionId?.value,
            ),
            selectedDestinationTripOccurrenceId: Value<int?>(
              selectedDestinationTripOccurrenceId,
            ),
            occurredAtUtcUs: DateTime.now().toUtc().microsecondsSinceEpoch,
          ),
        );
  }

  String _eventTypeToStorage(ExecutionTraceEventType type) {
    return switch (type) {
      ExecutionTraceEventType.scheduleRunStarted =>
        scheduleRunStartedTraceEvent,
      ExecutionTraceEventType.tripStarted => tripStartedTraceEvent,
      ExecutionTraceEventType.stepStarted => stepStartedTraceEvent,
      ExecutionTraceEventType.stepCompleted => stepCompletedTraceEvent,
      ExecutionTraceEventType.tripCompleted => tripCompletedTraceEvent,
      ExecutionTraceEventType.routeDecision => routeDecisionTraceEvent,
      ExecutionTraceEventType.scheduleRunCompleted =>
        scheduleRunCompletedTraceEvent,
    };
  }

  ExecutionTraceEventType _eventTypeFromStorage(String type) {
    return switch (type) {
      scheduleRunStartedTraceEvent =>
        ExecutionTraceEventType.scheduleRunStarted,
      tripStartedTraceEvent => ExecutionTraceEventType.tripStarted,
      stepStartedTraceEvent => ExecutionTraceEventType.stepStarted,
      stepCompletedTraceEvent => ExecutionTraceEventType.stepCompleted,
      tripCompletedTraceEvent => ExecutionTraceEventType.tripCompleted,
      routeDecisionTraceEvent => ExecutionTraceEventType.routeDecision,
      scheduleRunCompletedTraceEvent =>
        ExecutionTraceEventType.scheduleRunCompleted,
      _ => throw StateError('Unknown execution trace event type $type.'),
    };
  }

  Future<void> _insertStepDefinition(Step step) async {
    switch (step) {
      case TellStep():
        await _database
            .into(_database.stepDefinitions)
            .insert(
              StepDefinitionsCompanion.insert(
                id: Value<int>(step.id),
                name: step.name,
                stepType: tellStepType,
              ),
            );
        await _database
            .into(_database.tellStepDefinitions)
            .insert(
              TellStepDefinitionsCompanion.insert(
                stepDefinitionId: Value<int>(step.id),
                stepText: step.text,
              ),
            );
      case FixedDestinationStep():
        await _database
            .into(_database.stepDefinitions)
            .insert(
              StepDefinitionsCompanion.insert(
                id: Value<int>(step.id),
                name: step.name,
                stepType: fixedDestinationStepType,
              ),
            );
        await _database
            .into(_database.fixedDestinationStepDefinitions)
            .insert(
              FixedDestinationStepDefinitionsCompanion.insert(
                stepDefinitionId: Value<int>(step.id),
                destinationTripDefinitionId:
                    step.destinationTripDefinitionId.value,
              ),
            );
      case TestStep():
        await _database
            .into(_database.stepDefinitions)
            .insert(
              StepDefinitionsCompanion.insert(
                id: Value<int>(step.id),
                name: step.name,
                stepType: testStepType,
              ),
            );
        await _database
            .into(_database.testAgentDefinitions)
            .insert(
              TestAgentDefinitionsCompanion.insert(id: step.testAgentId.value),
              mode: InsertMode.insertOrIgnore,
            );
        await _database
            .into(_database.testStepDefinitions)
            .insert(
              TestStepDefinitionsCompanion.insert(
                stepDefinitionId: Value<int>(step.id),
                testAgentId: step.testAgentId.value,
                trueDestinationTripDefinitionId: Value<int?>(
                  step.trueDestinationTripDefinitionId?.value,
                ),
                falseDestinationTripDefinitionId: Value<int?>(
                  step.falseDestinationTripDefinitionId?.value,
                ),
              ),
            );
      case OpenFdaSettingsStep():
        await _database
            .into(_database.stepDefinitions)
            .insert(
              StepDefinitionsCompanion.insert(
                id: Value<int>(step.id),
                name: step.name,
                stepType: openFdaSettingsStepType,
              ),
            );
        await _database
            .into(_database.openFdaSettingsStepDefinitions)
            .insert(
              OpenFdaSettingsStepDefinitionsCompanion.insert(
                stepDefinitionId: Value<int>(step.id),
              ),
            );
      case ChoiceStep():
        await _database
            .into(_database.stepDefinitions)
            .insert(
              StepDefinitionsCompanion.insert(
                id: Value<int>(step.id),
                name: step.name,
                stepType: choiceStepType,
              ),
            );
        await _database
            .into(_database.choiceStepDefinitions)
            .insert(
              ChoiceStepDefinitionsCompanion.insert(
                stepDefinitionId: Value<int>(step.id),
              ),
            );
        for (var position = 0; position < step.options.length; position += 1) {
          final option = step.options[position];
          await _database
              .into(_database.choiceStepOptions)
              .insert(
                ChoiceStepOptionsCompanion.insert(
                  stepDefinitionId: step.id,
                  value: option.value.value,
                  position: position,
                  label: option.label,
                  destinationTripDefinitionId:
                      option.destinationTripDefinitionId.value,
                ),
              );
        }
    }
  }

  Future<void> _insertTripComposition(TripDefinition trip) async {
    for (var position = 0; position < trip.steps.length; position += 1) {
      final step = trip.steps[position];
      final existingStep = await (_database.select(
        _database.stepDefinitions,
      )..where((table) => table.id.equals(step.id))).getSingleOrNull();
      if (existingStep == null) {
        await _insertStepDefinition(step);
      } else {
        final loadedStep = await _loadStep(step.id);
        if (!_sameStep(loadedStep, step)) {
          throw StateError('Step ${step.id} has conflicting definitions.');
        }
      }
      await _database
          .into(_database.tripStepOccurrences)
          .insert(
            TripStepOccurrencesCompanion.insert(
              tripDefinitionId: trip.id.value,
              stepDefinitionId: step.id,
              position: position,
            ),
          );
    }
  }

  Future<ScheduleRun> _loadRun(int scheduleRunId) async {
    final run = await (_database.select(
      _database.scheduleRuns,
    )..where((table) => table.id.equals(scheduleRunId))).getSingle();
    final schedule = await (_database.select(
      _database.scheduleDefinitions,
    )..where((table) => table.id.equals(run.scheduleDefinitionId))).getSingle();

    final occurrenceId = run.currentTripOccurrenceId;
    if (occurrenceId == null) {
      return ScheduleRun(
        id: run.id,
        scheduleDefinitionId: run.scheduleDefinitionId,
        scheduleName: schedule.name,
        currentTripOccurrenceId: null,
        currentTripDefinition: null,
      );
    }

    final occurrence = await (_database.select(
      _database.scheduleTripOccurrences,
    )..where((table) => table.id.equals(occurrenceId))).getSingle();
    if (occurrence.scheduleDefinitionId != run.scheduleDefinitionId) {
      throw StateError(
        'Run ${run.id} points outside Schedule ${run.scheduleDefinitionId}.',
      );
    }

    return ScheduleRun(
      id: run.id,
      scheduleDefinitionId: run.scheduleDefinitionId,
      scheduleName: schedule.name,
      currentTripOccurrenceId: occurrence.id,
      currentTripDefinition: await _loadTrip(
        TripDefinitionId(occurrence.tripDefinitionId),
      ),
    );
  }

  Future<TripDefinition> _loadTrip(TripDefinitionId tripDefinitionId) async {
    final trip = await (_database.select(
      _database.tripDefinitions,
    )..where((table) => table.id.equals(tripDefinitionId.value))).getSingle();
    final occurrences =
        await (_database.select(_database.tripStepOccurrences)
              ..where(
                (table) =>
                    table.tripDefinitionId.equals(tripDefinitionId.value),
              )
              ..orderBy(<OrderClauseGenerator<TripStepOccurrences>>[
                (table) => OrderingTerm.asc(table.position),
              ]))
            .get();
    if (occurrences.isEmpty) {
      throw StateError('Trip $tripDefinitionId has no Steps.');
    }

    final steps = <Step>[];
    for (final occurrence in occurrences) {
      steps.add(await _loadStep(occurrence.stepDefinitionId));
    }
    return TripDefinition(
      id: TripDefinitionId(trip.id),
      name: trip.name,
      steps: steps,
    );
  }

  Future<Step> _loadStep(int stepDefinitionId) async {
    final step = await (_database.select(
      _database.stepDefinitions,
    )..where((table) => table.id.equals(stepDefinitionId))).getSingle();
    final tell =
        await (_database.select(_database.tellStepDefinitions)..where(
              (table) => table.stepDefinitionId.equals(stepDefinitionId),
            ))
            .getSingleOrNull();
    final fixedDestination =
        await (_database.select(_database.fixedDestinationStepDefinitions)
              ..where(
                (table) => table.stepDefinitionId.equals(stepDefinitionId),
              ))
            .getSingleOrNull();
    final test =
        await (_database.select(_database.testStepDefinitions)..where(
              (table) => table.stepDefinitionId.equals(stepDefinitionId),
            ))
            .getSingleOrNull();
    final openFdaSettings =
        await (_database.select(_database.openFdaSettingsStepDefinitions)
              ..where(
                (table) => table.stepDefinitionId.equals(stepDefinitionId),
              ))
            .getSingleOrNull();
    final choice =
        await (_database.select(_database.choiceStepDefinitions)..where(
              (table) => table.stepDefinitionId.equals(stepDefinitionId),
            ))
            .getSingleOrNull();
    final choiceOptions =
        await (_database.select(_database.choiceStepOptions)
              ..where(
                (table) => table.stepDefinitionId.equals(stepDefinitionId),
              )
              ..orderBy(<OrderClauseGenerator<ChoiceStepOptions>>[
                (table) => OrderingTerm.asc(table.position),
              ]))
            .get();
    if (choice == null && choiceOptions.isNotEmpty) {
      throw StateError(
        'Choice Step $stepDefinitionId has options without a subtype marker.',
      );
    }

    final activeSubtypeCount = <Object?>[
      tell,
      fixedDestination,
      test,
      openFdaSettings,
      choice,
    ].where((row) => row != null).length;
    if (activeSubtypeCount != 1) {
      throw StateError(
        'Step $stepDefinitionId must have exactly one active subtype row.',
      );
    }

    switch (step.stepType) {
      case tellStepType:
        if (tell == null || activeSubtypeCount != 1) {
          throw StateError('Tell Step $stepDefinitionId has no subtype row.');
        }
        return TellStep(id: step.id, name: step.name, text: tell.stepText);
      case fixedDestinationStepType:
        if (fixedDestination == null) {
          throw StateError(
            'Fixed Destination Step $stepDefinitionId has no subtype row.',
          );
        }
        return FixedDestinationStep(
          id: step.id,
          name: step.name,
          destinationTripDefinitionId: TripDefinitionId(
            fixedDestination.destinationTripDefinitionId,
          ),
        );
      case testStepType:
        if (test == null) {
          throw StateError('Test Step $stepDefinitionId has no subtype row.');
        }
        final testAgentId = TestAgentId(test.testAgentId);
        return TestStep(
          id: step.id,
          name: step.name,
          testAgentId: testAgentId,
          testAgent: _testAgentResolver.resolve(testAgentId),
          trueDestinationTripDefinitionId:
              test.trueDestinationTripDefinitionId == null
              ? null
              : TripDefinitionId(test.trueDestinationTripDefinitionId!),
          falseDestinationTripDefinitionId:
              test.falseDestinationTripDefinitionId == null
              ? null
              : TripDefinitionId(test.falseDestinationTripDefinitionId!),
        );
      case openFdaSettingsStepType:
        if (openFdaSettings == null) {
          throw StateError(
            'Open FDA Settings Step $stepDefinitionId has no subtype row.',
          );
        }
        return OpenFdaSettingsStep(
          id: step.id,
          name: step.name,
          settingsOpeningAuthority: _fdaSettingsOpeningAuthority,
        );
      case choiceStepType:
        if (choice == null) {
          throw StateError(
            'Choice Step $stepDefinitionId has no subtype marker.',
          );
        }
        return ChoiceStep(
          id: step.id,
          name: step.name,
          options: choiceOptions
              .map(
                (option) => ChoiceOption(
                  value: ChoiceValue(option.value),
                  label: option.label,
                  destinationTripDefinitionId: TripDefinitionId(
                    option.destinationTripDefinitionId,
                  ),
                ),
              )
              .toList(),
        );
      default:
        throw StateError(
          'Step $stepDefinitionId has unknown type ${step.stepType}.',
        );
    }
  }

  void _validateDefinition(ScheduleDefinition definition) {
    if (definition.name.trim().isEmpty) {
      throw ArgumentError.value(definition.name, 'name', 'Must not be empty.');
    }

    final occurrenceIds = <int>{};
    final positions = <int>{};
    final tripIds = <TripDefinitionId>{};
    final stepsById = <int, Step>{};
    for (final scheduledTrip in definition.trips) {
      if (!occurrenceIds.add(scheduledTrip.occurrenceId)) {
        throw ArgumentError('Duplicate Schedule Trip occurrence identity.');
      }
      if (!positions.add(scheduledTrip.position)) {
        throw ArgumentError('Duplicate Schedule Trip position.');
      }
      if (!tripIds.add(scheduledTrip.trip.id)) {
        throw ArgumentError('A Trip definition may appear only once.');
      }
      if (scheduledTrip.position < 0) {
        throw ArgumentError('Schedule Trip position must be non-negative.');
      }
      if (scheduledTrip.trip.name.trim().isEmpty) {
        throw ArgumentError('Trip names must not be empty.');
      }
    }

    for (final scheduledTrip in definition.trips) {
      final steps = scheduledTrip.trip.steps;
      for (var index = 0; index < steps.length; index += 1) {
        final step = steps[index];
        final previous = stepsById[step.id];
        if (previous != null && !_sameStep(previous, step)) {
          throw ArgumentError('Step ${step.id} has conflicting definitions.');
        }
        stepsById[step.id] = step;
        if (step.name.trim().isEmpty) {
          throw ArgumentError('Step names must not be empty.');
        }
        if (step case TellStep(text: final text) when text.trim().isEmpty) {
          throw ArgumentError('Tell Step text must not be empty.');
        }
        if (step case FixedDestinationStep(
          destinationTripDefinitionId: final destination,
        ) when !tripIds.contains(destination)) {
          throw ArgumentError(
            'Fixed Destination Step ${step.id} points to $destination, which '
            'is absent from Schedule ${definition.id}.',
          );
        }
        if (step is FixedDestinationStep && index != steps.length - 1) {
          throw ArgumentError(
            'Fixed Destination Step ${step.id} must be terminal in Trip '
            '${scheduledTrip.trip.id}.',
          );
        }
        if (step case TestStep(
          trueDestinationTripDefinitionId: final trueDestination,
          falseDestinationTripDefinitionId: final falseDestination,
        )) {
          for (final destination in <TripDefinitionId?>[
            trueDestination,
            falseDestination,
          ]) {
            if (destination != null && !tripIds.contains(destination)) {
              throw ArgumentError(
                'Test Step ${step.id} points to $destination, which is '
                'absent from Schedule ${definition.id}.',
              );
            }
          }
        }
        if (step is TestStep && index != steps.length - 1) {
          throw ArgumentError(
            'Test Step ${step.id} must be terminal in Trip '
            '${scheduledTrip.trip.id}.',
          );
        }
        if (step is OpenFdaSettingsStep && index != steps.length - 1) {
          throw ArgumentError(
            'Open FDA Settings Step ${step.id} must be terminal in Trip '
            '${scheduledTrip.trip.id}.',
          );
        }
        if (step case ChoiceStep(options: final options)) {
          for (final option in options) {
            final destination = option.destinationTripDefinitionId;
            if (!tripIds.contains(destination)) {
              throw ArgumentError(
                'Choice Step ${step.id} points to $destination, which is '
                'absent from Schedule ${definition.id}.',
              );
            }
          }
        }
        if (step is ChoiceStep && index != steps.length - 1) {
          throw ArgumentError(
            'Choice Step ${step.id} must be terminal in Trip '
            '${scheduledTrip.trip.id}.',
          );
        }
      }
    }
  }

  bool _sameStep(Step left, Step right) {
    return switch ((left, right)) {
      (
        TellStep(id: final leftId, name: final leftName, text: final leftText),
        TellStep(
          id: final rightId,
          name: final rightName,
          text: final rightText,
        ),
      ) =>
        leftId == rightId && leftName == rightName && leftText == rightText,
      (
        FixedDestinationStep(
          id: final leftId,
          name: final leftName,
          destinationTripDefinitionId: final leftDestination,
        ),
        FixedDestinationStep(
          id: final rightId,
          name: final rightName,
          destinationTripDefinitionId: final rightDestination,
        ),
      ) =>
        leftId == rightId &&
            leftName == rightName &&
            leftDestination == rightDestination,
      (
        TestStep(
          id: final leftId,
          name: final leftName,
          testAgentId: final leftAgentId,
          trueDestinationTripDefinitionId: final leftTrue,
          falseDestinationTripDefinitionId: final leftFalse,
        ),
        TestStep(
          id: final rightId,
          name: final rightName,
          testAgentId: final rightAgentId,
          trueDestinationTripDefinitionId: final rightTrue,
          falseDestinationTripDefinitionId: final rightFalse,
        ),
      ) =>
        leftId == rightId &&
            leftName == rightName &&
            leftAgentId == rightAgentId &&
            leftTrue == rightTrue &&
            leftFalse == rightFalse,
      (
        OpenFdaSettingsStep(id: final leftId, name: final leftName),
        OpenFdaSettingsStep(id: final rightId, name: final rightName),
      ) =>
        leftId == rightId && leftName == rightName,
      (
        ChoiceStep(
          id: final leftId,
          name: final leftName,
          options: final leftOptions,
        ),
        ChoiceStep(
          id: final rightId,
          name: final rightName,
          options: final rightOptions,
        ),
      ) =>
        leftId == rightId &&
            leftName == rightName &&
            _sameChoiceOptions(leftOptions, rightOptions),
      _ => false,
    };
  }

  bool _sameChoiceOptions(List<ChoiceOption> left, List<ChoiceOption> right) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }

  bool _sameTrip(TripDefinition left, TripDefinition right) {
    if (left.id != right.id ||
        left.name != right.name ||
        left.steps.length != right.steps.length) {
      return false;
    }
    for (var index = 0; index < left.steps.length; index += 1) {
      if (!_sameStep(left.steps[index], right.steps[index])) {
        return false;
      }
    }
    return true;
  }
}

final class _MissingTestAgentResolver implements TestAgentResolver {
  const _MissingTestAgentResolver();

  @override
  Never resolve(TestAgentId id) {
    throw MissingTestAgentBindingException(id);
  }
}

final class _UnavailableFdaSettingsOpeningAuthority
    implements FdaSettingsOpeningAuthority {
  const _UnavailableFdaSettingsOpeningAuthority();

  @override
  Future<void> openSettings() {
    return Future<void>.error(
      StateError('No FDA Settings-opening authority was supplied.'),
    );
  }
}
