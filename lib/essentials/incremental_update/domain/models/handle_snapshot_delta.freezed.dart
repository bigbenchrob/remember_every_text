// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'handle_snapshot_delta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HandleSnapshotDelta {

 int get rowIdDelta; int get handleCountDelta;
/// Create a copy of HandleSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandleSnapshotDeltaCopyWith<HandleSnapshotDelta> get copyWith => _$HandleSnapshotDeltaCopyWithImpl<HandleSnapshotDelta>(this as HandleSnapshotDelta, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleSnapshotDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.handleCountDelta, handleCountDelta) || other.handleCountDelta == handleCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,handleCountDelta);

@override
String toString() {
  return 'HandleSnapshotDelta(rowIdDelta: $rowIdDelta, handleCountDelta: $handleCountDelta)';
}


}

/// @nodoc
abstract mixin class $HandleSnapshotDeltaCopyWith<$Res>  {
  factory $HandleSnapshotDeltaCopyWith(HandleSnapshotDelta value, $Res Function(HandleSnapshotDelta) _then) = _$HandleSnapshotDeltaCopyWithImpl;
@useResult
$Res call({
 int rowIdDelta, int handleCountDelta
});




}
/// @nodoc
class _$HandleSnapshotDeltaCopyWithImpl<$Res>
    implements $HandleSnapshotDeltaCopyWith<$Res> {
  _$HandleSnapshotDeltaCopyWithImpl(this._self, this._then);

  final HandleSnapshotDelta _self;
  final $Res Function(HandleSnapshotDelta) _then;

/// Create a copy of HandleSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowIdDelta = null,Object? handleCountDelta = null,}) {
  return _then(_self.copyWith(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,handleCountDelta: null == handleCountDelta ? _self.handleCountDelta : handleCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HandleSnapshotDelta].
extension HandleSnapshotDeltaPatterns on HandleSnapshotDelta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HandleSnapshotDelta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandleSnapshotDelta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HandleSnapshotDelta value)  $default,){
final _that = this;
switch (_that) {
case _HandleSnapshotDelta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HandleSnapshotDelta value)?  $default,){
final _that = this;
switch (_that) {
case _HandleSnapshotDelta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowIdDelta,  int handleCountDelta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandleSnapshotDelta() when $default != null:
return $default(_that.rowIdDelta,_that.handleCountDelta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowIdDelta,  int handleCountDelta)  $default,) {final _that = this;
switch (_that) {
case _HandleSnapshotDelta():
return $default(_that.rowIdDelta,_that.handleCountDelta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowIdDelta,  int handleCountDelta)?  $default,) {final _that = this;
switch (_that) {
case _HandleSnapshotDelta() when $default != null:
return $default(_that.rowIdDelta,_that.handleCountDelta);case _:
  return null;

}
}

}

/// @nodoc


class _HandleSnapshotDelta extends HandleSnapshotDelta {
  const _HandleSnapshotDelta({required this.rowIdDelta, required this.handleCountDelta}): super._();
  

@override final  int rowIdDelta;
@override final  int handleCountDelta;

/// Create a copy of HandleSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandleSnapshotDeltaCopyWith<_HandleSnapshotDelta> get copyWith => __$HandleSnapshotDeltaCopyWithImpl<_HandleSnapshotDelta>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandleSnapshotDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.handleCountDelta, handleCountDelta) || other.handleCountDelta == handleCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,handleCountDelta);

@override
String toString() {
  return 'HandleSnapshotDelta(rowIdDelta: $rowIdDelta, handleCountDelta: $handleCountDelta)';
}


}

/// @nodoc
abstract mixin class _$HandleSnapshotDeltaCopyWith<$Res> implements $HandleSnapshotDeltaCopyWith<$Res> {
  factory _$HandleSnapshotDeltaCopyWith(_HandleSnapshotDelta value, $Res Function(_HandleSnapshotDelta) _then) = __$HandleSnapshotDeltaCopyWithImpl;
@override @useResult
$Res call({
 int rowIdDelta, int handleCountDelta
});




}
/// @nodoc
class __$HandleSnapshotDeltaCopyWithImpl<$Res>
    implements _$HandleSnapshotDeltaCopyWith<$Res> {
  __$HandleSnapshotDeltaCopyWithImpl(this._self, this._then);

  final _HandleSnapshotDelta _self;
  final $Res Function(_HandleSnapshotDelta) _then;

/// Create a copy of HandleSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowIdDelta = null,Object? handleCountDelta = null,}) {
  return _then(_HandleSnapshotDelta(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,handleCountDelta: null == handleCountDelta ? _self.handleCountDelta : handleCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
