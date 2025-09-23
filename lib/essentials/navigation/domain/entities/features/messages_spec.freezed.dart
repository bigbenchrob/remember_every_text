// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessagesSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagesSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessagesSpec()';
}


}

/// @nodoc
class $MessagesSpecCopyWith<$Res>  {
$MessagesSpecCopyWith(MessagesSpec _, $Res Function(MessagesSpec) __);
}


/// Adds pattern-matching-related methods to [MessagesSpec].
extension MessagesSpecPatterns on MessagesSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _MessagesForChat value)?  forChat,TResult Function( _MessagesForContact value)?  forContact,TResult Function( _RecentMessages value)?  recent,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessagesForChat() when forChat != null:
return forChat(_that);case _MessagesForContact() when forContact != null:
return forContact(_that);case _RecentMessages() when recent != null:
return recent(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _MessagesForChat value)  forChat,required TResult Function( _MessagesForContact value)  forContact,required TResult Function( _RecentMessages value)  recent,}){
final _that = this;
switch (_that) {
case _MessagesForChat():
return forChat(_that);case _MessagesForContact():
return forContact(_that);case _RecentMessages():
return recent(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _MessagesForChat value)?  forChat,TResult? Function( _MessagesForContact value)?  forContact,TResult? Function( _RecentMessages value)?  recent,}){
final _that = this;
switch (_that) {
case _MessagesForChat() when forChat != null:
return forChat(_that);case _MessagesForContact() when forContact != null:
return forContact(_that);case _RecentMessages() when recent != null:
return recent(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int chatId)?  forChat,TResult Function( String contactId)?  forContact,TResult Function( int limit)?  recent,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessagesForChat() when forChat != null:
return forChat(_that.chatId);case _MessagesForContact() when forContact != null:
return forContact(_that.contactId);case _RecentMessages() when recent != null:
return recent(_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int chatId)  forChat,required TResult Function( String contactId)  forContact,required TResult Function( int limit)  recent,}) {final _that = this;
switch (_that) {
case _MessagesForChat():
return forChat(_that.chatId);case _MessagesForContact():
return forContact(_that.contactId);case _RecentMessages():
return recent(_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int chatId)?  forChat,TResult? Function( String contactId)?  forContact,TResult? Function( int limit)?  recent,}) {final _that = this;
switch (_that) {
case _MessagesForChat() when forChat != null:
return forChat(_that.chatId);case _MessagesForContact() when forContact != null:
return forContact(_that.contactId);case _RecentMessages() when recent != null:
return recent(_that.limit);case _:
  return null;

}
}

}

/// @nodoc


class _MessagesForChat implements MessagesSpec {
  const _MessagesForChat({required this.chatId});
  

 final  int chatId;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesForChatCopyWith<_MessagesForChat> get copyWith => __$MessagesForChatCopyWithImpl<_MessagesForChat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesForChat&&(identical(other.chatId, chatId) || other.chatId == chatId));
}


@override
int get hashCode => Object.hash(runtimeType,chatId);

@override
String toString() {
  return 'MessagesSpec.forChat(chatId: $chatId)';
}


}

/// @nodoc
abstract mixin class _$MessagesForChatCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesForChatCopyWith(_MessagesForChat value, $Res Function(_MessagesForChat) _then) = __$MessagesForChatCopyWithImpl;
@useResult
$Res call({
 int chatId
});




}
/// @nodoc
class __$MessagesForChatCopyWithImpl<$Res>
    implements _$MessagesForChatCopyWith<$Res> {
  __$MessagesForChatCopyWithImpl(this._self, this._then);

  final _MessagesForChat _self;
  final $Res Function(_MessagesForChat) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chatId = null,}) {
  return _then(_MessagesForChat(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _MessagesForContact implements MessagesSpec {
  const _MessagesForContact({required this.contactId});
  

 final  String contactId;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesForContactCopyWith<_MessagesForContact> get copyWith => __$MessagesForContactCopyWithImpl<_MessagesForContact>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesForContact&&(identical(other.contactId, contactId) || other.contactId == contactId));
}


@override
int get hashCode => Object.hash(runtimeType,contactId);

@override
String toString() {
  return 'MessagesSpec.forContact(contactId: $contactId)';
}


}

/// @nodoc
abstract mixin class _$MessagesForContactCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesForContactCopyWith(_MessagesForContact value, $Res Function(_MessagesForContact) _then) = __$MessagesForContactCopyWithImpl;
@useResult
$Res call({
 String contactId
});




}
/// @nodoc
class __$MessagesForContactCopyWithImpl<$Res>
    implements _$MessagesForContactCopyWith<$Res> {
  __$MessagesForContactCopyWithImpl(this._self, this._then);

  final _MessagesForContact _self;
  final $Res Function(_MessagesForContact) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contactId = null,}) {
  return _then(_MessagesForContact(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _RecentMessages implements MessagesSpec {
  const _RecentMessages({required this.limit});
  

 final  int limit;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentMessagesCopyWith<_RecentMessages> get copyWith => __$RecentMessagesCopyWithImpl<_RecentMessages>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentMessages&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,limit);

@override
String toString() {
  return 'MessagesSpec.recent(limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$RecentMessagesCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$RecentMessagesCopyWith(_RecentMessages value, $Res Function(_RecentMessages) _then) = __$RecentMessagesCopyWithImpl;
@useResult
$Res call({
 int limit
});




}
/// @nodoc
class __$RecentMessagesCopyWithImpl<$Res>
    implements _$RecentMessagesCopyWith<$Res> {
  __$RecentMessagesCopyWithImpl(this._self, this._then);

  final _RecentMessages _self;
  final $Res Function(_RecentMessages) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? limit = null,}) {
  return _then(_RecentMessages(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
