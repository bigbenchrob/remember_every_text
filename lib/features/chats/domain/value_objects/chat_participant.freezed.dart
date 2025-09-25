// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_participant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatParticipant {

 String get handleId;// stable key from source (handle.ROWID or guid)
 String get service;// iMessage/SMS
 String get normalizedAddress;// E.164 or email
 String? get displayName;// optional projection from Contacts
 String? get contactId;
/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatParticipantCopyWith<ChatParticipant> get copyWith => _$ChatParticipantCopyWithImpl<ChatParticipant>(this as ChatParticipant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatParticipant&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.service, service) || other.service == service)&&(identical(other.normalizedAddress, normalizedAddress) || other.normalizedAddress == normalizedAddress)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.contactId, contactId) || other.contactId == contactId));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,service,normalizedAddress,displayName,contactId);

@override
String toString() {
  return 'ChatParticipant(handleId: $handleId, service: $service, normalizedAddress: $normalizedAddress, displayName: $displayName, contactId: $contactId)';
}


}

/// @nodoc
abstract mixin class $ChatParticipantCopyWith<$Res>  {
  factory $ChatParticipantCopyWith(ChatParticipant value, $Res Function(ChatParticipant) _then) = _$ChatParticipantCopyWithImpl;
@useResult
$Res call({
 String handleId, String service, String normalizedAddress, String? displayName, String? contactId
});




}
/// @nodoc
class _$ChatParticipantCopyWithImpl<$Res>
    implements $ChatParticipantCopyWith<$Res> {
  _$ChatParticipantCopyWithImpl(this._self, this._then);

  final ChatParticipant _self;
  final $Res Function(ChatParticipant) _then;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? handleId = null,Object? service = null,Object? normalizedAddress = null,Object? displayName = freezed,Object? contactId = freezed,}) {
  return _then(_self.copyWith(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as String,normalizedAddress: null == normalizedAddress ? _self.normalizedAddress : normalizedAddress // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String handleId,  String service,  String normalizedAddress,  String? displayName,  String? contactId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that.handleId,_that.service,_that.normalizedAddress,_that.displayName,_that.contactId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String handleId,  String service,  String normalizedAddress,  String? displayName,  String? contactId)  $default,) {final _that = this;
switch (_that) {
case _ChatParticipant():
return $default(_that.handleId,_that.service,_that.normalizedAddress,_that.displayName,_that.contactId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String handleId,  String service,  String normalizedAddress,  String? displayName,  String? contactId)?  $default,) {final _that = this;
switch (_that) {
case _ChatParticipant() when $default != null:
return $default(_that.handleId,_that.service,_that.normalizedAddress,_that.displayName,_that.contactId);case _:
  return null;

}
}

}

/// @nodoc


class _ChatParticipant extends ChatParticipant {
  const _ChatParticipant({required this.handleId, required this.service, required this.normalizedAddress, this.displayName, this.contactId}): super._();
  

@override final  String handleId;
// stable key from source (handle.ROWID or guid)
@override final  String service;
// iMessage/SMS
@override final  String normalizedAddress;
// E.164 or email
@override final  String? displayName;
// optional projection from Contacts
@override final  String? contactId;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatParticipantCopyWith<_ChatParticipant> get copyWith => __$ChatParticipantCopyWithImpl<_ChatParticipant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatParticipant&&(identical(other.handleId, handleId) || other.handleId == handleId)&&(identical(other.service, service) || other.service == service)&&(identical(other.normalizedAddress, normalizedAddress) || other.normalizedAddress == normalizedAddress)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.contactId, contactId) || other.contactId == contactId));
}


@override
int get hashCode => Object.hash(runtimeType,handleId,service,normalizedAddress,displayName,contactId);

@override
String toString() {
  return 'ChatParticipant(handleId: $handleId, service: $service, normalizedAddress: $normalizedAddress, displayName: $displayName, contactId: $contactId)';
}


}

/// @nodoc
abstract mixin class _$ChatParticipantCopyWith<$Res> implements $ChatParticipantCopyWith<$Res> {
  factory _$ChatParticipantCopyWith(_ChatParticipant value, $Res Function(_ChatParticipant) _then) = __$ChatParticipantCopyWithImpl;
@override @useResult
$Res call({
 String handleId, String service, String normalizedAddress, String? displayName, String? contactId
});




}
/// @nodoc
class __$ChatParticipantCopyWithImpl<$Res>
    implements _$ChatParticipantCopyWith<$Res> {
  __$ChatParticipantCopyWithImpl(this._self, this._then);

  final _ChatParticipant _self;
  final $Res Function(_ChatParticipant) _then;

/// Create a copy of ChatParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? handleId = null,Object? service = null,Object? normalizedAddress = null,Object? displayName = freezed,Object? contactId = freezed,}) {
  return _then(_ChatParticipant(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as String,normalizedAddress: null == normalizedAddress ? _self.normalizedAddress : normalizedAddress // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
