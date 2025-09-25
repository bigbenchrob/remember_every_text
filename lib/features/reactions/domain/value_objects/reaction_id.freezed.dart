// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reaction_id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReactionId {

 String get value;
/// Create a copy of ReactionId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactionIdCopyWith<ReactionId> get copyWith => _$ReactionIdCopyWithImpl<ReactionId>(this as ReactionId, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReactionId&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ReactionId(value: $value)';
}


}

/// @nodoc
abstract mixin class $ReactionIdCopyWith<$Res>  {
  factory $ReactionIdCopyWith(ReactionId value, $Res Function(ReactionId) _then) = _$ReactionIdCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$ReactionIdCopyWithImpl<$Res>
    implements $ReactionIdCopyWith<$Res> {
  _$ReactionIdCopyWithImpl(this._self, this._then);

  final ReactionId _self;
  final $Res Function(ReactionId) _then;

/// Create a copy of ReactionId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReactionId].
extension ReactionIdPatterns on ReactionId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReactionId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReactionId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReactionId value)  $default,){
final _that = this;
switch (_that) {
case _ReactionId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReactionId value)?  $default,){
final _that = this;
switch (_that) {
case _ReactionId() when $default != null:
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
case _ReactionId() when $default != null:
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
case _ReactionId():
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
case _ReactionId() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _ReactionId extends ReactionId {
  const _ReactionId(this.value): super._();
  

@override final  String value;

/// Create a copy of ReactionId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionIdCopyWith<_ReactionId> get copyWith => __$ReactionIdCopyWithImpl<_ReactionId>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReactionId&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ReactionId(value: $value)';
}


}

/// @nodoc
abstract mixin class _$ReactionIdCopyWith<$Res> implements $ReactionIdCopyWith<$Res> {
  factory _$ReactionIdCopyWith(_ReactionId value, $Res Function(_ReactionId) _then) = __$ReactionIdCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$ReactionIdCopyWithImpl<$Res>
    implements _$ReactionIdCopyWith<$Res> {
  __$ReactionIdCopyWithImpl(this._self, this._then);

  final _ReactionId _self;
  final $Res Function(_ReactionId) _then;

/// Create a copy of ReactionId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_ReactionId(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
