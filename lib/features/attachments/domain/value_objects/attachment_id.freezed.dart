// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment_id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AttachmentId {

 String get value;
/// Create a copy of AttachmentId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentIdCopyWith<AttachmentId> get copyWith => _$AttachmentIdCopyWithImpl<AttachmentId>(this as AttachmentId, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentId&&(identical(other.value, value) || other.value == value));
}


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


class _AttachmentId extends AttachmentId {
  const _AttachmentId(this.value): super._();
  

@override final  String value;

/// Create a copy of AttachmentId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentIdCopyWith<_AttachmentId> get copyWith => __$AttachmentIdCopyWithImpl<_AttachmentId>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentId&&(identical(other.value, value) || other.value == value));
}


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

// dart format on
