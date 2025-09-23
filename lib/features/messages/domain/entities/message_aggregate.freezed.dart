// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_aggregate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Message {

 MessageId get id; MessageContent get content; MessageSender get sender; MessageTimestamp get timestamp; MessageDirection get direction; MessageStatus get status; List<MessageAttachment> get attachments; MessageReply? get replyTo; MessageEditing? get editing; ImportMetadata? get importMetadata;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.replyTo, replyTo) || other.replyTo == replyTo)&&(identical(other.editing, editing) || other.editing == editing)&&(identical(other.importMetadata, importMetadata) || other.importMetadata == importMetadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,sender,timestamp,direction,status,const DeepCollectionEquality().hash(attachments),replyTo,editing,importMetadata);

@override
String toString() {
  return 'Message(id: $id, content: $content, sender: $sender, timestamp: $timestamp, direction: $direction, status: $status, attachments: $attachments, replyTo: $replyTo, editing: $editing, importMetadata: $importMetadata)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 MessageId id, MessageContent content, MessageSender sender, MessageTimestamp timestamp, MessageDirection direction, MessageStatus status, List<MessageAttachment> attachments, MessageReply? replyTo, MessageEditing? editing, ImportMetadata? importMetadata
});


$MessageIdCopyWith<$Res> get id;$MessageContentCopyWith<$Res> get content;$MessageSenderCopyWith<$Res> get sender;$MessageTimestampCopyWith<$Res> get timestamp;$MessageStatusCopyWith<$Res> get status;$MessageReplyCopyWith<$Res>? get replyTo;$MessageEditingCopyWith<$Res>? get editing;$ImportMetadataCopyWith<$Res>? get importMetadata;

}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? sender = null,Object? timestamp = null,Object? direction = null,Object? status = null,Object? attachments = null,Object? replyTo = freezed,Object? editing = freezed,Object? importMetadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as MessageId,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as MessageContent,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as MessageTimestamp,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as MessageDirection,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<MessageAttachment>,replyTo: freezed == replyTo ? _self.replyTo : replyTo // ignore: cast_nullable_to_non_nullable
as MessageReply?,editing: freezed == editing ? _self.editing : editing // ignore: cast_nullable_to_non_nullable
as MessageEditing?,importMetadata: freezed == importMetadata ? _self.importMetadata : importMetadata // ignore: cast_nullable_to_non_nullable
as ImportMetadata?,
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
$MessageContentCopyWith<$Res> get content {
  
  return $MessageContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<$Res> get sender {
  
  return $MessageSenderCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageTimestampCopyWith<$Res> get timestamp {
  
  return $MessageTimestampCopyWith<$Res>(_self.timestamp, (value) {
    return _then(_self.copyWith(timestamp: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageStatusCopyWith<$Res> get status {
  
  return $MessageStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageReplyCopyWith<$Res>? get replyTo {
    if (_self.replyTo == null) {
    return null;
  }

  return $MessageReplyCopyWith<$Res>(_self.replyTo!, (value) {
    return _then(_self.copyWith(replyTo: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageEditingCopyWith<$Res>? get editing {
    if (_self.editing == null) {
    return null;
  }

  return $MessageEditingCopyWith<$Res>(_self.editing!, (value) {
    return _then(_self.copyWith(editing: value));
  });
}/// Create a copy of Message
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MessageId id,  MessageContent content,  MessageSender sender,  MessageTimestamp timestamp,  MessageDirection direction,  MessageStatus status,  List<MessageAttachment> attachments,  MessageReply? replyTo,  MessageEditing? editing,  ImportMetadata? importMetadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.content,_that.sender,_that.timestamp,_that.direction,_that.status,_that.attachments,_that.replyTo,_that.editing,_that.importMetadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MessageId id,  MessageContent content,  MessageSender sender,  MessageTimestamp timestamp,  MessageDirection direction,  MessageStatus status,  List<MessageAttachment> attachments,  MessageReply? replyTo,  MessageEditing? editing,  ImportMetadata? importMetadata)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.content,_that.sender,_that.timestamp,_that.direction,_that.status,_that.attachments,_that.replyTo,_that.editing,_that.importMetadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MessageId id,  MessageContent content,  MessageSender sender,  MessageTimestamp timestamp,  MessageDirection direction,  MessageStatus status,  List<MessageAttachment> attachments,  MessageReply? replyTo,  MessageEditing? editing,  ImportMetadata? importMetadata)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.content,_that.sender,_that.timestamp,_that.direction,_that.status,_that.attachments,_that.replyTo,_that.editing,_that.importMetadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message extends Message {
  const _Message({required this.id, required this.content, required this.sender, required this.timestamp, required this.direction, required this.status, final  List<MessageAttachment> attachments = const [], this.replyTo, this.editing, this.importMetadata}): _attachments = attachments,super._();
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override final  MessageId id;
@override final  MessageContent content;
@override final  MessageSender sender;
@override final  MessageTimestamp timestamp;
@override final  MessageDirection direction;
@override final  MessageStatus status;
 final  List<MessageAttachment> _attachments;
@override@JsonKey() List<MessageAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  MessageReply? replyTo;
@override final  MessageEditing? editing;
@override final  ImportMetadata? importMetadata;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.replyTo, replyTo) || other.replyTo == replyTo)&&(identical(other.editing, editing) || other.editing == editing)&&(identical(other.importMetadata, importMetadata) || other.importMetadata == importMetadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,sender,timestamp,direction,status,const DeepCollectionEquality().hash(_attachments),replyTo,editing,importMetadata);

@override
String toString() {
  return 'Message(id: $id, content: $content, sender: $sender, timestamp: $timestamp, direction: $direction, status: $status, attachments: $attachments, replyTo: $replyTo, editing: $editing, importMetadata: $importMetadata)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 MessageId id, MessageContent content, MessageSender sender, MessageTimestamp timestamp, MessageDirection direction, MessageStatus status, List<MessageAttachment> attachments, MessageReply? replyTo, MessageEditing? editing, ImportMetadata? importMetadata
});


@override $MessageIdCopyWith<$Res> get id;@override $MessageContentCopyWith<$Res> get content;@override $MessageSenderCopyWith<$Res> get sender;@override $MessageTimestampCopyWith<$Res> get timestamp;@override $MessageStatusCopyWith<$Res> get status;@override $MessageReplyCopyWith<$Res>? get replyTo;@override $MessageEditingCopyWith<$Res>? get editing;@override $ImportMetadataCopyWith<$Res>? get importMetadata;

}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? sender = null,Object? timestamp = null,Object? direction = null,Object? status = null,Object? attachments = null,Object? replyTo = freezed,Object? editing = freezed,Object? importMetadata = freezed,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as MessageId,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as MessageContent,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as MessageTimestamp,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as MessageDirection,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<MessageAttachment>,replyTo: freezed == replyTo ? _self.replyTo : replyTo // ignore: cast_nullable_to_non_nullable
as MessageReply?,editing: freezed == editing ? _self.editing : editing // ignore: cast_nullable_to_non_nullable
as MessageEditing?,importMetadata: freezed == importMetadata ? _self.importMetadata : importMetadata // ignore: cast_nullable_to_non_nullable
as ImportMetadata?,
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
$MessageContentCopyWith<$Res> get content {
  
  return $MessageContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<$Res> get sender {
  
  return $MessageSenderCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageTimestampCopyWith<$Res> get timestamp {
  
  return $MessageTimestampCopyWith<$Res>(_self.timestamp, (value) {
    return _then(_self.copyWith(timestamp: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageStatusCopyWith<$Res> get status {
  
  return $MessageStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageReplyCopyWith<$Res>? get replyTo {
    if (_self.replyTo == null) {
    return null;
  }

  return $MessageReplyCopyWith<$Res>(_self.replyTo!, (value) {
    return _then(_self.copyWith(replyTo: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageEditingCopyWith<$Res>? get editing {
    if (_self.editing == null) {
    return null;
  }

  return $MessageEditingCopyWith<$Res>(_self.editing!, (value) {
    return _then(_self.copyWith(editing: value));
  });
}/// Create a copy of Message
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
mixin _$MessageId {

 String get value;
/// Create a copy of MessageId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageIdCopyWith<MessageId> get copyWith => _$MessageIdCopyWithImpl<MessageId>(this as MessageId, _$identity);

  /// Serializes this MessageId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'MessageId(value: $value)';
}


}

/// @nodoc
abstract mixin class $MessageIdCopyWith<$Res>  {
  factory $MessageIdCopyWith(MessageId value, $Res Function(MessageId) _then) = _$MessageIdCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$MessageIdCopyWithImpl<$Res>
    implements $MessageIdCopyWith<$Res> {
  _$MessageIdCopyWithImpl(this._self, this._then);

  final MessageId _self;
  final $Res Function(MessageId) _then;

/// Create a copy of MessageId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageId].
extension MessageIdPatterns on MessageId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageId value)  $default,){
final _that = this;
switch (_that) {
case _MessageId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageId value)?  $default,){
final _that = this;
switch (_that) {
case _MessageId() when $default != null:
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
case _MessageId() when $default != null:
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
case _MessageId():
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
case _MessageId() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageId implements MessageId {
  const _MessageId(this.value);
  factory _MessageId.fromJson(Map<String, dynamic> json) => _$MessageIdFromJson(json);

@override final  String value;

/// Create a copy of MessageId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageIdCopyWith<_MessageId> get copyWith => __$MessageIdCopyWithImpl<_MessageId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'MessageId(value: $value)';
}


}

/// @nodoc
abstract mixin class _$MessageIdCopyWith<$Res> implements $MessageIdCopyWith<$Res> {
  factory _$MessageIdCopyWith(_MessageId value, $Res Function(_MessageId) _then) = __$MessageIdCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$MessageIdCopyWithImpl<$Res>
    implements _$MessageIdCopyWith<$Res> {
  __$MessageIdCopyWithImpl(this._self, this._then);

  final _MessageId _self;
  final $Res Function(_MessageId) _then;

/// Create a copy of MessageId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_MessageId(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MessageContent {

 String? get plainText; String? get richText; MessageContentType? get contentType;
/// Create a copy of MessageContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageContentCopyWith<MessageContent> get copyWith => _$MessageContentCopyWithImpl<MessageContent>(this as MessageContent, _$identity);

  /// Serializes this MessageContent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageContent&&(identical(other.plainText, plainText) || other.plainText == plainText)&&(identical(other.richText, richText) || other.richText == richText)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plainText,richText,contentType);

@override
String toString() {
  return 'MessageContent(plainText: $plainText, richText: $richText, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $MessageContentCopyWith<$Res>  {
  factory $MessageContentCopyWith(MessageContent value, $Res Function(MessageContent) _then) = _$MessageContentCopyWithImpl;
@useResult
$Res call({
 String? plainText, String? richText, MessageContentType? contentType
});




}
/// @nodoc
class _$MessageContentCopyWithImpl<$Res>
    implements $MessageContentCopyWith<$Res> {
  _$MessageContentCopyWithImpl(this._self, this._then);

  final MessageContent _self;
  final $Res Function(MessageContent) _then;

/// Create a copy of MessageContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plainText = freezed,Object? richText = freezed,Object? contentType = freezed,}) {
  return _then(_self.copyWith(
plainText: freezed == plainText ? _self.plainText : plainText // ignore: cast_nullable_to_non_nullable
as String?,richText: freezed == richText ? _self.richText : richText // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as MessageContentType?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageContent].
extension MessageContentPatterns on MessageContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageContent value)  $default,){
final _that = this;
switch (_that) {
case _MessageContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageContent value)?  $default,){
final _that = this;
switch (_that) {
case _MessageContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? plainText,  String? richText,  MessageContentType? contentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageContent() when $default != null:
return $default(_that.plainText,_that.richText,_that.contentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? plainText,  String? richText,  MessageContentType? contentType)  $default,) {final _that = this;
switch (_that) {
case _MessageContent():
return $default(_that.plainText,_that.richText,_that.contentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? plainText,  String? richText,  MessageContentType? contentType)?  $default,) {final _that = this;
switch (_that) {
case _MessageContent() when $default != null:
return $default(_that.plainText,_that.richText,_that.contentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageContent extends MessageContent {
  const _MessageContent({this.plainText, this.richText, this.contentType}): super._();
  factory _MessageContent.fromJson(Map<String, dynamic> json) => _$MessageContentFromJson(json);

@override final  String? plainText;
@override final  String? richText;
@override final  MessageContentType? contentType;

/// Create a copy of MessageContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageContentCopyWith<_MessageContent> get copyWith => __$MessageContentCopyWithImpl<_MessageContent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageContent&&(identical(other.plainText, plainText) || other.plainText == plainText)&&(identical(other.richText, richText) || other.richText == richText)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plainText,richText,contentType);

@override
String toString() {
  return 'MessageContent(plainText: $plainText, richText: $richText, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$MessageContentCopyWith<$Res> implements $MessageContentCopyWith<$Res> {
  factory _$MessageContentCopyWith(_MessageContent value, $Res Function(_MessageContent) _then) = __$MessageContentCopyWithImpl;
@override @useResult
$Res call({
 String? plainText, String? richText, MessageContentType? contentType
});




}
/// @nodoc
class __$MessageContentCopyWithImpl<$Res>
    implements _$MessageContentCopyWith<$Res> {
  __$MessageContentCopyWithImpl(this._self, this._then);

  final _MessageContent _self;
  final $Res Function(_MessageContent) _then;

/// Create a copy of MessageContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plainText = freezed,Object? richText = freezed,Object? contentType = freezed,}) {
  return _then(_MessageContent(
plainText: freezed == plainText ? _self.plainText : plainText // ignore: cast_nullable_to_non_nullable
as String?,richText: freezed == richText ? _self.richText : richText // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as MessageContentType?,
  ));
}


}


/// @nodoc
mixin _$MessageSender {

 ContactId? get contactId; HandleId get handleId; String? get displayName;
/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<MessageSender> get copyWith => _$MessageSenderCopyWithImpl<MessageSender>(this as MessageSender, _$identity);

  /// Serializes this MessageSender to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSender&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contactId,handleId,displayName);

@override
String toString() {
  return 'MessageSender(contactId: $contactId, handleId: $handleId, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $MessageSenderCopyWith<$Res>  {
  factory $MessageSenderCopyWith(MessageSender value, $Res Function(MessageSender) _then) = _$MessageSenderCopyWithImpl;
@useResult
$Res call({
 ContactId? contactId, HandleId handleId, String? displayName
});


$ContactIdCopyWith<$Res>? get contactId;$HandleIdCopyWith<$Res> get handleId;

}
/// @nodoc
class _$MessageSenderCopyWithImpl<$Res>
    implements $MessageSenderCopyWith<$Res> {
  _$MessageSenderCopyWithImpl(this._self, this._then);

  final MessageSender _self;
  final $Res Function(MessageSender) _then;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contactId = freezed,Object? handleId = null,Object? displayName = freezed,}) {
  return _then(_self.copyWith(
contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as ContactId?,handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as HandleId,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res>? get contactId {
    if (_self.contactId == null) {
    return null;
  }

  return $ContactIdCopyWith<$Res>(_self.contactId!, (value) {
    return _then(_self.copyWith(contactId: value));
  });
}/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandleIdCopyWith<$Res> get handleId {
  
  return $HandleIdCopyWith<$Res>(_self.handleId, (value) {
    return _then(_self.copyWith(handleId: value));
  });
}
}


/// Adds pattern-matching-related methods to [MessageSender].
extension MessageSenderPatterns on MessageSender {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageSender value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageSender value)  $default,){
final _that = this;
switch (_that) {
case _MessageSender():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageSender value)?  $default,){
final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactId? contactId,  HandleId handleId,  String? displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that.contactId,_that.handleId,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactId? contactId,  HandleId handleId,  String? displayName)  $default,) {final _that = this;
switch (_that) {
case _MessageSender():
return $default(_that.contactId,_that.handleId,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactId? contactId,  HandleId handleId,  String? displayName)?  $default,) {final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that.contactId,_that.handleId,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageSender implements MessageSender {
  const _MessageSender({this.contactId, required this.handleId, this.displayName});
  factory _MessageSender.fromJson(Map<String, dynamic> json) => _$MessageSenderFromJson(json);

@override final  ContactId? contactId;
@override final  HandleId handleId;
@override final  String? displayName;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSenderCopyWith<_MessageSender> get copyWith => __$MessageSenderCopyWithImpl<_MessageSender>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageSenderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSender&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contactId,handleId,displayName);

@override
String toString() {
  return 'MessageSender(contactId: $contactId, handleId: $handleId, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$MessageSenderCopyWith<$Res> implements $MessageSenderCopyWith<$Res> {
  factory _$MessageSenderCopyWith(_MessageSender value, $Res Function(_MessageSender) _then) = __$MessageSenderCopyWithImpl;
@override @useResult
$Res call({
 ContactId? contactId, HandleId handleId, String? displayName
});


@override $ContactIdCopyWith<$Res>? get contactId;@override $HandleIdCopyWith<$Res> get handleId;

}
/// @nodoc
class __$MessageSenderCopyWithImpl<$Res>
    implements _$MessageSenderCopyWith<$Res> {
  __$MessageSenderCopyWithImpl(this._self, this._then);

  final _MessageSender _self;
  final $Res Function(_MessageSender) _then;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contactId = freezed,Object? handleId = null,Object? displayName = freezed,}) {
  return _then(_MessageSender(
contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as ContactId?,handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as HandleId,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res>? get contactId {
    if (_self.contactId == null) {
    return null;
  }

  return $ContactIdCopyWith<$Res>(_self.contactId!, (value) {
    return _then(_self.copyWith(contactId: value));
  });
}/// Create a copy of MessageSender
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
mixin _$MessageTimestamp {

 DateTime get value; TimestampPrecision? get precision;
/// Create a copy of MessageTimestamp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageTimestampCopyWith<MessageTimestamp> get copyWith => _$MessageTimestampCopyWithImpl<MessageTimestamp>(this as MessageTimestamp, _$identity);

  /// Serializes this MessageTimestamp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageTimestamp&&(identical(other.value, value) || other.value == value)&&(identical(other.precision, precision) || other.precision == precision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,precision);

@override
String toString() {
  return 'MessageTimestamp(value: $value, precision: $precision)';
}


}

/// @nodoc
abstract mixin class $MessageTimestampCopyWith<$Res>  {
  factory $MessageTimestampCopyWith(MessageTimestamp value, $Res Function(MessageTimestamp) _then) = _$MessageTimestampCopyWithImpl;
@useResult
$Res call({
 DateTime value, TimestampPrecision? precision
});




}
/// @nodoc
class _$MessageTimestampCopyWithImpl<$Res>
    implements $MessageTimestampCopyWith<$Res> {
  _$MessageTimestampCopyWithImpl(this._self, this._then);

  final MessageTimestamp _self;
  final $Res Function(MessageTimestamp) _then;

/// Create a copy of MessageTimestamp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? precision = freezed,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as DateTime,precision: freezed == precision ? _self.precision : precision // ignore: cast_nullable_to_non_nullable
as TimestampPrecision?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageTimestamp].
extension MessageTimestampPatterns on MessageTimestamp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageTimestamp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageTimestamp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageTimestamp value)  $default,){
final _that = this;
switch (_that) {
case _MessageTimestamp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageTimestamp value)?  $default,){
final _that = this;
switch (_that) {
case _MessageTimestamp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime value,  TimestampPrecision? precision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageTimestamp() when $default != null:
return $default(_that.value,_that.precision);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime value,  TimestampPrecision? precision)  $default,) {final _that = this;
switch (_that) {
case _MessageTimestamp():
return $default(_that.value,_that.precision);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime value,  TimestampPrecision? precision)?  $default,) {final _that = this;
switch (_that) {
case _MessageTimestamp() when $default != null:
return $default(_that.value,_that.precision);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageTimestamp extends MessageTimestamp {
  const _MessageTimestamp({required this.value, this.precision}): super._();
  factory _MessageTimestamp.fromJson(Map<String, dynamic> json) => _$MessageTimestampFromJson(json);

@override final  DateTime value;
@override final  TimestampPrecision? precision;

/// Create a copy of MessageTimestamp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageTimestampCopyWith<_MessageTimestamp> get copyWith => __$MessageTimestampCopyWithImpl<_MessageTimestamp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageTimestampToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageTimestamp&&(identical(other.value, value) || other.value == value)&&(identical(other.precision, precision) || other.precision == precision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,precision);

@override
String toString() {
  return 'MessageTimestamp(value: $value, precision: $precision)';
}


}

/// @nodoc
abstract mixin class _$MessageTimestampCopyWith<$Res> implements $MessageTimestampCopyWith<$Res> {
  factory _$MessageTimestampCopyWith(_MessageTimestamp value, $Res Function(_MessageTimestamp) _then) = __$MessageTimestampCopyWithImpl;
@override @useResult
$Res call({
 DateTime value, TimestampPrecision? precision
});




}
/// @nodoc
class __$MessageTimestampCopyWithImpl<$Res>
    implements _$MessageTimestampCopyWith<$Res> {
  __$MessageTimestampCopyWithImpl(this._self, this._then);

  final _MessageTimestamp _self;
  final $Res Function(_MessageTimestamp) _then;

/// Create a copy of MessageTimestamp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? precision = freezed,}) {
  return _then(_MessageTimestamp(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as DateTime,precision: freezed == precision ? _self.precision : precision // ignore: cast_nullable_to_non_nullable
as TimestampPrecision?,
  ));
}


}


/// @nodoc
mixin _$MessageStatus {

 DeliveryStatus get delivery; ReadStatus get read; DateTime? get deliveredAt; DateTime? get readAt;
/// Create a copy of MessageStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageStatusCopyWith<MessageStatus> get copyWith => _$MessageStatusCopyWithImpl<MessageStatus>(this as MessageStatus, _$identity);

  /// Serializes this MessageStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageStatus&&(identical(other.delivery, delivery) || other.delivery == delivery)&&(identical(other.read, read) || other.read == read)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.readAt, readAt) || other.readAt == readAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,delivery,read,deliveredAt,readAt);

@override
String toString() {
  return 'MessageStatus(delivery: $delivery, read: $read, deliveredAt: $deliveredAt, readAt: $readAt)';
}


}

/// @nodoc
abstract mixin class $MessageStatusCopyWith<$Res>  {
  factory $MessageStatusCopyWith(MessageStatus value, $Res Function(MessageStatus) _then) = _$MessageStatusCopyWithImpl;
@useResult
$Res call({
 DeliveryStatus delivery, ReadStatus read, DateTime? deliveredAt, DateTime? readAt
});




}
/// @nodoc
class _$MessageStatusCopyWithImpl<$Res>
    implements $MessageStatusCopyWith<$Res> {
  _$MessageStatusCopyWithImpl(this._self, this._then);

  final MessageStatus _self;
  final $Res Function(MessageStatus) _then;

/// Create a copy of MessageStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? delivery = null,Object? read = null,Object? deliveredAt = freezed,Object? readAt = freezed,}) {
  return _then(_self.copyWith(
delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as ReadStatus,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageStatus].
extension MessageStatusPatterns on MessageStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageStatus value)  $default,){
final _that = this;
switch (_that) {
case _MessageStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageStatus value)?  $default,){
final _that = this;
switch (_that) {
case _MessageStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeliveryStatus delivery,  ReadStatus read,  DateTime? deliveredAt,  DateTime? readAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageStatus() when $default != null:
return $default(_that.delivery,_that.read,_that.deliveredAt,_that.readAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeliveryStatus delivery,  ReadStatus read,  DateTime? deliveredAt,  DateTime? readAt)  $default,) {final _that = this;
switch (_that) {
case _MessageStatus():
return $default(_that.delivery,_that.read,_that.deliveredAt,_that.readAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeliveryStatus delivery,  ReadStatus read,  DateTime? deliveredAt,  DateTime? readAt)?  $default,) {final _that = this;
switch (_that) {
case _MessageStatus() when $default != null:
return $default(_that.delivery,_that.read,_that.deliveredAt,_that.readAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageStatus implements MessageStatus {
  const _MessageStatus({this.delivery = DeliveryStatus.unknown, this.read = ReadStatus.unknown, this.deliveredAt, this.readAt});
  factory _MessageStatus.fromJson(Map<String, dynamic> json) => _$MessageStatusFromJson(json);

@override@JsonKey() final  DeliveryStatus delivery;
@override@JsonKey() final  ReadStatus read;
@override final  DateTime? deliveredAt;
@override final  DateTime? readAt;

/// Create a copy of MessageStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageStatusCopyWith<_MessageStatus> get copyWith => __$MessageStatusCopyWithImpl<_MessageStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageStatus&&(identical(other.delivery, delivery) || other.delivery == delivery)&&(identical(other.read, read) || other.read == read)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.readAt, readAt) || other.readAt == readAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,delivery,read,deliveredAt,readAt);

@override
String toString() {
  return 'MessageStatus(delivery: $delivery, read: $read, deliveredAt: $deliveredAt, readAt: $readAt)';
}


}

/// @nodoc
abstract mixin class _$MessageStatusCopyWith<$Res> implements $MessageStatusCopyWith<$Res> {
  factory _$MessageStatusCopyWith(_MessageStatus value, $Res Function(_MessageStatus) _then) = __$MessageStatusCopyWithImpl;
@override @useResult
$Res call({
 DeliveryStatus delivery, ReadStatus read, DateTime? deliveredAt, DateTime? readAt
});




}
/// @nodoc
class __$MessageStatusCopyWithImpl<$Res>
    implements _$MessageStatusCopyWith<$Res> {
  __$MessageStatusCopyWithImpl(this._self, this._then);

  final _MessageStatus _self;
  final $Res Function(_MessageStatus) _then;

/// Create a copy of MessageStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? delivery = null,Object? read = null,Object? deliveredAt = freezed,Object? readAt = freezed,}) {
  return _then(_MessageStatus(
delivery: null == delivery ? _self.delivery : delivery // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as ReadStatus,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MessageAttachment {

 AttachmentId get id; String get filename; AttachmentType get type; int get sizeBytes; String? get mimeType; String? get localPath; String? get cloudUrl; AttachmentMetadata? get metadata;
/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageAttachmentCopyWith<MessageAttachment> get copyWith => _$MessageAttachmentCopyWithImpl<MessageAttachment>(this as MessageAttachment, _$identity);

  /// Serializes this MessageAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.type, type) || other.type == type)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.cloudUrl, cloudUrl) || other.cloudUrl == cloudUrl)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,filename,type,sizeBytes,mimeType,localPath,cloudUrl,metadata);

@override
String toString() {
  return 'MessageAttachment(id: $id, filename: $filename, type: $type, sizeBytes: $sizeBytes, mimeType: $mimeType, localPath: $localPath, cloudUrl: $cloudUrl, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $MessageAttachmentCopyWith<$Res>  {
  factory $MessageAttachmentCopyWith(MessageAttachment value, $Res Function(MessageAttachment) _then) = _$MessageAttachmentCopyWithImpl;
@useResult
$Res call({
 AttachmentId id, String filename, AttachmentType type, int sizeBytes, String? mimeType, String? localPath, String? cloudUrl, AttachmentMetadata? metadata
});


$AttachmentIdCopyWith<$Res> get id;$AttachmentMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class _$MessageAttachmentCopyWithImpl<$Res>
    implements $MessageAttachmentCopyWith<$Res> {
  _$MessageAttachmentCopyWithImpl(this._self, this._then);

  final MessageAttachment _self;
  final $Res Function(MessageAttachment) _then;

/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? filename = null,Object? type = null,Object? sizeBytes = null,Object? mimeType = freezed,Object? localPath = freezed,Object? cloudUrl = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as AttachmentId,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AttachmentType,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,cloudUrl: freezed == cloudUrl ? _self.cloudUrl : cloudUrl // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as AttachmentMetadata?,
  ));
}
/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttachmentIdCopyWith<$Res> get id {
  
  return $AttachmentIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttachmentMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $AttachmentMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [MessageAttachment].
extension MessageAttachmentPatterns on MessageAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageAttachment value)  $default,){
final _that = this;
switch (_that) {
case _MessageAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _MessageAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttachmentId id,  String filename,  AttachmentType type,  int sizeBytes,  String? mimeType,  String? localPath,  String? cloudUrl,  AttachmentMetadata? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageAttachment() when $default != null:
return $default(_that.id,_that.filename,_that.type,_that.sizeBytes,_that.mimeType,_that.localPath,_that.cloudUrl,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttachmentId id,  String filename,  AttachmentType type,  int sizeBytes,  String? mimeType,  String? localPath,  String? cloudUrl,  AttachmentMetadata? metadata)  $default,) {final _that = this;
switch (_that) {
case _MessageAttachment():
return $default(_that.id,_that.filename,_that.type,_that.sizeBytes,_that.mimeType,_that.localPath,_that.cloudUrl,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttachmentId id,  String filename,  AttachmentType type,  int sizeBytes,  String? mimeType,  String? localPath,  String? cloudUrl,  AttachmentMetadata? metadata)?  $default,) {final _that = this;
switch (_that) {
case _MessageAttachment() when $default != null:
return $default(_that.id,_that.filename,_that.type,_that.sizeBytes,_that.mimeType,_that.localPath,_that.cloudUrl,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageAttachment implements MessageAttachment {
  const _MessageAttachment({required this.id, required this.filename, required this.type, required this.sizeBytes, this.mimeType, this.localPath, this.cloudUrl, this.metadata});
  factory _MessageAttachment.fromJson(Map<String, dynamic> json) => _$MessageAttachmentFromJson(json);

@override final  AttachmentId id;
@override final  String filename;
@override final  AttachmentType type;
@override final  int sizeBytes;
@override final  String? mimeType;
@override final  String? localPath;
@override final  String? cloudUrl;
@override final  AttachmentMetadata? metadata;

/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageAttachmentCopyWith<_MessageAttachment> get copyWith => __$MessageAttachmentCopyWithImpl<_MessageAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.type, type) || other.type == type)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.cloudUrl, cloudUrl) || other.cloudUrl == cloudUrl)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,filename,type,sizeBytes,mimeType,localPath,cloudUrl,metadata);

@override
String toString() {
  return 'MessageAttachment(id: $id, filename: $filename, type: $type, sizeBytes: $sizeBytes, mimeType: $mimeType, localPath: $localPath, cloudUrl: $cloudUrl, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$MessageAttachmentCopyWith<$Res> implements $MessageAttachmentCopyWith<$Res> {
  factory _$MessageAttachmentCopyWith(_MessageAttachment value, $Res Function(_MessageAttachment) _then) = __$MessageAttachmentCopyWithImpl;
@override @useResult
$Res call({
 AttachmentId id, String filename, AttachmentType type, int sizeBytes, String? mimeType, String? localPath, String? cloudUrl, AttachmentMetadata? metadata
});


@override $AttachmentIdCopyWith<$Res> get id;@override $AttachmentMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class __$MessageAttachmentCopyWithImpl<$Res>
    implements _$MessageAttachmentCopyWith<$Res> {
  __$MessageAttachmentCopyWithImpl(this._self, this._then);

  final _MessageAttachment _self;
  final $Res Function(_MessageAttachment) _then;

/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? filename = null,Object? type = null,Object? sizeBytes = null,Object? mimeType = freezed,Object? localPath = freezed,Object? cloudUrl = freezed,Object? metadata = freezed,}) {
  return _then(_MessageAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as AttachmentId,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AttachmentType,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,cloudUrl: freezed == cloudUrl ? _self.cloudUrl : cloudUrl // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as AttachmentMetadata?,
  ));
}

/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttachmentIdCopyWith<$Res> get id {
  
  return $AttachmentIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttachmentMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $AttachmentMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// @nodoc
mixin _$AttachmentId {

 String get value;
/// Create a copy of AttachmentId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentIdCopyWith<AttachmentId> get copyWith => _$AttachmentIdCopyWithImpl<AttachmentId>(this as AttachmentId, _$identity);

  /// Serializes this AttachmentId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'AttachmentId(value: $value)';
}


}

/// @nodoc
abstract mixin class $AttachmentIdCopyWith<$Res>  {
  factory $AttachmentIdCopyWith(AttachmentId value, $Res Function(AttachmentId) _then) = _$AttachmentIdCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$AttachmentIdCopyWithImpl<$Res>
    implements $AttachmentIdCopyWith<$Res> {
  _$AttachmentIdCopyWithImpl(this._self, this._then);

  final AttachmentId _self;
  final $Res Function(AttachmentId) _then;

/// Create a copy of AttachmentId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentId].
extension AttachmentIdPatterns on AttachmentId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentId value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentId value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentId() when $default != null:
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
case _AttachmentId() when $default != null:
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
case _AttachmentId():
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
case _AttachmentId() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttachmentId implements AttachmentId {
  const _AttachmentId(this.value);
  factory _AttachmentId.fromJson(Map<String, dynamic> json) => _$AttachmentIdFromJson(json);

@override final  String value;

/// Create a copy of AttachmentId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentIdCopyWith<_AttachmentId> get copyWith => __$AttachmentIdCopyWithImpl<_AttachmentId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttachmentIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'AttachmentId(value: $value)';
}


}

/// @nodoc
abstract mixin class _$AttachmentIdCopyWith<$Res> implements $AttachmentIdCopyWith<$Res> {
  factory _$AttachmentIdCopyWith(_AttachmentId value, $Res Function(_AttachmentId) _then) = __$AttachmentIdCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$AttachmentIdCopyWithImpl<$Res>
    implements _$AttachmentIdCopyWith<$Res> {
  __$AttachmentIdCopyWithImpl(this._self, this._then);

  final _AttachmentId _self;
  final $Res Function(_AttachmentId) _then;

/// Create a copy of AttachmentId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_AttachmentId(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AttachmentMetadata {

 int? get width; int? get height; int? get durationMs; String? get title; String? get description;
/// Create a copy of AttachmentMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentMetadataCopyWith<AttachmentMetadata> get copyWith => _$AttachmentMetadataCopyWithImpl<AttachmentMetadata>(this as AttachmentMetadata, _$identity);

  /// Serializes this AttachmentMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentMetadata&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,durationMs,title,description);

@override
String toString() {
  return 'AttachmentMetadata(width: $width, height: $height, durationMs: $durationMs, title: $title, description: $description)';
}


}

/// @nodoc
abstract mixin class $AttachmentMetadataCopyWith<$Res>  {
  factory $AttachmentMetadataCopyWith(AttachmentMetadata value, $Res Function(AttachmentMetadata) _then) = _$AttachmentMetadataCopyWithImpl;
@useResult
$Res call({
 int? width, int? height, int? durationMs, String? title, String? description
});




}
/// @nodoc
class _$AttachmentMetadataCopyWithImpl<$Res>
    implements $AttachmentMetadataCopyWith<$Res> {
  _$AttachmentMetadataCopyWithImpl(this._self, this._then);

  final AttachmentMetadata _self;
  final $Res Function(AttachmentMetadata) _then;

/// Create a copy of AttachmentMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = freezed,Object? height = freezed,Object? durationMs = freezed,Object? title = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentMetadata].
extension AttachmentMetadataPatterns on AttachmentMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentMetadata value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? width,  int? height,  int? durationMs,  String? title,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttachmentMetadata() when $default != null:
return $default(_that.width,_that.height,_that.durationMs,_that.title,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? width,  int? height,  int? durationMs,  String? title,  String? description)  $default,) {final _that = this;
switch (_that) {
case _AttachmentMetadata():
return $default(_that.width,_that.height,_that.durationMs,_that.title,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? width,  int? height,  int? durationMs,  String? title,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _AttachmentMetadata() when $default != null:
return $default(_that.width,_that.height,_that.durationMs,_that.title,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttachmentMetadata implements AttachmentMetadata {
  const _AttachmentMetadata({this.width, this.height, this.durationMs, this.title, this.description});
  factory _AttachmentMetadata.fromJson(Map<String, dynamic> json) => _$AttachmentMetadataFromJson(json);

@override final  int? width;
@override final  int? height;
@override final  int? durationMs;
@override final  String? title;
@override final  String? description;

/// Create a copy of AttachmentMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentMetadataCopyWith<_AttachmentMetadata> get copyWith => __$AttachmentMetadataCopyWithImpl<_AttachmentMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttachmentMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentMetadata&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,durationMs,title,description);

@override
String toString() {
  return 'AttachmentMetadata(width: $width, height: $height, durationMs: $durationMs, title: $title, description: $description)';
}


}

/// @nodoc
abstract mixin class _$AttachmentMetadataCopyWith<$Res> implements $AttachmentMetadataCopyWith<$Res> {
  factory _$AttachmentMetadataCopyWith(_AttachmentMetadata value, $Res Function(_AttachmentMetadata) _then) = __$AttachmentMetadataCopyWithImpl;
@override @useResult
$Res call({
 int? width, int? height, int? durationMs, String? title, String? description
});




}
/// @nodoc
class __$AttachmentMetadataCopyWithImpl<$Res>
    implements _$AttachmentMetadataCopyWith<$Res> {
  __$AttachmentMetadataCopyWithImpl(this._self, this._then);

  final _AttachmentMetadata _self;
  final $Res Function(_AttachmentMetadata) _then;

/// Create a copy of AttachmentMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = freezed,Object? height = freezed,Object? durationMs = freezed,Object? title = freezed,Object? description = freezed,}) {
  return _then(_AttachmentMetadata(
width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MessageReply {

 MessageId get originalMessageId; String? get originalText; ContactId? get originalSenderId;
/// Create a copy of MessageReply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageReplyCopyWith<MessageReply> get copyWith => _$MessageReplyCopyWithImpl<MessageReply>(this as MessageReply, _$identity);

  /// Serializes this MessageReply to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageReply&&(identical(other.originalMessageId, originalMessageId) || other.originalMessageId == originalMessageId)&&(identical(other.originalText, originalText) || other.originalText == originalText)&&(identical(other.originalSenderId, originalSenderId) || other.originalSenderId == originalSenderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalMessageId,originalText,originalSenderId);

@override
String toString() {
  return 'MessageReply(originalMessageId: $originalMessageId, originalText: $originalText, originalSenderId: $originalSenderId)';
}


}

/// @nodoc
abstract mixin class $MessageReplyCopyWith<$Res>  {
  factory $MessageReplyCopyWith(MessageReply value, $Res Function(MessageReply) _then) = _$MessageReplyCopyWithImpl;
@useResult
$Res call({
 MessageId originalMessageId, String? originalText, ContactId? originalSenderId
});


$MessageIdCopyWith<$Res> get originalMessageId;$ContactIdCopyWith<$Res>? get originalSenderId;

}
/// @nodoc
class _$MessageReplyCopyWithImpl<$Res>
    implements $MessageReplyCopyWith<$Res> {
  _$MessageReplyCopyWithImpl(this._self, this._then);

  final MessageReply _self;
  final $Res Function(MessageReply) _then;

/// Create a copy of MessageReply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? originalMessageId = null,Object? originalText = freezed,Object? originalSenderId = freezed,}) {
  return _then(_self.copyWith(
originalMessageId: null == originalMessageId ? _self.originalMessageId : originalMessageId // ignore: cast_nullable_to_non_nullable
as MessageId,originalText: freezed == originalText ? _self.originalText : originalText // ignore: cast_nullable_to_non_nullable
as String?,originalSenderId: freezed == originalSenderId ? _self.originalSenderId : originalSenderId // ignore: cast_nullable_to_non_nullable
as ContactId?,
  ));
}
/// Create a copy of MessageReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageIdCopyWith<$Res> get originalMessageId {
  
  return $MessageIdCopyWith<$Res>(_self.originalMessageId, (value) {
    return _then(_self.copyWith(originalMessageId: value));
  });
}/// Create a copy of MessageReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res>? get originalSenderId {
    if (_self.originalSenderId == null) {
    return null;
  }

  return $ContactIdCopyWith<$Res>(_self.originalSenderId!, (value) {
    return _then(_self.copyWith(originalSenderId: value));
  });
}
}


/// Adds pattern-matching-related methods to [MessageReply].
extension MessageReplyPatterns on MessageReply {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageReply value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageReply() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageReply value)  $default,){
final _that = this;
switch (_that) {
case _MessageReply():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageReply value)?  $default,){
final _that = this;
switch (_that) {
case _MessageReply() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MessageId originalMessageId,  String? originalText,  ContactId? originalSenderId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageReply() when $default != null:
return $default(_that.originalMessageId,_that.originalText,_that.originalSenderId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MessageId originalMessageId,  String? originalText,  ContactId? originalSenderId)  $default,) {final _that = this;
switch (_that) {
case _MessageReply():
return $default(_that.originalMessageId,_that.originalText,_that.originalSenderId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MessageId originalMessageId,  String? originalText,  ContactId? originalSenderId)?  $default,) {final _that = this;
switch (_that) {
case _MessageReply() when $default != null:
return $default(_that.originalMessageId,_that.originalText,_that.originalSenderId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageReply implements MessageReply {
  const _MessageReply({required this.originalMessageId, this.originalText, this.originalSenderId});
  factory _MessageReply.fromJson(Map<String, dynamic> json) => _$MessageReplyFromJson(json);

@override final  MessageId originalMessageId;
@override final  String? originalText;
@override final  ContactId? originalSenderId;

/// Create a copy of MessageReply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageReplyCopyWith<_MessageReply> get copyWith => __$MessageReplyCopyWithImpl<_MessageReply>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageReplyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageReply&&(identical(other.originalMessageId, originalMessageId) || other.originalMessageId == originalMessageId)&&(identical(other.originalText, originalText) || other.originalText == originalText)&&(identical(other.originalSenderId, originalSenderId) || other.originalSenderId == originalSenderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalMessageId,originalText,originalSenderId);

@override
String toString() {
  return 'MessageReply(originalMessageId: $originalMessageId, originalText: $originalText, originalSenderId: $originalSenderId)';
}


}

/// @nodoc
abstract mixin class _$MessageReplyCopyWith<$Res> implements $MessageReplyCopyWith<$Res> {
  factory _$MessageReplyCopyWith(_MessageReply value, $Res Function(_MessageReply) _then) = __$MessageReplyCopyWithImpl;
@override @useResult
$Res call({
 MessageId originalMessageId, String? originalText, ContactId? originalSenderId
});


@override $MessageIdCopyWith<$Res> get originalMessageId;@override $ContactIdCopyWith<$Res>? get originalSenderId;

}
/// @nodoc
class __$MessageReplyCopyWithImpl<$Res>
    implements _$MessageReplyCopyWith<$Res> {
  __$MessageReplyCopyWithImpl(this._self, this._then);

  final _MessageReply _self;
  final $Res Function(_MessageReply) _then;

/// Create a copy of MessageReply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? originalMessageId = null,Object? originalText = freezed,Object? originalSenderId = freezed,}) {
  return _then(_MessageReply(
originalMessageId: null == originalMessageId ? _self.originalMessageId : originalMessageId // ignore: cast_nullable_to_non_nullable
as MessageId,originalText: freezed == originalText ? _self.originalText : originalText // ignore: cast_nullable_to_non_nullable
as String?,originalSenderId: freezed == originalSenderId ? _self.originalSenderId : originalSenderId // ignore: cast_nullable_to_non_nullable
as ContactId?,
  ));
}

/// Create a copy of MessageReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageIdCopyWith<$Res> get originalMessageId {
  
  return $MessageIdCopyWith<$Res>(_self.originalMessageId, (value) {
    return _then(_self.copyWith(originalMessageId: value));
  });
}/// Create a copy of MessageReply
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res>? get originalSenderId {
    if (_self.originalSenderId == null) {
    return null;
  }

  return $ContactIdCopyWith<$Res>(_self.originalSenderId!, (value) {
    return _then(_self.copyWith(originalSenderId: value));
  });
}
}


/// @nodoc
mixin _$MessageEditing {

 MessageContent get originalContent; List<MessageEdit> get edits;
/// Create a copy of MessageEditing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageEditingCopyWith<MessageEditing> get copyWith => _$MessageEditingCopyWithImpl<MessageEditing>(this as MessageEditing, _$identity);

  /// Serializes this MessageEditing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageEditing&&(identical(other.originalContent, originalContent) || other.originalContent == originalContent)&&const DeepCollectionEquality().equals(other.edits, edits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalContent,const DeepCollectionEquality().hash(edits));

@override
String toString() {
  return 'MessageEditing(originalContent: $originalContent, edits: $edits)';
}


}

/// @nodoc
abstract mixin class $MessageEditingCopyWith<$Res>  {
  factory $MessageEditingCopyWith(MessageEditing value, $Res Function(MessageEditing) _then) = _$MessageEditingCopyWithImpl;
@useResult
$Res call({
 MessageContent originalContent, List<MessageEdit> edits
});


$MessageContentCopyWith<$Res> get originalContent;

}
/// @nodoc
class _$MessageEditingCopyWithImpl<$Res>
    implements $MessageEditingCopyWith<$Res> {
  _$MessageEditingCopyWithImpl(this._self, this._then);

  final MessageEditing _self;
  final $Res Function(MessageEditing) _then;

/// Create a copy of MessageEditing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? originalContent = null,Object? edits = null,}) {
  return _then(_self.copyWith(
originalContent: null == originalContent ? _self.originalContent : originalContent // ignore: cast_nullable_to_non_nullable
as MessageContent,edits: null == edits ? _self.edits : edits // ignore: cast_nullable_to_non_nullable
as List<MessageEdit>,
  ));
}
/// Create a copy of MessageEditing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageContentCopyWith<$Res> get originalContent {
  
  return $MessageContentCopyWith<$Res>(_self.originalContent, (value) {
    return _then(_self.copyWith(originalContent: value));
  });
}
}


/// Adds pattern-matching-related methods to [MessageEditing].
extension MessageEditingPatterns on MessageEditing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageEditing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageEditing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageEditing value)  $default,){
final _that = this;
switch (_that) {
case _MessageEditing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageEditing value)?  $default,){
final _that = this;
switch (_that) {
case _MessageEditing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MessageContent originalContent,  List<MessageEdit> edits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageEditing() when $default != null:
return $default(_that.originalContent,_that.edits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MessageContent originalContent,  List<MessageEdit> edits)  $default,) {final _that = this;
switch (_that) {
case _MessageEditing():
return $default(_that.originalContent,_that.edits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MessageContent originalContent,  List<MessageEdit> edits)?  $default,) {final _that = this;
switch (_that) {
case _MessageEditing() when $default != null:
return $default(_that.originalContent,_that.edits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageEditing extends MessageEditing {
  const _MessageEditing({required this.originalContent, required final  List<MessageEdit> edits}): _edits = edits,super._();
  factory _MessageEditing.fromJson(Map<String, dynamic> json) => _$MessageEditingFromJson(json);

@override final  MessageContent originalContent;
 final  List<MessageEdit> _edits;
@override List<MessageEdit> get edits {
  if (_edits is EqualUnmodifiableListView) return _edits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_edits);
}


/// Create a copy of MessageEditing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageEditingCopyWith<_MessageEditing> get copyWith => __$MessageEditingCopyWithImpl<_MessageEditing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageEditingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageEditing&&(identical(other.originalContent, originalContent) || other.originalContent == originalContent)&&const DeepCollectionEquality().equals(other._edits, _edits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,originalContent,const DeepCollectionEquality().hash(_edits));

@override
String toString() {
  return 'MessageEditing(originalContent: $originalContent, edits: $edits)';
}


}

/// @nodoc
abstract mixin class _$MessageEditingCopyWith<$Res> implements $MessageEditingCopyWith<$Res> {
  factory _$MessageEditingCopyWith(_MessageEditing value, $Res Function(_MessageEditing) _then) = __$MessageEditingCopyWithImpl;
@override @useResult
$Res call({
 MessageContent originalContent, List<MessageEdit> edits
});


@override $MessageContentCopyWith<$Res> get originalContent;

}
/// @nodoc
class __$MessageEditingCopyWithImpl<$Res>
    implements _$MessageEditingCopyWith<$Res> {
  __$MessageEditingCopyWithImpl(this._self, this._then);

  final _MessageEditing _self;
  final $Res Function(_MessageEditing) _then;

/// Create a copy of MessageEditing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? originalContent = null,Object? edits = null,}) {
  return _then(_MessageEditing(
originalContent: null == originalContent ? _self.originalContent : originalContent // ignore: cast_nullable_to_non_nullable
as MessageContent,edits: null == edits ? _self._edits : edits // ignore: cast_nullable_to_non_nullable
as List<MessageEdit>,
  ));
}

/// Create a copy of MessageEditing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageContentCopyWith<$Res> get originalContent {
  
  return $MessageContentCopyWith<$Res>(_self.originalContent, (value) {
    return _then(_self.copyWith(originalContent: value));
  });
}
}


/// @nodoc
mixin _$MessageEdit {

 MessageContent get content; DateTime get editedAt;
/// Create a copy of MessageEdit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageEditCopyWith<MessageEdit> get copyWith => _$MessageEditCopyWithImpl<MessageEdit>(this as MessageEdit, _$identity);

  /// Serializes this MessageEdit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageEdit&&(identical(other.content, content) || other.content == content)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,editedAt);

@override
String toString() {
  return 'MessageEdit(content: $content, editedAt: $editedAt)';
}


}

/// @nodoc
abstract mixin class $MessageEditCopyWith<$Res>  {
  factory $MessageEditCopyWith(MessageEdit value, $Res Function(MessageEdit) _then) = _$MessageEditCopyWithImpl;
@useResult
$Res call({
 MessageContent content, DateTime editedAt
});


$MessageContentCopyWith<$Res> get content;

}
/// @nodoc
class _$MessageEditCopyWithImpl<$Res>
    implements $MessageEditCopyWith<$Res> {
  _$MessageEditCopyWithImpl(this._self, this._then);

  final MessageEdit _self;
  final $Res Function(MessageEdit) _then;

/// Create a copy of MessageEdit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? editedAt = null,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as MessageContent,editedAt: null == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of MessageEdit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageContentCopyWith<$Res> get content {
  
  return $MessageContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// Adds pattern-matching-related methods to [MessageEdit].
extension MessageEditPatterns on MessageEdit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageEdit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageEdit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageEdit value)  $default,){
final _that = this;
switch (_that) {
case _MessageEdit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageEdit value)?  $default,){
final _that = this;
switch (_that) {
case _MessageEdit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MessageContent content,  DateTime editedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageEdit() when $default != null:
return $default(_that.content,_that.editedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MessageContent content,  DateTime editedAt)  $default,) {final _that = this;
switch (_that) {
case _MessageEdit():
return $default(_that.content,_that.editedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MessageContent content,  DateTime editedAt)?  $default,) {final _that = this;
switch (_that) {
case _MessageEdit() when $default != null:
return $default(_that.content,_that.editedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageEdit implements MessageEdit {
  const _MessageEdit({required this.content, required this.editedAt});
  factory _MessageEdit.fromJson(Map<String, dynamic> json) => _$MessageEditFromJson(json);

@override final  MessageContent content;
@override final  DateTime editedAt;

/// Create a copy of MessageEdit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageEditCopyWith<_MessageEdit> get copyWith => __$MessageEditCopyWithImpl<_MessageEdit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageEditToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageEdit&&(identical(other.content, content) || other.content == content)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,editedAt);

@override
String toString() {
  return 'MessageEdit(content: $content, editedAt: $editedAt)';
}


}

/// @nodoc
abstract mixin class _$MessageEditCopyWith<$Res> implements $MessageEditCopyWith<$Res> {
  factory _$MessageEditCopyWith(_MessageEdit value, $Res Function(_MessageEdit) _then) = __$MessageEditCopyWithImpl;
@override @useResult
$Res call({
 MessageContent content, DateTime editedAt
});


@override $MessageContentCopyWith<$Res> get content;

}
/// @nodoc
class __$MessageEditCopyWithImpl<$Res>
    implements _$MessageEditCopyWith<$Res> {
  __$MessageEditCopyWithImpl(this._self, this._then);

  final _MessageEdit _self;
  final $Res Function(_MessageEdit) _then;

/// Create a copy of MessageEdit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? editedAt = null,}) {
  return _then(_MessageEdit(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as MessageContent,editedAt: null == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of MessageEdit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageContentCopyWith<$Res> get content {
  
  return $MessageContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
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
