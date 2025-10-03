// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overlay_database.dart';

// ignore_for_file: type=lint
class $ParticipantOverridesTable extends ParticipantOverrides
    with TableInfo<$ParticipantOverridesTable, ParticipantOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _participantIdMeta = const VerificationMeta(
    'participantId',
  );
  @override
  late final GeneratedColumn<int> participantId = GeneratedColumn<int>(
    'participant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMutedMeta = const VerificationMeta(
    'isMuted',
  );
  @override
  late final GeneratedColumn<bool> isMuted = GeneratedColumn<bool>(
    'is_muted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_muted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    participantId,
    shortName,
    isMuted,
    notes,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participant_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ParticipantOverride> instance, {
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
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    }
    if (data.containsKey('is_muted')) {
      context.handle(
        _isMutedMeta,
        isMuted.isAcceptableOrUnknown(data['is_muted']!, _isMutedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {participantId};
  @override
  ParticipantOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParticipantOverride(
      participantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_id'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      ),
      isMuted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_muted'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $ParticipantOverridesTable createAlias(String alias) {
    return $ParticipantOverridesTable(attachedDatabase, alias);
  }
}

class ParticipantOverride extends DataClass
    implements Insertable<ParticipantOverride> {
  /// Matches working.participants.id
  final int participantId;

  /// User's custom short name for this participant
  final String? shortName;

  /// Whether user has muted this participant
  final bool isMuted;

  /// User's custom notes about this participant
  final String? notes;
  final String createdAtUtc;
  final String updatedAtUtc;
  const ParticipantOverride({
    required this.participantId,
    this.shortName,
    required this.isMuted,
    this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['participant_id'] = Variable<int>(participantId);
    if (!nullToAbsent || shortName != null) {
      map['short_name'] = Variable<String>(shortName);
    }
    map['is_muted'] = Variable<bool>(isMuted);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  ParticipantOverridesCompanion toCompanion(bool nullToAbsent) {
    return ParticipantOverridesCompanion(
      participantId: Value(participantId),
      shortName: shortName == null && nullToAbsent
          ? const Value.absent()
          : Value(shortName),
      isMuted: Value(isMuted),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ParticipantOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParticipantOverride(
      participantId: serializer.fromJson<int>(json['participantId']),
      shortName: serializer.fromJson<String?>(json['shortName']),
      isMuted: serializer.fromJson<bool>(json['isMuted']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'participantId': serializer.toJson<int>(participantId),
      'shortName': serializer.toJson<String?>(shortName),
      'isMuted': serializer.toJson<bool>(isMuted),
      'notes': serializer.toJson<String?>(notes),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  ParticipantOverride copyWith({
    int? participantId,
    Value<String?> shortName = const Value.absent(),
    bool? isMuted,
    Value<String?> notes = const Value.absent(),
    String? createdAtUtc,
    String? updatedAtUtc,
  }) => ParticipantOverride(
    participantId: participantId ?? this.participantId,
    shortName: shortName.present ? shortName.value : this.shortName,
    isMuted: isMuted ?? this.isMuted,
    notes: notes.present ? notes.value : this.notes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ParticipantOverride copyWithCompanion(ParticipantOverridesCompanion data) {
    return ParticipantOverride(
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      isMuted: data.isMuted.present ? data.isMuted.value : this.isMuted,
      notes: data.notes.present ? data.notes.value : this.notes,
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
    return (StringBuffer('ParticipantOverride(')
          ..write('participantId: $participantId, ')
          ..write('shortName: $shortName, ')
          ..write('isMuted: $isMuted, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    participantId,
    shortName,
    isMuted,
    notes,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParticipantOverride &&
          other.participantId == this.participantId &&
          other.shortName == this.shortName &&
          other.isMuted == this.isMuted &&
          other.notes == this.notes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ParticipantOverridesCompanion
    extends UpdateCompanion<ParticipantOverride> {
  final Value<int> participantId;
  final Value<String?> shortName;
  final Value<bool> isMuted;
  final Value<String?> notes;
  final Value<String> createdAtUtc;
  final Value<String> updatedAtUtc;
  const ParticipantOverridesCompanion({
    this.participantId = const Value.absent(),
    this.shortName = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  ParticipantOverridesCompanion.insert({
    this.participantId = const Value.absent(),
    this.shortName = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAtUtc,
    required String updatedAtUtc,
  }) : createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ParticipantOverride> custom({
    Expression<int>? participantId,
    Expression<String>? shortName,
    Expression<bool>? isMuted,
    Expression<String>? notes,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (participantId != null) 'participant_id': participantId,
      if (shortName != null) 'short_name': shortName,
      if (isMuted != null) 'is_muted': isMuted,
      if (notes != null) 'notes': notes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  ParticipantOverridesCompanion copyWith({
    Value<int>? participantId,
    Value<String?>? shortName,
    Value<bool>? isMuted,
    Value<String?>? notes,
    Value<String>? createdAtUtc,
    Value<String>? updatedAtUtc,
  }) {
    return ParticipantOverridesCompanion(
      participantId: participantId ?? this.participantId,
      shortName: shortName ?? this.shortName,
      isMuted: isMuted ?? this.isMuted,
      notes: notes ?? this.notes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (participantId.present) {
      map['participant_id'] = Variable<int>(participantId.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (isMuted.present) {
      map['is_muted'] = Variable<bool>(isMuted.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('ParticipantOverridesCompanion(')
          ..write('participantId: $participantId, ')
          ..write('shortName: $shortName, ')
          ..write('isMuted: $isMuted, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $ChatOverridesTable extends ChatOverrides
    with TableInfo<$ChatOverridesTable, ChatOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customColorMeta = const VerificationMeta(
    'customColor',
  );
  @override
  late final GeneratedColumn<String> customColor = GeneratedColumn<String>(
    'custom_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<String> updatedAtUtc = GeneratedColumn<String>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chatId,
    customName,
    customColor,
    notes,
    createdAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatOverride> instance, {
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
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('custom_color')) {
      context.handle(
        _customColorMeta,
        customColor.isAcceptableOrUnknown(
          data['custom_color']!,
          _customColorMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId};
  @override
  ChatOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatOverride(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      customColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_color'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $ChatOverridesTable createAlias(String alias) {
    return $ChatOverridesTable(attachedDatabase, alias);
  }
}

class ChatOverride extends DataClass implements Insertable<ChatOverride> {
  /// Matches working.chats.id
  final int chatId;

  /// User's custom name for this chat (overrides derived title)
  final String? customName;

  /// User's custom color/theme for this chat
  final String? customColor;

  /// User's notes about this chat
  final String? notes;
  final String createdAtUtc;
  final String updatedAtUtc;
  const ChatOverride({
    required this.chatId,
    this.customName,
    this.customColor,
    this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    if (!nullToAbsent || customColor != null) {
      map['custom_color'] = Variable<String>(customColor);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at_utc'] = Variable<String>(createdAtUtc);
    map['updated_at_utc'] = Variable<String>(updatedAtUtc);
    return map;
  }

  ChatOverridesCompanion toCompanion(bool nullToAbsent) {
    return ChatOverridesCompanion(
      chatId: Value(chatId),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      customColor: customColor == null && nullToAbsent
          ? const Value.absent()
          : Value(customColor),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory ChatOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatOverride(
      chatId: serializer.fromJson<int>(json['chatId']),
      customName: serializer.fromJson<String?>(json['customName']),
      customColor: serializer.fromJson<String?>(json['customColor']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAtUtc: serializer.fromJson<String>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<String>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'customName': serializer.toJson<String?>(customName),
      'customColor': serializer.toJson<String?>(customColor),
      'notes': serializer.toJson<String?>(notes),
      'createdAtUtc': serializer.toJson<String>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<String>(updatedAtUtc),
    };
  }

  ChatOverride copyWith({
    int? chatId,
    Value<String?> customName = const Value.absent(),
    Value<String?> customColor = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdAtUtc,
    String? updatedAtUtc,
  }) => ChatOverride(
    chatId: chatId ?? this.chatId,
    customName: customName.present ? customName.value : this.customName,
    customColor: customColor.present ? customColor.value : this.customColor,
    notes: notes.present ? notes.value : this.notes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  ChatOverride copyWithCompanion(ChatOverridesCompanion data) {
    return ChatOverride(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      customColor: data.customColor.present
          ? data.customColor.value
          : this.customColor,
      notes: data.notes.present ? data.notes.value : this.notes,
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
    return (StringBuffer('ChatOverride(')
          ..write('chatId: $chatId, ')
          ..write('customName: $customName, ')
          ..write('customColor: $customColor, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chatId,
    customName,
    customColor,
    notes,
    createdAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatOverride &&
          other.chatId == this.chatId &&
          other.customName == this.customName &&
          other.customColor == this.customColor &&
          other.notes == this.notes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class ChatOverridesCompanion extends UpdateCompanion<ChatOverride> {
  final Value<int> chatId;
  final Value<String?> customName;
  final Value<String?> customColor;
  final Value<String?> notes;
  final Value<String> createdAtUtc;
  final Value<String> updatedAtUtc;
  const ChatOverridesCompanion({
    this.chatId = const Value.absent(),
    this.customName = const Value.absent(),
    this.customColor = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  ChatOverridesCompanion.insert({
    this.chatId = const Value.absent(),
    this.customName = const Value.absent(),
    this.customColor = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAtUtc,
    required String updatedAtUtc,
  }) : createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<ChatOverride> custom({
    Expression<int>? chatId,
    Expression<String>? customName,
    Expression<String>? customColor,
    Expression<String>? notes,
    Expression<String>? createdAtUtc,
    Expression<String>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (customName != null) 'custom_name': customName,
      if (customColor != null) 'custom_color': customColor,
      if (notes != null) 'notes': notes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  ChatOverridesCompanion copyWith({
    Value<int>? chatId,
    Value<String?>? customName,
    Value<String?>? customColor,
    Value<String?>? notes,
    Value<String>? createdAtUtc,
    Value<String>? updatedAtUtc,
  }) {
    return ChatOverridesCompanion(
      chatId: chatId ?? this.chatId,
      customName: customName ?? this.customName,
      customColor: customColor ?? this.customColor,
      notes: notes ?? this.notes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (customColor.present) {
      map['custom_color'] = Variable<String>(customColor.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('ChatOverridesCompanion(')
          ..write('chatId: $chatId, ')
          ..write('customName: $customName, ')
          ..write('customColor: $customColor, ')
          ..write('notes: $notes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

abstract class _$OverlayDatabase extends GeneratedDatabase {
  _$OverlayDatabase(QueryExecutor e) : super(e);
  $OverlayDatabaseManager get managers => $OverlayDatabaseManager(this);
  late final $ParticipantOverridesTable participantOverrides =
      $ParticipantOverridesTable(this);
  late final $ChatOverridesTable chatOverrides = $ChatOverridesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    participantOverrides,
    chatOverrides,
  ];
}

typedef $$ParticipantOverridesTableCreateCompanionBuilder =
    ParticipantOverridesCompanion Function({
      Value<int> participantId,
      Value<String?> shortName,
      Value<bool> isMuted,
      Value<String?> notes,
      required String createdAtUtc,
      required String updatedAtUtc,
    });
typedef $$ParticipantOverridesTableUpdateCompanionBuilder =
    ParticipantOverridesCompanion Function({
      Value<int> participantId,
      Value<String?> shortName,
      Value<bool> isMuted,
      Value<String?> notes,
      Value<String> createdAtUtc,
      Value<String> updatedAtUtc,
    });

class $$ParticipantOverridesTableFilterComposer
    extends Composer<_$OverlayDatabase, $ParticipantOverridesTable> {
  $$ParticipantOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMuted => $composableBuilder(
    column: $table.isMuted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$ParticipantOverridesTableOrderingComposer
    extends Composer<_$OverlayDatabase, $ParticipantOverridesTable> {
  $$ParticipantOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMuted => $composableBuilder(
    column: $table.isMuted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$ParticipantOverridesTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $ParticipantOverridesTable> {
  $$ParticipantOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get participantId => $composableBuilder(
    column: $table.participantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<bool> get isMuted =>
      $composableBuilder(column: $table.isMuted, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$ParticipantOverridesTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $ParticipantOverridesTable,
          ParticipantOverride,
          $$ParticipantOverridesTableFilterComposer,
          $$ParticipantOverridesTableOrderingComposer,
          $$ParticipantOverridesTableAnnotationComposer,
          $$ParticipantOverridesTableCreateCompanionBuilder,
          $$ParticipantOverridesTableUpdateCompanionBuilder,
          (
            ParticipantOverride,
            BaseReferences<
              _$OverlayDatabase,
              $ParticipantOverridesTable,
              ParticipantOverride
            >,
          ),
          ParticipantOverride,
          PrefetchHooks Function()
        > {
  $$ParticipantOverridesTableTableManager(
    _$OverlayDatabase db,
    $ParticipantOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantOverridesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ParticipantOverridesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> participantId = const Value.absent(),
                Value<String?> shortName = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => ParticipantOverridesCompanion(
                participantId: participantId,
                shortName: shortName,
                isMuted: isMuted,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> participantId = const Value.absent(),
                Value<String?> shortName = const Value.absent(),
                Value<bool> isMuted = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAtUtc,
                required String updatedAtUtc,
              }) => ParticipantOverridesCompanion.insert(
                participantId: participantId,
                shortName: shortName,
                isMuted: isMuted,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ParticipantOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $ParticipantOverridesTable,
      ParticipantOverride,
      $$ParticipantOverridesTableFilterComposer,
      $$ParticipantOverridesTableOrderingComposer,
      $$ParticipantOverridesTableAnnotationComposer,
      $$ParticipantOverridesTableCreateCompanionBuilder,
      $$ParticipantOverridesTableUpdateCompanionBuilder,
      (
        ParticipantOverride,
        BaseReferences<
          _$OverlayDatabase,
          $ParticipantOverridesTable,
          ParticipantOverride
        >,
      ),
      ParticipantOverride,
      PrefetchHooks Function()
    >;
typedef $$ChatOverridesTableCreateCompanionBuilder =
    ChatOverridesCompanion Function({
      Value<int> chatId,
      Value<String?> customName,
      Value<String?> customColor,
      Value<String?> notes,
      required String createdAtUtc,
      required String updatedAtUtc,
    });
typedef $$ChatOverridesTableUpdateCompanionBuilder =
    ChatOverridesCompanion Function({
      Value<int> chatId,
      Value<String?> customName,
      Value<String?> customColor,
      Value<String?> notes,
      Value<String> createdAtUtc,
      Value<String> updatedAtUtc,
    });

class $$ChatOverridesTableFilterComposer
    extends Composer<_$OverlayDatabase, $ChatOverridesTable> {
  $$ChatOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customColor => $composableBuilder(
    column: $table.customColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$ChatOverridesTableOrderingComposer
    extends Composer<_$OverlayDatabase, $ChatOverridesTable> {
  $$ChatOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customColor => $composableBuilder(
    column: $table.customColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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
}

class $$ChatOverridesTableAnnotationComposer
    extends Composer<_$OverlayDatabase, $ChatOverridesTable> {
  $$ChatOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customColor => $composableBuilder(
    column: $table.customColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$ChatOverridesTableTableManager
    extends
        RootTableManager<
          _$OverlayDatabase,
          $ChatOverridesTable,
          ChatOverride,
          $$ChatOverridesTableFilterComposer,
          $$ChatOverridesTableOrderingComposer,
          $$ChatOverridesTableAnnotationComposer,
          $$ChatOverridesTableCreateCompanionBuilder,
          $$ChatOverridesTableUpdateCompanionBuilder,
          (
            ChatOverride,
            BaseReferences<
              _$OverlayDatabase,
              $ChatOverridesTable,
              ChatOverride
            >,
          ),
          ChatOverride,
          PrefetchHooks Function()
        > {
  $$ChatOverridesTableTableManager(
    _$OverlayDatabase db,
    $ChatOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customColor = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAtUtc = const Value.absent(),
                Value<String> updatedAtUtc = const Value.absent(),
              }) => ChatOverridesCompanion(
                chatId: chatId,
                customName: customName,
                customColor: customColor,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customColor = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAtUtc,
                required String updatedAtUtc,
              }) => ChatOverridesCompanion.insert(
                chatId: chatId,
                customName: customName,
                customColor: customColor,
                notes: notes,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$OverlayDatabase,
      $ChatOverridesTable,
      ChatOverride,
      $$ChatOverridesTableFilterComposer,
      $$ChatOverridesTableOrderingComposer,
      $$ChatOverridesTableAnnotationComposer,
      $$ChatOverridesTableCreateCompanionBuilder,
      $$ChatOverridesTableUpdateCompanionBuilder,
      (
        ChatOverride,
        BaseReferences<_$OverlayDatabase, $ChatOverridesTable, ChatOverride>,
      ),
      ChatOverride,
      PrefetchHooks Function()
    >;

class $OverlayDatabaseManager {
  final _$OverlayDatabase _db;
  $OverlayDatabaseManager(this._db);
  $$ParticipantOverridesTableTableManager get participantOverrides =>
      $$ParticipantOverridesTableTableManager(_db, _db.participantOverrides);
  $$ChatOverridesTableTableManager get chatOverrides =>
      $$ChatOverridesTableTableManager(_db, _db.chatOverrides);
}
