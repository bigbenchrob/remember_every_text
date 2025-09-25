// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactId {

 String get value;
/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactIdCopyWith<ContactId> get copyWith => _$ContactIdCopyWithImpl<ContactId>(this as ContactId, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactId&&(identical(other.value, value) || other.value == value));
}


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


class _ContactId extends ContactId {
  const _ContactId(this.value): super._();
  

@override final  String value;

/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactIdCopyWith<_ContactId> get copyWith => __$ContactIdCopyWithImpl<_ContactId>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactId&&(identical(other.value, value) || other.value == value));
}


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

// dart format on
