// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Message {

/// Stable identifier for the message (macOS `message.guid` or ROWID string).
 MessageId get id;/// Foreign key reference to the owning Chat aggregate.
 ChatId get chatId;/// The handleId of the sender (must correspond to a Chat participant).
 String get senderHandleId;/// Time the message was sent.
 DateTime get sentAt;/// Decoded message text (from attributedBody). Immutable post-ingest.
 String get text;/// Whether this message originated from the local user.
 bool get isFromMe;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.senderHandleId, senderHandleId) || other.senderHandleId == senderHandleId)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.text, text) || other.text == text)&&(identical(other.isFromMe, isFromMe) || other.isFromMe == isFromMe));
}


@override
int get hashCode => Object.hash(runtimeType,id,chatId,senderHandleId,sentAt,text,isFromMe);

@override
String toString() {
  return 'Message(id: $id, chatId: $chatId, senderHandleId: $senderHandleId, sentAt: $sentAt, text: $text, isFromMe: $isFromMe)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 MessageId id, ChatId chatId, String senderHandleId, DateTime sentAt, String text, bool isFromMe
});


$MessageIdCopyWith<$Res> get id;$ChatIdCopyWith<$Res> get chatId;

}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chatId = null,Object? senderHandleId = null,Object? sentAt = null,Object? text = null,Object? isFromMe = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as MessageId,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as ChatId,senderHandleId: null == senderHandleId ? _self.senderHandleId : senderHandleId // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isFromMe: null == isFromMe ? _self.isFromMe : isFromMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageIdCopyWith<$Res> get id {
  
  return $MessageIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatIdCopyWith<$Res> get chatId {
  
  return $ChatIdCopyWith<$Res>(_self.chatId, (value) {
    return _then(_self.copyWith(chatId: value));
  });
}
}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MessageId id,  ChatId chatId,  String senderHandleId,  DateTime sentAt,  String text,  bool isFromMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.chatId,_that.senderHandleId,_that.sentAt,_that.text,_that.isFromMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MessageId id,  ChatId chatId,  String senderHandleId,  DateTime sentAt,  String text,  bool isFromMe)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.chatId,_that.senderHandleId,_that.sentAt,_that.text,_that.isFromMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MessageId id,  ChatId chatId,  String senderHandleId,  DateTime sentAt,  String text,  bool isFromMe)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.chatId,_that.senderHandleId,_that.sentAt,_that.text,_that.isFromMe);case _:
  return null;

}
}

}

/// @nodoc


class _Message extends Message {
  const _Message({required this.id, required this.chatId, required this.senderHandleId, required this.sentAt, required this.text, required this.isFromMe}): assert(senderHandleId != '', 'senderHandleId cannot be empty'),super._();
  

/// Stable identifier for the message (macOS `message.guid` or ROWID string).
@override final  MessageId id;
/// Foreign key reference to the owning Chat aggregate.
@override final  ChatId chatId;
/// The handleId of the sender (must correspond to a Chat participant).
@override final  String senderHandleId;
/// Time the message was sent.
@override final  DateTime sentAt;
/// Decoded message text (from attributedBody). Immutable post-ingest.
@override final  String text;
/// Whether this message originated from the local user.
@override final  bool isFromMe;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.senderHandleId, senderHandleId) || other.senderHandleId == senderHandleId)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.text, text) || other.text == text)&&(identical(other.isFromMe, isFromMe) || other.isFromMe == isFromMe));
}


@override
int get hashCode => Object.hash(runtimeType,id,chatId,senderHandleId,sentAt,text,isFromMe);

@override
String toString() {
  return 'Message(id: $id, chatId: $chatId, senderHandleId: $senderHandleId, sentAt: $sentAt, text: $text, isFromMe: $isFromMe)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 MessageId id, ChatId chatId, String senderHandleId, DateTime sentAt, String text, bool isFromMe
});


@override $MessageIdCopyWith<$Res> get id;@override $ChatIdCopyWith<$Res> get chatId;

}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chatId = null,Object? senderHandleId = null,Object? sentAt = null,Object? text = null,Object? isFromMe = null,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as MessageId,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as ChatId,senderHandleId: null == senderHandleId ? _self.senderHandleId : senderHandleId // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isFromMe: null == isFromMe ? _self.isFromMe : isFromMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageIdCopyWith<$Res> get id {
  
  return $MessageIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatIdCopyWith<$Res> get chatId {
  
  return $ChatIdCopyWith<$Res>(_self.chatId, (value) {
    return _then(_self.copyWith(chatId: value));
  });
}
}

// dart format on
