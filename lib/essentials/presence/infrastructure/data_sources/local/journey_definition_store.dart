import 'package:drift/drift.dart';

part 'journey_definition_store.g.dart';

const String tellStepType = 'tell';
const String askStepType = 'ask';

@DataClassName('JourneyRow')
class Journeys extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('StepRow')
class Steps extends Table {
  IntColumn get id => integer()();

  IntColumn get journeyId =>
      integer().named('journey_id').references(Journeys, #id)();

  late final IntColumn position = integer().check(
    position.isBiggerOrEqualValue(0),
  )();

  late final TextColumn stepType = text()
      .named('type')
      .check(stepType.isIn(const <String>[tellStepType, askStepType]))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{journeyId, position},
  ];
}

@DataClassName('TellStepRow')
class TellSteps extends Table {
  IntColumn get stepId => integer()
      .named('step_id')
      .references(Steps, #id, onDelete: KeyAction.cascade)();

  TextColumn get stepText => text().named('text')();

  BoolColumn get advancesAutomatically =>
      boolean().named('advances_automatically')();

  late final IntColumn holdDurationMs = integer()
      .named('hold_duration_ms')
      .check(holdDurationMs.isBiggerOrEqualValue(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{stepId};
}

@DataClassName('AskStepRow')
class AskSteps extends Table {
  IntColumn get stepId => integer()
      .named('step_id')
      .references(Steps, #id, onDelete: KeyAction.cascade)();

  TextColumn get question => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{stepId};
}

@DriftDatabase(tables: <Type>[Journeys, Steps, TellSteps, AskSteps])
class JourneyDefinitionStore extends _$JourneyDefinitionStore {
  JourneyDefinitionStore(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
