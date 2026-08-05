// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_definition_store.dart';

// ignore_for_file: type=lint
class $JourneysTable extends Journeys
    with TableInfo<$JourneysTable, JourneyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JourneysTable(this.attachedDatabase, [this._alias]);
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
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journeys';
  @override
  VerificationContext validateIntegrity(
    Insertable<JourneyRow> instance, {
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
  JourneyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JourneyRow(
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
  $JourneysTable createAlias(String alias) {
    return $JourneysTable(attachedDatabase, alias);
  }
}

class JourneyRow extends DataClass implements Insertable<JourneyRow> {
  final int id;
  final String name;
  const JourneyRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  JourneysCompanion toCompanion(bool nullToAbsent) {
    return JourneysCompanion(id: Value(id), name: Value(name));
  }

  factory JourneyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JourneyRow(
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

  JourneyRow copyWith({int? id, String? name}) =>
      JourneyRow(id: id ?? this.id, name: name ?? this.name);
  JourneyRow copyWithCompanion(JourneysCompanion data) {
    return JourneyRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JourneyRow(')
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
      (other is JourneyRow && other.id == this.id && other.name == this.name);
}

class JourneysCompanion extends UpdateCompanion<JourneyRow> {
  final Value<int> id;
  final Value<String> name;
  const JourneysCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  JourneysCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<JourneyRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  JourneysCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return JourneysCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return (StringBuffer('JourneysCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $StepsTable extends Steps with TableInfo<$StepsTable, StepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StepsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stepTypeMeta = const VerificationMeta(
    'stepType',
  );
  @override
  late final GeneratedColumn<String> stepType = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    check: () => stepType.isIn(const <String>[tellStepType, askStepType]),
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
  static const VerificationMeta _journeyIdMeta = const VerificationMeta(
    'journeyId',
  );
  @override
  late final GeneratedColumn<int> journeyId = GeneratedColumn<int>(
    'journey_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES journeys (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [position, stepType, id, journeyId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<StepRow> instance, {
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
    if (data.containsKey('journey_id')) {
      context.handle(
        _journeyIdMeta,
        journeyId.isAcceptableOrUnknown(data['journey_id']!, _journeyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_journeyIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {journeyId, position},
  ];
  @override
  StepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StepRow(
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      stepType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      journeyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}journey_id'],
      )!,
    );
  }

  @override
  $StepsTable createAlias(String alias) {
    return $StepsTable(attachedDatabase, alias);
  }
}

class StepRow extends DataClass implements Insertable<StepRow> {
  final int position;
  final String stepType;
  final int id;
  final int journeyId;
  const StepRow({
    required this.position,
    required this.stepType,
    required this.id,
    required this.journeyId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['position'] = Variable<int>(position);
    map['type'] = Variable<String>(stepType);
    map['id'] = Variable<int>(id);
    map['journey_id'] = Variable<int>(journeyId);
    return map;
  }

  StepsCompanion toCompanion(bool nullToAbsent) {
    return StepsCompanion(
      position: Value(position),
      stepType: Value(stepType),
      id: Value(id),
      journeyId: Value(journeyId),
    );
  }

  factory StepRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StepRow(
      position: serializer.fromJson<int>(json['position']),
      stepType: serializer.fromJson<String>(json['stepType']),
      id: serializer.fromJson<int>(json['id']),
      journeyId: serializer.fromJson<int>(json['journeyId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'position': serializer.toJson<int>(position),
      'stepType': serializer.toJson<String>(stepType),
      'id': serializer.toJson<int>(id),
      'journeyId': serializer.toJson<int>(journeyId),
    };
  }

  StepRow copyWith({
    int? position,
    String? stepType,
    int? id,
    int? journeyId,
  }) => StepRow(
    position: position ?? this.position,
    stepType: stepType ?? this.stepType,
    id: id ?? this.id,
    journeyId: journeyId ?? this.journeyId,
  );
  StepRow copyWithCompanion(StepsCompanion data) {
    return StepRow(
      position: data.position.present ? data.position.value : this.position,
      stepType: data.stepType.present ? data.stepType.value : this.stepType,
      id: data.id.present ? data.id.value : this.id,
      journeyId: data.journeyId.present ? data.journeyId.value : this.journeyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StepRow(')
          ..write('position: $position, ')
          ..write('stepType: $stepType, ')
          ..write('id: $id, ')
          ..write('journeyId: $journeyId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(position, stepType, id, journeyId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StepRow &&
          other.position == this.position &&
          other.stepType == this.stepType &&
          other.id == this.id &&
          other.journeyId == this.journeyId);
}

class StepsCompanion extends UpdateCompanion<StepRow> {
  final Value<int> position;
  final Value<String> stepType;
  final Value<int> id;
  final Value<int> journeyId;
  const StepsCompanion({
    this.position = const Value.absent(),
    this.stepType = const Value.absent(),
    this.id = const Value.absent(),
    this.journeyId = const Value.absent(),
  });
  StepsCompanion.insert({
    required int position,
    required String stepType,
    this.id = const Value.absent(),
    required int journeyId,
  }) : position = Value(position),
       stepType = Value(stepType),
       journeyId = Value(journeyId);
  static Insertable<StepRow> custom({
    Expression<int>? position,
    Expression<String>? stepType,
    Expression<int>? id,
    Expression<int>? journeyId,
  }) {
    return RawValuesInsertable({
      if (position != null) 'position': position,
      if (stepType != null) 'type': stepType,
      if (id != null) 'id': id,
      if (journeyId != null) 'journey_id': journeyId,
    });
  }

  StepsCompanion copyWith({
    Value<int>? position,
    Value<String>? stepType,
    Value<int>? id,
    Value<int>? journeyId,
  }) {
    return StepsCompanion(
      position: position ?? this.position,
      stepType: stepType ?? this.stepType,
      id: id ?? this.id,
      journeyId: journeyId ?? this.journeyId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (stepType.present) {
      map['type'] = Variable<String>(stepType.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (journeyId.present) {
      map['journey_id'] = Variable<int>(journeyId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StepsCompanion(')
          ..write('position: $position, ')
          ..write('stepType: $stepType, ')
          ..write('id: $id, ')
          ..write('journeyId: $journeyId')
          ..write(')'))
        .toString();
  }
}

class $TellStepsTable extends TellSteps
    with TableInfo<$TellStepsTable, TellStepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TellStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _holdDurationMsMeta = const VerificationMeta(
    'holdDurationMs',
  );
  @override
  late final GeneratedColumn<int> holdDurationMs = GeneratedColumn<int>(
    'hold_duration_ms',
    aliasedName,
    false,
    check: () => ComparableExpr(holdDurationMs).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepIdMeta = const VerificationMeta('stepId');
  @override
  late final GeneratedColumn<int> stepId = GeneratedColumn<int>(
    'step_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES steps (id) ON DELETE CASCADE',
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
  static const VerificationMeta _advancesAutomaticallyMeta =
      const VerificationMeta('advancesAutomatically');
  @override
  late final GeneratedColumn<bool> advancesAutomatically =
      GeneratedColumn<bool>(
        'advances_automatically',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("advances_automatically" IN (0, 1))',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    holdDurationMs,
    stepId,
    stepText,
    advancesAutomatically,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tell_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<TellStepRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hold_duration_ms')) {
      context.handle(
        _holdDurationMsMeta,
        holdDurationMs.isAcceptableOrUnknown(
          data['hold_duration_ms']!,
          _holdDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_holdDurationMsMeta);
    }
    if (data.containsKey('step_id')) {
      context.handle(
        _stepIdMeta,
        stepId.isAcceptableOrUnknown(data['step_id']!, _stepIdMeta),
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
    if (data.containsKey('advances_automatically')) {
      context.handle(
        _advancesAutomaticallyMeta,
        advancesAutomatically.isAcceptableOrUnknown(
          data['advances_automatically']!,
          _advancesAutomaticallyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_advancesAutomaticallyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepId};
  @override
  TellStepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TellStepRow(
      holdDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hold_duration_ms'],
      )!,
      stepId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_id'],
      )!,
      stepText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      advancesAutomatically: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}advances_automatically'],
      )!,
    );
  }

  @override
  $TellStepsTable createAlias(String alias) {
    return $TellStepsTable(attachedDatabase, alias);
  }
}

class TellStepRow extends DataClass implements Insertable<TellStepRow> {
  final int holdDurationMs;
  final int stepId;
  final String stepText;
  final bool advancesAutomatically;
  const TellStepRow({
    required this.holdDurationMs,
    required this.stepId,
    required this.stepText,
    required this.advancesAutomatically,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hold_duration_ms'] = Variable<int>(holdDurationMs);
    map['step_id'] = Variable<int>(stepId);
    map['text'] = Variable<String>(stepText);
    map['advances_automatically'] = Variable<bool>(advancesAutomatically);
    return map;
  }

  TellStepsCompanion toCompanion(bool nullToAbsent) {
    return TellStepsCompanion(
      holdDurationMs: Value(holdDurationMs),
      stepId: Value(stepId),
      stepText: Value(stepText),
      advancesAutomatically: Value(advancesAutomatically),
    );
  }

  factory TellStepRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TellStepRow(
      holdDurationMs: serializer.fromJson<int>(json['holdDurationMs']),
      stepId: serializer.fromJson<int>(json['stepId']),
      stepText: serializer.fromJson<String>(json['stepText']),
      advancesAutomatically: serializer.fromJson<bool>(
        json['advancesAutomatically'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'holdDurationMs': serializer.toJson<int>(holdDurationMs),
      'stepId': serializer.toJson<int>(stepId),
      'stepText': serializer.toJson<String>(stepText),
      'advancesAutomatically': serializer.toJson<bool>(advancesAutomatically),
    };
  }

  TellStepRow copyWith({
    int? holdDurationMs,
    int? stepId,
    String? stepText,
    bool? advancesAutomatically,
  }) => TellStepRow(
    holdDurationMs: holdDurationMs ?? this.holdDurationMs,
    stepId: stepId ?? this.stepId,
    stepText: stepText ?? this.stepText,
    advancesAutomatically: advancesAutomatically ?? this.advancesAutomatically,
  );
  TellStepRow copyWithCompanion(TellStepsCompanion data) {
    return TellStepRow(
      holdDurationMs: data.holdDurationMs.present
          ? data.holdDurationMs.value
          : this.holdDurationMs,
      stepId: data.stepId.present ? data.stepId.value : this.stepId,
      stepText: data.stepText.present ? data.stepText.value : this.stepText,
      advancesAutomatically: data.advancesAutomatically.present
          ? data.advancesAutomatically.value
          : this.advancesAutomatically,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TellStepRow(')
          ..write('holdDurationMs: $holdDurationMs, ')
          ..write('stepId: $stepId, ')
          ..write('stepText: $stepText, ')
          ..write('advancesAutomatically: $advancesAutomatically')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(holdDurationMs, stepId, stepText, advancesAutomatically);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TellStepRow &&
          other.holdDurationMs == this.holdDurationMs &&
          other.stepId == this.stepId &&
          other.stepText == this.stepText &&
          other.advancesAutomatically == this.advancesAutomatically);
}

class TellStepsCompanion extends UpdateCompanion<TellStepRow> {
  final Value<int> holdDurationMs;
  final Value<int> stepId;
  final Value<String> stepText;
  final Value<bool> advancesAutomatically;
  const TellStepsCompanion({
    this.holdDurationMs = const Value.absent(),
    this.stepId = const Value.absent(),
    this.stepText = const Value.absent(),
    this.advancesAutomatically = const Value.absent(),
  });
  TellStepsCompanion.insert({
    required int holdDurationMs,
    this.stepId = const Value.absent(),
    required String stepText,
    required bool advancesAutomatically,
  }) : holdDurationMs = Value(holdDurationMs),
       stepText = Value(stepText),
       advancesAutomatically = Value(advancesAutomatically);
  static Insertable<TellStepRow> custom({
    Expression<int>? holdDurationMs,
    Expression<int>? stepId,
    Expression<String>? stepText,
    Expression<bool>? advancesAutomatically,
  }) {
    return RawValuesInsertable({
      if (holdDurationMs != null) 'hold_duration_ms': holdDurationMs,
      if (stepId != null) 'step_id': stepId,
      if (stepText != null) 'text': stepText,
      if (advancesAutomatically != null)
        'advances_automatically': advancesAutomatically,
    });
  }

  TellStepsCompanion copyWith({
    Value<int>? holdDurationMs,
    Value<int>? stepId,
    Value<String>? stepText,
    Value<bool>? advancesAutomatically,
  }) {
    return TellStepsCompanion(
      holdDurationMs: holdDurationMs ?? this.holdDurationMs,
      stepId: stepId ?? this.stepId,
      stepText: stepText ?? this.stepText,
      advancesAutomatically:
          advancesAutomatically ?? this.advancesAutomatically,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (holdDurationMs.present) {
      map['hold_duration_ms'] = Variable<int>(holdDurationMs.value);
    }
    if (stepId.present) {
      map['step_id'] = Variable<int>(stepId.value);
    }
    if (stepText.present) {
      map['text'] = Variable<String>(stepText.value);
    }
    if (advancesAutomatically.present) {
      map['advances_automatically'] = Variable<bool>(
        advancesAutomatically.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TellStepsCompanion(')
          ..write('holdDurationMs: $holdDurationMs, ')
          ..write('stepId: $stepId, ')
          ..write('stepText: $stepText, ')
          ..write('advancesAutomatically: $advancesAutomatically')
          ..write(')'))
        .toString();
  }
}

class $AskStepsTable extends AskSteps
    with TableInfo<$AskStepsTable, AskStepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AskStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stepIdMeta = const VerificationMeta('stepId');
  @override
  late final GeneratedColumn<int> stepId = GeneratedColumn<int>(
    'step_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES steps (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [stepId, question];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ask_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<AskStepRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('step_id')) {
      context.handle(
        _stepIdMeta,
        stepId.isAcceptableOrUnknown(data['step_id']!, _stepIdMeta),
      );
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stepId};
  @override
  AskStepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AskStepRow(
      stepId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_id'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question'],
      )!,
    );
  }

  @override
  $AskStepsTable createAlias(String alias) {
    return $AskStepsTable(attachedDatabase, alias);
  }
}

class AskStepRow extends DataClass implements Insertable<AskStepRow> {
  final int stepId;
  final String question;
  const AskStepRow({required this.stepId, required this.question});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['step_id'] = Variable<int>(stepId);
    map['question'] = Variable<String>(question);
    return map;
  }

  AskStepsCompanion toCompanion(bool nullToAbsent) {
    return AskStepsCompanion(stepId: Value(stepId), question: Value(question));
  }

  factory AskStepRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AskStepRow(
      stepId: serializer.fromJson<int>(json['stepId']),
      question: serializer.fromJson<String>(json['question']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stepId': serializer.toJson<int>(stepId),
      'question': serializer.toJson<String>(question),
    };
  }

  AskStepRow copyWith({int? stepId, String? question}) => AskStepRow(
    stepId: stepId ?? this.stepId,
    question: question ?? this.question,
  );
  AskStepRow copyWithCompanion(AskStepsCompanion data) {
    return AskStepRow(
      stepId: data.stepId.present ? data.stepId.value : this.stepId,
      question: data.question.present ? data.question.value : this.question,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AskStepRow(')
          ..write('stepId: $stepId, ')
          ..write('question: $question')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stepId, question);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AskStepRow &&
          other.stepId == this.stepId &&
          other.question == this.question);
}

class AskStepsCompanion extends UpdateCompanion<AskStepRow> {
  final Value<int> stepId;
  final Value<String> question;
  const AskStepsCompanion({
    this.stepId = const Value.absent(),
    this.question = const Value.absent(),
  });
  AskStepsCompanion.insert({
    this.stepId = const Value.absent(),
    required String question,
  }) : question = Value(question);
  static Insertable<AskStepRow> custom({
    Expression<int>? stepId,
    Expression<String>? question,
  }) {
    return RawValuesInsertable({
      if (stepId != null) 'step_id': stepId,
      if (question != null) 'question': question,
    });
  }

  AskStepsCompanion copyWith({Value<int>? stepId, Value<String>? question}) {
    return AskStepsCompanion(
      stepId: stepId ?? this.stepId,
      question: question ?? this.question,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stepId.present) {
      map['step_id'] = Variable<int>(stepId.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AskStepsCompanion(')
          ..write('stepId: $stepId, ')
          ..write('question: $question')
          ..write(')'))
        .toString();
  }
}

abstract class _$JourneyDefinitionStore extends GeneratedDatabase {
  _$JourneyDefinitionStore(QueryExecutor e) : super(e);
  $JourneyDefinitionStoreManager get managers =>
      $JourneyDefinitionStoreManager(this);
  late final $JourneysTable journeys = $JourneysTable(this);
  late final $StepsTable steps = $StepsTable(this);
  late final $TellStepsTable tellSteps = $TellStepsTable(this);
  late final $AskStepsTable askSteps = $AskStepsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    journeys,
    steps,
    tellSteps,
    askSteps,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'steps',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tell_steps', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'steps',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ask_steps', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$JourneysTableCreateCompanionBuilder =
    JourneysCompanion Function({Value<int> id, required String name});
typedef $$JourneysTableUpdateCompanionBuilder =
    JourneysCompanion Function({Value<int> id, Value<String> name});

final class $$JourneysTableReferences
    extends
        BaseReferences<_$JourneyDefinitionStore, $JourneysTable, JourneyRow> {
  $$JourneysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StepsTable, List<StepRow>> _stepsRefsTable(
    _$JourneyDefinitionStore db,
  ) => MultiTypedResultKey.fromTable(
    db.steps,
    aliasName: $_aliasNameGenerator(db.journeys.id, db.steps.journeyId),
  );

  $$StepsTableProcessedTableManager get stepsRefs {
    final manager = $$StepsTableTableManager(
      $_db,
      $_db.steps,
    ).filter((f) => f.journeyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JourneysTableFilterComposer
    extends Composer<_$JourneyDefinitionStore, $JourneysTable> {
  $$JourneysTableFilterComposer({
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

  Expression<bool> stepsRefs(
    Expression<bool> Function($$StepsTableFilterComposer f) f,
  ) {
    final $$StepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.steps,
      getReferencedColumn: (t) => t.journeyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepsTableFilterComposer(
            $db: $db,
            $table: $db.steps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JourneysTableOrderingComposer
    extends Composer<_$JourneyDefinitionStore, $JourneysTable> {
  $$JourneysTableOrderingComposer({
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

class $$JourneysTableAnnotationComposer
    extends Composer<_$JourneyDefinitionStore, $JourneysTable> {
  $$JourneysTableAnnotationComposer({
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

  Expression<T> stepsRefs<T extends Object>(
    Expression<T> Function($$StepsTableAnnotationComposer a) f,
  ) {
    final $$StepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.steps,
      getReferencedColumn: (t) => t.journeyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepsTableAnnotationComposer(
            $db: $db,
            $table: $db.steps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JourneysTableTableManager
    extends
        RootTableManager<
          _$JourneyDefinitionStore,
          $JourneysTable,
          JourneyRow,
          $$JourneysTableFilterComposer,
          $$JourneysTableOrderingComposer,
          $$JourneysTableAnnotationComposer,
          $$JourneysTableCreateCompanionBuilder,
          $$JourneysTableUpdateCompanionBuilder,
          (JourneyRow, $$JourneysTableReferences),
          JourneyRow,
          PrefetchHooks Function({bool stepsRefs})
        > {
  $$JourneysTableTableManager(_$JourneyDefinitionStore db, $JourneysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JourneysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JourneysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JourneysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => JourneysCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  JourneysCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JourneysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stepsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (stepsRefs) db.steps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stepsRefs)
                    await $_getPrefetchedData<
                      JourneyRow,
                      $JourneysTable,
                      StepRow
                    >(
                      currentTable: table,
                      referencedTable: $$JourneysTableReferences
                          ._stepsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$JourneysTableReferences(db, table, p0).stepsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.journeyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$JourneysTableProcessedTableManager =
    ProcessedTableManager<
      _$JourneyDefinitionStore,
      $JourneysTable,
      JourneyRow,
      $$JourneysTableFilterComposer,
      $$JourneysTableOrderingComposer,
      $$JourneysTableAnnotationComposer,
      $$JourneysTableCreateCompanionBuilder,
      $$JourneysTableUpdateCompanionBuilder,
      (JourneyRow, $$JourneysTableReferences),
      JourneyRow,
      PrefetchHooks Function({bool stepsRefs})
    >;
typedef $$StepsTableCreateCompanionBuilder =
    StepsCompanion Function({
      required int position,
      required String stepType,
      Value<int> id,
      required int journeyId,
    });
typedef $$StepsTableUpdateCompanionBuilder =
    StepsCompanion Function({
      Value<int> position,
      Value<String> stepType,
      Value<int> id,
      Value<int> journeyId,
    });

final class $$StepsTableReferences
    extends BaseReferences<_$JourneyDefinitionStore, $StepsTable, StepRow> {
  $$StepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JourneysTable _journeyIdTable(_$JourneyDefinitionStore db) => db
      .journeys
      .createAlias($_aliasNameGenerator(db.steps.journeyId, db.journeys.id));

  $$JourneysTableProcessedTableManager get journeyId {
    final $_column = $_itemColumn<int>('journey_id')!;

    final manager = $$JourneysTableTableManager(
      $_db,
      $_db.journeys,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_journeyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TellStepsTable, List<TellStepRow>>
  _tellStepsRefsTable(_$JourneyDefinitionStore db) =>
      MultiTypedResultKey.fromTable(
        db.tellSteps,
        aliasName: $_aliasNameGenerator(db.steps.id, db.tellSteps.stepId),
      );

  $$TellStepsTableProcessedTableManager get tellStepsRefs {
    final manager = $$TellStepsTableTableManager(
      $_db,
      $_db.tellSteps,
    ).filter((f) => f.stepId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tellStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AskStepsTable, List<AskStepRow>>
  _askStepsRefsTable(_$JourneyDefinitionStore db) =>
      MultiTypedResultKey.fromTable(
        db.askSteps,
        aliasName: $_aliasNameGenerator(db.steps.id, db.askSteps.stepId),
      );

  $$AskStepsTableProcessedTableManager get askStepsRefs {
    final manager = $$AskStepsTableTableManager(
      $_db,
      $_db.askSteps,
    ).filter((f) => f.stepId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_askStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StepsTableFilterComposer
    extends Composer<_$JourneyDefinitionStore, $StepsTable> {
  $$StepsTableFilterComposer({
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

  ColumnFilters<String> get stepType => $composableBuilder(
    column: $table.stepType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$JourneysTableFilterComposer get journeyId {
    final $$JourneysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journeyId,
      referencedTable: $db.journeys,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JourneysTableFilterComposer(
            $db: $db,
            $table: $db.journeys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tellStepsRefs(
    Expression<bool> Function($$TellStepsTableFilterComposer f) f,
  ) {
    final $$TellStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tellSteps,
      getReferencedColumn: (t) => t.stepId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TellStepsTableFilterComposer(
            $db: $db,
            $table: $db.tellSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> askStepsRefs(
    Expression<bool> Function($$AskStepsTableFilterComposer f) f,
  ) {
    final $$AskStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.askSteps,
      getReferencedColumn: (t) => t.stepId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AskStepsTableFilterComposer(
            $db: $db,
            $table: $db.askSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StepsTableOrderingComposer
    extends Composer<_$JourneyDefinitionStore, $StepsTable> {
  $$StepsTableOrderingComposer({
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

  ColumnOrderings<String> get stepType => $composableBuilder(
    column: $table.stepType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$JourneysTableOrderingComposer get journeyId {
    final $$JourneysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journeyId,
      referencedTable: $db.journeys,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JourneysTableOrderingComposer(
            $db: $db,
            $table: $db.journeys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StepsTableAnnotationComposer
    extends Composer<_$JourneyDefinitionStore, $StepsTable> {
  $$StepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get stepType =>
      $composableBuilder(column: $table.stepType, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$JourneysTableAnnotationComposer get journeyId {
    final $$JourneysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.journeyId,
      referencedTable: $db.journeys,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JourneysTableAnnotationComposer(
            $db: $db,
            $table: $db.journeys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tellStepsRefs<T extends Object>(
    Expression<T> Function($$TellStepsTableAnnotationComposer a) f,
  ) {
    final $$TellStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tellSteps,
      getReferencedColumn: (t) => t.stepId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TellStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.tellSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> askStepsRefs<T extends Object>(
    Expression<T> Function($$AskStepsTableAnnotationComposer a) f,
  ) {
    final $$AskStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.askSteps,
      getReferencedColumn: (t) => t.stepId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AskStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.askSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StepsTableTableManager
    extends
        RootTableManager<
          _$JourneyDefinitionStore,
          $StepsTable,
          StepRow,
          $$StepsTableFilterComposer,
          $$StepsTableOrderingComposer,
          $$StepsTableAnnotationComposer,
          $$StepsTableCreateCompanionBuilder,
          $$StepsTableUpdateCompanionBuilder,
          (StepRow, $$StepsTableReferences),
          StepRow,
          PrefetchHooks Function({
            bool journeyId,
            bool tellStepsRefs,
            bool askStepsRefs,
          })
        > {
  $$StepsTableTableManager(_$JourneyDefinitionStore db, $StepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> position = const Value.absent(),
                Value<String> stepType = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> journeyId = const Value.absent(),
              }) => StepsCompanion(
                position: position,
                stepType: stepType,
                id: id,
                journeyId: journeyId,
              ),
          createCompanionCallback:
              ({
                required int position,
                required String stepType,
                Value<int> id = const Value.absent(),
                required int journeyId,
              }) => StepsCompanion.insert(
                position: position,
                stepType: stepType,
                id: id,
                journeyId: journeyId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$StepsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                journeyId = false,
                tellStepsRefs = false,
                askStepsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tellStepsRefs) db.tellSteps,
                    if (askStepsRefs) db.askSteps,
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
                        if (journeyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.journeyId,
                                    referencedTable: $$StepsTableReferences
                                        ._journeyIdTable(db),
                                    referencedColumn: $$StepsTableReferences
                                        ._journeyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tellStepsRefs)
                        await $_getPrefetchedData<
                          StepRow,
                          $StepsTable,
                          TellStepRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepsTableReferences
                              ._tellStepsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StepsTableReferences(
                                db,
                                table,
                                p0,
                              ).tellStepsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (askStepsRefs)
                        await $_getPrefetchedData<
                          StepRow,
                          $StepsTable,
                          AskStepRow
                        >(
                          currentTable: table,
                          referencedTable: $$StepsTableReferences
                              ._askStepsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StepsTableReferences(
                                db,
                                table,
                                p0,
                              ).askStepsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stepId == item.id,
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

typedef $$StepsTableProcessedTableManager =
    ProcessedTableManager<
      _$JourneyDefinitionStore,
      $StepsTable,
      StepRow,
      $$StepsTableFilterComposer,
      $$StepsTableOrderingComposer,
      $$StepsTableAnnotationComposer,
      $$StepsTableCreateCompanionBuilder,
      $$StepsTableUpdateCompanionBuilder,
      (StepRow, $$StepsTableReferences),
      StepRow,
      PrefetchHooks Function({
        bool journeyId,
        bool tellStepsRefs,
        bool askStepsRefs,
      })
    >;
typedef $$TellStepsTableCreateCompanionBuilder =
    TellStepsCompanion Function({
      required int holdDurationMs,
      Value<int> stepId,
      required String stepText,
      required bool advancesAutomatically,
    });
typedef $$TellStepsTableUpdateCompanionBuilder =
    TellStepsCompanion Function({
      Value<int> holdDurationMs,
      Value<int> stepId,
      Value<String> stepText,
      Value<bool> advancesAutomatically,
    });

final class $$TellStepsTableReferences
    extends
        BaseReferences<_$JourneyDefinitionStore, $TellStepsTable, TellStepRow> {
  $$TellStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StepsTable _stepIdTable(_$JourneyDefinitionStore db) => db.steps
      .createAlias($_aliasNameGenerator(db.tellSteps.stepId, db.steps.id));

  $$StepsTableProcessedTableManager get stepId {
    final $_column = $_itemColumn<int>('step_id')!;

    final manager = $$StepsTableTableManager(
      $_db,
      $_db.steps,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TellStepsTableFilterComposer
    extends Composer<_$JourneyDefinitionStore, $TellStepsTable> {
  $$TellStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get holdDurationMs => $composableBuilder(
    column: $table.holdDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepText => $composableBuilder(
    column: $table.stepText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get advancesAutomatically => $composableBuilder(
    column: $table.advancesAutomatically,
    builder: (column) => ColumnFilters(column),
  );

  $$StepsTableFilterComposer get stepId {
    final $$StepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepId,
      referencedTable: $db.steps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepsTableFilterComposer(
            $db: $db,
            $table: $db.steps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TellStepsTableOrderingComposer
    extends Composer<_$JourneyDefinitionStore, $TellStepsTable> {
  $$TellStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get holdDurationMs => $composableBuilder(
    column: $table.holdDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepText => $composableBuilder(
    column: $table.stepText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get advancesAutomatically => $composableBuilder(
    column: $table.advancesAutomatically,
    builder: (column) => ColumnOrderings(column),
  );

  $$StepsTableOrderingComposer get stepId {
    final $$StepsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepId,
      referencedTable: $db.steps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepsTableOrderingComposer(
            $db: $db,
            $table: $db.steps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TellStepsTableAnnotationComposer
    extends Composer<_$JourneyDefinitionStore, $TellStepsTable> {
  $$TellStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get holdDurationMs => $composableBuilder(
    column: $table.holdDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stepText =>
      $composableBuilder(column: $table.stepText, builder: (column) => column);

  GeneratedColumn<bool> get advancesAutomatically => $composableBuilder(
    column: $table.advancesAutomatically,
    builder: (column) => column,
  );

  $$StepsTableAnnotationComposer get stepId {
    final $$StepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepId,
      referencedTable: $db.steps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepsTableAnnotationComposer(
            $db: $db,
            $table: $db.steps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TellStepsTableTableManager
    extends
        RootTableManager<
          _$JourneyDefinitionStore,
          $TellStepsTable,
          TellStepRow,
          $$TellStepsTableFilterComposer,
          $$TellStepsTableOrderingComposer,
          $$TellStepsTableAnnotationComposer,
          $$TellStepsTableCreateCompanionBuilder,
          $$TellStepsTableUpdateCompanionBuilder,
          (TellStepRow, $$TellStepsTableReferences),
          TellStepRow,
          PrefetchHooks Function({bool stepId})
        > {
  $$TellStepsTableTableManager(
    _$JourneyDefinitionStore db,
    $TellStepsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TellStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TellStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TellStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> holdDurationMs = const Value.absent(),
                Value<int> stepId = const Value.absent(),
                Value<String> stepText = const Value.absent(),
                Value<bool> advancesAutomatically = const Value.absent(),
              }) => TellStepsCompanion(
                holdDurationMs: holdDurationMs,
                stepId: stepId,
                stepText: stepText,
                advancesAutomatically: advancesAutomatically,
              ),
          createCompanionCallback:
              ({
                required int holdDurationMs,
                Value<int> stepId = const Value.absent(),
                required String stepText,
                required bool advancesAutomatically,
              }) => TellStepsCompanion.insert(
                holdDurationMs: holdDurationMs,
                stepId: stepId,
                stepText: stepText,
                advancesAutomatically: advancesAutomatically,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TellStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stepId = false}) {
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
                    if (stepId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stepId,
                                referencedTable: $$TellStepsTableReferences
                                    ._stepIdTable(db),
                                referencedColumn: $$TellStepsTableReferences
                                    ._stepIdTable(db)
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

typedef $$TellStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$JourneyDefinitionStore,
      $TellStepsTable,
      TellStepRow,
      $$TellStepsTableFilterComposer,
      $$TellStepsTableOrderingComposer,
      $$TellStepsTableAnnotationComposer,
      $$TellStepsTableCreateCompanionBuilder,
      $$TellStepsTableUpdateCompanionBuilder,
      (TellStepRow, $$TellStepsTableReferences),
      TellStepRow,
      PrefetchHooks Function({bool stepId})
    >;
typedef $$AskStepsTableCreateCompanionBuilder =
    AskStepsCompanion Function({Value<int> stepId, required String question});
typedef $$AskStepsTableUpdateCompanionBuilder =
    AskStepsCompanion Function({Value<int> stepId, Value<String> question});

final class $$AskStepsTableReferences
    extends
        BaseReferences<_$JourneyDefinitionStore, $AskStepsTable, AskStepRow> {
  $$AskStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StepsTable _stepIdTable(_$JourneyDefinitionStore db) => db.steps
      .createAlias($_aliasNameGenerator(db.askSteps.stepId, db.steps.id));

  $$StepsTableProcessedTableManager get stepId {
    final $_column = $_itemColumn<int>('step_id')!;

    final manager = $$StepsTableTableManager(
      $_db,
      $_db.steps,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stepIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AskStepsTableFilterComposer
    extends Composer<_$JourneyDefinitionStore, $AskStepsTable> {
  $$AskStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );

  $$StepsTableFilterComposer get stepId {
    final $$StepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepId,
      referencedTable: $db.steps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepsTableFilterComposer(
            $db: $db,
            $table: $db.steps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AskStepsTableOrderingComposer
    extends Composer<_$JourneyDefinitionStore, $AskStepsTable> {
  $$AskStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );

  $$StepsTableOrderingComposer get stepId {
    final $$StepsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepId,
      referencedTable: $db.steps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepsTableOrderingComposer(
            $db: $db,
            $table: $db.steps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AskStepsTableAnnotationComposer
    extends Composer<_$JourneyDefinitionStore, $AskStepsTable> {
  $$AskStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  $$StepsTableAnnotationComposer get stepId {
    final $$StepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stepId,
      referencedTable: $db.steps,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StepsTableAnnotationComposer(
            $db: $db,
            $table: $db.steps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AskStepsTableTableManager
    extends
        RootTableManager<
          _$JourneyDefinitionStore,
          $AskStepsTable,
          AskStepRow,
          $$AskStepsTableFilterComposer,
          $$AskStepsTableOrderingComposer,
          $$AskStepsTableAnnotationComposer,
          $$AskStepsTableCreateCompanionBuilder,
          $$AskStepsTableUpdateCompanionBuilder,
          (AskStepRow, $$AskStepsTableReferences),
          AskStepRow,
          PrefetchHooks Function({bool stepId})
        > {
  $$AskStepsTableTableManager(_$JourneyDefinitionStore db, $AskStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AskStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AskStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AskStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> stepId = const Value.absent(),
                Value<String> question = const Value.absent(),
              }) => AskStepsCompanion(stepId: stepId, question: question),
          createCompanionCallback:
              ({
                Value<int> stepId = const Value.absent(),
                required String question,
              }) =>
                  AskStepsCompanion.insert(stepId: stepId, question: question),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AskStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stepId = false}) {
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
                    if (stepId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.stepId,
                                referencedTable: $$AskStepsTableReferences
                                    ._stepIdTable(db),
                                referencedColumn: $$AskStepsTableReferences
                                    ._stepIdTable(db)
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

typedef $$AskStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$JourneyDefinitionStore,
      $AskStepsTable,
      AskStepRow,
      $$AskStepsTableFilterComposer,
      $$AskStepsTableOrderingComposer,
      $$AskStepsTableAnnotationComposer,
      $$AskStepsTableCreateCompanionBuilder,
      $$AskStepsTableUpdateCompanionBuilder,
      (AskStepRow, $$AskStepsTableReferences),
      AskStepRow,
      PrefetchHooks Function({bool stepId})
    >;

class $JourneyDefinitionStoreManager {
  final _$JourneyDefinitionStore _db;
  $JourneyDefinitionStoreManager(this._db);
  $$JourneysTableTableManager get journeys =>
      $$JourneysTableTableManager(_db, _db.journeys);
  $$StepsTableTableManager get steps =>
      $$StepsTableTableManager(_db, _db.steps);
  $$TellStepsTableTableManager get tellSteps =>
      $$TellStepsTableTableManager(_db, _db.tellSteps);
  $$AskStepsTableTableManager get askSteps =>
      $$AskStepsTableTableManager(_db, _db.askSteps);
}
