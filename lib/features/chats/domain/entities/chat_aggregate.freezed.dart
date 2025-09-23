// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_aggregate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Chat {

 ChatId get id; String get guid; ChatDisplayName get displayName; List<ChatParticipant> get participants; ChatTimestamps get timestamps; ChatStats get stats; ContactId? get primaryContactId;// For 1:1 chats
 List<String> get tags; ImportMetadata? get importMetadata;
/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatCopyWith<Chat> get copyWith => _$ChatCopyWithImpl<Chat>(this as Chat, _$identity);

  /// Serializes this Chat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Chat&&(identical(other.id, id) || other.id == id)&&(identical(other.guid, guid) || other.guid == guid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.timestamps, timestamps) || other.timestamps == timestamps)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.primaryContactId, primaryContactId) || other.primaryContactId == primaryContactId)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.importMetadata, importMetadata) || other.importMetadata == importMetadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guid,displayName,const DeepCollectionEquality().hash(participants),timestamps,stats,primaryContactId,const DeepCollectionEquality().hash(tags),importMetadata);

@override
String toString() {
  return 'Chat(id: $id, guid: $guid, displayName: $displayName, participants: $participants, timestamps: $timestamps, stats: $stats, primaryContactId: $primaryContactId, tags: $tags, importMetadata: $importMetadata)';
}


}

/// @nodoc
abstract mixin class $ChatCopyWith<$Res>  {
  factory $ChatCopyWith(Chat value, $Res Function(Chat) _then) = _$ChatCopyWithImpl;
@useResult
$Res call({
 ChatId id, String guid, ChatDisplayName displayName, List<ChatParticipant> participants, ChatTimestamps timestamps, ChatStats stats, ContactId? primaryContactId, List<String> tags, ImportMetadata? importMetadata
});


$ChatIdCopyWith<$Res> get id;$ChatDisplayNameCopyWith<$Res> get displayName;$ChatTimestampsCopyWith<$Res> get timestamps;$ChatStatsCopyWith<$Res> get stats;$ContactIdCopyWith<$Res>? get primaryContactId;$ImportMetadataCopyWith<$Res>? get importMetadata;

}
/// @nodoc
class _$ChatCopyWithImpl<$Res>
    implements $ChatCopyWith<$Res> {
  _$ChatCopyWithImpl(this._self, this._then);

  final Chat _self;
  final $Res Function(Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guid = null,Object? displayName = null,Object? participants = null,Object? timestamps = null,Object? stats = null,Object? primaryContactId = freezed,Object? tags = null,Object? importMetadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ChatId,guid: null == guid ? _self.guid : guid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as ChatDisplayName,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<ChatParticipant>,timestamps: null == timestamps ? _self.timestamps : timestamps // ignore: cast_nullable_to_non_nullable
as ChatTimestamps,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ChatStats,primaryContactId: freezed == primaryContactId ? _self.primaryContactId : primaryContactId // ignore: cast_nullable_to_non_nullable
as ContactId?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,importMetadata: freezed == importMetadata ? _self.importMetadata : importMetadata // ignore: cast_nullable_to_non_nullable
as ImportMetadata?,
  ));
}
/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatIdCopyWith<$Res> get id {
  
  return $ChatIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatDisplayNameCopyWith<$Res> get displayName {
  
  return $ChatDisplayNameCopyWith<$Res>(_self.displayName, (value) {
    return _then(_self.copyWith(displayName: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatTimestampsCopyWith<$Res> get timestamps {
  
  return $ChatTimestampsCopyWith<$Res>(_self.timestamps, (value) {
    return _then(_self.copyWith(timestamps: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatStatsCopyWith<$Res> get stats {
  
  return $ChatStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res>? get primaryContactId {
    if (_self.primaryContactId == null) {
    return null;
  }

  return $ContactIdCopyWith<$Res>(_self.primaryContactId!, (value) {
    return _then(_self.copyWith(primaryContactId: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportMetadataCopyWith<$Res>? get importMetadata {
    if (_self.importMetadata == null) {
    return null;
  }

  return $ImportMetadataCopyWith<$Res>(_self.importMetadata!, (value) {
    return _then(_self.copyWith(importMetadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [Chat].
extension ChatPatterns on Chat {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Chat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Chat value)  $default,){
final _that = this;
switch (_that) {
case _Chat():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Chat value)?  $default,){
final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatId id,  String guid,  ChatDisplayName displayName,  List<ChatParticipant> participants,  ChatTimestamps timestamps,  ChatStats stats,  ContactId? primaryContactId,  List<String> tags,  ImportMetadata? importMetadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that.id,_that.guid,_that.displayName,_that.participants,_that.timestamps,_that.stats,_that.primaryContactId,_that.tags,_that.importMetadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatId id,  String guid,  ChatDisplayName displayName,  List<ChatParticipant> participants,  ChatTimestamps timestamps,  ChatStats stats,  ContactId? primaryContactId,  List<String> tags,  ImportMetadata? importMetadata)  $default,) {final _that = this;
switch (_that) {
case _Chat():
return $default(_that.id,_that.guid,_that.displayName,_that.participants,_that.timestamps,_that.stats,_that.primaryContactId,_that.tags,_that.importMetadata);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatId id,  String guid,  ChatDisplayName displayName,  List<ChatParticipant> participants,  ChatTimestamps timestamps,  ChatStats stats,  ContactId? primaryContactId,  List<String> tags,  ImportMetadata? importMetadata)?  $default,) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that.id,_that.guid,_that.displayName,_that.participants,_that.timestamps,_that.stats,_that.primaryContactId,_that.tags,_that.importMetadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Chat extends Chat {
  const _Chat({required this.id, required this.guid, required this.displayName, required final  List<ChatParticipant> participants, required this.timestamps, required this.stats, this.primaryContactId, final  List<String> tags = const [], this.importMetadata}): _participants = participants,_tags = tags,super._();
  factory _Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

@override final  ChatId id;
@override final  String guid;
@override final  ChatDisplayName displayName;
 final  List<ChatParticipant> _participants;
@override List<ChatParticipant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

@override final  ChatTimestamps timestamps;
@override final  ChatStats stats;
@override final  ContactId? primaryContactId;
// For 1:1 chats
 final  List<String> _tags;
// For 1:1 chats
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  ImportMetadata? importMetadata;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatCopyWith<_Chat> get copyWith => __$ChatCopyWithImpl<_Chat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Chat&&(identical(other.id, id) || other.id == id)&&(identical(other.guid, guid) || other.guid == guid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other._participants, _participants)&&(identical(other.timestamps, timestamps) || other.timestamps == timestamps)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.primaryContactId, primaryContactId) || other.primaryContactId == primaryContactId)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.importMetadata, importMetadata) || other.importMetadata == importMetadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guid,displayName,const DeepCollectionEquality().hash(_participants),timestamps,stats,primaryContactId,const DeepCollectionEquality().hash(_tags),importMetadata);

@override
String toString() {
  return 'Chat(id: $id, guid: $guid, displayName: $displayName, participants: $participants, timestamps: $timestamps, stats: $stats, primaryContactId: $primaryContactId, tags: $tags, importMetadata: $importMetadata)';
}


}

/// @nodoc
abstract mixin class _$ChatCopyWith<$Res> implements $ChatCopyWith<$Res> {
  factory _$ChatCopyWith(_Chat value, $Res Function(_Chat) _then) = __$ChatCopyWithImpl;
@override @useResult
$Res call({
 ChatId id, String guid, ChatDisplayName displayName, List<ChatParticipant> participants, ChatTimestamps timestamps, ChatStats stats, ContactId? primaryContactId, List<String> tags, ImportMetadata? importMetadata
});


@override $ChatIdCopyWith<$Res> get id;@override $ChatDisplayNameCopyWith<$Res> get displayName;@override $ChatTimestampsCopyWith<$Res> get timestamps;@override $ChatStatsCopyWith<$Res> get stats;@override $ContactIdCopyWith<$Res>? get primaryContactId;@override $ImportMetadataCopyWith<$Res>? get importMetadata;

}
/// @nodoc
class __$ChatCopyWithImpl<$Res>
    implements _$ChatCopyWith<$Res> {
  __$ChatCopyWithImpl(this._self, this._then);

  final _Chat _self;
  final $Res Function(_Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guid = null,Object? displayName = null,Object? participants = null,Object? timestamps = null,Object? stats = null,Object? primaryContactId = freezed,Object? tags = null,Object? importMetadata = freezed,}) {
  return _then(_Chat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ChatId,guid: null == guid ? _self.guid : guid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as ChatDisplayName,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<ChatParticipant>,timestamps: null == timestamps ? _self.timestamps : timestamps // ignore: cast_nullable_to_non_nullable
as ChatTimestamps,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ChatStats,primaryContactId: freezed == primaryContactId ? _self.primaryContactId : primaryContactId // ignore: cast_nullable_to_non_nullable
as ContactId?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,importMetadata: freezed == importMetadata ? _self.importMetadata : importMetadata // ignore: cast_nullable_to_non_nullable
as ImportMetadata?,
  ));
}

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatIdCopyWith<$Res> get id {
  
  return $ChatIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatDisplayNameCopyWith<$Res> get displayName {
  
  return $ChatDisplayNameCopyWith<$Res>(_self.displayName, (value) {
    return _then(_self.copyWith(displayName: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatTimestampsCopyWith<$Res> get timestamps {
  
  return $ChatTimestampsCopyWith<$Res>(_self.timestamps, (value) {
    return _then(_self.copyWith(timestamps: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatStatsCopyWith<$Res> get stats {
  
  return $ChatStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res>? get primaryContactId {
    if (_self.primaryContactId == null) {
    return null;
  }

  return $ContactIdCopyWith<$Res>(_self.primaryContactId!, (value) {
    return _then(_self.copyWith(primaryContactId: value));
  });
}/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportMetadataCopyWith<$Res>? get importMetadata {
    if (_self.importMetadata == null) {
    return null;
  }

  return $ImportMetadataCopyWith<$Res>(_self.importMetadata!, (value) {
    return _then(_self.copyWith(importMetadata: value));
  });
}
}


/// @nodoc
mixin _$ChatId {

 String get value;
/// Create a copy of ChatId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatIdCopyWith<ChatId> get copyWith => _$ChatIdCopyWithImpl<ChatId>(this as ChatId, _$identity);

  /// Serializes this ChatId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ChatId(value: $value)';
}


}

/// @nodoc
abstract mixin class $ChatIdCopyWith<$Res>  {
  factory $ChatIdCopyWith(ChatId value, $Res Function(ChatId) _then) = _$ChatIdCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$ChatIdCopyWithImpl<$Res>
    implements $ChatIdCopyWith<$Res> {
  _$ChatIdCopyWithImpl(this._self, this._then);

  final ChatId _self;
  final $Res Function(ChatId) _then;

/// Create a copy of ChatId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatId].
extension ChatIdPatterns on ChatId {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatId() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatId value)  $default,){
final _that = this;
switch (_that) {
case _ChatId():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatId value)?  $default,){
final _that = this;
switch (_that) {
case _ChatId() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatId() when $default != null:
return $default(_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value)  $default,) {final _that = this;
switch (_that) {
case _ChatId():
return $default(_that.value);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value)?  $default,) {final _that = this;
switch (_that) {
case _ChatId() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatId implements ChatId {
  const _ChatId(this.value);
  factory _ChatId.fromJson(Map<String, dynamic> json) => _$ChatIdFromJson(json);

@override final  String value;

/// Create a copy of ChatId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatIdCopyWith<_ChatId> get copyWith => __$ChatIdCopyWithImpl<_ChatId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ChatId(value: $value)';
}


}

/// @nodoc
abstract mixin class _$ChatIdCopyWith<$Res> implements $ChatIdCopyWith<$Res> {
  factory _$ChatIdCopyWith(_ChatId value, $Res Function(_ChatId) _then) = __$ChatIdCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$ChatIdCopyWithImpl<$Res>
    implements _$ChatIdCopyWith<$Res> {
  __$ChatIdCopyWithImpl(this._self, this._then);

  final _ChatId _self;
  final $Res Function(_ChatId) _then;

/// Create a copy of ChatId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_ChatId(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChatDisplayName {

 String get value; DisplayNameSource get source;
/// Create a copy of ChatDisplayName
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatDisplayNameCopyWith<ChatDisplayName> get copyWith => _$ChatDisplayNameCopyWithImpl<ChatDisplayName>(this as ChatDisplayName, _$identity);

  /// Serializes this ChatDisplayName to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatDisplayName&&(identical(other.value, value) || other.value == value)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,source);

@override
String toString() {
  return 'ChatDisplayName(value: $value, source: $source)';
}


}

/// @nodoc
abstract mixin class $ChatDisplayNameCopyWith<$Res>  {
  factory $ChatDisplayNameCopyWith(ChatDisplayName value, $Res Function(ChatDisplayName) _then) = _$ChatDisplayNameCopyWithImpl;
@useResult
$Res call({
 String value, DisplayNameSource source
});




}
/// @nodoc
class _$ChatDisplayNameCopyWithImpl<$Res>
    implements $ChatDisplayNameCopyWith<$Res> {
  _$ChatDisplayNameCopyWithImpl(this._self, this._then);

  final ChatDisplayName _self;
  final $Res Function(ChatDisplayName) _then;

/// Create a copy of ChatDisplayName
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? source = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DisplayNameSource,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatDisplayName].
extension ChatDisplayNamePatterns on ChatDisplayName {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatDisplayName value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatDisplayName() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatDisplayName value)  $default,){
final _that = this;
switch (_that) {
case _ChatDisplayName():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatDisplayName value)?  $default,){
final _that = this;
switch (_that) {
case _ChatDisplayName() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  DisplayNameSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatDisplayName() when $default != null:
return $default(_that.value,_that.source);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  DisplayNameSource source)  $default,) {final _that = this;
switch (_that) {
case _ChatDisplayName():
return $default(_that.value,_that.source);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  DisplayNameSource source)?  $default,) {final _that = this;
switch (_that) {
case _ChatDisplayName() when $default != null:
return $default(_that.value,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatDisplayName extends ChatDisplayName {
  const _ChatDisplayName({required this.value, required this.source}): super._();
  factory _ChatDisplayName.fromJson(Map<String, dynamic> json) => _$ChatDisplayNameFromJson(json);

@override final  String value;
@override final  DisplayNameSource source;

/// Create a copy of ChatDisplayName
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatDisplayNameCopyWith<_ChatDisplayName> get copyWith => __$ChatDisplayNameCopyWithImpl<_ChatDisplayName>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatDisplayNameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatDisplayName&&(identical(other.value, value) || other.value == value)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,source);

@override
String toString() {
  return 'ChatDisplayName(value: $value, source: $source)';
}


}

/// @nodoc
abstract mixin class _$ChatDisplayNameCopyWith<$Res> implements $ChatDisplayNameCopyWith<$Res> {
  factory _$ChatDisplayNameCopyWith(_ChatDisplayName value, $Res Function(_ChatDisplayName) _then) = __$ChatDisplayNameCopyWithImpl;
@override @useResult
$Res call({
 String value, DisplayNameSource source
});




}
/// @nodoc
class __$ChatDisplayNameCopyWithImpl<$Res>
    implements _$ChatDisplayNameCopyWith<$Res> {
  __$ChatDisplayNameCopyWithImpl(this._self, this._then);

  final _ChatDisplayName _self;
  final $Res Function(_ChatDisplayName) _then;

/// Create a copy of ChatDisplayName
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? source = null,}) {
  return _then(_ChatDisplayName(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DisplayNameSource,
  ));
}


}


/// @nodoc
mixin _$ChatParticipant {

 ContactId get contactId; HandleId get handleId; DateTime get joinedAt; DateTime? get leftAt; ChatRole get role;
/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatParticipantCopyWith<ChatParticipant> get copyWith => _$ChatParticipantCopyWithImpl<ChatParticipant>(this as ChatParticipant, _$identity);

  /// Serializes this ChatParticipant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatParticipant&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contactId,handleId,joinedAt,leftAt,role);

@override
String toString() {
  return 'ChatParticipant(contactId: $contactId, handleId: $handleId, joinedAt: $joinedAt, leftAt: $leftAt, role: $role)';
}


}

/// @nodoc
abstract mixin class $ChatParticipantCopyWith<$Res>  {
  factory $ChatParticipantCopyWith(ChatParticipant value, $Res Function(ChatParticipant) _then) = _$ChatParticipantCopyWithImpl;
@useResult
$Res call({
 ContactId contactId, HandleId handleId, DateTime joinedAt, DateTime? leftAt, ChatRole role
});


$ContactIdCopyWith<$Res> get contactId;$HandleIdCopyWith<$Res> get handleId;

}
/// @nodoc
class _$ChatParticipantCopyWithImpl<$Res>
    implements $ChatParticipantCopyWith<$Res> {
  _$ChatParticipantCopyWithImpl(this._self, this._then);

  final ChatParticipant _self;
  final $Res Function(ChatParticipant) _then;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contactId = null,Object? handleId = null,Object? joinedAt = null,Object? leftAt = freezed,Object? role = null,}) {
  return _then(_self.copyWith(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as ContactId,handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as HandleId,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ChatRole,
  ));
}
/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res> get contactId {
  
  return $ContactIdCopyWith<$Res>(_self.contactId, (value) {
    return _then(_self.copyWith(contactId: value));
  });
}/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandleIdCopyWith<$Res> get handleId {
  
  return $HandleIdCopyWith<$Res>(_self.handleId, (value) {
    return _then(_self.copyWith(handleId: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatParticipant].
extension ChatParticipantPatterns on ChatParticipant {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatParticipant value)  $default,){
final _that = this;
switch (_that) {
case _ChatParticipant():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactId contactId,  HandleId handleId,  DateTime joinedAt,  DateTime? leftAt,  ChatRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that.contactId,_that.handleId,_that.joinedAt,_that.leftAt,_that.role);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactId contactId,  HandleId handleId,  DateTime joinedAt,  DateTime? leftAt,  ChatRole role)  $default,) {final _that = this;
switch (_that) {
case _ChatParticipant():
return $default(_that.contactId,_that.handleId,_that.joinedAt,_that.leftAt,_that.role);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactId contactId,  HandleId handleId,  DateTime joinedAt,  DateTime? leftAt,  ChatRole role)?  $default,) {final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that.contactId,_that.handleId,_that.joinedAt,_that.leftAt,_that.role);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatParticipant implements ChatParticipant {
  const _ChatParticipant({required this.contactId, required this.handleId, required this.joinedAt, this.leftAt, this.role = ChatRole.member});
  factory _ChatParticipant.fromJson(Map<String, dynamic> json) => _$ChatParticipantFromJson(json);

@override final  ContactId contactId;
@override final  HandleId handleId;
@override final  DateTime joinedAt;
@override final  DateTime? leftAt;
@override@JsonKey() final  ChatRole role;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatParticipantCopyWith<_ChatParticipant> get copyWith => __$ChatParticipantCopyWithImpl<_ChatParticipant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatParticipant&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.leftAt, leftAt) || other.leftAt == leftAt)&&(identical(other.role, role) || other.role == role));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contactId,handleId,joinedAt,leftAt,role);

@override
String toString() {
  return 'ChatParticipant(contactId: $contactId, handleId: $handleId, joinedAt: $joinedAt, leftAt: $leftAt, role: $role)';
}


}

/// @nodoc
abstract mixin class _$ChatParticipantCopyWith<$Res> implements $ChatParticipantCopyWith<$Res> {
  factory _$ChatParticipantCopyWith(_ChatParticipant value, $Res Function(_ChatParticipant) _then) = __$ChatParticipantCopyWithImpl;
@override @useResult
$Res call({
 ContactId contactId, HandleId handleId, DateTime joinedAt, DateTime? leftAt, ChatRole role
});


@override $ContactIdCopyWith<$Res> get contactId;@override $HandleIdCopyWith<$Res> get handleId;

}
/// @nodoc
class __$ChatParticipantCopyWithImpl<$Res>
    implements _$ChatParticipantCopyWith<$Res> {
  __$ChatParticipantCopyWithImpl(this._self, this._then);

  final _ChatParticipant _self;
  final $Res Function(_ChatParticipant) _then;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contactId = null,Object? handleId = null,Object? joinedAt = null,Object? leftAt = freezed,Object? role = null,}) {
  return _then(_ChatParticipant(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as ContactId,handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as HandleId,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,leftAt: freezed == leftAt ? _self.leftAt : leftAt // ignore: cast_nullable_to_non_nullable
as DateTime?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ChatRole,
  ));
}

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res> get contactId {
  
  return $ContactIdCopyWith<$Res>(_self.contactId, (value) {
    return _then(_self.copyWith(contactId: value));
  });
}/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandleIdCopyWith<$Res> get handleId {
  
  return $HandleIdCopyWith<$Res>(_self.handleId, (value) {
    return _then(_self.copyWith(handleId: value));
  });
}
}


/// @nodoc
mixin _$ChatTimestamps {

 DateTime get createdAt; DateTime get lastModified; DateTime? get firstMessageAt; DateTime? get lastMessageAt;
/// Create a copy of ChatTimestamps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatTimestampsCopyWith<ChatTimestamps> get copyWith => _$ChatTimestampsCopyWithImpl<ChatTimestamps>(this as ChatTimestamps, _$identity);

  /// Serializes this ChatTimestamps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatTimestamps&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.firstMessageAt, firstMessageAt) || other.firstMessageAt == firstMessageAt)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,lastModified,firstMessageAt,lastMessageAt);

@override
String toString() {
  return 'ChatTimestamps(createdAt: $createdAt, lastModified: $lastModified, firstMessageAt: $firstMessageAt, lastMessageAt: $lastMessageAt)';
}


}

/// @nodoc
abstract mixin class $ChatTimestampsCopyWith<$Res>  {
  factory $ChatTimestampsCopyWith(ChatTimestamps value, $Res Function(ChatTimestamps) _then) = _$ChatTimestampsCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, DateTime lastModified, DateTime? firstMessageAt, DateTime? lastMessageAt
});




}
/// @nodoc
class _$ChatTimestampsCopyWithImpl<$Res>
    implements $ChatTimestampsCopyWith<$Res> {
  _$ChatTimestampsCopyWithImpl(this._self, this._then);

  final ChatTimestamps _self;
  final $Res Function(ChatTimestamps) _then;

/// Create a copy of ChatTimestamps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? lastModified = null,Object? firstMessageAt = freezed,Object? lastMessageAt = freezed,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,firstMessageAt: freezed == firstMessageAt ? _self.firstMessageAt : firstMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatTimestamps].
extension ChatTimestampsPatterns on ChatTimestamps {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatTimestamps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatTimestamps() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatTimestamps value)  $default,){
final _that = this;
switch (_that) {
case _ChatTimestamps():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatTimestamps value)?  $default,){
final _that = this;
switch (_that) {
case _ChatTimestamps() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime lastModified,  DateTime? firstMessageAt,  DateTime? lastMessageAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatTimestamps() when $default != null:
return $default(_that.createdAt,_that.lastModified,_that.firstMessageAt,_that.lastMessageAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime lastModified,  DateTime? firstMessageAt,  DateTime? lastMessageAt)  $default,) {final _that = this;
switch (_that) {
case _ChatTimestamps():
return $default(_that.createdAt,_that.lastModified,_that.firstMessageAt,_that.lastMessageAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime createdAt,  DateTime lastModified,  DateTime? firstMessageAt,  DateTime? lastMessageAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatTimestamps() when $default != null:
return $default(_that.createdAt,_that.lastModified,_that.firstMessageAt,_that.lastMessageAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatTimestamps implements ChatTimestamps {
  const _ChatTimestamps({required this.createdAt, required this.lastModified, this.firstMessageAt, this.lastMessageAt});
  factory _ChatTimestamps.fromJson(Map<String, dynamic> json) => _$ChatTimestampsFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime lastModified;
@override final  DateTime? firstMessageAt;
@override final  DateTime? lastMessageAt;

/// Create a copy of ChatTimestamps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatTimestampsCopyWith<_ChatTimestamps> get copyWith => __$ChatTimestampsCopyWithImpl<_ChatTimestamps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatTimestampsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatTimestamps&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.firstMessageAt, firstMessageAt) || other.firstMessageAt == firstMessageAt)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,lastModified,firstMessageAt,lastMessageAt);

@override
String toString() {
  return 'ChatTimestamps(createdAt: $createdAt, lastModified: $lastModified, firstMessageAt: $firstMessageAt, lastMessageAt: $lastMessageAt)';
}


}

/// @nodoc
abstract mixin class _$ChatTimestampsCopyWith<$Res> implements $ChatTimestampsCopyWith<$Res> {
  factory _$ChatTimestampsCopyWith(_ChatTimestamps value, $Res Function(_ChatTimestamps) _then) = __$ChatTimestampsCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime lastModified, DateTime? firstMessageAt, DateTime? lastMessageAt
});




}
/// @nodoc
class __$ChatTimestampsCopyWithImpl<$Res>
    implements _$ChatTimestampsCopyWith<$Res> {
  __$ChatTimestampsCopyWithImpl(this._self, this._then);

  final _ChatTimestamps _self;
  final $Res Function(_ChatTimestamps) _then;

/// Create a copy of ChatTimestamps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? lastModified = null,Object? firstMessageAt = freezed,Object? lastMessageAt = freezed,}) {
  return _then(_ChatTimestamps(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,firstMessageAt: freezed == firstMessageAt ? _self.firstMessageAt : firstMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChatStats {

 int get messageCount; int get unreadCount; int get attachmentCount;
/// Create a copy of ChatStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStatsCopyWith<ChatStats> get copyWith => _$ChatStatsCopyWithImpl<ChatStats>(this as ChatStats, _$identity);

  /// Serializes this ChatStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatStats&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.attachmentCount, attachmentCount) || other.attachmentCount == attachmentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageCount,unreadCount,attachmentCount);

@override
String toString() {
  return 'ChatStats(messageCount: $messageCount, unreadCount: $unreadCount, attachmentCount: $attachmentCount)';
}


}

/// @nodoc
abstract mixin class $ChatStatsCopyWith<$Res>  {
  factory $ChatStatsCopyWith(ChatStats value, $Res Function(ChatStats) _then) = _$ChatStatsCopyWithImpl;
@useResult
$Res call({
 int messageCount, int unreadCount, int attachmentCount
});




}
/// @nodoc
class _$ChatStatsCopyWithImpl<$Res>
    implements $ChatStatsCopyWith<$Res> {
  _$ChatStatsCopyWithImpl(this._self, this._then);

  final ChatStats _self;
  final $Res Function(ChatStats) _then;

/// Create a copy of ChatStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageCount = null,Object? unreadCount = null,Object? attachmentCount = null,}) {
  return _then(_self.copyWith(
messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,attachmentCount: null == attachmentCount ? _self.attachmentCount : attachmentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatStats].
extension ChatStatsPatterns on ChatStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatStats value)  $default,){
final _that = this;
switch (_that) {
case _ChatStats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatStats value)?  $default,){
final _that = this;
switch (_that) {
case _ChatStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int messageCount,  int unreadCount,  int attachmentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatStats() when $default != null:
return $default(_that.messageCount,_that.unreadCount,_that.attachmentCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int messageCount,  int unreadCount,  int attachmentCount)  $default,) {final _that = this;
switch (_that) {
case _ChatStats():
return $default(_that.messageCount,_that.unreadCount,_that.attachmentCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int messageCount,  int unreadCount,  int attachmentCount)?  $default,) {final _that = this;
switch (_that) {
case _ChatStats() when $default != null:
return $default(_that.messageCount,_that.unreadCount,_that.attachmentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatStats implements ChatStats {
  const _ChatStats({this.messageCount = 0, this.unreadCount = 0, this.attachmentCount = 0});
  factory _ChatStats.fromJson(Map<String, dynamic> json) => _$ChatStatsFromJson(json);

@override@JsonKey() final  int messageCount;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  int attachmentCount;

/// Create a copy of ChatStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatStatsCopyWith<_ChatStats> get copyWith => __$ChatStatsCopyWithImpl<_ChatStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatStats&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.attachmentCount, attachmentCount) || other.attachmentCount == attachmentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,messageCount,unreadCount,attachmentCount);

@override
String toString() {
  return 'ChatStats(messageCount: $messageCount, unreadCount: $unreadCount, attachmentCount: $attachmentCount)';
}


}

/// @nodoc
abstract mixin class _$ChatStatsCopyWith<$Res> implements $ChatStatsCopyWith<$Res> {
  factory _$ChatStatsCopyWith(_ChatStats value, $Res Function(_ChatStats) _then) = __$ChatStatsCopyWithImpl;
@override @useResult
$Res call({
 int messageCount, int unreadCount, int attachmentCount
});




}
/// @nodoc
class __$ChatStatsCopyWithImpl<$Res>
    implements _$ChatStatsCopyWith<$Res> {
  __$ChatStatsCopyWithImpl(this._self, this._then);

  final _ChatStats _self;
  final $Res Function(_ChatStats) _then;

/// Create a copy of ChatStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageCount = null,Object? unreadCount = null,Object? attachmentCount = null,}) {
  return _then(_ChatStats(
messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,attachmentCount: null == attachmentCount ? _self.attachmentCount : attachmentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ContactId {

 String get value;
/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactIdCopyWith<ContactId> get copyWith => _$ContactIdCopyWithImpl<ContactId>(this as ContactId, _$identity);

  /// Serializes this ContactId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ContactId(value: $value)';
}


}

/// @nodoc
abstract mixin class $ContactIdCopyWith<$Res>  {
  factory $ContactIdCopyWith(ContactId value, $Res Function(ContactId) _then) = _$ContactIdCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$ContactIdCopyWithImpl<$Res>
    implements $ContactIdCopyWith<$Res> {
  _$ContactIdCopyWithImpl(this._self, this._then);

  final ContactId _self;
  final $Res Function(ContactId) _then;

/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactId].
extension ContactIdPatterns on ContactId {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactId() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactId value)  $default,){
final _that = this;
switch (_that) {
case _ContactId():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactId value)?  $default,){
final _that = this;
switch (_that) {
case _ContactId() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactId() when $default != null:
return $default(_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value)  $default,) {final _that = this;
switch (_that) {
case _ContactId():
return $default(_that.value);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value)?  $default,) {final _that = this;
switch (_that) {
case _ContactId() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactId implements ContactId {
  const _ContactId(this.value);
  factory _ContactId.fromJson(Map<String, dynamic> json) => _$ContactIdFromJson(json);

@override final  String value;

/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactIdCopyWith<_ContactId> get copyWith => __$ContactIdCopyWithImpl<_ContactId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ContactId(value: $value)';
}


}

/// @nodoc
abstract mixin class _$ContactIdCopyWith<$Res> implements $ContactIdCopyWith<$Res> {
  factory _$ContactIdCopyWith(_ContactId value, $Res Function(_ContactId) _then) = __$ContactIdCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$ContactIdCopyWithImpl<$Res>
    implements _$ContactIdCopyWith<$Res> {
  __$ContactIdCopyWithImpl(this._self, this._then);

  final _ContactId _self;
  final $Res Function(_ContactId) _then;

/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_ContactId(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$HandleId {

 String get value;
/// Create a copy of HandleId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandleIdCopyWith<HandleId> get copyWith => _$HandleIdCopyWithImpl<HandleId>(this as HandleId, _$identity);

  /// Serializes this HandleId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'HandleId(value: $value)';
}


}

/// @nodoc
abstract mixin class $HandleIdCopyWith<$Res>  {
  factory $HandleIdCopyWith(HandleId value, $Res Function(HandleId) _then) = _$HandleIdCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$HandleIdCopyWithImpl<$Res>
    implements $HandleIdCopyWith<$Res> {
  _$HandleIdCopyWithImpl(this._self, this._then);

  final HandleId _self;
  final $Res Function(HandleId) _then;

/// Create a copy of HandleId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HandleId].
extension HandleIdPatterns on HandleId {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HandleId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandleId() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HandleId value)  $default,){
final _that = this;
switch (_that) {
case _HandleId():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HandleId value)?  $default,){
final _that = this;
switch (_that) {
case _HandleId() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandleId() when $default != null:
return $default(_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value)  $default,) {final _that = this;
switch (_that) {
case _HandleId():
return $default(_that.value);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value)?  $default,) {final _that = this;
switch (_that) {
case _HandleId() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HandleId implements HandleId {
  const _HandleId(this.value);
  factory _HandleId.fromJson(Map<String, dynamic> json) => _$HandleIdFromJson(json);

@override final  String value;

/// Create a copy of HandleId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandleIdCopyWith<_HandleId> get copyWith => __$HandleIdCopyWithImpl<_HandleId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HandleIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandleId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'HandleId(value: $value)';
}


}

/// @nodoc
abstract mixin class _$HandleIdCopyWith<$Res> implements $HandleIdCopyWith<$Res> {
  factory _$HandleIdCopyWith(_HandleId value, $Res Function(_HandleId) _then) = __$HandleIdCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$HandleIdCopyWithImpl<$Res>
    implements _$HandleIdCopyWith<$Res> {
  __$HandleIdCopyWithImpl(this._self, this._then);

  final _HandleId _self;
  final $Res Function(_HandleId) _then;

/// Create a copy of HandleId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_HandleId(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ImportMetadata {

 String get sourceSystem; int get sourceId; DateTime get importedAt; String? get sourceHash; int? get sourceVersion;
/// Create a copy of ImportMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportMetadataCopyWith<ImportMetadata> get copyWith => _$ImportMetadataCopyWithImpl<ImportMetadata>(this as ImportMetadata, _$identity);

  /// Serializes this ImportMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportMetadata&&(identical(other.sourceSystem, sourceSystem) || other.sourceSystem == sourceSystem)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.sourceHash, sourceHash) || other.sourceHash == sourceHash)&&(identical(other.sourceVersion, sourceVersion) || other.sourceVersion == sourceVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceSystem,sourceId,importedAt,sourceHash,sourceVersion);

@override
String toString() {
  return 'ImportMetadata(sourceSystem: $sourceSystem, sourceId: $sourceId, importedAt: $importedAt, sourceHash: $sourceHash, sourceVersion: $sourceVersion)';
}


}

/// @nodoc
abstract mixin class $ImportMetadataCopyWith<$Res>  {
  factory $ImportMetadataCopyWith(ImportMetadata value, $Res Function(ImportMetadata) _then) = _$ImportMetadataCopyWithImpl;
@useResult
$Res call({
 String sourceSystem, int sourceId, DateTime importedAt, String? sourceHash, int? sourceVersion
});




}
/// @nodoc
class _$ImportMetadataCopyWithImpl<$Res>
    implements $ImportMetadataCopyWith<$Res> {
  _$ImportMetadataCopyWithImpl(this._self, this._then);

  final ImportMetadata _self;
  final $Res Function(ImportMetadata) _then;

/// Create a copy of ImportMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceSystem = null,Object? sourceId = null,Object? importedAt = null,Object? sourceHash = freezed,Object? sourceVersion = freezed,}) {
  return _then(_self.copyWith(
sourceSystem: null == sourceSystem ? _self.sourceSystem : sourceSystem // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as int,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceHash: freezed == sourceHash ? _self.sourceHash : sourceHash // ignore: cast_nullable_to_non_nullable
as String?,sourceVersion: freezed == sourceVersion ? _self.sourceVersion : sourceVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportMetadata].
extension ImportMetadataPatterns on ImportMetadata {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportMetadata() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportMetadata value)  $default,){
final _that = this;
switch (_that) {
case _ImportMetadata():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _ImportMetadata() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceSystem,  int sourceId,  DateTime importedAt,  String? sourceHash,  int? sourceVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportMetadata() when $default != null:
return $default(_that.sourceSystem,_that.sourceId,_that.importedAt,_that.sourceHash,_that.sourceVersion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceSystem,  int sourceId,  DateTime importedAt,  String? sourceHash,  int? sourceVersion)  $default,) {final _that = this;
switch (_that) {
case _ImportMetadata():
return $default(_that.sourceSystem,_that.sourceId,_that.importedAt,_that.sourceHash,_that.sourceVersion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceSystem,  int sourceId,  DateTime importedAt,  String? sourceHash,  int? sourceVersion)?  $default,) {final _that = this;
switch (_that) {
case _ImportMetadata() when $default != null:
return $default(_that.sourceSystem,_that.sourceId,_that.importedAt,_that.sourceHash,_that.sourceVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportMetadata implements ImportMetadata {
  const _ImportMetadata({required this.sourceSystem, required this.sourceId, required this.importedAt, this.sourceHash, this.sourceVersion});
  factory _ImportMetadata.fromJson(Map<String, dynamic> json) => _$ImportMetadataFromJson(json);

@override final  String sourceSystem;
@override final  int sourceId;
@override final  DateTime importedAt;
@override final  String? sourceHash;
@override final  int? sourceVersion;

/// Create a copy of ImportMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportMetadataCopyWith<_ImportMetadata> get copyWith => __$ImportMetadataCopyWithImpl<_ImportMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportMetadata&&(identical(other.sourceSystem, sourceSystem) || other.sourceSystem == sourceSystem)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.sourceHash, sourceHash) || other.sourceHash == sourceHash)&&(identical(other.sourceVersion, sourceVersion) || other.sourceVersion == sourceVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceSystem,sourceId,importedAt,sourceHash,sourceVersion);

@override
String toString() {
  return 'ImportMetadata(sourceSystem: $sourceSystem, sourceId: $sourceId, importedAt: $importedAt, sourceHash: $sourceHash, sourceVersion: $sourceVersion)';
}


}

/// @nodoc
abstract mixin class _$ImportMetadataCopyWith<$Res> implements $ImportMetadataCopyWith<$Res> {
  factory _$ImportMetadataCopyWith(_ImportMetadata value, $Res Function(_ImportMetadata) _then) = __$ImportMetadataCopyWithImpl;
@override @useResult
$Res call({
 String sourceSystem, int sourceId, DateTime importedAt, String? sourceHash, int? sourceVersion
});




}
/// @nodoc
class __$ImportMetadataCopyWithImpl<$Res>
    implements _$ImportMetadataCopyWith<$Res> {
  __$ImportMetadataCopyWithImpl(this._self, this._then);

  final _ImportMetadata _self;
  final $Res Function(_ImportMetadata) _then;

/// Create a copy of ImportMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceSystem = null,Object? sourceId = null,Object? importedAt = null,Object? sourceHash = freezed,Object? sourceVersion = freezed,}) {
  return _then(_ImportMetadata(
sourceSystem: null == sourceSystem ? _self.sourceSystem : sourceSystem // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as int,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceHash: freezed == sourceHash ? _self.sourceHash : sourceHash // ignore: cast_nullable_to_non_nullable
as String?,sourceVersion: freezed == sourceVersion ? _self.sourceVersion : sourceVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
