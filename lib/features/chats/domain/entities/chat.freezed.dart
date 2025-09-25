// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Chat {

/// Stable identifier for the chat (e.g., canonicalized macOS chat.guid).
 ChatId get id;/// Unique set of participants (value objects). Enforced via @Assert above.
 List<ChatParticipant> get participants;/// Group title (if any). DMs typically leave this null.
 String? get title;/// Pointer to the newest visible message for list rendering.
 MessageId? get lastMessageId;/// Timestamp of the newest visible message.
 DateTime? get lastTimestamp;/// User preference flags (domain-level; device-specific as needed).
 bool get muted; bool get pinned;
/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatCopyWith<Chat> get copyWith => _$ChatCopyWithImpl<Chat>(this as Chat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Chat&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.title, title) || other.title == title)&&(identical(other.lastMessageId, lastMessageId) || other.lastMessageId == lastMessageId)&&(identical(other.lastTimestamp, lastTimestamp) || other.lastTimestamp == lastTimestamp)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.pinned, pinned) || other.pinned == pinned));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(participants),title,lastMessageId,lastTimestamp,muted,pinned);

@override
String toString() {
  return 'Chat(id: $id, participants: $participants, title: $title, lastMessageId: $lastMessageId, lastTimestamp: $lastTimestamp, muted: $muted, pinned: $pinned)';
}


}

/// @nodoc
abstract mixin class $ChatCopyWith<$Res>  {
  factory $ChatCopyWith(Chat value, $Res Function(Chat) _then) = _$ChatCopyWithImpl;
@useResult
$Res call({
 ChatId id, List<ChatParticipant> participants, String? title, MessageId? lastMessageId, DateTime? lastTimestamp, bool muted, bool pinned
});


$ChatIdCopyWith<$Res> get id;$MessageIdCopyWith<$Res>? get lastMessageId;

}
/// @nodoc
class _$ChatCopyWithImpl<$Res>
    implements $ChatCopyWith<$Res> {
  _$ChatCopyWithImpl(this._self, this._then);

  final Chat _self;
  final $Res Function(Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? participants = null,Object? title = freezed,Object? lastMessageId = freezed,Object? lastTimestamp = freezed,Object? muted = null,Object? pinned = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ChatId,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<ChatParticipant>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,lastMessageId: freezed == lastMessageId ? _self.lastMessageId : lastMessageId // ignore: cast_nullable_to_non_nullable
as MessageId?,lastTimestamp: freezed == lastTimestamp ? _self.lastTimestamp : lastTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,
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
$MessageIdCopyWith<$Res>? get lastMessageId {
    if (_self.lastMessageId == null) {
    return null;
  }

  return $MessageIdCopyWith<$Res>(_self.lastMessageId!, (value) {
    return _then(_self.copyWith(lastMessageId: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatId id,  List<ChatParticipant> participants,  String? title,  MessageId? lastMessageId,  DateTime? lastTimestamp,  bool muted,  bool pinned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that.id,_that.participants,_that.title,_that.lastMessageId,_that.lastTimestamp,_that.muted,_that.pinned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatId id,  List<ChatParticipant> participants,  String? title,  MessageId? lastMessageId,  DateTime? lastTimestamp,  bool muted,  bool pinned)  $default,) {final _that = this;
switch (_that) {
case _Chat():
return $default(_that.id,_that.participants,_that.title,_that.lastMessageId,_that.lastTimestamp,_that.muted,_that.pinned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatId id,  List<ChatParticipant> participants,  String? title,  MessageId? lastMessageId,  DateTime? lastTimestamp,  bool muted,  bool pinned)?  $default,) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that.id,_that.participants,_that.title,_that.lastMessageId,_that.lastTimestamp,_that.muted,_that.pinned);case _:
  return null;

}
}

}

/// @nodoc


class _Chat extends Chat {
  const _Chat({required this.id, final  List<ChatParticipant> participants = const <ChatParticipant>[], this.title, this.lastMessageId, this.lastTimestamp, this.muted = false, this.pinned = false}): assert(participants.map((p) => p.handleId).toSet().length == participants.length, 'participants must be unique by handleId'),_participants = participants,super._();
  

/// Stable identifier for the chat (e.g., canonicalized macOS chat.guid).
@override final  ChatId id;
/// Unique set of participants (value objects). Enforced via @Assert above.
 final  List<ChatParticipant> _participants;
/// Unique set of participants (value objects). Enforced via @Assert above.
@override@JsonKey() List<ChatParticipant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

/// Group title (if any). DMs typically leave this null.
@override final  String? title;
/// Pointer to the newest visible message for list rendering.
@override final  MessageId? lastMessageId;
/// Timestamp of the newest visible message.
@override final  DateTime? lastTimestamp;
/// User preference flags (domain-level; device-specific as needed).
@override@JsonKey() final  bool muted;
@override@JsonKey() final  bool pinned;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatCopyWith<_Chat> get copyWith => __$ChatCopyWithImpl<_Chat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Chat&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._participants, _participants)&&(identical(other.title, title) || other.title == title)&&(identical(other.lastMessageId, lastMessageId) || other.lastMessageId == lastMessageId)&&(identical(other.lastTimestamp, lastTimestamp) || other.lastTimestamp == lastTimestamp)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.pinned, pinned) || other.pinned == pinned));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_participants),title,lastMessageId,lastTimestamp,muted,pinned);

@override
String toString() {
  return 'Chat(id: $id, participants: $participants, title: $title, lastMessageId: $lastMessageId, lastTimestamp: $lastTimestamp, muted: $muted, pinned: $pinned)';
}


}

/// @nodoc
abstract mixin class _$ChatCopyWith<$Res> implements $ChatCopyWith<$Res> {
  factory _$ChatCopyWith(_Chat value, $Res Function(_Chat) _then) = __$ChatCopyWithImpl;
@override @useResult
$Res call({
 ChatId id, List<ChatParticipant> participants, String? title, MessageId? lastMessageId, DateTime? lastTimestamp, bool muted, bool pinned
});


@override $ChatIdCopyWith<$Res> get id;@override $MessageIdCopyWith<$Res>? get lastMessageId;

}
/// @nodoc
class __$ChatCopyWithImpl<$Res>
    implements _$ChatCopyWith<$Res> {
  __$ChatCopyWithImpl(this._self, this._then);

  final _Chat _self;
  final $Res Function(_Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? participants = null,Object? title = freezed,Object? lastMessageId = freezed,Object? lastTimestamp = freezed,Object? muted = null,Object? pinned = null,}) {
  return _then(_Chat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ChatId,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<ChatParticipant>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,lastMessageId: freezed == lastMessageId ? _self.lastMessageId : lastMessageId // ignore: cast_nullable_to_non_nullable
as MessageId?,lastTimestamp: freezed == lastTimestamp ? _self.lastTimestamp : lastTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,
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
$MessageIdCopyWith<$Res>? get lastMessageId {
    if (_self.lastMessageId == null) {
    return null;
  }

  return $MessageIdCopyWith<$Res>(_self.lastMessageId!, (value) {
    return _then(_self.copyWith(lastMessageId: value));
  });
}
}

// dart format on
