// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_database.dart';

// ignore_for_file: type=lint
class $WorkingSchemaMigrationsTable extends WorkingSchemaMigrations
    with TableInfo<$WorkingSchemaMigrationsTable, WorkingSchemaMigration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingSchemaMigrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appliedAtUtcMeta = const VerificationMeta(
    'appliedAtUtc',
  );
  @override
  late final GeneratedColumn<String> appliedAtUtc = GeneratedColumn<String>(
    'applied_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [version, appliedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_migrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingSchemaMigration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('applied_at_utc')) {
      context.handle(
        _appliedAtUtcMeta,
        appliedAtUtc.isAcceptableOrUnknown(
          data['applied_at_utc']!,
          _appliedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {version};
  @override
  WorkingSchemaMigration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingSchemaMigration(
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      appliedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applied_at_utc'],
      )!,
    );
  }

  @override
  $WorkingSchemaMigrationsTable createAlias(String alias) {
    return $WorkingSchemaMigrationsTable(attachedDatabase, alias);
  }
}

class WorkingSchemaMigration extends DataClass
    implements Insertable<WorkingSchemaMigration> {
  final int version;
  final String appliedAtUtc;
  const WorkingSchemaMigration({
    required this.version,
    required this.appliedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version'] = Variable<int>(version);
    map['applied_at_utc'] = Variable<String>(appliedAtUtc);
    return map;
  }

  WorkingSchemaMigrationsCompanion toCompanion(bool nullToAbsent) {
    return WorkingSchemaMigrationsCompanion(
      version: Value(version),
      appliedAtUtc: Value(appliedAtUtc),
    );
  }

  factory WorkingSchemaMigration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingSchemaMigration(
      version: serializer.fromJson<int>(json['version']),
      appliedAtUtc: serializer.fromJson<String>(json['appliedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'version': serializer.toJson<int>(version),
      'appliedAtUtc': serializer.toJson<String>(appliedAtUtc),
    };
  }

  WorkingSchemaMigration copyWith({int? version, String? appliedAtUtc}) =>
      WorkingSchemaMigration(
        version: version ?? this.version,
        appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
      );
  WorkingSchemaMigration copyWithCompanion(
    WorkingSchemaMigrationsCompanion data,
  ) {
    return WorkingSchemaMigration(
      version: data.version.present ? data.version.value : this.version,
      appliedAtUtc: data.appliedAtUtc.present
          ? data.appliedAtUtc.value
          : this.appliedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingSchemaMigration(')
          ..write('version: $version, ')
          ..write('appliedAtUtc: $appliedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(version, appliedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingSchemaMigration &&
          other.version == this.version &&
          other.appliedAtUtc == this.appliedAtUtc);
}

class WorkingSchemaMigrationsCompanion
    extends UpdateCompanion<WorkingSchemaMigration> {
  final Value<int> version;
  final Value<String> appliedAtUtc;
  const WorkingSchemaMigrationsCompanion({
    this.version = const Value.absent(),
    this.appliedAtUtc = const Value.absent(),
  });
  WorkingSchemaMigrationsCompanion.insert({
    this.version = const Value.absent(),
    required String appliedAtUtc,
  }) : appliedAtUtc = Value(appliedAtUtc);
  static Insertable<WorkingSchemaMigration> custom({
    Expression<int>? version,
    Expression<String>? appliedAtUtc,
  }) {
    return RawValuesInsertable({
      if (version != null) 'version': version,
      if (appliedAtUtc != null) 'applied_at_utc': appliedAtUtc,
    });
  }

  WorkingSchemaMigrationsCompanion copyWith({
    Value<int>? version,
    Value<String>? appliedAtUtc,
  }) {
    return WorkingSchemaMigrationsCompanion(
      version: version ?? this.version,
      appliedAtUtc: appliedAtUtc ?? this.appliedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (appliedAtUtc.present) {
      map['applied_at_utc'] = Variable<String>(appliedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingSchemaMigrationsCompanion(')
          ..write('version: $version, ')
          ..write('appliedAtUtc: $appliedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $ProjectionStateTable extends ProjectionState
    with TableInfo<$ProjectionStateTable, ProjectionStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectionStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK(id=1)',
    clientDefault: () => 1,
  );
  static const VerificationMeta _lastImportBatchIdMeta = const VerificationMeta(
    'lastImportBatchId',
  );
  @override
  late final GeneratedColumn<int> lastImportBatchId = GeneratedColumn<int>(
    'last_import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastProjectedAtUtcMeta =
      const VerificationMeta('lastProjectedAtUtc');
  @override
  late final GeneratedColumn<String> lastProjectedAtUtc =
      GeneratedColumn<String>(
        'last_projected_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastProjectedMessageIdMeta =
      const VerificationMeta('lastProjectedMessageId');
  @override
  late final GeneratedColumn<int> lastProjectedMessageId = GeneratedColumn<int>(
    'last_projected_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastProjectedAttachmentIdMeta =
      const VerificationMeta('lastProjectedAttachmentId');
  @override
  late final GeneratedColumn<int> lastProjectedAttachmentId =
      GeneratedColumn<int>(
        'last_projected_attachment_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastImportBatchId,
    lastProjectedAtUtc,
    lastProjectedMessageId,
    lastProjectedAttachmentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projection_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectionStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_import_batch_id')) {
      context.handle(
        _lastImportBatchIdMeta,
        lastImportBatchId.isAcceptableOrUnknown(
          data['last_import_batch_id']!,
          _lastImportBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('last_projected_at_utc')) {
      context.handle(
        _lastProjectedAtUtcMeta,
        lastProjectedAtUtc.isAcceptableOrUnknown(
          data['last_projected_at_utc']!,
          _lastProjectedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_projected_message_id')) {
      context.handle(
        _lastProjectedMessageIdMeta,
        lastProjectedMessageId.isAcceptableOrUnknown(
          data['last_projected_message_id']!,
          _lastProjectedMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_projected_attachment_id')) {
      context.handle(
        _lastProjectedAttachmentIdMeta,
        lastProjectedAttachmentId.isAcceptableOrUnknown(
          data['last_projected_attachment_id']!,
          _lastProjectedAttachmentIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectionStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectionStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastImportBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_import_batch_id'],
      ),
      lastProjectedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_projected_at_utc'],
      ),
      lastProjectedMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_projected_message_id'],
      ),
      lastProjectedAttachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_projected_attachment_id'],
      ),
    );
  }

  @override
  $ProjectionStateTable createAlias(String alias) {
    return $ProjectionStateTable(attachedDatabase, alias);
  }
}

class ProjectionStateData extends DataClass
    implements Insertable<ProjectionStateData> {
  final int id;
  final int? lastImportBatchId;
  final String? lastProjectedAtUtc;
  final int? lastProjectedMessageId;
  final int? lastProjectedAttachmentId;
  const ProjectionStateData({
    required this.id,
    this.lastImportBatchId,
    this.lastProjectedAtUtc,
    this.lastProjectedMessageId,
    this.lastProjectedAttachmentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastImportBatchId != null) {
      map['last_import_batch_id'] = Variable<int>(lastImportBatchId);
    }
    if (!nullToAbsent || lastProjectedAtUtc != null) {
      map['last_projected_at_utc'] = Variable<String>(lastProjectedAtUtc);
    }
    if (!nullToAbsent || lastProjectedMessageId != null) {
      map['last_projected_message_id'] = Variable<int>(lastProjectedMessageId);
    }
    if (!nullToAbsent || lastProjectedAttachmentId != null) {
      map['last_projected_attachment_id'] = Variable<int>(
        lastProjectedAttachmentId,
      );
    }
    return map;
  }

  ProjectionStateCompanion toCompanion(bool nullToAbsent) {
    return ProjectionStateCompanion(
      id: Value(id),
      lastImportBatchId: lastImportBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastImportBatchId),
      lastProjectedAtUtc: lastProjectedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastProjectedAtUtc),
      lastProjectedMessageId: lastProjectedMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastProjectedMessageId),
      lastProjectedAttachmentId:
          lastProjectedAttachmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastProjectedAttachmentId),
    );
  }

  factory ProjectionStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectionStateData(
      id: serializer.fromJson<int>(json['id']),
      lastImportBatchId: serializer.fromJson<int?>(json['lastImportBatchId']),
      lastProjectedAtUtc: serializer.fromJson<String?>(
        json['lastProjectedAtUtc'],
      ),
      lastProjectedMessageId: serializer.fromJson<int?>(
        json['lastProjectedMessageId'],
      ),
      lastProjectedAttachmentId: serializer.fromJson<int?>(
        json['lastProjectedAttachmentId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastImportBatchId': serializer.toJson<int?>(lastImportBatchId),
      'lastProjectedAtUtc': serializer.toJson<String?>(lastProjectedAtUtc),
      'lastProjectedMessageId': serializer.toJson<int?>(lastProjectedMessageId),
      'lastProjectedAttachmentId': serializer.toJson<int?>(
        lastProjectedAttachmentId,
      ),
    };
  }

  ProjectionStateData copyWith({
    int? id,
    Value<int?> lastImportBatchId = const Value.absent(),
    Value<String?> lastProjectedAtUtc = const Value.absent(),
    Value<int?> lastProjectedMessageId = const Value.absent(),
    Value<int?> lastProjectedAttachmentId = const Value.absent(),
  }) => ProjectionStateData(
    id: id ?? this.id,
    lastImportBatchId: lastImportBatchId.present
        ? lastImportBatchId.value
        : this.lastImportBatchId,
    lastProjectedAtUtc: lastProjectedAtUtc.present
        ? lastProjectedAtUtc.value
        : this.lastProjectedAtUtc,
    lastProjectedMessageId: lastProjectedMessageId.present
        ? lastProjectedMessageId.value
        : this.lastProjectedMessageId,
    lastProjectedAttachmentId: lastProjectedAttachmentId.present
        ? lastProjectedAttachmentId.value
        : this.lastProjectedAttachmentId,
  );
  ProjectionStateData copyWithCompanion(ProjectionStateCompanion data) {
    return ProjectionStateData(
      id: data.id.present ? data.id.value : this.id,
      lastImportBatchId: data.lastImportBatchId.present
          ? data.lastImportBatchId.value
          : this.lastImportBatchId,
      lastProjectedAtUtc: data.lastProjectedAtUtc.present
          ? data.lastProjectedAtUtc.value
          : this.lastProjectedAtUtc,
      lastProjectedMessageId: data.lastProjectedMessageId.present
          ? data.lastProjectedMessageId.value
          : this.lastProjectedMessageId,
      lastProjectedAttachmentId: data.lastProjectedAttachmentId.present
          ? data.lastProjectedAttachmentId.value
          : this.lastProjectedAttachmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectionStateData(')
          ..write('id: $id, ')
          ..write('lastImportBatchId: $lastImportBatchId, ')
          ..write('lastProjectedAtUtc: $lastProjectedAtUtc, ')
          ..write('lastProjectedMessageId: $lastProjectedMessageId, ')
          ..write('lastProjectedAttachmentId: $lastProjectedAttachmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lastImportBatchId,
    lastProjectedAtUtc,
    lastProjectedMessageId,
    lastProjectedAttachmentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectionStateData &&
          other.id == this.id &&
          other.lastImportBatchId == this.lastImportBatchId &&
          other.lastProjectedAtUtc == this.lastProjectedAtUtc &&
          other.lastProjectedMessageId == this.lastProjectedMessageId &&
          other.lastProjectedAttachmentId == this.lastProjectedAttachmentId);
}

class ProjectionStateCompanion extends UpdateCompanion<ProjectionStateData> {
  final Value<int> id;
  final Value<int?> lastImportBatchId;
  final Value<String?> lastProjectedAtUtc;
  final Value<int?> lastProjectedMessageId;
  final Value<int?> lastProjectedAttachmentId;
  const ProjectionStateCompanion({
    this.id = const Value.absent(),
    this.lastImportBatchId = const Value.absent(),
    this.lastProjectedAtUtc = const Value.absent(),
    this.lastProjectedMessageId = const Value.absent(),
    this.lastProjectedAttachmentId = const Value.absent(),
  });
  ProjectionStateCompanion.insert({
    this.id = const Value.absent(),
    this.lastImportBatchId = const Value.absent(),
    this.lastProjectedAtUtc = const Value.absent(),
    this.lastProjectedMessageId = const Value.absent(),
    this.lastProjectedAttachmentId = const Value.absent(),
  });
  static Insertable<ProjectionStateData> custom({
    Expression<int>? id,
    Expression<int>? lastImportBatchId,
    Expression<String>? lastProjectedAtUtc,
    Expression<int>? lastProjectedMessageId,
    Expression<int>? lastProjectedAttachmentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastImportBatchId != null) 'last_import_batch_id': lastImportBatchId,
      if (lastProjectedAtUtc != null)
        'last_projected_at_utc': lastProjectedAtUtc,
      if (lastProjectedMessageId != null)
        'last_projected_message_id': lastProjectedMessageId,
      if (lastProjectedAttachmentId != null)
        'last_projected_attachment_id': lastProjectedAttachmentId,
    });
  }

  ProjectionStateCompanion copyWith({
    Value<int>? id,
    Value<int?>? lastImportBatchId,
    Value<String?>? lastProjectedAtUtc,
    Value<int?>? lastProjectedMessageId,
    Value<int?>? lastProjectedAttachmentId,
  }) {
    return ProjectionStateCompanion(
      id: id ?? this.id,
      lastImportBatchId: lastImportBatchId ?? this.lastImportBatchId,
      lastProjectedAtUtc: lastProjectedAtUtc ?? this.lastProjectedAtUtc,
      lastProjectedMessageId:
          lastProjectedMessageId ?? this.lastProjectedMessageId,
      lastProjectedAttachmentId:
          lastProjectedAttachmentId ?? this.lastProjectedAttachmentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastImportBatchId.present) {
      map['last_import_batch_id'] = Variable<int>(lastImportBatchId.value);
    }
    if (lastProjectedAtUtc.present) {
      map['last_projected_at_utc'] = Variable<String>(lastProjectedAtUtc.value);
    }
    if (lastProjectedMessageId.present) {
      map['last_projected_message_id'] = Variable<int>(
        lastProjectedMessageId.value,
      );
    }
    if (lastProjectedAttachmentId.present) {
      map['last_projected_attachment_id'] = Variable<int>(
        lastProjectedAttachmentId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectionStateCompanion(')
          ..write('id: $id, ')
          ..write('lastImportBatchId: $lastImportBatchId, ')
          ..write('lastProjectedAtUtc: $lastProjectedAtUtc, ')
          ..write('lastProjectedMessageId: $lastProjectedMessageId, ')
          ..write('lastProjectedAttachmentId: $lastProjectedAttachmentId')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkingParticipantsTable extends WorkingParticipants
    with TableInfo<$WorkingParticipantsTable, WorkingParticipant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingParticipantsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _normalizedAddressMeta = const VerificationMeta(
    'normalizedAddress',
  );
  @override
  late final GeneratedColumn<String> normalizedAddress =
      GeneratedColumn<String>(
        'normalized_address',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'Unknown\' CHECK(service IN (\'iMessage\',\'iMessageLite\',\'SMS\',\'RCS\',\'Unknown\'))',
    defaultValue: const CustomExpression('\'Unknown\''),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactRefMeta = const VerificationMeta(
    'contactRef',
  );
  @override
  late final GeneratedColumn<String> contactRef = GeneratedColumn<String>(
    'contact_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarRefMeta = const VerificationMeta(
    'avatarRef',
  );
  @override
  late final GeneratedColumn<String> avatarRef = GeneratedColumn<String>(
    'avatar_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    normalizedAddress,
    service,
    displayName,
    contactRef,
    avatarRef,
    isSystem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingParticipant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('normalized_address')) {
      context.handle(
        _normalizedAddressMeta,
        normalizedAddress.isAcceptableOrUnknown(
          data['normalized_address']!,
          _normalizedAddressMeta,
        ),
      );
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('contact_ref')) {
      context.handle(
        _contactRefMeta,
        contactRef.isAcceptableOrUnknown(data['contact_ref']!, _contactRefMeta),
      );
    }
    if (data.containsKey('avatar_ref')) {
      context.handle(
        _avatarRefMeta,
        avatarRef.isAcceptableOrUnknown(data['avatar_ref']!, _avatarRefMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {service, normalizedAddress},
  ];
  @override
  WorkingParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingParticipant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      normalizedAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_address'],
      ),
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      contactRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_ref'],
      ),
      avatarRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_ref'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
    );
  }

  @override
  $WorkingParticipantsTable createAlias(String alias) {
    return $WorkingParticipantsTable(attachedDatabase, alias);
  }
}

class WorkingParticipant extends DataClass
    implements Insertable<WorkingParticipant> {
  final int id;
  final String? normalizedAddress;
  final String service;
  final String? displayName;
  final String? contactRef;
  final String? avatarRef;
  final bool isSystem;
  const WorkingParticipant({
    required this.id,
    this.normalizedAddress,
    required this.service,
    this.displayName,
    this.contactRef,
    this.avatarRef,
    required this.isSystem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || normalizedAddress != null) {
      map['normalized_address'] = Variable<String>(normalizedAddress);
    }
    map['service'] = Variable<String>(service);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || contactRef != null) {
      map['contact_ref'] = Variable<String>(contactRef);
    }
    if (!nullToAbsent || avatarRef != null) {
      map['avatar_ref'] = Variable<String>(avatarRef);
    }
    map['is_system'] = Variable<bool>(isSystem);
    return map;
  }

  WorkingParticipantsCompanion toCompanion(bool nullToAbsent) {
    return WorkingParticipantsCompanion(
      id: Value(id),
      normalizedAddress: normalizedAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedAddress),
      service: Value(service),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      contactRef: contactRef == null && nullToAbsent
          ? const Value.absent()
          : Value(contactRef),
      avatarRef: avatarRef == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarRef),
      isSystem: Value(isSystem),
    );
  }

  factory WorkingParticipant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingParticipant(
      id: serializer.fromJson<int>(json['id']),
      normalizedAddress: serializer.fromJson<String?>(
        json['normalizedAddress'],
      ),
      service: serializer.fromJson<String>(json['service']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      contactRef: serializer.fromJson<String?>(json['contactRef']),
      avatarRef: serializer.fromJson<String?>(json['avatarRef']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'normalizedAddress': serializer.toJson<String?>(normalizedAddress),
      'service': serializer.toJson<String>(service),
      'displayName': serializer.toJson<String?>(displayName),
      'contactRef': serializer.toJson<String?>(contactRef),
      'avatarRef': serializer.toJson<String?>(avatarRef),
      'isSystem': serializer.toJson<bool>(isSystem),
    };
  }

  WorkingParticipant copyWith({
    int? id,
    Value<String?> normalizedAddress = const Value.absent(),
    String? service,
    Value<String?> displayName = const Value.absent(),
    Value<String?> contactRef = const Value.absent(),
    Value<String?> avatarRef = const Value.absent(),
    bool? isSystem,
  }) => WorkingParticipant(
    id: id ?? this.id,
    normalizedAddress: normalizedAddress.present
        ? normalizedAddress.value
        : this.normalizedAddress,
    service: service ?? this.service,
    displayName: displayName.present ? displayName.value : this.displayName,
    contactRef: contactRef.present ? contactRef.value : this.contactRef,
    avatarRef: avatarRef.present ? avatarRef.value : this.avatarRef,
    isSystem: isSystem ?? this.isSystem,
  );
  WorkingParticipant copyWithCompanion(WorkingParticipantsCompanion data) {
    return WorkingParticipant(
      id: data.id.present ? data.id.value : this.id,
      normalizedAddress: data.normalizedAddress.present
          ? data.normalizedAddress.value
          : this.normalizedAddress,
      service: data.service.present ? data.service.value : this.service,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      contactRef: data.contactRef.present
          ? data.contactRef.value
          : this.contactRef,
      avatarRef: data.avatarRef.present ? data.avatarRef.value : this.avatarRef,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingParticipant(')
          ..write('id: $id, ')
          ..write('normalizedAddress: $normalizedAddress, ')
          ..write('service: $service, ')
          ..write('displayName: $displayName, ')
          ..write('contactRef: $contactRef, ')
          ..write('avatarRef: $avatarRef, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    normalizedAddress,
    service,
    displayName,
    contactRef,
    avatarRef,
    isSystem,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingParticipant &&
          other.id == this.id &&
          other.normalizedAddress == this.normalizedAddress &&
          other.service == this.service &&
          other.displayName == this.displayName &&
          other.contactRef == this.contactRef &&
          other.avatarRef == this.avatarRef &&
          other.isSystem == this.isSystem);
}

class WorkingParticipantsCompanion extends UpdateCompanion<WorkingParticipant> {
  final Value<int> id;
  final Value<String?> normalizedAddress;
  final Value<String> service;
  final Value<String?> displayName;
  final Value<String?> contactRef;
  final Value<String?> avatarRef;
  final Value<bool> isSystem;
  const WorkingParticipantsCompanion({
    this.id = const Value.absent(),
    this.normalizedAddress = const Value.absent(),
    this.service = const Value.absent(),
    this.displayName = const Value.absent(),
    this.contactRef = const Value.absent(),
    this.avatarRef = const Value.absent(),
    this.isSystem = const Value.absent(),
  });
  WorkingParticipantsCompanion.insert({
    this.id = const Value.absent(),
    this.normalizedAddress = const Value.absent(),
    this.service = const Value.absent(),
    this.displayName = const Value.absent(),
    this.contactRef = const Value.absent(),
    this.avatarRef = const Value.absent(),
    this.isSystem = const Value.absent(),
  });
  static Insertable<WorkingParticipant> custom({
    Expression<int>? id,
    Expression<String>? normalizedAddress,
    Expression<String>? service,
    Expression<String>? displayName,
    Expression<String>? contactRef,
    Expression<String>? avatarRef,
    Expression<bool>? isSystem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (normalizedAddress != null) 'normalized_address': normalizedAddress,
      if (service != null) 'service': service,
      if (displayName != null) 'display_name': displayName,
      if (contactRef != null) 'contact_ref': contactRef,
      if (avatarRef != null) 'avatar_ref': avatarRef,
      if (isSystem != null) 'is_system': isSystem,
    });
  }

  WorkingParticipantsCompanion copyWith({
    Value<int>? id,
    Value<String?>? normalizedAddress,
    Value<String>? service,
    Value<String?>? displayName,
    Value<String?>? contactRef,
    Value<String?>? avatarRef,
    Value<bool>? isSystem,
  }) {
    return WorkingParticipantsCompanion(
      id: id ?? this.id,
      normalizedAddress: normalizedAddress ?? this.normalizedAddress,
      service: service ?? this.service,
      displayName: displayName ?? this.displayName,
      contactRef: contactRef ?? this.contactRef,
      avatarRef: avatarRef ?? this.avatarRef,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (normalizedAddress.present) {
      map['normalized_address'] = Variable<String>(normalizedAddress.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (contactRef.present) {
      map['contact_ref'] = Variable<String>(contactRef.value);
    }
    if (avatarRef.present) {
      map['avatar_ref'] = Variable<String>(avatarRef.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('normalizedAddress: $normalizedAddress, ')
          ..write('service: $service, ')
          ..write('displayName: $displayName, ')
          ..write('contactRef: $contactRef, ')
          ..write('avatarRef: $avatarRef, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }
}

class $ParticipantHandleLinksTable extends ParticipantHandleLinks
    with TableInfo<$ParticipantHandleLinksTable, ParticipantHandleLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantHandleLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES participants (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _importHandleIdMeta = const VerificationMeta(
    'importHandleId',
  );
  @override
  late final GeneratedColumn<int> importHandleId = GeneratedColumn<int>(
    'import_handle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [participantId, importHandleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participant_handle_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParticipantHandleLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('import_handle_id')) {
      context.handle(
        _importHandleIdMeta,
        importHandleId.isAcceptableOrUnknown(
          data['import_handle_id']!,
          _importHandleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_importHandleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {participantId, importHandleId};
  @override
  ParticipantHandleLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParticipantHandleLink(
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      )!,
      importHandleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_handle_id'],
      )!,
    );
  }

  @override
  $ParticipantHandleLinksTable createAlias(String alias) {
    return $ParticipantHandleLinksTable(attachedDatabase, alias);
  }
}

class ParticipantHandleLink extends DataClass
    implements Insertable<ParticipantHandleLink> {
  final int participantId;
  final int importHandleId;
  const ParticipantHandleLink({
    required this.participantId,
    required this.importHandleId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['participant_id'] = Variable<int>(participantId);
    map['import_handle_id'] = Variable<int>(importHandleId);
    return map;
  }

  ParticipantHandleLinksCompanion toCompanion(bool nullToAbsent) {
    return ParticipantHandleLinksCompanion(
      participantId: Value(participantId),
      importHandleId: Value(importHandleId),
    );
  }

  factory ParticipantHandleLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParticipantHandleLink(
      participantId: serializer.fromJson<int>(json['participantId']),
      importHandleId: serializer.fromJson<int>(json['importHandleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'participantId': serializer.toJson<int>(participantId),
      'importHandleId': serializer.toJson<int>(importHandleId),
    };
  }

  ParticipantHandleLink copyWith({int? participantId, int? importHandleId}) =>
      ParticipantHandleLink(
        participantId: participantId ?? this.participantId,
        importHandleId: importHandleId ?? this.importHandleId,
      );
  ParticipantHandleLink copyWithCompanion(
    ParticipantHandleLinksCompanion data,
  ) {
    return ParticipantHandleLink(
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      importHandleId: data.importHandleId.present
          ? data.importHandleId.value
          : this.importHandleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantHandleLink(')
          ..write('participantId: $participantId, ')
          ..write('importHandleId: $importHandleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(participantId, importHandleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParticipantHandleLink &&
          other.participantId == this.participantId &&
          other.importHandleId == this.importHandleId);
}

class ParticipantHandleLinksCompanion
    extends UpdateCompanion<ParticipantHandleLink> {
  final Value<int> participantId;
  final Value<int> importHandleId;
  final Value<int> rowid;
  const ParticipantHandleLinksCompanion({
    this.participantId = const Value.absent(),
    this.importHandleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParticipantHandleLinksCompanion.insert({
    required int participantId,
    required int importHandleId,
    this.rowid = const Value.absent(),
  }) : participantId = Value(participantId),
       importHandleId = Value(importHandleId);
  static Insertable<ParticipantHandleLink> custom({
    Expression<int>? participantId,
    Expression<int>? importHandleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (participantId != null) 'participant_id': participantId,
      if (importHandleId != null) 'import_handle_id': importHandleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParticipantHandleLinksCompanion copyWith({
    Value<int>? participantId,
    Value<int>? importHandleId,
    Value<int>? rowid,
  }) {
    return ParticipantHandleLinksCompanion(
      participantId: participantId ?? this.participantId,
      importHandleId: importHandleId ?? this.importHandleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (importHandleId.present) {
      map['import_handle_id'] = Variable<int>(importHandleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantHandleLinksCompanion(')
          ..write('participantId: $participantId, ')
          ..write('importHandleId: $importHandleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkingChatsTable extends WorkingChats
    with TableInfo<$WorkingChatsTable, WorkingChat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingChatsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'Unknown\' CHECK(service IN (\'iMessage\',\'iMessageLite\',\'SMS\',\'RCS\',\'Unknown\'))',
    defaultValue: const CustomExpression('\'Unknown\''),
  );
  static const VerificationMeta _isGroupMeta = const VerificationMeta(
    'isGroup',
  );
  @override
  late final GeneratedColumn<bool> isGroup = GeneratedColumn<bool>(
    'is_group',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_group" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastMessageAtUtcMeta = const VerificationMeta(
    'lastMessageAtUtc',
  );
  @override
  late final GeneratedColumn<String> lastMessageAtUtc = GeneratedColumn<String>(
    'last_message_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSenderParticipantIdMeta =
      const VerificationMeta('lastSenderParticipantId');
  @override
  late final GeneratedColumn<int> lastSenderParticipantId =
      GeneratedColumn<int>(
        'last_sender_participant_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES participants (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  @override
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>(
        'last_message_preview',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mutedUntilUtcMeta = const VerificationMeta(
    'mutedUntilUtc',
  );
  @override
  late final GeneratedColumn<String> mutedUntilUtc = GeneratedColumn<String>(
    'muted_until_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favouriteMeta = const VerificationMeta(
    'favourite',
  );
  @override
  late final GeneratedColumn<bool> favourite = GeneratedColumn<bool>(
    'favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
    'created_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    guid,
    service,
    isGroup,
    lastMessageAtUtc,
    lastSenderParticipantId,
    lastMessagePreview,
    unreadCount,
    pinned,
    archived,
    mutedUntilUtc,
    favourite,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingChat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    }
    if (data.containsKey('is_group')) {
      context.handle(
        _isGroupMeta,
        isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta),
      );
    }
    if (data.containsKey('last_message_at_utc')) {
      context.handle(
        _lastMessageAtUtcMeta,
        lastMessageAtUtc.isAcceptableOrUnknown(
          data['last_message_at_utc']!,
          _lastMessageAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('last_sender_participant_id')) {
      context.handle(
        _lastSenderParticipantIdMeta,
        lastSenderParticipantId.isAcceptableOrUnknown(
          data['last_sender_participant_id']!,
          _lastSenderParticipantIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
        _lastMessagePreviewMeta,
        lastMessagePreview.isAcceptableOrUnknown(
          data['last_message_preview']!,
          _lastMessagePreviewMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('muted_until_utc')) {
      context.handle(
        _mutedUntilUtcMeta,
        mutedUntilUtc.isAcceptableOrUnknown(
          data['muted_until_utc']!,
          _mutedUntilUtcMeta,
        ),
      );
    }
    if (data.containsKey('favourite')) {
      context.handle(
        _favouriteMeta,
        favourite.isAcceptableOrUnknown(data['favourite']!, _favouriteMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {guid},
  ];
  @override
  WorkingChat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingChat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      isGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_group'],
      )!,
      lastMessageAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_at_utc'],
      ),
      lastSenderParticipantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sender_participant_id'],
      ),
      lastMessagePreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_preview'],
      ),
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      mutedUntilUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muted_until_utc'],
      ),
      favourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favourite'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      ),
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      ),
    );
  }

  @override
  $WorkingChatsTable createAlias(String alias) {
    return $WorkingChatsTable(attachedDatabase, alias);
  }
}

class WorkingChat extends DataClass implements Insertable<WorkingChat> {
  final int id;
  final String guid;
  final String service;
  final bool isGroup;
  final String? lastMessageAtUtc;
  final int? lastSenderParticipantId;
  final String? lastMessagePreview;
  final int unreadCount;
  final bool pinned;
  final bool archived;
  final String? mutedUntilUtc;
  final bool favourite;
  final String? createdAtUtc;
  final String? updatedAtUtc;
  const WorkingChat({
    required this.id,
    required this.guid,
    required this.service,
    required this.isGroup,
    this.lastMessageAtUtc,
    this.lastSenderParticipantId,
    this.lastMessagePreview,
    required this.unreadCount,
    required this.pinned,
    required this.archived,
    this.mutedUntilUtc,
    required this.favourite,
    this.createdAtUtc,
    this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['guid'] = Variable<String>(guid);
    map['service'] = Variable<String>(service);
    map['is_group'] = Variable<bool>(isGroup);
    if (!nullToAbsent || lastMessageAtUtc != null) {
      map['last_message_at_utc'] = Variable<String>(lastMessageAtUtc);
    }
    if (!nullToAbsent || lastSenderParticipantId != null) {
      map['last_sender_participant_id'] = Variable<int>(
        lastSenderParticipantId,
      );
    }
    if (!nullToAbsent || lastMessagePreview != null) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['pinned'] = Variable<bool>(pinned);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || mutedUntilUtc != null) {
      map['muted_until_utc'] = Variable<String>(mutedUntilUtc);
    }
    map['favourite'] = Variable<bool>(favourite);
    if (!nullToAbsent || createdAtUtc != null) {
      map['created_at_utc'] = Variable<String>(createdAtUtc);
    }
    if (!nullToAbsent || updatedAtUtc != null) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    }
    return map;
  }

  WorkingChatsCompanion toCompanion(bool nullToAbsent) {
    return WorkingChatsCompanion(
      id: Value(id),
      guid: Value(guid),
      service: Value(service),
      isGroup: Value(isGroup),
      lastMessageAtUtc: lastMessageAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAtUtc),
      lastSenderParticipantId: lastSenderParticipantId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSenderParticipantId),
      lastMessagePreview: lastMessagePreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagePreview),
      unreadCount: Value(unreadCount),
      pinned: Value(pinned),
      archived: Value(archived),
      mutedUntilUtc: mutedUntilUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(mutedUntilUtc),
      favourite: Value(favourite),
      createdAtUtc: createdAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAtUtc),
      updatedAtUtc: updatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtUtc),
    );
  }

  factory WorkingChat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingChat(
      id: serializer.fromJson<int>(json['id']),
      guid: serializer.fromJson<String>(json['guid']),
      service: serializer.fromJson<String>(json['service']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      lastMessageAtUtc: serializer.fromJson<String?>(json['lastMessageAtUtc']),
      lastSenderParticipantId: serializer.fromJson<int?>(
        json['lastSenderParticipantId'],
      ),
      lastMessagePreview: serializer.fromJson<String?>(
        json['lastMessagePreview'],
      ),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      archived: serializer.fromJson<bool>(json['archived']),
      mutedUntilUtc: serializer.fromJson<String?>(json['mutedUntilUtc']),
      favourite: serializer.fromJson<bool>(json['favourite']),
      createdAtUtc: serializer.fromJson<String?>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String?>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'guid': serializer.toJson<String>(guid),
      'service': serializer.toJson<String>(service),
      'isGroup': serializer.toJson<bool>(isGroup),
      'lastMessageAtUtc': serializer.toJson<String?>(lastMessageAtUtc),
      'lastSenderParticipantId': serializer.toJson<int?>(
        lastSenderParticipantId,
      ),
      'lastMessagePreview': serializer.toJson<String?>(lastMessagePreview),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'pinned': serializer.toJson<bool>(pinned),
      'archived': serializer.toJson<bool>(archived),
      'mutedUntilUtc': serializer.toJson<String?>(mutedUntilUtc),
      'favourite': serializer.toJson<bool>(favourite),
      'createdAtUtc': serializer.toJson<String?>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String?>(updatedAtUtc),
    };
  }

  WorkingChat copyWith({
    int? id,
    String? guid,
    String? service,
    bool? isGroup,
    Value<String?> lastMessageAtUtc = const Value.absent(),
    Value<int?> lastSenderParticipantId = const Value.absent(),
    Value<String?> lastMessagePreview = const Value.absent(),
    int? unreadCount,
    bool? pinned,
    bool? archived,
    Value<String?> mutedUntilUtc = const Value.absent(),
    bool? favourite,
    Value<String?> createdAtUtc = const Value.absent(),
    Value<String?> updatedAtUtc = const Value.absent(),
  }) => WorkingChat(
    id: id ?? this.id,
    guid: guid ?? this.guid,
    service: service ?? this.service,
    isGroup: isGroup ?? this.isGroup,
    lastMessageAtUtc: lastMessageAtUtc.present
        ? lastMessageAtUtc.value
        : this.lastMessageAtUtc,
    lastSenderParticipantId: lastSenderParticipantId.present
        ? lastSenderParticipantId.value
        : this.lastSenderParticipantId,
    lastMessagePreview: lastMessagePreview.present
        ? lastMessagePreview.value
        : this.lastMessagePreview,
    unreadCount: unreadCount ?? this.unreadCount,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    mutedUntilUtc: mutedUntilUtc.present
        ? mutedUntilUtc.value
        : this.mutedUntilUtc,
    favourite: favourite ?? this.favourite,
    createdAtUtc: createdAtUtc.present ? createdAtUtc.value : this.createdAtUtc,
    updatedAtUtc: updatedAtUtc.present ? updatedAtUtc.value : this.updatedAtUtc,
  );
  WorkingChat copyWithCompanion(WorkingChatsCompanion data) {
    return WorkingChat(
      id: data.id.present ? data.id.value : this.id,
      guid: data.guid.present ? data.guid.value : this.guid,
      service: data.service.present ? data.service.value : this.service,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      lastMessageAtUtc: data.lastMessageAtUtc.present
          ? data.lastMessageAtUtc.value
          : this.lastMessageAtUtc,
      lastSenderParticipantId: data.lastSenderParticipantId.present
          ? data.lastSenderParticipantId.value
          : this.lastSenderParticipantId,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      archived: data.archived.present ? data.archived.value : this.archived,
      mutedUntilUtc: data.mutedUntilUtc.present
          ? data.mutedUntilUtc.value
          : this.mutedUntilUtc,
      favourite: data.favourite.present ? data.favourite.value : this.favourite,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingChat(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('service: $service, ')
          ..write('isGroup: $isGroup, ')
          ..write('lastMessageAtUtc: $lastMessageAtUtc, ')
          ..write('lastSenderParticipantId: $lastSenderParticipantId, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('mutedUntilUtc: $mutedUntilUtc, ')
          ..write('favourite: $favourite, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    guid,
    service,
    isGroup,
    lastMessageAtUtc,
    lastSenderParticipantId,
    lastMessagePreview,
    unreadCount,
    pinned,
    archived,
    mutedUntilUtc,
    favourite,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingChat &&
          other.id == this.id &&
          other.guid == this.guid &&
          other.service == this.service &&
          other.isGroup == this.isGroup &&
          other.lastMessageAtUtc == this.lastMessageAtUtc &&
          other.lastSenderParticipantId == this.lastSenderParticipantId &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.unreadCount == this.unreadCount &&
          other.pinned == this.pinned &&
          other.archived == this.archived &&
          other.mutedUntilUtc == this.mutedUntilUtc &&
          other.favourite == this.favourite &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class WorkingChatsCompanion extends UpdateCompanion<WorkingChat> {
  final Value<int> id;
  final Value<String> guid;
  final Value<String> service;
  final Value<bool> isGroup;
  final Value<String?> lastMessageAtUtc;
  final Value<int?> lastSenderParticipantId;
  final Value<String?> lastMessagePreview;
  final Value<int> unreadCount;
  final Value<bool> pinned;
  final Value<bool> archived;
  final Value<String?> mutedUntilUtc;
  final Value<bool> favourite;
  final Value<String?> createdAtUtc;
  final Value<String?> updatedAtUtc;
  const WorkingChatsCompanion({
    this.id = const Value.absent(),
    this.guid = const Value.absent(),
    this.service = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.lastMessageAtUtc = const Value.absent(),
    this.lastSenderParticipantId = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.mutedUntilUtc = const Value.absent(),
    this.favourite = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  WorkingChatsCompanion.insert({
    this.id = const Value.absent(),
    required String guid,
    this.service = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.lastMessageAtUtc = const Value.absent(),
    this.lastSenderParticipantId = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.mutedUntilUtc = const Value.absent(),
    this.favourite = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  }) : guid = Value(guid);
  static Insertable<WorkingChat> custom({
    Expression<int>? id,
    Expression<String>? guid,
    Expression<String>? service,
    Expression<bool>? isGroup,
    Expression<String>? lastMessageAtUtc,
    Expression<int>? lastSenderParticipantId,
    Expression<String>? lastMessagePreview,
    Expression<int>? unreadCount,
    Expression<bool>? pinned,
    Expression<bool>? archived,
    Expression<String>? mutedUntilUtc,
    Expression<bool>? favourite,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (guid != null) 'guid': guid,
      if (service != null) 'service': service,
      if (isGroup != null) 'is_group': isGroup,
      if (lastMessageAtUtc != null) 'last_message_at_utc': lastMessageAtUtc,
      if (lastSenderParticipantId != null)
        'last_sender_participant_id': lastSenderParticipantId,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (pinned != null) 'pinned': pinned,
      if (archived != null) 'archived': archived,
      if (mutedUntilUtc != null) 'muted_until_utc': mutedUntilUtc,
      if (favourite != null) 'favourite': favourite,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  WorkingChatsCompanion copyWith({
    Value<int>? id,
    Value<String>? guid,
    Value<String>? service,
    Value<bool>? isGroup,
    Value<String?>? lastMessageAtUtc,
    Value<int?>? lastSenderParticipantId,
    Value<String?>? lastMessagePreview,
    Value<int>? unreadCount,
    Value<bool>? pinned,
    Value<bool>? archived,
    Value<String?>? mutedUntilUtc,
    Value<bool>? favourite,
    Value<String?>? createdAtUtc,
    Value<String?>? updatedAtUtc,
  }) {
    return WorkingChatsCompanion(
      id: id ?? this.id,
      guid: guid ?? this.guid,
      service: service ?? this.service,
      isGroup: isGroup ?? this.isGroup,
      lastMessageAtUtc: lastMessageAtUtc ?? this.lastMessageAtUtc,
      lastSenderParticipantId:
          lastSenderParticipantId ?? this.lastSenderParticipantId,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      unreadCount: unreadCount ?? this.unreadCount,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      mutedUntilUtc: mutedUntilUtc ?? this.mutedUntilUtc,
      favourite: favourite ?? this.favourite,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (lastMessageAtUtc.present) {
      map['last_message_at_utc'] = Variable<String>(lastMessageAtUtc.value);
    }
    if (lastSenderParticipantId.present) {
      map['last_sender_participant_id'] = Variable<int>(
        lastSenderParticipantId.value,
      );
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (mutedUntilUtc.present) {
      map['muted_until_utc'] = Variable<String>(mutedUntilUtc.value);
    }
    if (favourite.present) {
      map['favourite'] = Variable<bool>(favourite.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingChatsCompanion(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('service: $service, ')
          ..write('isGroup: $isGroup, ')
          ..write('lastMessageAtUtc: $lastMessageAtUtc, ')
          ..write('lastSenderParticipantId: $lastSenderParticipantId, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('mutedUntilUtc: $mutedUntilUtc, ')
          ..write('favourite: $favourite, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $ChatToParticipantTable extends ChatToParticipant
    with TableInfo<$ChatToParticipantTable, ChatToParticipantData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatToParticipantTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES participants (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'member\' CHECK(role IN (\'member\',\'owner\',\'unknown\'))',
    defaultValue: const CustomExpression('\'member\''),
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta(
    'sortKey',
  );
  @override
  late final GeneratedColumn<int> sortKey = GeneratedColumn<int>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [chatId, participantId, role, sortKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_to_participant';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatToParticipantData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
        _participantIdMeta,
        participantId.isAcceptableOrUnknown(
          data['participant_id']!,
          _participantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('sort_key')) {
      context.handle(
        _sortKeyMeta,
        sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, participantId};
  @override
  ChatToParticipantData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatToParticipantData(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      sortKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_key'],
      )!,
    );
  }

  @override
  $ChatToParticipantTable createAlias(String alias) {
    return $ChatToParticipantTable(attachedDatabase, alias);
  }
}

class ChatToParticipantData extends DataClass
    implements Insertable<ChatToParticipantData> {
  final int chatId;
  final int participantId;
  final String role;
  final int sortKey;
  const ChatToParticipantData({
    required this.chatId,
    required this.participantId,
    required this.role,
    required this.sortKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    map['participant_id'] = Variable<int>(participantId);
    map['role'] = Variable<String>(role);
    map['sort_key'] = Variable<int>(sortKey);
    return map;
  }

  ChatToParticipantCompanion toCompanion(bool nullToAbsent) {
    return ChatToParticipantCompanion(
      chatId: Value(chatId),
      participantId: Value(participantId),
      role: Value(role),
      sortKey: Value(sortKey),
    );
  }

  factory ChatToParticipantData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatToParticipantData(
      chatId: serializer.fromJson<int>(json['chatId']),
      participantId: serializer.fromJson<int>(json['participantId']),
      role: serializer.fromJson<String>(json['role']),
      sortKey: serializer.fromJson<int>(json['sortKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'participantId': serializer.toJson<int>(participantId),
      'role': serializer.toJson<String>(role),
      'sortKey': serializer.toJson<int>(sortKey),
    };
  }

  ChatToParticipantData copyWith({
    int? chatId,
    int? participantId,
    String? role,
    int? sortKey,
  }) => ChatToParticipantData(
    chatId: chatId ?? this.chatId,
    participantId: participantId ?? this.participantId,
    role: role ?? this.role,
    sortKey: sortKey ?? this.sortKey,
  );
  ChatToParticipantData copyWithCompanion(ChatToParticipantCompanion data) {
    return ChatToParticipantData(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      role: data.role.present ? data.role.value : this.role,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatToParticipantData(')
          ..write('chatId: $chatId, ')
          ..write('participantId: $participantId, ')
          ..write('role: $role, ')
          ..write('sortKey: $sortKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, participantId, role, sortKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatToParticipantData &&
          other.chatId == this.chatId &&
          other.participantId == this.participantId &&
          other.role == this.role &&
          other.sortKey == this.sortKey);
}

class ChatToParticipantCompanion
    extends UpdateCompanion<ChatToParticipantData> {
  final Value<int> chatId;
  final Value<int> participantId;
  final Value<String> role;
  final Value<int> sortKey;
  final Value<int> rowid;
  const ChatToParticipantCompanion({
    this.chatId = const Value.absent(),
    this.participantId = const Value.absent(),
    this.role = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatToParticipantCompanion.insert({
    required int chatId,
    required int participantId,
    this.role = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chatId = Value(chatId),
       participantId = Value(participantId);
  static Insertable<ChatToParticipantData> custom({
    Expression<int>? chatId,
    Expression<int>? participantId,
    Expression<String>? role,
    Expression<int>? sortKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (participantId != null) 'participant_id': participantId,
      if (role != null) 'role': role,
      if (sortKey != null) 'sort_key': sortKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatToParticipantCompanion copyWith({
    Value<int>? chatId,
    Value<int>? participantId,
    Value<String>? role,
    Value<int>? sortKey,
    Value<int>? rowid,
  }) {
    return ChatToParticipantCompanion(
      chatId: chatId ?? this.chatId,
      participantId: participantId ?? this.participantId,
      role: role ?? this.role,
      sortKey: sortKey ?? this.sortKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<int>(sortKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatToParticipantCompanion(')
          ..write('chatId: $chatId, ')
          ..write('participantId: $participantId, ')
          ..write('role: $role, ')
          ..write('sortKey: $sortKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkingMessagesTable extends WorkingMessages
    with TableInfo<$WorkingMessagesTable, WorkingMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingMessagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _senderParticipantIdMeta =
      const VerificationMeta('senderParticipantId');
  @override
  late final GeneratedColumn<int> senderParticipantId = GeneratedColumn<int>(
    'sender_participant_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES participants (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _isFromMeMeta = const VerificationMeta(
    'isFromMe',
  );
  @override
  late final GeneratedColumn<bool> isFromMe = GeneratedColumn<bool>(
    'is_from_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_from_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sentAtUtcMeta = const VerificationMeta(
    'sentAtUtc',
  );
  @override
  late final GeneratedColumn<String> sentAtUtc = GeneratedColumn<String>(
    'sent_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveredAtUtcMeta = const VerificationMeta(
    'deliveredAtUtc',
  );
  @override
  late final GeneratedColumn<String> deliveredAtUtc = GeneratedColumn<String>(
    'delivered_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtUtcMeta = const VerificationMeta(
    'readAtUtc',
  );
  @override
  late final GeneratedColumn<String> readAtUtc = GeneratedColumn<String>(
    'read_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'unknown\' CHECK(status IN (\'unknown\',\'sent\',\'delivered\',\'read\',\'failed\'))',
    defaultValue: const CustomExpression('\'unknown\''),
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasAttachmentsMeta = const VerificationMeta(
    'hasAttachments',
  );
  @override
  late final GeneratedColumn<bool> hasAttachments = GeneratedColumn<bool>(
    'has_attachments',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_attachments" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _replyToGuidMeta = const VerificationMeta(
    'replyToGuid',
  );
  @override
  late final GeneratedColumn<String> replyToGuid = GeneratedColumn<String>(
    'reply_to_guid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _systemTypeMeta = const VerificationMeta(
    'systemType',
  );
  @override
  late final GeneratedColumn<String> systemType = GeneratedColumn<String>(
    'system_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reactionCarrierMeta = const VerificationMeta(
    'reactionCarrier',
  );
  @override
  late final GeneratedColumn<bool> reactionCarrier = GeneratedColumn<bool>(
    'reaction_carrier',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reaction_carrier" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _balloonBundleIdMeta = const VerificationMeta(
    'balloonBundleId',
  );
  @override
  late final GeneratedColumn<String> balloonBundleId = GeneratedColumn<String>(
    'balloon_bundle_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reactionSummaryJsonMeta =
      const VerificationMeta('reactionSummaryJson');
  @override
  late final GeneratedColumn<String> reactionSummaryJson =
      GeneratedColumn<String>(
        'reaction_summary_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedLocalMeta = const VerificationMeta(
    'isDeletedLocal',
  );
  @override
  late final GeneratedColumn<bool> isDeletedLocal = GeneratedColumn<bool>(
    'is_deleted_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted_local" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    guid,
    chatId,
    senderParticipantId,
    isFromMe,
    sentAtUtc,
    deliveredAtUtc,
    readAtUtc,
    status,
    textContent,
    hasAttachments,
    replyToGuid,
    systemType,
    reactionCarrier,
    balloonBundleId,
    reactionSummaryJson,
    isStarred,
    isDeletedLocal,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_participant_id')) {
      context.handle(
        _senderParticipantIdMeta,
        senderParticipantId.isAcceptableOrUnknown(
          data['sender_participant_id']!,
          _senderParticipantIdMeta,
        ),
      );
    }
    if (data.containsKey('is_from_me')) {
      context.handle(
        _isFromMeMeta,
        isFromMe.isAcceptableOrUnknown(data['is_from_me']!, _isFromMeMeta),
      );
    }
    if (data.containsKey('sent_at_utc')) {
      context.handle(
        _sentAtUtcMeta,
        sentAtUtc.isAcceptableOrUnknown(data['sent_at_utc']!, _sentAtUtcMeta),
      );
    }
    if (data.containsKey('delivered_at_utc')) {
      context.handle(
        _deliveredAtUtcMeta,
        deliveredAtUtc.isAcceptableOrUnknown(
          data['delivered_at_utc']!,
          _deliveredAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('read_at_utc')) {
      context.handle(
        _readAtUtcMeta,
        readAtUtc.isAcceptableOrUnknown(data['read_at_utc']!, _readAtUtcMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(data['text']!, _textContentMeta),
      );
    }
    if (data.containsKey('has_attachments')) {
      context.handle(
        _hasAttachmentsMeta,
        hasAttachments.isAcceptableOrUnknown(
          data['has_attachments']!,
          _hasAttachmentsMeta,
        ),
      );
    }
    if (data.containsKey('reply_to_guid')) {
      context.handle(
        _replyToGuidMeta,
        replyToGuid.isAcceptableOrUnknown(
          data['reply_to_guid']!,
          _replyToGuidMeta,
        ),
      );
    }
    if (data.containsKey('system_type')) {
      context.handle(
        _systemTypeMeta,
        systemType.isAcceptableOrUnknown(data['system_type']!, _systemTypeMeta),
      );
    }
    if (data.containsKey('reaction_carrier')) {
      context.handle(
        _reactionCarrierMeta,
        reactionCarrier.isAcceptableOrUnknown(
          data['reaction_carrier']!,
          _reactionCarrierMeta,
        ),
      );
    }
    if (data.containsKey('balloon_bundle_id')) {
      context.handle(
        _balloonBundleIdMeta,
        balloonBundleId.isAcceptableOrUnknown(
          data['balloon_bundle_id']!,
          _balloonBundleIdMeta,
        ),
      );
    }
    if (data.containsKey('reaction_summary_json')) {
      context.handle(
        _reactionSummaryJsonMeta,
        reactionSummaryJson.isAcceptableOrUnknown(
          data['reaction_summary_json']!,
          _reactionSummaryJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('is_deleted_local')) {
      context.handle(
        _isDeletedLocalMeta,
        isDeletedLocal.isAcceptableOrUnknown(
          data['is_deleted_local']!,
          _isDeletedLocalMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {guid},
  ];
  @override
  WorkingMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      senderParticipantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sender_participant_id'],
      ),
      isFromMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_from_me'],
      )!,
      sentAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sent_at_utc'],
      ),
      deliveredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivered_at_utc'],
      ),
      readAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}read_at_utc'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      ),
      hasAttachments: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_attachments'],
      )!,
      replyToGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_to_guid'],
      ),
      systemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_type'],
      ),
      reactionCarrier: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reaction_carrier'],
      )!,
      balloonBundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}balloon_bundle_id'],
      ),
      reactionSummaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reaction_summary_json'],
      ),
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      isDeletedLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted_local'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      ),
    );
  }

  @override
  $WorkingMessagesTable createAlias(String alias) {
    return $WorkingMessagesTable(attachedDatabase, alias);
  }
}

class WorkingMessage extends DataClass implements Insertable<WorkingMessage> {
  final int id;
  final String guid;
  final int chatId;
  final int? senderParticipantId;
  final bool isFromMe;
  final String? sentAtUtc;
  final String? deliveredAtUtc;
  final String? readAtUtc;
  final String status;
  final String? textContent;
  final bool hasAttachments;
  final String? replyToGuid;
  final String? systemType;
  final bool reactionCarrier;
  final String? balloonBundleId;
  final String? reactionSummaryJson;
  final bool isStarred;
  final bool isDeletedLocal;
  final String? updatedAtUtc;
  const WorkingMessage({
    required this.id,
    required this.guid,
    required this.chatId,
    this.senderParticipantId,
    required this.isFromMe,
    this.sentAtUtc,
    this.deliveredAtUtc,
    this.readAtUtc,
    required this.status,
    this.textContent,
    required this.hasAttachments,
    this.replyToGuid,
    this.systemType,
    required this.reactionCarrier,
    this.balloonBundleId,
    this.reactionSummaryJson,
    required this.isStarred,
    required this.isDeletedLocal,
    this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['guid'] = Variable<String>(guid);
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || senderParticipantId != null) {
      map['sender_participant_id'] = Variable<int>(senderParticipantId);
    }
    map['is_from_me'] = Variable<bool>(isFromMe);
    if (!nullToAbsent || sentAtUtc != null) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc);
    }
    if (!nullToAbsent || deliveredAtUtc != null) {
      map['delivered_at_utc'] = Variable<String>(deliveredAtUtc);
    }
    if (!nullToAbsent || readAtUtc != null) {
      map['read_at_utc'] = Variable<String>(readAtUtc);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || textContent != null) {
      map['text'] = Variable<String>(textContent);
    }
    map['has_attachments'] = Variable<bool>(hasAttachments);
    if (!nullToAbsent || replyToGuid != null) {
      map['reply_to_guid'] = Variable<String>(replyToGuid);
    }
    if (!nullToAbsent || systemType != null) {
      map['system_type'] = Variable<String>(systemType);
    }
    map['reaction_carrier'] = Variable<bool>(reactionCarrier);
    if (!nullToAbsent || balloonBundleId != null) {
      map['balloon_bundle_id'] = Variable<String>(balloonBundleId);
    }
    if (!nullToAbsent || reactionSummaryJson != null) {
      map['reaction_summary_json'] = Variable<String>(reactionSummaryJson);
    }
    map['is_starred'] = Variable<bool>(isStarred);
    map['is_deleted_local'] = Variable<bool>(isDeletedLocal);
    if (!nullToAbsent || updatedAtUtc != null) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    }
    return map;
  }

  WorkingMessagesCompanion toCompanion(bool nullToAbsent) {
    return WorkingMessagesCompanion(
      id: Value(id),
      guid: Value(guid),
      chatId: Value(chatId),
      senderParticipantId: senderParticipantId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderParticipantId),
      isFromMe: Value(isFromMe),
      sentAtUtc: sentAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAtUtc),
      deliveredAtUtc: deliveredAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAtUtc),
      readAtUtc: readAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(readAtUtc),
      status: Value(status),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      hasAttachments: Value(hasAttachments),
      replyToGuid: replyToGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToGuid),
      systemType: systemType == null && nullToAbsent
          ? const Value.absent()
          : Value(systemType),
      reactionCarrier: Value(reactionCarrier),
      balloonBundleId: balloonBundleId == null && nullToAbsent
          ? const Value.absent()
          : Value(balloonBundleId),
      reactionSummaryJson: reactionSummaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(reactionSummaryJson),
      isStarred: Value(isStarred),
      isDeletedLocal: Value(isDeletedLocal),
      updatedAtUtc: updatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtUtc),
    );
  }

  factory WorkingMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingMessage(
      id: serializer.fromJson<int>(json['id']),
      guid: serializer.fromJson<String>(json['guid']),
      chatId: serializer.fromJson<int>(json['chatId']),
      senderParticipantId: serializer.fromJson<int?>(
        json['senderParticipantId'],
      ),
      isFromMe: serializer.fromJson<bool>(json['isFromMe']),
      sentAtUtc: serializer.fromJson<String?>(json['sentAtUtc']),
      deliveredAtUtc: serializer.fromJson<String?>(json['deliveredAtUtc']),
      readAtUtc: serializer.fromJson<String?>(json['readAtUtc']),
      status: serializer.fromJson<String>(json['status']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      hasAttachments: serializer.fromJson<bool>(json['hasAttachments']),
      replyToGuid: serializer.fromJson<String?>(json['replyToGuid']),
      systemType: serializer.fromJson<String?>(json['systemType']),
      reactionCarrier: serializer.fromJson<bool>(json['reactionCarrier']),
      balloonBundleId: serializer.fromJson<String?>(json['balloonBundleId']),
      reactionSummaryJson: serializer.fromJson<String?>(
        json['reactionSummaryJson'],
      ),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      isDeletedLocal: serializer.fromJson<bool>(json['isDeletedLocal']),
      updatedAtUtc: serializer.fromJson<String?>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'guid': serializer.toJson<String>(guid),
      'chatId': serializer.toJson<int>(chatId),
      'senderParticipantId': serializer.toJson<int?>(senderParticipantId),
      'isFromMe': serializer.toJson<bool>(isFromMe),
      'sentAtUtc': serializer.toJson<String?>(sentAtUtc),
      'deliveredAtUtc': serializer.toJson<String?>(deliveredAtUtc),
      'readAtUtc': serializer.toJson<String?>(readAtUtc),
      'status': serializer.toJson<String>(status),
      'textContent': serializer.toJson<String?>(textContent),
      'hasAttachments': serializer.toJson<bool>(hasAttachments),
      'replyToGuid': serializer.toJson<String?>(replyToGuid),
      'systemType': serializer.toJson<String?>(systemType),
      'reactionCarrier': serializer.toJson<bool>(reactionCarrier),
      'balloonBundleId': serializer.toJson<String?>(balloonBundleId),
      'reactionSummaryJson': serializer.toJson<String?>(reactionSummaryJson),
      'isStarred': serializer.toJson<bool>(isStarred),
      'isDeletedLocal': serializer.toJson<bool>(isDeletedLocal),
      'updatedAtUtc': serializer.toJson<String?>(updatedAtUtc),
    };
  }

  WorkingMessage copyWith({
    int? id,
    String? guid,
    int? chatId,
    Value<int?> senderParticipantId = const Value.absent(),
    bool? isFromMe,
    Value<String?> sentAtUtc = const Value.absent(),
    Value<String?> deliveredAtUtc = const Value.absent(),
    Value<String?> readAtUtc = const Value.absent(),
    String? status,
    Value<String?> textContent = const Value.absent(),
    bool? hasAttachments,
    Value<String?> replyToGuid = const Value.absent(),
    Value<String?> systemType = const Value.absent(),
    bool? reactionCarrier,
    Value<String?> balloonBundleId = const Value.absent(),
    Value<String?> reactionSummaryJson = const Value.absent(),
    bool? isStarred,
    bool? isDeletedLocal,
    Value<String?> updatedAtUtc = const Value.absent(),
  }) => WorkingMessage(
    id: id ?? this.id,
    guid: guid ?? this.guid,
    chatId: chatId ?? this.chatId,
    senderParticipantId: senderParticipantId.present
        ? senderParticipantId.value
        : this.senderParticipantId,
    isFromMe: isFromMe ?? this.isFromMe,
    sentAtUtc: sentAtUtc.present ? sentAtUtc.value : this.sentAtUtc,
    deliveredAtUtc: deliveredAtUtc.present
        ? deliveredAtUtc.value
        : this.deliveredAtUtc,
    readAtUtc: readAtUtc.present ? readAtUtc.value : this.readAtUtc,
    status: status ?? this.status,
    textContent: textContent.present ? textContent.value : this.textContent,
    hasAttachments: hasAttachments ?? this.hasAttachments,
    replyToGuid: replyToGuid.present ? replyToGuid.value : this.replyToGuid,
    systemType: systemType.present ? systemType.value : this.systemType,
    reactionCarrier: reactionCarrier ?? this.reactionCarrier,
    balloonBundleId: balloonBundleId.present
        ? balloonBundleId.value
        : this.balloonBundleId,
    reactionSummaryJson: reactionSummaryJson.present
        ? reactionSummaryJson.value
        : this.reactionSummaryJson,
    isStarred: isStarred ?? this.isStarred,
    isDeletedLocal: isDeletedLocal ?? this.isDeletedLocal,
    updatedAtUtc: updatedAtUtc.present ? updatedAtUtc.value : this.updatedAtUtc,
  );
  WorkingMessage copyWithCompanion(WorkingMessagesCompanion data) {
    return WorkingMessage(
      id: data.id.present ? data.id.value : this.id,
      guid: data.guid.present ? data.guid.value : this.guid,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderParticipantId: data.senderParticipantId.present
          ? data.senderParticipantId.value
          : this.senderParticipantId,
      isFromMe: data.isFromMe.present ? data.isFromMe.value : this.isFromMe,
      sentAtUtc: data.sentAtUtc.present ? data.sentAtUtc.value : this.sentAtUtc,
      deliveredAtUtc: data.deliveredAtUtc.present
          ? data.deliveredAtUtc.value
          : this.deliveredAtUtc,
      readAtUtc: data.readAtUtc.present ? data.readAtUtc.value : this.readAtUtc,
      status: data.status.present ? data.status.value : this.status,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      hasAttachments: data.hasAttachments.present
          ? data.hasAttachments.value
          : this.hasAttachments,
      replyToGuid: data.replyToGuid.present
          ? data.replyToGuid.value
          : this.replyToGuid,
      systemType: data.systemType.present
          ? data.systemType.value
          : this.systemType,
      reactionCarrier: data.reactionCarrier.present
          ? data.reactionCarrier.value
          : this.reactionCarrier,
      balloonBundleId: data.balloonBundleId.present
          ? data.balloonBundleId.value
          : this.balloonBundleId,
      reactionSummaryJson: data.reactionSummaryJson.present
          ? data.reactionSummaryJson.value
          : this.reactionSummaryJson,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      isDeletedLocal: data.isDeletedLocal.present
          ? data.isDeletedLocal.value
          : this.isDeletedLocal,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingMessage(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('chatId: $chatId, ')
          ..write('senderParticipantId: $senderParticipantId, ')
          ..write('isFromMe: $isFromMe, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('deliveredAtUtc: $deliveredAtUtc, ')
          ..write('readAtUtc: $readAtUtc, ')
          ..write('status: $status, ')
          ..write('textContent: $textContent, ')
          ..write('hasAttachments: $hasAttachments, ')
          ..write('replyToGuid: $replyToGuid, ')
          ..write('systemType: $systemType, ')
          ..write('reactionCarrier: $reactionCarrier, ')
          ..write('balloonBundleId: $balloonBundleId, ')
          ..write('reactionSummaryJson: $reactionSummaryJson, ')
          ..write('isStarred: $isStarred, ')
          ..write('isDeletedLocal: $isDeletedLocal, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    guid,
    chatId,
    senderParticipantId,
    isFromMe,
    sentAtUtc,
    deliveredAtUtc,
    readAtUtc,
    status,
    textContent,
    hasAttachments,
    replyToGuid,
    systemType,
    reactionCarrier,
    balloonBundleId,
    reactionSummaryJson,
    isStarred,
    isDeletedLocal,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingMessage &&
          other.id == this.id &&
          other.guid == this.guid &&
          other.chatId == this.chatId &&
          other.senderParticipantId == this.senderParticipantId &&
          other.isFromMe == this.isFromMe &&
          other.sentAtUtc == this.sentAtUtc &&
          other.deliveredAtUtc == this.deliveredAtUtc &&
          other.readAtUtc == this.readAtUtc &&
          other.status == this.status &&
          other.textContent == this.textContent &&
          other.hasAttachments == this.hasAttachments &&
          other.replyToGuid == this.replyToGuid &&
          other.systemType == this.systemType &&
          other.reactionCarrier == this.reactionCarrier &&
          other.balloonBundleId == this.balloonBundleId &&
          other.reactionSummaryJson == this.reactionSummaryJson &&
          other.isStarred == this.isStarred &&
          other.isDeletedLocal == this.isDeletedLocal &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class WorkingMessagesCompanion extends UpdateCompanion<WorkingMessage> {
  final Value<int> id;
  final Value<String> guid;
  final Value<int> chatId;
  final Value<int?> senderParticipantId;
  final Value<bool> isFromMe;
  final Value<String?> sentAtUtc;
  final Value<String?> deliveredAtUtc;
  final Value<String?> readAtUtc;
  final Value<String> status;
  final Value<String?> textContent;
  final Value<bool> hasAttachments;
  final Value<String?> replyToGuid;
  final Value<String?> systemType;
  final Value<bool> reactionCarrier;
  final Value<String?> balloonBundleId;
  final Value<String?> reactionSummaryJson;
  final Value<bool> isStarred;
  final Value<bool> isDeletedLocal;
  final Value<String?> updatedAtUtc;
  const WorkingMessagesCompanion({
    this.id = const Value.absent(),
    this.guid = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderParticipantId = const Value.absent(),
    this.isFromMe = const Value.absent(),
    this.sentAtUtc = const Value.absent(),
    this.deliveredAtUtc = const Value.absent(),
    this.readAtUtc = const Value.absent(),
    this.status = const Value.absent(),
    this.textContent = const Value.absent(),
    this.hasAttachments = const Value.absent(),
    this.replyToGuid = const Value.absent(),
    this.systemType = const Value.absent(),
    this.reactionCarrier = const Value.absent(),
    this.balloonBundleId = const Value.absent(),
    this.reactionSummaryJson = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isDeletedLocal = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  WorkingMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String guid,
    required int chatId,
    this.senderParticipantId = const Value.absent(),
    this.isFromMe = const Value.absent(),
    this.sentAtUtc = const Value.absent(),
    this.deliveredAtUtc = const Value.absent(),
    this.readAtUtc = const Value.absent(),
    this.status = const Value.absent(),
    this.textContent = const Value.absent(),
    this.hasAttachments = const Value.absent(),
    this.replyToGuid = const Value.absent(),
    this.systemType = const Value.absent(),
    this.reactionCarrier = const Value.absent(),
    this.balloonBundleId = const Value.absent(),
    this.reactionSummaryJson = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isDeletedLocal = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  }) : guid = Value(guid),
       chatId = Value(chatId);
  static Insertable<WorkingMessage> custom({
    Expression<int>? id,
    Expression<String>? guid,
    Expression<int>? chatId,
    Expression<int>? senderParticipantId,
    Expression<bool>? isFromMe,
    Expression<String>? sentAtUtc,
    Expression<String>? deliveredAtUtc,
    Expression<String>? readAtUtc,
    Expression<String>? status,
    Expression<String>? textContent,
    Expression<bool>? hasAttachments,
    Expression<String>? replyToGuid,
    Expression<String>? systemType,
    Expression<bool>? reactionCarrier,
    Expression<String>? balloonBundleId,
    Expression<String>? reactionSummaryJson,
    Expression<bool>? isStarred,
    Expression<bool>? isDeletedLocal,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (guid != null) 'guid': guid,
      if (chatId != null) 'chat_id': chatId,
      if (senderParticipantId != null)
        'sender_participant_id': senderParticipantId,
      if (isFromMe != null) 'is_from_me': isFromMe,
      if (sentAtUtc != null) 'sent_at_utc': sentAtUtc,
      if (deliveredAtUtc != null) 'delivered_at_utc': deliveredAtUtc,
      if (readAtUtc != null) 'read_at_utc': readAtUtc,
      if (status != null) 'status': status,
      if (textContent != null) 'text': textContent,
      if (hasAttachments != null) 'has_attachments': hasAttachments,
      if (replyToGuid != null) 'reply_to_guid': replyToGuid,
      if (systemType != null) 'system_type': systemType,
      if (reactionCarrier != null) 'reaction_carrier': reactionCarrier,
      if (balloonBundleId != null) 'balloon_bundle_id': balloonBundleId,
      if (reactionSummaryJson != null)
        'reaction_summary_json': reactionSummaryJson,
      if (isStarred != null) 'is_starred': isStarred,
      if (isDeletedLocal != null) 'is_deleted_local': isDeletedLocal,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  WorkingMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? guid,
    Value<int>? chatId,
    Value<int?>? senderParticipantId,
    Value<bool>? isFromMe,
    Value<String?>? sentAtUtc,
    Value<String?>? deliveredAtUtc,
    Value<String?>? readAtUtc,
    Value<String>? status,
    Value<String?>? textContent,
    Value<bool>? hasAttachments,
    Value<String?>? replyToGuid,
    Value<String?>? systemType,
    Value<bool>? reactionCarrier,
    Value<String?>? balloonBundleId,
    Value<String?>? reactionSummaryJson,
    Value<bool>? isStarred,
    Value<bool>? isDeletedLocal,
    Value<String?>? updatedAtUtc,
  }) {
    return WorkingMessagesCompanion(
      id: id ?? this.id,
      guid: guid ?? this.guid,
      chatId: chatId ?? this.chatId,
      senderParticipantId: senderParticipantId ?? this.senderParticipantId,
      isFromMe: isFromMe ?? this.isFromMe,
      sentAtUtc: sentAtUtc ?? this.sentAtUtc,
      deliveredAtUtc: deliveredAtUtc ?? this.deliveredAtUtc,
      readAtUtc: readAtUtc ?? this.readAtUtc,
      status: status ?? this.status,
      textContent: textContent ?? this.textContent,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      replyToGuid: replyToGuid ?? this.replyToGuid,
      systemType: systemType ?? this.systemType,
      reactionCarrier: reactionCarrier ?? this.reactionCarrier,
      balloonBundleId: balloonBundleId ?? this.balloonBundleId,
      reactionSummaryJson: reactionSummaryJson ?? this.reactionSummaryJson,
      isStarred: isStarred ?? this.isStarred,
      isDeletedLocal: isDeletedLocal ?? this.isDeletedLocal,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (senderParticipantId.present) {
      map['sender_participant_id'] = Variable<int>(senderParticipantId.value);
    }
    if (isFromMe.present) {
      map['is_from_me'] = Variable<bool>(isFromMe.value);
    }
    if (sentAtUtc.present) {
      map['sent_at_utc'] = Variable<String>(sentAtUtc.value);
    }
    if (deliveredAtUtc.present) {
      map['delivered_at_utc'] = Variable<String>(deliveredAtUtc.value);
    }
    if (readAtUtc.present) {
      map['read_at_utc'] = Variable<String>(readAtUtc.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (textContent.present) {
      map['text'] = Variable<String>(textContent.value);
    }
    if (hasAttachments.present) {
      map['has_attachments'] = Variable<bool>(hasAttachments.value);
    }
    if (replyToGuid.present) {
      map['reply_to_guid'] = Variable<String>(replyToGuid.value);
    }
    if (systemType.present) {
      map['system_type'] = Variable<String>(systemType.value);
    }
    if (reactionCarrier.present) {
      map['reaction_carrier'] = Variable<bool>(reactionCarrier.value);
    }
    if (balloonBundleId.present) {
      map['balloon_bundle_id'] = Variable<String>(balloonBundleId.value);
    }
    if (reactionSummaryJson.present) {
      map['reaction_summary_json'] = Variable<String>(
        reactionSummaryJson.value,
      );
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (isDeletedLocal.present) {
      map['is_deleted_local'] = Variable<bool>(isDeletedLocal.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<String>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingMessagesCompanion(')
          ..write('id: $id, ')
          ..write('guid: $guid, ')
          ..write('chatId: $chatId, ')
          ..write('senderParticipantId: $senderParticipantId, ')
          ..write('isFromMe: $isFromMe, ')
          ..write('sentAtUtc: $sentAtUtc, ')
          ..write('deliveredAtUtc: $deliveredAtUtc, ')
          ..write('readAtUtc: $readAtUtc, ')
          ..write('status: $status, ')
          ..write('textContent: $textContent, ')
          ..write('hasAttachments: $hasAttachments, ')
          ..write('replyToGuid: $replyToGuid, ')
          ..write('systemType: $systemType, ')
          ..write('reactionCarrier: $reactionCarrier, ')
          ..write('balloonBundleId: $balloonBundleId, ')
          ..write('reactionSummaryJson: $reactionSummaryJson, ')
          ..write('isStarred: $isStarred, ')
          ..write('isDeletedLocal: $isDeletedLocal, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $WorkingAttachmentsTable extends WorkingAttachments
    with TableInfo<$WorkingAttachmentsTable, WorkingAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingAttachmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _messageGuidMeta = const VerificationMeta(
    'messageGuid',
  );
  @override
  late final GeneratedColumn<String> messageGuid = GeneratedColumn<String>(
    'message_guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importAttachmentIdMeta =
      const VerificationMeta('importAttachmentId');
  @override
  late final GeneratedColumn<int> importAttachmentId = GeneratedColumn<int>(
    'import_attachment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _utiMeta = const VerificationMeta('uti');
  @override
  late final GeneratedColumn<String> uti = GeneratedColumn<String>(
    'uti',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transferNameMeta = const VerificationMeta(
    'transferName',
  );
  @override
  late final GeneratedColumn<String> transferName = GeneratedColumn<String>(
    'transfer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isStickerMeta = const VerificationMeta(
    'isSticker',
  );
  @override
  late final GeneratedColumn<bool> isSticker = GeneratedColumn<bool>(
    'is_sticker',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sticker" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _thumbPathMeta = const VerificationMeta(
    'thumbPath',
  );
  @override
  late final GeneratedColumn<String> thumbPath = GeneratedColumn<String>(
    'thumb_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<String> createdAtUtc = GeneratedColumn<String>(
    'created_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageGuid,
    importAttachmentId,
    localPath,
    mimeType,
    uti,
    transferName,
    sizeBytes,
    isSticker,
    thumbPath,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_guid')) {
      context.handle(
        _messageGuidMeta,
        messageGuid.isAcceptableOrUnknown(
          data['message_guid']!,
          _messageGuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageGuidMeta);
    }
    if (data.containsKey('import_attachment_id')) {
      context.handle(
        _importAttachmentIdMeta,
        importAttachmentId.isAcceptableOrUnknown(
          data['import_attachment_id']!,
          _importAttachmentIdMeta,
        ),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('uti')) {
      context.handle(
        _utiMeta,
        uti.isAcceptableOrUnknown(data['uti']!, _utiMeta),
      );
    }
    if (data.containsKey('transfer_name')) {
      context.handle(
        _transferNameMeta,
        transferName.isAcceptableOrUnknown(
          data['transfer_name']!,
          _transferNameMeta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('is_sticker')) {
      context.handle(
        _isStickerMeta,
        isSticker.isAcceptableOrUnknown(data['is_sticker']!, _isStickerMeta),
      );
    }
    if (data.containsKey('thumb_path')) {
      context.handle(
        _thumbPathMeta,
        thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkingAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_guid'],
      )!,
      importAttachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_attachment_id'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      uti: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uti'],
      ),
      transferName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_name'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      isSticker: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sticker'],
      )!,
      thumbPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumb_path'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      ),
    );
  }

  @override
  $WorkingAttachmentsTable createAlias(String alias) {
    return $WorkingAttachmentsTable(attachedDatabase, alias);
  }
}

class WorkingAttachment extends DataClass
    implements Insertable<WorkingAttachment> {
  final int id;
  final String messageGuid;
  final int? importAttachmentId;
  final String? localPath;
  final String? mimeType;
  final String? uti;
  final String? transferName;
  final int? sizeBytes;
  final bool isSticker;
  final String? thumbPath;
  final String? createdAtUtc;
  const WorkingAttachment({
    required this.id,
    required this.messageGuid,
    this.importAttachmentId,
    this.localPath,
    this.mimeType,
    this.uti,
    this.transferName,
    this.sizeBytes,
    required this.isSticker,
    this.thumbPath,
    this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_guid'] = Variable<String>(messageGuid);
    if (!nullToAbsent || importAttachmentId != null) {
      map['import_attachment_id'] = Variable<int>(importAttachmentId);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || uti != null) {
      map['uti'] = Variable<String>(uti);
    }
    if (!nullToAbsent || transferName != null) {
      map['transfer_name'] = Variable<String>(transferName);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['is_sticker'] = Variable<bool>(isSticker);
    if (!nullToAbsent || thumbPath != null) {
      map['thumb_path'] = Variable<String>(thumbPath);
    }
    if (!nullToAbsent || createdAtUtc != null) {
      map['created_at_utc'] = Variable<String>(createdAtUtc);
    }
    return map;
  }

  WorkingAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return WorkingAttachmentsCompanion(
      id: Value(id),
      messageGuid: Value(messageGuid),
      importAttachmentId: importAttachmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(importAttachmentId),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      uti: uti == null && nullToAbsent ? const Value.absent() : Value(uti),
      transferName: transferName == null && nullToAbsent
          ? const Value.absent()
          : Value(transferName),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      isSticker: Value(isSticker),
      thumbPath: thumbPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbPath),
      createdAtUtc: createdAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAtUtc),
    );
  }

  factory WorkingAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingAttachment(
      id: serializer.fromJson<int>(json['id']),
      messageGuid: serializer.fromJson<String>(json['messageGuid']),
      importAttachmentId: serializer.fromJson<int?>(json['importAttachmentId']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      uti: serializer.fromJson<String?>(json['uti']),
      transferName: serializer.fromJson<String?>(json['transferName']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      isSticker: serializer.fromJson<bool>(json['isSticker']),
      thumbPath: serializer.fromJson<String?>(json['thumbPath']),
      createdAtUtc: serializer.fromJson<String?>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageGuid': serializer.toJson<String>(messageGuid),
      'importAttachmentId': serializer.toJson<int?>(importAttachmentId),
      'localPath': serializer.toJson<String?>(localPath),
      'mimeType': serializer.toJson<String?>(mimeType),
      'uti': serializer.toJson<String?>(uti),
      'transferName': serializer.toJson<String?>(transferName),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'isSticker': serializer.toJson<bool>(isSticker),
      'thumbPath': serializer.toJson<String?>(thumbPath),
      'createdAtUtc': serializer.toJson<String?>(createdAtUtc),
    };
  }

  WorkingAttachment copyWith({
    int? id,
    String? messageGuid,
    Value<int?> importAttachmentId = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    Value<String?> uti = const Value.absent(),
    Value<String?> transferName = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    bool? isSticker,
    Value<String?> thumbPath = const Value.absent(),
    Value<String?> createdAtUtc = const Value.absent(),
  }) => WorkingAttachment(
    id: id ?? this.id,
    messageGuid: messageGuid ?? this.messageGuid,
    importAttachmentId: importAttachmentId.present
        ? importAttachmentId.value
        : this.importAttachmentId,
    localPath: localPath.present ? localPath.value : this.localPath,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    uti: uti.present ? uti.value : this.uti,
    transferName: transferName.present ? transferName.value : this.transferName,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    isSticker: isSticker ?? this.isSticker,
    thumbPath: thumbPath.present ? thumbPath.value : this.thumbPath,
    createdAtUtc: createdAtUtc.present ? createdAtUtc.value : this.createdAtUtc,
  );
  WorkingAttachment copyWithCompanion(WorkingAttachmentsCompanion data) {
    return WorkingAttachment(
      id: data.id.present ? data.id.value : this.id,
      messageGuid: data.messageGuid.present
          ? data.messageGuid.value
          : this.messageGuid,
      importAttachmentId: data.importAttachmentId.present
          ? data.importAttachmentId.value
          : this.importAttachmentId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      uti: data.uti.present ? data.uti.value : this.uti,
      transferName: data.transferName.present
          ? data.transferName.value
          : this.transferName,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      isSticker: data.isSticker.present ? data.isSticker.value : this.isSticker,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingAttachment(')
          ..write('id: $id, ')
          ..write('messageGuid: $messageGuid, ')
          ..write('importAttachmentId: $importAttachmentId, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('uti: $uti, ')
          ..write('transferName: $transferName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('isSticker: $isSticker, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageGuid,
    importAttachmentId,
    localPath,
    mimeType,
    uti,
    transferName,
    sizeBytes,
    isSticker,
    thumbPath,
    createdAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingAttachment &&
          other.id == this.id &&
          other.messageGuid == this.messageGuid &&
          other.importAttachmentId == this.importAttachmentId &&
          other.localPath == this.localPath &&
          other.mimeType == this.mimeType &&
          other.uti == this.uti &&
          other.transferName == this.transferName &&
          other.sizeBytes == this.sizeBytes &&
          other.isSticker == this.isSticker &&
          other.thumbPath == this.thumbPath &&
          other.createdAtUtc == this.createdAtUtc);
}

class WorkingAttachmentsCompanion extends UpdateCompanion<WorkingAttachment> {
  final Value<int> id;
  final Value<String> messageGuid;
  final Value<int?> importAttachmentId;
  final Value<String?> localPath;
  final Value<String?> mimeType;
  final Value<String?> uti;
  final Value<String?> transferName;
  final Value<int?> sizeBytes;
  final Value<bool> isSticker;
  final Value<String?> thumbPath;
  final Value<String?> createdAtUtc;
  const WorkingAttachmentsCompanion({
    this.id = const Value.absent(),
    this.messageGuid = const Value.absent(),
    this.importAttachmentId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.uti = const Value.absent(),
    this.transferName = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.isSticker = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
  });
  WorkingAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required String messageGuid,
    this.importAttachmentId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.uti = const Value.absent(),
    this.transferName = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.isSticker = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
  }) : messageGuid = Value(messageGuid);
  static Insertable<WorkingAttachment> custom({
    Expression<int>? id,
    Expression<String>? messageGuid,
    Expression<int>? importAttachmentId,
    Expression<String>? localPath,
    Expression<String>? mimeType,
    Expression<String>? uti,
    Expression<String>? transferName,
    Expression<int>? sizeBytes,
    Expression<bool>? isSticker,
    Expression<String>? thumbPath,
    Expression<String>? createdAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageGuid != null) 'message_guid': messageGuid,
      if (importAttachmentId != null)
        'import_attachment_id': importAttachmentId,
      if (localPath != null) 'local_path': localPath,
      if (mimeType != null) 'mime_type': mimeType,
      if (uti != null) 'uti': uti,
      if (transferName != null) 'transfer_name': transferName,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (isSticker != null) 'is_sticker': isSticker,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
    });
  }

  WorkingAttachmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? messageGuid,
    Value<int?>? importAttachmentId,
    Value<String?>? localPath,
    Value<String?>? mimeType,
    Value<String?>? uti,
    Value<String?>? transferName,
    Value<int?>? sizeBytes,
    Value<bool>? isSticker,
    Value<String?>? thumbPath,
    Value<String?>? createdAtUtc,
  }) {
    return WorkingAttachmentsCompanion(
      id: id ?? this.id,
      messageGuid: messageGuid ?? this.messageGuid,
      importAttachmentId: importAttachmentId ?? this.importAttachmentId,
      localPath: localPath ?? this.localPath,
      mimeType: mimeType ?? this.mimeType,
      uti: uti ?? this.uti,
      transferName: transferName ?? this.transferName,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isSticker: isSticker ?? this.isSticker,
      thumbPath: thumbPath ?? this.thumbPath,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageGuid.present) {
      map['message_guid'] = Variable<String>(messageGuid.value);
    }
    if (importAttachmentId.present) {
      map['import_attachment_id'] = Variable<int>(importAttachmentId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (uti.present) {
      map['uti'] = Variable<String>(uti.value);
    }
    if (transferName.present) {
      map['transfer_name'] = Variable<String>(transferName.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (isSticker.present) {
      map['is_sticker'] = Variable<bool>(isSticker.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<String>(createdAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('messageGuid: $messageGuid, ')
          ..write('importAttachmentId: $importAttachmentId, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('uti: $uti, ')
          ..write('transferName: $transferName, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('isSticker: $isSticker, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }
}

class $WorkingReactionsTable extends WorkingReactions
    with TableInfo<$WorkingReactionsTable, WorkingReaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkingReactionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _messageGuidMeta = const VerificationMeta(
    'messageGuid',
  );
  @override
  late final GeneratedColumn<String> messageGuid = GeneratedColumn<String>(
    'message_guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK(kind IN (\'love\',\'like\',\'dislike\',\'laugh\',\'emphasize\',\'question\',\'unknown\'))',
  );
  static const VerificationMeta _reactorParticipantIdMeta =
      const VerificationMeta('reactorParticipantId');
  @override
  late final GeneratedColumn<int> reactorParticipantId = GeneratedColumn<int>(
    'reactor_participant_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES participants (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK("action" IN (\'add\',\'remove\'))',
  );
  static const VerificationMeta _reactedAtUtcMeta = const VerificationMeta(
    'reactedAtUtc',
  );
  @override
  late final GeneratedColumn<String> reactedAtUtc = GeneratedColumn<String>(
    'reacted_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageGuid,
    kind,
    reactorParticipantId,
    action,
    reactedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkingReaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_guid')) {
      context.handle(
        _messageGuidMeta,
        messageGuid.isAcceptableOrUnknown(
          data['message_guid']!,
          _messageGuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageGuidMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('reactor_participant_id')) {
      context.handle(
        _reactorParticipantIdMeta,
        reactorParticipantId.isAcceptableOrUnknown(
          data['reactor_participant_id']!,
          _reactorParticipantIdMeta,
        ),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('reacted_at_utc')) {
      context.handle(
        _reactedAtUtcMeta,
        reactedAtUtc.isAcceptableOrUnknown(
          data['reacted_at_utc']!,
          _reactedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkingReaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkingReaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_guid'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      reactorParticipantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reactor_participant_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      reactedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reacted_at_utc'],
      ),
    );
  }

  @override
  $WorkingReactionsTable createAlias(String alias) {
    return $WorkingReactionsTable(attachedDatabase, alias);
  }
}

class WorkingReaction extends DataClass implements Insertable<WorkingReaction> {
  final int id;
  final String messageGuid;
  final String kind;
  final int? reactorParticipantId;
  final String action;
  final String? reactedAtUtc;
  const WorkingReaction({
    required this.id,
    required this.messageGuid,
    required this.kind,
    this.reactorParticipantId,
    required this.action,
    this.reactedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_guid'] = Variable<String>(messageGuid);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || reactorParticipantId != null) {
      map['reactor_participant_id'] = Variable<int>(reactorParticipantId);
    }
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || reactedAtUtc != null) {
      map['reacted_at_utc'] = Variable<String>(reactedAtUtc);
    }
    return map;
  }

  WorkingReactionsCompanion toCompanion(bool nullToAbsent) {
    return WorkingReactionsCompanion(
      id: Value(id),
      messageGuid: Value(messageGuid),
      kind: Value(kind),
      reactorParticipantId: reactorParticipantId == null && nullToAbsent
          ? const Value.absent()
          : Value(reactorParticipantId),
      action: Value(action),
      reactedAtUtc: reactedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(reactedAtUtc),
    );
  }

  factory WorkingReaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkingReaction(
      id: serializer.fromJson<int>(json['id']),
      messageGuid: serializer.fromJson<String>(json['messageGuid']),
      kind: serializer.fromJson<String>(json['kind']),
      reactorParticipantId: serializer.fromJson<int?>(
        json['reactorParticipantId'],
      ),
      action: serializer.fromJson<String>(json['action']),
      reactedAtUtc: serializer.fromJson<String?>(json['reactedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageGuid': serializer.toJson<String>(messageGuid),
      'kind': serializer.toJson<String>(kind),
      'reactorParticipantId': serializer.toJson<int?>(reactorParticipantId),
      'action': serializer.toJson<String>(action),
      'reactedAtUtc': serializer.toJson<String?>(reactedAtUtc),
    };
  }

  WorkingReaction copyWith({
    int? id,
    String? messageGuid,
    String? kind,
    Value<int?> reactorParticipantId = const Value.absent(),
    String? action,
    Value<String?> reactedAtUtc = const Value.absent(),
  }) => WorkingReaction(
    id: id ?? this.id,
    messageGuid: messageGuid ?? this.messageGuid,
    kind: kind ?? this.kind,
    reactorParticipantId: reactorParticipantId.present
        ? reactorParticipantId.value
        : this.reactorParticipantId,
    action: action ?? this.action,
    reactedAtUtc: reactedAtUtc.present ? reactedAtUtc.value : this.reactedAtUtc,
  );
  WorkingReaction copyWithCompanion(WorkingReactionsCompanion data) {
    return WorkingReaction(
      id: data.id.present ? data.id.value : this.id,
      messageGuid: data.messageGuid.present
          ? data.messageGuid.value
          : this.messageGuid,
      kind: data.kind.present ? data.kind.value : this.kind,
      reactorParticipantId: data.reactorParticipantId.present
          ? data.reactorParticipantId.value
          : this.reactorParticipantId,
      action: data.action.present ? data.action.value : this.action,
      reactedAtUtc: data.reactedAtUtc.present
          ? data.reactedAtUtc.value
          : this.reactedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkingReaction(')
          ..write('id: $id, ')
          ..write('messageGuid: $messageGuid, ')
          ..write('kind: $kind, ')
          ..write('reactorParticipantId: $reactorParticipantId, ')
          ..write('action: $action, ')
          ..write('reactedAtUtc: $reactedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageGuid,
    kind,
    reactorParticipantId,
    action,
    reactedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkingReaction &&
          other.id == this.id &&
          other.messageGuid == this.messageGuid &&
          other.kind == this.kind &&
          other.reactorParticipantId == this.reactorParticipantId &&
          other.action == this.action &&
          other.reactedAtUtc == this.reactedAtUtc);
}

class WorkingReactionsCompanion extends UpdateCompanion<WorkingReaction> {
  final Value<int> id;
  final Value<String> messageGuid;
  final Value<String> kind;
  final Value<int?> reactorParticipantId;
  final Value<String> action;
  final Value<String?> reactedAtUtc;
  const WorkingReactionsCompanion({
    this.id = const Value.absent(),
    this.messageGuid = const Value.absent(),
    this.kind = const Value.absent(),
    this.reactorParticipantId = const Value.absent(),
    this.action = const Value.absent(),
    this.reactedAtUtc = const Value.absent(),
  });
  WorkingReactionsCompanion.insert({
    this.id = const Value.absent(),
    required String messageGuid,
    required String kind,
    this.reactorParticipantId = const Value.absent(),
    required String action,
    this.reactedAtUtc = const Value.absent(),
  }) : messageGuid = Value(messageGuid),
       kind = Value(kind),
       action = Value(action);
  static Insertable<WorkingReaction> custom({
    Expression<int>? id,
    Expression<String>? messageGuid,
    Expression<String>? kind,
    Expression<int>? reactorParticipantId,
    Expression<String>? action,
    Expression<String>? reactedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageGuid != null) 'message_guid': messageGuid,
      if (kind != null) 'kind': kind,
      if (reactorParticipantId != null)
        'reactor_participant_id': reactorParticipantId,
      if (action != null) 'action': action,
      if (reactedAtUtc != null) 'reacted_at_utc': reactedAtUtc,
    });
  }

  WorkingReactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? messageGuid,
    Value<String>? kind,
    Value<int?>? reactorParticipantId,
    Value<String>? action,
    Value<String?>? reactedAtUtc,
  }) {
    return WorkingReactionsCompanion(
      id: id ?? this.id,
      messageGuid: messageGuid ?? this.messageGuid,
      kind: kind ?? this.kind,
      reactorParticipantId: reactorParticipantId ?? this.reactorParticipantId,
      action: action ?? this.action,
      reactedAtUtc: reactedAtUtc ?? this.reactedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageGuid.present) {
      map['message_guid'] = Variable<String>(messageGuid.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (reactorParticipantId.present) {
      map['reactor_participant_id'] = Variable<int>(reactorParticipantId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (reactedAtUtc.present) {
      map['reacted_at_utc'] = Variable<String>(reactedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkingReactionsCompanion(')
          ..write('id: $id, ')
          ..write('messageGuid: $messageGuid, ')
          ..write('kind: $kind, ')
          ..write('reactorParticipantId: $reactorParticipantId, ')
          ..write('action: $action, ')
          ..write('reactedAtUtc: $reactedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $ReactionCountsTable extends ReactionCounts
    with TableInfo<$ReactionCountsTable, ReactionCount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReactionCountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageGuidMeta = const VerificationMeta(
    'messageGuid',
  );
  @override
  late final GeneratedColumn<String> messageGuid = GeneratedColumn<String>(
    'message_guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loveMeta = const VerificationMeta('love');
  @override
  late final GeneratedColumn<int> love = GeneratedColumn<int>(
    'love',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _likeMeta = const VerificationMeta('like');
  @override
  late final GeneratedColumn<int> like = GeneratedColumn<int>(
    'like',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dislikeMeta = const VerificationMeta(
    'dislike',
  );
  @override
  late final GeneratedColumn<int> dislike = GeneratedColumn<int>(
    'dislike',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _laughMeta = const VerificationMeta('laugh');
  @override
  late final GeneratedColumn<int> laugh = GeneratedColumn<int>(
    'laugh',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _emphasizeMeta = const VerificationMeta(
    'emphasize',
  );
  @override
  late final GeneratedColumn<int> emphasize = GeneratedColumn<int>(
    'emphasize',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<int> question = GeneratedColumn<int>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageGuid,
    love,
    like,
    dislike,
    laugh,
    emphasize,
    question,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reaction_counts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReactionCount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_guid')) {
      context.handle(
        _messageGuidMeta,
        messageGuid.isAcceptableOrUnknown(
          data['message_guid']!,
          _messageGuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageGuidMeta);
    }
    if (data.containsKey('love')) {
      context.handle(
        _loveMeta,
        love.isAcceptableOrUnknown(data['love']!, _loveMeta),
      );
    }
    if (data.containsKey('like')) {
      context.handle(
        _likeMeta,
        like.isAcceptableOrUnknown(data['like']!, _likeMeta),
      );
    }
    if (data.containsKey('dislike')) {
      context.handle(
        _dislikeMeta,
        dislike.isAcceptableOrUnknown(data['dislike']!, _dislikeMeta),
      );
    }
    if (data.containsKey('laugh')) {
      context.handle(
        _laughMeta,
        laugh.isAcceptableOrUnknown(data['laugh']!, _laughMeta),
      );
    }
    if (data.containsKey('emphasize')) {
      context.handle(
        _emphasizeMeta,
        emphasize.isAcceptableOrUnknown(data['emphasize']!, _emphasizeMeta),
      );
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageGuid};
  @override
  ReactionCount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReactionCount(
      messageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_guid'],
      )!,
      love: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}love'],
      )!,
      like: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}like'],
      )!,
      dislike: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dislike'],
      )!,
      laugh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}laugh'],
      )!,
      emphasize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}emphasize'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question'],
      )!,
    );
  }

  @override
  $ReactionCountsTable createAlias(String alias) {
    return $ReactionCountsTable(attachedDatabase, alias);
  }
}

class ReactionCount extends DataClass implements Insertable<ReactionCount> {
  final String messageGuid;
  final int love;
  final int like;
  final int dislike;
  final int laugh;
  final int emphasize;
  final int question;
  const ReactionCount({
    required this.messageGuid,
    required this.love,
    required this.like,
    required this.dislike,
    required this.laugh,
    required this.emphasize,
    required this.question,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_guid'] = Variable<String>(messageGuid);
    map['love'] = Variable<int>(love);
    map['like'] = Variable<int>(like);
    map['dislike'] = Variable<int>(dislike);
    map['laugh'] = Variable<int>(laugh);
    map['emphasize'] = Variable<int>(emphasize);
    map['question'] = Variable<int>(question);
    return map;
  }

  ReactionCountsCompanion toCompanion(bool nullToAbsent) {
    return ReactionCountsCompanion(
      messageGuid: Value(messageGuid),
      love: Value(love),
      like: Value(like),
      dislike: Value(dislike),
      laugh: Value(laugh),
      emphasize: Value(emphasize),
      question: Value(question),
    );
  }

  factory ReactionCount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReactionCount(
      messageGuid: serializer.fromJson<String>(json['messageGuid']),
      love: serializer.fromJson<int>(json['love']),
      like: serializer.fromJson<int>(json['like']),
      dislike: serializer.fromJson<int>(json['dislike']),
      laugh: serializer.fromJson<int>(json['laugh']),
      emphasize: serializer.fromJson<int>(json['emphasize']),
      question: serializer.fromJson<int>(json['question']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageGuid': serializer.toJson<String>(messageGuid),
      'love': serializer.toJson<int>(love),
      'like': serializer.toJson<int>(like),
      'dislike': serializer.toJson<int>(dislike),
      'laugh': serializer.toJson<int>(laugh),
      'emphasize': serializer.toJson<int>(emphasize),
      'question': serializer.toJson<int>(question),
    };
  }

  ReactionCount copyWith({
    String? messageGuid,
    int? love,
    int? like,
    int? dislike,
    int? laugh,
    int? emphasize,
    int? question,
  }) => ReactionCount(
    messageGuid: messageGuid ?? this.messageGuid,
    love: love ?? this.love,
    like: like ?? this.like,
    dislike: dislike ?? this.dislike,
    laugh: laugh ?? this.laugh,
    emphasize: emphasize ?? this.emphasize,
    question: question ?? this.question,
  );
  ReactionCount copyWithCompanion(ReactionCountsCompanion data) {
    return ReactionCount(
      messageGuid: data.messageGuid.present
          ? data.messageGuid.value
          : this.messageGuid,
      love: data.love.present ? data.love.value : this.love,
      like: data.like.present ? data.like.value : this.like,
      dislike: data.dislike.present ? data.dislike.value : this.dislike,
      laugh: data.laugh.present ? data.laugh.value : this.laugh,
      emphasize: data.emphasize.present ? data.emphasize.value : this.emphasize,
      question: data.question.present ? data.question.value : this.question,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReactionCount(')
          ..write('messageGuid: $messageGuid, ')
          ..write('love: $love, ')
          ..write('like: $like, ')
          ..write('dislike: $dislike, ')
          ..write('laugh: $laugh, ')
          ..write('emphasize: $emphasize, ')
          ..write('question: $question')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(messageGuid, love, like, dislike, laugh, emphasize, question);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReactionCount &&
          other.messageGuid == this.messageGuid &&
          other.love == this.love &&
          other.like == this.like &&
          other.dislike == this.dislike &&
          other.laugh == this.laugh &&
          other.emphasize == this.emphasize &&
          other.question == this.question);
}

class ReactionCountsCompanion extends UpdateCompanion<ReactionCount> {
  final Value<String> messageGuid;
  final Value<int> love;
  final Value<int> like;
  final Value<int> dislike;
  final Value<int> laugh;
  final Value<int> emphasize;
  final Value<int> question;
  final Value<int> rowid;
  const ReactionCountsCompanion({
    this.messageGuid = const Value.absent(),
    this.love = const Value.absent(),
    this.like = const Value.absent(),
    this.dislike = const Value.absent(),
    this.laugh = const Value.absent(),
    this.emphasize = const Value.absent(),
    this.question = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReactionCountsCompanion.insert({
    required String messageGuid,
    this.love = const Value.absent(),
    this.like = const Value.absent(),
    this.dislike = const Value.absent(),
    this.laugh = const Value.absent(),
    this.emphasize = const Value.absent(),
    this.question = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : messageGuid = Value(messageGuid);
  static Insertable<ReactionCount> custom({
    Expression<String>? messageGuid,
    Expression<int>? love,
    Expression<int>? like,
    Expression<int>? dislike,
    Expression<int>? laugh,
    Expression<int>? emphasize,
    Expression<int>? question,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageGuid != null) 'message_guid': messageGuid,
      if (love != null) 'love': love,
      if (like != null) 'like': like,
      if (dislike != null) 'dislike': dislike,
      if (laugh != null) 'laugh': laugh,
      if (emphasize != null) 'emphasize': emphasize,
      if (question != null) 'question': question,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReactionCountsCompanion copyWith({
    Value<String>? messageGuid,
    Value<int>? love,
    Value<int>? like,
    Value<int>? dislike,
    Value<int>? laugh,
    Value<int>? emphasize,
    Value<int>? question,
    Value<int>? rowid,
  }) {
    return ReactionCountsCompanion(
      messageGuid: messageGuid ?? this.messageGuid,
      love: love ?? this.love,
      like: like ?? this.like,
      dislike: dislike ?? this.dislike,
      laugh: laugh ?? this.laugh,
      emphasize: emphasize ?? this.emphasize,
      question: question ?? this.question,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageGuid.present) {
      map['message_guid'] = Variable<String>(messageGuid.value);
    }
    if (love.present) {
      map['love'] = Variable<int>(love.value);
    }
    if (like.present) {
      map['like'] = Variable<int>(like.value);
    }
    if (dislike.present) {
      map['dislike'] = Variable<int>(dislike.value);
    }
    if (laugh.present) {
      map['laugh'] = Variable<int>(laugh.value);
    }
    if (emphasize.present) {
      map['emphasize'] = Variable<int>(emphasize.value);
    }
    if (question.present) {
      map['question'] = Variable<int>(question.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReactionCountsCompanion(')
          ..write('messageGuid: $messageGuid, ')
          ..write('love: $love, ')
          ..write('like: $like, ')
          ..write('dislike: $dislike, ')
          ..write('laugh: $laugh, ')
          ..write('emphasize: $emphasize, ')
          ..write('question: $question, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadStateTable extends ReadState
    with TableInfo<$ReadStateTable, ReadStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chats (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lastReadAtUtcMeta = const VerificationMeta(
    'lastReadAtUtc',
  );
  @override
  late final GeneratedColumn<String> lastReadAtUtc = GeneratedColumn<String>(
    'last_read_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [chatId, lastReadAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'read_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    }
    if (data.containsKey('last_read_at_utc')) {
      context.handle(
        _lastReadAtUtcMeta,
        lastReadAtUtc.isAcceptableOrUnknown(
          data['last_read_at_utc']!,
          _lastReadAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId};
  @override
  ReadStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadStateData(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      lastReadAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_read_at_utc'],
      ),
    );
  }

  @override
  $ReadStateTable createAlias(String alias) {
    return $ReadStateTable(attachedDatabase, alias);
  }
}

class ReadStateData extends DataClass implements Insertable<ReadStateData> {
  final int chatId;
  final String? lastReadAtUtc;
  const ReadStateData({required this.chatId, this.lastReadAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || lastReadAtUtc != null) {
      map['last_read_at_utc'] = Variable<String>(lastReadAtUtc);
    }
    return map;
  }

  ReadStateCompanion toCompanion(bool nullToAbsent) {
    return ReadStateCompanion(
      chatId: Value(chatId),
      lastReadAtUtc: lastReadAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAtUtc),
    );
  }

  factory ReadStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadStateData(
      chatId: serializer.fromJson<int>(json['chatId']),
      lastReadAtUtc: serializer.fromJson<String?>(json['lastReadAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'lastReadAtUtc': serializer.toJson<String?>(lastReadAtUtc),
    };
  }

  ReadStateData copyWith({
    int? chatId,
    Value<String?> lastReadAtUtc = const Value.absent(),
  }) => ReadStateData(
    chatId: chatId ?? this.chatId,
    lastReadAtUtc: lastReadAtUtc.present
        ? lastReadAtUtc.value
        : this.lastReadAtUtc,
  );
  ReadStateData copyWithCompanion(ReadStateCompanion data) {
    return ReadStateData(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      lastReadAtUtc: data.lastReadAtUtc.present
          ? data.lastReadAtUtc.value
          : this.lastReadAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadStateData(')
          ..write('chatId: $chatId, ')
          ..write('lastReadAtUtc: $lastReadAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, lastReadAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadStateData &&
          other.chatId == this.chatId &&
          other.lastReadAtUtc == this.lastReadAtUtc);
}

class ReadStateCompanion extends UpdateCompanion<ReadStateData> {
  final Value<int> chatId;
  final Value<String?> lastReadAtUtc;
  const ReadStateCompanion({
    this.chatId = const Value.absent(),
    this.lastReadAtUtc = const Value.absent(),
  });
  ReadStateCompanion.insert({
    this.chatId = const Value.absent(),
    this.lastReadAtUtc = const Value.absent(),
  });
  static Insertable<ReadStateData> custom({
    Expression<int>? chatId,
    Expression<String>? lastReadAtUtc,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (lastReadAtUtc != null) 'last_read_at_utc': lastReadAtUtc,
    });
  }

  ReadStateCompanion copyWith({
    Value<int>? chatId,
    Value<String?>? lastReadAtUtc,
  }) {
    return ReadStateCompanion(
      chatId: chatId ?? this.chatId,
      lastReadAtUtc: lastReadAtUtc ?? this.lastReadAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (lastReadAtUtc.present) {
      map['last_read_at_utc'] = Variable<String>(lastReadAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadStateCompanion(')
          ..write('chatId: $chatId, ')
          ..write('lastReadAtUtc: $lastReadAtUtc')
          ..write(')'))
        .toString();
  }
}

class $MessageReadMarksTable extends MessageReadMarks
    with TableInfo<$MessageReadMarksTable, MessageReadMark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageReadMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageGuidMeta = const VerificationMeta(
    'messageGuid',
  );
  @override
  late final GeneratedColumn<String> messageGuid = GeneratedColumn<String>(
    'message_guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markedAtUtcMeta = const VerificationMeta(
    'markedAtUtc',
  );
  @override
  late final GeneratedColumn<String> markedAtUtc = GeneratedColumn<String>(
    'marked_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [messageGuid, markedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_read_marks';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageReadMark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_guid')) {
      context.handle(
        _messageGuidMeta,
        messageGuid.isAcceptableOrUnknown(
          data['message_guid']!,
          _messageGuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageGuidMeta);
    }
    if (data.containsKey('marked_at_utc')) {
      context.handle(
        _markedAtUtcMeta,
        markedAtUtc.isAcceptableOrUnknown(
          data['marked_at_utc']!,
          _markedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageGuid};
  @override
  MessageReadMark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageReadMark(
      messageGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_guid'],
      )!,
      markedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marked_at_utc'],
      )!,
    );
  }

  @override
  $MessageReadMarksTable createAlias(String alias) {
    return $MessageReadMarksTable(attachedDatabase, alias);
  }
}

class MessageReadMark extends DataClass implements Insertable<MessageReadMark> {
  final String messageGuid;
  final String markedAtUtc;
  const MessageReadMark({required this.messageGuid, required this.markedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_guid'] = Variable<String>(messageGuid);
    map['marked_at_utc'] = Variable<String>(markedAtUtc);
    return map;
  }

  MessageReadMarksCompanion toCompanion(bool nullToAbsent) {
    return MessageReadMarksCompanion(
      messageGuid: Value(messageGuid),
      markedAtUtc: Value(markedAtUtc),
    );
  }

  factory MessageReadMark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageReadMark(
      messageGuid: serializer.fromJson<String>(json['messageGuid']),
      markedAtUtc: serializer.fromJson<String>(json['markedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageGuid': serializer.toJson<String>(messageGuid),
      'markedAtUtc': serializer.toJson<String>(markedAtUtc),
    };
  }

  MessageReadMark copyWith({String? messageGuid, String? markedAtUtc}) =>
      MessageReadMark(
        messageGuid: messageGuid ?? this.messageGuid,
        markedAtUtc: markedAtUtc ?? this.markedAtUtc,
      );
  MessageReadMark copyWithCompanion(MessageReadMarksCompanion data) {
    return MessageReadMark(
      messageGuid: data.messageGuid.present
          ? data.messageGuid.value
          : this.messageGuid,
      markedAtUtc: data.markedAtUtc.present
          ? data.markedAtUtc.value
          : this.markedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageReadMark(')
          ..write('messageGuid: $messageGuid, ')
          ..write('markedAtUtc: $markedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageGuid, markedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageReadMark &&
          other.messageGuid == this.messageGuid &&
          other.markedAtUtc == this.markedAtUtc);
}

class MessageReadMarksCompanion extends UpdateCompanion<MessageReadMark> {
  final Value<String> messageGuid;
  final Value<String> markedAtUtc;
  final Value<int> rowid;
  const MessageReadMarksCompanion({
    this.messageGuid = const Value.absent(),
    this.markedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageReadMarksCompanion.insert({
    required String messageGuid,
    required String markedAtUtc,
    this.rowid = const Value.absent(),
  }) : messageGuid = Value(messageGuid),
       markedAtUtc = Value(markedAtUtc);
  static Insertable<MessageReadMark> custom({
    Expression<String>? messageGuid,
    Expression<String>? markedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageGuid != null) 'message_guid': messageGuid,
      if (markedAtUtc != null) 'marked_at_utc': markedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageReadMarksCompanion copyWith({
    Value<String>? messageGuid,
    Value<String>? markedAtUtc,
    Value<int>? rowid,
  }) {
    return MessageReadMarksCompanion(
      messageGuid: messageGuid ?? this.messageGuid,
      markedAtUtc: markedAtUtc ?? this.markedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageGuid.present) {
      map['message_guid'] = Variable<String>(messageGuid.value);
    }
    if (markedAtUtc.present) {
      map['marked_at_utc'] = Variable<String>(markedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageReadMarksCompanion(')
          ..write('messageGuid: $messageGuid, ')
          ..write('markedAtUtc: $markedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupabaseSyncStateTable extends SupabaseSyncState
    with TableInfo<$SupabaseSyncStateTable, SupabaseSyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupabaseSyncStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastBatchIdMeta = const VerificationMeta(
    'lastBatchId',
  );
  @override
  late final GeneratedColumn<int> lastBatchId = GeneratedColumn<int>(
    'last_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedRowIdMeta = const VerificationMeta(
    'lastSyncedRowId',
  );
  @override
  late final GeneratedColumn<int> lastSyncedRowId = GeneratedColumn<int>(
    'last_synced_row_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedGuidMeta = const VerificationMeta(
    'lastSyncedGuid',
  );
  @override
  late final GeneratedColumn<String> lastSyncedGuid = GeneratedColumn<String>(
    'last_synced_guid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    lastBatchId,
    lastSyncedRowId,
    lastSyncedGuid,
    lastSyncedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supabase_sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupabaseSyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('last_batch_id')) {
      context.handle(
        _lastBatchIdMeta,
        lastBatchId.isAcceptableOrUnknown(
          data['last_batch_id']!,
          _lastBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_row_id')) {
      context.handle(
        _lastSyncedRowIdMeta,
        lastSyncedRowId.isAcceptableOrUnknown(
          data['last_synced_row_id']!,
          _lastSyncedRowIdMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_guid')) {
      context.handle(
        _lastSyncedGuidMeta,
        lastSyncedGuid.isAcceptableOrUnknown(
          data['last_synced_guid']!,
          _lastSyncedGuidMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {targetTable},
  ];
  @override
  SupabaseSyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupabaseSyncStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      lastBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_batch_id'],
      ),
      lastSyncedRowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_row_id'],
      ),
      lastSyncedGuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_synced_guid'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SupabaseSyncStateTable createAlias(String alias) {
    return $SupabaseSyncStateTable(attachedDatabase, alias);
  }
}

class SupabaseSyncStateData extends DataClass
    implements Insertable<SupabaseSyncStateData> {
  final int id;
  final String targetTable;
  final int? lastBatchId;
  final int? lastSyncedRowId;
  final String? lastSyncedGuid;
  final DateTime? lastSyncedAt;
  final DateTime updatedAt;
  const SupabaseSyncStateData({
    required this.id,
    required this.targetTable,
    this.lastBatchId,
    this.lastSyncedRowId,
    this.lastSyncedGuid,
    this.lastSyncedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_table'] = Variable<String>(targetTable);
    if (!nullToAbsent || lastBatchId != null) {
      map['last_batch_id'] = Variable<int>(lastBatchId);
    }
    if (!nullToAbsent || lastSyncedRowId != null) {
      map['last_synced_row_id'] = Variable<int>(lastSyncedRowId);
    }
    if (!nullToAbsent || lastSyncedGuid != null) {
      map['last_synced_guid'] = Variable<String>(lastSyncedGuid);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SupabaseSyncStateCompanion toCompanion(bool nullToAbsent) {
    return SupabaseSyncStateCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      lastBatchId: lastBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBatchId),
      lastSyncedRowId: lastSyncedRowId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedRowId),
      lastSyncedGuid: lastSyncedGuid == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedGuid),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SupabaseSyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupabaseSyncStateData(
      id: serializer.fromJson<int>(json['id']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      lastBatchId: serializer.fromJson<int?>(json['lastBatchId']),
      lastSyncedRowId: serializer.fromJson<int?>(json['lastSyncedRowId']),
      lastSyncedGuid: serializer.fromJson<String?>(json['lastSyncedGuid']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetTable': serializer.toJson<String>(targetTable),
      'lastBatchId': serializer.toJson<int?>(lastBatchId),
      'lastSyncedRowId': serializer.toJson<int?>(lastSyncedRowId),
      'lastSyncedGuid': serializer.toJson<String?>(lastSyncedGuid),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SupabaseSyncStateData copyWith({
    int? id,
    String? targetTable,
    Value<int?> lastBatchId = const Value.absent(),
    Value<int?> lastSyncedRowId = const Value.absent(),
    Value<String?> lastSyncedGuid = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => SupabaseSyncStateData(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    lastBatchId: lastBatchId.present ? lastBatchId.value : this.lastBatchId,
    lastSyncedRowId: lastSyncedRowId.present
        ? lastSyncedRowId.value
        : this.lastSyncedRowId,
    lastSyncedGuid: lastSyncedGuid.present
        ? lastSyncedGuid.value
        : this.lastSyncedGuid,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SupabaseSyncStateData copyWithCompanion(SupabaseSyncStateCompanion data) {
    return SupabaseSyncStateData(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      lastBatchId: data.lastBatchId.present
          ? data.lastBatchId.value
          : this.lastBatchId,
      lastSyncedRowId: data.lastSyncedRowId.present
          ? data.lastSyncedRowId.value
          : this.lastSyncedRowId,
      lastSyncedGuid: data.lastSyncedGuid.present
          ? data.lastSyncedGuid.value
          : this.lastSyncedGuid,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupabaseSyncStateData(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('lastBatchId: $lastBatchId, ')
          ..write('lastSyncedRowId: $lastSyncedRowId, ')
          ..write('lastSyncedGuid: $lastSyncedGuid, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    lastBatchId,
    lastSyncedRowId,
    lastSyncedGuid,
    lastSyncedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupabaseSyncStateData &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.lastBatchId == this.lastBatchId &&
          other.lastSyncedRowId == this.lastSyncedRowId &&
          other.lastSyncedGuid == this.lastSyncedGuid &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.updatedAt == this.updatedAt);
}

class SupabaseSyncStateCompanion
    extends UpdateCompanion<SupabaseSyncStateData> {
  final Value<int> id;
  final Value<String> targetTable;
  final Value<int?> lastBatchId;
  final Value<int?> lastSyncedRowId;
  final Value<String?> lastSyncedGuid;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> updatedAt;
  const SupabaseSyncStateCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.lastBatchId = const Value.absent(),
    this.lastSyncedRowId = const Value.absent(),
    this.lastSyncedGuid = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SupabaseSyncStateCompanion.insert({
    this.id = const Value.absent(),
    required String targetTable,
    this.lastBatchId = const Value.absent(),
    this.lastSyncedRowId = const Value.absent(),
    this.lastSyncedGuid = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : targetTable = Value(targetTable);
  static Insertable<SupabaseSyncStateData> custom({
    Expression<int>? id,
    Expression<String>? targetTable,
    Expression<int>? lastBatchId,
    Expression<int>? lastSyncedRowId,
    Expression<String>? lastSyncedGuid,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (lastBatchId != null) 'last_batch_id': lastBatchId,
      if (lastSyncedRowId != null) 'last_synced_row_id': lastSyncedRowId,
      if (lastSyncedGuid != null) 'last_synced_guid': lastSyncedGuid,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SupabaseSyncStateCompanion copyWith({
    Value<int>? id,
    Value<String>? targetTable,
    Value<int?>? lastBatchId,
    Value<int?>? lastSyncedRowId,
    Value<String?>? lastSyncedGuid,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? updatedAt,
  }) {
    return SupabaseSyncStateCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      lastBatchId: lastBatchId ?? this.lastBatchId,
      lastSyncedRowId: lastSyncedRowId ?? this.lastSyncedRowId,
      lastSyncedGuid: lastSyncedGuid ?? this.lastSyncedGuid,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (lastBatchId.present) {
      map['last_batch_id'] = Variable<int>(lastBatchId.value);
    }
    if (lastSyncedRowId.present) {
      map['last_synced_row_id'] = Variable<int>(lastSyncedRowId.value);
    }
    if (lastSyncedGuid.present) {
      map['last_synced_guid'] = Variable<String>(lastSyncedGuid.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupabaseSyncStateCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('lastBatchId: $lastBatchId, ')
          ..write('lastSyncedRowId: $lastSyncedRowId, ')
          ..write('lastSyncedGuid: $lastSyncedGuid, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SupabaseSyncLogsTable extends SupabaseSyncLogs
    with TableInfo<$SupabaseSyncLogsTable, SupabaseSyncLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupabaseSyncLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    targetTable,
    status,
    attempt,
    requestId,
    message,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supabase_sync_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupabaseSyncLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupabaseSyncLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupabaseSyncLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batch_id'],
      ),
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SupabaseSyncLogsTable createAlias(String alias) {
    return $SupabaseSyncLogsTable(attachedDatabase, alias);
  }
}

class SupabaseSyncLog extends DataClass implements Insertable<SupabaseSyncLog> {
  final int id;
  final int? batchId;
  final String? targetTable;
  final String? status;
  final int attempt;
  final String? requestId;
  final String? message;
  final DateTime createdAt;
  const SupabaseSyncLog({
    required this.id,
    this.batchId,
    this.targetTable,
    this.status,
    required this.attempt,
    this.requestId,
    this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    if (!nullToAbsent || targetTable != null) {
      map['target_table'] = Variable<String>(targetTable);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['attempt'] = Variable<int>(attempt);
    if (!nullToAbsent || requestId != null) {
      map['request_id'] = Variable<String>(requestId);
    }
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SupabaseSyncLogsCompanion toCompanion(bool nullToAbsent) {
    return SupabaseSyncLogsCompanion(
      id: Value(id),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      targetTable: targetTable == null && nullToAbsent
          ? const Value.absent()
          : Value(targetTable),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      attempt: Value(attempt),
      requestId: requestId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestId),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory SupabaseSyncLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupabaseSyncLog(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<int?>(json['batchId']),
      targetTable: serializer.fromJson<String?>(json['targetTable']),
      status: serializer.fromJson<String?>(json['status']),
      attempt: serializer.fromJson<int>(json['attempt']),
      requestId: serializer.fromJson<String?>(json['requestId']),
      message: serializer.fromJson<String?>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<int?>(batchId),
      'targetTable': serializer.toJson<String?>(targetTable),
      'status': serializer.toJson<String?>(status),
      'attempt': serializer.toJson<int>(attempt),
      'requestId': serializer.toJson<String?>(requestId),
      'message': serializer.toJson<String?>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SupabaseSyncLog copyWith({
    int? id,
    Value<int?> batchId = const Value.absent(),
    Value<String?> targetTable = const Value.absent(),
    Value<String?> status = const Value.absent(),
    int? attempt,
    Value<String?> requestId = const Value.absent(),
    Value<String?> message = const Value.absent(),
    DateTime? createdAt,
  }) => SupabaseSyncLog(
    id: id ?? this.id,
    batchId: batchId.present ? batchId.value : this.batchId,
    targetTable: targetTable.present ? targetTable.value : this.targetTable,
    status: status.present ? status.value : this.status,
    attempt: attempt ?? this.attempt,
    requestId: requestId.present ? requestId.value : this.requestId,
    message: message.present ? message.value : this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  SupabaseSyncLog copyWithCompanion(SupabaseSyncLogsCompanion data) {
    return SupabaseSyncLog(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      status: data.status.present ? data.status.value : this.status,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupabaseSyncLog(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('targetTable: $targetTable, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('requestId: $requestId, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    targetTable,
    status,
    attempt,
    requestId,
    message,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupabaseSyncLog &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.targetTable == this.targetTable &&
          other.status == this.status &&
          other.attempt == this.attempt &&
          other.requestId == this.requestId &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class SupabaseSyncLogsCompanion extends UpdateCompanion<SupabaseSyncLog> {
  final Value<int> id;
  final Value<int?> batchId;
  final Value<String?> targetTable;
  final Value<String?> status;
  final Value<int> attempt;
  final Value<String?> requestId;
  final Value<String?> message;
  final Value<DateTime> createdAt;
  const SupabaseSyncLogsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.requestId = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SupabaseSyncLogsCompanion.insert({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.status = const Value.absent(),
    this.attempt = const Value.absent(),
    this.requestId = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<SupabaseSyncLog> custom({
    Expression<int>? id,
    Expression<int>? batchId,
    Expression<String>? targetTable,
    Expression<String>? status,
    Expression<int>? attempt,
    Expression<String>? requestId,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (targetTable != null) 'target_table': targetTable,
      if (status != null) 'status': status,
      if (attempt != null) 'attempt': attempt,
      if (requestId != null) 'request_id': requestId,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SupabaseSyncLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? batchId,
    Value<String?>? targetTable,
    Value<String?>? status,
    Value<int>? attempt,
    Value<String?>? requestId,
    Value<String?>? message,
    Value<DateTime>? createdAt,
  }) {
    return SupabaseSyncLogsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      targetTable: targetTable ?? this.targetTable,
      status: status ?? this.status,
      attempt: attempt ?? this.attempt,
      requestId: requestId ?? this.requestId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupabaseSyncLogsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('targetTable: $targetTable, ')
          ..write('status: $status, ')
          ..write('attempt: $attempt, ')
          ..write('requestId: $requestId, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$WorkingDatabase extends GeneratedDatabase {
  _$WorkingDatabase(QueryExecutor e) : super(e);
  $WorkingDatabaseManager get managers => $WorkingDatabaseManager(this);
  late final $WorkingSchemaMigrationsTable workingSchemaMigrations =
      $WorkingSchemaMigrationsTable(this);
  late final $ProjectionStateTable projectionState = $ProjectionStateTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $WorkingParticipantsTable workingParticipants =
      $WorkingParticipantsTable(this);
  late final $ParticipantHandleLinksTable participantHandleLinks =
      $ParticipantHandleLinksTable(this);
  late final $WorkingChatsTable workingChats = $WorkingChatsTable(this);
  late final $ChatToParticipantTable chatToParticipant =
      $ChatToParticipantTable(this);
  late final $WorkingMessagesTable workingMessages = $WorkingMessagesTable(
    this,
  );
  late final $WorkingAttachmentsTable workingAttachments =
      $WorkingAttachmentsTable(this);
  late final $WorkingReactionsTable workingReactions = $WorkingReactionsTable(
    this,
  );
  late final $ReactionCountsTable reactionCounts = $ReactionCountsTable(this);
  late final $ReadStateTable readState = $ReadStateTable(this);
  late final $MessageReadMarksTable messageReadMarks = $MessageReadMarksTable(
    this,
  );
  late final $SupabaseSyncStateTable supabaseSyncState =
      $SupabaseSyncStateTable(this);
  late final $SupabaseSyncLogsTable supabaseSyncLogs = $SupabaseSyncLogsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workingSchemaMigrations,
    projectionState,
    appSettings,
    workingParticipants,
    participantHandleLinks,
    workingChats,
    chatToParticipant,
    workingMessages,
    workingAttachments,
    workingReactions,
    reactionCounts,
    readState,
    messageReadMarks,
    supabaseSyncState,
    supabaseSyncLogs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'participants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('participant_handle_links', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'participants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chats', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_to_participant', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'participants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chat_to_participant', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'participants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'participants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'chats',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('read_state', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WorkingSchemaMigrationsTableCreateCompanionBuilder =
    WorkingSchemaMigrationsCompanion Function({
      Value<int> version,
      required String appliedAtUtc,
    });
typedef $$WorkingSchemaMigrationsTableUpdateCompanionBuilder =
    WorkingSchemaMigrationsCompanion Function({
      Value<int> version,
      Value<String> appliedAtUtc,
    });

class $$WorkingSchemaMigrationsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingSchemaMigrationsTable> {
  $$WorkingSchemaMigrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliedAtUtc => $composableBuilder(
    column: $table.appliedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkingSchemaMigrationsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingSchemaMigrationsTable> {
  $$WorkingSchemaMigrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliedAtUtc => $composableBuilder(
    column: $table.appliedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkingSchemaMigrationsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingSchemaMigrationsTable> {
  $$WorkingSchemaMigrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get appliedAtUtc => $composableBuilder(
    column: $table.appliedAtUtc,
    builder: (column) => column,
  );
}

class $$WorkingSchemaMigrationsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingSchemaMigrationsTable,
          WorkingSchemaMigration,
          $$WorkingSchemaMigrationsTableFilterComposer,
          $$WorkingSchemaMigrationsTableOrderingComposer,
          $$WorkingSchemaMigrationsTableAnnotationComposer,
          $$WorkingSchemaMigrationsTableCreateCompanionBuilder,
          $$WorkingSchemaMigrationsTableUpdateCompanionBuilder,
          (
            WorkingSchemaMigration,
            BaseReferences<
              _$WorkingDatabase,
              $WorkingSchemaMigrationsTable,
              WorkingSchemaMigration
            >,
          ),
          WorkingSchemaMigration,
          PrefetchHooks Function()
        > {
  $$WorkingSchemaMigrationsTableTableManager(
    _$WorkingDatabase db,
    $WorkingSchemaMigrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingSchemaMigrationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WorkingSchemaMigrationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkingSchemaMigrationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> version = const Value.absent(),
                Value<String> appliedAtUtc = const Value.absent(),
              }) => WorkingSchemaMigrationsCompanion(
                version: version,
                appliedAtUtc: appliedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> version = const Value.absent(),
                required String appliedAtUtc,
              }) => WorkingSchemaMigrationsCompanion.insert(
                version: version,
                appliedAtUtc: appliedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkingSchemaMigrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingSchemaMigrationsTable,
      WorkingSchemaMigration,
      $$WorkingSchemaMigrationsTableFilterComposer,
      $$WorkingSchemaMigrationsTableOrderingComposer,
      $$WorkingSchemaMigrationsTableAnnotationComposer,
      $$WorkingSchemaMigrationsTableCreateCompanionBuilder,
      $$WorkingSchemaMigrationsTableUpdateCompanionBuilder,
      (
        WorkingSchemaMigration,
        BaseReferences<
          _$WorkingDatabase,
          $WorkingSchemaMigrationsTable,
          WorkingSchemaMigration
        >,
      ),
      WorkingSchemaMigration,
      PrefetchHooks Function()
    >;
typedef $$ProjectionStateTableCreateCompanionBuilder =
    ProjectionStateCompanion Function({
      Value<int> id,
      Value<int?> lastImportBatchId,
      Value<String?> lastProjectedAtUtc,
      Value<int?> lastProjectedMessageId,
      Value<int?> lastProjectedAttachmentId,
    });
typedef $$ProjectionStateTableUpdateCompanionBuilder =
    ProjectionStateCompanion Function({
      Value<int> id,
      Value<int?> lastImportBatchId,
      Value<String?> lastProjectedAtUtc,
      Value<int?> lastProjectedMessageId,
      Value<int?> lastProjectedAttachmentId,
    });

class $$ProjectionStateTableFilterComposer
    extends Composer<_$WorkingDatabase, $ProjectionStateTable> {
  $$ProjectionStateTableFilterComposer({
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

  ColumnFilters<int> get lastImportBatchId => $composableBuilder(
    column: $table.lastImportBatchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastProjectedAtUtc => $composableBuilder(
    column: $table.lastProjectedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastProjectedMessageId => $composableBuilder(
    column: $table.lastProjectedMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastProjectedAttachmentId => $composableBuilder(
    column: $table.lastProjectedAttachmentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectionStateTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ProjectionStateTable> {
  $$ProjectionStateTableOrderingComposer({
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

  ColumnOrderings<int> get lastImportBatchId => $composableBuilder(
    column: $table.lastImportBatchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastProjectedAtUtc => $composableBuilder(
    column: $table.lastProjectedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastProjectedMessageId => $composableBuilder(
    column: $table.lastProjectedMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastProjectedAttachmentId => $composableBuilder(
    column: $table.lastProjectedAttachmentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectionStateTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ProjectionStateTable> {
  $$ProjectionStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastImportBatchId => $composableBuilder(
    column: $table.lastImportBatchId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastProjectedAtUtc => $composableBuilder(
    column: $table.lastProjectedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastProjectedMessageId => $composableBuilder(
    column: $table.lastProjectedMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastProjectedAttachmentId => $composableBuilder(
    column: $table.lastProjectedAttachmentId,
    builder: (column) => column,
  );
}

class $$ProjectionStateTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ProjectionStateTable,
          ProjectionStateData,
          $$ProjectionStateTableFilterComposer,
          $$ProjectionStateTableOrderingComposer,
          $$ProjectionStateTableAnnotationComposer,
          $$ProjectionStateTableCreateCompanionBuilder,
          $$ProjectionStateTableUpdateCompanionBuilder,
          (
            ProjectionStateData,
            BaseReferences<
              _$WorkingDatabase,
              $ProjectionStateTable,
              ProjectionStateData
            >,
          ),
          ProjectionStateData,
          PrefetchHooks Function()
        > {
  $$ProjectionStateTableTableManager(
    _$WorkingDatabase db,
    $ProjectionStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectionStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectionStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectionStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastImportBatchId = const Value.absent(),
                Value<String?> lastProjectedAtUtc = const Value.absent(),
                Value<int?> lastProjectedMessageId = const Value.absent(),
                Value<int?> lastProjectedAttachmentId = const Value.absent(),
              }) => ProjectionStateCompanion(
                id: id,
                lastImportBatchId: lastImportBatchId,
                lastProjectedAtUtc: lastProjectedAtUtc,
                lastProjectedMessageId: lastProjectedMessageId,
                lastProjectedAttachmentId: lastProjectedAttachmentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> lastImportBatchId = const Value.absent(),
                Value<String?> lastProjectedAtUtc = const Value.absent(),
                Value<int?> lastProjectedMessageId = const Value.absent(),
                Value<int?> lastProjectedAttachmentId = const Value.absent(),
              }) => ProjectionStateCompanion.insert(
                id: id,
                lastImportBatchId: lastImportBatchId,
                lastProjectedAtUtc: lastProjectedAtUtc,
                lastProjectedMessageId: lastProjectedMessageId,
                lastProjectedAttachmentId: lastProjectedAttachmentId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectionStateTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ProjectionStateTable,
      ProjectionStateData,
      $$ProjectionStateTableFilterComposer,
      $$ProjectionStateTableOrderingComposer,
      $$ProjectionStateTableAnnotationComposer,
      $$ProjectionStateTableCreateCompanionBuilder,
      $$ProjectionStateTableUpdateCompanionBuilder,
      (
        ProjectionStateData,
        BaseReferences<
          _$WorkingDatabase,
          $ProjectionStateTable,
          ProjectionStateData
        >,
      ),
      ProjectionStateData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$WorkingDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$WorkingDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$WorkingDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$WorkingDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$WorkingParticipantsTableCreateCompanionBuilder =
    WorkingParticipantsCompanion Function({
      Value<int> id,
      Value<String?> normalizedAddress,
      Value<String> service,
      Value<String?> displayName,
      Value<String?> contactRef,
      Value<String?> avatarRef,
      Value<bool> isSystem,
    });
typedef $$WorkingParticipantsTableUpdateCompanionBuilder =
    WorkingParticipantsCompanion Function({
      Value<int> id,
      Value<String?> normalizedAddress,
      Value<String> service,
      Value<String?> displayName,
      Value<String?> contactRef,
      Value<String?> avatarRef,
      Value<bool> isSystem,
    });

final class $$WorkingParticipantsTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $WorkingParticipantsTable,
          WorkingParticipant
        > {
  $$WorkingParticipantsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ParticipantHandleLinksTable,
    List<ParticipantHandleLink>
  >
  _participantHandleLinksRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.participantHandleLinks,
        aliasName: $_aliasNameGenerator(
          db.workingParticipants.id,
          db.participantHandleLinks.participantId,
        ),
      );

  $$ParticipantHandleLinksTableProcessedTableManager
  get participantHandleLinksRefs {
    final manager = $$ParticipantHandleLinksTableTableManager(
      $_db,
      $_db.participantHandleLinks,
    ).filter((f) => f.participantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _participantHandleLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkingChatsTable, List<WorkingChat>>
  _workingChatsRefsTable(_$WorkingDatabase db) => MultiTypedResultKey.fromTable(
    db.workingChats,
    aliasName: $_aliasNameGenerator(
      db.workingParticipants.id,
      db.workingChats.lastSenderParticipantId,
    ),
  );

  $$WorkingChatsTableProcessedTableManager get workingChatsRefs {
    final manager = $$WorkingChatsTableTableManager($_db, $_db.workingChats)
        .filter(
          (f) =>
              f.lastSenderParticipantId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_workingChatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ChatToParticipantTable,
    List<ChatToParticipantData>
  >
  _chatToParticipantRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chatToParticipant,
        aliasName: $_aliasNameGenerator(
          db.workingParticipants.id,
          db.chatToParticipant.participantId,
        ),
      );

  $$ChatToParticipantTableProcessedTableManager get chatToParticipantRefs {
    final manager = $$ChatToParticipantTableTableManager(
      $_db,
      $_db.chatToParticipant,
    ).filter((f) => f.participantId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chatToParticipantRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkingMessagesTable, List<WorkingMessage>>
  _workingMessagesRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workingMessages,
        aliasName: $_aliasNameGenerator(
          db.workingParticipants.id,
          db.workingMessages.senderParticipantId,
        ),
      );

  $$WorkingMessagesTableProcessedTableManager get workingMessagesRefs {
    final manager =
        $$WorkingMessagesTableTableManager($_db, $_db.workingMessages).filter(
          (f) => f.senderParticipantId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _workingMessagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkingReactionsTable, List<WorkingReaction>>
  _workingReactionsRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workingReactions,
        aliasName: $_aliasNameGenerator(
          db.workingParticipants.id,
          db.workingReactions.reactorParticipantId,
        ),
      );

  $$WorkingReactionsTableProcessedTableManager get workingReactionsRefs {
    final manager =
        $$WorkingReactionsTableTableManager($_db, $_db.workingReactions).filter(
          (f) => f.reactorParticipantId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _workingReactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkingParticipantsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingParticipantsTable> {
  $$WorkingParticipantsTableFilterComposer({
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

  ColumnFilters<String> get normalizedAddress => $composableBuilder(
    column: $table.normalizedAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactRef => $composableBuilder(
    column: $table.contactRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarRef => $composableBuilder(
    column: $table.avatarRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> participantHandleLinksRefs(
    Expression<bool> Function($$ParticipantHandleLinksTableFilterComposer f) f,
  ) {
    final $$ParticipantHandleLinksTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.participantHandleLinks,
          getReferencedColumn: (t) => t.participantId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ParticipantHandleLinksTableFilterComposer(
                $db: $db,
                $table: $db.participantHandleLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> workingChatsRefs(
    Expression<bool> Function($$WorkingChatsTableFilterComposer f) f,
  ) {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.lastSenderParticipantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatToParticipantRefs(
    Expression<bool> Function($$ChatToParticipantTableFilterComposer f) f,
  ) {
    final $$ChatToParticipantTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatToParticipant,
      getReferencedColumn: (t) => t.participantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatToParticipantTableFilterComposer(
            $db: $db,
            $table: $db.chatToParticipant,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workingMessagesRefs(
    Expression<bool> Function($$WorkingMessagesTableFilterComposer f) f,
  ) {
    final $$WorkingMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.senderParticipantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableFilterComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workingReactionsRefs(
    Expression<bool> Function($$WorkingReactionsTableFilterComposer f) f,
  ) {
    final $$WorkingReactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingReactions,
      getReferencedColumn: (t) => t.reactorParticipantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingReactionsTableFilterComposer(
            $db: $db,
            $table: $db.workingReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkingParticipantsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingParticipantsTable> {
  $$WorkingParticipantsTableOrderingComposer({
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

  ColumnOrderings<String> get normalizedAddress => $composableBuilder(
    column: $table.normalizedAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactRef => $composableBuilder(
    column: $table.contactRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarRef => $composableBuilder(
    column: $table.avatarRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkingParticipantsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingParticipantsTable> {
  $$WorkingParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get normalizedAddress => $composableBuilder(
    column: $table.normalizedAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactRef => $composableBuilder(
    column: $table.contactRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarRef =>
      $composableBuilder(column: $table.avatarRef, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  Expression<T> participantHandleLinksRefs<T extends Object>(
    Expression<T> Function($$ParticipantHandleLinksTableAnnotationComposer a) f,
  ) {
    final $$ParticipantHandleLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.participantHandleLinks,
          getReferencedColumn: (t) => t.participantId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ParticipantHandleLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.participantHandleLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workingChatsRefs<T extends Object>(
    Expression<T> Function($$WorkingChatsTableAnnotationComposer a) f,
  ) {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.lastSenderParticipantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatToParticipantRefs<T extends Object>(
    Expression<T> Function($$ChatToParticipantTableAnnotationComposer a) f,
  ) {
    final $$ChatToParticipantTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chatToParticipant,
          getReferencedColumn: (t) => t.participantId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChatToParticipantTableAnnotationComposer(
                $db: $db,
                $table: $db.chatToParticipant,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workingMessagesRefs<T extends Object>(
    Expression<T> Function($$WorkingMessagesTableAnnotationComposer a) f,
  ) {
    final $$WorkingMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.senderParticipantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workingReactionsRefs<T extends Object>(
    Expression<T> Function($$WorkingReactionsTableAnnotationComposer a) f,
  ) {
    final $$WorkingReactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingReactions,
      getReferencedColumn: (t) => t.reactorParticipantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingReactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingReactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkingParticipantsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingParticipantsTable,
          WorkingParticipant,
          $$WorkingParticipantsTableFilterComposer,
          $$WorkingParticipantsTableOrderingComposer,
          $$WorkingParticipantsTableAnnotationComposer,
          $$WorkingParticipantsTableCreateCompanionBuilder,
          $$WorkingParticipantsTableUpdateCompanionBuilder,
          (WorkingParticipant, $$WorkingParticipantsTableReferences),
          WorkingParticipant,
          PrefetchHooks Function({
            bool participantHandleLinksRefs,
            bool workingChatsRefs,
            bool chatToParticipantRefs,
            bool workingMessagesRefs,
            bool workingReactionsRefs,
          })
        > {
  $$WorkingParticipantsTableTableManager(
    _$WorkingDatabase db,
    $WorkingParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingParticipantsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkingParticipantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> normalizedAddress = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> contactRef = const Value.absent(),
                Value<String?> avatarRef = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
              }) => WorkingParticipantsCompanion(
                id: id,
                normalizedAddress: normalizedAddress,
                service: service,
                displayName: displayName,
                contactRef: contactRef,
                avatarRef: avatarRef,
                isSystem: isSystem,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> normalizedAddress = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> contactRef = const Value.absent(),
                Value<String?> avatarRef = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
              }) => WorkingParticipantsCompanion.insert(
                id: id,
                normalizedAddress: normalizedAddress,
                service: service,
                displayName: displayName,
                contactRef: contactRef,
                avatarRef: avatarRef,
                isSystem: isSystem,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkingParticipantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                participantHandleLinksRefs = false,
                workingChatsRefs = false,
                chatToParticipantRefs = false,
                workingMessagesRefs = false,
                workingReactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (participantHandleLinksRefs) db.participantHandleLinks,
                    if (workingChatsRefs) db.workingChats,
                    if (chatToParticipantRefs) db.chatToParticipant,
                    if (workingMessagesRefs) db.workingMessages,
                    if (workingReactionsRefs) db.workingReactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (participantHandleLinksRefs)
                        await $_getPrefetchedData<
                          WorkingParticipant,
                          $WorkingParticipantsTable,
                          ParticipantHandleLink
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingParticipantsTableReferences
                              ._participantHandleLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingParticipantsTableReferences(
                                db,
                                table,
                                p0,
                              ).participantHandleLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.participantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workingChatsRefs)
                        await $_getPrefetchedData<
                          WorkingParticipant,
                          $WorkingParticipantsTable,
                          WorkingChat
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingParticipantsTableReferences
                              ._workingChatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingParticipantsTableReferences(
                                db,
                                table,
                                p0,
                              ).workingChatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lastSenderParticipantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chatToParticipantRefs)
                        await $_getPrefetchedData<
                          WorkingParticipant,
                          $WorkingParticipantsTable,
                          ChatToParticipantData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingParticipantsTableReferences
                              ._chatToParticipantRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingParticipantsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatToParticipantRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.participantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workingMessagesRefs)
                        await $_getPrefetchedData<
                          WorkingParticipant,
                          $WorkingParticipantsTable,
                          WorkingMessage
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingParticipantsTableReferences
                              ._workingMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingParticipantsTableReferences(
                                db,
                                table,
                                p0,
                              ).workingMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.senderParticipantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workingReactionsRefs)
                        await $_getPrefetchedData<
                          WorkingParticipant,
                          $WorkingParticipantsTable,
                          WorkingReaction
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingParticipantsTableReferences
                              ._workingReactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingParticipantsTableReferences(
                                db,
                                table,
                                p0,
                              ).workingReactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reactorParticipantId == item.id,
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

typedef $$WorkingParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingParticipantsTable,
      WorkingParticipant,
      $$WorkingParticipantsTableFilterComposer,
      $$WorkingParticipantsTableOrderingComposer,
      $$WorkingParticipantsTableAnnotationComposer,
      $$WorkingParticipantsTableCreateCompanionBuilder,
      $$WorkingParticipantsTableUpdateCompanionBuilder,
      (WorkingParticipant, $$WorkingParticipantsTableReferences),
      WorkingParticipant,
      PrefetchHooks Function({
        bool participantHandleLinksRefs,
        bool workingChatsRefs,
        bool chatToParticipantRefs,
        bool workingMessagesRefs,
        bool workingReactionsRefs,
      })
    >;
typedef $$ParticipantHandleLinksTableCreateCompanionBuilder =
    ParticipantHandleLinksCompanion Function({
      required int participantId,
      required int importHandleId,
      Value<int> rowid,
    });
typedef $$ParticipantHandleLinksTableUpdateCompanionBuilder =
    ParticipantHandleLinksCompanion Function({
      Value<int> participantId,
      Value<int> importHandleId,
      Value<int> rowid,
    });

final class $$ParticipantHandleLinksTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $ParticipantHandleLinksTable,
          ParticipantHandleLink
        > {
  $$ParticipantHandleLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkingParticipantsTable _participantIdTable(_$WorkingDatabase db) =>
      db.workingParticipants.createAlias(
        $_aliasNameGenerator(
          db.participantHandleLinks.participantId,
          db.workingParticipants.id,
        ),
      );

  $$WorkingParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$WorkingParticipantsTableTableManager(
      $_db,
      $_db.workingParticipants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ParticipantHandleLinksTableFilterComposer
    extends Composer<_$WorkingDatabase, $ParticipantHandleLinksTable> {
  $$ParticipantHandleLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get importHandleId => $composableBuilder(
    column: $table.importHandleId,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingParticipantsTableFilterComposer get participantId {
    final $$WorkingParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.workingParticipants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.workingParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ParticipantHandleLinksTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ParticipantHandleLinksTable> {
  $$ParticipantHandleLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get importHandleId => $composableBuilder(
    column: $table.importHandleId,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingParticipantsTableOrderingComposer get participantId {
    final $$WorkingParticipantsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.participantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableOrderingComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ParticipantHandleLinksTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ParticipantHandleLinksTable> {
  $$ParticipantHandleLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get importHandleId => $composableBuilder(
    column: $table.importHandleId,
    builder: (column) => column,
  );

  $$WorkingParticipantsTableAnnotationComposer get participantId {
    final $$WorkingParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.participantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ParticipantHandleLinksTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ParticipantHandleLinksTable,
          ParticipantHandleLink,
          $$ParticipantHandleLinksTableFilterComposer,
          $$ParticipantHandleLinksTableOrderingComposer,
          $$ParticipantHandleLinksTableAnnotationComposer,
          $$ParticipantHandleLinksTableCreateCompanionBuilder,
          $$ParticipantHandleLinksTableUpdateCompanionBuilder,
          (ParticipantHandleLink, $$ParticipantHandleLinksTableReferences),
          ParticipantHandleLink,
          PrefetchHooks Function({bool participantId})
        > {
  $$ParticipantHandleLinksTableTableManager(
    _$WorkingDatabase db,
    $ParticipantHandleLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantHandleLinksTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ParticipantHandleLinksTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ParticipantHandleLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> participantId = const Value.absent(),
                Value<int> importHandleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ParticipantHandleLinksCompanion(
                participantId: participantId,
                importHandleId: importHandleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int participantId,
                required int importHandleId,
                Value<int> rowid = const Value.absent(),
              }) => ParticipantHandleLinksCompanion.insert(
                participantId: participantId,
                importHandleId: importHandleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ParticipantHandleLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({participantId = false}) {
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
                    if (participantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.participantId,
                                referencedTable:
                                    $$ParticipantHandleLinksTableReferences
                                        ._participantIdTable(db),
                                referencedColumn:
                                    $$ParticipantHandleLinksTableReferences
                                        ._participantIdTable(db)
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

typedef $$ParticipantHandleLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ParticipantHandleLinksTable,
      ParticipantHandleLink,
      $$ParticipantHandleLinksTableFilterComposer,
      $$ParticipantHandleLinksTableOrderingComposer,
      $$ParticipantHandleLinksTableAnnotationComposer,
      $$ParticipantHandleLinksTableCreateCompanionBuilder,
      $$ParticipantHandleLinksTableUpdateCompanionBuilder,
      (ParticipantHandleLink, $$ParticipantHandleLinksTableReferences),
      ParticipantHandleLink,
      PrefetchHooks Function({bool participantId})
    >;
typedef $$WorkingChatsTableCreateCompanionBuilder =
    WorkingChatsCompanion Function({
      Value<int> id,
      required String guid,
      Value<String> service,
      Value<bool> isGroup,
      Value<String?> lastMessageAtUtc,
      Value<int?> lastSenderParticipantId,
      Value<String?> lastMessagePreview,
      Value<int> unreadCount,
      Value<bool> pinned,
      Value<bool> archived,
      Value<String?> mutedUntilUtc,
      Value<bool> favourite,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
    });
typedef $$WorkingChatsTableUpdateCompanionBuilder =
    WorkingChatsCompanion Function({
      Value<int> id,
      Value<String> guid,
      Value<String> service,
      Value<bool> isGroup,
      Value<String?> lastMessageAtUtc,
      Value<int?> lastSenderParticipantId,
      Value<String?> lastMessagePreview,
      Value<int> unreadCount,
      Value<bool> pinned,
      Value<bool> archived,
      Value<String?> mutedUntilUtc,
      Value<bool> favourite,
      Value<String?> createdAtUtc,
      Value<String?> updatedAtUtc,
    });

final class $$WorkingChatsTableReferences
    extends BaseReferences<_$WorkingDatabase, $WorkingChatsTable, WorkingChat> {
  $$WorkingChatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkingParticipantsTable _lastSenderParticipantIdTable(
    _$WorkingDatabase db,
  ) => db.workingParticipants.createAlias(
    $_aliasNameGenerator(
      db.workingChats.lastSenderParticipantId,
      db.workingParticipants.id,
    ),
  );

  $$WorkingParticipantsTableProcessedTableManager? get lastSenderParticipantId {
    final $_column = $_itemColumn<int>('last_sender_participant_id');
    if ($_column == null) return null;
    final manager = $$WorkingParticipantsTableTableManager(
      $_db,
      $_db.workingParticipants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _lastSenderParticipantIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ChatToParticipantTable,
    List<ChatToParticipantData>
  >
  _chatToParticipantRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chatToParticipant,
        aliasName: $_aliasNameGenerator(
          db.workingChats.id,
          db.chatToParticipant.chatId,
        ),
      );

  $$ChatToParticipantTableProcessedTableManager get chatToParticipantRefs {
    final manager = $$ChatToParticipantTableTableManager(
      $_db,
      $_db.chatToParticipant,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chatToParticipantRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkingMessagesTable, List<WorkingMessage>>
  _workingMessagesRefsTable(_$WorkingDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workingMessages,
        aliasName: $_aliasNameGenerator(
          db.workingChats.id,
          db.workingMessages.chatId,
        ),
      );

  $$WorkingMessagesTableProcessedTableManager get workingMessagesRefs {
    final manager = $$WorkingMessagesTableTableManager(
      $_db,
      $_db.workingMessages,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workingMessagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadStateTable, List<ReadStateData>>
  _readStateRefsTable(_$WorkingDatabase db) => MultiTypedResultKey.fromTable(
    db.readState,
    aliasName: $_aliasNameGenerator(db.workingChats.id, db.readState.chatId),
  );

  $$ReadStateTableProcessedTableManager get readStateRefs {
    final manager = $$ReadStateTableTableManager(
      $_db,
      $_db.readState,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readStateRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkingChatsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingChatsTable> {
  $$WorkingChatsTableFilterComposer({
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

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageAtUtc => $composableBuilder(
    column: $table.lastMessageAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutedUntilUtc => $composableBuilder(
    column: $table.mutedUntilUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favourite => $composableBuilder(
    column: $table.favourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingParticipantsTableFilterComposer get lastSenderParticipantId {
    final $$WorkingParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastSenderParticipantId,
      referencedTable: $db.workingParticipants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.workingParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatToParticipantRefs(
    Expression<bool> Function($$ChatToParticipantTableFilterComposer f) f,
  ) {
    final $$ChatToParticipantTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatToParticipant,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatToParticipantTableFilterComposer(
            $db: $db,
            $table: $db.chatToParticipant,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workingMessagesRefs(
    Expression<bool> Function($$WorkingMessagesTableFilterComposer f) f,
  ) {
    final $$WorkingMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableFilterComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readStateRefs(
    Expression<bool> Function($$ReadStateTableFilterComposer f) f,
  ) {
    final $$ReadStateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readState,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadStateTableFilterComposer(
            $db: $db,
            $table: $db.readState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkingChatsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingChatsTable> {
  $$WorkingChatsTableOrderingComposer({
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

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageAtUtc => $composableBuilder(
    column: $table.lastMessageAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutedUntilUtc => $composableBuilder(
    column: $table.mutedUntilUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favourite => $composableBuilder(
    column: $table.favourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingParticipantsTableOrderingComposer get lastSenderParticipantId {
    final $$WorkingParticipantsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.lastSenderParticipantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableOrderingComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkingChatsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingChatsTable> {
  $$WorkingChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<String> get lastMessageAtUtc => $composableBuilder(
    column: $table.lastMessageAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get mutedUntilUtc => $composableBuilder(
    column: $table.mutedUntilUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get favourite =>
      $composableBuilder(column: $table.favourite, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$WorkingParticipantsTableAnnotationComposer get lastSenderParticipantId {
    final $$WorkingParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.lastSenderParticipantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> chatToParticipantRefs<T extends Object>(
    Expression<T> Function($$ChatToParticipantTableAnnotationComposer a) f,
  ) {
    final $$ChatToParticipantTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chatToParticipant,
          getReferencedColumn: (t) => t.chatId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChatToParticipantTableAnnotationComposer(
                $db: $db,
                $table: $db.chatToParticipant,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workingMessagesRefs<T extends Object>(
    Expression<T> Function($$WorkingMessagesTableAnnotationComposer a) f,
  ) {
    final $$WorkingMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workingMessages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.workingMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readStateRefs<T extends Object>(
    Expression<T> Function($$ReadStateTableAnnotationComposer a) f,
  ) {
    final $$ReadStateTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readState,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadStateTableAnnotationComposer(
            $db: $db,
            $table: $db.readState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkingChatsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingChatsTable,
          WorkingChat,
          $$WorkingChatsTableFilterComposer,
          $$WorkingChatsTableOrderingComposer,
          $$WorkingChatsTableAnnotationComposer,
          $$WorkingChatsTableCreateCompanionBuilder,
          $$WorkingChatsTableUpdateCompanionBuilder,
          (WorkingChat, $$WorkingChatsTableReferences),
          WorkingChat,
          PrefetchHooks Function({
            bool lastSenderParticipantId,
            bool chatToParticipantRefs,
            bool workingMessagesRefs,
            bool readStateRefs,
          })
        > {
  $$WorkingChatsTableTableManager(
    _$WorkingDatabase db,
    $WorkingChatsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkingChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> lastMessageAtUtc = const Value.absent(),
                Value<int?> lastSenderParticipantId = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> mutedUntilUtc = const Value.absent(),
                Value<bool> favourite = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
              }) => WorkingChatsCompanion(
                id: id,
                guid: guid,
                service: service,
                isGroup: isGroup,
                lastMessageAtUtc: lastMessageAtUtc,
                lastSenderParticipantId: lastSenderParticipantId,
                lastMessagePreview: lastMessagePreview,
                unreadCount: unreadCount,
                pinned: pinned,
                archived: archived,
                mutedUntilUtc: mutedUntilUtc,
                favourite: favourite,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String guid,
                Value<String> service = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<String?> lastMessageAtUtc = const Value.absent(),
                Value<int?> lastSenderParticipantId = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> mutedUntilUtc = const Value.absent(),
                Value<bool> favourite = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
              }) => WorkingChatsCompanion.insert(
                id: id,
                guid: guid,
                service: service,
                isGroup: isGroup,
                lastMessageAtUtc: lastMessageAtUtc,
                lastSenderParticipantId: lastSenderParticipantId,
                lastMessagePreview: lastMessagePreview,
                unreadCount: unreadCount,
                pinned: pinned,
                archived: archived,
                mutedUntilUtc: mutedUntilUtc,
                favourite: favourite,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkingChatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                lastSenderParticipantId = false,
                chatToParticipantRefs = false,
                workingMessagesRefs = false,
                readStateRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatToParticipantRefs) db.chatToParticipant,
                    if (workingMessagesRefs) db.workingMessages,
                    if (readStateRefs) db.readState,
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
                        if (lastSenderParticipantId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.lastSenderParticipantId,
                                    referencedTable:
                                        $$WorkingChatsTableReferences
                                            ._lastSenderParticipantIdTable(db),
                                    referencedColumn:
                                        $$WorkingChatsTableReferences
                                            ._lastSenderParticipantIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatToParticipantRefs)
                        await $_getPrefetchedData<
                          WorkingChat,
                          $WorkingChatsTable,
                          ChatToParticipantData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingChatsTableReferences
                              ._chatToParticipantRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatToParticipantRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workingMessagesRefs)
                        await $_getPrefetchedData<
                          WorkingChat,
                          $WorkingChatsTable,
                          WorkingMessage
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingChatsTableReferences
                              ._workingMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).workingMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readStateRefs)
                        await $_getPrefetchedData<
                          WorkingChat,
                          $WorkingChatsTable,
                          ReadStateData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkingChatsTableReferences
                              ._readStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkingChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).readStateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
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

typedef $$WorkingChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingChatsTable,
      WorkingChat,
      $$WorkingChatsTableFilterComposer,
      $$WorkingChatsTableOrderingComposer,
      $$WorkingChatsTableAnnotationComposer,
      $$WorkingChatsTableCreateCompanionBuilder,
      $$WorkingChatsTableUpdateCompanionBuilder,
      (WorkingChat, $$WorkingChatsTableReferences),
      WorkingChat,
      PrefetchHooks Function({
        bool lastSenderParticipantId,
        bool chatToParticipantRefs,
        bool workingMessagesRefs,
        bool readStateRefs,
      })
    >;
typedef $$ChatToParticipantTableCreateCompanionBuilder =
    ChatToParticipantCompanion Function({
      required int chatId,
      required int participantId,
      Value<String> role,
      Value<int> sortKey,
      Value<int> rowid,
    });
typedef $$ChatToParticipantTableUpdateCompanionBuilder =
    ChatToParticipantCompanion Function({
      Value<int> chatId,
      Value<int> participantId,
      Value<String> role,
      Value<int> sortKey,
      Value<int> rowid,
    });

final class $$ChatToParticipantTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $ChatToParticipantTable,
          ChatToParticipantData
        > {
  $$ChatToParticipantTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkingChatsTable _chatIdTable(_$WorkingDatabase db) =>
      db.workingChats.createAlias(
        $_aliasNameGenerator(db.chatToParticipant.chatId, db.workingChats.id),
      );

  $$WorkingChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$WorkingChatsTableTableManager(
      $_db,
      $_db.workingChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkingParticipantsTable _participantIdTable(_$WorkingDatabase db) =>
      db.workingParticipants.createAlias(
        $_aliasNameGenerator(
          db.chatToParticipant.participantId,
          db.workingParticipants.id,
        ),
      );

  $$WorkingParticipantsTableProcessedTableManager get participantId {
    final $_column = $_itemColumn<int>('participant_id')!;

    final manager = $$WorkingParticipantsTableTableManager(
      $_db,
      $_db.workingParticipants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_participantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatToParticipantTableFilterComposer
    extends Composer<_$WorkingDatabase, $ChatToParticipantTable> {
  $$ChatToParticipantTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingChatsTableFilterComposer get chatId {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingParticipantsTableFilterComposer get participantId {
    final $$WorkingParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.participantId,
      referencedTable: $db.workingParticipants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.workingParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatToParticipantTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ChatToParticipantTable> {
  $$ChatToParticipantTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingChatsTableOrderingComposer get chatId {
    final $$WorkingChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableOrderingComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingParticipantsTableOrderingComposer get participantId {
    final $$WorkingParticipantsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.participantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableOrderingComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChatToParticipantTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ChatToParticipantTable> {
  $$ChatToParticipantTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => column);

  $$WorkingChatsTableAnnotationComposer get chatId {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingParticipantsTableAnnotationComposer get participantId {
    final $$WorkingParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.participantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ChatToParticipantTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ChatToParticipantTable,
          ChatToParticipantData,
          $$ChatToParticipantTableFilterComposer,
          $$ChatToParticipantTableOrderingComposer,
          $$ChatToParticipantTableAnnotationComposer,
          $$ChatToParticipantTableCreateCompanionBuilder,
          $$ChatToParticipantTableUpdateCompanionBuilder,
          (ChatToParticipantData, $$ChatToParticipantTableReferences),
          ChatToParticipantData,
          PrefetchHooks Function({bool chatId, bool participantId})
        > {
  $$ChatToParticipantTableTableManager(
    _$WorkingDatabase db,
    $ChatToParticipantTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatToParticipantTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatToParticipantTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatToParticipantTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<int> participantId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatToParticipantCompanion(
                chatId: chatId,
                participantId: participantId,
                role: role,
                sortKey: sortKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int chatId,
                required int participantId,
                Value<String> role = const Value.absent(),
                Value<int> sortKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatToParticipantCompanion.insert(
                chatId: chatId,
                participantId: participantId,
                role: role,
                sortKey: sortKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatToParticipantTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatId = false, participantId = false}) {
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
                    if (chatId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chatId,
                                referencedTable:
                                    $$ChatToParticipantTableReferences
                                        ._chatIdTable(db),
                                referencedColumn:
                                    $$ChatToParticipantTableReferences
                                        ._chatIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (participantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.participantId,
                                referencedTable:
                                    $$ChatToParticipantTableReferences
                                        ._participantIdTable(db),
                                referencedColumn:
                                    $$ChatToParticipantTableReferences
                                        ._participantIdTable(db)
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

typedef $$ChatToParticipantTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ChatToParticipantTable,
      ChatToParticipantData,
      $$ChatToParticipantTableFilterComposer,
      $$ChatToParticipantTableOrderingComposer,
      $$ChatToParticipantTableAnnotationComposer,
      $$ChatToParticipantTableCreateCompanionBuilder,
      $$ChatToParticipantTableUpdateCompanionBuilder,
      (ChatToParticipantData, $$ChatToParticipantTableReferences),
      ChatToParticipantData,
      PrefetchHooks Function({bool chatId, bool participantId})
    >;
typedef $$WorkingMessagesTableCreateCompanionBuilder =
    WorkingMessagesCompanion Function({
      Value<int> id,
      required String guid,
      required int chatId,
      Value<int?> senderParticipantId,
      Value<bool> isFromMe,
      Value<String?> sentAtUtc,
      Value<String?> deliveredAtUtc,
      Value<String?> readAtUtc,
      Value<String> status,
      Value<String?> textContent,
      Value<bool> hasAttachments,
      Value<String?> replyToGuid,
      Value<String?> systemType,
      Value<bool> reactionCarrier,
      Value<String?> balloonBundleId,
      Value<String?> reactionSummaryJson,
      Value<bool> isStarred,
      Value<bool> isDeletedLocal,
      Value<String?> updatedAtUtc,
    });
typedef $$WorkingMessagesTableUpdateCompanionBuilder =
    WorkingMessagesCompanion Function({
      Value<int> id,
      Value<String> guid,
      Value<int> chatId,
      Value<int?> senderParticipantId,
      Value<bool> isFromMe,
      Value<String?> sentAtUtc,
      Value<String?> deliveredAtUtc,
      Value<String?> readAtUtc,
      Value<String> status,
      Value<String?> textContent,
      Value<bool> hasAttachments,
      Value<String?> replyToGuid,
      Value<String?> systemType,
      Value<bool> reactionCarrier,
      Value<String?> balloonBundleId,
      Value<String?> reactionSummaryJson,
      Value<bool> isStarred,
      Value<bool> isDeletedLocal,
      Value<String?> updatedAtUtc,
    });

final class $$WorkingMessagesTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $WorkingMessagesTable,
          WorkingMessage
        > {
  $$WorkingMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkingChatsTable _chatIdTable(_$WorkingDatabase db) =>
      db.workingChats.createAlias(
        $_aliasNameGenerator(db.workingMessages.chatId, db.workingChats.id),
      );

  $$WorkingChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$WorkingChatsTableTableManager(
      $_db,
      $_db.workingChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkingParticipantsTable _senderParticipantIdTable(
    _$WorkingDatabase db,
  ) => db.workingParticipants.createAlias(
    $_aliasNameGenerator(
      db.workingMessages.senderParticipantId,
      db.workingParticipants.id,
    ),
  );

  $$WorkingParticipantsTableProcessedTableManager? get senderParticipantId {
    final $_column = $_itemColumn<int>('sender_participant_id');
    if ($_column == null) return null;
    final manager = $$WorkingParticipantsTableTableManager(
      $_db,
      $_db.workingParticipants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_senderParticipantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkingMessagesTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingMessagesTable> {
  $$WorkingMessagesTableFilterComposer({
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

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFromMe => $composableBuilder(
    column: $table.isFromMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveredAtUtc => $composableBuilder(
    column: $table.deliveredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readAtUtc => $composableBuilder(
    column: $table.readAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyToGuid => $composableBuilder(
    column: $table.replyToGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reactionCarrier => $composableBuilder(
    column: $table.reactionCarrier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get balloonBundleId => $composableBuilder(
    column: $table.balloonBundleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reactionSummaryJson => $composableBuilder(
    column: $table.reactionSummaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeletedLocal => $composableBuilder(
    column: $table.isDeletedLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingChatsTableFilterComposer get chatId {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingParticipantsTableFilterComposer get senderParticipantId {
    final $$WorkingParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderParticipantId,
      referencedTable: $db.workingParticipants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.workingParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkingMessagesTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingMessagesTable> {
  $$WorkingMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFromMe => $composableBuilder(
    column: $table.isFromMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sentAtUtc => $composableBuilder(
    column: $table.sentAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveredAtUtc => $composableBuilder(
    column: $table.deliveredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readAtUtc => $composableBuilder(
    column: $table.readAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyToGuid => $composableBuilder(
    column: $table.replyToGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reactionCarrier => $composableBuilder(
    column: $table.reactionCarrier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get balloonBundleId => $composableBuilder(
    column: $table.balloonBundleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactionSummaryJson => $composableBuilder(
    column: $table.reactionSummaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeletedLocal => $composableBuilder(
    column: $table.isDeletedLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingChatsTableOrderingComposer get chatId {
    final $$WorkingChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableOrderingComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingParticipantsTableOrderingComposer get senderParticipantId {
    final $$WorkingParticipantsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.senderParticipantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableOrderingComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkingMessagesTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingMessagesTable> {
  $$WorkingMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<bool> get isFromMe =>
      $composableBuilder(column: $table.isFromMe, builder: (column) => column);

  GeneratedColumn<String> get sentAtUtc =>
      $composableBuilder(column: $table.sentAtUtc, builder: (column) => column);

  GeneratedColumn<String> get deliveredAtUtc => $composableBuilder(
    column: $table.deliveredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readAtUtc =>
      $composableBuilder(column: $table.readAtUtc, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replyToGuid => $composableBuilder(
    column: $table.replyToGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get systemType => $composableBuilder(
    column: $table.systemType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reactionCarrier => $composableBuilder(
    column: $table.reactionCarrier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get balloonBundleId => $composableBuilder(
    column: $table.balloonBundleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reactionSummaryJson => $composableBuilder(
    column: $table.reactionSummaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get isDeletedLocal => $composableBuilder(
    column: $table.isDeletedLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  $$WorkingChatsTableAnnotationComposer get chatId {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkingParticipantsTableAnnotationComposer get senderParticipantId {
    final $$WorkingParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.senderParticipantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkingMessagesTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingMessagesTable,
          WorkingMessage,
          $$WorkingMessagesTableFilterComposer,
          $$WorkingMessagesTableOrderingComposer,
          $$WorkingMessagesTableAnnotationComposer,
          $$WorkingMessagesTableCreateCompanionBuilder,
          $$WorkingMessagesTableUpdateCompanionBuilder,
          (WorkingMessage, $$WorkingMessagesTableReferences),
          WorkingMessage,
          PrefetchHooks Function({bool chatId, bool senderParticipantId})
        > {
  $$WorkingMessagesTableTableManager(
    _$WorkingDatabase db,
    $WorkingMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkingMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<int?> senderParticipantId = const Value.absent(),
                Value<bool> isFromMe = const Value.absent(),
                Value<String?> sentAtUtc = const Value.absent(),
                Value<String?> deliveredAtUtc = const Value.absent(),
                Value<String?> readAtUtc = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<bool> hasAttachments = const Value.absent(),
                Value<String?> replyToGuid = const Value.absent(),
                Value<String?> systemType = const Value.absent(),
                Value<bool> reactionCarrier = const Value.absent(),
                Value<String?> balloonBundleId = const Value.absent(),
                Value<String?> reactionSummaryJson = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isDeletedLocal = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
              }) => WorkingMessagesCompanion(
                id: id,
                guid: guid,
                chatId: chatId,
                senderParticipantId: senderParticipantId,
                isFromMe: isFromMe,
                sentAtUtc: sentAtUtc,
                deliveredAtUtc: deliveredAtUtc,
                readAtUtc: readAtUtc,
                status: status,
                textContent: textContent,
                hasAttachments: hasAttachments,
                replyToGuid: replyToGuid,
                systemType: systemType,
                reactionCarrier: reactionCarrier,
                balloonBundleId: balloonBundleId,
                reactionSummaryJson: reactionSummaryJson,
                isStarred: isStarred,
                isDeletedLocal: isDeletedLocal,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String guid,
                required int chatId,
                Value<int?> senderParticipantId = const Value.absent(),
                Value<bool> isFromMe = const Value.absent(),
                Value<String?> sentAtUtc = const Value.absent(),
                Value<String?> deliveredAtUtc = const Value.absent(),
                Value<String?> readAtUtc = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<bool> hasAttachments = const Value.absent(),
                Value<String?> replyToGuid = const Value.absent(),
                Value<String?> systemType = const Value.absent(),
                Value<bool> reactionCarrier = const Value.absent(),
                Value<String?> balloonBundleId = const Value.absent(),
                Value<String?> reactionSummaryJson = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isDeletedLocal = const Value.absent(),
                Value<String?> updatedAtUtc = const Value.absent(),
              }) => WorkingMessagesCompanion.insert(
                id: id,
                guid: guid,
                chatId: chatId,
                senderParticipantId: senderParticipantId,
                isFromMe: isFromMe,
                sentAtUtc: sentAtUtc,
                deliveredAtUtc: deliveredAtUtc,
                readAtUtc: readAtUtc,
                status: status,
                textContent: textContent,
                hasAttachments: hasAttachments,
                replyToGuid: replyToGuid,
                systemType: systemType,
                reactionCarrier: reactionCarrier,
                balloonBundleId: balloonBundleId,
                reactionSummaryJson: reactionSummaryJson,
                isStarred: isStarred,
                isDeletedLocal: isDeletedLocal,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkingMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({chatId = false, senderParticipantId = false}) {
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
                        if (chatId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chatId,
                                    referencedTable:
                                        $$WorkingMessagesTableReferences
                                            ._chatIdTable(db),
                                    referencedColumn:
                                        $$WorkingMessagesTableReferences
                                            ._chatIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (senderParticipantId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.senderParticipantId,
                                    referencedTable:
                                        $$WorkingMessagesTableReferences
                                            ._senderParticipantIdTable(db),
                                    referencedColumn:
                                        $$WorkingMessagesTableReferences
                                            ._senderParticipantIdTable(db)
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

typedef $$WorkingMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingMessagesTable,
      WorkingMessage,
      $$WorkingMessagesTableFilterComposer,
      $$WorkingMessagesTableOrderingComposer,
      $$WorkingMessagesTableAnnotationComposer,
      $$WorkingMessagesTableCreateCompanionBuilder,
      $$WorkingMessagesTableUpdateCompanionBuilder,
      (WorkingMessage, $$WorkingMessagesTableReferences),
      WorkingMessage,
      PrefetchHooks Function({bool chatId, bool senderParticipantId})
    >;
typedef $$WorkingAttachmentsTableCreateCompanionBuilder =
    WorkingAttachmentsCompanion Function({
      Value<int> id,
      required String messageGuid,
      Value<int?> importAttachmentId,
      Value<String?> localPath,
      Value<String?> mimeType,
      Value<String?> uti,
      Value<String?> transferName,
      Value<int?> sizeBytes,
      Value<bool> isSticker,
      Value<String?> thumbPath,
      Value<String?> createdAtUtc,
    });
typedef $$WorkingAttachmentsTableUpdateCompanionBuilder =
    WorkingAttachmentsCompanion Function({
      Value<int> id,
      Value<String> messageGuid,
      Value<int?> importAttachmentId,
      Value<String?> localPath,
      Value<String?> mimeType,
      Value<String?> uti,
      Value<String?> transferName,
      Value<int?> sizeBytes,
      Value<bool> isSticker,
      Value<String?> thumbPath,
      Value<String?> createdAtUtc,
    });

class $$WorkingAttachmentsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingAttachmentsTable> {
  $$WorkingAttachmentsTableFilterComposer({
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

  ColumnFilters<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importAttachmentId => $composableBuilder(
    column: $table.importAttachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uti => $composableBuilder(
    column: $table.uti,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferName => $composableBuilder(
    column: $table.transferName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSticker => $composableBuilder(
    column: $table.isSticker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkingAttachmentsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingAttachmentsTable> {
  $$WorkingAttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importAttachmentId => $composableBuilder(
    column: $table.importAttachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uti => $composableBuilder(
    column: $table.uti,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferName => $composableBuilder(
    column: $table.transferName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSticker => $composableBuilder(
    column: $table.isSticker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkingAttachmentsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingAttachmentsTable> {
  $$WorkingAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importAttachmentId => $composableBuilder(
    column: $table.importAttachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get uti =>
      $composableBuilder(column: $table.uti, builder: (column) => column);

  GeneratedColumn<String> get transferName => $composableBuilder(
    column: $table.transferName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get isSticker =>
      $composableBuilder(column: $table.isSticker, builder: (column) => column);

  GeneratedColumn<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$WorkingAttachmentsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingAttachmentsTable,
          WorkingAttachment,
          $$WorkingAttachmentsTableFilterComposer,
          $$WorkingAttachmentsTableOrderingComposer,
          $$WorkingAttachmentsTableAnnotationComposer,
          $$WorkingAttachmentsTableCreateCompanionBuilder,
          $$WorkingAttachmentsTableUpdateCompanionBuilder,
          (
            WorkingAttachment,
            BaseReferences<
              _$WorkingDatabase,
              $WorkingAttachmentsTable,
              WorkingAttachment
            >,
          ),
          WorkingAttachment,
          PrefetchHooks Function()
        > {
  $$WorkingAttachmentsTableTableManager(
    _$WorkingDatabase db,
    $WorkingAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkingAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageGuid = const Value.absent(),
                Value<int?> importAttachmentId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<String?> uti = const Value.absent(),
                Value<String?> transferName = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<bool> isSticker = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
              }) => WorkingAttachmentsCompanion(
                id: id,
                messageGuid: messageGuid,
                importAttachmentId: importAttachmentId,
                localPath: localPath,
                mimeType: mimeType,
                uti: uti,
                transferName: transferName,
                sizeBytes: sizeBytes,
                isSticker: isSticker,
                thumbPath: thumbPath,
                createdAtUtc: createdAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageGuid,
                Value<int?> importAttachmentId = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<String?> uti = const Value.absent(),
                Value<String?> transferName = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<bool> isSticker = const Value.absent(),
                Value<String?> thumbPath = const Value.absent(),
                Value<String?> createdAtUtc = const Value.absent(),
              }) => WorkingAttachmentsCompanion.insert(
                id: id,
                messageGuid: messageGuid,
                importAttachmentId: importAttachmentId,
                localPath: localPath,
                mimeType: mimeType,
                uti: uti,
                transferName: transferName,
                sizeBytes: sizeBytes,
                isSticker: isSticker,
                thumbPath: thumbPath,
                createdAtUtc: createdAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkingAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingAttachmentsTable,
      WorkingAttachment,
      $$WorkingAttachmentsTableFilterComposer,
      $$WorkingAttachmentsTableOrderingComposer,
      $$WorkingAttachmentsTableAnnotationComposer,
      $$WorkingAttachmentsTableCreateCompanionBuilder,
      $$WorkingAttachmentsTableUpdateCompanionBuilder,
      (
        WorkingAttachment,
        BaseReferences<
          _$WorkingDatabase,
          $WorkingAttachmentsTable,
          WorkingAttachment
        >,
      ),
      WorkingAttachment,
      PrefetchHooks Function()
    >;
typedef $$WorkingReactionsTableCreateCompanionBuilder =
    WorkingReactionsCompanion Function({
      Value<int> id,
      required String messageGuid,
      required String kind,
      Value<int?> reactorParticipantId,
      required String action,
      Value<String?> reactedAtUtc,
    });
typedef $$WorkingReactionsTableUpdateCompanionBuilder =
    WorkingReactionsCompanion Function({
      Value<int> id,
      Value<String> messageGuid,
      Value<String> kind,
      Value<int?> reactorParticipantId,
      Value<String> action,
      Value<String?> reactedAtUtc,
    });

final class $$WorkingReactionsTableReferences
    extends
        BaseReferences<
          _$WorkingDatabase,
          $WorkingReactionsTable,
          WorkingReaction
        > {
  $$WorkingReactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkingParticipantsTable _reactorParticipantIdTable(
    _$WorkingDatabase db,
  ) => db.workingParticipants.createAlias(
    $_aliasNameGenerator(
      db.workingReactions.reactorParticipantId,
      db.workingParticipants.id,
    ),
  );

  $$WorkingParticipantsTableProcessedTableManager? get reactorParticipantId {
    final $_column = $_itemColumn<int>('reactor_participant_id');
    if ($_column == null) return null;
    final manager = $$WorkingParticipantsTableTableManager(
      $_db,
      $_db.workingParticipants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _reactorParticipantIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkingReactionsTableFilterComposer
    extends Composer<_$WorkingDatabase, $WorkingReactionsTable> {
  $$WorkingReactionsTableFilterComposer({
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

  ColumnFilters<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reactedAtUtc => $composableBuilder(
    column: $table.reactedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingParticipantsTableFilterComposer get reactorParticipantId {
    final $$WorkingParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reactorParticipantId,
      referencedTable: $db.workingParticipants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.workingParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkingReactionsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $WorkingReactionsTable> {
  $$WorkingReactionsTableOrderingComposer({
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

  ColumnOrderings<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactedAtUtc => $composableBuilder(
    column: $table.reactedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingParticipantsTableOrderingComposer get reactorParticipantId {
    final $$WorkingParticipantsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reactorParticipantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableOrderingComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkingReactionsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $WorkingReactionsTable> {
  $$WorkingReactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get reactedAtUtc => $composableBuilder(
    column: $table.reactedAtUtc,
    builder: (column) => column,
  );

  $$WorkingParticipantsTableAnnotationComposer get reactorParticipantId {
    final $$WorkingParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.reactorParticipantId,
          referencedTable: $db.workingParticipants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkingParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.workingParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$WorkingReactionsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $WorkingReactionsTable,
          WorkingReaction,
          $$WorkingReactionsTableFilterComposer,
          $$WorkingReactionsTableOrderingComposer,
          $$WorkingReactionsTableAnnotationComposer,
          $$WorkingReactionsTableCreateCompanionBuilder,
          $$WorkingReactionsTableUpdateCompanionBuilder,
          (WorkingReaction, $$WorkingReactionsTableReferences),
          WorkingReaction,
          PrefetchHooks Function({bool reactorParticipantId})
        > {
  $$WorkingReactionsTableTableManager(
    _$WorkingDatabase db,
    $WorkingReactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkingReactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkingReactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkingReactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageGuid = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> reactorParticipantId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> reactedAtUtc = const Value.absent(),
              }) => WorkingReactionsCompanion(
                id: id,
                messageGuid: messageGuid,
                kind: kind,
                reactorParticipantId: reactorParticipantId,
                action: action,
                reactedAtUtc: reactedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageGuid,
                required String kind,
                Value<int?> reactorParticipantId = const Value.absent(),
                required String action,
                Value<String?> reactedAtUtc = const Value.absent(),
              }) => WorkingReactionsCompanion.insert(
                id: id,
                messageGuid: messageGuid,
                kind: kind,
                reactorParticipantId: reactorParticipantId,
                action: action,
                reactedAtUtc: reactedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkingReactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reactorParticipantId = false}) {
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
                    if (reactorParticipantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reactorParticipantId,
                                referencedTable:
                                    $$WorkingReactionsTableReferences
                                        ._reactorParticipantIdTable(db),
                                referencedColumn:
                                    $$WorkingReactionsTableReferences
                                        ._reactorParticipantIdTable(db)
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

typedef $$WorkingReactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $WorkingReactionsTable,
      WorkingReaction,
      $$WorkingReactionsTableFilterComposer,
      $$WorkingReactionsTableOrderingComposer,
      $$WorkingReactionsTableAnnotationComposer,
      $$WorkingReactionsTableCreateCompanionBuilder,
      $$WorkingReactionsTableUpdateCompanionBuilder,
      (WorkingReaction, $$WorkingReactionsTableReferences),
      WorkingReaction,
      PrefetchHooks Function({bool reactorParticipantId})
    >;
typedef $$ReactionCountsTableCreateCompanionBuilder =
    ReactionCountsCompanion Function({
      required String messageGuid,
      Value<int> love,
      Value<int> like,
      Value<int> dislike,
      Value<int> laugh,
      Value<int> emphasize,
      Value<int> question,
      Value<int> rowid,
    });
typedef $$ReactionCountsTableUpdateCompanionBuilder =
    ReactionCountsCompanion Function({
      Value<String> messageGuid,
      Value<int> love,
      Value<int> like,
      Value<int> dislike,
      Value<int> laugh,
      Value<int> emphasize,
      Value<int> question,
      Value<int> rowid,
    });

class $$ReactionCountsTableFilterComposer
    extends Composer<_$WorkingDatabase, $ReactionCountsTable> {
  $$ReactionCountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get love => $composableBuilder(
    column: $table.love,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get like => $composableBuilder(
    column: $table.like,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dislike => $composableBuilder(
    column: $table.dislike,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get laugh => $composableBuilder(
    column: $table.laugh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emphasize => $composableBuilder(
    column: $table.emphasize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReactionCountsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ReactionCountsTable> {
  $$ReactionCountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get love => $composableBuilder(
    column: $table.love,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get like => $composableBuilder(
    column: $table.like,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dislike => $composableBuilder(
    column: $table.dislike,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get laugh => $composableBuilder(
    column: $table.laugh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emphasize => $composableBuilder(
    column: $table.emphasize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReactionCountsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ReactionCountsTable> {
  $$ReactionCountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get love =>
      $composableBuilder(column: $table.love, builder: (column) => column);

  GeneratedColumn<int> get like =>
      $composableBuilder(column: $table.like, builder: (column) => column);

  GeneratedColumn<int> get dislike =>
      $composableBuilder(column: $table.dislike, builder: (column) => column);

  GeneratedColumn<int> get laugh =>
      $composableBuilder(column: $table.laugh, builder: (column) => column);

  GeneratedColumn<int> get emphasize =>
      $composableBuilder(column: $table.emphasize, builder: (column) => column);

  GeneratedColumn<int> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);
}

class $$ReactionCountsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ReactionCountsTable,
          ReactionCount,
          $$ReactionCountsTableFilterComposer,
          $$ReactionCountsTableOrderingComposer,
          $$ReactionCountsTableAnnotationComposer,
          $$ReactionCountsTableCreateCompanionBuilder,
          $$ReactionCountsTableUpdateCompanionBuilder,
          (
            ReactionCount,
            BaseReferences<
              _$WorkingDatabase,
              $ReactionCountsTable,
              ReactionCount
            >,
          ),
          ReactionCount,
          PrefetchHooks Function()
        > {
  $$ReactionCountsTableTableManager(
    _$WorkingDatabase db,
    $ReactionCountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReactionCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReactionCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReactionCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageGuid = const Value.absent(),
                Value<int> love = const Value.absent(),
                Value<int> like = const Value.absent(),
                Value<int> dislike = const Value.absent(),
                Value<int> laugh = const Value.absent(),
                Value<int> emphasize = const Value.absent(),
                Value<int> question = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionCountsCompanion(
                messageGuid: messageGuid,
                love: love,
                like: like,
                dislike: dislike,
                laugh: laugh,
                emphasize: emphasize,
                question: question,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageGuid,
                Value<int> love = const Value.absent(),
                Value<int> like = const Value.absent(),
                Value<int> dislike = const Value.absent(),
                Value<int> laugh = const Value.absent(),
                Value<int> emphasize = const Value.absent(),
                Value<int> question = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReactionCountsCompanion.insert(
                messageGuid: messageGuid,
                love: love,
                like: like,
                dislike: dislike,
                laugh: laugh,
                emphasize: emphasize,
                question: question,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReactionCountsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ReactionCountsTable,
      ReactionCount,
      $$ReactionCountsTableFilterComposer,
      $$ReactionCountsTableOrderingComposer,
      $$ReactionCountsTableAnnotationComposer,
      $$ReactionCountsTableCreateCompanionBuilder,
      $$ReactionCountsTableUpdateCompanionBuilder,
      (
        ReactionCount,
        BaseReferences<_$WorkingDatabase, $ReactionCountsTable, ReactionCount>,
      ),
      ReactionCount,
      PrefetchHooks Function()
    >;
typedef $$ReadStateTableCreateCompanionBuilder =
    ReadStateCompanion Function({
      Value<int> chatId,
      Value<String?> lastReadAtUtc,
    });
typedef $$ReadStateTableUpdateCompanionBuilder =
    ReadStateCompanion Function({
      Value<int> chatId,
      Value<String?> lastReadAtUtc,
    });

final class $$ReadStateTableReferences
    extends BaseReferences<_$WorkingDatabase, $ReadStateTable, ReadStateData> {
  $$ReadStateTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkingChatsTable _chatIdTable(_$WorkingDatabase db) =>
      db.workingChats.createAlias(
        $_aliasNameGenerator(db.readState.chatId, db.workingChats.id),
      );

  $$WorkingChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$WorkingChatsTableTableManager(
      $_db,
      $_db.workingChats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadStateTableFilterComposer
    extends Composer<_$WorkingDatabase, $ReadStateTable> {
  $$ReadStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lastReadAtUtc => $composableBuilder(
    column: $table.lastReadAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkingChatsTableFilterComposer get chatId {
    final $$WorkingChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableFilterComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadStateTableOrderingComposer
    extends Composer<_$WorkingDatabase, $ReadStateTable> {
  $$ReadStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lastReadAtUtc => $composableBuilder(
    column: $table.lastReadAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkingChatsTableOrderingComposer get chatId {
    final $$WorkingChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableOrderingComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadStateTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $ReadStateTable> {
  $$ReadStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lastReadAtUtc => $composableBuilder(
    column: $table.lastReadAtUtc,
    builder: (column) => column,
  );

  $$WorkingChatsTableAnnotationComposer get chatId {
    final $$WorkingChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.workingChats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkingChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.workingChats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadStateTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $ReadStateTable,
          ReadStateData,
          $$ReadStateTableFilterComposer,
          $$ReadStateTableOrderingComposer,
          $$ReadStateTableAnnotationComposer,
          $$ReadStateTableCreateCompanionBuilder,
          $$ReadStateTableUpdateCompanionBuilder,
          (ReadStateData, $$ReadStateTableReferences),
          ReadStateData,
          PrefetchHooks Function({bool chatId})
        > {
  $$ReadStateTableTableManager(_$WorkingDatabase db, $ReadStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> lastReadAtUtc = const Value.absent(),
              }) => ReadStateCompanion(
                chatId: chatId,
                lastReadAtUtc: lastReadAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> lastReadAtUtc = const Value.absent(),
              }) => ReadStateCompanion.insert(
                chatId: chatId,
                lastReadAtUtc: lastReadAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadStateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatId = false}) {
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
                    if (chatId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.chatId,
                                referencedTable: $$ReadStateTableReferences
                                    ._chatIdTable(db),
                                referencedColumn: $$ReadStateTableReferences
                                    ._chatIdTable(db)
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

typedef $$ReadStateTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $ReadStateTable,
      ReadStateData,
      $$ReadStateTableFilterComposer,
      $$ReadStateTableOrderingComposer,
      $$ReadStateTableAnnotationComposer,
      $$ReadStateTableCreateCompanionBuilder,
      $$ReadStateTableUpdateCompanionBuilder,
      (ReadStateData, $$ReadStateTableReferences),
      ReadStateData,
      PrefetchHooks Function({bool chatId})
    >;
typedef $$MessageReadMarksTableCreateCompanionBuilder =
    MessageReadMarksCompanion Function({
      required String messageGuid,
      required String markedAtUtc,
      Value<int> rowid,
    });
typedef $$MessageReadMarksTableUpdateCompanionBuilder =
    MessageReadMarksCompanion Function({
      Value<String> messageGuid,
      Value<String> markedAtUtc,
      Value<int> rowid,
    });

class $$MessageReadMarksTableFilterComposer
    extends Composer<_$WorkingDatabase, $MessageReadMarksTable> {
  $$MessageReadMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markedAtUtc => $composableBuilder(
    column: $table.markedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessageReadMarksTableOrderingComposer
    extends Composer<_$WorkingDatabase, $MessageReadMarksTable> {
  $$MessageReadMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markedAtUtc => $composableBuilder(
    column: $table.markedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessageReadMarksTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $MessageReadMarksTable> {
  $$MessageReadMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageGuid => $composableBuilder(
    column: $table.messageGuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get markedAtUtc => $composableBuilder(
    column: $table.markedAtUtc,
    builder: (column) => column,
  );
}

class $$MessageReadMarksTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $MessageReadMarksTable,
          MessageReadMark,
          $$MessageReadMarksTableFilterComposer,
          $$MessageReadMarksTableOrderingComposer,
          $$MessageReadMarksTableAnnotationComposer,
          $$MessageReadMarksTableCreateCompanionBuilder,
          $$MessageReadMarksTableUpdateCompanionBuilder,
          (
            MessageReadMark,
            BaseReferences<
              _$WorkingDatabase,
              $MessageReadMarksTable,
              MessageReadMark
            >,
          ),
          MessageReadMark,
          PrefetchHooks Function()
        > {
  $$MessageReadMarksTableTableManager(
    _$WorkingDatabase db,
    $MessageReadMarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageReadMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageReadMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageReadMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageGuid = const Value.absent(),
                Value<String> markedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageReadMarksCompanion(
                messageGuid: messageGuid,
                markedAtUtc: markedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageGuid,
                required String markedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => MessageReadMarksCompanion.insert(
                messageGuid: messageGuid,
                markedAtUtc: markedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageReadMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $MessageReadMarksTable,
      MessageReadMark,
      $$MessageReadMarksTableFilterComposer,
      $$MessageReadMarksTableOrderingComposer,
      $$MessageReadMarksTableAnnotationComposer,
      $$MessageReadMarksTableCreateCompanionBuilder,
      $$MessageReadMarksTableUpdateCompanionBuilder,
      (
        MessageReadMark,
        BaseReferences<
          _$WorkingDatabase,
          $MessageReadMarksTable,
          MessageReadMark
        >,
      ),
      MessageReadMark,
      PrefetchHooks Function()
    >;
typedef $$SupabaseSyncStateTableCreateCompanionBuilder =
    SupabaseSyncStateCompanion Function({
      Value<int> id,
      required String targetTable,
      Value<int?> lastBatchId,
      Value<int?> lastSyncedRowId,
      Value<String?> lastSyncedGuid,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> updatedAt,
    });
typedef $$SupabaseSyncStateTableUpdateCompanionBuilder =
    SupabaseSyncStateCompanion Function({
      Value<int> id,
      Value<String> targetTable,
      Value<int?> lastBatchId,
      Value<int?> lastSyncedRowId,
      Value<String?> lastSyncedGuid,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> updatedAt,
    });

class $$SupabaseSyncStateTableFilterComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncStateTable> {
  $$SupabaseSyncStateTableFilterComposer({
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

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastBatchId => $composableBuilder(
    column: $table.lastBatchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedRowId => $composableBuilder(
    column: $table.lastSyncedRowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncedGuid => $composableBuilder(
    column: $table.lastSyncedGuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupabaseSyncStateTableOrderingComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncStateTable> {
  $$SupabaseSyncStateTableOrderingComposer({
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

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastBatchId => $composableBuilder(
    column: $table.lastBatchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedRowId => $composableBuilder(
    column: $table.lastSyncedRowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncedGuid => $composableBuilder(
    column: $table.lastSyncedGuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupabaseSyncStateTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncStateTable> {
  $$SupabaseSyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastBatchId => $composableBuilder(
    column: $table.lastBatchId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedRowId => $composableBuilder(
    column: $table.lastSyncedRowId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncedGuid => $composableBuilder(
    column: $table.lastSyncedGuid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SupabaseSyncStateTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $SupabaseSyncStateTable,
          SupabaseSyncStateData,
          $$SupabaseSyncStateTableFilterComposer,
          $$SupabaseSyncStateTableOrderingComposer,
          $$SupabaseSyncStateTableAnnotationComposer,
          $$SupabaseSyncStateTableCreateCompanionBuilder,
          $$SupabaseSyncStateTableUpdateCompanionBuilder,
          (
            SupabaseSyncStateData,
            BaseReferences<
              _$WorkingDatabase,
              $SupabaseSyncStateTable,
              SupabaseSyncStateData
            >,
          ),
          SupabaseSyncStateData,
          PrefetchHooks Function()
        > {
  $$SupabaseSyncStateTableTableManager(
    _$WorkingDatabase db,
    $SupabaseSyncStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupabaseSyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupabaseSyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupabaseSyncStateTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<int?> lastBatchId = const Value.absent(),
                Value<int?> lastSyncedRowId = const Value.absent(),
                Value<String?> lastSyncedGuid = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SupabaseSyncStateCompanion(
                id: id,
                targetTable: targetTable,
                lastBatchId: lastBatchId,
                lastSyncedRowId: lastSyncedRowId,
                lastSyncedGuid: lastSyncedGuid,
                lastSyncedAt: lastSyncedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetTable,
                Value<int?> lastBatchId = const Value.absent(),
                Value<int?> lastSyncedRowId = const Value.absent(),
                Value<String?> lastSyncedGuid = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SupabaseSyncStateCompanion.insert(
                id: id,
                targetTable: targetTable,
                lastBatchId: lastBatchId,
                lastSyncedRowId: lastSyncedRowId,
                lastSyncedGuid: lastSyncedGuid,
                lastSyncedAt: lastSyncedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupabaseSyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $SupabaseSyncStateTable,
      SupabaseSyncStateData,
      $$SupabaseSyncStateTableFilterComposer,
      $$SupabaseSyncStateTableOrderingComposer,
      $$SupabaseSyncStateTableAnnotationComposer,
      $$SupabaseSyncStateTableCreateCompanionBuilder,
      $$SupabaseSyncStateTableUpdateCompanionBuilder,
      (
        SupabaseSyncStateData,
        BaseReferences<
          _$WorkingDatabase,
          $SupabaseSyncStateTable,
          SupabaseSyncStateData
        >,
      ),
      SupabaseSyncStateData,
      PrefetchHooks Function()
    >;
typedef $$SupabaseSyncLogsTableCreateCompanionBuilder =
    SupabaseSyncLogsCompanion Function({
      Value<int> id,
      Value<int?> batchId,
      Value<String?> targetTable,
      Value<String?> status,
      Value<int> attempt,
      Value<String?> requestId,
      Value<String?> message,
      Value<DateTime> createdAt,
    });
typedef $$SupabaseSyncLogsTableUpdateCompanionBuilder =
    SupabaseSyncLogsCompanion Function({
      Value<int> id,
      Value<int?> batchId,
      Value<String?> targetTable,
      Value<String?> status,
      Value<int> attempt,
      Value<String?> requestId,
      Value<String?> message,
      Value<DateTime> createdAt,
    });

class $$SupabaseSyncLogsTableFilterComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncLogsTable> {
  $$SupabaseSyncLogsTableFilterComposer({
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

  ColumnFilters<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupabaseSyncLogsTableOrderingComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncLogsTable> {
  $$SupabaseSyncLogsTableOrderingComposer({
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

  ColumnOrderings<int> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupabaseSyncLogsTableAnnotationComposer
    extends Composer<_$WorkingDatabase, $SupabaseSyncLogsTable> {
  $$SupabaseSyncLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SupabaseSyncLogsTableTableManager
    extends
        RootTableManager<
          _$WorkingDatabase,
          $SupabaseSyncLogsTable,
          SupabaseSyncLog,
          $$SupabaseSyncLogsTableFilterComposer,
          $$SupabaseSyncLogsTableOrderingComposer,
          $$SupabaseSyncLogsTableAnnotationComposer,
          $$SupabaseSyncLogsTableCreateCompanionBuilder,
          $$SupabaseSyncLogsTableUpdateCompanionBuilder,
          (
            SupabaseSyncLog,
            BaseReferences<
              _$WorkingDatabase,
              $SupabaseSyncLogsTable,
              SupabaseSyncLog
            >,
          ),
          SupabaseSyncLog,
          PrefetchHooks Function()
        > {
  $$SupabaseSyncLogsTableTableManager(
    _$WorkingDatabase db,
    $SupabaseSyncLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupabaseSyncLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupabaseSyncLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupabaseSyncLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
                Value<String?> targetTable = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SupabaseSyncLogsCompanion(
                id: id,
                batchId: batchId,
                targetTable: targetTable,
                status: status,
                attempt: attempt,
                requestId: requestId,
                message: message,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> batchId = const Value.absent(),
                Value<String?> targetTable = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<String?> requestId = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SupabaseSyncLogsCompanion.insert(
                id: id,
                batchId: batchId,
                targetTable: targetTable,
                status: status,
                attempt: attempt,
                requestId: requestId,
                message: message,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupabaseSyncLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$WorkingDatabase,
      $SupabaseSyncLogsTable,
      SupabaseSyncLog,
      $$SupabaseSyncLogsTableFilterComposer,
      $$SupabaseSyncLogsTableOrderingComposer,
      $$SupabaseSyncLogsTableAnnotationComposer,
      $$SupabaseSyncLogsTableCreateCompanionBuilder,
      $$SupabaseSyncLogsTableUpdateCompanionBuilder,
      (
        SupabaseSyncLog,
        BaseReferences<
          _$WorkingDatabase,
          $SupabaseSyncLogsTable,
          SupabaseSyncLog
        >,
      ),
      SupabaseSyncLog,
      PrefetchHooks Function()
    >;

class $WorkingDatabaseManager {
  final _$WorkingDatabase _db;
  $WorkingDatabaseManager(this._db);
  $$WorkingSchemaMigrationsTableTableManager get workingSchemaMigrations =>
      $$WorkingSchemaMigrationsTableTableManager(
        _db,
        _db.workingSchemaMigrations,
      );
  $$ProjectionStateTableTableManager get projectionState =>
      $$ProjectionStateTableTableManager(_db, _db.projectionState);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$WorkingParticipantsTableTableManager get workingParticipants =>
      $$WorkingParticipantsTableTableManager(_db, _db.workingParticipants);
  $$ParticipantHandleLinksTableTableManager get participantHandleLinks =>
      $$ParticipantHandleLinksTableTableManager(
        _db,
        _db.participantHandleLinks,
      );
  $$WorkingChatsTableTableManager get workingChats =>
      $$WorkingChatsTableTableManager(_db, _db.workingChats);
  $$ChatToParticipantTableTableManager get chatToParticipant =>
      $$ChatToParticipantTableTableManager(_db, _db.chatToParticipant);
  $$WorkingMessagesTableTableManager get workingMessages =>
      $$WorkingMessagesTableTableManager(_db, _db.workingMessages);
  $$WorkingAttachmentsTableTableManager get workingAttachments =>
      $$WorkingAttachmentsTableTableManager(_db, _db.workingAttachments);
  $$WorkingReactionsTableTableManager get workingReactions =>
      $$WorkingReactionsTableTableManager(_db, _db.workingReactions);
  $$ReactionCountsTableTableManager get reactionCounts =>
      $$ReactionCountsTableTableManager(_db, _db.reactionCounts);
  $$ReadStateTableTableManager get readState =>
      $$ReadStateTableTableManager(_db, _db.readState);
  $$MessageReadMarksTableTableManager get messageReadMarks =>
      $$MessageReadMarksTableTableManager(_db, _db.messageReadMarks);
  $$SupabaseSyncStateTableTableManager get supabaseSyncState =>
      $$SupabaseSyncStateTableTableManager(_db, _db.supabaseSyncState);
  $$SupabaseSyncLogsTableTableManager get supabaseSyncLogs =>
      $$SupabaseSyncLogsTableTableManager(_db, _db.supabaseSyncLogs);
}
