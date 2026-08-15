// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_database.dart';

// ignore_for_file: type=lint
class $ScheduleDefinitionsTable extends ScheduleDefinitions
    with TableInfo<$ScheduleDefinitionsTable, ScheduleDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleDefinitionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ScheduleDefinitionsTable createAlias(String alias) {
    return $ScheduleDefinitionsTable(attachedDatabase, alias);
  }
}

class ScheduleDefinitionRow extends DataClass
    implements Insertable<ScheduleDefinitionRow> {
  final int id;
  final String name;
  const ScheduleDefinitionRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ScheduleDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleDefinitionsCompanion(id: Value(id), name: Value(name));
  }

  factory ScheduleDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleDefinitionRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  ScheduleDefinitionRow copyWith({int? id, String? name}) =>
      ScheduleDefinitionRow(id: id ?? this.id, name: name ?? this.name);
  ScheduleDefinitionRow copyWithCompanion(ScheduleDefinitionsCompanion data) {
    return ScheduleDefinitionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleDefinitionRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleDefinitionRow &&
          other.id == this.id &&
          other.name == this.name);
}

class ScheduleDefinitionsCompanion
    extends UpdateCompanion<ScheduleDefinitionRow> {
  final Value<int> id;
  final Value<String> name;
  const ScheduleDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ScheduleDefinitionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<ScheduleDefinitionRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ScheduleDefinitionsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ScheduleDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $TripDefinitionsTable extends TripDefinitions
    with TableInfo<$TripDefinitionsTable, TripDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripDefinitionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TripDefinitionsTable createAlias(String alias) {
    return $TripDefinitionsTable(attachedDatabase, alias);
  }
}

class TripDefinitionRow extends DataClass
    implements Insertable<TripDefinitionRow> {
  final int id;
  final String name;
  const TripDefinitionRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TripDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return TripDefinitionsCompanion(id: Value(id), name: Value(name));
  }

  factory TripDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripDefinitionRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TripDefinitionRow copyWith({int? id, String? name}) =>
      TripDefinitionRow(id: id ?? this.id, name: name ?? this.name);
  TripDefinitionRow copyWithCompanion(TripDefinitionsCompanion data) {
    return TripDefinitionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripDefinitionRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripDefinitionRow &&
          other.id == this.id &&
          other.name == this.name);
}

class TripDefinitionsCompanion extends UpdateCompanion<TripDefinitionRow> {
  final Value<int> id;
  final Value<String> name;
  const TripDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TripDefinitionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<TripDefinitionRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TripDefinitionsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TripDefinitionsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $StepDefinitionsTable extends StepDefinitions
    with TableInfo<$StepDefinitionsTable, StepDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StepDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stepTypeMeta = const VerificationMeta(
    'stepType',
  );
  @override
  late final GeneratedColumn<String> stepType = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => stepType.isIn(const <String>[
      tellStepType,
      fixedDestinationStepType,
      testStepType,
      choiceStepType,
      fdaTestStepType,
      contactsSourceReadinessStepType,
      openFdaSettingsStepType,
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [stepType, id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'step_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StepDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('type')) {
      context.handle(
        _stepTypeMeta,
        stepType.isAcceptableOrUnknown(data['type']!, _stepTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_stepTypeMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StepDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StepDefinitionRow(
      stepType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $StepDefinitionsTable createAlias(String alias) {
    return $StepDefinitionsTable(attachedDatabase, alias);
  }
}

class StepDefinitionRow extends DataClass
    implements Insertable<StepDefinitionRow> {
  final String stepType;
  final int id;
  final String name;
  const StepDefinitionRow({
    required this.stepType,
    required this.id,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['type'] = Variable<String>(stepType);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  StepDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return StepDefinitionsCompanion(
      stepType: Value(stepType),
      id: Value(id),
      name: Value(name),
    );
  }

  factory StepDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StepDefinitionRow(
      stepType: serializer.fromJson<String>(json['stepType']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepType': serializer.toJson<String>(stepType),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  StepDefinitionRow copyWith({String? stepType, int? id, String? name}) =>
      StepDefinitionRow(
        stepType: stepType ?? this.stepType,
        id: id ?? this.id,
        name: name ?? this.name,
      );
  StepDefinitionRow copyWithCompanion(StepDefinitionsCompanion data) {
    return StepDefinitionRow(
      stepType: data.stepType.present ? data.stepType.value : this.stepType,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StepDefinitionRow(')
          ..write('stepType: $stepType, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stepType, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StepDefinitionRow &&
          other.stepType == this.stepType &&
          other.id == this.id &&
          other.name == this.name);
}

class StepDefinitionsCompanion extends UpdateCompanion<StepDefinitionRow> {
  final Value<String> stepType;
  final Value<int> id;
  final Value<String> name;
  const StepDefinitionsCompanion({
    this.stepType = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  StepDefinitionsCompanion.insert({
    required String stepType,
    this.id = const Value.absent(),
    required String name,
  }) : stepType = Value(stepType),
       name = Value(name);
  static Insertable<StepDefinitionRow> custom({
    Expression<String>? stepType,
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (stepType != null) 'type': stepType,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  StepDefinitionsCompanion copyWith({
    Value<String>? stepType,
    Value<int>? id,
    Value<String>? name,
  }) {
    return StepDefinitionsCompanion(
      stepType: stepType ?? this.stepType,
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepType.present) {
      map['type'] = Variable<String>(stepType.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StepDefinitionsCompanion(')
          ..write('stepType: $stepType, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ScheduleTripOccurrencesTable extends ScheduleTripOccurrences
    with TableInfo<$ScheduleTripOccurrencesTable, ScheduleTripOccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleTripOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    check: () => ComparableExpr(position).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleDefinitionIdMeta =
      const VerificationMeta('scheduleDefinitionId');
  @override
  late final GeneratedColumn<int> scheduleDefinitionId = GeneratedColumn<int>(
    'schedule_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedule_definitions (id)',
    ),
  );
  static const VerificationMeta _tripDefinitionIdMeta = const VerificationMeta(
    'tripDefinitionId',
  );
  @override
  late final GeneratedColumn<int> tripDefinitionId = GeneratedColumn<int>(
    'trip_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_definitions (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    position,
    id,
    scheduleDefinitionId,
    tripDefinitionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_trip_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleTripOccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_definition_id')) {
      context.handle(
        _scheduleDefinitionIdMeta,
        scheduleDefinitionId.isAcceptableOrUnknown(
          data['schedule_definition_id']!,
          _scheduleDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleDefinitionIdMeta);
    }
    if (data.containsKey('trip_definition_id')) {
      context.handle(
        _tripDefinitionIdMeta,
        tripDefinitionId.isAcceptableOrUnknown(
          data['trip_definition_id']!,
          _tripDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tripDefinitionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {scheduleDefinitionId, position},
    {scheduleDefinitionId, tripDefinitionId},
    {scheduleDefinitionId, id},
  ];
  @override
  ScheduleTripOccurrenceRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleTripOccurrenceRow(
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scheduleDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_definition_id'],
      )!,
      tripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_definition_id'],
      )!,
    );
  }

  @override
  $ScheduleTripOccurrencesTable createAlias(String alias) {
    return $ScheduleTripOccurrencesTable(attachedDatabase, alias);
  }
}

class ScheduleTripOccurrenceRow extends DataClass
    implements Insertable<ScheduleTripOccurrenceRow> {
  final int position;
  final int id;
  final int scheduleDefinitionId;
  final int tripDefinitionId;
  const ScheduleTripOccurrenceRow({
    required this.position,
    required this.id,
    required this.scheduleDefinitionId,
    required this.tripDefinitionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['position'] = Variable<int>(position);
    map['id'] = Variable<int>(id);
    map['schedule_definition_id'] = Variable<int>(scheduleDefinitionId);
    map['trip_definition_id'] = Variable<int>(tripDefinitionId);
    return map;
  }

  ScheduleTripOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return ScheduleTripOccurrencesCompanion(
      position: Value(position),
      id: Value(id),
      scheduleDefinitionId: Value(scheduleDefinitionId),
      tripDefinitionId: Value(tripDefinitionId),
    );
  }

  factory ScheduleTripOccurrenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleTripOccurrenceRow(
      position: serializer.fromJson<int>(json['position']),
      id: serializer.fromJson<int>(json['id']),
      scheduleDefinitionId: serializer.fromJson<int>(
        json['scheduleDefinitionId'],
      ),
      tripDefinitionId: serializer.fromJson<int>(json['tripDefinitionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'position': serializer.toJson<int>(position),
      'id': serializer.toJson<int>(id),
      'scheduleDefinitionId': serializer.toJson<int>(scheduleDefinitionId),
      'tripDefinitionId': serializer.toJson<int>(tripDefinitionId),
    };
  }

  ScheduleTripOccurrenceRow copyWith({
    int? position,
    int? id,
    int? scheduleDefinitionId,
    int? tripDefinitionId,
  }) => ScheduleTripOccurrenceRow(
    position: position ?? this.position,
    id: id ?? this.id,
    scheduleDefinitionId: scheduleDefinitionId ?? this.scheduleDefinitionId,
    tripDefinitionId: tripDefinitionId ?? this.tripDefinitionId,
  );
  ScheduleTripOccurrenceRow copyWithCompanion(
    ScheduleTripOccurrencesCompanion data,
  ) {
    return ScheduleTripOccurrenceRow(
      position: data.position.present ? data.position.value : this.position,
      id: data.id.present ? data.id.value : this.id,
      scheduleDefinitionId: data.scheduleDefinitionId.present
          ? data.scheduleDefinitionId.value
          : this.scheduleDefinitionId,
      tripDefinitionId: data.tripDefinitionId.present
          ? data.tripDefinitionId.value
          : this.tripDefinitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleTripOccurrenceRow(')
          ..write('position: $position, ')
          ..write('id: $id, ')
          ..write('scheduleDefinitionId: $scheduleDefinitionId, ')
          ..write('tripDefinitionId: $tripDefinitionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(position, id, scheduleDefinitionId, tripDefinitionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleTripOccurrenceRow &&
          other.position == this.position &&
          other.id == this.id &&
          other.scheduleDefinitionId == this.scheduleDefinitionId &&
          other.tripDefinitionId == this.tripDefinitionId);
}

class ScheduleTripOccurrencesCompanion
    extends UpdateCompanion<ScheduleTripOccurrenceRow> {
  final Value<int> position;
  final Value<int> id;
  final Value<int> scheduleDefinitionId;
  final Value<int> tripDefinitionId;
  const ScheduleTripOccurrencesCompanion({
    this.position = const Value.absent(),
    this.id = const Value.absent(),
    this.scheduleDefinitionId = const Value.absent(),
    this.tripDefinitionId = const Value.absent(),
  });
  ScheduleTripOccurrencesCompanion.insert({
    required int position,
    this.id = const Value.absent(),
    required int scheduleDefinitionId,
    required int tripDefinitionId,
  }) : position = Value(position),
       scheduleDefinitionId = Value(scheduleDefinitionId),
       tripDefinitionId = Value(tripDefinitionId);
  static Insertable<ScheduleTripOccurrenceRow> custom({
    Expression<int>? position,
    Expression<int>? id,
    Expression<int>? scheduleDefinitionId,
    Expression<int>? tripDefinitionId,
  }) {
    return RawValuesInsertable({
      if (position != null) 'position': position,
      if (id != null) 'id': id,
      if (scheduleDefinitionId != null)
        'schedule_definition_id': scheduleDefinitionId,
      if (tripDefinitionId != null) 'trip_definition_id': tripDefinitionId,
    });
  }

  ScheduleTripOccurrencesCompanion copyWith({
    Value<int>? position,
    Value<int>? id,
    Value<int>? scheduleDefinitionId,
    Value<int>? tripDefinitionId,
  }) {
    return ScheduleTripOccurrencesCompanion(
      position: position ?? this.position,
      id: id ?? this.id,
      scheduleDefinitionId: scheduleDefinitionId ?? this.scheduleDefinitionId,
      tripDefinitionId: tripDefinitionId ?? this.tripDefinitionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduleDefinitionId.present) {
      map['schedule_definition_id'] = Variable<int>(scheduleDefinitionId.value);
    }
    if (tripDefinitionId.present) {
      map['trip_definition_id'] = Variable<int>(tripDefinitionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleTripOccurrencesCompanion(')
          ..write('position: $position, ')
          ..write('id: $id, ')
          ..write('scheduleDefinitionId: $scheduleDefinitionId, ')
          ..write('tripDefinitionId: $tripDefinitionId')
          ..write(')'))
        .toString();
  }
}

class $TripStepOccurrencesTable extends TripStepOccurrences
    with TableInfo<$TripStepOccurrencesTable, TripStepOccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripStepOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    check: () => ComparableExpr(position).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tripDefinitionIdMeta = const VerificationMeta(
    'tripDefinitionId',
  );
  @override
  late final GeneratedColumn<int> tripDefinitionId = GeneratedColumn<int>(
    'trip_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_definitions (id)',
    ),
  );
  static const VerificationMeta _stepDefinitionIdMeta = const VerificationMeta(
    'stepDefinitionId',
  );
  @override
  late final GeneratedColumn<int> stepDefinitionId = GeneratedColumn<int>(
    'step_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES step_definitions (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    position,
    id,
    tripDefinitionId,
    stepDefinitionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_step_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripStepOccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_definition_id')) {
      context.handle(
        _tripDefinitionIdMeta,
        tripDefinitionId.isAcceptableOrUnknown(
          data['trip_definition_id']!,
          _tripDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tripDefinitionIdMeta);
    }
    if (data.containsKey('step_definition_id')) {
      context.handle(
        _stepDefinitionIdMeta,
        stepDefinitionId.isAcceptableOrUnknown(
          data['step_definition_id']!,
          _stepDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stepDefinitionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tripDefinitionId, position},
  ];
  @override
  TripStepOccurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripStepOccurrenceRow(
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_definition_id'],
      )!,
      stepDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_definition_id'],
      )!,
    );
  }

  @override
  $TripStepOccurrencesTable createAlias(String alias) {
    return $TripStepOccurrencesTable(attachedDatabase, alias);
  }
}

class TripStepOccurrenceRow extends DataClass
    implements Insertable<TripStepOccurrenceRow> {
  final int position;
  final int id;
  final int tripDefinitionId;
  final int stepDefinitionId;
  const TripStepOccurrenceRow({
    required this.position,
    required this.id,
    required this.tripDefinitionId,
    required this.stepDefinitionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['position'] = Variable<int>(position);
    map['id'] = Variable<int>(id);
    map['trip_definition_id'] = Variable<int>(tripDefinitionId);
    map['step_definition_id'] = Variable<int>(stepDefinitionId);
    return map;
  }

  TripStepOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return TripStepOccurrencesCompanion(
      position: Value(position),
      id: Value(id),
      tripDefinitionId: Value(tripDefinitionId),
      stepDefinitionId: Value(stepDefinitionId),
    );
  }

  factory TripStepOccurrenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripStepOccurrenceRow(
      position: serializer.fromJson<int>(json['position']),
      id: serializer.fromJson<int>(json['id']),
      tripDefinitionId: serializer.fromJson<int>(json['tripDefinitionId']),
      stepDefinitionId: serializer.fromJson<int>(json['stepDefinitionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'position': serializer.toJson<int>(position),
      'id': serializer.toJson<int>(id),
      'tripDefinitionId': serializer.toJson<int>(tripDefinitionId),
      'stepDefinitionId': serializer.toJson<int>(stepDefinitionId),
    };
  }

  TripStepOccurrenceRow copyWith({
    int? position,
    int? id,
    int? tripDefinitionId,
    int? stepDefinitionId,
  }) => TripStepOccurrenceRow(
    position: position ?? this.position,
    id: id ?? this.id,
    tripDefinitionId: tripDefinitionId ?? this.tripDefinitionId,
    stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
  );
  TripStepOccurrenceRow copyWithCompanion(TripStepOccurrencesCompanion data) {
    return TripStepOccurrenceRow(
      position: data.position.present ? data.position.value : this.position,
      id: data.id.present ? data.id.value : this.id,
      tripDefinitionId: data.tripDefinitionId.present
          ? data.tripDefinitionId.value
          : this.tripDefinitionId,
      stepDefinitionId: data.stepDefinitionId.present
          ? data.stepDefinitionId.value
          : this.stepDefinitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripStepOccurrenceRow(')
          ..write('position: $position, ')
          ..write('id: $id, ')
          ..write('tripDefinitionId: $tripDefinitionId, ')
          ..write('stepDefinitionId: $stepDefinitionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(position, id, tripDefinitionId, stepDefinitionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripStepOccurrenceRow &&
          other.position == this.position &&
          other.id == this.id &&
          other.tripDefinitionId == this.tripDefinitionId &&
          other.stepDefinitionId == this.stepDefinitionId);
}

class TripStepOccurrencesCompanion
    extends UpdateCompanion<TripStepOccurrenceRow> {
  final Value<int> position;
  final Value<int> id;
  final Value<int> tripDefinitionId;
  final Value<int> stepDefinitionId;
  const TripStepOccurrencesCompanion({
    this.position = const Value.absent(),
    this.id = const Value.absent(),
    this.tripDefinitionId = const Value.absent(),
    this.stepDefinitionId = const Value.absent(),
  });
  TripStepOccurrencesCompanion.insert({
    required int position,
    this.id = const Value.absent(),
    required int tripDefinitionId,
    required int stepDefinitionId,
  }) : position = Value(position),
       tripDefinitionId = Value(tripDefinitionId),
       stepDefinitionId = Value(stepDefinitionId);
  static Insertable<TripStepOccurrenceRow> custom({
    Expression<int>? position,
    Expression<int>? id,
    Expression<int>? tripDefinitionId,
    Expression<int>? stepDefinitionId,
  }) {
    return RawValuesInsertable({
      if (position != null) 'position': position,
      if (id != null) 'id': id,
      if (tripDefinitionId != null) 'trip_definition_id': tripDefinitionId,
      if (stepDefinitionId != null) 'step_definition_id': stepDefinitionId,
    });
  }

  TripStepOccurrencesCompanion copyWith({
    Value<int>? position,
    Value<int>? id,
    Value<int>? tripDefinitionId,
    Value<int>? stepDefinitionId,
  }) {
    return TripStepOccurrencesCompanion(
      position: position ?? this.position,
      id: id ?? this.id,
      tripDefinitionId: tripDefinitionId ?? this.tripDefinitionId,
      stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripDefinitionId.present) {
      map['trip_definition_id'] = Variable<int>(tripDefinitionId.value);
    }
    if (stepDefinitionId.present) {
      map['step_definition_id'] = Variable<int>(stepDefinitionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripStepOccurrencesCompanion(')
          ..write('position: $position, ')
          ..write('id: $id, ')
          ..write('tripDefinitionId: $tripDefinitionId, ')
          ..write('stepDefinitionId: $stepDefinitionId')
          ..write(')'))
        .toString();
  }
}

class $TellStepDefinitionsTable extends TellStepDefinitions
    with TableInfo<$TellStepDefinitionsTable, TellStepDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TellStepDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stepDefinitionIdMeta = const VerificationMeta(
    'stepDefinitionId',
  );
  @override
  late final GeneratedColumn<int> stepDefinitionId = GeneratedColumn<int>(
    'step_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES step_definitions (id)',
    ),
  );
  static const VerificationMeta _stepTextMeta = const VerificationMeta(
    'stepText',
  );
  @override
  late final GeneratedColumn<String> stepText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [stepDefinitionId, stepText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tell_step_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TellStepDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('step_definition_id')) {
      context.handle(
        _stepDefinitionIdMeta,
        stepDefinitionId.isAcceptableOrUnknown(
          data['step_definition_id']!,
          _stepDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _stepTextMeta,
        stepText.isAcceptableOrUnknown(data['text']!, _stepTextMeta),
      );
    } else if (isInserting) {
      context.missing(_stepTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepDefinitionId};
  @override
  TellStepDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TellStepDefinitionRow(
      stepDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_definition_id'],
      )!,
      stepText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
    );
  }

  @override
  $TellStepDefinitionsTable createAlias(String alias) {
    return $TellStepDefinitionsTable(attachedDatabase, alias);
  }
}

class TellStepDefinitionRow extends DataClass
    implements Insertable<TellStepDefinitionRow> {
  final int stepDefinitionId;
  final String stepText;
  const TellStepDefinitionRow({
    required this.stepDefinitionId,
    required this.stepText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['step_definition_id'] = Variable<int>(stepDefinitionId);
    map['text'] = Variable<String>(stepText);
    return map;
  }

  TellStepDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return TellStepDefinitionsCompanion(
      stepDefinitionId: Value(stepDefinitionId),
      stepText: Value(stepText),
    );
  }

  factory TellStepDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TellStepDefinitionRow(
      stepDefinitionId: serializer.fromJson<int>(json['stepDefinitionId']),
      stepText: serializer.fromJson<String>(json['stepText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepDefinitionId': serializer.toJson<int>(stepDefinitionId),
      'stepText': serializer.toJson<String>(stepText),
    };
  }

  TellStepDefinitionRow copyWith({int? stepDefinitionId, String? stepText}) =>
      TellStepDefinitionRow(
        stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
        stepText: stepText ?? this.stepText,
      );
  TellStepDefinitionRow copyWithCompanion(TellStepDefinitionsCompanion data) {
    return TellStepDefinitionRow(
      stepDefinitionId: data.stepDefinitionId.present
          ? data.stepDefinitionId.value
          : this.stepDefinitionId,
      stepText: data.stepText.present ? data.stepText.value : this.stepText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TellStepDefinitionRow(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write('stepText: $stepText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stepDefinitionId, stepText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TellStepDefinitionRow &&
          other.stepDefinitionId == this.stepDefinitionId &&
          other.stepText == this.stepText);
}

class TellStepDefinitionsCompanion
    extends UpdateCompanion<TellStepDefinitionRow> {
  final Value<int> stepDefinitionId;
  final Value<String> stepText;
  const TellStepDefinitionsCompanion({
    this.stepDefinitionId = const Value.absent(),
    this.stepText = const Value.absent(),
  });
  TellStepDefinitionsCompanion.insert({
    this.stepDefinitionId = const Value.absent(),
    required String stepText,
  }) : stepText = Value(stepText);
  static Insertable<TellStepDefinitionRow> custom({
    Expression<int>? stepDefinitionId,
    Expression<String>? stepText,
  }) {
    return RawValuesInsertable({
      if (stepDefinitionId != null) 'step_definition_id': stepDefinitionId,
      if (stepText != null) 'text': stepText,
    });
  }

  TellStepDefinitionsCompanion copyWith({
    Value<int>? stepDefinitionId,
    Value<String>? stepText,
  }) {
    return TellStepDefinitionsCompanion(
      stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
      stepText: stepText ?? this.stepText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepDefinitionId.present) {
      map['step_definition_id'] = Variable<int>(stepDefinitionId.value);
    }
    if (stepText.present) {
      map['text'] = Variable<String>(stepText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TellStepDefinitionsCompanion(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write('stepText: $stepText')
          ..write(')'))
        .toString();
  }
}

class $FixedDestinationStepDefinitionsTable
    extends FixedDestinationStepDefinitions
    with
        TableInfo<
          $FixedDestinationStepDefinitionsTable,
          FixedDestinationStepDefinitionRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixedDestinationStepDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stepDefinitionIdMeta = const VerificationMeta(
    'stepDefinitionId',
  );
  @override
  late final GeneratedColumn<int> stepDefinitionId = GeneratedColumn<int>(
    'step_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES step_definitions (id)',
    ),
  );
  static const VerificationMeta _destinationTripDefinitionIdMeta =
      const VerificationMeta('destinationTripDefinitionId');
  @override
  late final GeneratedColumn<int> destinationTripDefinitionId =
      GeneratedColumn<int>(
        'destination_trip_definition_id',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trip_definitions (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    stepDefinitionId,
    destinationTripDefinitionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixed_destination_step_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixedDestinationStepDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('step_definition_id')) {
      context.handle(
        _stepDefinitionIdMeta,
        stepDefinitionId.isAcceptableOrUnknown(
          data['step_definition_id']!,
          _stepDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('destination_trip_definition_id')) {
      context.handle(
        _destinationTripDefinitionIdMeta,
        destinationTripDefinitionId.isAcceptableOrUnknown(
          data['destination_trip_definition_id']!,
          _destinationTripDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationTripDefinitionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepDefinitionId};
  @override
  FixedDestinationStepDefinitionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixedDestinationStepDefinitionRow(
      stepDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_definition_id'],
      )!,
      destinationTripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}destination_trip_definition_id'],
      )!,
    );
  }

  @override
  $FixedDestinationStepDefinitionsTable createAlias(String alias) {
    return $FixedDestinationStepDefinitionsTable(attachedDatabase, alias);
  }
}

class FixedDestinationStepDefinitionRow extends DataClass
    implements Insertable<FixedDestinationStepDefinitionRow> {
  final int stepDefinitionId;
  final int destinationTripDefinitionId;
  const FixedDestinationStepDefinitionRow({
    required this.stepDefinitionId,
    required this.destinationTripDefinitionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['step_definition_id'] = Variable<int>(stepDefinitionId);
    map['destination_trip_definition_id'] = Variable<int>(
      destinationTripDefinitionId,
    );
    return map;
  }

  FixedDestinationStepDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return FixedDestinationStepDefinitionsCompanion(
      stepDefinitionId: Value(stepDefinitionId),
      destinationTripDefinitionId: Value(destinationTripDefinitionId),
    );
  }

  factory FixedDestinationStepDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixedDestinationStepDefinitionRow(
      stepDefinitionId: serializer.fromJson<int>(json['stepDefinitionId']),
      destinationTripDefinitionId: serializer.fromJson<int>(
        json['destinationTripDefinitionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepDefinitionId': serializer.toJson<int>(stepDefinitionId),
      'destinationTripDefinitionId': serializer.toJson<int>(
        destinationTripDefinitionId,
      ),
    };
  }

  FixedDestinationStepDefinitionRow copyWith({
    int? stepDefinitionId,
    int? destinationTripDefinitionId,
  }) => FixedDestinationStepDefinitionRow(
    stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
    destinationTripDefinitionId:
        destinationTripDefinitionId ?? this.destinationTripDefinitionId,
  );
  FixedDestinationStepDefinitionRow copyWithCompanion(
    FixedDestinationStepDefinitionsCompanion data,
  ) {
    return FixedDestinationStepDefinitionRow(
      stepDefinitionId: data.stepDefinitionId.present
          ? data.stepDefinitionId.value
          : this.stepDefinitionId,
      destinationTripDefinitionId: data.destinationTripDefinitionId.present
          ? data.destinationTripDefinitionId.value
          : this.destinationTripDefinitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixedDestinationStepDefinitionRow(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write('destinationTripDefinitionId: $destinationTripDefinitionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(stepDefinitionId, destinationTripDefinitionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixedDestinationStepDefinitionRow &&
          other.stepDefinitionId == this.stepDefinitionId &&
          other.destinationTripDefinitionId ==
              this.destinationTripDefinitionId);
}

class FixedDestinationStepDefinitionsCompanion
    extends UpdateCompanion<FixedDestinationStepDefinitionRow> {
  final Value<int> stepDefinitionId;
  final Value<int> destinationTripDefinitionId;
  const FixedDestinationStepDefinitionsCompanion({
    this.stepDefinitionId = const Value.absent(),
    this.destinationTripDefinitionId = const Value.absent(),
  });
  FixedDestinationStepDefinitionsCompanion.insert({
    this.stepDefinitionId = const Value.absent(),
    required int destinationTripDefinitionId,
  }) : destinationTripDefinitionId = Value(destinationTripDefinitionId);
  static Insertable<FixedDestinationStepDefinitionRow> custom({
    Expression<int>? stepDefinitionId,
    Expression<int>? destinationTripDefinitionId,
  }) {
    return RawValuesInsertable({
      if (stepDefinitionId != null) 'step_definition_id': stepDefinitionId,
      if (destinationTripDefinitionId != null)
        'destination_trip_definition_id': destinationTripDefinitionId,
    });
  }

  FixedDestinationStepDefinitionsCompanion copyWith({
    Value<int>? stepDefinitionId,
    Value<int>? destinationTripDefinitionId,
  }) {
    return FixedDestinationStepDefinitionsCompanion(
      stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
      destinationTripDefinitionId:
          destinationTripDefinitionId ?? this.destinationTripDefinitionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepDefinitionId.present) {
      map['step_definition_id'] = Variable<int>(stepDefinitionId.value);
    }
    if (destinationTripDefinitionId.present) {
      map['destination_trip_definition_id'] = Variable<int>(
        destinationTripDefinitionId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixedDestinationStepDefinitionsCompanion(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write('destinationTripDefinitionId: $destinationTripDefinitionId')
          ..write(')'))
        .toString();
  }
}

class $FdaTestStepDefinitionsTable extends FdaTestStepDefinitions
    with TableInfo<$FdaTestStepDefinitionsTable, FdaTestStepDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FdaTestStepDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stepDefinitionIdMeta = const VerificationMeta(
    'stepDefinitionId',
  );
  @override
  late final GeneratedColumn<int> stepDefinitionId = GeneratedColumn<int>(
    'step_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES step_definitions (id)',
    ),
  );
  static const VerificationMeta _presentDestinationTripDefinitionIdMeta =
      const VerificationMeta('presentDestinationTripDefinitionId');
  @override
  late final GeneratedColumn<int> presentDestinationTripDefinitionId =
      GeneratedColumn<int>(
        'present_destination_trip_definition_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trip_definitions (id)',
        ),
      );
  static const VerificationMeta _absentDestinationTripDefinitionIdMeta =
      const VerificationMeta('absentDestinationTripDefinitionId');
  @override
  late final GeneratedColumn<int> absentDestinationTripDefinitionId =
      GeneratedColumn<int>(
        'absent_destination_trip_definition_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trip_definitions (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    stepDefinitionId,
    presentDestinationTripDefinitionId,
    absentDestinationTripDefinitionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fda_test_step_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FdaTestStepDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('step_definition_id')) {
      context.handle(
        _stepDefinitionIdMeta,
        stepDefinitionId.isAcceptableOrUnknown(
          data['step_definition_id']!,
          _stepDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('present_destination_trip_definition_id')) {
      context.handle(
        _presentDestinationTripDefinitionIdMeta,
        presentDestinationTripDefinitionId.isAcceptableOrUnknown(
          data['present_destination_trip_definition_id']!,
          _presentDestinationTripDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('absent_destination_trip_definition_id')) {
      context.handle(
        _absentDestinationTripDefinitionIdMeta,
        absentDestinationTripDefinitionId.isAcceptableOrUnknown(
          data['absent_destination_trip_definition_id']!,
          _absentDestinationTripDefinitionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepDefinitionId};
  @override
  FdaTestStepDefinitionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FdaTestStepDefinitionRow(
      stepDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_definition_id'],
      )!,
      presentDestinationTripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}present_destination_trip_definition_id'],
      ),
      absentDestinationTripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}absent_destination_trip_definition_id'],
      ),
    );
  }

  @override
  $FdaTestStepDefinitionsTable createAlias(String alias) {
    return $FdaTestStepDefinitionsTable(attachedDatabase, alias);
  }
}

class FdaTestStepDefinitionRow extends DataClass
    implements Insertable<FdaTestStepDefinitionRow> {
  final int stepDefinitionId;
  final int? presentDestinationTripDefinitionId;
  final int? absentDestinationTripDefinitionId;
  const FdaTestStepDefinitionRow({
    required this.stepDefinitionId,
    this.presentDestinationTripDefinitionId,
    this.absentDestinationTripDefinitionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['step_definition_id'] = Variable<int>(stepDefinitionId);
    if (!nullToAbsent || presentDestinationTripDefinitionId != null) {
      map['present_destination_trip_definition_id'] = Variable<int>(
        presentDestinationTripDefinitionId,
      );
    }
    if (!nullToAbsent || absentDestinationTripDefinitionId != null) {
      map['absent_destination_trip_definition_id'] = Variable<int>(
        absentDestinationTripDefinitionId,
      );
    }
    return map;
  }

  FdaTestStepDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return FdaTestStepDefinitionsCompanion(
      stepDefinitionId: Value(stepDefinitionId),
      presentDestinationTripDefinitionId:
          presentDestinationTripDefinitionId == null && nullToAbsent
          ? const Value.absent()
          : Value(presentDestinationTripDefinitionId),
      absentDestinationTripDefinitionId:
          absentDestinationTripDefinitionId == null && nullToAbsent
          ? const Value.absent()
          : Value(absentDestinationTripDefinitionId),
    );
  }

  factory FdaTestStepDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FdaTestStepDefinitionRow(
      stepDefinitionId: serializer.fromJson<int>(json['stepDefinitionId']),
      presentDestinationTripDefinitionId: serializer.fromJson<int?>(
        json['presentDestinationTripDefinitionId'],
      ),
      absentDestinationTripDefinitionId: serializer.fromJson<int?>(
        json['absentDestinationTripDefinitionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepDefinitionId': serializer.toJson<int>(stepDefinitionId),
      'presentDestinationTripDefinitionId': serializer.toJson<int?>(
        presentDestinationTripDefinitionId,
      ),
      'absentDestinationTripDefinitionId': serializer.toJson<int?>(
        absentDestinationTripDefinitionId,
      ),
    };
  }

  FdaTestStepDefinitionRow copyWith({
    int? stepDefinitionId,
    Value<int?> presentDestinationTripDefinitionId = const Value.absent(),
    Value<int?> absentDestinationTripDefinitionId = const Value.absent(),
  }) => FdaTestStepDefinitionRow(
    stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
    presentDestinationTripDefinitionId:
        presentDestinationTripDefinitionId.present
        ? presentDestinationTripDefinitionId.value
        : this.presentDestinationTripDefinitionId,
    absentDestinationTripDefinitionId: absentDestinationTripDefinitionId.present
        ? absentDestinationTripDefinitionId.value
        : this.absentDestinationTripDefinitionId,
  );
  FdaTestStepDefinitionRow copyWithCompanion(
    FdaTestStepDefinitionsCompanion data,
  ) {
    return FdaTestStepDefinitionRow(
      stepDefinitionId: data.stepDefinitionId.present
          ? data.stepDefinitionId.value
          : this.stepDefinitionId,
      presentDestinationTripDefinitionId:
          data.presentDestinationTripDefinitionId.present
          ? data.presentDestinationTripDefinitionId.value
          : this.presentDestinationTripDefinitionId,
      absentDestinationTripDefinitionId:
          data.absentDestinationTripDefinitionId.present
          ? data.absentDestinationTripDefinitionId.value
          : this.absentDestinationTripDefinitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FdaTestStepDefinitionRow(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write(
            'presentDestinationTripDefinitionId: $presentDestinationTripDefinitionId, ',
          )
          ..write(
            'absentDestinationTripDefinitionId: $absentDestinationTripDefinitionId',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    stepDefinitionId,
    presentDestinationTripDefinitionId,
    absentDestinationTripDefinitionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FdaTestStepDefinitionRow &&
          other.stepDefinitionId == this.stepDefinitionId &&
          other.presentDestinationTripDefinitionId ==
              this.presentDestinationTripDefinitionId &&
          other.absentDestinationTripDefinitionId ==
              this.absentDestinationTripDefinitionId);
}

class FdaTestStepDefinitionsCompanion
    extends UpdateCompanion<FdaTestStepDefinitionRow> {
  final Value<int> stepDefinitionId;
  final Value<int?> presentDestinationTripDefinitionId;
  final Value<int?> absentDestinationTripDefinitionId;
  const FdaTestStepDefinitionsCompanion({
    this.stepDefinitionId = const Value.absent(),
    this.presentDestinationTripDefinitionId = const Value.absent(),
    this.absentDestinationTripDefinitionId = const Value.absent(),
  });
  FdaTestStepDefinitionsCompanion.insert({
    this.stepDefinitionId = const Value.absent(),
    this.presentDestinationTripDefinitionId = const Value.absent(),
    this.absentDestinationTripDefinitionId = const Value.absent(),
  });
  static Insertable<FdaTestStepDefinitionRow> custom({
    Expression<int>? stepDefinitionId,
    Expression<int>? presentDestinationTripDefinitionId,
    Expression<int>? absentDestinationTripDefinitionId,
  }) {
    return RawValuesInsertable({
      if (stepDefinitionId != null) 'step_definition_id': stepDefinitionId,
      if (presentDestinationTripDefinitionId != null)
        'present_destination_trip_definition_id':
            presentDestinationTripDefinitionId,
      if (absentDestinationTripDefinitionId != null)
        'absent_destination_trip_definition_id':
            absentDestinationTripDefinitionId,
    });
  }

  FdaTestStepDefinitionsCompanion copyWith({
    Value<int>? stepDefinitionId,
    Value<int?>? presentDestinationTripDefinitionId,
    Value<int?>? absentDestinationTripDefinitionId,
  }) {
    return FdaTestStepDefinitionsCompanion(
      stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
      presentDestinationTripDefinitionId:
          presentDestinationTripDefinitionId ??
          this.presentDestinationTripDefinitionId,
      absentDestinationTripDefinitionId:
          absentDestinationTripDefinitionId ??
          this.absentDestinationTripDefinitionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepDefinitionId.present) {
      map['step_definition_id'] = Variable<int>(stepDefinitionId.value);
    }
    if (presentDestinationTripDefinitionId.present) {
      map['present_destination_trip_definition_id'] = Variable<int>(
        presentDestinationTripDefinitionId.value,
      );
    }
    if (absentDestinationTripDefinitionId.present) {
      map['absent_destination_trip_definition_id'] = Variable<int>(
        absentDestinationTripDefinitionId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FdaTestStepDefinitionsCompanion(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write(
            'presentDestinationTripDefinitionId: $presentDestinationTripDefinitionId, ',
          )
          ..write(
            'absentDestinationTripDefinitionId: $absentDestinationTripDefinitionId',
          )
          ..write(')'))
        .toString();
  }
}

class $ContactsSourceReadinessStepDefinitionsTable
    extends ContactsSourceReadinessStepDefinitions
    with
        TableInfo<
          $ContactsSourceReadinessStepDefinitionsTable,
          ContactsSourceReadinessStepDefinitionRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsSourceReadinessStepDefinitionsTable(
    this.attachedDatabase, [
    this._alias,
  ]);
  static const VerificationMeta _stepDefinitionIdMeta = const VerificationMeta(
    'stepDefinitionId',
  );
  @override
  late final GeneratedColumn<int> stepDefinitionId = GeneratedColumn<int>(
    'step_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES step_definitions (id)',
    ),
  );
  static const VerificationMeta _availableDestinationTripDefinitionIdMeta =
      const VerificationMeta('availableDestinationTripDefinitionId');
  @override
  late final GeneratedColumn<int> availableDestinationTripDefinitionId =
      GeneratedColumn<int>(
        'available_destination_trip_definition_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trip_definitions (id)',
        ),
      );
  static const VerificationMeta _unavailableDestinationTripDefinitionIdMeta =
      const VerificationMeta('unavailableDestinationTripDefinitionId');
  @override
  late final GeneratedColumn<int> unavailableDestinationTripDefinitionId =
      GeneratedColumn<int>(
        'unavailable_destination_trip_definition_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trip_definitions (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    stepDefinitionId,
    availableDestinationTripDefinitionId,
    unavailableDestinationTripDefinitionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts_source_readiness_step_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactsSourceReadinessStepDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('step_definition_id')) {
      context.handle(
        _stepDefinitionIdMeta,
        stepDefinitionId.isAcceptableOrUnknown(
          data['step_definition_id']!,
          _stepDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('available_destination_trip_definition_id')) {
      context.handle(
        _availableDestinationTripDefinitionIdMeta,
        availableDestinationTripDefinitionId.isAcceptableOrUnknown(
          data['available_destination_trip_definition_id']!,
          _availableDestinationTripDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('unavailable_destination_trip_definition_id')) {
      context.handle(
        _unavailableDestinationTripDefinitionIdMeta,
        unavailableDestinationTripDefinitionId.isAcceptableOrUnknown(
          data['unavailable_destination_trip_definition_id']!,
          _unavailableDestinationTripDefinitionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepDefinitionId};
  @override
  ContactsSourceReadinessStepDefinitionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactsSourceReadinessStepDefinitionRow(
      stepDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_definition_id'],
      )!,
      availableDestinationTripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_destination_trip_definition_id'],
      ),
      unavailableDestinationTripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unavailable_destination_trip_definition_id'],
      ),
    );
  }

  @override
  $ContactsSourceReadinessStepDefinitionsTable createAlias(String alias) {
    return $ContactsSourceReadinessStepDefinitionsTable(
      attachedDatabase,
      alias,
    );
  }
}

class ContactsSourceReadinessStepDefinitionRow extends DataClass
    implements Insertable<ContactsSourceReadinessStepDefinitionRow> {
  final int stepDefinitionId;
  final int? availableDestinationTripDefinitionId;
  final int? unavailableDestinationTripDefinitionId;
  const ContactsSourceReadinessStepDefinitionRow({
    required this.stepDefinitionId,
    this.availableDestinationTripDefinitionId,
    this.unavailableDestinationTripDefinitionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['step_definition_id'] = Variable<int>(stepDefinitionId);
    if (!nullToAbsent || availableDestinationTripDefinitionId != null) {
      map['available_destination_trip_definition_id'] = Variable<int>(
        availableDestinationTripDefinitionId,
      );
    }
    if (!nullToAbsent || unavailableDestinationTripDefinitionId != null) {
      map['unavailable_destination_trip_definition_id'] = Variable<int>(
        unavailableDestinationTripDefinitionId,
      );
    }
    return map;
  }

  ContactsSourceReadinessStepDefinitionsCompanion toCompanion(
    bool nullToAbsent,
  ) {
    return ContactsSourceReadinessStepDefinitionsCompanion(
      stepDefinitionId: Value(stepDefinitionId),
      availableDestinationTripDefinitionId:
          availableDestinationTripDefinitionId == null && nullToAbsent
          ? const Value.absent()
          : Value(availableDestinationTripDefinitionId),
      unavailableDestinationTripDefinitionId:
          unavailableDestinationTripDefinitionId == null && nullToAbsent
          ? const Value.absent()
          : Value(unavailableDestinationTripDefinitionId),
    );
  }

  factory ContactsSourceReadinessStepDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactsSourceReadinessStepDefinitionRow(
      stepDefinitionId: serializer.fromJson<int>(json['stepDefinitionId']),
      availableDestinationTripDefinitionId: serializer.fromJson<int?>(
        json['availableDestinationTripDefinitionId'],
      ),
      unavailableDestinationTripDefinitionId: serializer.fromJson<int?>(
        json['unavailableDestinationTripDefinitionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepDefinitionId': serializer.toJson<int>(stepDefinitionId),
      'availableDestinationTripDefinitionId': serializer.toJson<int?>(
        availableDestinationTripDefinitionId,
      ),
      'unavailableDestinationTripDefinitionId': serializer.toJson<int?>(
        unavailableDestinationTripDefinitionId,
      ),
    };
  }

  ContactsSourceReadinessStepDefinitionRow copyWith({
    int? stepDefinitionId,
    Value<int?> availableDestinationTripDefinitionId = const Value.absent(),
    Value<int?> unavailableDestinationTripDefinitionId = const Value.absent(),
  }) => ContactsSourceReadinessStepDefinitionRow(
    stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
    availableDestinationTripDefinitionId:
        availableDestinationTripDefinitionId.present
        ? availableDestinationTripDefinitionId.value
        : this.availableDestinationTripDefinitionId,
    unavailableDestinationTripDefinitionId:
        unavailableDestinationTripDefinitionId.present
        ? unavailableDestinationTripDefinitionId.value
        : this.unavailableDestinationTripDefinitionId,
  );
  ContactsSourceReadinessStepDefinitionRow copyWithCompanion(
    ContactsSourceReadinessStepDefinitionsCompanion data,
  ) {
    return ContactsSourceReadinessStepDefinitionRow(
      stepDefinitionId: data.stepDefinitionId.present
          ? data.stepDefinitionId.value
          : this.stepDefinitionId,
      availableDestinationTripDefinitionId:
          data.availableDestinationTripDefinitionId.present
          ? data.availableDestinationTripDefinitionId.value
          : this.availableDestinationTripDefinitionId,
      unavailableDestinationTripDefinitionId:
          data.unavailableDestinationTripDefinitionId.present
          ? data.unavailableDestinationTripDefinitionId.value
          : this.unavailableDestinationTripDefinitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactsSourceReadinessStepDefinitionRow(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write(
            'availableDestinationTripDefinitionId: $availableDestinationTripDefinitionId, ',
          )
          ..write(
            'unavailableDestinationTripDefinitionId: $unavailableDestinationTripDefinitionId',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    stepDefinitionId,
    availableDestinationTripDefinitionId,
    unavailableDestinationTripDefinitionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactsSourceReadinessStepDefinitionRow &&
          other.stepDefinitionId == this.stepDefinitionId &&
          other.availableDestinationTripDefinitionId ==
              this.availableDestinationTripDefinitionId &&
          other.unavailableDestinationTripDefinitionId ==
              this.unavailableDestinationTripDefinitionId);
}

class ContactsSourceReadinessStepDefinitionsCompanion
    extends UpdateCompanion<ContactsSourceReadinessStepDefinitionRow> {
  final Value<int> stepDefinitionId;
  final Value<int?> availableDestinationTripDefinitionId;
  final Value<int?> unavailableDestinationTripDefinitionId;
  const ContactsSourceReadinessStepDefinitionsCompanion({
    this.stepDefinitionId = const Value.absent(),
    this.availableDestinationTripDefinitionId = const Value.absent(),
    this.unavailableDestinationTripDefinitionId = const Value.absent(),
  });
  ContactsSourceReadinessStepDefinitionsCompanion.insert({
    this.stepDefinitionId = const Value.absent(),
    this.availableDestinationTripDefinitionId = const Value.absent(),
    this.unavailableDestinationTripDefinitionId = const Value.absent(),
  });
  static Insertable<ContactsSourceReadinessStepDefinitionRow> custom({
    Expression<int>? stepDefinitionId,
    Expression<int>? availableDestinationTripDefinitionId,
    Expression<int>? unavailableDestinationTripDefinitionId,
  }) {
    return RawValuesInsertable({
      if (stepDefinitionId != null) 'step_definition_id': stepDefinitionId,
      if (availableDestinationTripDefinitionId != null)
        'available_destination_trip_definition_id':
            availableDestinationTripDefinitionId,
      if (unavailableDestinationTripDefinitionId != null)
        'unavailable_destination_trip_definition_id':
            unavailableDestinationTripDefinitionId,
    });
  }

  ContactsSourceReadinessStepDefinitionsCompanion copyWith({
    Value<int>? stepDefinitionId,
    Value<int?>? availableDestinationTripDefinitionId,
    Value<int?>? unavailableDestinationTripDefinitionId,
  }) {
    return ContactsSourceReadinessStepDefinitionsCompanion(
      stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
      availableDestinationTripDefinitionId:
          availableDestinationTripDefinitionId ??
          this.availableDestinationTripDefinitionId,
      unavailableDestinationTripDefinitionId:
          unavailableDestinationTripDefinitionId ??
          this.unavailableDestinationTripDefinitionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepDefinitionId.present) {
      map['step_definition_id'] = Variable<int>(stepDefinitionId.value);
    }
    if (availableDestinationTripDefinitionId.present) {
      map['available_destination_trip_definition_id'] = Variable<int>(
        availableDestinationTripDefinitionId.value,
      );
    }
    if (unavailableDestinationTripDefinitionId.present) {
      map['unavailable_destination_trip_definition_id'] = Variable<int>(
        unavailableDestinationTripDefinitionId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsSourceReadinessStepDefinitionsCompanion(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write(
            'availableDestinationTripDefinitionId: $availableDestinationTripDefinitionId, ',
          )
          ..write(
            'unavailableDestinationTripDefinitionId: $unavailableDestinationTripDefinitionId',
          )
          ..write(')'))
        .toString();
  }
}

class $OpenFdaSettingsStepDefinitionsTable
    extends OpenFdaSettingsStepDefinitions
    with
        TableInfo<
          $OpenFdaSettingsStepDefinitionsTable,
          OpenFdaSettingsStepDefinitionRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpenFdaSettingsStepDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stepDefinitionIdMeta = const VerificationMeta(
    'stepDefinitionId',
  );
  @override
  late final GeneratedColumn<int> stepDefinitionId = GeneratedColumn<int>(
    'step_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES step_definitions (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [stepDefinitionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'open_fda_settings_step_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpenFdaSettingsStepDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('step_definition_id')) {
      context.handle(
        _stepDefinitionIdMeta,
        stepDefinitionId.isAcceptableOrUnknown(
          data['step_definition_id']!,
          _stepDefinitionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepDefinitionId};
  @override
  OpenFdaSettingsStepDefinitionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpenFdaSettingsStepDefinitionRow(
      stepDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_definition_id'],
      )!,
    );
  }

  @override
  $OpenFdaSettingsStepDefinitionsTable createAlias(String alias) {
    return $OpenFdaSettingsStepDefinitionsTable(attachedDatabase, alias);
  }
}

class OpenFdaSettingsStepDefinitionRow extends DataClass
    implements Insertable<OpenFdaSettingsStepDefinitionRow> {
  final int stepDefinitionId;
  const OpenFdaSettingsStepDefinitionRow({required this.stepDefinitionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['step_definition_id'] = Variable<int>(stepDefinitionId);
    return map;
  }

  OpenFdaSettingsStepDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return OpenFdaSettingsStepDefinitionsCompanion(
      stepDefinitionId: Value(stepDefinitionId),
    );
  }

  factory OpenFdaSettingsStepDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpenFdaSettingsStepDefinitionRow(
      stepDefinitionId: serializer.fromJson<int>(json['stepDefinitionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepDefinitionId': serializer.toJson<int>(stepDefinitionId),
    };
  }

  OpenFdaSettingsStepDefinitionRow copyWith({int? stepDefinitionId}) =>
      OpenFdaSettingsStepDefinitionRow(
        stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
      );
  OpenFdaSettingsStepDefinitionRow copyWithCompanion(
    OpenFdaSettingsStepDefinitionsCompanion data,
  ) {
    return OpenFdaSettingsStepDefinitionRow(
      stepDefinitionId: data.stepDefinitionId.present
          ? data.stepDefinitionId.value
          : this.stepDefinitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpenFdaSettingsStepDefinitionRow(')
          ..write('stepDefinitionId: $stepDefinitionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => stepDefinitionId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpenFdaSettingsStepDefinitionRow &&
          other.stepDefinitionId == this.stepDefinitionId);
}

class OpenFdaSettingsStepDefinitionsCompanion
    extends UpdateCompanion<OpenFdaSettingsStepDefinitionRow> {
  final Value<int> stepDefinitionId;
  const OpenFdaSettingsStepDefinitionsCompanion({
    this.stepDefinitionId = const Value.absent(),
  });
  OpenFdaSettingsStepDefinitionsCompanion.insert({
    this.stepDefinitionId = const Value.absent(),
  });
  static Insertable<OpenFdaSettingsStepDefinitionRow> custom({
    Expression<int>? stepDefinitionId,
  }) {
    return RawValuesInsertable({
      if (stepDefinitionId != null) 'step_definition_id': stepDefinitionId,
    });
  }

  OpenFdaSettingsStepDefinitionsCompanion copyWith({
    Value<int>? stepDefinitionId,
  }) {
    return OpenFdaSettingsStepDefinitionsCompanion(
      stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepDefinitionId.present) {
      map['step_definition_id'] = Variable<int>(stepDefinitionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpenFdaSettingsStepDefinitionsCompanion(')
          ..write('stepDefinitionId: $stepDefinitionId')
          ..write(')'))
        .toString();
  }
}

class $TestAgentDefinitionsTable extends TestAgentDefinitions
    with TableInfo<$TestAgentDefinitionsTable, TestAgentDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestAgentDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_agent_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestAgentDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestAgentDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestAgentDefinitionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $TestAgentDefinitionsTable createAlias(String alias) {
    return $TestAgentDefinitionsTable(attachedDatabase, alias);
  }
}

class TestAgentDefinitionRow extends DataClass
    implements Insertable<TestAgentDefinitionRow> {
  final String id;
  const TestAgentDefinitionRow({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    return map;
  }

  TestAgentDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return TestAgentDefinitionsCompanion(id: Value(id));
  }

  factory TestAgentDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestAgentDefinitionRow(id: serializer.fromJson<String>(json['id']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<String>(id)};
  }

  TestAgentDefinitionRow copyWith({String? id}) =>
      TestAgentDefinitionRow(id: id ?? this.id);
  TestAgentDefinitionRow copyWithCompanion(TestAgentDefinitionsCompanion data) {
    return TestAgentDefinitionRow(
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestAgentDefinitionRow(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestAgentDefinitionRow && other.id == this.id);
}

class TestAgentDefinitionsCompanion
    extends UpdateCompanion<TestAgentDefinitionRow> {
  final Value<String> id;
  final Value<int> rowid;
  const TestAgentDefinitionsCompanion({
    this.id = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TestAgentDefinitionsCompanion.insert({
    required String id,
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<TestAgentDefinitionRow> custom({
    Expression<String>? id,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TestAgentDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<int>? rowid,
  }) {
    return TestAgentDefinitionsCompanion(
      id: id ?? this.id,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestAgentDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TestStepDefinitionsTable extends TestStepDefinitions
    with TableInfo<$TestStepDefinitionsTable, TestStepDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestStepDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stepDefinitionIdMeta = const VerificationMeta(
    'stepDefinitionId',
  );
  @override
  late final GeneratedColumn<int> stepDefinitionId = GeneratedColumn<int>(
    'step_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES step_definitions (id)',
    ),
  );
  static const VerificationMeta _testAgentIdMeta = const VerificationMeta(
    'testAgentId',
  );
  @override
  late final GeneratedColumn<String> testAgentId = GeneratedColumn<String>(
    'test_agent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES test_agent_definitions (id)',
    ),
  );
  static const VerificationMeta _trueDestinationTripDefinitionIdMeta =
      const VerificationMeta('trueDestinationTripDefinitionId');
  @override
  late final GeneratedColumn<int> trueDestinationTripDefinitionId =
      GeneratedColumn<int>(
        'true_destination_trip_definition_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trip_definitions (id)',
        ),
      );
  static const VerificationMeta _falseDestinationTripDefinitionIdMeta =
      const VerificationMeta('falseDestinationTripDefinitionId');
  @override
  late final GeneratedColumn<int> falseDestinationTripDefinitionId =
      GeneratedColumn<int>(
        'false_destination_trip_definition_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trip_definitions (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    stepDefinitionId,
    testAgentId,
    trueDestinationTripDefinitionId,
    falseDestinationTripDefinitionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_step_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestStepDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('step_definition_id')) {
      context.handle(
        _stepDefinitionIdMeta,
        stepDefinitionId.isAcceptableOrUnknown(
          data['step_definition_id']!,
          _stepDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('test_agent_id')) {
      context.handle(
        _testAgentIdMeta,
        testAgentId.isAcceptableOrUnknown(
          data['test_agent_id']!,
          _testAgentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_testAgentIdMeta);
    }
    if (data.containsKey('true_destination_trip_definition_id')) {
      context.handle(
        _trueDestinationTripDefinitionIdMeta,
        trueDestinationTripDefinitionId.isAcceptableOrUnknown(
          data['true_destination_trip_definition_id']!,
          _trueDestinationTripDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('false_destination_trip_definition_id')) {
      context.handle(
        _falseDestinationTripDefinitionIdMeta,
        falseDestinationTripDefinitionId.isAcceptableOrUnknown(
          data['false_destination_trip_definition_id']!,
          _falseDestinationTripDefinitionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepDefinitionId};
  @override
  TestStepDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestStepDefinitionRow(
      stepDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_definition_id'],
      )!,
      testAgentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_agent_id'],
      )!,
      trueDestinationTripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}true_destination_trip_definition_id'],
      ),
      falseDestinationTripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}false_destination_trip_definition_id'],
      ),
    );
  }

  @override
  $TestStepDefinitionsTable createAlias(String alias) {
    return $TestStepDefinitionsTable(attachedDatabase, alias);
  }
}

class TestStepDefinitionRow extends DataClass
    implements Insertable<TestStepDefinitionRow> {
  final int stepDefinitionId;
  final String testAgentId;
  final int? trueDestinationTripDefinitionId;
  final int? falseDestinationTripDefinitionId;
  const TestStepDefinitionRow({
    required this.stepDefinitionId,
    required this.testAgentId,
    this.trueDestinationTripDefinitionId,
    this.falseDestinationTripDefinitionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['step_definition_id'] = Variable<int>(stepDefinitionId);
    map['test_agent_id'] = Variable<String>(testAgentId);
    if (!nullToAbsent || trueDestinationTripDefinitionId != null) {
      map['true_destination_trip_definition_id'] = Variable<int>(
        trueDestinationTripDefinitionId,
      );
    }
    if (!nullToAbsent || falseDestinationTripDefinitionId != null) {
      map['false_destination_trip_definition_id'] = Variable<int>(
        falseDestinationTripDefinitionId,
      );
    }
    return map;
  }

  TestStepDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return TestStepDefinitionsCompanion(
      stepDefinitionId: Value(stepDefinitionId),
      testAgentId: Value(testAgentId),
      trueDestinationTripDefinitionId:
          trueDestinationTripDefinitionId == null && nullToAbsent
          ? const Value.absent()
          : Value(trueDestinationTripDefinitionId),
      falseDestinationTripDefinitionId:
          falseDestinationTripDefinitionId == null && nullToAbsent
          ? const Value.absent()
          : Value(falseDestinationTripDefinitionId),
    );
  }

  factory TestStepDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestStepDefinitionRow(
      stepDefinitionId: serializer.fromJson<int>(json['stepDefinitionId']),
      testAgentId: serializer.fromJson<String>(json['testAgentId']),
      trueDestinationTripDefinitionId: serializer.fromJson<int?>(
        json['trueDestinationTripDefinitionId'],
      ),
      falseDestinationTripDefinitionId: serializer.fromJson<int?>(
        json['falseDestinationTripDefinitionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepDefinitionId': serializer.toJson<int>(stepDefinitionId),
      'testAgentId': serializer.toJson<String>(testAgentId),
      'trueDestinationTripDefinitionId': serializer.toJson<int?>(
        trueDestinationTripDefinitionId,
      ),
      'falseDestinationTripDefinitionId': serializer.toJson<int?>(
        falseDestinationTripDefinitionId,
      ),
    };
  }

  TestStepDefinitionRow copyWith({
    int? stepDefinitionId,
    String? testAgentId,
    Value<int?> trueDestinationTripDefinitionId = const Value.absent(),
    Value<int?> falseDestinationTripDefinitionId = const Value.absent(),
  }) => TestStepDefinitionRow(
    stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
    testAgentId: testAgentId ?? this.testAgentId,
    trueDestinationTripDefinitionId: trueDestinationTripDefinitionId.present
        ? trueDestinationTripDefinitionId.value
        : this.trueDestinationTripDefinitionId,
    falseDestinationTripDefinitionId: falseDestinationTripDefinitionId.present
        ? falseDestinationTripDefinitionId.value
        : this.falseDestinationTripDefinitionId,
  );
  TestStepDefinitionRow copyWithCompanion(TestStepDefinitionsCompanion data) {
    return TestStepDefinitionRow(
      stepDefinitionId: data.stepDefinitionId.present
          ? data.stepDefinitionId.value
          : this.stepDefinitionId,
      testAgentId: data.testAgentId.present
          ? data.testAgentId.value
          : this.testAgentId,
      trueDestinationTripDefinitionId:
          data.trueDestinationTripDefinitionId.present
          ? data.trueDestinationTripDefinitionId.value
          : this.trueDestinationTripDefinitionId,
      falseDestinationTripDefinitionId:
          data.falseDestinationTripDefinitionId.present
          ? data.falseDestinationTripDefinitionId.value
          : this.falseDestinationTripDefinitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestStepDefinitionRow(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write('testAgentId: $testAgentId, ')
          ..write(
            'trueDestinationTripDefinitionId: $trueDestinationTripDefinitionId, ',
          )
          ..write(
            'falseDestinationTripDefinitionId: $falseDestinationTripDefinitionId',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    stepDefinitionId,
    testAgentId,
    trueDestinationTripDefinitionId,
    falseDestinationTripDefinitionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestStepDefinitionRow &&
          other.stepDefinitionId == this.stepDefinitionId &&
          other.testAgentId == this.testAgentId &&
          other.trueDestinationTripDefinitionId ==
              this.trueDestinationTripDefinitionId &&
          other.falseDestinationTripDefinitionId ==
              this.falseDestinationTripDefinitionId);
}

class TestStepDefinitionsCompanion
    extends UpdateCompanion<TestStepDefinitionRow> {
  final Value<int> stepDefinitionId;
  final Value<String> testAgentId;
  final Value<int?> trueDestinationTripDefinitionId;
  final Value<int?> falseDestinationTripDefinitionId;
  const TestStepDefinitionsCompanion({
    this.stepDefinitionId = const Value.absent(),
    this.testAgentId = const Value.absent(),
    this.trueDestinationTripDefinitionId = const Value.absent(),
    this.falseDestinationTripDefinitionId = const Value.absent(),
  });
  TestStepDefinitionsCompanion.insert({
    this.stepDefinitionId = const Value.absent(),
    required String testAgentId,
    this.trueDestinationTripDefinitionId = const Value.absent(),
    this.falseDestinationTripDefinitionId = const Value.absent(),
  }) : testAgentId = Value(testAgentId);
  static Insertable<TestStepDefinitionRow> custom({
    Expression<int>? stepDefinitionId,
    Expression<String>? testAgentId,
    Expression<int>? trueDestinationTripDefinitionId,
    Expression<int>? falseDestinationTripDefinitionId,
  }) {
    return RawValuesInsertable({
      if (stepDefinitionId != null) 'step_definition_id': stepDefinitionId,
      if (testAgentId != null) 'test_agent_id': testAgentId,
      if (trueDestinationTripDefinitionId != null)
        'true_destination_trip_definition_id': trueDestinationTripDefinitionId,
      if (falseDestinationTripDefinitionId != null)
        'false_destination_trip_definition_id':
            falseDestinationTripDefinitionId,
    });
  }

  TestStepDefinitionsCompanion copyWith({
    Value<int>? stepDefinitionId,
    Value<String>? testAgentId,
    Value<int?>? trueDestinationTripDefinitionId,
    Value<int?>? falseDestinationTripDefinitionId,
  }) {
    return TestStepDefinitionsCompanion(
      stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
      testAgentId: testAgentId ?? this.testAgentId,
      trueDestinationTripDefinitionId:
          trueDestinationTripDefinitionId ??
          this.trueDestinationTripDefinitionId,
      falseDestinationTripDefinitionId:
          falseDestinationTripDefinitionId ??
          this.falseDestinationTripDefinitionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepDefinitionId.present) {
      map['step_definition_id'] = Variable<int>(stepDefinitionId.value);
    }
    if (testAgentId.present) {
      map['test_agent_id'] = Variable<String>(testAgentId.value);
    }
    if (trueDestinationTripDefinitionId.present) {
      map['true_destination_trip_definition_id'] = Variable<int>(
        trueDestinationTripDefinitionId.value,
      );
    }
    if (falseDestinationTripDefinitionId.present) {
      map['false_destination_trip_definition_id'] = Variable<int>(
        falseDestinationTripDefinitionId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestStepDefinitionsCompanion(')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write('testAgentId: $testAgentId, ')
          ..write(
            'trueDestinationTripDefinitionId: $trueDestinationTripDefinitionId, ',
          )
          ..write(
            'falseDestinationTripDefinitionId: $falseDestinationTripDefinitionId',
          )
          ..write(')'))
        .toString();
  }
}

class $ChoiceStepDefinitionsTable extends ChoiceStepDefinitions
    with TableInfo<$ChoiceStepDefinitionsTable, ChoiceStepDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChoiceStepDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stepDefinitionIdMeta = const VerificationMeta(
    'stepDefinitionId',
  );
  @override
  late final GeneratedColumn<int> stepDefinitionId = GeneratedColumn<int>(
    'step_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES step_definitions (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [stepDefinitionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'choice_step_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChoiceStepDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('step_definition_id')) {
      context.handle(
        _stepDefinitionIdMeta,
        stepDefinitionId.isAcceptableOrUnknown(
          data['step_definition_id']!,
          _stepDefinitionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepDefinitionId};
  @override
  ChoiceStepDefinitionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChoiceStepDefinitionRow(
      stepDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_definition_id'],
      )!,
    );
  }

  @override
  $ChoiceStepDefinitionsTable createAlias(String alias) {
    return $ChoiceStepDefinitionsTable(attachedDatabase, alias);
  }
}

class ChoiceStepDefinitionRow extends DataClass
    implements Insertable<ChoiceStepDefinitionRow> {
  final int stepDefinitionId;
  const ChoiceStepDefinitionRow({required this.stepDefinitionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['step_definition_id'] = Variable<int>(stepDefinitionId);
    return map;
  }

  ChoiceStepDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return ChoiceStepDefinitionsCompanion(
      stepDefinitionId: Value(stepDefinitionId),
    );
  }

  factory ChoiceStepDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChoiceStepDefinitionRow(
      stepDefinitionId: serializer.fromJson<int>(json['stepDefinitionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepDefinitionId': serializer.toJson<int>(stepDefinitionId),
    };
  }

  ChoiceStepDefinitionRow copyWith({int? stepDefinitionId}) =>
      ChoiceStepDefinitionRow(
        stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
      );
  ChoiceStepDefinitionRow copyWithCompanion(
    ChoiceStepDefinitionsCompanion data,
  ) {
    return ChoiceStepDefinitionRow(
      stepDefinitionId: data.stepDefinitionId.present
          ? data.stepDefinitionId.value
          : this.stepDefinitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChoiceStepDefinitionRow(')
          ..write('stepDefinitionId: $stepDefinitionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => stepDefinitionId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChoiceStepDefinitionRow &&
          other.stepDefinitionId == this.stepDefinitionId);
}

class ChoiceStepDefinitionsCompanion
    extends UpdateCompanion<ChoiceStepDefinitionRow> {
  final Value<int> stepDefinitionId;
  const ChoiceStepDefinitionsCompanion({
    this.stepDefinitionId = const Value.absent(),
  });
  ChoiceStepDefinitionsCompanion.insert({
    this.stepDefinitionId = const Value.absent(),
  });
  static Insertable<ChoiceStepDefinitionRow> custom({
    Expression<int>? stepDefinitionId,
  }) {
    return RawValuesInsertable({
      if (stepDefinitionId != null) 'step_definition_id': stepDefinitionId,
    });
  }

  ChoiceStepDefinitionsCompanion copyWith({Value<int>? stepDefinitionId}) {
    return ChoiceStepDefinitionsCompanion(
      stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepDefinitionId.present) {
      map['step_definition_id'] = Variable<int>(stepDefinitionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChoiceStepDefinitionsCompanion(')
          ..write('stepDefinitionId: $stepDefinitionId')
          ..write(')'))
        .toString();
  }
}

class $ChoiceStepOptionsTable extends ChoiceStepOptions
    with TableInfo<$ChoiceStepOptionsTable, ChoiceStepOptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChoiceStepOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    check: () => ComparableExpr(position).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepDefinitionIdMeta = const VerificationMeta(
    'stepDefinitionId',
  );
  @override
  late final GeneratedColumn<int> stepDefinitionId = GeneratedColumn<int>(
    'step_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES choice_step_definitions (step_definition_id)',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationTripDefinitionIdMeta =
      const VerificationMeta('destinationTripDefinitionId');
  @override
  late final GeneratedColumn<int> destinationTripDefinitionId =
      GeneratedColumn<int>(
        'destination_trip_definition_id',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trip_definitions (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    position,
    stepDefinitionId,
    value,
    label,
    destinationTripDefinitionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'choice_step_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChoiceStepOptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('step_definition_id')) {
      context.handle(
        _stepDefinitionIdMeta,
        stepDefinitionId.isAcceptableOrUnknown(
          data['step_definition_id']!,
          _stepDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stepDefinitionIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('destination_trip_definition_id')) {
      context.handle(
        _destinationTripDefinitionIdMeta,
        destinationTripDefinitionId.isAcceptableOrUnknown(
          data['destination_trip_definition_id']!,
          _destinationTripDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationTripDefinitionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepDefinitionId, value};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {stepDefinitionId, position},
  ];
  @override
  ChoiceStepOptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChoiceStepOptionRow(
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      stepDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_definition_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      destinationTripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}destination_trip_definition_id'],
      )!,
    );
  }

  @override
  $ChoiceStepOptionsTable createAlias(String alias) {
    return $ChoiceStepOptionsTable(attachedDatabase, alias);
  }
}

class ChoiceStepOptionRow extends DataClass
    implements Insertable<ChoiceStepOptionRow> {
  final int position;
  final int stepDefinitionId;
  final String value;
  final String label;
  final int destinationTripDefinitionId;
  const ChoiceStepOptionRow({
    required this.position,
    required this.stepDefinitionId,
    required this.value,
    required this.label,
    required this.destinationTripDefinitionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['position'] = Variable<int>(position);
    map['step_definition_id'] = Variable<int>(stepDefinitionId);
    map['value'] = Variable<String>(value);
    map['label'] = Variable<String>(label);
    map['destination_trip_definition_id'] = Variable<int>(
      destinationTripDefinitionId,
    );
    return map;
  }

  ChoiceStepOptionsCompanion toCompanion(bool nullToAbsent) {
    return ChoiceStepOptionsCompanion(
      position: Value(position),
      stepDefinitionId: Value(stepDefinitionId),
      value: Value(value),
      label: Value(label),
      destinationTripDefinitionId: Value(destinationTripDefinitionId),
    );
  }

  factory ChoiceStepOptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChoiceStepOptionRow(
      position: serializer.fromJson<int>(json['position']),
      stepDefinitionId: serializer.fromJson<int>(json['stepDefinitionId']),
      value: serializer.fromJson<String>(json['value']),
      label: serializer.fromJson<String>(json['label']),
      destinationTripDefinitionId: serializer.fromJson<int>(
        json['destinationTripDefinitionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'position': serializer.toJson<int>(position),
      'stepDefinitionId': serializer.toJson<int>(stepDefinitionId),
      'value': serializer.toJson<String>(value),
      'label': serializer.toJson<String>(label),
      'destinationTripDefinitionId': serializer.toJson<int>(
        destinationTripDefinitionId,
      ),
    };
  }

  ChoiceStepOptionRow copyWith({
    int? position,
    int? stepDefinitionId,
    String? value,
    String? label,
    int? destinationTripDefinitionId,
  }) => ChoiceStepOptionRow(
    position: position ?? this.position,
    stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
    value: value ?? this.value,
    label: label ?? this.label,
    destinationTripDefinitionId:
        destinationTripDefinitionId ?? this.destinationTripDefinitionId,
  );
  ChoiceStepOptionRow copyWithCompanion(ChoiceStepOptionsCompanion data) {
    return ChoiceStepOptionRow(
      position: data.position.present ? data.position.value : this.position,
      stepDefinitionId: data.stepDefinitionId.present
          ? data.stepDefinitionId.value
          : this.stepDefinitionId,
      value: data.value.present ? data.value.value : this.value,
      label: data.label.present ? data.label.value : this.label,
      destinationTripDefinitionId: data.destinationTripDefinitionId.present
          ? data.destinationTripDefinitionId.value
          : this.destinationTripDefinitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChoiceStepOptionRow(')
          ..write('position: $position, ')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write('value: $value, ')
          ..write('label: $label, ')
          ..write('destinationTripDefinitionId: $destinationTripDefinitionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    position,
    stepDefinitionId,
    value,
    label,
    destinationTripDefinitionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChoiceStepOptionRow &&
          other.position == this.position &&
          other.stepDefinitionId == this.stepDefinitionId &&
          other.value == this.value &&
          other.label == this.label &&
          other.destinationTripDefinitionId ==
              this.destinationTripDefinitionId);
}

class ChoiceStepOptionsCompanion extends UpdateCompanion<ChoiceStepOptionRow> {
  final Value<int> position;
  final Value<int> stepDefinitionId;
  final Value<String> value;
  final Value<String> label;
  final Value<int> destinationTripDefinitionId;
  final Value<int> rowid;
  const ChoiceStepOptionsCompanion({
    this.position = const Value.absent(),
    this.stepDefinitionId = const Value.absent(),
    this.value = const Value.absent(),
    this.label = const Value.absent(),
    this.destinationTripDefinitionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChoiceStepOptionsCompanion.insert({
    required int position,
    required int stepDefinitionId,
    required String value,
    required String label,
    required int destinationTripDefinitionId,
    this.rowid = const Value.absent(),
  }) : position = Value(position),
       stepDefinitionId = Value(stepDefinitionId),
       value = Value(value),
       label = Value(label),
       destinationTripDefinitionId = Value(destinationTripDefinitionId);
  static Insertable<ChoiceStepOptionRow> custom({
    Expression<int>? position,
    Expression<int>? stepDefinitionId,
    Expression<String>? value,
    Expression<String>? label,
    Expression<int>? destinationTripDefinitionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (position != null) 'position': position,
      if (stepDefinitionId != null) 'step_definition_id': stepDefinitionId,
      if (value != null) 'value': value,
      if (label != null) 'label': label,
      if (destinationTripDefinitionId != null)
        'destination_trip_definition_id': destinationTripDefinitionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChoiceStepOptionsCompanion copyWith({
    Value<int>? position,
    Value<int>? stepDefinitionId,
    Value<String>? value,
    Value<String>? label,
    Value<int>? destinationTripDefinitionId,
    Value<int>? rowid,
  }) {
    return ChoiceStepOptionsCompanion(
      position: position ?? this.position,
      stepDefinitionId: stepDefinitionId ?? this.stepDefinitionId,
      value: value ?? this.value,
      label: label ?? this.label,
      destinationTripDefinitionId:
          destinationTripDefinitionId ?? this.destinationTripDefinitionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (stepDefinitionId.present) {
      map['step_definition_id'] = Variable<int>(stepDefinitionId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (destinationTripDefinitionId.present) {
      map['destination_trip_definition_id'] = Variable<int>(
        destinationTripDefinitionId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChoiceStepOptionsCompanion(')
          ..write('position: $position, ')
          ..write('stepDefinitionId: $stepDefinitionId, ')
          ..write('value: $value, ')
          ..write('label: $label, ')
          ..write('destinationTripDefinitionId: $destinationTripDefinitionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleRunsTable extends ScheduleRuns
    with TableInfo<$ScheduleRunsTable, ScheduleRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scheduleDefinitionIdMeta =
      const VerificationMeta('scheduleDefinitionId');
  @override
  late final GeneratedColumn<int> scheduleDefinitionId = GeneratedColumn<int>(
    'schedule_definition_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedule_definitions (id)',
    ),
  );
  static const VerificationMeta _currentTripOccurrenceIdMeta =
      const VerificationMeta('currentTripOccurrenceId');
  @override
  late final GeneratedColumn<int> currentTripOccurrenceId =
      GeneratedColumn<int>(
        'current_trip_occurrence_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheduleDefinitionId,
    currentTripOccurrenceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_definition_id')) {
      context.handle(
        _scheduleDefinitionIdMeta,
        scheduleDefinitionId.isAcceptableOrUnknown(
          data['schedule_definition_id']!,
          _scheduleDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleDefinitionIdMeta);
    }
    if (data.containsKey('current_trip_occurrence_id')) {
      context.handle(
        _currentTripOccurrenceIdMeta,
        currentTripOccurrenceId.isAcceptableOrUnknown(
          data['current_trip_occurrence_id']!,
          _currentTripOccurrenceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleRunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scheduleDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_definition_id'],
      )!,
      currentTripOccurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_trip_occurrence_id'],
      ),
    );
  }

  @override
  $ScheduleRunsTable createAlias(String alias) {
    return $ScheduleRunsTable(attachedDatabase, alias);
  }
}

class ScheduleRunRow extends DataClass implements Insertable<ScheduleRunRow> {
  final int id;
  final int scheduleDefinitionId;
  final int? currentTripOccurrenceId;
  const ScheduleRunRow({
    required this.id,
    required this.scheduleDefinitionId,
    this.currentTripOccurrenceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schedule_definition_id'] = Variable<int>(scheduleDefinitionId);
    if (!nullToAbsent || currentTripOccurrenceId != null) {
      map['current_trip_occurrence_id'] = Variable<int>(
        currentTripOccurrenceId,
      );
    }
    return map;
  }

  ScheduleRunsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleRunsCompanion(
      id: Value(id),
      scheduleDefinitionId: Value(scheduleDefinitionId),
      currentTripOccurrenceId: currentTripOccurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTripOccurrenceId),
    );
  }

  factory ScheduleRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleRunRow(
      id: serializer.fromJson<int>(json['id']),
      scheduleDefinitionId: serializer.fromJson<int>(
        json['scheduleDefinitionId'],
      ),
      currentTripOccurrenceId: serializer.fromJson<int?>(
        json['currentTripOccurrenceId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduleDefinitionId': serializer.toJson<int>(scheduleDefinitionId),
      'currentTripOccurrenceId': serializer.toJson<int?>(
        currentTripOccurrenceId,
      ),
    };
  }

  ScheduleRunRow copyWith({
    int? id,
    int? scheduleDefinitionId,
    Value<int?> currentTripOccurrenceId = const Value.absent(),
  }) => ScheduleRunRow(
    id: id ?? this.id,
    scheduleDefinitionId: scheduleDefinitionId ?? this.scheduleDefinitionId,
    currentTripOccurrenceId: currentTripOccurrenceId.present
        ? currentTripOccurrenceId.value
        : this.currentTripOccurrenceId,
  );
  ScheduleRunRow copyWithCompanion(ScheduleRunsCompanion data) {
    return ScheduleRunRow(
      id: data.id.present ? data.id.value : this.id,
      scheduleDefinitionId: data.scheduleDefinitionId.present
          ? data.scheduleDefinitionId.value
          : this.scheduleDefinitionId,
      currentTripOccurrenceId: data.currentTripOccurrenceId.present
          ? data.currentTripOccurrenceId.value
          : this.currentTripOccurrenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRunRow(')
          ..write('id: $id, ')
          ..write('scheduleDefinitionId: $scheduleDefinitionId, ')
          ..write('currentTripOccurrenceId: $currentTripOccurrenceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, scheduleDefinitionId, currentTripOccurrenceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleRunRow &&
          other.id == this.id &&
          other.scheduleDefinitionId == this.scheduleDefinitionId &&
          other.currentTripOccurrenceId == this.currentTripOccurrenceId);
}

class ScheduleRunsCompanion extends UpdateCompanion<ScheduleRunRow> {
  final Value<int> id;
  final Value<int> scheduleDefinitionId;
  final Value<int?> currentTripOccurrenceId;
  const ScheduleRunsCompanion({
    this.id = const Value.absent(),
    this.scheduleDefinitionId = const Value.absent(),
    this.currentTripOccurrenceId = const Value.absent(),
  });
  ScheduleRunsCompanion.insert({
    this.id = const Value.absent(),
    required int scheduleDefinitionId,
    this.currentTripOccurrenceId = const Value.absent(),
  }) : scheduleDefinitionId = Value(scheduleDefinitionId);
  static Insertable<ScheduleRunRow> custom({
    Expression<int>? id,
    Expression<int>? scheduleDefinitionId,
    Expression<int>? currentTripOccurrenceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleDefinitionId != null)
        'schedule_definition_id': scheduleDefinitionId,
      if (currentTripOccurrenceId != null)
        'current_trip_occurrence_id': currentTripOccurrenceId,
    });
  }

  ScheduleRunsCompanion copyWith({
    Value<int>? id,
    Value<int>? scheduleDefinitionId,
    Value<int?>? currentTripOccurrenceId,
  }) {
    return ScheduleRunsCompanion(
      id: id ?? this.id,
      scheduleDefinitionId: scheduleDefinitionId ?? this.scheduleDefinitionId,
      currentTripOccurrenceId:
          currentTripOccurrenceId ?? this.currentTripOccurrenceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduleDefinitionId.present) {
      map['schedule_definition_id'] = Variable<int>(scheduleDefinitionId.value);
    }
    if (currentTripOccurrenceId.present) {
      map['current_trip_occurrence_id'] = Variable<int>(
        currentTripOccurrenceId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRunsCompanion(')
          ..write('id: $id, ')
          ..write('scheduleDefinitionId: $scheduleDefinitionId, ')
          ..write('currentTripOccurrenceId: $currentTripOccurrenceId')
          ..write(')'))
        .toString();
  }
}

class $ExecutionTraceEventsTable extends ExecutionTraceEvents
    with TableInfo<$ExecutionTraceEventsTable, ExecutionTraceEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExecutionTraceEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    check: () => ComparableExpr(sequence).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    check: () => eventType.isIn(const <String>[
      scheduleRunStartedTraceEvent,
      tripStartedTraceEvent,
      stepStartedTraceEvent,
      stepCompletedTraceEvent,
      tripCompletedTraceEvent,
      routeDecisionTraceEvent,
      scheduleRunCompletedTraceEvent,
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcUsMeta = const VerificationMeta(
    'occurredAtUtcUs',
  );
  @override
  late final GeneratedColumn<int> occurredAtUtcUs = GeneratedColumn<int>(
    'occurred_at_utc_us',
    aliasedName,
    false,
    check: () => ComparableExpr(occurredAtUtcUs).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scheduleRunIdMeta = const VerificationMeta(
    'scheduleRunId',
  );
  @override
  late final GeneratedColumn<int> scheduleRunId = GeneratedColumn<int>(
    'schedule_run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedule_runs (id)',
    ),
  );
  static const VerificationMeta _tripOccurrenceIdMeta = const VerificationMeta(
    'tripOccurrenceId',
  );
  @override
  late final GeneratedColumn<int> tripOccurrenceId = GeneratedColumn<int>(
    'trip_occurrence_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedule_trip_occurrences (id)',
    ),
  );
  static const VerificationMeta _stepOccurrenceIdMeta = const VerificationMeta(
    'stepOccurrenceId',
  );
  @override
  late final GeneratedColumn<int> stepOccurrenceId = GeneratedColumn<int>(
    'step_occurrence_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trip_step_occurrences (id)',
    ),
  );
  static const VerificationMeta _routingResultTripDefinitionIdMeta =
      const VerificationMeta('routingResultTripDefinitionId');
  @override
  late final GeneratedColumn<int> routingResultTripDefinitionId =
      GeneratedColumn<int>(
        'routing_result_trip_definition_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES trip_definitions (id)',
        ),
      );
  static const VerificationMeta _selectedDestinationTripOccurrenceIdMeta =
      const VerificationMeta('selectedDestinationTripOccurrenceId');
  @override
  late final GeneratedColumn<int> selectedDestinationTripOccurrenceId =
      GeneratedColumn<int>(
        'selected_destination_trip_occurrence_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_trip_occurrences (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    sequence,
    eventType,
    occurredAtUtcUs,
    id,
    scheduleRunId,
    tripOccurrenceId,
    stepOccurrenceId,
    routingResultTripDefinitionId,
    selectedDestinationTripOccurrenceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'execution_trace_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExecutionTraceEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('occurred_at_utc_us')) {
      context.handle(
        _occurredAtUtcUsMeta,
        occurredAtUtcUs.isAcceptableOrUnknown(
          data['occurred_at_utc_us']!,
          _occurredAtUtcUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcUsMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_run_id')) {
      context.handle(
        _scheduleRunIdMeta,
        scheduleRunId.isAcceptableOrUnknown(
          data['schedule_run_id']!,
          _scheduleRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleRunIdMeta);
    }
    if (data.containsKey('trip_occurrence_id')) {
      context.handle(
        _tripOccurrenceIdMeta,
        tripOccurrenceId.isAcceptableOrUnknown(
          data['trip_occurrence_id']!,
          _tripOccurrenceIdMeta,
        ),
      );
    }
    if (data.containsKey('step_occurrence_id')) {
      context.handle(
        _stepOccurrenceIdMeta,
        stepOccurrenceId.isAcceptableOrUnknown(
          data['step_occurrence_id']!,
          _stepOccurrenceIdMeta,
        ),
      );
    }
    if (data.containsKey('routing_result_trip_definition_id')) {
      context.handle(
        _routingResultTripDefinitionIdMeta,
        routingResultTripDefinitionId.isAcceptableOrUnknown(
          data['routing_result_trip_definition_id']!,
          _routingResultTripDefinitionIdMeta,
        ),
      );
    }
    if (data.containsKey('selected_destination_trip_occurrence_id')) {
      context.handle(
        _selectedDestinationTripOccurrenceIdMeta,
        selectedDestinationTripOccurrenceId.isAcceptableOrUnknown(
          data['selected_destination_trip_occurrence_id']!,
          _selectedDestinationTripOccurrenceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {scheduleRunId, sequence},
  ];
  @override
  ExecutionTraceEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExecutionTraceEventRow(
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      occurredAtUtcUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_utc_us'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scheduleRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_run_id'],
      )!,
      tripOccurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_occurrence_id'],
      ),
      stepOccurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_occurrence_id'],
      ),
      routingResultTripDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routing_result_trip_definition_id'],
      ),
      selectedDestinationTripOccurrenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_destination_trip_occurrence_id'],
      ),
    );
  }

  @override
  $ExecutionTraceEventsTable createAlias(String alias) {
    return $ExecutionTraceEventsTable(attachedDatabase, alias);
  }
}

class ExecutionTraceEventRow extends DataClass
    implements Insertable<ExecutionTraceEventRow> {
  final int sequence;
  final String eventType;
  final int occurredAtUtcUs;
  final int id;
  final int scheduleRunId;
  final int? tripOccurrenceId;
  final int? stepOccurrenceId;
  final int? routingResultTripDefinitionId;
  final int? selectedDestinationTripOccurrenceId;
  const ExecutionTraceEventRow({
    required this.sequence,
    required this.eventType,
    required this.occurredAtUtcUs,
    required this.id,
    required this.scheduleRunId,
    this.tripOccurrenceId,
    this.stepOccurrenceId,
    this.routingResultTripDefinitionId,
    this.selectedDestinationTripOccurrenceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sequence'] = Variable<int>(sequence);
    map['event_type'] = Variable<String>(eventType);
    map['occurred_at_utc_us'] = Variable<int>(occurredAtUtcUs);
    map['id'] = Variable<int>(id);
    map['schedule_run_id'] = Variable<int>(scheduleRunId);
    if (!nullToAbsent || tripOccurrenceId != null) {
      map['trip_occurrence_id'] = Variable<int>(tripOccurrenceId);
    }
    if (!nullToAbsent || stepOccurrenceId != null) {
      map['step_occurrence_id'] = Variable<int>(stepOccurrenceId);
    }
    if (!nullToAbsent || routingResultTripDefinitionId != null) {
      map['routing_result_trip_definition_id'] = Variable<int>(
        routingResultTripDefinitionId,
      );
    }
    if (!nullToAbsent || selectedDestinationTripOccurrenceId != null) {
      map['selected_destination_trip_occurrence_id'] = Variable<int>(
        selectedDestinationTripOccurrenceId,
      );
    }
    return map;
  }

  ExecutionTraceEventsCompanion toCompanion(bool nullToAbsent) {
    return ExecutionTraceEventsCompanion(
      sequence: Value(sequence),
      eventType: Value(eventType),
      occurredAtUtcUs: Value(occurredAtUtcUs),
      id: Value(id),
      scheduleRunId: Value(scheduleRunId),
      tripOccurrenceId: tripOccurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripOccurrenceId),
      stepOccurrenceId: stepOccurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(stepOccurrenceId),
      routingResultTripDefinitionId:
          routingResultTripDefinitionId == null && nullToAbsent
          ? const Value.absent()
          : Value(routingResultTripDefinitionId),
      selectedDestinationTripOccurrenceId:
          selectedDestinationTripOccurrenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedDestinationTripOccurrenceId),
    );
  }

  factory ExecutionTraceEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExecutionTraceEventRow(
      sequence: serializer.fromJson<int>(json['sequence']),
      eventType: serializer.fromJson<String>(json['eventType']),
      occurredAtUtcUs: serializer.fromJson<int>(json['occurredAtUtcUs']),
      id: serializer.fromJson<int>(json['id']),
      scheduleRunId: serializer.fromJson<int>(json['scheduleRunId']),
      tripOccurrenceId: serializer.fromJson<int?>(json['tripOccurrenceId']),
      stepOccurrenceId: serializer.fromJson<int?>(json['stepOccurrenceId']),
      routingResultTripDefinitionId: serializer.fromJson<int?>(
        json['routingResultTripDefinitionId'],
      ),
      selectedDestinationTripOccurrenceId: serializer.fromJson<int?>(
        json['selectedDestinationTripOccurrenceId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sequence': serializer.toJson<int>(sequence),
      'eventType': serializer.toJson<String>(eventType),
      'occurredAtUtcUs': serializer.toJson<int>(occurredAtUtcUs),
      'id': serializer.toJson<int>(id),
      'scheduleRunId': serializer.toJson<int>(scheduleRunId),
      'tripOccurrenceId': serializer.toJson<int?>(tripOccurrenceId),
      'stepOccurrenceId': serializer.toJson<int?>(stepOccurrenceId),
      'routingResultTripDefinitionId': serializer.toJson<int?>(
        routingResultTripDefinitionId,
      ),
      'selectedDestinationTripOccurrenceId': serializer.toJson<int?>(
        selectedDestinationTripOccurrenceId,
      ),
    };
  }

  ExecutionTraceEventRow copyWith({
    int? sequence,
    String? eventType,
    int? occurredAtUtcUs,
    int? id,
    int? scheduleRunId,
    Value<int?> tripOccurrenceId = const Value.absent(),
    Value<int?> stepOccurrenceId = const Value.absent(),
    Value<int?> routingResultTripDefinitionId = const Value.absent(),
    Value<int?> selectedDestinationTripOccurrenceId = const Value.absent(),
  }) => ExecutionTraceEventRow(
    sequence: sequence ?? this.sequence,
    eventType: eventType ?? this.eventType,
    occurredAtUtcUs: occurredAtUtcUs ?? this.occurredAtUtcUs,
    id: id ?? this.id,
    scheduleRunId: scheduleRunId ?? this.scheduleRunId,
    tripOccurrenceId: tripOccurrenceId.present
        ? tripOccurrenceId.value
        : this.tripOccurrenceId,
    stepOccurrenceId: stepOccurrenceId.present
        ? stepOccurrenceId.value
        : this.stepOccurrenceId,
    routingResultTripDefinitionId: routingResultTripDefinitionId.present
        ? routingResultTripDefinitionId.value
        : this.routingResultTripDefinitionId,
    selectedDestinationTripOccurrenceId:
        selectedDestinationTripOccurrenceId.present
        ? selectedDestinationTripOccurrenceId.value
        : this.selectedDestinationTripOccurrenceId,
  );
  ExecutionTraceEventRow copyWithCompanion(ExecutionTraceEventsCompanion data) {
    return ExecutionTraceEventRow(
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAtUtcUs: data.occurredAtUtcUs.present
          ? data.occurredAtUtcUs.value
          : this.occurredAtUtcUs,
      id: data.id.present ? data.id.value : this.id,
      scheduleRunId: data.scheduleRunId.present
          ? data.scheduleRunId.value
          : this.scheduleRunId,
      tripOccurrenceId: data.tripOccurrenceId.present
          ? data.tripOccurrenceId.value
          : this.tripOccurrenceId,
      stepOccurrenceId: data.stepOccurrenceId.present
          ? data.stepOccurrenceId.value
          : this.stepOccurrenceId,
      routingResultTripDefinitionId: data.routingResultTripDefinitionId.present
          ? data.routingResultTripDefinitionId.value
          : this.routingResultTripDefinitionId,
      selectedDestinationTripOccurrenceId:
          data.selectedDestinationTripOccurrenceId.present
          ? data.selectedDestinationTripOccurrenceId.value
          : this.selectedDestinationTripOccurrenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExecutionTraceEventRow(')
          ..write('sequence: $sequence, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAtUtcUs: $occurredAtUtcUs, ')
          ..write('id: $id, ')
          ..write('scheduleRunId: $scheduleRunId, ')
          ..write('tripOccurrenceId: $tripOccurrenceId, ')
          ..write('stepOccurrenceId: $stepOccurrenceId, ')
          ..write(
            'routingResultTripDefinitionId: $routingResultTripDefinitionId, ',
          )
          ..write(
            'selectedDestinationTripOccurrenceId: $selectedDestinationTripOccurrenceId',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sequence,
    eventType,
    occurredAtUtcUs,
    id,
    scheduleRunId,
    tripOccurrenceId,
    stepOccurrenceId,
    routingResultTripDefinitionId,
    selectedDestinationTripOccurrenceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExecutionTraceEventRow &&
          other.sequence == this.sequence &&
          other.eventType == this.eventType &&
          other.occurredAtUtcUs == this.occurredAtUtcUs &&
          other.id == this.id &&
          other.scheduleRunId == this.scheduleRunId &&
          other.tripOccurrenceId == this.tripOccurrenceId &&
          other.stepOccurrenceId == this.stepOccurrenceId &&
          other.routingResultTripDefinitionId ==
              this.routingResultTripDefinitionId &&
          other.selectedDestinationTripOccurrenceId ==
              this.selectedDestinationTripOccurrenceId);
}

class ExecutionTraceEventsCompanion
    extends UpdateCompanion<ExecutionTraceEventRow> {
  final Value<int> sequence;
  final Value<String> eventType;
  final Value<int> occurredAtUtcUs;
  final Value<int> id;
  final Value<int> scheduleRunId;
  final Value<int?> tripOccurrenceId;
  final Value<int?> stepOccurrenceId;
  final Value<int?> routingResultTripDefinitionId;
  final Value<int?> selectedDestinationTripOccurrenceId;
  const ExecutionTraceEventsCompanion({
    this.sequence = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAtUtcUs = const Value.absent(),
    this.id = const Value.absent(),
    this.scheduleRunId = const Value.absent(),
    this.tripOccurrenceId = const Value.absent(),
    this.stepOccurrenceId = const Value.absent(),
    this.routingResultTripDefinitionId = const Value.absent(),
    this.selectedDestinationTripOccurrenceId = const Value.absent(),
  });
  ExecutionTraceEventsCompanion.insert({
    required int sequence,
    required String eventType,
    required int occurredAtUtcUs,
    this.id = const Value.absent(),
    required int scheduleRunId,
    this.tripOccurrenceId = const Value.absent(),
    this.stepOccurrenceId = const Value.absent(),
    this.routingResultTripDefinitionId = const Value.absent(),
    this.selectedDestinationTripOccurrenceId = const Value.absent(),
  }) : sequence = Value(sequence),
       eventType = Value(eventType),
       occurredAtUtcUs = Value(occurredAtUtcUs),
       scheduleRunId = Value(scheduleRunId);
  static Insertable<ExecutionTraceEventRow> custom({
    Expression<int>? sequence,
    Expression<String>? eventType,
    Expression<int>? occurredAtUtcUs,
    Expression<int>? id,
    Expression<int>? scheduleRunId,
    Expression<int>? tripOccurrenceId,
    Expression<int>? stepOccurrenceId,
    Expression<int>? routingResultTripDefinitionId,
    Expression<int>? selectedDestinationTripOccurrenceId,
  }) {
    return RawValuesInsertable({
      if (sequence != null) 'sequence': sequence,
      if (eventType != null) 'event_type': eventType,
      if (occurredAtUtcUs != null) 'occurred_at_utc_us': occurredAtUtcUs,
      if (id != null) 'id': id,
      if (scheduleRunId != null) 'schedule_run_id': scheduleRunId,
      if (tripOccurrenceId != null) 'trip_occurrence_id': tripOccurrenceId,
      if (stepOccurrenceId != null) 'step_occurrence_id': stepOccurrenceId,
      if (routingResultTripDefinitionId != null)
        'routing_result_trip_definition_id': routingResultTripDefinitionId,
      if (selectedDestinationTripOccurrenceId != null)
        'selected_destination_trip_occurrence_id':
            selectedDestinationTripOccurrenceId,
    });
  }

  ExecutionTraceEventsCompanion copyWith({
    Value<int>? sequence,
    Value<String>? eventType,
    Value<int>? occurredAtUtcUs,
    Value<int>? id,
    Value<int>? scheduleRunId,
    Value<int?>? tripOccurrenceId,
    Value<int?>? stepOccurrenceId,
    Value<int?>? routingResultTripDefinitionId,
    Value<int?>? selectedDestinationTripOccurrenceId,
  }) {
    return ExecutionTraceEventsCompanion(
      sequence: sequence ?? this.sequence,
      eventType: eventType ?? this.eventType,
      occurredAtUtcUs: occurredAtUtcUs ?? this.occurredAtUtcUs,
      id: id ?? this.id,
      scheduleRunId: scheduleRunId ?? this.scheduleRunId,
      tripOccurrenceId: tripOccurrenceId ?? this.tripOccurrenceId,
      stepOccurrenceId: stepOccurrenceId ?? this.stepOccurrenceId,
      routingResultTripDefinitionId:
          routingResultTripDefinitionId ?? this.routingResultTripDefinitionId,
      selectedDestinationTripOccurrenceId:
          selectedDestinationTripOccurrenceId ??
          this.selectedDestinationTripOccurrenceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (occurredAtUtcUs.present) {
      map['occurred_at_utc_us'] = Variable<int>(occurredAtUtcUs.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduleRunId.present) {
      map['schedule_run_id'] = Variable<int>(scheduleRunId.value);
    }
    if (tripOccurrenceId.present) {
      map['trip_occurrence_id'] = Variable<int>(tripOccurrenceId.value);
    }
    if (stepOccurrenceId.present) {
      map['step_occurrence_id'] = Variable<int>(stepOccurrenceId.value);
    }
    if (routingResultTripDefinitionId.present) {
      map['routing_result_trip_definition_id'] = Variable<int>(
        routingResultTripDefinitionId.value,
      );
    }
    if (selectedDestinationTripOccurrenceId.present) {
      map['selected_destination_trip_occurrence_id'] = Variable<int>(
        selectedDestinationTripOccurrenceId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExecutionTraceEventsCompanion(')
          ..write('sequence: $sequence, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAtUtcUs: $occurredAtUtcUs, ')
          ..write('id: $id, ')
          ..write('scheduleRunId: $scheduleRunId, ')
          ..write('tripOccurrenceId: $tripOccurrenceId, ')
          ..write('stepOccurrenceId: $stepOccurrenceId, ')
          ..write(
            'routingResultTripDefinitionId: $routingResultTripDefinitionId, ',
          )
          ..write(
            'selectedDestinationTripOccurrenceId: $selectedDestinationTripOccurrenceId',
          )
          ..write(')'))
        .toString();
  }
}

abstract class _$PresenceDatabase extends GeneratedDatabase {
  _$PresenceDatabase(QueryExecutor e) : super(e);
  $PresenceDatabaseManager get managers => $PresenceDatabaseManager(this);
  late final $ScheduleDefinitionsTable scheduleDefinitions =
      $ScheduleDefinitionsTable(this);
  late final $TripDefinitionsTable tripDefinitions = $TripDefinitionsTable(
    this,
  );
  late final $StepDefinitionsTable stepDefinitions = $StepDefinitionsTable(
    this,
  );
  late final $ScheduleTripOccurrencesTable scheduleTripOccurrences =
      $ScheduleTripOccurrencesTable(this);
  late final $TripStepOccurrencesTable tripStepOccurrences =
      $TripStepOccurrencesTable(this);
  late final $TellStepDefinitionsTable tellStepDefinitions =
      $TellStepDefinitionsTable(this);
  late final $FixedDestinationStepDefinitionsTable
  fixedDestinationStepDefinitions = $FixedDestinationStepDefinitionsTable(this);
  late final $FdaTestStepDefinitionsTable fdaTestStepDefinitions =
      $FdaTestStepDefinitionsTable(this);
  late final $ContactsSourceReadinessStepDefinitionsTable
  contactsSourceReadinessStepDefinitions =
      $ContactsSourceReadinessStepDefinitionsTable(this);
  late final $OpenFdaSettingsStepDefinitionsTable
  openFdaSettingsStepDefinitions = $OpenFdaSettingsStepDefinitionsTable(this);
  late final $TestAgentDefinitionsTable testAgentDefinitions =
      $TestAgentDefinitionsTable(this);
  late final $TestStepDefinitionsTable testStepDefinitions =
      $TestStepDefinitionsTable(this);
  late final $ChoiceStepDefinitionsTable choiceStepDefinitions =
      $ChoiceStepDefinitionsTable(this);
  late final $ChoiceStepOptionsTable choiceStepOptions =
      $ChoiceStepOptionsTable(this);
  late final $ScheduleRunsTable scheduleRuns = $ScheduleRunsTable(this);
  late final $ExecutionTraceEventsTable executionTraceEvents =
      $ExecutionTraceEventsTable(this);
  late final Index fixedDestinationStepDestinationTrip = Index(
    'fixed_destination_step_destination_trip',
    'CREATE INDEX fixed_destination_step_destination_trip ON fixed_destination_step_definitions (destination_trip_definition_id)',
  );
  late final Index fdaTestStepPresentDestinationTrip = Index(
    'fda_test_step_present_destination_trip',
    'CREATE INDEX fda_test_step_present_destination_trip ON fda_test_step_definitions (present_destination_trip_definition_id)',
  );
  late final Index fdaTestStepAbsentDestinationTrip = Index(
    'fda_test_step_absent_destination_trip',
    'CREATE INDEX fda_test_step_absent_destination_trip ON fda_test_step_definitions (absent_destination_trip_definition_id)',
  );
  late final Index contactsSourceReadinessStepAvailableDestinationTrip = Index(
    'contacts_source_readiness_step_available_destination_trip',
    'CREATE INDEX contacts_source_readiness_step_available_destination_trip ON contacts_source_readiness_step_definitions (available_destination_trip_definition_id)',
  );
  late final Index
  contactsSourceReadinessStepUnavailableDestinationTrip = Index(
    'contacts_source_readiness_step_unavailable_destination_trip',
    'CREATE INDEX contacts_source_readiness_step_unavailable_destination_trip ON contacts_source_readiness_step_definitions (unavailable_destination_trip_definition_id)',
  );
  late final Index testStepTrueDestinationTrip = Index(
    'test_step_true_destination_trip',
    'CREATE INDEX test_step_true_destination_trip ON test_step_definitions (true_destination_trip_definition_id)',
  );
  late final Index testStepFalseDestinationTrip = Index(
    'test_step_false_destination_trip',
    'CREATE INDEX test_step_false_destination_trip ON test_step_definitions (false_destination_trip_definition_id)',
  );
  late final Index choiceStepOptionDestinationTrip = Index(
    'choice_step_option_destination_trip',
    'CREATE INDEX choice_step_option_destination_trip ON choice_step_options (destination_trip_definition_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scheduleDefinitions,
    tripDefinitions,
    stepDefinitions,
    scheduleTripOccurrences,
    tripStepOccurrences,
    tellStepDefinitions,
    fixedDestinationStepDefinitions,
    fdaTestStepDefinitions,
    contactsSourceReadinessStepDefinitions,
    openFdaSettingsStepDefinitions,
    testAgentDefinitions,
    testStepDefinitions,
    choiceStepDefinitions,
    choiceStepOptions,
    scheduleRuns,
    executionTraceEvents,
    fixedDestinationStepDestinationTrip,
    fdaTestStepPresentDestinationTrip,
    fdaTestStepAbsentDestinationTrip,
    contactsSourceReadinessStepAvailableDestinationTrip,
    contactsSourceReadinessStepUnavailableDestinationTrip,
    testStepTrueDestinationTrip,
    testStepFalseDestinationTrip,
    choiceStepOptionDestinationTrip,
  ];
}

typedef $$ScheduleDefinitionsTableCreateCompanionBuilder =
    ScheduleDefinitionsCompanion Function({
      Value<int> id,
      required String name,
    });
typedef $$ScheduleDefinitionsTableUpdateCompanionBuilder =
    ScheduleDefinitionsCompanion Function({Value<int> id, Value<String> name});

final class $$ScheduleDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $ScheduleDefinitionsTable,
          ScheduleDefinitionRow
        > {
  $$ScheduleDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ScheduleTripOccurrencesTable,
    List<ScheduleTripOccurrenceRow>
  >
  _scheduleTripOccurrencesRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduleTripOccurrences,
        aliasName: $_aliasNameGenerator(
          db.scheduleDefinitions.id,
          db.scheduleTripOccurrences.scheduleDefinitionId,
        ),
      );

  $$ScheduleTripOccurrencesTableProcessedTableManager
  get scheduleTripOccurrencesRefs {
    final manager =
        $$ScheduleTripOccurrencesTableTableManager(
          $_db,
          $_db.scheduleTripOccurrences,
        ).filter(
          (f) => f.scheduleDefinitionId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _scheduleTripOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScheduleRunsTable, List<ScheduleRunRow>>
  _scheduleRunsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduleRuns,
        aliasName: $_aliasNameGenerator(
          db.scheduleDefinitions.id,
          db.scheduleRuns.scheduleDefinitionId,
        ),
      );

  $$ScheduleRunsTableProcessedTableManager get scheduleRunsRefs {
    final manager = $$ScheduleRunsTableTableManager($_db, $_db.scheduleRuns)
        .filter(
          (f) => f.scheduleDefinitionId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_scheduleRunsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScheduleDefinitionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $ScheduleDefinitionsTable> {
  $$ScheduleDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scheduleTripOccurrencesRefs(
    Expression<bool> Function($$ScheduleTripOccurrencesTableFilterComposer f) f,
  ) {
    final $$ScheduleTripOccurrencesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.scheduleDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableFilterComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> scheduleRunsRefs(
    Expression<bool> Function($$ScheduleRunsTableFilterComposer f) f,
  ) {
    final $$ScheduleRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleRuns,
      getReferencedColumn: (t) => t.scheduleDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleRunsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScheduleDefinitionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $ScheduleDefinitionsTable> {
  $$ScheduleDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleDefinitionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $ScheduleDefinitionsTable> {
  $$ScheduleDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> scheduleTripOccurrencesRefs<T extends Object>(
    Expression<T> Function($$ScheduleTripOccurrencesTableAnnotationComposer a)
    f,
  ) {
    final $$ScheduleTripOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.scheduleDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> scheduleRunsRefs<T extends Object>(
    Expression<T> Function($$ScheduleRunsTableAnnotationComposer a) f,
  ) {
    final $$ScheduleRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleRuns,
      getReferencedColumn: (t) => t.scheduleDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduleRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScheduleDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $ScheduleDefinitionsTable,
          ScheduleDefinitionRow,
          $$ScheduleDefinitionsTableFilterComposer,
          $$ScheduleDefinitionsTableOrderingComposer,
          $$ScheduleDefinitionsTableAnnotationComposer,
          $$ScheduleDefinitionsTableCreateCompanionBuilder,
          $$ScheduleDefinitionsTableUpdateCompanionBuilder,
          (ScheduleDefinitionRow, $$ScheduleDefinitionsTableReferences),
          ScheduleDefinitionRow,
          PrefetchHooks Function({
            bool scheduleTripOccurrencesRefs,
            bool scheduleRunsRefs,
          })
        > {
  $$ScheduleDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $ScheduleDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduleDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => ScheduleDefinitionsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  ScheduleDefinitionsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduleDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                scheduleTripOccurrencesRefs = false,
                scheduleRunsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scheduleTripOccurrencesRefs) db.scheduleTripOccurrences,
                    if (scheduleRunsRefs) db.scheduleRuns,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scheduleTripOccurrencesRefs)
                        await $_getPrefetchedData<
                          ScheduleDefinitionRow,
                          $ScheduleDefinitionsTable,
                          ScheduleTripOccurrenceRow
                        >(
                          currentTable: table,
                          referencedTable: $$ScheduleDefinitionsTableReferences
                              ._scheduleTripOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScheduleDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleTripOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scheduleRunsRefs)
                        await $_getPrefetchedData<
                          ScheduleDefinitionRow,
                          $ScheduleDefinitionsTable,
                          ScheduleRunRow
                        >(
                          currentTable: table,
                          referencedTable: $$ScheduleDefinitionsTableReferences
                              ._scheduleRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScheduleDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ScheduleDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $ScheduleDefinitionsTable,
      ScheduleDefinitionRow,
      $$ScheduleDefinitionsTableFilterComposer,
      $$ScheduleDefinitionsTableOrderingComposer,
      $$ScheduleDefinitionsTableAnnotationComposer,
      $$ScheduleDefinitionsTableCreateCompanionBuilder,
      $$ScheduleDefinitionsTableUpdateCompanionBuilder,
      (ScheduleDefinitionRow, $$ScheduleDefinitionsTableReferences),
      ScheduleDefinitionRow,
      PrefetchHooks Function({
        bool scheduleTripOccurrencesRefs,
        bool scheduleRunsRefs,
      })
    >;
typedef $$TripDefinitionsTableCreateCompanionBuilder =
    TripDefinitionsCompanion Function({Value<int> id, required String name});
typedef $$TripDefinitionsTableUpdateCompanionBuilder =
    TripDefinitionsCompanion Function({Value<int> id, Value<String> name});

final class $$TripDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $TripDefinitionsTable,
          TripDefinitionRow
        > {
  $$TripDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ScheduleTripOccurrencesTable,
    List<ScheduleTripOccurrenceRow>
  >
  _scheduleTripOccurrencesRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduleTripOccurrences,
        aliasName: $_aliasNameGenerator(
          db.tripDefinitions.id,
          db.scheduleTripOccurrences.tripDefinitionId,
        ),
      );

  $$ScheduleTripOccurrencesTableProcessedTableManager
  get scheduleTripOccurrencesRefs {
    final manager = $$ScheduleTripOccurrencesTableTableManager(
      $_db,
      $_db.scheduleTripOccurrences,
    ).filter((f) => f.tripDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduleTripOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TripStepOccurrencesTable,
    List<TripStepOccurrenceRow>
  >
  _tripStepOccurrencesRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tripStepOccurrences,
        aliasName: $_aliasNameGenerator(
          db.tripDefinitions.id,
          db.tripStepOccurrences.tripDefinitionId,
        ),
      );

  $$TripStepOccurrencesTableProcessedTableManager get tripStepOccurrencesRefs {
    final manager = $$TripStepOccurrencesTableTableManager(
      $_db,
      $_db.tripStepOccurrences,
    ).filter((f) => f.tripDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tripStepOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $FixedDestinationStepDefinitionsTable,
    List<FixedDestinationStepDefinitionRow>
  >
  _fixedDestinationStepDefinitionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fixedDestinationStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.tripDefinitions.id,
          db.fixedDestinationStepDefinitions.destinationTripDefinitionId,
        ),
      );

  $$FixedDestinationStepDefinitionsTableProcessedTableManager
  get fixedDestinationStepDefinitionsRefs {
    final manager =
        $$FixedDestinationStepDefinitionsTableTableManager(
          $_db,
          $_db.fixedDestinationStepDefinitions,
        ).filter(
          (f) => f.destinationTripDefinitionId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _fixedDestinationStepDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $FdaTestStepDefinitionsTable,
    List<FdaTestStepDefinitionRow>
  >
  _presentFdaTestStepDefinitionsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fdaTestStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.tripDefinitions.id,
          db.fdaTestStepDefinitions.presentDestinationTripDefinitionId,
        ),
      );

  $$FdaTestStepDefinitionsTableProcessedTableManager
  get presentFdaTestStepDefinitions {
    final manager =
        $$FdaTestStepDefinitionsTableTableManager(
          $_db,
          $_db.fdaTestStepDefinitions,
        ).filter(
          (f) => f.presentDestinationTripDefinitionId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _presentFdaTestStepDefinitionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $FdaTestStepDefinitionsTable,
    List<FdaTestStepDefinitionRow>
  >
  _absentFdaTestStepDefinitionsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fdaTestStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.tripDefinitions.id,
          db.fdaTestStepDefinitions.absentDestinationTripDefinitionId,
        ),
      );

  $$FdaTestStepDefinitionsTableProcessedTableManager
  get absentFdaTestStepDefinitions {
    final manager =
        $$FdaTestStepDefinitionsTableTableManager(
          $_db,
          $_db.fdaTestStepDefinitions,
        ).filter(
          (f) => f.absentDestinationTripDefinitionId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _absentFdaTestStepDefinitionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ContactsSourceReadinessStepDefinitionsTable,
    List<ContactsSourceReadinessStepDefinitionRow>
  >
  _availableContactsSourceReadinessStepDefinitionsTable(
    _$PresenceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.contactsSourceReadinessStepDefinitions,
    aliasName: $_aliasNameGenerator(
      db.tripDefinitions.id,
      db
          .contactsSourceReadinessStepDefinitions
          .availableDestinationTripDefinitionId,
    ),
  );

  $$ContactsSourceReadinessStepDefinitionsTableProcessedTableManager
  get availableContactsSourceReadinessStepDefinitions {
    final manager =
        $$ContactsSourceReadinessStepDefinitionsTableTableManager(
          $_db,
          $_db.contactsSourceReadinessStepDefinitions,
        ).filter(
          (f) => f.availableDestinationTripDefinitionId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _availableContactsSourceReadinessStepDefinitionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ContactsSourceReadinessStepDefinitionsTable,
    List<ContactsSourceReadinessStepDefinitionRow>
  >
  _unavailableContactsSourceReadinessStepDefinitionsTable(
    _$PresenceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.contactsSourceReadinessStepDefinitions,
    aliasName: $_aliasNameGenerator(
      db.tripDefinitions.id,
      db
          .contactsSourceReadinessStepDefinitions
          .unavailableDestinationTripDefinitionId,
    ),
  );

  $$ContactsSourceReadinessStepDefinitionsTableProcessedTableManager
  get unavailableContactsSourceReadinessStepDefinitions {
    final manager =
        $$ContactsSourceReadinessStepDefinitionsTableTableManager(
          $_db,
          $_db.contactsSourceReadinessStepDefinitions,
        ).filter(
          (f) => f.unavailableDestinationTripDefinitionId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _unavailableContactsSourceReadinessStepDefinitionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TestStepDefinitionsTable,
    List<TestStepDefinitionRow>
  >
  _trueTestStepDefinitionsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.testStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.tripDefinitions.id,
          db.testStepDefinitions.trueDestinationTripDefinitionId,
        ),
      );

  $$TestStepDefinitionsTableProcessedTableManager get trueTestStepDefinitions {
    final manager =
        $$TestStepDefinitionsTableTableManager(
          $_db,
          $_db.testStepDefinitions,
        ).filter(
          (f) => f.trueDestinationTripDefinitionId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _trueTestStepDefinitionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TestStepDefinitionsTable,
    List<TestStepDefinitionRow>
  >
  _falseTestStepDefinitionsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.testStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.tripDefinitions.id,
          db.testStepDefinitions.falseDestinationTripDefinitionId,
        ),
      );

  $$TestStepDefinitionsTableProcessedTableManager get falseTestStepDefinitions {
    final manager =
        $$TestStepDefinitionsTableTableManager(
          $_db,
          $_db.testStepDefinitions,
        ).filter(
          (f) => f.falseDestinationTripDefinitionId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _falseTestStepDefinitionsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChoiceStepOptionsTable, List<ChoiceStepOptionRow>>
  _choiceStepOptionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.choiceStepOptions,
        aliasName: $_aliasNameGenerator(
          db.tripDefinitions.id,
          db.choiceStepOptions.destinationTripDefinitionId,
        ),
      );

  $$ChoiceStepOptionsTableProcessedTableManager get choiceStepOptionsRefs {
    final manager =
        $$ChoiceStepOptionsTableTableManager(
          $_db,
          $_db.choiceStepOptions,
        ).filter(
          (f) => f.destinationTripDefinitionId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _choiceStepOptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExecutionTraceEventsTable,
    List<ExecutionTraceEventRow>
  >
  _executionTraceEventsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.executionTraceEvents,
        aliasName: $_aliasNameGenerator(
          db.tripDefinitions.id,
          db.executionTraceEvents.routingResultTripDefinitionId,
        ),
      );

  $$ExecutionTraceEventsTableProcessedTableManager
  get executionTraceEventsRefs {
    final manager =
        $$ExecutionTraceEventsTableTableManager(
          $_db,
          $_db.executionTraceEvents,
        ).filter(
          (f) => f.routingResultTripDefinitionId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _executionTraceEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripDefinitionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $TripDefinitionsTable> {
  $$TripDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scheduleTripOccurrencesRefs(
    Expression<bool> Function($$ScheduleTripOccurrencesTableFilterComposer f) f,
  ) {
    final $$ScheduleTripOccurrencesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.tripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableFilterComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> tripStepOccurrencesRefs(
    Expression<bool> Function($$TripStepOccurrencesTableFilterComposer f) f,
  ) {
    final $$TripStepOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripStepOccurrences,
      getReferencedColumn: (t) => t.tripDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripStepOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.tripStepOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fixedDestinationStepDefinitionsRefs(
    Expression<bool> Function(
      $$FixedDestinationStepDefinitionsTableFilterComposer f,
    )
    f,
  ) {
    final $$FixedDestinationStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fixedDestinationStepDefinitions,
          getReferencedColumn: (t) => t.destinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FixedDestinationStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.fixedDestinationStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> presentFdaTestStepDefinitions(
    Expression<bool> Function($$FdaTestStepDefinitionsTableFilterComposer f) f,
  ) {
    final $$FdaTestStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fdaTestStepDefinitions,
          getReferencedColumn: (t) => t.presentDestinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FdaTestStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.fdaTestStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> absentFdaTestStepDefinitions(
    Expression<bool> Function($$FdaTestStepDefinitionsTableFilterComposer f) f,
  ) {
    final $$FdaTestStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fdaTestStepDefinitions,
          getReferencedColumn: (t) => t.absentDestinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FdaTestStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.fdaTestStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> availableContactsSourceReadinessStepDefinitions(
    Expression<bool> Function(
      $$ContactsSourceReadinessStepDefinitionsTableFilterComposer f,
    )
    f,
  ) {
    final $$ContactsSourceReadinessStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.contactsSourceReadinessStepDefinitions,
          getReferencedColumn: (t) => t.availableDestinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactsSourceReadinessStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.contactsSourceReadinessStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> unavailableContactsSourceReadinessStepDefinitions(
    Expression<bool> Function(
      $$ContactsSourceReadinessStepDefinitionsTableFilterComposer f,
    )
    f,
  ) {
    final $$ContactsSourceReadinessStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.contactsSourceReadinessStepDefinitions,
          getReferencedColumn: (t) => t.unavailableDestinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactsSourceReadinessStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.contactsSourceReadinessStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> trueTestStepDefinitions(
    Expression<bool> Function($$TestStepDefinitionsTableFilterComposer f) f,
  ) {
    final $$TestStepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testStepDefinitions,
      getReferencedColumn: (t) => t.trueDestinationTripDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestStepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.testStepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> falseTestStepDefinitions(
    Expression<bool> Function($$TestStepDefinitionsTableFilterComposer f) f,
  ) {
    final $$TestStepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testStepDefinitions,
      getReferencedColumn: (t) => t.falseDestinationTripDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestStepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.testStepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> choiceStepOptionsRefs(
    Expression<bool> Function($$ChoiceStepOptionsTableFilterComposer f) f,
  ) {
    final $$ChoiceStepOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.choiceStepOptions,
      getReferencedColumn: (t) => t.destinationTripDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoiceStepOptionsTableFilterComposer(
            $db: $db,
            $table: $db.choiceStepOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> executionTraceEventsRefs(
    Expression<bool> Function($$ExecutionTraceEventsTableFilterComposer f) f,
  ) {
    final $$ExecutionTraceEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.executionTraceEvents,
      getReferencedColumn: (t) => t.routingResultTripDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExecutionTraceEventsTableFilterComposer(
            $db: $db,
            $table: $db.executionTraceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripDefinitionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $TripDefinitionsTable> {
  $$TripDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripDefinitionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $TripDefinitionsTable> {
  $$TripDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> scheduleTripOccurrencesRefs<T extends Object>(
    Expression<T> Function($$ScheduleTripOccurrencesTableAnnotationComposer a)
    f,
  ) {
    final $$ScheduleTripOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.tripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tripStepOccurrencesRefs<T extends Object>(
    Expression<T> Function($$TripStepOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$TripStepOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tripStepOccurrences,
          getReferencedColumn: (t) => t.tripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TripStepOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.tripStepOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> fixedDestinationStepDefinitionsRefs<T extends Object>(
    Expression<T> Function(
      $$FixedDestinationStepDefinitionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$FixedDestinationStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fixedDestinationStepDefinitions,
          getReferencedColumn: (t) => t.destinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FixedDestinationStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.fixedDestinationStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> presentFdaTestStepDefinitions<T extends Object>(
    Expression<T> Function($$FdaTestStepDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$FdaTestStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fdaTestStepDefinitions,
          getReferencedColumn: (t) => t.presentDestinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FdaTestStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.fdaTestStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> absentFdaTestStepDefinitions<T extends Object>(
    Expression<T> Function($$FdaTestStepDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$FdaTestStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fdaTestStepDefinitions,
          getReferencedColumn: (t) => t.absentDestinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FdaTestStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.fdaTestStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T>
  availableContactsSourceReadinessStepDefinitions<T extends Object>(
    Expression<T> Function(
      $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer
    composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactsSourceReadinessStepDefinitions,
      getReferencedColumn: (t) => t.availableDestinationTripDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.contactsSourceReadinessStepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T>
  unavailableContactsSourceReadinessStepDefinitions<T extends Object>(
    Expression<T> Function(
      $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer
    composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactsSourceReadinessStepDefinitions,
      getReferencedColumn: (t) => t.unavailableDestinationTripDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.contactsSourceReadinessStepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> trueTestStepDefinitions<T extends Object>(
    Expression<T> Function($$TestStepDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$TestStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.testStepDefinitions,
          getReferencedColumn: (t) => t.trueDestinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TestStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.testStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> falseTestStepDefinitions<T extends Object>(
    Expression<T> Function($$TestStepDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$TestStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.testStepDefinitions,
          getReferencedColumn: (t) => t.falseDestinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TestStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.testStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> choiceStepOptionsRefs<T extends Object>(
    Expression<T> Function($$ChoiceStepOptionsTableAnnotationComposer a) f,
  ) {
    final $$ChoiceStepOptionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.choiceStepOptions,
          getReferencedColumn: (t) => t.destinationTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChoiceStepOptionsTableAnnotationComposer(
                $db: $db,
                $table: $db.choiceStepOptions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> executionTraceEventsRefs<T extends Object>(
    Expression<T> Function($$ExecutionTraceEventsTableAnnotationComposer a) f,
  ) {
    final $$ExecutionTraceEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.executionTraceEvents,
          getReferencedColumn: (t) => t.routingResultTripDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExecutionTraceEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.executionTraceEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TripDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $TripDefinitionsTable,
          TripDefinitionRow,
          $$TripDefinitionsTableFilterComposer,
          $$TripDefinitionsTableOrderingComposer,
          $$TripDefinitionsTableAnnotationComposer,
          $$TripDefinitionsTableCreateCompanionBuilder,
          $$TripDefinitionsTableUpdateCompanionBuilder,
          (TripDefinitionRow, $$TripDefinitionsTableReferences),
          TripDefinitionRow,
          PrefetchHooks Function({
            bool scheduleTripOccurrencesRefs,
            bool tripStepOccurrencesRefs,
            bool fixedDestinationStepDefinitionsRefs,
            bool presentFdaTestStepDefinitions,
            bool absentFdaTestStepDefinitions,
            bool availableContactsSourceReadinessStepDefinitions,
            bool unavailableContactsSourceReadinessStepDefinitions,
            bool trueTestStepDefinitions,
            bool falseTestStepDefinitions,
            bool choiceStepOptionsRefs,
            bool executionTraceEventsRefs,
          })
        > {
  $$TripDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $TripDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripDefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => TripDefinitionsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  TripDefinitionsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                scheduleTripOccurrencesRefs = false,
                tripStepOccurrencesRefs = false,
                fixedDestinationStepDefinitionsRefs = false,
                presentFdaTestStepDefinitions = false,
                absentFdaTestStepDefinitions = false,
                availableContactsSourceReadinessStepDefinitions = false,
                unavailableContactsSourceReadinessStepDefinitions = false,
                trueTestStepDefinitions = false,
                falseTestStepDefinitions = false,
                choiceStepOptionsRefs = false,
                executionTraceEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scheduleTripOccurrencesRefs) db.scheduleTripOccurrences,
                    if (tripStepOccurrencesRefs) db.tripStepOccurrences,
                    if (fixedDestinationStepDefinitionsRefs)
                      db.fixedDestinationStepDefinitions,
                    if (presentFdaTestStepDefinitions)
                      db.fdaTestStepDefinitions,
                    if (absentFdaTestStepDefinitions) db.fdaTestStepDefinitions,
                    if (availableContactsSourceReadinessStepDefinitions)
                      db.contactsSourceReadinessStepDefinitions,
                    if (unavailableContactsSourceReadinessStepDefinitions)
                      db.contactsSourceReadinessStepDefinitions,
                    if (trueTestStepDefinitions) db.testStepDefinitions,
                    if (falseTestStepDefinitions) db.testStepDefinitions,
                    if (choiceStepOptionsRefs) db.choiceStepOptions,
                    if (executionTraceEventsRefs) db.executionTraceEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scheduleTripOccurrencesRefs)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          ScheduleTripOccurrenceRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._scheduleTripOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleTripOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tripStepOccurrencesRefs)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          TripStepOccurrenceRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._tripStepOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripStepOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fixedDestinationStepDefinitionsRefs)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          FixedDestinationStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._fixedDestinationStepDefinitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).fixedDestinationStepDefinitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.destinationTripDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (presentFdaTestStepDefinitions)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          FdaTestStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._presentFdaTestStepDefinitionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).presentFdaTestStepDefinitions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.presentDestinationTripDefinitionId ==
                                    item.id,
                              ),
                          typedResults: items,
                        ),
                      if (absentFdaTestStepDefinitions)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          FdaTestStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._absentFdaTestStepDefinitionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).absentFdaTestStepDefinitions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.absentDestinationTripDefinitionId ==
                                    item.id,
                              ),
                          typedResults: items,
                        ),
                      if (availableContactsSourceReadinessStepDefinitions)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          ContactsSourceReadinessStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._availableContactsSourceReadinessStepDefinitionsTable(
                                db,
                              ),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).availableContactsSourceReadinessStepDefinitions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.availableDestinationTripDefinitionId ==
                                    item.id,
                              ),
                          typedResults: items,
                        ),
                      if (unavailableContactsSourceReadinessStepDefinitions)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          ContactsSourceReadinessStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._unavailableContactsSourceReadinessStepDefinitionsTable(
                                db,
                              ),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).unavailableContactsSourceReadinessStepDefinitions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.unavailableDestinationTripDefinitionId ==
                                    item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trueTestStepDefinitions)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          TestStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._trueTestStepDefinitionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).trueTestStepDefinitions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.trueDestinationTripDefinitionId ==
                                    item.id,
                              ),
                          typedResults: items,
                        ),
                      if (falseTestStepDefinitions)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          TestStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._falseTestStepDefinitionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).falseTestStepDefinitions,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.falseDestinationTripDefinitionId ==
                                    item.id,
                              ),
                          typedResults: items,
                        ),
                      if (choiceStepOptionsRefs)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          ChoiceStepOptionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._choiceStepOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).choiceStepOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.destinationTripDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (executionTraceEventsRefs)
                        await $_getPrefetchedData<
                          TripDefinitionRow,
                          $TripDefinitionsTable,
                          ExecutionTraceEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripDefinitionsTableReferences
                              ._executionTraceEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).executionTraceEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.routingResultTripDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $TripDefinitionsTable,
      TripDefinitionRow,
      $$TripDefinitionsTableFilterComposer,
      $$TripDefinitionsTableOrderingComposer,
      $$TripDefinitionsTableAnnotationComposer,
      $$TripDefinitionsTableCreateCompanionBuilder,
      $$TripDefinitionsTableUpdateCompanionBuilder,
      (TripDefinitionRow, $$TripDefinitionsTableReferences),
      TripDefinitionRow,
      PrefetchHooks Function({
        bool scheduleTripOccurrencesRefs,
        bool tripStepOccurrencesRefs,
        bool fixedDestinationStepDefinitionsRefs,
        bool presentFdaTestStepDefinitions,
        bool absentFdaTestStepDefinitions,
        bool availableContactsSourceReadinessStepDefinitions,
        bool unavailableContactsSourceReadinessStepDefinitions,
        bool trueTestStepDefinitions,
        bool falseTestStepDefinitions,
        bool choiceStepOptionsRefs,
        bool executionTraceEventsRefs,
      })
    >;
typedef $$StepDefinitionsTableCreateCompanionBuilder =
    StepDefinitionsCompanion Function({
      required String stepType,
      Value<int> id,
      required String name,
    });
typedef $$StepDefinitionsTableUpdateCompanionBuilder =
    StepDefinitionsCompanion Function({
      Value<String> stepType,
      Value<int> id,
      Value<String> name,
    });

final class $$StepDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $StepDefinitionsTable,
          StepDefinitionRow
        > {
  $$StepDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $TripStepOccurrencesTable,
    List<TripStepOccurrenceRow>
  >
  _tripStepOccurrencesRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tripStepOccurrences,
        aliasName: $_aliasNameGenerator(
          db.stepDefinitions.id,
          db.tripStepOccurrences.stepDefinitionId,
        ),
      );

  $$TripStepOccurrencesTableProcessedTableManager get tripStepOccurrencesRefs {
    final manager = $$TripStepOccurrencesTableTableManager(
      $_db,
      $_db.tripStepOccurrences,
    ).filter((f) => f.stepDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tripStepOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TellStepDefinitionsTable,
    List<TellStepDefinitionRow>
  >
  _tellStepDefinitionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tellStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.stepDefinitions.id,
          db.tellStepDefinitions.stepDefinitionId,
        ),
      );

  $$TellStepDefinitionsTableProcessedTableManager get tellStepDefinitionsRefs {
    final manager = $$TellStepDefinitionsTableTableManager(
      $_db,
      $_db.tellStepDefinitions,
    ).filter((f) => f.stepDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _tellStepDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $FixedDestinationStepDefinitionsTable,
    List<FixedDestinationStepDefinitionRow>
  >
  _fixedDestinationStepDefinitionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fixedDestinationStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.stepDefinitions.id,
          db.fixedDestinationStepDefinitions.stepDefinitionId,
        ),
      );

  $$FixedDestinationStepDefinitionsTableProcessedTableManager
  get fixedDestinationStepDefinitionsRefs {
    final manager = $$FixedDestinationStepDefinitionsTableTableManager(
      $_db,
      $_db.fixedDestinationStepDefinitions,
    ).filter((f) => f.stepDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _fixedDestinationStepDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $FdaTestStepDefinitionsTable,
    List<FdaTestStepDefinitionRow>
  >
  _fdaTestStepDefinitionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fdaTestStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.stepDefinitions.id,
          db.fdaTestStepDefinitions.stepDefinitionId,
        ),
      );

  $$FdaTestStepDefinitionsTableProcessedTableManager
  get fdaTestStepDefinitionsRefs {
    final manager = $$FdaTestStepDefinitionsTableTableManager(
      $_db,
      $_db.fdaTestStepDefinitions,
    ).filter((f) => f.stepDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _fdaTestStepDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ContactsSourceReadinessStepDefinitionsTable,
    List<ContactsSourceReadinessStepDefinitionRow>
  >
  _contactsSourceReadinessStepDefinitionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contactsSourceReadinessStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.stepDefinitions.id,
          db.contactsSourceReadinessStepDefinitions.stepDefinitionId,
        ),
      );

  $$ContactsSourceReadinessStepDefinitionsTableProcessedTableManager
  get contactsSourceReadinessStepDefinitionsRefs {
    final manager = $$ContactsSourceReadinessStepDefinitionsTableTableManager(
      $_db,
      $_db.contactsSourceReadinessStepDefinitions,
    ).filter((f) => f.stepDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _contactsSourceReadinessStepDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $OpenFdaSettingsStepDefinitionsTable,
    List<OpenFdaSettingsStepDefinitionRow>
  >
  _openFdaSettingsStepDefinitionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.openFdaSettingsStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.stepDefinitions.id,
          db.openFdaSettingsStepDefinitions.stepDefinitionId,
        ),
      );

  $$OpenFdaSettingsStepDefinitionsTableProcessedTableManager
  get openFdaSettingsStepDefinitionsRefs {
    final manager = $$OpenFdaSettingsStepDefinitionsTableTableManager(
      $_db,
      $_db.openFdaSettingsStepDefinitions,
    ).filter((f) => f.stepDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _openFdaSettingsStepDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $TestStepDefinitionsTable,
    List<TestStepDefinitionRow>
  >
  _testStepDefinitionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.testStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.stepDefinitions.id,
          db.testStepDefinitions.stepDefinitionId,
        ),
      );

  $$TestStepDefinitionsTableProcessedTableManager get testStepDefinitionsRefs {
    final manager = $$TestStepDefinitionsTableTableManager(
      $_db,
      $_db.testStepDefinitions,
    ).filter((f) => f.stepDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _testStepDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ChoiceStepDefinitionsTable,
    List<ChoiceStepDefinitionRow>
  >
  _choiceStepDefinitionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.choiceStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.stepDefinitions.id,
          db.choiceStepDefinitions.stepDefinitionId,
        ),
      );

  $$ChoiceStepDefinitionsTableProcessedTableManager
  get choiceStepDefinitionsRefs {
    final manager = $$ChoiceStepDefinitionsTableTableManager(
      $_db,
      $_db.choiceStepDefinitions,
    ).filter((f) => f.stepDefinitionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _choiceStepDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StepDefinitionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $StepDefinitionsTable> {
  $$StepDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stepType => $composableBuilder(
    column: $table.stepType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tripStepOccurrencesRefs(
    Expression<bool> Function($$TripStepOccurrencesTableFilterComposer f) f,
  ) {
    final $$TripStepOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripStepOccurrences,
      getReferencedColumn: (t) => t.stepDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripStepOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.tripStepOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tellStepDefinitionsRefs(
    Expression<bool> Function($$TellStepDefinitionsTableFilterComposer f) f,
  ) {
    final $$TellStepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tellStepDefinitions,
      getReferencedColumn: (t) => t.stepDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TellStepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tellStepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fixedDestinationStepDefinitionsRefs(
    Expression<bool> Function(
      $$FixedDestinationStepDefinitionsTableFilterComposer f,
    )
    f,
  ) {
    final $$FixedDestinationStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fixedDestinationStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FixedDestinationStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.fixedDestinationStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> fdaTestStepDefinitionsRefs(
    Expression<bool> Function($$FdaTestStepDefinitionsTableFilterComposer f) f,
  ) {
    final $$FdaTestStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fdaTestStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FdaTestStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.fdaTestStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> contactsSourceReadinessStepDefinitionsRefs(
    Expression<bool> Function(
      $$ContactsSourceReadinessStepDefinitionsTableFilterComposer f,
    )
    f,
  ) {
    final $$ContactsSourceReadinessStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.contactsSourceReadinessStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactsSourceReadinessStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.contactsSourceReadinessStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> openFdaSettingsStepDefinitionsRefs(
    Expression<bool> Function(
      $$OpenFdaSettingsStepDefinitionsTableFilterComposer f,
    )
    f,
  ) {
    final $$OpenFdaSettingsStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.openFdaSettingsStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OpenFdaSettingsStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.openFdaSettingsStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> testStepDefinitionsRefs(
    Expression<bool> Function($$TestStepDefinitionsTableFilterComposer f) f,
  ) {
    final $$TestStepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testStepDefinitions,
      getReferencedColumn: (t) => t.stepDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestStepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.testStepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> choiceStepDefinitionsRefs(
    Expression<bool> Function($$ChoiceStepDefinitionsTableFilterComposer f) f,
  ) {
    final $$ChoiceStepDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.choiceStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChoiceStepDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.choiceStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StepDefinitionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $StepDefinitionsTable> {
  $$StepDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stepType => $composableBuilder(
    column: $table.stepType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StepDefinitionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $StepDefinitionsTable> {
  $$StepDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stepType =>
      $composableBuilder(column: $table.stepType, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> tripStepOccurrencesRefs<T extends Object>(
    Expression<T> Function($$TripStepOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$TripStepOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tripStepOccurrences,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TripStepOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.tripStepOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tellStepDefinitionsRefs<T extends Object>(
    Expression<T> Function($$TellStepDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$TellStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.tellStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TellStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.tellStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> fixedDestinationStepDefinitionsRefs<T extends Object>(
    Expression<T> Function(
      $$FixedDestinationStepDefinitionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$FixedDestinationStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fixedDestinationStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FixedDestinationStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.fixedDestinationStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> fdaTestStepDefinitionsRefs<T extends Object>(
    Expression<T> Function($$FdaTestStepDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$FdaTestStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.fdaTestStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FdaTestStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.fdaTestStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> contactsSourceReadinessStepDefinitionsRefs<T extends Object>(
    Expression<T> Function(
      $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer
    composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactsSourceReadinessStepDefinitions,
      getReferencedColumn: (t) => t.stepDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.contactsSourceReadinessStepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> openFdaSettingsStepDefinitionsRefs<T extends Object>(
    Expression<T> Function(
      $$OpenFdaSettingsStepDefinitionsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$OpenFdaSettingsStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.openFdaSettingsStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OpenFdaSettingsStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.openFdaSettingsStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> testStepDefinitionsRefs<T extends Object>(
    Expression<T> Function($$TestStepDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$TestStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.testStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TestStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.testStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> choiceStepDefinitionsRefs<T extends Object>(
    Expression<T> Function($$ChoiceStepDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$ChoiceStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.choiceStepDefinitions,
          getReferencedColumn: (t) => t.stepDefinitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChoiceStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.choiceStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StepDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $StepDefinitionsTable,
          StepDefinitionRow,
          $$StepDefinitionsTableFilterComposer,
          $$StepDefinitionsTableOrderingComposer,
          $$StepDefinitionsTableAnnotationComposer,
          $$StepDefinitionsTableCreateCompanionBuilder,
          $$StepDefinitionsTableUpdateCompanionBuilder,
          (StepDefinitionRow, $$StepDefinitionsTableReferences),
          StepDefinitionRow,
          PrefetchHooks Function({
            bool tripStepOccurrencesRefs,
            bool tellStepDefinitionsRefs,
            bool fixedDestinationStepDefinitionsRefs,
            bool fdaTestStepDefinitionsRefs,
            bool contactsSourceReadinessStepDefinitionsRefs,
            bool openFdaSettingsStepDefinitionsRefs,
            bool testStepDefinitionsRefs,
            bool choiceStepDefinitionsRefs,
          })
        > {
  $$StepDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $StepDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StepDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StepDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StepDefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> stepType = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => StepDefinitionsCompanion(
                stepType: stepType,
                id: id,
                name: name,
              ),
          createCompanionCallback:
              ({
                required String stepType,
                Value<int> id = const Value.absent(),
                required String name,
              }) => StepDefinitionsCompanion.insert(
                stepType: stepType,
                id: id,
                name: name,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StepDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripStepOccurrencesRefs = false,
                tellStepDefinitionsRefs = false,
                fixedDestinationStepDefinitionsRefs = false,
                fdaTestStepDefinitionsRefs = false,
                contactsSourceReadinessStepDefinitionsRefs = false,
                openFdaSettingsStepDefinitionsRefs = false,
                testStepDefinitionsRefs = false,
                choiceStepDefinitionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tripStepOccurrencesRefs) db.tripStepOccurrences,
                    if (tellStepDefinitionsRefs) db.tellStepDefinitions,
                    if (fixedDestinationStepDefinitionsRefs)
                      db.fixedDestinationStepDefinitions,
                    if (fdaTestStepDefinitionsRefs) db.fdaTestStepDefinitions,
                    if (contactsSourceReadinessStepDefinitionsRefs)
                      db.contactsSourceReadinessStepDefinitions,
                    if (openFdaSettingsStepDefinitionsRefs)
                      db.openFdaSettingsStepDefinitions,
                    if (testStepDefinitionsRefs) db.testStepDefinitions,
                    if (choiceStepDefinitionsRefs) db.choiceStepDefinitions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tripStepOccurrencesRefs)
                        await $_getPrefetchedData<
                          StepDefinitionRow,
                          $StepDefinitionsTable,
                          TripStepOccurrenceRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepDefinitionsTableReferences
                              ._tripStepOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StepDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripStepOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tellStepDefinitionsRefs)
                        await $_getPrefetchedData<
                          StepDefinitionRow,
                          $StepDefinitionsTable,
                          TellStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepDefinitionsTableReferences
                              ._tellStepDefinitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StepDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).tellStepDefinitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fixedDestinationStepDefinitionsRefs)
                        await $_getPrefetchedData<
                          StepDefinitionRow,
                          $StepDefinitionsTable,
                          FixedDestinationStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepDefinitionsTableReferences
                              ._fixedDestinationStepDefinitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StepDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).fixedDestinationStepDefinitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fdaTestStepDefinitionsRefs)
                        await $_getPrefetchedData<
                          StepDefinitionRow,
                          $StepDefinitionsTable,
                          FdaTestStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepDefinitionsTableReferences
                              ._fdaTestStepDefinitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StepDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).fdaTestStepDefinitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (contactsSourceReadinessStepDefinitionsRefs)
                        await $_getPrefetchedData<
                          StepDefinitionRow,
                          $StepDefinitionsTable,
                          ContactsSourceReadinessStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepDefinitionsTableReferences
                              ._contactsSourceReadinessStepDefinitionsRefsTable(
                                db,
                              ),
                          managerFromTypedResult: (p0) =>
                              $$StepDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).contactsSourceReadinessStepDefinitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (openFdaSettingsStepDefinitionsRefs)
                        await $_getPrefetchedData<
                          StepDefinitionRow,
                          $StepDefinitionsTable,
                          OpenFdaSettingsStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepDefinitionsTableReferences
                              ._openFdaSettingsStepDefinitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StepDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).openFdaSettingsStepDefinitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (testStepDefinitionsRefs)
                        await $_getPrefetchedData<
                          StepDefinitionRow,
                          $StepDefinitionsTable,
                          TestStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepDefinitionsTableReferences
                              ._testStepDefinitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StepDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).testStepDefinitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (choiceStepDefinitionsRefs)
                        await $_getPrefetchedData<
                          StepDefinitionRow,
                          $StepDefinitionsTable,
                          ChoiceStepDefinitionRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepDefinitionsTableReferences
                              ._choiceStepDefinitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StepDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).choiceStepDefinitionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepDefinitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StepDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $StepDefinitionsTable,
      StepDefinitionRow,
      $$StepDefinitionsTableFilterComposer,
      $$StepDefinitionsTableOrderingComposer,
      $$StepDefinitionsTableAnnotationComposer,
      $$StepDefinitionsTableCreateCompanionBuilder,
      $$StepDefinitionsTableUpdateCompanionBuilder,
      (StepDefinitionRow, $$StepDefinitionsTableReferences),
      StepDefinitionRow,
      PrefetchHooks Function({
        bool tripStepOccurrencesRefs,
        bool tellStepDefinitionsRefs,
        bool fixedDestinationStepDefinitionsRefs,
        bool fdaTestStepDefinitionsRefs,
        bool contactsSourceReadinessStepDefinitionsRefs,
        bool openFdaSettingsStepDefinitionsRefs,
        bool testStepDefinitionsRefs,
        bool choiceStepDefinitionsRefs,
      })
    >;
typedef $$ScheduleTripOccurrencesTableCreateCompanionBuilder =
    ScheduleTripOccurrencesCompanion Function({
      required int position,
      Value<int> id,
      required int scheduleDefinitionId,
      required int tripDefinitionId,
    });
typedef $$ScheduleTripOccurrencesTableUpdateCompanionBuilder =
    ScheduleTripOccurrencesCompanion Function({
      Value<int> position,
      Value<int> id,
      Value<int> scheduleDefinitionId,
      Value<int> tripDefinitionId,
    });

final class $$ScheduleTripOccurrencesTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $ScheduleTripOccurrencesTable,
          ScheduleTripOccurrenceRow
        > {
  $$ScheduleTripOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScheduleDefinitionsTable _scheduleDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.scheduleDefinitions.createAlias(
    $_aliasNameGenerator(
      db.scheduleTripOccurrences.scheduleDefinitionId,
      db.scheduleDefinitions.id,
    ),
  );

  $$ScheduleDefinitionsTableProcessedTableManager get scheduleDefinitionId {
    final $_column = $_itemColumn<int>('schedule_definition_id')!;

    final manager = $$ScheduleDefinitionsTableTableManager(
      $_db,
      $_db.scheduleDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _scheduleDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripDefinitionsTable _tripDefinitionIdTable(_$PresenceDatabase db) =>
      db.tripDefinitions.createAlias(
        $_aliasNameGenerator(
          db.scheduleTripOccurrences.tripDefinitionId,
          db.tripDefinitions.id,
        ),
      );

  $$TripDefinitionsTableProcessedTableManager get tripDefinitionId {
    final $_column = $_itemColumn<int>('trip_definition_id')!;

    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ExecutionTraceEventsTable,
    List<ExecutionTraceEventRow>
  >
  _traceTripOccurrencesTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.executionTraceEvents,
        aliasName: $_aliasNameGenerator(
          db.scheduleTripOccurrences.id,
          db.executionTraceEvents.tripOccurrenceId,
        ),
      );

  $$ExecutionTraceEventsTableProcessedTableManager get traceTripOccurrences {
    final manager = $$ExecutionTraceEventsTableTableManager(
      $_db,
      $_db.executionTraceEvents,
    ).filter((f) => f.tripOccurrenceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _traceTripOccurrencesTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExecutionTraceEventsTable,
    List<ExecutionTraceEventRow>
  >
  _traceSelectedDestinationOccurrencesTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.executionTraceEvents,
        aliasName: $_aliasNameGenerator(
          db.scheduleTripOccurrences.id,
          db.executionTraceEvents.selectedDestinationTripOccurrenceId,
        ),
      );

  $$ExecutionTraceEventsTableProcessedTableManager
  get traceSelectedDestinationOccurrences {
    final manager =
        $$ExecutionTraceEventsTableTableManager(
          $_db,
          $_db.executionTraceEvents,
        ).filter(
          (f) => f.selectedDestinationTripOccurrenceId.id.sqlEquals(
            $_itemColumn<int>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _traceSelectedDestinationOccurrencesTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScheduleTripOccurrencesTableFilterComposer
    extends Composer<_$PresenceDatabase, $ScheduleTripOccurrencesTable> {
  $$ScheduleTripOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$ScheduleDefinitionsTableFilterComposer get scheduleDefinitionId {
    final $$ScheduleDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleDefinitionId,
      referencedTable: $db.scheduleDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableFilterComposer get tripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> traceTripOccurrences(
    Expression<bool> Function($$ExecutionTraceEventsTableFilterComposer f) f,
  ) {
    final $$ExecutionTraceEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.executionTraceEvents,
      getReferencedColumn: (t) => t.tripOccurrenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExecutionTraceEventsTableFilterComposer(
            $db: $db,
            $table: $db.executionTraceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> traceSelectedDestinationOccurrences(
    Expression<bool> Function($$ExecutionTraceEventsTableFilterComposer f) f,
  ) {
    final $$ExecutionTraceEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.executionTraceEvents,
      getReferencedColumn: (t) => t.selectedDestinationTripOccurrenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExecutionTraceEventsTableFilterComposer(
            $db: $db,
            $table: $db.executionTraceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScheduleTripOccurrencesTableOrderingComposer
    extends Composer<_$PresenceDatabase, $ScheduleTripOccurrencesTable> {
  $$ScheduleTripOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScheduleDefinitionsTableOrderingComposer get scheduleDefinitionId {
    final $$ScheduleDefinitionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleDefinitionId,
          referencedTable: $db.scheduleDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleDefinitionsTableOrderingComposer(
                $db: $db,
                $table: $db.scheduleDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TripDefinitionsTableOrderingComposer get tripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleTripOccurrencesTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $ScheduleTripOccurrencesTable> {
  $$ScheduleTripOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$ScheduleDefinitionsTableAnnotationComposer get scheduleDefinitionId {
    final $$ScheduleDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleDefinitionId,
          referencedTable: $db.scheduleDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduleDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TripDefinitionsTableAnnotationComposer get tripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> traceTripOccurrences<T extends Object>(
    Expression<T> Function($$ExecutionTraceEventsTableAnnotationComposer a) f,
  ) {
    final $$ExecutionTraceEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.executionTraceEvents,
          getReferencedColumn: (t) => t.tripOccurrenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExecutionTraceEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.executionTraceEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> traceSelectedDestinationOccurrences<T extends Object>(
    Expression<T> Function($$ExecutionTraceEventsTableAnnotationComposer a) f,
  ) {
    final $$ExecutionTraceEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.executionTraceEvents,
          getReferencedColumn: (t) => t.selectedDestinationTripOccurrenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExecutionTraceEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.executionTraceEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScheduleTripOccurrencesTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $ScheduleTripOccurrencesTable,
          ScheduleTripOccurrenceRow,
          $$ScheduleTripOccurrencesTableFilterComposer,
          $$ScheduleTripOccurrencesTableOrderingComposer,
          $$ScheduleTripOccurrencesTableAnnotationComposer,
          $$ScheduleTripOccurrencesTableCreateCompanionBuilder,
          $$ScheduleTripOccurrencesTableUpdateCompanionBuilder,
          (ScheduleTripOccurrenceRow, $$ScheduleTripOccurrencesTableReferences),
          ScheduleTripOccurrenceRow,
          PrefetchHooks Function({
            bool scheduleDefinitionId,
            bool tripDefinitionId,
            bool traceTripOccurrences,
            bool traceSelectedDestinationOccurrences,
          })
        > {
  $$ScheduleTripOccurrencesTableTableManager(
    _$PresenceDatabase db,
    $ScheduleTripOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleTripOccurrencesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScheduleTripOccurrencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduleTripOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> position = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> scheduleDefinitionId = const Value.absent(),
                Value<int> tripDefinitionId = const Value.absent(),
              }) => ScheduleTripOccurrencesCompanion(
                position: position,
                id: id,
                scheduleDefinitionId: scheduleDefinitionId,
                tripDefinitionId: tripDefinitionId,
              ),
          createCompanionCallback:
              ({
                required int position,
                Value<int> id = const Value.absent(),
                required int scheduleDefinitionId,
                required int tripDefinitionId,
              }) => ScheduleTripOccurrencesCompanion.insert(
                position: position,
                id: id,
                scheduleDefinitionId: scheduleDefinitionId,
                tripDefinitionId: tripDefinitionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduleTripOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                scheduleDefinitionId = false,
                tripDefinitionId = false,
                traceTripOccurrences = false,
                traceSelectedDestinationOccurrences = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (traceTripOccurrences) db.executionTraceEvents,
                    if (traceSelectedDestinationOccurrences)
                      db.executionTraceEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (scheduleDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.scheduleDefinitionId,
                                    referencedTable:
                                        $$ScheduleTripOccurrencesTableReferences
                                            ._scheduleDefinitionIdTable(db),
                                    referencedColumn:
                                        $$ScheduleTripOccurrencesTableReferences
                                            ._scheduleDefinitionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (tripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripDefinitionId,
                                    referencedTable:
                                        $$ScheduleTripOccurrencesTableReferences
                                            ._tripDefinitionIdTable(db),
                                    referencedColumn:
                                        $$ScheduleTripOccurrencesTableReferences
                                            ._tripDefinitionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (traceTripOccurrences)
                        await $_getPrefetchedData<
                          ScheduleTripOccurrenceRow,
                          $ScheduleTripOccurrencesTable,
                          ExecutionTraceEventRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ScheduleTripOccurrencesTableReferences
                                  ._traceTripOccurrencesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScheduleTripOccurrencesTableReferences(
                                db,
                                table,
                                p0,
                              ).traceTripOccurrences,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripOccurrenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (traceSelectedDestinationOccurrences)
                        await $_getPrefetchedData<
                          ScheduleTripOccurrenceRow,
                          $ScheduleTripOccurrencesTable,
                          ExecutionTraceEventRow
                        >(
                          currentTable: table,
                          referencedTable:
                              $$ScheduleTripOccurrencesTableReferences
                                  ._traceSelectedDestinationOccurrencesTable(
                                    db,
                                  ),
                          managerFromTypedResult: (p0) =>
                              $$ScheduleTripOccurrencesTableReferences(
                                db,
                                table,
                                p0,
                              ).traceSelectedDestinationOccurrences,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.selectedDestinationTripOccurrenceId ==
                                    item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ScheduleTripOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $ScheduleTripOccurrencesTable,
      ScheduleTripOccurrenceRow,
      $$ScheduleTripOccurrencesTableFilterComposer,
      $$ScheduleTripOccurrencesTableOrderingComposer,
      $$ScheduleTripOccurrencesTableAnnotationComposer,
      $$ScheduleTripOccurrencesTableCreateCompanionBuilder,
      $$ScheduleTripOccurrencesTableUpdateCompanionBuilder,
      (ScheduleTripOccurrenceRow, $$ScheduleTripOccurrencesTableReferences),
      ScheduleTripOccurrenceRow,
      PrefetchHooks Function({
        bool scheduleDefinitionId,
        bool tripDefinitionId,
        bool traceTripOccurrences,
        bool traceSelectedDestinationOccurrences,
      })
    >;
typedef $$TripStepOccurrencesTableCreateCompanionBuilder =
    TripStepOccurrencesCompanion Function({
      required int position,
      Value<int> id,
      required int tripDefinitionId,
      required int stepDefinitionId,
    });
typedef $$TripStepOccurrencesTableUpdateCompanionBuilder =
    TripStepOccurrencesCompanion Function({
      Value<int> position,
      Value<int> id,
      Value<int> tripDefinitionId,
      Value<int> stepDefinitionId,
    });

final class $$TripStepOccurrencesTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $TripStepOccurrencesTable,
          TripStepOccurrenceRow
        > {
  $$TripStepOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripDefinitionsTable _tripDefinitionIdTable(_$PresenceDatabase db) =>
      db.tripDefinitions.createAlias(
        $_aliasNameGenerator(
          db.tripStepOccurrences.tripDefinitionId,
          db.tripDefinitions.id,
        ),
      );

  $$TripDefinitionsTableProcessedTableManager get tripDefinitionId {
    final $_column = $_itemColumn<int>('trip_definition_id')!;

    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StepDefinitionsTable _stepDefinitionIdTable(_$PresenceDatabase db) =>
      db.stepDefinitions.createAlias(
        $_aliasNameGenerator(
          db.tripStepOccurrences.stepDefinitionId,
          db.stepDefinitions.id,
        ),
      );

  $$StepDefinitionsTableProcessedTableManager get stepDefinitionId {
    final $_column = $_itemColumn<int>('step_definition_id')!;

    final manager = $$StepDefinitionsTableTableManager(
      $_db,
      $_db.stepDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ExecutionTraceEventsTable,
    List<ExecutionTraceEventRow>
  >
  _executionTraceEventsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.executionTraceEvents,
        aliasName: $_aliasNameGenerator(
          db.tripStepOccurrences.id,
          db.executionTraceEvents.stepOccurrenceId,
        ),
      );

  $$ExecutionTraceEventsTableProcessedTableManager
  get executionTraceEventsRefs {
    final manager = $$ExecutionTraceEventsTableTableManager(
      $_db,
      $_db.executionTraceEvents,
    ).filter((f) => f.stepOccurrenceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _executionTraceEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripStepOccurrencesTableFilterComposer
    extends Composer<_$PresenceDatabase, $TripStepOccurrencesTable> {
  $$TripStepOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$TripDefinitionsTableFilterComposer get tripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StepDefinitionsTableFilterComposer get stepDefinitionId {
    final $$StepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> executionTraceEventsRefs(
    Expression<bool> Function($$ExecutionTraceEventsTableFilterComposer f) f,
  ) {
    final $$ExecutionTraceEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.executionTraceEvents,
      getReferencedColumn: (t) => t.stepOccurrenceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExecutionTraceEventsTableFilterComposer(
            $db: $db,
            $table: $db.executionTraceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripStepOccurrencesTableOrderingComposer
    extends Composer<_$PresenceDatabase, $TripStepOccurrencesTable> {
  $$TripStepOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripDefinitionsTableOrderingComposer get tripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StepDefinitionsTableOrderingComposer get stepDefinitionId {
    final $$StepDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripStepOccurrencesTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $TripStepOccurrencesTable> {
  $$TripStepOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$TripDefinitionsTableAnnotationComposer get tripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StepDefinitionsTableAnnotationComposer get stepDefinitionId {
    final $$StepDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> executionTraceEventsRefs<T extends Object>(
    Expression<T> Function($$ExecutionTraceEventsTableAnnotationComposer a) f,
  ) {
    final $$ExecutionTraceEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.executionTraceEvents,
          getReferencedColumn: (t) => t.stepOccurrenceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExecutionTraceEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.executionTraceEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TripStepOccurrencesTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $TripStepOccurrencesTable,
          TripStepOccurrenceRow,
          $$TripStepOccurrencesTableFilterComposer,
          $$TripStepOccurrencesTableOrderingComposer,
          $$TripStepOccurrencesTableAnnotationComposer,
          $$TripStepOccurrencesTableCreateCompanionBuilder,
          $$TripStepOccurrencesTableUpdateCompanionBuilder,
          (TripStepOccurrenceRow, $$TripStepOccurrencesTableReferences),
          TripStepOccurrenceRow,
          PrefetchHooks Function({
            bool tripDefinitionId,
            bool stepDefinitionId,
            bool executionTraceEventsRefs,
          })
        > {
  $$TripStepOccurrencesTableTableManager(
    _$PresenceDatabase db,
    $TripStepOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripStepOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripStepOccurrencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TripStepOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> position = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> tripDefinitionId = const Value.absent(),
                Value<int> stepDefinitionId = const Value.absent(),
              }) => TripStepOccurrencesCompanion(
                position: position,
                id: id,
                tripDefinitionId: tripDefinitionId,
                stepDefinitionId: stepDefinitionId,
              ),
          createCompanionCallback:
              ({
                required int position,
                Value<int> id = const Value.absent(),
                required int tripDefinitionId,
                required int stepDefinitionId,
              }) => TripStepOccurrencesCompanion.insert(
                position: position,
                id: id,
                tripDefinitionId: tripDefinitionId,
                stepDefinitionId: stepDefinitionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripStepOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripDefinitionId = false,
                stepDefinitionId = false,
                executionTraceEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (executionTraceEventsRefs) db.executionTraceEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripDefinitionId,
                                    referencedTable:
                                        $$TripStepOccurrencesTableReferences
                                            ._tripDefinitionIdTable(db),
                                    referencedColumn:
                                        $$TripStepOccurrencesTableReferences
                                            ._tripDefinitionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (stepDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stepDefinitionId,
                                    referencedTable:
                                        $$TripStepOccurrencesTableReferences
                                            ._stepDefinitionIdTable(db),
                                    referencedColumn:
                                        $$TripStepOccurrencesTableReferences
                                            ._stepDefinitionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (executionTraceEventsRefs)
                        await $_getPrefetchedData<
                          TripStepOccurrenceRow,
                          $TripStepOccurrencesTable,
                          ExecutionTraceEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripStepOccurrencesTableReferences
                              ._executionTraceEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripStepOccurrencesTableReferences(
                                db,
                                table,
                                p0,
                              ).executionTraceEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepOccurrenceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripStepOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $TripStepOccurrencesTable,
      TripStepOccurrenceRow,
      $$TripStepOccurrencesTableFilterComposer,
      $$TripStepOccurrencesTableOrderingComposer,
      $$TripStepOccurrencesTableAnnotationComposer,
      $$TripStepOccurrencesTableCreateCompanionBuilder,
      $$TripStepOccurrencesTableUpdateCompanionBuilder,
      (TripStepOccurrenceRow, $$TripStepOccurrencesTableReferences),
      TripStepOccurrenceRow,
      PrefetchHooks Function({
        bool tripDefinitionId,
        bool stepDefinitionId,
        bool executionTraceEventsRefs,
      })
    >;
typedef $$TellStepDefinitionsTableCreateCompanionBuilder =
    TellStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      required String stepText,
    });
typedef $$TellStepDefinitionsTableUpdateCompanionBuilder =
    TellStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      Value<String> stepText,
    });

final class $$TellStepDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $TellStepDefinitionsTable,
          TellStepDefinitionRow
        > {
  $$TellStepDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StepDefinitionsTable _stepDefinitionIdTable(_$PresenceDatabase db) =>
      db.stepDefinitions.createAlias(
        $_aliasNameGenerator(
          db.tellStepDefinitions.stepDefinitionId,
          db.stepDefinitions.id,
        ),
      );

  $$StepDefinitionsTableProcessedTableManager get stepDefinitionId {
    final $_column = $_itemColumn<int>('step_definition_id')!;

    final manager = $$StepDefinitionsTableTableManager(
      $_db,
      $_db.stepDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TellStepDefinitionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $TellStepDefinitionsTable> {
  $$TellStepDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stepText => $composableBuilder(
    column: $table.stepText,
    builder: (column) => ColumnFilters(column),
  );

  $$StepDefinitionsTableFilterComposer get stepDefinitionId {
    final $$StepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TellStepDefinitionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $TellStepDefinitionsTable> {
  $$TellStepDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stepText => $composableBuilder(
    column: $table.stepText,
    builder: (column) => ColumnOrderings(column),
  );

  $$StepDefinitionsTableOrderingComposer get stepDefinitionId {
    final $$StepDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TellStepDefinitionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $TellStepDefinitionsTable> {
  $$TellStepDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stepText =>
      $composableBuilder(column: $table.stepText, builder: (column) => column);

  $$StepDefinitionsTableAnnotationComposer get stepDefinitionId {
    final $$StepDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TellStepDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $TellStepDefinitionsTable,
          TellStepDefinitionRow,
          $$TellStepDefinitionsTableFilterComposer,
          $$TellStepDefinitionsTableOrderingComposer,
          $$TellStepDefinitionsTableAnnotationComposer,
          $$TellStepDefinitionsTableCreateCompanionBuilder,
          $$TellStepDefinitionsTableUpdateCompanionBuilder,
          (TellStepDefinitionRow, $$TellStepDefinitionsTableReferences),
          TellStepDefinitionRow,
          PrefetchHooks Function({bool stepDefinitionId})
        > {
  $$TellStepDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $TellStepDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TellStepDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TellStepDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TellStepDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                Value<String> stepText = const Value.absent(),
              }) => TellStepDefinitionsCompanion(
                stepDefinitionId: stepDefinitionId,
                stepText: stepText,
              ),
          createCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                required String stepText,
              }) => TellStepDefinitionsCompanion.insert(
                stepDefinitionId: stepDefinitionId,
                stepText: stepText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TellStepDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stepDefinitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (stepDefinitionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stepDefinitionId,
                                referencedTable:
                                    $$TellStepDefinitionsTableReferences
                                        ._stepDefinitionIdTable(db),
                                referencedColumn:
                                    $$TellStepDefinitionsTableReferences
                                        ._stepDefinitionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TellStepDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $TellStepDefinitionsTable,
      TellStepDefinitionRow,
      $$TellStepDefinitionsTableFilterComposer,
      $$TellStepDefinitionsTableOrderingComposer,
      $$TellStepDefinitionsTableAnnotationComposer,
      $$TellStepDefinitionsTableCreateCompanionBuilder,
      $$TellStepDefinitionsTableUpdateCompanionBuilder,
      (TellStepDefinitionRow, $$TellStepDefinitionsTableReferences),
      TellStepDefinitionRow,
      PrefetchHooks Function({bool stepDefinitionId})
    >;
typedef $$FixedDestinationStepDefinitionsTableCreateCompanionBuilder =
    FixedDestinationStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      required int destinationTripDefinitionId,
    });
typedef $$FixedDestinationStepDefinitionsTableUpdateCompanionBuilder =
    FixedDestinationStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      Value<int> destinationTripDefinitionId,
    });

final class $$FixedDestinationStepDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $FixedDestinationStepDefinitionsTable,
          FixedDestinationStepDefinitionRow
        > {
  $$FixedDestinationStepDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StepDefinitionsTable _stepDefinitionIdTable(_$PresenceDatabase db) =>
      db.stepDefinitions.createAlias(
        $_aliasNameGenerator(
          db.fixedDestinationStepDefinitions.stepDefinitionId,
          db.stepDefinitions.id,
        ),
      );

  $$StepDefinitionsTableProcessedTableManager get stepDefinitionId {
    final $_column = $_itemColumn<int>('step_definition_id')!;

    final manager = $$StepDefinitionsTableTableManager(
      $_db,
      $_db.stepDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripDefinitionsTable _destinationTripDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.tripDefinitions.createAlias(
    $_aliasNameGenerator(
      db.fixedDestinationStepDefinitions.destinationTripDefinitionId,
      db.tripDefinitions.id,
    ),
  );

  $$TripDefinitionsTableProcessedTableManager get destinationTripDefinitionId {
    final $_column = $_itemColumn<int>('destination_trip_definition_id')!;

    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _destinationTripDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FixedDestinationStepDefinitionsTableFilterComposer
    extends
        Composer<_$PresenceDatabase, $FixedDestinationStepDefinitionsTable> {
  $$FixedDestinationStepDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableFilterComposer get stepDefinitionId {
    final $$StepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableFilterComposer get destinationTripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedDestinationStepDefinitionsTableOrderingComposer
    extends
        Composer<_$PresenceDatabase, $FixedDestinationStepDefinitionsTable> {
  $$FixedDestinationStepDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableOrderingComposer get stepDefinitionId {
    final $$StepDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableOrderingComposer get destinationTripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedDestinationStepDefinitionsTableAnnotationComposer
    extends
        Composer<_$PresenceDatabase, $FixedDestinationStepDefinitionsTable> {
  $$FixedDestinationStepDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableAnnotationComposer get stepDefinitionId {
    final $$StepDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableAnnotationComposer get destinationTripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedDestinationStepDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $FixedDestinationStepDefinitionsTable,
          FixedDestinationStepDefinitionRow,
          $$FixedDestinationStepDefinitionsTableFilterComposer,
          $$FixedDestinationStepDefinitionsTableOrderingComposer,
          $$FixedDestinationStepDefinitionsTableAnnotationComposer,
          $$FixedDestinationStepDefinitionsTableCreateCompanionBuilder,
          $$FixedDestinationStepDefinitionsTableUpdateCompanionBuilder,
          (
            FixedDestinationStepDefinitionRow,
            $$FixedDestinationStepDefinitionsTableReferences,
          ),
          FixedDestinationStepDefinitionRow,
          PrefetchHooks Function({
            bool stepDefinitionId,
            bool destinationTripDefinitionId,
          })
        > {
  $$FixedDestinationStepDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $FixedDestinationStepDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixedDestinationStepDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FixedDestinationStepDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FixedDestinationStepDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                Value<int> destinationTripDefinitionId = const Value.absent(),
              }) => FixedDestinationStepDefinitionsCompanion(
                stepDefinitionId: stepDefinitionId,
                destinationTripDefinitionId: destinationTripDefinitionId,
              ),
          createCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                required int destinationTripDefinitionId,
              }) => FixedDestinationStepDefinitionsCompanion.insert(
                stepDefinitionId: stepDefinitionId,
                destinationTripDefinitionId: destinationTripDefinitionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FixedDestinationStepDefinitionsTableReferences(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                stepDefinitionId = false,
                destinationTripDefinitionId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (stepDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stepDefinitionId,
                                    referencedTable:
                                        $$FixedDestinationStepDefinitionsTableReferences
                                            ._stepDefinitionIdTable(db),
                                    referencedColumn:
                                        $$FixedDestinationStepDefinitionsTableReferences
                                            ._stepDefinitionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (destinationTripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.destinationTripDefinitionId,
                                    referencedTable:
                                        $$FixedDestinationStepDefinitionsTableReferences
                                            ._destinationTripDefinitionIdTable(
                                              db,
                                            ),
                                    referencedColumn:
                                        $$FixedDestinationStepDefinitionsTableReferences
                                            ._destinationTripDefinitionIdTable(
                                              db,
                                            )
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$FixedDestinationStepDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $FixedDestinationStepDefinitionsTable,
      FixedDestinationStepDefinitionRow,
      $$FixedDestinationStepDefinitionsTableFilterComposer,
      $$FixedDestinationStepDefinitionsTableOrderingComposer,
      $$FixedDestinationStepDefinitionsTableAnnotationComposer,
      $$FixedDestinationStepDefinitionsTableCreateCompanionBuilder,
      $$FixedDestinationStepDefinitionsTableUpdateCompanionBuilder,
      (
        FixedDestinationStepDefinitionRow,
        $$FixedDestinationStepDefinitionsTableReferences,
      ),
      FixedDestinationStepDefinitionRow,
      PrefetchHooks Function({
        bool stepDefinitionId,
        bool destinationTripDefinitionId,
      })
    >;
typedef $$FdaTestStepDefinitionsTableCreateCompanionBuilder =
    FdaTestStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      Value<int?> presentDestinationTripDefinitionId,
      Value<int?> absentDestinationTripDefinitionId,
    });
typedef $$FdaTestStepDefinitionsTableUpdateCompanionBuilder =
    FdaTestStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      Value<int?> presentDestinationTripDefinitionId,
      Value<int?> absentDestinationTripDefinitionId,
    });

final class $$FdaTestStepDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $FdaTestStepDefinitionsTable,
          FdaTestStepDefinitionRow
        > {
  $$FdaTestStepDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StepDefinitionsTable _stepDefinitionIdTable(_$PresenceDatabase db) =>
      db.stepDefinitions.createAlias(
        $_aliasNameGenerator(
          db.fdaTestStepDefinitions.stepDefinitionId,
          db.stepDefinitions.id,
        ),
      );

  $$StepDefinitionsTableProcessedTableManager get stepDefinitionId {
    final $_column = $_itemColumn<int>('step_definition_id')!;

    final manager = $$StepDefinitionsTableTableManager(
      $_db,
      $_db.stepDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripDefinitionsTable _presentDestinationTripDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.tripDefinitions.createAlias(
    $_aliasNameGenerator(
      db.fdaTestStepDefinitions.presentDestinationTripDefinitionId,
      db.tripDefinitions.id,
    ),
  );

  $$TripDefinitionsTableProcessedTableManager?
  get presentDestinationTripDefinitionId {
    final $_column = $_itemColumn<int>(
      'present_destination_trip_definition_id',
    );
    if ($_column == null) return null;
    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _presentDestinationTripDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripDefinitionsTable _absentDestinationTripDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.tripDefinitions.createAlias(
    $_aliasNameGenerator(
      db.fdaTestStepDefinitions.absentDestinationTripDefinitionId,
      db.tripDefinitions.id,
    ),
  );

  $$TripDefinitionsTableProcessedTableManager?
  get absentDestinationTripDefinitionId {
    final $_column = $_itemColumn<int>('absent_destination_trip_definition_id');
    if ($_column == null) return null;
    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _absentDestinationTripDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FdaTestStepDefinitionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $FdaTestStepDefinitionsTable> {
  $$FdaTestStepDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableFilterComposer get stepDefinitionId {
    final $$StepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableFilterComposer get presentDestinationTripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presentDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableFilterComposer get absentDestinationTripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.absentDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FdaTestStepDefinitionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $FdaTestStepDefinitionsTable> {
  $$FdaTestStepDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableOrderingComposer get stepDefinitionId {
    final $$StepDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableOrderingComposer
  get presentDestinationTripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presentDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableOrderingComposer get absentDestinationTripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.absentDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FdaTestStepDefinitionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $FdaTestStepDefinitionsTable> {
  $$FdaTestStepDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableAnnotationComposer get stepDefinitionId {
    final $$StepDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableAnnotationComposer
  get presentDestinationTripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.presentDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableAnnotationComposer
  get absentDestinationTripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.absentDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FdaTestStepDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $FdaTestStepDefinitionsTable,
          FdaTestStepDefinitionRow,
          $$FdaTestStepDefinitionsTableFilterComposer,
          $$FdaTestStepDefinitionsTableOrderingComposer,
          $$FdaTestStepDefinitionsTableAnnotationComposer,
          $$FdaTestStepDefinitionsTableCreateCompanionBuilder,
          $$FdaTestStepDefinitionsTableUpdateCompanionBuilder,
          (FdaTestStepDefinitionRow, $$FdaTestStepDefinitionsTableReferences),
          FdaTestStepDefinitionRow,
          PrefetchHooks Function({
            bool stepDefinitionId,
            bool presentDestinationTripDefinitionId,
            bool absentDestinationTripDefinitionId,
          })
        > {
  $$FdaTestStepDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $FdaTestStepDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FdaTestStepDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FdaTestStepDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FdaTestStepDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                Value<int?> presentDestinationTripDefinitionId =
                    const Value.absent(),
                Value<int?> absentDestinationTripDefinitionId =
                    const Value.absent(),
              }) => FdaTestStepDefinitionsCompanion(
                stepDefinitionId: stepDefinitionId,
                presentDestinationTripDefinitionId:
                    presentDestinationTripDefinitionId,
                absentDestinationTripDefinitionId:
                    absentDestinationTripDefinitionId,
              ),
          createCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                Value<int?> presentDestinationTripDefinitionId =
                    const Value.absent(),
                Value<int?> absentDestinationTripDefinitionId =
                    const Value.absent(),
              }) => FdaTestStepDefinitionsCompanion.insert(
                stepDefinitionId: stepDefinitionId,
                presentDestinationTripDefinitionId:
                    presentDestinationTripDefinitionId,
                absentDestinationTripDefinitionId:
                    absentDestinationTripDefinitionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FdaTestStepDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                stepDefinitionId = false,
                presentDestinationTripDefinitionId = false,
                absentDestinationTripDefinitionId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (stepDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stepDefinitionId,
                                    referencedTable:
                                        $$FdaTestStepDefinitionsTableReferences
                                            ._stepDefinitionIdTable(db),
                                    referencedColumn:
                                        $$FdaTestStepDefinitionsTableReferences
                                            ._stepDefinitionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (presentDestinationTripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table
                                        .presentDestinationTripDefinitionId,
                                    referencedTable:
                                        $$FdaTestStepDefinitionsTableReferences
                                            ._presentDestinationTripDefinitionIdTable(
                                              db,
                                            ),
                                    referencedColumn:
                                        $$FdaTestStepDefinitionsTableReferences
                                            ._presentDestinationTripDefinitionIdTable(
                                              db,
                                            )
                                            .id,
                                  )
                                  as T;
                        }
                        if (absentDestinationTripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.absentDestinationTripDefinitionId,
                                    referencedTable:
                                        $$FdaTestStepDefinitionsTableReferences
                                            ._absentDestinationTripDefinitionIdTable(
                                              db,
                                            ),
                                    referencedColumn:
                                        $$FdaTestStepDefinitionsTableReferences
                                            ._absentDestinationTripDefinitionIdTable(
                                              db,
                                            )
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$FdaTestStepDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $FdaTestStepDefinitionsTable,
      FdaTestStepDefinitionRow,
      $$FdaTestStepDefinitionsTableFilterComposer,
      $$FdaTestStepDefinitionsTableOrderingComposer,
      $$FdaTestStepDefinitionsTableAnnotationComposer,
      $$FdaTestStepDefinitionsTableCreateCompanionBuilder,
      $$FdaTestStepDefinitionsTableUpdateCompanionBuilder,
      (FdaTestStepDefinitionRow, $$FdaTestStepDefinitionsTableReferences),
      FdaTestStepDefinitionRow,
      PrefetchHooks Function({
        bool stepDefinitionId,
        bool presentDestinationTripDefinitionId,
        bool absentDestinationTripDefinitionId,
      })
    >;
typedef $$ContactsSourceReadinessStepDefinitionsTableCreateCompanionBuilder =
    ContactsSourceReadinessStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      Value<int?> availableDestinationTripDefinitionId,
      Value<int?> unavailableDestinationTripDefinitionId,
    });
typedef $$ContactsSourceReadinessStepDefinitionsTableUpdateCompanionBuilder =
    ContactsSourceReadinessStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      Value<int?> availableDestinationTripDefinitionId,
      Value<int?> unavailableDestinationTripDefinitionId,
    });

final class $$ContactsSourceReadinessStepDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $ContactsSourceReadinessStepDefinitionsTable,
          ContactsSourceReadinessStepDefinitionRow
        > {
  $$ContactsSourceReadinessStepDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StepDefinitionsTable _stepDefinitionIdTable(_$PresenceDatabase db) =>
      db.stepDefinitions.createAlias(
        $_aliasNameGenerator(
          db.contactsSourceReadinessStepDefinitions.stepDefinitionId,
          db.stepDefinitions.id,
        ),
      );

  $$StepDefinitionsTableProcessedTableManager get stepDefinitionId {
    final $_column = $_itemColumn<int>('step_definition_id')!;

    final manager = $$StepDefinitionsTableTableManager(
      $_db,
      $_db.stepDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripDefinitionsTable _availableDestinationTripDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.tripDefinitions.createAlias(
    $_aliasNameGenerator(
      db
          .contactsSourceReadinessStepDefinitions
          .availableDestinationTripDefinitionId,
      db.tripDefinitions.id,
    ),
  );

  $$TripDefinitionsTableProcessedTableManager?
  get availableDestinationTripDefinitionId {
    final $_column = $_itemColumn<int>(
      'available_destination_trip_definition_id',
    );
    if ($_column == null) return null;
    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _availableDestinationTripDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripDefinitionsTable _unavailableDestinationTripDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.tripDefinitions.createAlias(
    $_aliasNameGenerator(
      db
          .contactsSourceReadinessStepDefinitions
          .unavailableDestinationTripDefinitionId,
      db.tripDefinitions.id,
    ),
  );

  $$TripDefinitionsTableProcessedTableManager?
  get unavailableDestinationTripDefinitionId {
    final $_column = $_itemColumn<int>(
      'unavailable_destination_trip_definition_id',
    );
    if ($_column == null) return null;
    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _unavailableDestinationTripDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ContactsSourceReadinessStepDefinitionsTableFilterComposer
    extends
        Composer<
          _$PresenceDatabase,
          $ContactsSourceReadinessStepDefinitionsTable
        > {
  $$ContactsSourceReadinessStepDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableFilterComposer get stepDefinitionId {
    final $$StepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableFilterComposer
  get availableDestinationTripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.availableDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableFilterComposer
  get unavailableDestinationTripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unavailableDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactsSourceReadinessStepDefinitionsTableOrderingComposer
    extends
        Composer<
          _$PresenceDatabase,
          $ContactsSourceReadinessStepDefinitionsTable
        > {
  $$ContactsSourceReadinessStepDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableOrderingComposer get stepDefinitionId {
    final $$StepDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableOrderingComposer
  get availableDestinationTripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.availableDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableOrderingComposer
  get unavailableDestinationTripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unavailableDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer
    extends
        Composer<
          _$PresenceDatabase,
          $ContactsSourceReadinessStepDefinitionsTable
        > {
  $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableAnnotationComposer get stepDefinitionId {
    final $$StepDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableAnnotationComposer
  get availableDestinationTripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.availableDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableAnnotationComposer
  get unavailableDestinationTripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unavailableDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactsSourceReadinessStepDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $ContactsSourceReadinessStepDefinitionsTable,
          ContactsSourceReadinessStepDefinitionRow,
          $$ContactsSourceReadinessStepDefinitionsTableFilterComposer,
          $$ContactsSourceReadinessStepDefinitionsTableOrderingComposer,
          $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer,
          $$ContactsSourceReadinessStepDefinitionsTableCreateCompanionBuilder,
          $$ContactsSourceReadinessStepDefinitionsTableUpdateCompanionBuilder,
          (
            ContactsSourceReadinessStepDefinitionRow,
            $$ContactsSourceReadinessStepDefinitionsTableReferences,
          ),
          ContactsSourceReadinessStepDefinitionRow,
          PrefetchHooks Function({
            bool stepDefinitionId,
            bool availableDestinationTripDefinitionId,
            bool unavailableDestinationTripDefinitionId,
          })
        > {
  $$ContactsSourceReadinessStepDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $ContactsSourceReadinessStepDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsSourceReadinessStepDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ContactsSourceReadinessStepDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                Value<int?> availableDestinationTripDefinitionId =
                    const Value.absent(),
                Value<int?> unavailableDestinationTripDefinitionId =
                    const Value.absent(),
              }) => ContactsSourceReadinessStepDefinitionsCompanion(
                stepDefinitionId: stepDefinitionId,
                availableDestinationTripDefinitionId:
                    availableDestinationTripDefinitionId,
                unavailableDestinationTripDefinitionId:
                    unavailableDestinationTripDefinitionId,
              ),
          createCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                Value<int?> availableDestinationTripDefinitionId =
                    const Value.absent(),
                Value<int?> unavailableDestinationTripDefinitionId =
                    const Value.absent(),
              }) => ContactsSourceReadinessStepDefinitionsCompanion.insert(
                stepDefinitionId: stepDefinitionId,
                availableDestinationTripDefinitionId:
                    availableDestinationTripDefinitionId,
                unavailableDestinationTripDefinitionId:
                    unavailableDestinationTripDefinitionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactsSourceReadinessStepDefinitionsTableReferences(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                stepDefinitionId = false,
                availableDestinationTripDefinitionId = false,
                unavailableDestinationTripDefinitionId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (stepDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stepDefinitionId,
                                    referencedTable:
                                        $$ContactsSourceReadinessStepDefinitionsTableReferences
                                            ._stepDefinitionIdTable(db),
                                    referencedColumn:
                                        $$ContactsSourceReadinessStepDefinitionsTableReferences
                                            ._stepDefinitionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (availableDestinationTripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table
                                        .availableDestinationTripDefinitionId,
                                    referencedTable:
                                        $$ContactsSourceReadinessStepDefinitionsTableReferences
                                            ._availableDestinationTripDefinitionIdTable(
                                              db,
                                            ),
                                    referencedColumn:
                                        $$ContactsSourceReadinessStepDefinitionsTableReferences
                                            ._availableDestinationTripDefinitionIdTable(
                                              db,
                                            )
                                            .id,
                                  )
                                  as T;
                        }
                        if (unavailableDestinationTripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table
                                        .unavailableDestinationTripDefinitionId,
                                    referencedTable:
                                        $$ContactsSourceReadinessStepDefinitionsTableReferences
                                            ._unavailableDestinationTripDefinitionIdTable(
                                              db,
                                            ),
                                    referencedColumn:
                                        $$ContactsSourceReadinessStepDefinitionsTableReferences
                                            ._unavailableDestinationTripDefinitionIdTable(
                                              db,
                                            )
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ContactsSourceReadinessStepDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $ContactsSourceReadinessStepDefinitionsTable,
      ContactsSourceReadinessStepDefinitionRow,
      $$ContactsSourceReadinessStepDefinitionsTableFilterComposer,
      $$ContactsSourceReadinessStepDefinitionsTableOrderingComposer,
      $$ContactsSourceReadinessStepDefinitionsTableAnnotationComposer,
      $$ContactsSourceReadinessStepDefinitionsTableCreateCompanionBuilder,
      $$ContactsSourceReadinessStepDefinitionsTableUpdateCompanionBuilder,
      (
        ContactsSourceReadinessStepDefinitionRow,
        $$ContactsSourceReadinessStepDefinitionsTableReferences,
      ),
      ContactsSourceReadinessStepDefinitionRow,
      PrefetchHooks Function({
        bool stepDefinitionId,
        bool availableDestinationTripDefinitionId,
        bool unavailableDestinationTripDefinitionId,
      })
    >;
typedef $$OpenFdaSettingsStepDefinitionsTableCreateCompanionBuilder =
    OpenFdaSettingsStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
    });
typedef $$OpenFdaSettingsStepDefinitionsTableUpdateCompanionBuilder =
    OpenFdaSettingsStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
    });

final class $$OpenFdaSettingsStepDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $OpenFdaSettingsStepDefinitionsTable,
          OpenFdaSettingsStepDefinitionRow
        > {
  $$OpenFdaSettingsStepDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StepDefinitionsTable _stepDefinitionIdTable(_$PresenceDatabase db) =>
      db.stepDefinitions.createAlias(
        $_aliasNameGenerator(
          db.openFdaSettingsStepDefinitions.stepDefinitionId,
          db.stepDefinitions.id,
        ),
      );

  $$StepDefinitionsTableProcessedTableManager get stepDefinitionId {
    final $_column = $_itemColumn<int>('step_definition_id')!;

    final manager = $$StepDefinitionsTableTableManager(
      $_db,
      $_db.stepDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OpenFdaSettingsStepDefinitionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $OpenFdaSettingsStepDefinitionsTable> {
  $$OpenFdaSettingsStepDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableFilterComposer get stepDefinitionId {
    final $$StepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpenFdaSettingsStepDefinitionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $OpenFdaSettingsStepDefinitionsTable> {
  $$OpenFdaSettingsStepDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableOrderingComposer get stepDefinitionId {
    final $$StepDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpenFdaSettingsStepDefinitionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $OpenFdaSettingsStepDefinitionsTable> {
  $$OpenFdaSettingsStepDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableAnnotationComposer get stepDefinitionId {
    final $$StepDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpenFdaSettingsStepDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $OpenFdaSettingsStepDefinitionsTable,
          OpenFdaSettingsStepDefinitionRow,
          $$OpenFdaSettingsStepDefinitionsTableFilterComposer,
          $$OpenFdaSettingsStepDefinitionsTableOrderingComposer,
          $$OpenFdaSettingsStepDefinitionsTableAnnotationComposer,
          $$OpenFdaSettingsStepDefinitionsTableCreateCompanionBuilder,
          $$OpenFdaSettingsStepDefinitionsTableUpdateCompanionBuilder,
          (
            OpenFdaSettingsStepDefinitionRow,
            $$OpenFdaSettingsStepDefinitionsTableReferences,
          ),
          OpenFdaSettingsStepDefinitionRow,
          PrefetchHooks Function({bool stepDefinitionId})
        > {
  $$OpenFdaSettingsStepDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $OpenFdaSettingsStepDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpenFdaSettingsStepDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OpenFdaSettingsStepDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OpenFdaSettingsStepDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({Value<int> stepDefinitionId = const Value.absent()}) =>
                  OpenFdaSettingsStepDefinitionsCompanion(
                    stepDefinitionId: stepDefinitionId,
                  ),
          createCompanionCallback:
              ({Value<int> stepDefinitionId = const Value.absent()}) =>
                  OpenFdaSettingsStepDefinitionsCompanion.insert(
                    stepDefinitionId: stepDefinitionId,
                  ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OpenFdaSettingsStepDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stepDefinitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (stepDefinitionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stepDefinitionId,
                                referencedTable:
                                    $$OpenFdaSettingsStepDefinitionsTableReferences
                                        ._stepDefinitionIdTable(db),
                                referencedColumn:
                                    $$OpenFdaSettingsStepDefinitionsTableReferences
                                        ._stepDefinitionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OpenFdaSettingsStepDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $OpenFdaSettingsStepDefinitionsTable,
      OpenFdaSettingsStepDefinitionRow,
      $$OpenFdaSettingsStepDefinitionsTableFilterComposer,
      $$OpenFdaSettingsStepDefinitionsTableOrderingComposer,
      $$OpenFdaSettingsStepDefinitionsTableAnnotationComposer,
      $$OpenFdaSettingsStepDefinitionsTableCreateCompanionBuilder,
      $$OpenFdaSettingsStepDefinitionsTableUpdateCompanionBuilder,
      (
        OpenFdaSettingsStepDefinitionRow,
        $$OpenFdaSettingsStepDefinitionsTableReferences,
      ),
      OpenFdaSettingsStepDefinitionRow,
      PrefetchHooks Function({bool stepDefinitionId})
    >;
typedef $$TestAgentDefinitionsTableCreateCompanionBuilder =
    TestAgentDefinitionsCompanion Function({
      required String id,
      Value<int> rowid,
    });
typedef $$TestAgentDefinitionsTableUpdateCompanionBuilder =
    TestAgentDefinitionsCompanion Function({
      Value<String> id,
      Value<int> rowid,
    });

final class $$TestAgentDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $TestAgentDefinitionsTable,
          TestAgentDefinitionRow
        > {
  $$TestAgentDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $TestStepDefinitionsTable,
    List<TestStepDefinitionRow>
  >
  _testStepDefinitionsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.testStepDefinitions,
        aliasName: $_aliasNameGenerator(
          db.testAgentDefinitions.id,
          db.testStepDefinitions.testAgentId,
        ),
      );

  $$TestStepDefinitionsTableProcessedTableManager get testStepDefinitionsRefs {
    final manager = $$TestStepDefinitionsTableTableManager(
      $_db,
      $_db.testStepDefinitions,
    ).filter((f) => f.testAgentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _testStepDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TestAgentDefinitionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $TestAgentDefinitionsTable> {
  $$TestAgentDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> testStepDefinitionsRefs(
    Expression<bool> Function($$TestStepDefinitionsTableFilterComposer f) f,
  ) {
    final $$TestStepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testStepDefinitions,
      getReferencedColumn: (t) => t.testAgentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestStepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.testStepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestAgentDefinitionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $TestAgentDefinitionsTable> {
  $$TestAgentDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestAgentDefinitionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $TestAgentDefinitionsTable> {
  $$TestAgentDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  Expression<T> testStepDefinitionsRefs<T extends Object>(
    Expression<T> Function($$TestStepDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$TestStepDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.testStepDefinitions,
          getReferencedColumn: (t) => t.testAgentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TestStepDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.testStepDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TestAgentDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $TestAgentDefinitionsTable,
          TestAgentDefinitionRow,
          $$TestAgentDefinitionsTableFilterComposer,
          $$TestAgentDefinitionsTableOrderingComposer,
          $$TestAgentDefinitionsTableAnnotationComposer,
          $$TestAgentDefinitionsTableCreateCompanionBuilder,
          $$TestAgentDefinitionsTableUpdateCompanionBuilder,
          (TestAgentDefinitionRow, $$TestAgentDefinitionsTableReferences),
          TestAgentDefinitionRow,
          PrefetchHooks Function({bool testStepDefinitionsRefs})
        > {
  $$TestAgentDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $TestAgentDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestAgentDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestAgentDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TestAgentDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TestAgentDefinitionsCompanion(id: id, rowid: rowid),
          createCompanionCallback:
              ({required String id, Value<int> rowid = const Value.absent()}) =>
                  TestAgentDefinitionsCompanion.insert(id: id, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TestAgentDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({testStepDefinitionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (testStepDefinitionsRefs) db.testStepDefinitions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (testStepDefinitionsRefs)
                    await $_getPrefetchedData<
                      TestAgentDefinitionRow,
                      $TestAgentDefinitionsTable,
                      TestStepDefinitionRow
                    >(
                      currentTable: table,
                      referencedTable: $$TestAgentDefinitionsTableReferences
                          ._testStepDefinitionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TestAgentDefinitionsTableReferences(
                            db,
                            table,
                            p0,
                          ).testStepDefinitionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.testAgentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TestAgentDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $TestAgentDefinitionsTable,
      TestAgentDefinitionRow,
      $$TestAgentDefinitionsTableFilterComposer,
      $$TestAgentDefinitionsTableOrderingComposer,
      $$TestAgentDefinitionsTableAnnotationComposer,
      $$TestAgentDefinitionsTableCreateCompanionBuilder,
      $$TestAgentDefinitionsTableUpdateCompanionBuilder,
      (TestAgentDefinitionRow, $$TestAgentDefinitionsTableReferences),
      TestAgentDefinitionRow,
      PrefetchHooks Function({bool testStepDefinitionsRefs})
    >;
typedef $$TestStepDefinitionsTableCreateCompanionBuilder =
    TestStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      required String testAgentId,
      Value<int?> trueDestinationTripDefinitionId,
      Value<int?> falseDestinationTripDefinitionId,
    });
typedef $$TestStepDefinitionsTableUpdateCompanionBuilder =
    TestStepDefinitionsCompanion Function({
      Value<int> stepDefinitionId,
      Value<String> testAgentId,
      Value<int?> trueDestinationTripDefinitionId,
      Value<int?> falseDestinationTripDefinitionId,
    });

final class $$TestStepDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $TestStepDefinitionsTable,
          TestStepDefinitionRow
        > {
  $$TestStepDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StepDefinitionsTable _stepDefinitionIdTable(_$PresenceDatabase db) =>
      db.stepDefinitions.createAlias(
        $_aliasNameGenerator(
          db.testStepDefinitions.stepDefinitionId,
          db.stepDefinitions.id,
        ),
      );

  $$StepDefinitionsTableProcessedTableManager get stepDefinitionId {
    final $_column = $_itemColumn<int>('step_definition_id')!;

    final manager = $$StepDefinitionsTableTableManager(
      $_db,
      $_db.stepDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TestAgentDefinitionsTable _testAgentIdTable(_$PresenceDatabase db) =>
      db.testAgentDefinitions.createAlias(
        $_aliasNameGenerator(
          db.testStepDefinitions.testAgentId,
          db.testAgentDefinitions.id,
        ),
      );

  $$TestAgentDefinitionsTableProcessedTableManager get testAgentId {
    final $_column = $_itemColumn<String>('test_agent_id')!;

    final manager = $$TestAgentDefinitionsTableTableManager(
      $_db,
      $_db.testAgentDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_testAgentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripDefinitionsTable _trueDestinationTripDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.tripDefinitions.createAlias(
    $_aliasNameGenerator(
      db.testStepDefinitions.trueDestinationTripDefinitionId,
      db.tripDefinitions.id,
    ),
  );

  $$TripDefinitionsTableProcessedTableManager?
  get trueDestinationTripDefinitionId {
    final $_column = $_itemColumn<int>('true_destination_trip_definition_id');
    if ($_column == null) return null;
    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _trueDestinationTripDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripDefinitionsTable _falseDestinationTripDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.tripDefinitions.createAlias(
    $_aliasNameGenerator(
      db.testStepDefinitions.falseDestinationTripDefinitionId,
      db.tripDefinitions.id,
    ),
  );

  $$TripDefinitionsTableProcessedTableManager?
  get falseDestinationTripDefinitionId {
    final $_column = $_itemColumn<int>('false_destination_trip_definition_id');
    if ($_column == null) return null;
    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _falseDestinationTripDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TestStepDefinitionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $TestStepDefinitionsTable> {
  $$TestStepDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableFilterComposer get stepDefinitionId {
    final $$StepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TestAgentDefinitionsTableFilterComposer get testAgentId {
    final $$TestAgentDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.testAgentId,
      referencedTable: $db.testAgentDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestAgentDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.testAgentDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableFilterComposer get trueDestinationTripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trueDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableFilterComposer get falseDestinationTripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.falseDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestStepDefinitionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $TestStepDefinitionsTable> {
  $$TestStepDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableOrderingComposer get stepDefinitionId {
    final $$StepDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TestAgentDefinitionsTableOrderingComposer get testAgentId {
    final $$TestAgentDefinitionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.testAgentId,
          referencedTable: $db.testAgentDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TestAgentDefinitionsTableOrderingComposer(
                $db: $db,
                $table: $db.testAgentDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TripDefinitionsTableOrderingComposer get trueDestinationTripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trueDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableOrderingComposer get falseDestinationTripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.falseDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestStepDefinitionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $TestStepDefinitionsTable> {
  $$TestStepDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableAnnotationComposer get stepDefinitionId {
    final $$StepDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TestAgentDefinitionsTableAnnotationComposer get testAgentId {
    final $$TestAgentDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.testAgentId,
          referencedTable: $db.testAgentDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TestAgentDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.testAgentDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TripDefinitionsTableAnnotationComposer get trueDestinationTripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trueDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableAnnotationComposer
  get falseDestinationTripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.falseDestinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestStepDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $TestStepDefinitionsTable,
          TestStepDefinitionRow,
          $$TestStepDefinitionsTableFilterComposer,
          $$TestStepDefinitionsTableOrderingComposer,
          $$TestStepDefinitionsTableAnnotationComposer,
          $$TestStepDefinitionsTableCreateCompanionBuilder,
          $$TestStepDefinitionsTableUpdateCompanionBuilder,
          (TestStepDefinitionRow, $$TestStepDefinitionsTableReferences),
          TestStepDefinitionRow,
          PrefetchHooks Function({
            bool stepDefinitionId,
            bool testAgentId,
            bool trueDestinationTripDefinitionId,
            bool falseDestinationTripDefinitionId,
          })
        > {
  $$TestStepDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $TestStepDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestStepDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestStepDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TestStepDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                Value<String> testAgentId = const Value.absent(),
                Value<int?> trueDestinationTripDefinitionId =
                    const Value.absent(),
                Value<int?> falseDestinationTripDefinitionId =
                    const Value.absent(),
              }) => TestStepDefinitionsCompanion(
                stepDefinitionId: stepDefinitionId,
                testAgentId: testAgentId,
                trueDestinationTripDefinitionId:
                    trueDestinationTripDefinitionId,
                falseDestinationTripDefinitionId:
                    falseDestinationTripDefinitionId,
              ),
          createCompanionCallback:
              ({
                Value<int> stepDefinitionId = const Value.absent(),
                required String testAgentId,
                Value<int?> trueDestinationTripDefinitionId =
                    const Value.absent(),
                Value<int?> falseDestinationTripDefinitionId =
                    const Value.absent(),
              }) => TestStepDefinitionsCompanion.insert(
                stepDefinitionId: stepDefinitionId,
                testAgentId: testAgentId,
                trueDestinationTripDefinitionId:
                    trueDestinationTripDefinitionId,
                falseDestinationTripDefinitionId:
                    falseDestinationTripDefinitionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TestStepDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                stepDefinitionId = false,
                testAgentId = false,
                trueDestinationTripDefinitionId = false,
                falseDestinationTripDefinitionId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (stepDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stepDefinitionId,
                                    referencedTable:
                                        $$TestStepDefinitionsTableReferences
                                            ._stepDefinitionIdTable(db),
                                    referencedColumn:
                                        $$TestStepDefinitionsTableReferences
                                            ._stepDefinitionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (testAgentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.testAgentId,
                                    referencedTable:
                                        $$TestStepDefinitionsTableReferences
                                            ._testAgentIdTable(db),
                                    referencedColumn:
                                        $$TestStepDefinitionsTableReferences
                                            ._testAgentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (trueDestinationTripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.trueDestinationTripDefinitionId,
                                    referencedTable:
                                        $$TestStepDefinitionsTableReferences
                                            ._trueDestinationTripDefinitionIdTable(
                                              db,
                                            ),
                                    referencedColumn:
                                        $$TestStepDefinitionsTableReferences
                                            ._trueDestinationTripDefinitionIdTable(
                                              db,
                                            )
                                            .id,
                                  )
                                  as T;
                        }
                        if (falseDestinationTripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.falseDestinationTripDefinitionId,
                                    referencedTable:
                                        $$TestStepDefinitionsTableReferences
                                            ._falseDestinationTripDefinitionIdTable(
                                              db,
                                            ),
                                    referencedColumn:
                                        $$TestStepDefinitionsTableReferences
                                            ._falseDestinationTripDefinitionIdTable(
                                              db,
                                            )
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TestStepDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $TestStepDefinitionsTable,
      TestStepDefinitionRow,
      $$TestStepDefinitionsTableFilterComposer,
      $$TestStepDefinitionsTableOrderingComposer,
      $$TestStepDefinitionsTableAnnotationComposer,
      $$TestStepDefinitionsTableCreateCompanionBuilder,
      $$TestStepDefinitionsTableUpdateCompanionBuilder,
      (TestStepDefinitionRow, $$TestStepDefinitionsTableReferences),
      TestStepDefinitionRow,
      PrefetchHooks Function({
        bool stepDefinitionId,
        bool testAgentId,
        bool trueDestinationTripDefinitionId,
        bool falseDestinationTripDefinitionId,
      })
    >;
typedef $$ChoiceStepDefinitionsTableCreateCompanionBuilder =
    ChoiceStepDefinitionsCompanion Function({Value<int> stepDefinitionId});
typedef $$ChoiceStepDefinitionsTableUpdateCompanionBuilder =
    ChoiceStepDefinitionsCompanion Function({Value<int> stepDefinitionId});

final class $$ChoiceStepDefinitionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $ChoiceStepDefinitionsTable,
          ChoiceStepDefinitionRow
        > {
  $$ChoiceStepDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StepDefinitionsTable _stepDefinitionIdTable(_$PresenceDatabase db) =>
      db.stepDefinitions.createAlias(
        $_aliasNameGenerator(
          db.choiceStepDefinitions.stepDefinitionId,
          db.stepDefinitions.id,
        ),
      );

  $$StepDefinitionsTableProcessedTableManager get stepDefinitionId {
    final $_column = $_itemColumn<int>('step_definition_id')!;

    final manager = $$StepDefinitionsTableTableManager(
      $_db,
      $_db.stepDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChoiceStepDefinitionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $ChoiceStepDefinitionsTable> {
  $$ChoiceStepDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableFilterComposer get stepDefinitionId {
    final $$StepDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoiceStepDefinitionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $ChoiceStepDefinitionsTable> {
  $$ChoiceStepDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableOrderingComposer get stepDefinitionId {
    final $$StepDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoiceStepDefinitionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $ChoiceStepDefinitionsTable> {
  $$ChoiceStepDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StepDefinitionsTableAnnotationComposer get stepDefinitionId {
    final $$StepDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepDefinitionId,
      referencedTable: $db.stepDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.stepDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoiceStepDefinitionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $ChoiceStepDefinitionsTable,
          ChoiceStepDefinitionRow,
          $$ChoiceStepDefinitionsTableFilterComposer,
          $$ChoiceStepDefinitionsTableOrderingComposer,
          $$ChoiceStepDefinitionsTableAnnotationComposer,
          $$ChoiceStepDefinitionsTableCreateCompanionBuilder,
          $$ChoiceStepDefinitionsTableUpdateCompanionBuilder,
          (ChoiceStepDefinitionRow, $$ChoiceStepDefinitionsTableReferences),
          ChoiceStepDefinitionRow,
          PrefetchHooks Function({bool stepDefinitionId})
        > {
  $$ChoiceStepDefinitionsTableTableManager(
    _$PresenceDatabase db,
    $ChoiceStepDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChoiceStepDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ChoiceStepDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChoiceStepDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({Value<int> stepDefinitionId = const Value.absent()}) =>
                  ChoiceStepDefinitionsCompanion(
                    stepDefinitionId: stepDefinitionId,
                  ),
          createCompanionCallback:
              ({Value<int> stepDefinitionId = const Value.absent()}) =>
                  ChoiceStepDefinitionsCompanion.insert(
                    stepDefinitionId: stepDefinitionId,
                  ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChoiceStepDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stepDefinitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (stepDefinitionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stepDefinitionId,
                                referencedTable:
                                    $$ChoiceStepDefinitionsTableReferences
                                        ._stepDefinitionIdTable(db),
                                referencedColumn:
                                    $$ChoiceStepDefinitionsTableReferences
                                        ._stepDefinitionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChoiceStepDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $ChoiceStepDefinitionsTable,
      ChoiceStepDefinitionRow,
      $$ChoiceStepDefinitionsTableFilterComposer,
      $$ChoiceStepDefinitionsTableOrderingComposer,
      $$ChoiceStepDefinitionsTableAnnotationComposer,
      $$ChoiceStepDefinitionsTableCreateCompanionBuilder,
      $$ChoiceStepDefinitionsTableUpdateCompanionBuilder,
      (ChoiceStepDefinitionRow, $$ChoiceStepDefinitionsTableReferences),
      ChoiceStepDefinitionRow,
      PrefetchHooks Function({bool stepDefinitionId})
    >;
typedef $$ChoiceStepOptionsTableCreateCompanionBuilder =
    ChoiceStepOptionsCompanion Function({
      required int position,
      required int stepDefinitionId,
      required String value,
      required String label,
      required int destinationTripDefinitionId,
      Value<int> rowid,
    });
typedef $$ChoiceStepOptionsTableUpdateCompanionBuilder =
    ChoiceStepOptionsCompanion Function({
      Value<int> position,
      Value<int> stepDefinitionId,
      Value<String> value,
      Value<String> label,
      Value<int> destinationTripDefinitionId,
      Value<int> rowid,
    });

final class $$ChoiceStepOptionsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $ChoiceStepOptionsTable,
          ChoiceStepOptionRow
        > {
  $$ChoiceStepOptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripDefinitionsTable _destinationTripDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.tripDefinitions.createAlias(
    $_aliasNameGenerator(
      db.choiceStepOptions.destinationTripDefinitionId,
      db.tripDefinitions.id,
    ),
  );

  $$TripDefinitionsTableProcessedTableManager get destinationTripDefinitionId {
    final $_column = $_itemColumn<int>('destination_trip_definition_id')!;

    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _destinationTripDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChoiceStepOptionsTableFilterComposer
    extends Composer<_$PresenceDatabase, $ChoiceStepOptionsTable> {
  $$ChoiceStepOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  $$TripDefinitionsTableFilterComposer get destinationTripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoiceStepOptionsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $ChoiceStepOptionsTable> {
  $$ChoiceStepOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripDefinitionsTableOrderingComposer get destinationTripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoiceStepOptionsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $ChoiceStepOptionsTable> {
  $$ChoiceStepOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$TripDefinitionsTableAnnotationComposer get destinationTripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoiceStepOptionsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $ChoiceStepOptionsTable,
          ChoiceStepOptionRow,
          $$ChoiceStepOptionsTableFilterComposer,
          $$ChoiceStepOptionsTableOrderingComposer,
          $$ChoiceStepOptionsTableAnnotationComposer,
          $$ChoiceStepOptionsTableCreateCompanionBuilder,
          $$ChoiceStepOptionsTableUpdateCompanionBuilder,
          (ChoiceStepOptionRow, $$ChoiceStepOptionsTableReferences),
          ChoiceStepOptionRow,
          PrefetchHooks Function({bool destinationTripDefinitionId})
        > {
  $$ChoiceStepOptionsTableTableManager(
    _$PresenceDatabase db,
    $ChoiceStepOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChoiceStepOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChoiceStepOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChoiceStepOptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> position = const Value.absent(),
                Value<int> stepDefinitionId = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> destinationTripDefinitionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChoiceStepOptionsCompanion(
                position: position,
                stepDefinitionId: stepDefinitionId,
                value: value,
                label: label,
                destinationTripDefinitionId: destinationTripDefinitionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int position,
                required int stepDefinitionId,
                required String value,
                required String label,
                required int destinationTripDefinitionId,
                Value<int> rowid = const Value.absent(),
              }) => ChoiceStepOptionsCompanion.insert(
                position: position,
                stepDefinitionId: stepDefinitionId,
                value: value,
                label: label,
                destinationTripDefinitionId: destinationTripDefinitionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChoiceStepOptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({destinationTripDefinitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (destinationTripDefinitionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn:
                                    table.destinationTripDefinitionId,
                                referencedTable:
                                    $$ChoiceStepOptionsTableReferences
                                        ._destinationTripDefinitionIdTable(db),
                                referencedColumn:
                                    $$ChoiceStepOptionsTableReferences
                                        ._destinationTripDefinitionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChoiceStepOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $ChoiceStepOptionsTable,
      ChoiceStepOptionRow,
      $$ChoiceStepOptionsTableFilterComposer,
      $$ChoiceStepOptionsTableOrderingComposer,
      $$ChoiceStepOptionsTableAnnotationComposer,
      $$ChoiceStepOptionsTableCreateCompanionBuilder,
      $$ChoiceStepOptionsTableUpdateCompanionBuilder,
      (ChoiceStepOptionRow, $$ChoiceStepOptionsTableReferences),
      ChoiceStepOptionRow,
      PrefetchHooks Function({bool destinationTripDefinitionId})
    >;
typedef $$ScheduleRunsTableCreateCompanionBuilder =
    ScheduleRunsCompanion Function({
      Value<int> id,
      required int scheduleDefinitionId,
      Value<int?> currentTripOccurrenceId,
    });
typedef $$ScheduleRunsTableUpdateCompanionBuilder =
    ScheduleRunsCompanion Function({
      Value<int> id,
      Value<int> scheduleDefinitionId,
      Value<int?> currentTripOccurrenceId,
    });

final class $$ScheduleRunsTableReferences
    extends
        BaseReferences<_$PresenceDatabase, $ScheduleRunsTable, ScheduleRunRow> {
  $$ScheduleRunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleDefinitionsTable _scheduleDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.scheduleDefinitions.createAlias(
    $_aliasNameGenerator(
      db.scheduleRuns.scheduleDefinitionId,
      db.scheduleDefinitions.id,
    ),
  );

  $$ScheduleDefinitionsTableProcessedTableManager get scheduleDefinitionId {
    final $_column = $_itemColumn<int>('schedule_definition_id')!;

    final manager = $$ScheduleDefinitionsTableTableManager(
      $_db,
      $_db.scheduleDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _scheduleDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ExecutionTraceEventsTable,
    List<ExecutionTraceEventRow>
  >
  _executionTraceEventsRefsTable(_$PresenceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.executionTraceEvents,
        aliasName: $_aliasNameGenerator(
          db.scheduleRuns.id,
          db.executionTraceEvents.scheduleRunId,
        ),
      );

  $$ExecutionTraceEventsTableProcessedTableManager
  get executionTraceEventsRefs {
    final manager = $$ExecutionTraceEventsTableTableManager(
      $_db,
      $_db.executionTraceEvents,
    ).filter((f) => f.scheduleRunId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _executionTraceEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScheduleRunsTableFilterComposer
    extends Composer<_$PresenceDatabase, $ScheduleRunsTable> {
  $$ScheduleRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentTripOccurrenceId => $composableBuilder(
    column: $table.currentTripOccurrenceId,
    builder: (column) => ColumnFilters(column),
  );

  $$ScheduleDefinitionsTableFilterComposer get scheduleDefinitionId {
    final $$ScheduleDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleDefinitionId,
      referencedTable: $db.scheduleDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> executionTraceEventsRefs(
    Expression<bool> Function($$ExecutionTraceEventsTableFilterComposer f) f,
  ) {
    final $$ExecutionTraceEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.executionTraceEvents,
      getReferencedColumn: (t) => t.scheduleRunId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExecutionTraceEventsTableFilterComposer(
            $db: $db,
            $table: $db.executionTraceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScheduleRunsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $ScheduleRunsTable> {
  $$ScheduleRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentTripOccurrenceId => $composableBuilder(
    column: $table.currentTripOccurrenceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScheduleDefinitionsTableOrderingComposer get scheduleDefinitionId {
    final $$ScheduleDefinitionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleDefinitionId,
          referencedTable: $db.scheduleDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleDefinitionsTableOrderingComposer(
                $db: $db,
                $table: $db.scheduleDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ScheduleRunsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $ScheduleRunsTable> {
  $$ScheduleRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentTripOccurrenceId => $composableBuilder(
    column: $table.currentTripOccurrenceId,
    builder: (column) => column,
  );

  $$ScheduleDefinitionsTableAnnotationComposer get scheduleDefinitionId {
    final $$ScheduleDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleDefinitionId,
          referencedTable: $db.scheduleDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduleDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> executionTraceEventsRefs<T extends Object>(
    Expression<T> Function($$ExecutionTraceEventsTableAnnotationComposer a) f,
  ) {
    final $$ExecutionTraceEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.executionTraceEvents,
          getReferencedColumn: (t) => t.scheduleRunId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExecutionTraceEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.executionTraceEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScheduleRunsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $ScheduleRunsTable,
          ScheduleRunRow,
          $$ScheduleRunsTableFilterComposer,
          $$ScheduleRunsTableOrderingComposer,
          $$ScheduleRunsTableAnnotationComposer,
          $$ScheduleRunsTableCreateCompanionBuilder,
          $$ScheduleRunsTableUpdateCompanionBuilder,
          (ScheduleRunRow, $$ScheduleRunsTableReferences),
          ScheduleRunRow,
          PrefetchHooks Function({
            bool scheduleDefinitionId,
            bool executionTraceEventsRefs,
          })
        > {
  $$ScheduleRunsTableTableManager(
    _$PresenceDatabase db,
    $ScheduleRunsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scheduleDefinitionId = const Value.absent(),
                Value<int?> currentTripOccurrenceId = const Value.absent(),
              }) => ScheduleRunsCompanion(
                id: id,
                scheduleDefinitionId: scheduleDefinitionId,
                currentTripOccurrenceId: currentTripOccurrenceId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scheduleDefinitionId,
                Value<int?> currentTripOccurrenceId = const Value.absent(),
              }) => ScheduleRunsCompanion.insert(
                id: id,
                scheduleDefinitionId: scheduleDefinitionId,
                currentTripOccurrenceId: currentTripOccurrenceId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduleRunsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                scheduleDefinitionId = false,
                executionTraceEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (executionTraceEventsRefs) db.executionTraceEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (scheduleDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.scheduleDefinitionId,
                                    referencedTable:
                                        $$ScheduleRunsTableReferences
                                            ._scheduleDefinitionIdTable(db),
                                    referencedColumn:
                                        $$ScheduleRunsTableReferences
                                            ._scheduleDefinitionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (executionTraceEventsRefs)
                        await $_getPrefetchedData<
                          ScheduleRunRow,
                          $ScheduleRunsTable,
                          ExecutionTraceEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$ScheduleRunsTableReferences
                              ._executionTraceEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ScheduleRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).executionTraceEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleRunId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ScheduleRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $ScheduleRunsTable,
      ScheduleRunRow,
      $$ScheduleRunsTableFilterComposer,
      $$ScheduleRunsTableOrderingComposer,
      $$ScheduleRunsTableAnnotationComposer,
      $$ScheduleRunsTableCreateCompanionBuilder,
      $$ScheduleRunsTableUpdateCompanionBuilder,
      (ScheduleRunRow, $$ScheduleRunsTableReferences),
      ScheduleRunRow,
      PrefetchHooks Function({
        bool scheduleDefinitionId,
        bool executionTraceEventsRefs,
      })
    >;
typedef $$ExecutionTraceEventsTableCreateCompanionBuilder =
    ExecutionTraceEventsCompanion Function({
      required int sequence,
      required String eventType,
      required int occurredAtUtcUs,
      Value<int> id,
      required int scheduleRunId,
      Value<int?> tripOccurrenceId,
      Value<int?> stepOccurrenceId,
      Value<int?> routingResultTripDefinitionId,
      Value<int?> selectedDestinationTripOccurrenceId,
    });
typedef $$ExecutionTraceEventsTableUpdateCompanionBuilder =
    ExecutionTraceEventsCompanion Function({
      Value<int> sequence,
      Value<String> eventType,
      Value<int> occurredAtUtcUs,
      Value<int> id,
      Value<int> scheduleRunId,
      Value<int?> tripOccurrenceId,
      Value<int?> stepOccurrenceId,
      Value<int?> routingResultTripDefinitionId,
      Value<int?> selectedDestinationTripOccurrenceId,
    });

final class $$ExecutionTraceEventsTableReferences
    extends
        BaseReferences<
          _$PresenceDatabase,
          $ExecutionTraceEventsTable,
          ExecutionTraceEventRow
        > {
  $$ExecutionTraceEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScheduleRunsTable _scheduleRunIdTable(_$PresenceDatabase db) =>
      db.scheduleRuns.createAlias(
        $_aliasNameGenerator(
          db.executionTraceEvents.scheduleRunId,
          db.scheduleRuns.id,
        ),
      );

  $$ScheduleRunsTableProcessedTableManager get scheduleRunId {
    final $_column = $_itemColumn<int>('schedule_run_id')!;

    final manager = $$ScheduleRunsTableTableManager(
      $_db,
      $_db.scheduleRuns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ScheduleTripOccurrencesTable _tripOccurrenceIdTable(
    _$PresenceDatabase db,
  ) => db.scheduleTripOccurrences.createAlias(
    $_aliasNameGenerator(
      db.executionTraceEvents.tripOccurrenceId,
      db.scheduleTripOccurrences.id,
    ),
  );

  $$ScheduleTripOccurrencesTableProcessedTableManager? get tripOccurrenceId {
    final $_column = $_itemColumn<int>('trip_occurrence_id');
    if ($_column == null) return null;
    final manager = $$ScheduleTripOccurrencesTableTableManager(
      $_db,
      $_db.scheduleTripOccurrences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripOccurrenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripStepOccurrencesTable _stepOccurrenceIdTable(
    _$PresenceDatabase db,
  ) => db.tripStepOccurrences.createAlias(
    $_aliasNameGenerator(
      db.executionTraceEvents.stepOccurrenceId,
      db.tripStepOccurrences.id,
    ),
  );

  $$TripStepOccurrencesTableProcessedTableManager? get stepOccurrenceId {
    final $_column = $_itemColumn<int>('step_occurrence_id');
    if ($_column == null) return null;
    final manager = $$TripStepOccurrencesTableTableManager(
      $_db,
      $_db.tripStepOccurrences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepOccurrenceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripDefinitionsTable _routingResultTripDefinitionIdTable(
    _$PresenceDatabase db,
  ) => db.tripDefinitions.createAlias(
    $_aliasNameGenerator(
      db.executionTraceEvents.routingResultTripDefinitionId,
      db.tripDefinitions.id,
    ),
  );

  $$TripDefinitionsTableProcessedTableManager?
  get routingResultTripDefinitionId {
    final $_column = $_itemColumn<int>('routing_result_trip_definition_id');
    if ($_column == null) return null;
    final manager = $$TripDefinitionsTableTableManager(
      $_db,
      $_db.tripDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _routingResultTripDefinitionIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ScheduleTripOccurrencesTable
  _selectedDestinationTripOccurrenceIdTable(_$PresenceDatabase db) =>
      db.scheduleTripOccurrences.createAlias(
        $_aliasNameGenerator(
          db.executionTraceEvents.selectedDestinationTripOccurrenceId,
          db.scheduleTripOccurrences.id,
        ),
      );

  $$ScheduleTripOccurrencesTableProcessedTableManager?
  get selectedDestinationTripOccurrenceId {
    final $_column = $_itemColumn<int>(
      'selected_destination_trip_occurrence_id',
    );
    if ($_column == null) return null;
    final manager = $$ScheduleTripOccurrencesTableTableManager(
      $_db,
      $_db.scheduleTripOccurrences,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _selectedDestinationTripOccurrenceIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExecutionTraceEventsTableFilterComposer
    extends Composer<_$PresenceDatabase, $ExecutionTraceEventsTable> {
  $$ExecutionTraceEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAtUtcUs => $composableBuilder(
    column: $table.occurredAtUtcUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$ScheduleRunsTableFilterComposer get scheduleRunId {
    final $$ScheduleRunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleRunId,
      referencedTable: $db.scheduleRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleRunsTableFilterComposer(
            $db: $db,
            $table: $db.scheduleRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScheduleTripOccurrencesTableFilterComposer get tripOccurrenceId {
    final $$ScheduleTripOccurrencesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.tripOccurrenceId,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableFilterComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TripStepOccurrencesTableFilterComposer get stepOccurrenceId {
    final $$TripStepOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepOccurrenceId,
      referencedTable: $db.tripStepOccurrences,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripStepOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.tripStepOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripDefinitionsTableFilterComposer get routingResultTripDefinitionId {
    final $$TripDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routingResultTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScheduleTripOccurrencesTableFilterComposer
  get selectedDestinationTripOccurrenceId {
    final $$ScheduleTripOccurrencesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.selectedDestinationTripOccurrenceId,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableFilterComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ExecutionTraceEventsTableOrderingComposer
    extends Composer<_$PresenceDatabase, $ExecutionTraceEventsTable> {
  $$ExecutionTraceEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAtUtcUs => $composableBuilder(
    column: $table.occurredAtUtcUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScheduleRunsTableOrderingComposer get scheduleRunId {
    final $$ScheduleRunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleRunId,
      referencedTable: $db.scheduleRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleRunsTableOrderingComposer(
            $db: $db,
            $table: $db.scheduleRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScheduleTripOccurrencesTableOrderingComposer get tripOccurrenceId {
    final $$ScheduleTripOccurrencesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.tripOccurrenceId,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableOrderingComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TripStepOccurrencesTableOrderingComposer get stepOccurrenceId {
    final $$TripStepOccurrencesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.stepOccurrenceId,
          referencedTable: $db.tripStepOccurrences,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TripStepOccurrencesTableOrderingComposer(
                $db: $db,
                $table: $db.tripStepOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TripDefinitionsTableOrderingComposer get routingResultTripDefinitionId {
    final $$TripDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routingResultTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScheduleTripOccurrencesTableOrderingComposer
  get selectedDestinationTripOccurrenceId {
    final $$ScheduleTripOccurrencesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.selectedDestinationTripOccurrenceId,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableOrderingComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ExecutionTraceEventsTableAnnotationComposer
    extends Composer<_$PresenceDatabase, $ExecutionTraceEventsTable> {
  $$ExecutionTraceEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get occurredAtUtcUs => $composableBuilder(
    column: $table.occurredAtUtcUs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$ScheduleRunsTableAnnotationComposer get scheduleRunId {
    final $$ScheduleRunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleRunId,
      referencedTable: $db.scheduleRuns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleRunsTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduleRuns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScheduleTripOccurrencesTableAnnotationComposer get tripOccurrenceId {
    final $$ScheduleTripOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.tripOccurrenceId,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TripStepOccurrencesTableAnnotationComposer get stepOccurrenceId {
    final $$TripStepOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.stepOccurrenceId,
          referencedTable: $db.tripStepOccurrences,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TripStepOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.tripStepOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TripDefinitionsTableAnnotationComposer get routingResultTripDefinitionId {
    final $$TripDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routingResultTripDefinitionId,
      referencedTable: $db.tripDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ScheduleTripOccurrencesTableAnnotationComposer
  get selectedDestinationTripOccurrenceId {
    final $$ScheduleTripOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.selectedDestinationTripOccurrenceId,
          referencedTable: $db.scheduleTripOccurrences,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduleTripOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduleTripOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ExecutionTraceEventsTableTableManager
    extends
        RootTableManager<
          _$PresenceDatabase,
          $ExecutionTraceEventsTable,
          ExecutionTraceEventRow,
          $$ExecutionTraceEventsTableFilterComposer,
          $$ExecutionTraceEventsTableOrderingComposer,
          $$ExecutionTraceEventsTableAnnotationComposer,
          $$ExecutionTraceEventsTableCreateCompanionBuilder,
          $$ExecutionTraceEventsTableUpdateCompanionBuilder,
          (ExecutionTraceEventRow, $$ExecutionTraceEventsTableReferences),
          ExecutionTraceEventRow,
          PrefetchHooks Function({
            bool scheduleRunId,
            bool tripOccurrenceId,
            bool stepOccurrenceId,
            bool routingResultTripDefinitionId,
            bool selectedDestinationTripOccurrenceId,
          })
        > {
  $$ExecutionTraceEventsTableTableManager(
    _$PresenceDatabase db,
    $ExecutionTraceEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExecutionTraceEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExecutionTraceEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExecutionTraceEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int> occurredAtUtcUs = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> scheduleRunId = const Value.absent(),
                Value<int?> tripOccurrenceId = const Value.absent(),
                Value<int?> stepOccurrenceId = const Value.absent(),
                Value<int?> routingResultTripDefinitionId =
                    const Value.absent(),
                Value<int?> selectedDestinationTripOccurrenceId =
                    const Value.absent(),
              }) => ExecutionTraceEventsCompanion(
                sequence: sequence,
                eventType: eventType,
                occurredAtUtcUs: occurredAtUtcUs,
                id: id,
                scheduleRunId: scheduleRunId,
                tripOccurrenceId: tripOccurrenceId,
                stepOccurrenceId: stepOccurrenceId,
                routingResultTripDefinitionId: routingResultTripDefinitionId,
                selectedDestinationTripOccurrenceId:
                    selectedDestinationTripOccurrenceId,
              ),
          createCompanionCallback:
              ({
                required int sequence,
                required String eventType,
                required int occurredAtUtcUs,
                Value<int> id = const Value.absent(),
                required int scheduleRunId,
                Value<int?> tripOccurrenceId = const Value.absent(),
                Value<int?> stepOccurrenceId = const Value.absent(),
                Value<int?> routingResultTripDefinitionId =
                    const Value.absent(),
                Value<int?> selectedDestinationTripOccurrenceId =
                    const Value.absent(),
              }) => ExecutionTraceEventsCompanion.insert(
                sequence: sequence,
                eventType: eventType,
                occurredAtUtcUs: occurredAtUtcUs,
                id: id,
                scheduleRunId: scheduleRunId,
                tripOccurrenceId: tripOccurrenceId,
                stepOccurrenceId: stepOccurrenceId,
                routingResultTripDefinitionId: routingResultTripDefinitionId,
                selectedDestinationTripOccurrenceId:
                    selectedDestinationTripOccurrenceId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExecutionTraceEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                scheduleRunId = false,
                tripOccurrenceId = false,
                stepOccurrenceId = false,
                routingResultTripDefinitionId = false,
                selectedDestinationTripOccurrenceId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (scheduleRunId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.scheduleRunId,
                                    referencedTable:
                                        $$ExecutionTraceEventsTableReferences
                                            ._scheduleRunIdTable(db),
                                    referencedColumn:
                                        $$ExecutionTraceEventsTableReferences
                                            ._scheduleRunIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (tripOccurrenceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripOccurrenceId,
                                    referencedTable:
                                        $$ExecutionTraceEventsTableReferences
                                            ._tripOccurrenceIdTable(db),
                                    referencedColumn:
                                        $$ExecutionTraceEventsTableReferences
                                            ._tripOccurrenceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (stepOccurrenceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stepOccurrenceId,
                                    referencedTable:
                                        $$ExecutionTraceEventsTableReferences
                                            ._stepOccurrenceIdTable(db),
                                    referencedColumn:
                                        $$ExecutionTraceEventsTableReferences
                                            ._stepOccurrenceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (routingResultTripDefinitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.routingResultTripDefinitionId,
                                    referencedTable:
                                        $$ExecutionTraceEventsTableReferences
                                            ._routingResultTripDefinitionIdTable(
                                              db,
                                            ),
                                    referencedColumn:
                                        $$ExecutionTraceEventsTableReferences
                                            ._routingResultTripDefinitionIdTable(
                                              db,
                                            )
                                            .id,
                                  )
                                  as T;
                        }
                        if (selectedDestinationTripOccurrenceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table
                                        .selectedDestinationTripOccurrenceId,
                                    referencedTable:
                                        $$ExecutionTraceEventsTableReferences
                                            ._selectedDestinationTripOccurrenceIdTable(
                                              db,
                                            ),
                                    referencedColumn:
                                        $$ExecutionTraceEventsTableReferences
                                            ._selectedDestinationTripOccurrenceIdTable(
                                              db,
                                            )
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ExecutionTraceEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$PresenceDatabase,
      $ExecutionTraceEventsTable,
      ExecutionTraceEventRow,
      $$ExecutionTraceEventsTableFilterComposer,
      $$ExecutionTraceEventsTableOrderingComposer,
      $$ExecutionTraceEventsTableAnnotationComposer,
      $$ExecutionTraceEventsTableCreateCompanionBuilder,
      $$ExecutionTraceEventsTableUpdateCompanionBuilder,
      (ExecutionTraceEventRow, $$ExecutionTraceEventsTableReferences),
      ExecutionTraceEventRow,
      PrefetchHooks Function({
        bool scheduleRunId,
        bool tripOccurrenceId,
        bool stepOccurrenceId,
        bool routingResultTripDefinitionId,
        bool selectedDestinationTripOccurrenceId,
      })
    >;

class $PresenceDatabaseManager {
  final _$PresenceDatabase _db;
  $PresenceDatabaseManager(this._db);
  $$ScheduleDefinitionsTableTableManager get scheduleDefinitions =>
      $$ScheduleDefinitionsTableTableManager(_db, _db.scheduleDefinitions);
  $$TripDefinitionsTableTableManager get tripDefinitions =>
      $$TripDefinitionsTableTableManager(_db, _db.tripDefinitions);
  $$StepDefinitionsTableTableManager get stepDefinitions =>
      $$StepDefinitionsTableTableManager(_db, _db.stepDefinitions);
  $$ScheduleTripOccurrencesTableTableManager get scheduleTripOccurrences =>
      $$ScheduleTripOccurrencesTableTableManager(
        _db,
        _db.scheduleTripOccurrences,
      );
  $$TripStepOccurrencesTableTableManager get tripStepOccurrences =>
      $$TripStepOccurrencesTableTableManager(_db, _db.tripStepOccurrences);
  $$TellStepDefinitionsTableTableManager get tellStepDefinitions =>
      $$TellStepDefinitionsTableTableManager(_db, _db.tellStepDefinitions);
  $$FixedDestinationStepDefinitionsTableTableManager
  get fixedDestinationStepDefinitions =>
      $$FixedDestinationStepDefinitionsTableTableManager(
        _db,
        _db.fixedDestinationStepDefinitions,
      );
  $$FdaTestStepDefinitionsTableTableManager get fdaTestStepDefinitions =>
      $$FdaTestStepDefinitionsTableTableManager(
        _db,
        _db.fdaTestStepDefinitions,
      );
  $$ContactsSourceReadinessStepDefinitionsTableTableManager
  get contactsSourceReadinessStepDefinitions =>
      $$ContactsSourceReadinessStepDefinitionsTableTableManager(
        _db,
        _db.contactsSourceReadinessStepDefinitions,
      );
  $$OpenFdaSettingsStepDefinitionsTableTableManager
  get openFdaSettingsStepDefinitions =>
      $$OpenFdaSettingsStepDefinitionsTableTableManager(
        _db,
        _db.openFdaSettingsStepDefinitions,
      );
  $$TestAgentDefinitionsTableTableManager get testAgentDefinitions =>
      $$TestAgentDefinitionsTableTableManager(_db, _db.testAgentDefinitions);
  $$TestStepDefinitionsTableTableManager get testStepDefinitions =>
      $$TestStepDefinitionsTableTableManager(_db, _db.testStepDefinitions);
  $$ChoiceStepDefinitionsTableTableManager get choiceStepDefinitions =>
      $$ChoiceStepDefinitionsTableTableManager(_db, _db.choiceStepDefinitions);
  $$ChoiceStepOptionsTableTableManager get choiceStepOptions =>
      $$ChoiceStepOptionsTableTableManager(_db, _db.choiceStepOptions);
  $$ScheduleRunsTableTableManager get scheduleRuns =>
      $$ScheduleRunsTableTableManager(_db, _db.scheduleRuns);
  $$ExecutionTraceEventsTableTableManager get executionTraceEvents =>
      $$ExecutionTraceEventsTableTableManager(_db, _db.executionTraceEvents);
}
