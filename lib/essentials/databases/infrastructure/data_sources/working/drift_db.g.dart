// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_db.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  @override
  late final GeneratedColumn<int> firstSeen = GeneratedColumn<int>(
    'first_seen',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
    'last_seen',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMessagesMeta = const VerificationMeta(
    'totalMessages',
  );
  @override
  late final GeneratedColumn<int> totalMessages = GeneratedColumn<int>(
    'total_messages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _importSourceIdMeta = const VerificationMeta(
    'importSourceId',
  );
  @override
  late final GeneratedColumn<int> importSourceId = GeneratedColumn<int>(
    'import_source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importLastSyncedAtMeta =
      const VerificationMeta('importLastSyncedAt');
  @override
  late final GeneratedColumn<int> importLastSyncedAt = GeneratedColumn<int>(
    'import_last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    avatarPath,
    firstSeen,
    lastSeen,
    totalMessages,
    isGroup,
    importSourceId,
    importLastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    }
    if (data.containsKey('total_messages')) {
      context.handle(
        _totalMessagesMeta,
        totalMessages.isAcceptableOrUnknown(
          data['total_messages']!,
          _totalMessagesMeta,
        ),
      );
    }
    if (data.containsKey('is_group')) {
      context.handle(
        _isGroupMeta,
        isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta),
      );
    }
    if (data.containsKey('import_source_id')) {
      context.handle(
        _importSourceIdMeta,
        importSourceId.isAcceptableOrUnknown(
          data['import_source_id']!,
          _importSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('import_last_synced_at')) {
      context.handle(
        _importLastSyncedAtMeta,
        importLastSyncedAt.isAcceptableOrUnknown(
          data['import_last_synced_at']!,
          _importLastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen'],
      ),
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen'],
      ),
      totalMessages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_messages'],
      )!,
      isGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_group'],
      )!,
      importSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_source_id'],
      ),
      importLastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_last_synced_at'],
      ),
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final int id;
  final String displayName;
  final String? avatarPath;
  final int? firstSeen;
  final int? lastSeen;
  final int totalMessages;
  final bool isGroup;
  final int? importSourceId;
  final int? importLastSyncedAt;
  const Contact({
    required this.id,
    required this.displayName,
    this.avatarPath,
    this.firstSeen,
    this.lastSeen,
    required this.totalMessages,
    required this.isGroup,
    this.importSourceId,
    this.importLastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || firstSeen != null) {
      map['first_seen'] = Variable<int>(firstSeen);
    }
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<int>(lastSeen);
    }
    map['total_messages'] = Variable<int>(totalMessages);
    map['is_group'] = Variable<bool>(isGroup);
    if (!nullToAbsent || importSourceId != null) {
      map['import_source_id'] = Variable<int>(importSourceId);
    }
    if (!nullToAbsent || importLastSyncedAt != null) {
      map['import_last_synced_at'] = Variable<int>(importLastSyncedAt);
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      firstSeen: firstSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(firstSeen),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
      totalMessages: Value(totalMessages),
      isGroup: Value(isGroup),
      importSourceId: importSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(importSourceId),
      importLastSyncedAt: importLastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importLastSyncedAt),
    );
  }

  factory Contact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      firstSeen: serializer.fromJson<int?>(json['firstSeen']),
      lastSeen: serializer.fromJson<int?>(json['lastSeen']),
      totalMessages: serializer.fromJson<int>(json['totalMessages']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      importSourceId: serializer.fromJson<int?>(json['importSourceId']),
      importLastSyncedAt: serializer.fromJson<int?>(json['importLastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'firstSeen': serializer.toJson<int?>(firstSeen),
      'lastSeen': serializer.toJson<int?>(lastSeen),
      'totalMessages': serializer.toJson<int>(totalMessages),
      'isGroup': serializer.toJson<bool>(isGroup),
      'importSourceId': serializer.toJson<int?>(importSourceId),
      'importLastSyncedAt': serializer.toJson<int?>(importLastSyncedAt),
    };
  }

  Contact copyWith({
    int? id,
    String? displayName,
    Value<String?> avatarPath = const Value.absent(),
    Value<int?> firstSeen = const Value.absent(),
    Value<int?> lastSeen = const Value.absent(),
    int? totalMessages,
    bool? isGroup,
    Value<int?> importSourceId = const Value.absent(),
    Value<int?> importLastSyncedAt = const Value.absent(),
  }) => Contact(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    firstSeen: firstSeen.present ? firstSeen.value : this.firstSeen,
    lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
    totalMessages: totalMessages ?? this.totalMessages,
    isGroup: isGroup ?? this.isGroup,
    importSourceId: importSourceId.present
        ? importSourceId.value
        : this.importSourceId,
    importLastSyncedAt: importLastSyncedAt.present
        ? importLastSyncedAt.value
        : this.importLastSyncedAt,
  );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      totalMessages: data.totalMessages.present
          ? data.totalMessages.value
          : this.totalMessages,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      importSourceId: data.importSourceId.present
          ? data.importSourceId.value
          : this.importSourceId,
      importLastSyncedAt: data.importLastSyncedAt.present
          ? data.importLastSyncedAt.value
          : this.importLastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('totalMessages: $totalMessages, ')
          ..write('isGroup: $isGroup, ')
          ..write('importSourceId: $importSourceId, ')
          ..write('importLastSyncedAt: $importLastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    avatarPath,
    firstSeen,
    lastSeen,
    totalMessages,
    isGroup,
    importSourceId,
    importLastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.avatarPath == this.avatarPath &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen &&
          other.totalMessages == this.totalMessages &&
          other.isGroup == this.isGroup &&
          other.importSourceId == this.importSourceId &&
          other.importLastSyncedAt == this.importLastSyncedAt);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String?> avatarPath;
  final Value<int?> firstSeen;
  final Value<int?> lastSeen;
  final Value<int> totalMessages;
  final Value<bool> isGroup;
  final Value<int?> importSourceId;
  final Value<int?> importLastSyncedAt;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.totalMessages = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.importSourceId = const Value.absent(),
    this.importLastSyncedAt = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    this.avatarPath = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.totalMessages = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.importSourceId = const Value.absent(),
    this.importLastSyncedAt = const Value.absent(),
  }) : displayName = Value(displayName);
  static Insertable<Contact> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? avatarPath,
    Expression<int>? firstSeen,
    Expression<int>? lastSeen,
    Expression<int>? totalMessages,
    Expression<bool>? isGroup,
    Expression<int>? importSourceId,
    Expression<int>? importLastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (totalMessages != null) 'total_messages': totalMessages,
      if (isGroup != null) 'is_group': isGroup,
      if (importSourceId != null) 'import_source_id': importSourceId,
      if (importLastSyncedAt != null)
        'import_last_synced_at': importLastSyncedAt,
    });
  }

  ContactsCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<String?>? avatarPath,
    Value<int?>? firstSeen,
    Value<int?>? lastSeen,
    Value<int>? totalMessages,
    Value<bool>? isGroup,
    Value<int?>? importSourceId,
    Value<int?>? importLastSyncedAt,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      totalMessages: totalMessages ?? this.totalMessages,
      isGroup: isGroup ?? this.isGroup,
      importSourceId: importSourceId ?? this.importSourceId,
      importLastSyncedAt: importLastSyncedAt ?? this.importLastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<int>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (totalMessages.present) {
      map['total_messages'] = Variable<int>(totalMessages.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (importSourceId.present) {
      map['import_source_id'] = Variable<int>(importSourceId.value);
    }
    if (importLastSyncedAt.present) {
      map['import_last_synced_at'] = Variable<int>(importLastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('totalMessages: $totalMessages, ')
          ..write('isGroup: $isGroup, ')
          ..write('importSourceId: $importSourceId, ')
          ..write('importLastSyncedAt: $importLastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $HandlesTable extends Handles with TableInfo<$HandlesTable, Handle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HandlesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id)',
    ),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importSourceIdMeta = const VerificationMeta(
    'importSourceId',
  );
  @override
  late final GeneratedColumn<int> importSourceId = GeneratedColumn<int>(
    'import_source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    address,
    service,
    importSourceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'handles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Handle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceMeta);
    }
    if (data.containsKey('import_source_id')) {
      context.handle(
        _importSourceIdMeta,
        importSourceId.isAcceptableOrUnknown(
          data['import_source_id']!,
          _importSourceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {address, service},
  ];
  @override
  Handle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Handle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      importSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_source_id'],
      ),
    );
  }

  @override
  $HandlesTable createAlias(String alias) {
    return $HandlesTable(attachedDatabase, alias);
  }
}

class Handle extends DataClass implements Insertable<Handle> {
  final int id;
  final int? contactId;
  final String address;
  final String service;
  final int? importSourceId;
  const Handle({
    required this.id,
    this.contactId,
    required this.address,
    required this.service,
    this.importSourceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    map['address'] = Variable<String>(address);
    map['service'] = Variable<String>(service);
    if (!nullToAbsent || importSourceId != null) {
      map['import_source_id'] = Variable<int>(importSourceId);
    }
    return map;
  }

  HandlesCompanion toCompanion(bool nullToAbsent) {
    return HandlesCompanion(
      id: Value(id),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      address: Value(address),
      service: Value(service),
      importSourceId: importSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(importSourceId),
    );
  }

  factory Handle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Handle(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      address: serializer.fromJson<String>(json['address']),
      service: serializer.fromJson<String>(json['service']),
      importSourceId: serializer.fromJson<int?>(json['importSourceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int?>(contactId),
      'address': serializer.toJson<String>(address),
      'service': serializer.toJson<String>(service),
      'importSourceId': serializer.toJson<int?>(importSourceId),
    };
  }

  Handle copyWith({
    int? id,
    Value<int?> contactId = const Value.absent(),
    String? address,
    String? service,
    Value<int?> importSourceId = const Value.absent(),
  }) => Handle(
    id: id ?? this.id,
    contactId: contactId.present ? contactId.value : this.contactId,
    address: address ?? this.address,
    service: service ?? this.service,
    importSourceId: importSourceId.present
        ? importSourceId.value
        : this.importSourceId,
  );
  Handle copyWithCompanion(HandlesCompanion data) {
    return Handle(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      address: data.address.present ? data.address.value : this.address,
      service: data.service.present ? data.service.value : this.service,
      importSourceId: data.importSourceId.present
          ? data.importSourceId.value
          : this.importSourceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Handle(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('address: $address, ')
          ..write('service: $service, ')
          ..write('importSourceId: $importSourceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contactId, address, service, importSourceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Handle &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.address == this.address &&
          other.service == this.service &&
          other.importSourceId == this.importSourceId);
}

class HandlesCompanion extends UpdateCompanion<Handle> {
  final Value<int> id;
  final Value<int?> contactId;
  final Value<String> address;
  final Value<String> service;
  final Value<int?> importSourceId;
  const HandlesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.address = const Value.absent(),
    this.service = const Value.absent(),
    this.importSourceId = const Value.absent(),
  });
  HandlesCompanion.insert({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    required String address,
    required String service,
    this.importSourceId = const Value.absent(),
  }) : address = Value(address),
       service = Value(service);
  static Insertable<Handle> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<String>? address,
    Expression<String>? service,
    Expression<int>? importSourceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (address != null) 'address': address,
      if (service != null) 'service': service,
      if (importSourceId != null) 'import_source_id': importSourceId,
    });
  }

  HandlesCompanion copyWith({
    Value<int>? id,
    Value<int?>? contactId,
    Value<String>? address,
    Value<String>? service,
    Value<int?>? importSourceId,
  }) {
    return HandlesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      address: address ?? this.address,
      service: service ?? this.service,
      importSourceId: importSourceId ?? this.importSourceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (importSourceId.present) {
      map['import_source_id'] = Variable<int>(importSourceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HandlesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('address: $address, ')
          ..write('service: $service, ')
          ..write('importSourceId: $importSourceId')
          ..write(')'))
        .toString();
  }
}

class $ChatsTable extends Chats with TableInfo<$ChatsTable, Chat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id)',
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
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<int> startDate = GeneratedColumn<int>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<int> endDate = GeneratedColumn<int>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageCountMeta = const VerificationMeta(
    'messageCount',
  );
  @override
  late final GeneratedColumn<int> messageCount = GeneratedColumn<int>(
    'message_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _importSourceIdMeta = const VerificationMeta(
    'importSourceId',
  );
  @override
  late final GeneratedColumn<int> importSourceId = GeneratedColumn<int>(
    'import_source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importLastSyncedAtMeta =
      const VerificationMeta('importLastSyncedAt');
  @override
  late final GeneratedColumn<int> importLastSyncedAt = GeneratedColumn<int>(
    'import_last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    guid,
    displayName,
    startDate,
    endDate,
    messageCount,
    importSourceId,
    importLastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
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
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('message_count')) {
      context.handle(
        _messageCountMeta,
        messageCount.isAcceptableOrUnknown(
          data['message_count']!,
          _messageCountMeta,
        ),
      );
    }
    if (data.containsKey('import_source_id')) {
      context.handle(
        _importSourceIdMeta,
        importSourceId.isAcceptableOrUnknown(
          data['import_source_id']!,
          _importSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('import_last_synced_at')) {
      context.handle(
        _importLastSyncedAtMeta,
        importLastSyncedAt.isAcceptableOrUnknown(
          data['import_last_synced_at']!,
          _importLastSyncedAtMeta,
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
  Chat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      ),
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_date'],
      ),
      messageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_count'],
      )!,
      importSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_source_id'],
      ),
      importLastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_last_synced_at'],
      ),
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class Chat extends DataClass implements Insertable<Chat> {
  final int id;
  final int? contactId;
  final String guid;
  final String? displayName;
  final int? startDate;
  final int? endDate;
  final int messageCount;
  final int? importSourceId;
  final int? importLastSyncedAt;
  const Chat({
    required this.id,
    this.contactId,
    required this.guid,
    this.displayName,
    this.startDate,
    this.endDate,
    required this.messageCount,
    this.importSourceId,
    this.importLastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    map['guid'] = Variable<String>(guid);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<int>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<int>(endDate);
    }
    map['message_count'] = Variable<int>(messageCount);
    if (!nullToAbsent || importSourceId != null) {
      map['import_source_id'] = Variable<int>(importSourceId);
    }
    if (!nullToAbsent || importLastSyncedAt != null) {
      map['import_last_synced_at'] = Variable<int>(importLastSyncedAt);
    }
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      guid: Value(guid),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      messageCount: Value(messageCount),
      importSourceId: importSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(importSourceId),
      importLastSyncedAt: importLastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importLastSyncedAt),
    );
  }

  factory Chat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chat(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      guid: serializer.fromJson<String>(json['guid']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      startDate: serializer.fromJson<int?>(json['startDate']),
      endDate: serializer.fromJson<int?>(json['endDate']),
      messageCount: serializer.fromJson<int>(json['messageCount']),
      importSourceId: serializer.fromJson<int?>(json['importSourceId']),
      importLastSyncedAt: serializer.fromJson<int?>(json['importLastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int?>(contactId),
      'guid': serializer.toJson<String>(guid),
      'displayName': serializer.toJson<String?>(displayName),
      'startDate': serializer.toJson<int?>(startDate),
      'endDate': serializer.toJson<int?>(endDate),
      'messageCount': serializer.toJson<int>(messageCount),
      'importSourceId': serializer.toJson<int?>(importSourceId),
      'importLastSyncedAt': serializer.toJson<int?>(importLastSyncedAt),
    };
  }

  Chat copyWith({
    int? id,
    Value<int?> contactId = const Value.absent(),
    String? guid,
    Value<String?> displayName = const Value.absent(),
    Value<int?> startDate = const Value.absent(),
    Value<int?> endDate = const Value.absent(),
    int? messageCount,
    Value<int?> importSourceId = const Value.absent(),
    Value<int?> importLastSyncedAt = const Value.absent(),
  }) => Chat(
    id: id ?? this.id,
    contactId: contactId.present ? contactId.value : this.contactId,
    guid: guid ?? this.guid,
    displayName: displayName.present ? displayName.value : this.displayName,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    messageCount: messageCount ?? this.messageCount,
    importSourceId: importSourceId.present
        ? importSourceId.value
        : this.importSourceId,
    importLastSyncedAt: importLastSyncedAt.present
        ? importLastSyncedAt.value
        : this.importLastSyncedAt,
  );
  Chat copyWithCompanion(ChatsCompanion data) {
    return Chat(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      guid: data.guid.present ? data.guid.value : this.guid,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      messageCount: data.messageCount.present
          ? data.messageCount.value
          : this.messageCount,
      importSourceId: data.importSourceId.present
          ? data.importSourceId.value
          : this.importSourceId,
      importLastSyncedAt: data.importLastSyncedAt.present
          ? data.importLastSyncedAt.value
          : this.importLastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chat(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('guid: $guid, ')
          ..write('displayName: $displayName, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('messageCount: $messageCount, ')
          ..write('importSourceId: $importSourceId, ')
          ..write('importLastSyncedAt: $importLastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contactId,
    guid,
    displayName,
    startDate,
    endDate,
    messageCount,
    importSourceId,
    importLastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chat &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.guid == this.guid &&
          other.displayName == this.displayName &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.messageCount == this.messageCount &&
          other.importSourceId == this.importSourceId &&
          other.importLastSyncedAt == this.importLastSyncedAt);
}

class ChatsCompanion extends UpdateCompanion<Chat> {
  final Value<int> id;
  final Value<int?> contactId;
  final Value<String> guid;
  final Value<String?> displayName;
  final Value<int?> startDate;
  final Value<int?> endDate;
  final Value<int> messageCount;
  final Value<int?> importSourceId;
  final Value<int?> importLastSyncedAt;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.guid = const Value.absent(),
    this.displayName = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.importSourceId = const Value.absent(),
    this.importLastSyncedAt = const Value.absent(),
  });
  ChatsCompanion.insert({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    required String guid,
    this.displayName = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.importSourceId = const Value.absent(),
    this.importLastSyncedAt = const Value.absent(),
  }) : guid = Value(guid);
  static Insertable<Chat> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<String>? guid,
    Expression<String>? displayName,
    Expression<int>? startDate,
    Expression<int>? endDate,
    Expression<int>? messageCount,
    Expression<int>? importSourceId,
    Expression<int>? importLastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (guid != null) 'guid': guid,
      if (displayName != null) 'display_name': displayName,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (messageCount != null) 'message_count': messageCount,
      if (importSourceId != null) 'import_source_id': importSourceId,
      if (importLastSyncedAt != null)
        'import_last_synced_at': importLastSyncedAt,
    });
  }

  ChatsCompanion copyWith({
    Value<int>? id,
    Value<int?>? contactId,
    Value<String>? guid,
    Value<String?>? displayName,
    Value<int?>? startDate,
    Value<int?>? endDate,
    Value<int>? messageCount,
    Value<int?>? importSourceId,
    Value<int?>? importLastSyncedAt,
  }) {
    return ChatsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      guid: guid ?? this.guid,
      displayName: displayName ?? this.displayName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      messageCount: messageCount ?? this.messageCount,
      importSourceId: importSourceId ?? this.importSourceId,
      importLastSyncedAt: importLastSyncedAt ?? this.importLastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<int>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<int>(endDate.value);
    }
    if (messageCount.present) {
      map['message_count'] = Variable<int>(messageCount.value);
    }
    if (importSourceId.present) {
      map['import_source_id'] = Variable<int>(importSourceId.value);
    }
    if (importLastSyncedAt.present) {
      map['import_last_synced_at'] = Variable<int>(importLastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('guid: $guid, ')
          ..write('displayName: $displayName, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('messageCount: $messageCount, ')
          ..write('importSourceId: $importSourceId, ')
          ..write('importLastSyncedAt: $importLastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $ChatParticipantsTable extends ChatParticipants
    with TableInfo<$ChatParticipantsTable, ChatParticipant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chats (id)',
    ),
  );
  static const VerificationMeta _handleIdMeta = const VerificationMeta(
    'handleId',
  );
  @override
  late final GeneratedColumn<int> handleId = GeneratedColumn<int>(
    'handle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES handles (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [chatId, handleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatParticipant> instance, {
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
    if (data.containsKey('handle_id')) {
      context.handle(
        _handleIdMeta,
        handleId.isAcceptableOrUnknown(data['handle_id']!, _handleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_handleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId, handleId};
  @override
  ChatParticipant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatParticipant(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      handleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}handle_id'],
      )!,
    );
  }

  @override
  $ChatParticipantsTable createAlias(String alias) {
    return $ChatParticipantsTable(attachedDatabase, alias);
  }
}

class ChatParticipant extends DataClass implements Insertable<ChatParticipant> {
  final int chatId;
  final int handleId;
  const ChatParticipant({required this.chatId, required this.handleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    map['handle_id'] = Variable<int>(handleId);
    return map;
  }

  ChatParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ChatParticipantsCompanion(
      chatId: Value(chatId),
      handleId: Value(handleId),
    );
  }

  factory ChatParticipant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatParticipant(
      chatId: serializer.fromJson<int>(json['chatId']),
      handleId: serializer.fromJson<int>(json['handleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'handleId': serializer.toJson<int>(handleId),
    };
  }

  ChatParticipant copyWith({int? chatId, int? handleId}) => ChatParticipant(
    chatId: chatId ?? this.chatId,
    handleId: handleId ?? this.handleId,
  );
  ChatParticipant copyWithCompanion(ChatParticipantsCompanion data) {
    return ChatParticipant(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      handleId: data.handleId.present ? data.handleId.value : this.handleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatParticipant(')
          ..write('chatId: $chatId, ')
          ..write('handleId: $handleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, handleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatParticipant &&
          other.chatId == this.chatId &&
          other.handleId == this.handleId);
}

class ChatParticipantsCompanion extends UpdateCompanion<ChatParticipant> {
  final Value<int> chatId;
  final Value<int> handleId;
  final Value<int> rowid;
  const ChatParticipantsCompanion({
    this.chatId = const Value.absent(),
    this.handleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatParticipantsCompanion.insert({
    required int chatId,
    required int handleId,
    this.rowid = const Value.absent(),
  }) : chatId = Value(chatId),
       handleId = Value(handleId);
  static Insertable<ChatParticipant> custom({
    Expression<int>? chatId,
    Expression<int>? handleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (handleId != null) 'handle_id': handleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatParticipantsCompanion copyWith({
    Value<int>? chatId,
    Value<int>? handleId,
    Value<int>? rowid,
  }) {
    return ChatParticipantsCompanion(
      chatId: chatId ?? this.chatId,
      handleId: handleId ?? this.handleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (handleId.present) {
      map['handle_id'] = Variable<int>(handleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatParticipantsCompanion(')
          ..write('chatId: $chatId, ')
          ..write('handleId: $handleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chats (id)',
    ),
  );
  static const VerificationMeta _senderHandleIdMeta = const VerificationMeta(
    'senderHandleId',
  );
  @override
  late final GeneratedColumn<int> senderHandleId = GeneratedColumn<int>(
    'sender_handle_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES handles (id)',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _quotedMessageIdMeta = const VerificationMeta(
    'quotedMessageId',
  );
  @override
  late final GeneratedColumn<int> quotedMessageId = GeneratedColumn<int>(
    'quoted_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id)',
    ),
  );
  static const VerificationMeta _importSourceIdMeta = const VerificationMeta(
    'importSourceId',
  );
  @override
  late final GeneratedColumn<int> importSourceId = GeneratedColumn<int>(
    'import_source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importLastSyncedAtMeta =
      const VerificationMeta('importLastSyncedAt');
  @override
  late final GeneratedColumn<int> importLastSyncedAt = GeneratedColumn<int>(
    'import_last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatId,
    senderHandleId,
    timestamp,
    content,
    isFromMe,
    hasAttachments,
    quotedMessageId,
    importSourceId,
    importLastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_handle_id')) {
      context.handle(
        _senderHandleIdMeta,
        senderHandleId.isAcceptableOrUnknown(
          data['sender_handle_id']!,
          _senderHandleIdMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('is_from_me')) {
      context.handle(
        _isFromMeMeta,
        isFromMe.isAcceptableOrUnknown(data['is_from_me']!, _isFromMeMeta),
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
    if (data.containsKey('quoted_message_id')) {
      context.handle(
        _quotedMessageIdMeta,
        quotedMessageId.isAcceptableOrUnknown(
          data['quoted_message_id']!,
          _quotedMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('import_source_id')) {
      context.handle(
        _importSourceIdMeta,
        importSourceId.isAcceptableOrUnknown(
          data['import_source_id']!,
          _importSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('import_last_synced_at')) {
      context.handle(
        _importLastSyncedAtMeta,
        importLastSyncedAt.isAcceptableOrUnknown(
          data['import_last_synced_at']!,
          _importLastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      senderHandleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sender_handle_id'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      isFromMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_from_me'],
      )!,
      hasAttachments: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_attachments'],
      )!,
      quotedMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quoted_message_id'],
      ),
      importSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_source_id'],
      ),
      importLastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_last_synced_at'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final int chatId;
  final int? senderHandleId;
  final int timestamp;
  final String? content;
  final bool isFromMe;
  final bool hasAttachments;
  final int? quotedMessageId;
  final int? importSourceId;
  final int? importLastSyncedAt;
  const Message({
    required this.id,
    required this.chatId,
    this.senderHandleId,
    required this.timestamp,
    this.content,
    required this.isFromMe,
    required this.hasAttachments,
    this.quotedMessageId,
    this.importSourceId,
    this.importLastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || senderHandleId != null) {
      map['sender_handle_id'] = Variable<int>(senderHandleId);
    }
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['is_from_me'] = Variable<bool>(isFromMe);
    map['has_attachments'] = Variable<bool>(hasAttachments);
    if (!nullToAbsent || quotedMessageId != null) {
      map['quoted_message_id'] = Variable<int>(quotedMessageId);
    }
    if (!nullToAbsent || importSourceId != null) {
      map['import_source_id'] = Variable<int>(importSourceId);
    }
    if (!nullToAbsent || importLastSyncedAt != null) {
      map['import_last_synced_at'] = Variable<int>(importLastSyncedAt);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      senderHandleId: senderHandleId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderHandleId),
      timestamp: Value(timestamp),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      isFromMe: Value(isFromMe),
      hasAttachments: Value(hasAttachments),
      quotedMessageId: quotedMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(quotedMessageId),
      importSourceId: importSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(importSourceId),
      importLastSyncedAt: importLastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importLastSyncedAt),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      chatId: serializer.fromJson<int>(json['chatId']),
      senderHandleId: serializer.fromJson<int?>(json['senderHandleId']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      content: serializer.fromJson<String?>(json['content']),
      isFromMe: serializer.fromJson<bool>(json['isFromMe']),
      hasAttachments: serializer.fromJson<bool>(json['hasAttachments']),
      quotedMessageId: serializer.fromJson<int?>(json['quotedMessageId']),
      importSourceId: serializer.fromJson<int?>(json['importSourceId']),
      importLastSyncedAt: serializer.fromJson<int?>(json['importLastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chatId': serializer.toJson<int>(chatId),
      'senderHandleId': serializer.toJson<int?>(senderHandleId),
      'timestamp': serializer.toJson<int>(timestamp),
      'content': serializer.toJson<String?>(content),
      'isFromMe': serializer.toJson<bool>(isFromMe),
      'hasAttachments': serializer.toJson<bool>(hasAttachments),
      'quotedMessageId': serializer.toJson<int?>(quotedMessageId),
      'importSourceId': serializer.toJson<int?>(importSourceId),
      'importLastSyncedAt': serializer.toJson<int?>(importLastSyncedAt),
    };
  }

  Message copyWith({
    int? id,
    int? chatId,
    Value<int?> senderHandleId = const Value.absent(),
    int? timestamp,
    Value<String?> content = const Value.absent(),
    bool? isFromMe,
    bool? hasAttachments,
    Value<int?> quotedMessageId = const Value.absent(),
    Value<int?> importSourceId = const Value.absent(),
    Value<int?> importLastSyncedAt = const Value.absent(),
  }) => Message(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    senderHandleId: senderHandleId.present
        ? senderHandleId.value
        : this.senderHandleId,
    timestamp: timestamp ?? this.timestamp,
    content: content.present ? content.value : this.content,
    isFromMe: isFromMe ?? this.isFromMe,
    hasAttachments: hasAttachments ?? this.hasAttachments,
    quotedMessageId: quotedMessageId.present
        ? quotedMessageId.value
        : this.quotedMessageId,
    importSourceId: importSourceId.present
        ? importSourceId.value
        : this.importSourceId,
    importLastSyncedAt: importLastSyncedAt.present
        ? importLastSyncedAt.value
        : this.importLastSyncedAt,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderHandleId: data.senderHandleId.present
          ? data.senderHandleId.value
          : this.senderHandleId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      content: data.content.present ? data.content.value : this.content,
      isFromMe: data.isFromMe.present ? data.isFromMe.value : this.isFromMe,
      hasAttachments: data.hasAttachments.present
          ? data.hasAttachments.value
          : this.hasAttachments,
      quotedMessageId: data.quotedMessageId.present
          ? data.quotedMessageId.value
          : this.quotedMessageId,
      importSourceId: data.importSourceId.present
          ? data.importSourceId.value
          : this.importSourceId,
      importLastSyncedAt: data.importLastSyncedAt.present
          ? data.importLastSyncedAt.value
          : this.importLastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderHandleId: $senderHandleId, ')
          ..write('timestamp: $timestamp, ')
          ..write('content: $content, ')
          ..write('isFromMe: $isFromMe, ')
          ..write('hasAttachments: $hasAttachments, ')
          ..write('quotedMessageId: $quotedMessageId, ')
          ..write('importSourceId: $importSourceId, ')
          ..write('importLastSyncedAt: $importLastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatId,
    senderHandleId,
    timestamp,
    content,
    isFromMe,
    hasAttachments,
    quotedMessageId,
    importSourceId,
    importLastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.senderHandleId == this.senderHandleId &&
          other.timestamp == this.timestamp &&
          other.content == this.content &&
          other.isFromMe == this.isFromMe &&
          other.hasAttachments == this.hasAttachments &&
          other.quotedMessageId == this.quotedMessageId &&
          other.importSourceId == this.importSourceId &&
          other.importLastSyncedAt == this.importLastSyncedAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<int> chatId;
  final Value<int?> senderHandleId;
  final Value<int> timestamp;
  final Value<String?> content;
  final Value<bool> isFromMe;
  final Value<bool> hasAttachments;
  final Value<int?> quotedMessageId;
  final Value<int?> importSourceId;
  final Value<int?> importLastSyncedAt;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderHandleId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.content = const Value.absent(),
    this.isFromMe = const Value.absent(),
    this.hasAttachments = const Value.absent(),
    this.quotedMessageId = const Value.absent(),
    this.importSourceId = const Value.absent(),
    this.importLastSyncedAt = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int chatId,
    this.senderHandleId = const Value.absent(),
    required int timestamp,
    this.content = const Value.absent(),
    this.isFromMe = const Value.absent(),
    this.hasAttachments = const Value.absent(),
    this.quotedMessageId = const Value.absent(),
    this.importSourceId = const Value.absent(),
    this.importLastSyncedAt = const Value.absent(),
  }) : chatId = Value(chatId),
       timestamp = Value(timestamp);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<int>? chatId,
    Expression<int>? senderHandleId,
    Expression<int>? timestamp,
    Expression<String>? content,
    Expression<bool>? isFromMe,
    Expression<bool>? hasAttachments,
    Expression<int>? quotedMessageId,
    Expression<int>? importSourceId,
    Expression<int>? importLastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (senderHandleId != null) 'sender_handle_id': senderHandleId,
      if (timestamp != null) 'timestamp': timestamp,
      if (content != null) 'content': content,
      if (isFromMe != null) 'is_from_me': isFromMe,
      if (hasAttachments != null) 'has_attachments': hasAttachments,
      if (quotedMessageId != null) 'quoted_message_id': quotedMessageId,
      if (importSourceId != null) 'import_source_id': importSourceId,
      if (importLastSyncedAt != null)
        'import_last_synced_at': importLastSyncedAt,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? chatId,
    Value<int?>? senderHandleId,
    Value<int>? timestamp,
    Value<String?>? content,
    Value<bool>? isFromMe,
    Value<bool>? hasAttachments,
    Value<int?>? quotedMessageId,
    Value<int?>? importSourceId,
    Value<int?>? importLastSyncedAt,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderHandleId: senderHandleId ?? this.senderHandleId,
      timestamp: timestamp ?? this.timestamp,
      content: content ?? this.content,
      isFromMe: isFromMe ?? this.isFromMe,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      quotedMessageId: quotedMessageId ?? this.quotedMessageId,
      importSourceId: importSourceId ?? this.importSourceId,
      importLastSyncedAt: importLastSyncedAt ?? this.importLastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (senderHandleId.present) {
      map['sender_handle_id'] = Variable<int>(senderHandleId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isFromMe.present) {
      map['is_from_me'] = Variable<bool>(isFromMe.value);
    }
    if (hasAttachments.present) {
      map['has_attachments'] = Variable<bool>(hasAttachments.value);
    }
    if (quotedMessageId.present) {
      map['quoted_message_id'] = Variable<int>(quotedMessageId.value);
    }
    if (importSourceId.present) {
      map['import_source_id'] = Variable<int>(importSourceId.value);
    }
    if (importLastSyncedAt.present) {
      map['import_last_synced_at'] = Variable<int>(importLastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('senderHandleId: $senderHandleId, ')
          ..write('timestamp: $timestamp, ')
          ..write('content: $content, ')
          ..write('isFromMe: $isFromMe, ')
          ..write('hasAttachments: $hasAttachments, ')
          ..write('quotedMessageId: $quotedMessageId, ')
          ..write('importSourceId: $importSourceId, ')
          ..write('importLastSyncedAt: $importLastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id)',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importSourceIdMeta = const VerificationMeta(
    'importSourceId',
  );
  @override
  late final GeneratedColumn<int> importSourceId = GeneratedColumn<int>(
    'import_source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importLastSyncedAtMeta =
      const VerificationMeta('importLastSyncedAt');
  @override
  late final GeneratedColumn<int> importLastSyncedAt = GeneratedColumn<int>(
    'import_last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    filePath,
    mimeType,
    fileSize,
    thumbnailPath,
    importSourceId,
    importLastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('import_source_id')) {
      context.handle(
        _importSourceIdMeta,
        importSourceId.isAcceptableOrUnknown(
          data['import_source_id']!,
          _importSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('import_last_synced_at')) {
      context.handle(
        _importLastSyncedAtMeta,
        importLastSyncedAt.isAcceptableOrUnknown(
          data['import_last_synced_at']!,
          _importLastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      importSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_source_id'],
      ),
      importLastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_last_synced_at'],
      ),
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final int id;
  final int messageId;
  final String filePath;
  final String? mimeType;
  final int? fileSize;
  final String? thumbnailPath;
  final int? importSourceId;
  final int? importLastSyncedAt;
  const Attachment({
    required this.id,
    required this.messageId,
    required this.filePath,
    this.mimeType,
    this.fileSize,
    this.thumbnailPath,
    this.importSourceId,
    this.importLastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<int>(messageId);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || importSourceId != null) {
      map['import_source_id'] = Variable<int>(importSourceId);
    }
    if (!nullToAbsent || importLastSyncedAt != null) {
      map['import_last_synced_at'] = Variable<int>(importLastSyncedAt);
    }
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      messageId: Value(messageId),
      filePath: Value(filePath),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      importSourceId: importSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(importSourceId),
      importLastSyncedAt: importLastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importLastSyncedAt),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<int>(json['messageId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      importSourceId: serializer.fromJson<int?>(json['importSourceId']),
      importLastSyncedAt: serializer.fromJson<int?>(json['importLastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<int>(messageId),
      'filePath': serializer.toJson<String>(filePath),
      'mimeType': serializer.toJson<String?>(mimeType),
      'fileSize': serializer.toJson<int?>(fileSize),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'importSourceId': serializer.toJson<int?>(importSourceId),
      'importLastSyncedAt': serializer.toJson<int?>(importLastSyncedAt),
    };
  }

  Attachment copyWith({
    int? id,
    int? messageId,
    String? filePath,
    Value<String?> mimeType = const Value.absent(),
    Value<int?> fileSize = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    Value<int?> importSourceId = const Value.absent(),
    Value<int?> importLastSyncedAt = const Value.absent(),
  }) => Attachment(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    filePath: filePath ?? this.filePath,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    importSourceId: importSourceId.present
        ? importSourceId.value
        : this.importSourceId,
    importLastSyncedAt: importLastSyncedAt.present
        ? importLastSyncedAt.value
        : this.importLastSyncedAt,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      importSourceId: data.importSourceId.present
          ? data.importSourceId.value
          : this.importSourceId,
      importLastSyncedAt: data.importLastSyncedAt.present
          ? data.importLastSyncedAt.value
          : this.importLastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('filePath: $filePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('importSourceId: $importSourceId, ')
          ..write('importLastSyncedAt: $importLastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    filePath,
    mimeType,
    fileSize,
    thumbnailPath,
    importSourceId,
    importLastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.filePath == this.filePath &&
          other.mimeType == this.mimeType &&
          other.fileSize == this.fileSize &&
          other.thumbnailPath == this.thumbnailPath &&
          other.importSourceId == this.importSourceId &&
          other.importLastSyncedAt == this.importLastSyncedAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<int> id;
  final Value<int> messageId;
  final Value<String> filePath;
  final Value<String?> mimeType;
  final Value<int?> fileSize;
  final Value<String?> thumbnailPath;
  final Value<int?> importSourceId;
  final Value<int?> importLastSyncedAt;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.importSourceId = const Value.absent(),
    this.importLastSyncedAt = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int messageId,
    required String filePath,
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.importSourceId = const Value.absent(),
    this.importLastSyncedAt = const Value.absent(),
  }) : messageId = Value(messageId),
       filePath = Value(filePath);
  static Insertable<Attachment> custom({
    Expression<int>? id,
    Expression<int>? messageId,
    Expression<String>? filePath,
    Expression<String>? mimeType,
    Expression<int>? fileSize,
    Expression<String>? thumbnailPath,
    Expression<int>? importSourceId,
    Expression<int>? importLastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (filePath != null) 'file_path': filePath,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSize != null) 'file_size': fileSize,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (importSourceId != null) 'import_source_id': importSourceId,
      if (importLastSyncedAt != null)
        'import_last_synced_at': importLastSyncedAt,
    });
  }

  AttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? messageId,
    Value<String>? filePath,
    Value<String?>? mimeType,
    Value<int?>? fileSize,
    Value<String?>? thumbnailPath,
    Value<int?>? importSourceId,
    Value<int?>? importLastSyncedAt,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      filePath: filePath ?? this.filePath,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      importSourceId: importSourceId ?? this.importSourceId,
      importLastSyncedAt: importLastSyncedAt ?? this.importLastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (importSourceId.present) {
      map['import_source_id'] = Variable<int>(importSourceId.value);
    }
    if (importLastSyncedAt.present) {
      map['import_last_synced_at'] = Variable<int>(importLastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('filePath: $filePath, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('importSourceId: $importSourceId, ')
          ..write('importLastSyncedAt: $importLastSyncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$DriftDb extends GeneratedDatabase {
  _$DriftDb(QueryExecutor e) : super(e);
  $DriftDbManager get managers => $DriftDbManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $HandlesTable handles = $HandlesTable(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $ChatParticipantsTable chatParticipants = $ChatParticipantsTable(
    this,
  );
  late final $MessagesTable messages = $MessagesTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contacts,
    handles,
    chats,
    chatParticipants,
    messages,
    attachments,
  ];
}

typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      required String displayName,
      Value<String?> avatarPath,
      Value<int?> firstSeen,
      Value<int?> lastSeen,
      Value<int> totalMessages,
      Value<bool> isGroup,
      Value<int?> importSourceId,
      Value<int?> importLastSyncedAt,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<String?> avatarPath,
      Value<int?> firstSeen,
      Value<int?> lastSeen,
      Value<int> totalMessages,
      Value<bool> isGroup,
      Value<int?> importSourceId,
      Value<int?> importLastSyncedAt,
    });

final class $$ContactsTableReferences
    extends BaseReferences<_$DriftDb, $ContactsTable, Contact> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HandlesTable, List<Handle>> _handlesRefsTable(
    _$DriftDb db,
  ) => MultiTypedResultKey.fromTable(
    db.handles,
    aliasName: $_aliasNameGenerator(db.contacts.id, db.handles.contactId),
  );

  $$HandlesTableProcessedTableManager get handlesRefs {
    final manager = $$HandlesTableTableManager(
      $_db,
      $_db.handles,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_handlesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatsTable, List<Chat>> _chatsRefsTable(
    _$DriftDb db,
  ) => MultiTypedResultKey.fromTable(
    db.chats,
    aliasName: $_aliasNameGenerator(db.contacts.id, db.chats.contactId),
  );

  $$ChatsTableProcessedTableManager get chatsRefs {
    final manager = $$ChatsTableTableManager(
      $_db,
      $_db.chats,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContactsTableFilterComposer
    extends Composer<_$DriftDb, $ContactsTable> {
  $$ContactsTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMessages => $composableBuilder(
    column: $table.totalMessages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> handlesRefs(
    Expression<bool> Function($$HandlesTableFilterComposer f) f,
  ) {
    final $$HandlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.handles,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesTableFilterComposer(
            $db: $db,
            $table: $db.handles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatsRefs(
    Expression<bool> Function($$ChatsTableFilterComposer f) f,
  ) {
    final $$ChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableFilterComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactsTableOrderingComposer
    extends Composer<_$DriftDb, $ContactsTable> {
  $$ContactsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMessages => $composableBuilder(
    column: $table.totalMessages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGroup => $composableBuilder(
    column: $table.isGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$DriftDb, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<int> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<int> get totalMessages => $composableBuilder(
    column: $table.totalMessages,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => column,
  );

  Expression<T> handlesRefs<T extends Object>(
    Expression<T> Function($$HandlesTableAnnotationComposer a) f,
  ) {
    final $$HandlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.handles,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesTableAnnotationComposer(
            $db: $db,
            $table: $db.handles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatsRefs<T extends Object>(
    Expression<T> Function($$ChatsTableAnnotationComposer a) f,
  ) {
    final $$ChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$DriftDb,
          $ContactsTable,
          Contact,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (Contact, $$ContactsTableReferences),
          Contact,
          PrefetchHooks Function({bool handlesRefs, bool chatsRefs})
        > {
  $$ContactsTableTableManager(_$DriftDb db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<int?> firstSeen = const Value.absent(),
                Value<int?> lastSeen = const Value.absent(),
                Value<int> totalMessages = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<int?> importSourceId = const Value.absent(),
                Value<int?> importLastSyncedAt = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                displayName: displayName,
                avatarPath: avatarPath,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                totalMessages: totalMessages,
                isGroup: isGroup,
                importSourceId: importSourceId,
                importLastSyncedAt: importLastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                Value<String?> avatarPath = const Value.absent(),
                Value<int?> firstSeen = const Value.absent(),
                Value<int?> lastSeen = const Value.absent(),
                Value<int> totalMessages = const Value.absent(),
                Value<bool> isGroup = const Value.absent(),
                Value<int?> importSourceId = const Value.absent(),
                Value<int?> importLastSyncedAt = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                displayName: displayName,
                avatarPath: avatarPath,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                totalMessages: totalMessages,
                isGroup: isGroup,
                importSourceId: importSourceId,
                importLastSyncedAt: importLastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({handlesRefs = false, chatsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (handlesRefs) db.handles,
                if (chatsRefs) db.chats,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (handlesRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable, Handle>(
                      currentTable: table,
                      referencedTable: $$ContactsTableReferences
                          ._handlesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ContactsTableReferences(db, table, p0).handlesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.contactId == item.id),
                      typedResults: items,
                    ),
                  if (chatsRefs)
                    await $_getPrefetchedData<Contact, $ContactsTable, Chat>(
                      currentTable: table,
                      referencedTable: $$ContactsTableReferences
                          ._chatsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ContactsTableReferences(db, table, p0).chatsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.contactId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDb,
      $ContactsTable,
      Contact,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (Contact, $$ContactsTableReferences),
      Contact,
      PrefetchHooks Function({bool handlesRefs, bool chatsRefs})
    >;
typedef $$HandlesTableCreateCompanionBuilder =
    HandlesCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      required String address,
      required String service,
      Value<int?> importSourceId,
    });
typedef $$HandlesTableUpdateCompanionBuilder =
    HandlesCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      Value<String> address,
      Value<String> service,
      Value<int?> importSourceId,
    });

final class $$HandlesTableReferences
    extends BaseReferences<_$DriftDb, $HandlesTable, Handle> {
  $$HandlesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactIdTable(_$DriftDb db) => db.contacts
      .createAlias($_aliasNameGenerator(db.handles.contactId, db.contacts.id));

  $$ContactsTableProcessedTableManager? get contactId {
    final $_column = $_itemColumn<int>('contact_id');
    if ($_column == null) return null;
    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatParticipantsTable, List<ChatParticipant>>
  _chatParticipantsRefsTable(_$DriftDb db) => MultiTypedResultKey.fromTable(
    db.chatParticipants,
    aliasName: $_aliasNameGenerator(
      db.handles.id,
      db.chatParticipants.handleId,
    ),
  );

  $$ChatParticipantsTableProcessedTableManager get chatParticipantsRefs {
    final manager = $$ChatParticipantsTableTableManager(
      $_db,
      $_db.chatParticipants,
    ).filter((f) => f.handleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chatParticipantsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$DriftDb db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(db.handles.id, db.messages.senderHandleId),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.senderHandleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HandlesTableFilterComposer extends Composer<_$DriftDb, $HandlesTable> {
  $$HandlesTableFilterComposer({
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

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatParticipantsRefs(
    Expression<bool> Function($$ChatParticipantsTableFilterComposer f) f,
  ) {
    final $$ChatParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatParticipants,
      getReferencedColumn: (t) => t.handleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.chatParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.senderHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HandlesTableOrderingComposer
    extends Composer<_$DriftDb, $HandlesTable> {
  $$HandlesTableOrderingComposer({
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

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HandlesTableAnnotationComposer
    extends Composer<_$DriftDb, $HandlesTable> {
  $$HandlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => column,
  );

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatParticipantsRefs<T extends Object>(
    Expression<T> Function($$ChatParticipantsTableAnnotationComposer a) f,
  ) {
    final $$ChatParticipantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatParticipants,
      getReferencedColumn: (t) => t.handleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatParticipantsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.senderHandleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HandlesTableTableManager
    extends
        RootTableManager<
          _$DriftDb,
          $HandlesTable,
          Handle,
          $$HandlesTableFilterComposer,
          $$HandlesTableOrderingComposer,
          $$HandlesTableAnnotationComposer,
          $$HandlesTableCreateCompanionBuilder,
          $$HandlesTableUpdateCompanionBuilder,
          (Handle, $$HandlesTableReferences),
          Handle,
          PrefetchHooks Function({
            bool contactId,
            bool chatParticipantsRefs,
            bool messagesRefs,
          })
        > {
  $$HandlesTableTableManager(_$DriftDb db, $HandlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HandlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HandlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HandlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<int?> importSourceId = const Value.absent(),
              }) => HandlesCompanion(
                id: id,
                contactId: contactId,
                address: address,
                service: service,
                importSourceId: importSourceId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                required String address,
                required String service,
                Value<int?> importSourceId = const Value.absent(),
              }) => HandlesCompanion.insert(
                id: id,
                contactId: contactId,
                address: address,
                service: service,
                importSourceId: importSourceId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HandlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                contactId = false,
                chatParticipantsRefs = false,
                messagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatParticipantsRefs) db.chatParticipants,
                    if (messagesRefs) db.messages,
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
                        if (contactId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.contactId,
                                    referencedTable: $$HandlesTableReferences
                                        ._contactIdTable(db),
                                    referencedColumn: $$HandlesTableReferences
                                        ._contactIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatParticipantsRefs)
                        await $_getPrefetchedData<
                          Handle,
                          $HandlesTable,
                          ChatParticipant
                        >(
                          currentTable: table,
                          referencedTable: $$HandlesTableReferences
                              ._chatParticipantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HandlesTableReferences(
                                db,
                                table,
                                p0,
                              ).chatParticipantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.handleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (messagesRefs)
                        await $_getPrefetchedData<
                          Handle,
                          $HandlesTable,
                          Message
                        >(
                          currentTable: table,
                          referencedTable: $$HandlesTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HandlesTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.senderHandleId == item.id,
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

typedef $$HandlesTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDb,
      $HandlesTable,
      Handle,
      $$HandlesTableFilterComposer,
      $$HandlesTableOrderingComposer,
      $$HandlesTableAnnotationComposer,
      $$HandlesTableCreateCompanionBuilder,
      $$HandlesTableUpdateCompanionBuilder,
      (Handle, $$HandlesTableReferences),
      Handle,
      PrefetchHooks Function({
        bool contactId,
        bool chatParticipantsRefs,
        bool messagesRefs,
      })
    >;
typedef $$ChatsTableCreateCompanionBuilder =
    ChatsCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      required String guid,
      Value<String?> displayName,
      Value<int?> startDate,
      Value<int?> endDate,
      Value<int> messageCount,
      Value<int?> importSourceId,
      Value<int?> importLastSyncedAt,
    });
typedef $$ChatsTableUpdateCompanionBuilder =
    ChatsCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      Value<String> guid,
      Value<String?> displayName,
      Value<int?> startDate,
      Value<int?> endDate,
      Value<int> messageCount,
      Value<int?> importSourceId,
      Value<int?> importLastSyncedAt,
    });

final class $$ChatsTableReferences
    extends BaseReferences<_$DriftDb, $ChatsTable, Chat> {
  $$ChatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactIdTable(_$DriftDb db) => db.contacts
      .createAlias($_aliasNameGenerator(db.chats.contactId, db.contacts.id));

  $$ContactsTableProcessedTableManager? get contactId {
    final $_column = $_itemColumn<int>('contact_id');
    if ($_column == null) return null;
    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatParticipantsTable, List<ChatParticipant>>
  _chatParticipantsRefsTable(_$DriftDb db) => MultiTypedResultKey.fromTable(
    db.chatParticipants,
    aliasName: $_aliasNameGenerator(db.chats.id, db.chatParticipants.chatId),
  );

  $$ChatParticipantsTableProcessedTableManager get chatParticipantsRefs {
    final manager = $$ChatParticipantsTableTableManager(
      $_db,
      $_db.chatParticipants,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chatParticipantsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$DriftDb db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(db.chats.id, db.messages.chatId),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.chatId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatsTableFilterComposer extends Composer<_$DriftDb, $ChatsTable> {
  $$ChatsTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatParticipantsRefs(
    Expression<bool> Function($$ChatParticipantsTableFilterComposer f) f,
  ) {
    final $$ChatParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatParticipants,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.chatParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatsTableOrderingComposer extends Composer<_$DriftDb, $ChatsTable> {
  $$ChatsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatsTableAnnotationComposer extends Composer<_$DriftDb, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
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

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => column,
  );

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatParticipantsRefs<T extends Object>(
    Expression<T> Function($$ChatParticipantsTableAnnotationComposer a) f,
  ) {
    final $$ChatParticipantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatParticipants,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatParticipantsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.chatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatsTableTableManager
    extends
        RootTableManager<
          _$DriftDb,
          $ChatsTable,
          Chat,
          $$ChatsTableFilterComposer,
          $$ChatsTableOrderingComposer,
          $$ChatsTableAnnotationComposer,
          $$ChatsTableCreateCompanionBuilder,
          $$ChatsTableUpdateCompanionBuilder,
          (Chat, $$ChatsTableReferences),
          Chat,
          PrefetchHooks Function({
            bool contactId,
            bool chatParticipantsRefs,
            bool messagesRefs,
          })
        > {
  $$ChatsTableTableManager(_$DriftDb db, $ChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<int?> startDate = const Value.absent(),
                Value<int?> endDate = const Value.absent(),
                Value<int> messageCount = const Value.absent(),
                Value<int?> importSourceId = const Value.absent(),
                Value<int?> importLastSyncedAt = const Value.absent(),
              }) => ChatsCompanion(
                id: id,
                contactId: contactId,
                guid: guid,
                displayName: displayName,
                startDate: startDate,
                endDate: endDate,
                messageCount: messageCount,
                importSourceId: importSourceId,
                importLastSyncedAt: importLastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                required String guid,
                Value<String?> displayName = const Value.absent(),
                Value<int?> startDate = const Value.absent(),
                Value<int?> endDate = const Value.absent(),
                Value<int> messageCount = const Value.absent(),
                Value<int?> importSourceId = const Value.absent(),
                Value<int?> importLastSyncedAt = const Value.absent(),
              }) => ChatsCompanion.insert(
                id: id,
                contactId: contactId,
                guid: guid,
                displayName: displayName,
                startDate: startDate,
                endDate: endDate,
                messageCount: messageCount,
                importSourceId: importSourceId,
                importLastSyncedAt: importLastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ChatsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                contactId = false,
                chatParticipantsRefs = false,
                messagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatParticipantsRefs) db.chatParticipants,
                    if (messagesRefs) db.messages,
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
                        if (contactId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.contactId,
                                    referencedTable: $$ChatsTableReferences
                                        ._contactIdTable(db),
                                    referencedColumn: $$ChatsTableReferences
                                        ._contactIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatParticipantsRefs)
                        await $_getPrefetchedData<
                          Chat,
                          $ChatsTable,
                          ChatParticipant
                        >(
                          currentTable: table,
                          referencedTable: $$ChatsTableReferences
                              ._chatParticipantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatParticipantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (messagesRefs)
                        await $_getPrefetchedData<Chat, $ChatsTable, Message>(
                          currentTable: table,
                          referencedTable: $$ChatsTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatsTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
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

typedef $$ChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDb,
      $ChatsTable,
      Chat,
      $$ChatsTableFilterComposer,
      $$ChatsTableOrderingComposer,
      $$ChatsTableAnnotationComposer,
      $$ChatsTableCreateCompanionBuilder,
      $$ChatsTableUpdateCompanionBuilder,
      (Chat, $$ChatsTableReferences),
      Chat,
      PrefetchHooks Function({
        bool contactId,
        bool chatParticipantsRefs,
        bool messagesRefs,
      })
    >;
typedef $$ChatParticipantsTableCreateCompanionBuilder =
    ChatParticipantsCompanion Function({
      required int chatId,
      required int handleId,
      Value<int> rowid,
    });
typedef $$ChatParticipantsTableUpdateCompanionBuilder =
    ChatParticipantsCompanion Function({
      Value<int> chatId,
      Value<int> handleId,
      Value<int> rowid,
    });

final class $$ChatParticipantsTableReferences
    extends BaseReferences<_$DriftDb, $ChatParticipantsTable, ChatParticipant> {
  $$ChatParticipantsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChatsTable _chatIdTable(_$DriftDb db) => db.chats.createAlias(
    $_aliasNameGenerator(db.chatParticipants.chatId, db.chats.id),
  );

  $$ChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$ChatsTableTableManager(
      $_db,
      $_db.chats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HandlesTable _handleIdTable(_$DriftDb db) => db.handles.createAlias(
    $_aliasNameGenerator(db.chatParticipants.handleId, db.handles.id),
  );

  $$HandlesTableProcessedTableManager get handleId {
    final $_column = $_itemColumn<int>('handle_id')!;

    final manager = $$HandlesTableTableManager(
      $_db,
      $_db.handles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_handleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChatParticipantsTableFilterComposer
    extends Composer<_$DriftDb, $ChatParticipantsTable> {
  $$ChatParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ChatsTableFilterComposer get chatId {
    final $$ChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableFilterComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesTableFilterComposer get handleId {
    final $$HandlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.handles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesTableFilterComposer(
            $db: $db,
            $table: $db.handles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatParticipantsTableOrderingComposer
    extends Composer<_$DriftDb, $ChatParticipantsTable> {
  $$ChatParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ChatsTableOrderingComposer get chatId {
    final $$ChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableOrderingComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesTableOrderingComposer get handleId {
    final $$HandlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.handles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesTableOrderingComposer(
            $db: $db,
            $table: $db.handles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatParticipantsTableAnnotationComposer
    extends Composer<_$DriftDb, $ChatParticipantsTable> {
  $$ChatParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ChatsTableAnnotationComposer get chatId {
    final $$ChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesTableAnnotationComposer get handleId {
    final $$HandlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.handleId,
      referencedTable: $db.handles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesTableAnnotationComposer(
            $db: $db,
            $table: $db.handles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatParticipantsTableTableManager
    extends
        RootTableManager<
          _$DriftDb,
          $ChatParticipantsTable,
          ChatParticipant,
          $$ChatParticipantsTableFilterComposer,
          $$ChatParticipantsTableOrderingComposer,
          $$ChatParticipantsTableAnnotationComposer,
          $$ChatParticipantsTableCreateCompanionBuilder,
          $$ChatParticipantsTableUpdateCompanionBuilder,
          (ChatParticipant, $$ChatParticipantsTableReferences),
          ChatParticipant,
          PrefetchHooks Function({bool chatId, bool handleId})
        > {
  $$ChatParticipantsTableTableManager(
    _$DriftDb db,
    $ChatParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<int> handleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatParticipantsCompanion(
                chatId: chatId,
                handleId: handleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int chatId,
                required int handleId,
                Value<int> rowid = const Value.absent(),
              }) => ChatParticipantsCompanion.insert(
                chatId: chatId,
                handleId: handleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatParticipantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chatId = false, handleId = false}) {
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
                                    $$ChatParticipantsTableReferences
                                        ._chatIdTable(db),
                                referencedColumn:
                                    $$ChatParticipantsTableReferences
                                        ._chatIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (handleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.handleId,
                                referencedTable:
                                    $$ChatParticipantsTableReferences
                                        ._handleIdTable(db),
                                referencedColumn:
                                    $$ChatParticipantsTableReferences
                                        ._handleIdTable(db)
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

typedef $$ChatParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDb,
      $ChatParticipantsTable,
      ChatParticipant,
      $$ChatParticipantsTableFilterComposer,
      $$ChatParticipantsTableOrderingComposer,
      $$ChatParticipantsTableAnnotationComposer,
      $$ChatParticipantsTableCreateCompanionBuilder,
      $$ChatParticipantsTableUpdateCompanionBuilder,
      (ChatParticipant, $$ChatParticipantsTableReferences),
      ChatParticipant,
      PrefetchHooks Function({bool chatId, bool handleId})
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required int chatId,
      Value<int?> senderHandleId,
      required int timestamp,
      Value<String?> content,
      Value<bool> isFromMe,
      Value<bool> hasAttachments,
      Value<int?> quotedMessageId,
      Value<int?> importSourceId,
      Value<int?> importLastSyncedAt,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<int> chatId,
      Value<int?> senderHandleId,
      Value<int> timestamp,
      Value<String?> content,
      Value<bool> isFromMe,
      Value<bool> hasAttachments,
      Value<int?> quotedMessageId,
      Value<int?> importSourceId,
      Value<int?> importLastSyncedAt,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$DriftDb, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatsTable _chatIdTable(_$DriftDb db) => db.chats.createAlias(
    $_aliasNameGenerator(db.messages.chatId, db.chats.id),
  );

  $$ChatsTableProcessedTableManager get chatId {
    final $_column = $_itemColumn<int>('chat_id')!;

    final manager = $$ChatsTableTableManager(
      $_db,
      $_db.chats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HandlesTable _senderHandleIdTable(_$DriftDb db) =>
      db.handles.createAlias(
        $_aliasNameGenerator(db.messages.senderHandleId, db.handles.id),
      );

  $$HandlesTableProcessedTableManager? get senderHandleId {
    final $_column = $_itemColumn<int>('sender_handle_id');
    if ($_column == null) return null;
    final manager = $$HandlesTableTableManager(
      $_db,
      $_db.handles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_senderHandleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MessagesTable _quotedMessageIdTable(_$DriftDb db) =>
      db.messages.createAlias(
        $_aliasNameGenerator(db.messages.quotedMessageId, db.messages.id),
      );

  $$MessagesTableProcessedTableManager? get quotedMessageId {
    final $_column = $_itemColumn<int>('quoted_message_id');
    if ($_column == null) return null;
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quotedMessageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<Attachment>>
  _attachmentsRefsTable(_$DriftDb db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: $_aliasNameGenerator(db.messages.id, db.attachments.messageId),
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$DriftDb, $MessagesTable> {
  $$MessagesTableFilterComposer({
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

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFromMe => $composableBuilder(
    column: $table.isFromMe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatsTableFilterComposer get chatId {
    final $$ChatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableFilterComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesTableFilterComposer get senderHandleId {
    final $$HandlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderHandleId,
      referencedTable: $db.handles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesTableFilterComposer(
            $db: $db,
            $table: $db.handles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MessagesTableFilterComposer get quotedMessageId {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quotedMessageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$DriftDb, $MessagesTable> {
  $$MessagesTableOrderingComposer({
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

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFromMe => $composableBuilder(
    column: $table.isFromMe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatsTableOrderingComposer get chatId {
    final $$ChatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableOrderingComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesTableOrderingComposer get senderHandleId {
    final $$HandlesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderHandleId,
      referencedTable: $db.handles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesTableOrderingComposer(
            $db: $db,
            $table: $db.handles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MessagesTableOrderingComposer get quotedMessageId {
    final $$MessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quotedMessageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableOrderingComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$DriftDb, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isFromMe =>
      $composableBuilder(column: $table.isFromMe, builder: (column) => column);

  GeneratedColumn<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => column,
  );

  $$ChatsTableAnnotationComposer get chatId {
    final $$ChatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatId,
      referencedTable: $db.chats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatsTableAnnotationComposer(
            $db: $db,
            $table: $db.chats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HandlesTableAnnotationComposer get senderHandleId {
    final $$HandlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderHandleId,
      referencedTable: $db.handles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HandlesTableAnnotationComposer(
            $db: $db,
            $table: $db.handles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MessagesTableAnnotationComposer get quotedMessageId {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quotedMessageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$DriftDb,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({
            bool chatId,
            bool senderHandleId,
            bool quotedMessageId,
            bool attachmentsRefs,
          })
        > {
  $$MessagesTableTableManager(_$DriftDb db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<int?> senderHandleId = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<bool> isFromMe = const Value.absent(),
                Value<bool> hasAttachments = const Value.absent(),
                Value<int?> quotedMessageId = const Value.absent(),
                Value<int?> importSourceId = const Value.absent(),
                Value<int?> importLastSyncedAt = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                chatId: chatId,
                senderHandleId: senderHandleId,
                timestamp: timestamp,
                content: content,
                isFromMe: isFromMe,
                hasAttachments: hasAttachments,
                quotedMessageId: quotedMessageId,
                importSourceId: importSourceId,
                importLastSyncedAt: importLastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chatId,
                Value<int?> senderHandleId = const Value.absent(),
                required int timestamp,
                Value<String?> content = const Value.absent(),
                Value<bool> isFromMe = const Value.absent(),
                Value<bool> hasAttachments = const Value.absent(),
                Value<int?> quotedMessageId = const Value.absent(),
                Value<int?> importSourceId = const Value.absent(),
                Value<int?> importLastSyncedAt = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                chatId: chatId,
                senderHandleId: senderHandleId,
                timestamp: timestamp,
                content: content,
                isFromMe: isFromMe,
                hasAttachments: hasAttachments,
                quotedMessageId: quotedMessageId,
                importSourceId: importSourceId,
                importLastSyncedAt: importLastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                chatId = false,
                senderHandleId = false,
                quotedMessageId = false,
                attachmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attachmentsRefs) db.attachments,
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
                        if (chatId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chatId,
                                    referencedTable: $$MessagesTableReferences
                                        ._chatIdTable(db),
                                    referencedColumn: $$MessagesTableReferences
                                        ._chatIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (senderHandleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.senderHandleId,
                                    referencedTable: $$MessagesTableReferences
                                        ._senderHandleIdTable(db),
                                    referencedColumn: $$MessagesTableReferences
                                        ._senderHandleIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (quotedMessageId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.quotedMessageId,
                                    referencedTable: $$MessagesTableReferences
                                        ._quotedMessageIdTable(db),
                                    referencedColumn: $$MessagesTableReferences
                                        ._quotedMessageIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attachmentsRefs)
                        await $_getPrefetchedData<
                          Message,
                          $MessagesTable,
                          Attachment
                        >(
                          currentTable: table,
                          referencedTable: $$MessagesTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MessagesTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.messageId == item.id,
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

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDb,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({
        bool chatId,
        bool senderHandleId,
        bool quotedMessageId,
        bool attachmentsRefs,
      })
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      required int messageId,
      required String filePath,
      Value<String?> mimeType,
      Value<int?> fileSize,
      Value<String?> thumbnailPath,
      Value<int?> importSourceId,
      Value<int?> importLastSyncedAt,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<int> id,
      Value<int> messageId,
      Value<String> filePath,
      Value<String?> mimeType,
      Value<int?> fileSize,
      Value<String?> thumbnailPath,
      Value<int?> importSourceId,
      Value<int?> importLastSyncedAt,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$DriftDb, $AttachmentsTable, Attachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MessagesTable _messageIdTable(_$DriftDb db) =>
      db.messages.createAlias(
        $_aliasNameGenerator(db.attachments.messageId, db.messages.id),
      );

  $$MessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<int>('message_id')!;

    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$DriftDb, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
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

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MessagesTableFilterComposer get messageId {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$DriftDb, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MessagesTableOrderingComposer get messageId {
    final $$MessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableOrderingComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$DriftDb, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importSourceId => $composableBuilder(
    column: $table.importSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importLastSyncedAt => $composableBuilder(
    column: $table.importLastSyncedAt,
    builder: (column) => column,
  );

  $$MessagesTableAnnotationComposer get messageId {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$DriftDb,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (Attachment, $$AttachmentsTableReferences),
          Attachment,
          PrefetchHooks Function({bool messageId})
        > {
  $$AttachmentsTableTableManager(_$DriftDb db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> messageId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> importSourceId = const Value.absent(),
                Value<int?> importLastSyncedAt = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                messageId: messageId,
                filePath: filePath,
                mimeType: mimeType,
                fileSize: fileSize,
                thumbnailPath: thumbnailPath,
                importSourceId: importSourceId,
                importLastSyncedAt: importLastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int messageId,
                required String filePath,
                Value<String?> mimeType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> importSourceId = const Value.absent(),
                Value<int?> importLastSyncedAt = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                messageId: messageId,
                filePath: filePath,
                mimeType: mimeType,
                fileSize: fileSize,
                thumbnailPath: thumbnailPath,
                importSourceId: importSourceId,
                importLastSyncedAt: importLastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageId = false}) {
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
                    if (messageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.messageId,
                                referencedTable: $$AttachmentsTableReferences
                                    ._messageIdTable(db),
                                referencedColumn: $$AttachmentsTableReferences
                                    ._messageIdTable(db)
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

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftDb,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (Attachment, $$AttachmentsTableReferences),
      Attachment,
      PrefetchHooks Function({bool messageId})
    >;

class $DriftDbManager {
  final _$DriftDb _db;
  $DriftDbManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$HandlesTableTableManager get handles =>
      $$HandlesTableTableManager(_db, _db.handles);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$ChatParticipantsTableTableManager get chatParticipants =>
      $$ChatParticipantsTableTableManager(_db, _db.chatParticipants);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
}
