// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chats_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatsSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatsSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatsSpec()';
}


}

/// @nodoc
class $ChatsSpecCopyWith<$Res>  {
$ChatsSpecCopyWith(ChatsSpec _, $Res Function(ChatsSpec) __);
}


/// Adds pattern-matching-related methods to [ChatsSpec].
extension ChatsSpecPatterns on ChatsSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ChatsList value)?  list,TResult Function( _ChatsForContact value)?  forContact,TResult Function( _RecentChats value)?  recent,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatsList() when list != null:
return list(_that);case _ChatsForContact() when forContact != null:
return forContact(_that);case _RecentChats() when recent != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ChatsList value)  list,required TResult Function( _ChatsForContact value)  forContact,required TResult Function( _RecentChats value)  recent,}){
final _that = this;
switch (_that) {
case _ChatsList():
return list(_that);case _ChatsForContact():
return forContact(_that);case _RecentChats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ChatsList value)?  list,TResult? Function( _ChatsForContact value)?  forContact,TResult? Function( _RecentChats value)?  recent,}){
final _that = this;
switch (_that) {
case _ChatsList() when list != null:
return list(_that);case _ChatsForContact() when forContact != null:
return forContact(_that);case _RecentChats() when recent != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  list,TResult Function( String contactId)?  forContact,TResult Function( int limit)?  recent,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatsList() when list != null:
return list();case _ChatsForContact() when forContact != null:
return forContact(_that.contactId);case _RecentChats() when recent != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  list,required TResult Function( String contactId)  forContact,required TResult Function( int limit)  recent,}) {final _that = this;
switch (_that) {
case _ChatsList():
return list();case _ChatsForContact():
return forContact(_that.contactId);case _RecentChats():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  list,TResult? Function( String contactId)?  forContact,TResult? Function( int limit)?  recent,}) {final _that = this;
switch (_that) {
case _ChatsList() when list != null:
return list();case _ChatsForContact() when forContact != null:
return forContact(_that.contactId);case _RecentChats() when recent != null:
return recent(_that.limit);case _:
  return null;

}
}

}

/// @nodoc


class _ChatsList implements ChatsSpec {
  const _ChatsList();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatsList);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatsSpec.list()';
}


}




/// @nodoc


class _ChatsForContact implements ChatsSpec {
  const _ChatsForContact({required this.contactId});
  

 final  String contactId;

/// Create a copy of ChatsSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatsForContactCopyWith<_ChatsForContact> get copyWith => __$ChatsForContactCopyWithImpl<_ChatsForContact>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatsForContact&&(identical(other.contactId, contactId) || other.contactId == contactId));
}


@override
int get hashCode => Object.hash(runtimeType,contactId);

@override
String toString() {
  return 'ChatsSpec.forContact(contactId: $contactId)';
}


}

/// @nodoc
abstract mixin class _$ChatsForContactCopyWith<$Res> implements $ChatsSpecCopyWith<$Res> {
  factory _$ChatsForContactCopyWith(_ChatsForContact value, $Res Function(_ChatsForContact) _then) = __$ChatsForContactCopyWithImpl;
@useResult
$Res call({
 String contactId
});




}
/// @nodoc
class __$ChatsForContactCopyWithImpl<$Res>
    implements _$ChatsForContactCopyWith<$Res> {
  __$ChatsForContactCopyWithImpl(this._self, this._then);

  final _ChatsForContact _self;
  final $Res Function(_ChatsForContact) _then;

/// Create a copy of ChatsSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contactId = null,}) {
  return _then(_ChatsForContact(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _RecentChats implements ChatsSpec {
  const _RecentChats({required this.limit});
  

 final  int limit;

/// Create a copy of ChatsSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentChatsCopyWith<_RecentChats> get copyWith => __$RecentChatsCopyWithImpl<_RecentChats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentChats&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,limit);

@override
String toString() {
  return 'ChatsSpec.recent(limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$RecentChatsCopyWith<$Res> implements $ChatsSpecCopyWith<$Res> {
  factory _$RecentChatsCopyWith(_RecentChats value, $Res Function(_RecentChats) _then) = __$RecentChatsCopyWithImpl;
@useResult
$Res call({
 int limit
});




}
/// @nodoc
class __$RecentChatsCopyWithImpl<$Res>
    implements _$RecentChatsCopyWith<$Res> {
  __$RecentChatsCopyWithImpl(this._self, this._then);

  final _RecentChats _self;
  final $Res Function(_RecentChats) _then;

/// Create a copy of ChatsSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? limit = null,}) {
  return _then(_RecentChats(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
