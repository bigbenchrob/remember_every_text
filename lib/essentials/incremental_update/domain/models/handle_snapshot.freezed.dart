// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'handle_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HandleSnapshot {

 int get maxRowId; int get totalHandleCount;
/// Create a copy of HandleSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandleSnapshotCopyWith<HandleSnapshot> get copyWith => _$HandleSnapshotCopyWithImpl<HandleSnapshot>(this as HandleSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleSnapshot&&(identical(other.maxRowId, maxRowId) || other.maxRowId == maxRowId)&&(identical(other.totalHandleCount, totalHandleCount) || other.totalHandleCount == totalHandleCount));
}


@override
int get hashCode => Object.hash(runtimeType,maxRowId,totalHandleCount);

@override
String toString() {
  return 'HandleSnapshot(maxRowId: $maxRowId, totalHandleCount: $totalHandleCount)';
}


}

/// @nodoc
abstract mixin class $HandleSnapshotCopyWith<$Res>  {
  factory $HandleSnapshotCopyWith(HandleSnapshot value, $Res Function(HandleSnapshot) _then) = _$HandleSnapshotCopyWithImpl;
@useResult
$Res call({
 int maxRowId, int totalHandleCount
});




}
/// @nodoc
class _$HandleSnapshotCopyWithImpl<$Res>
    implements $HandleSnapshotCopyWith<$Res> {
  _$HandleSnapshotCopyWithImpl(this._self, this._then);

  final HandleSnapshot _self;
  final $Res Function(HandleSnapshot) _then;

/// Create a copy of HandleSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxRowId = null,Object? totalHandleCount = null,}) {
  return _then(_self.copyWith(
maxRowId: null == maxRowId ? _self.maxRowId : maxRowId // ignore: cast_nullable_to_non_nullable
as int,totalHandleCount: null == totalHandleCount ? _self.totalHandleCount : totalHandleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HandleSnapshot].
extension HandleSnapshotPatterns on HandleSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HandleSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandleSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HandleSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _HandleSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HandleSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _HandleSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int maxRowId,  int totalHandleCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandleSnapshot() when $default != null:
return $default(_that.maxRowId,_that.totalHandleCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int maxRowId,  int totalHandleCount)  $default,) {final _that = this;
switch (_that) {
case _HandleSnapshot():
return $default(_that.maxRowId,_that.totalHandleCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int maxRowId,  int totalHandleCount)?  $default,) {final _that = this;
switch (_that) {
case _HandleSnapshot() when $default != null:
return $default(_that.maxRowId,_that.totalHandleCount);case _:
  return null;

}
}

}

/// @nodoc


class _HandleSnapshot implements HandleSnapshot {
  const _HandleSnapshot({required this.maxRowId, required this.totalHandleCount});
  

@override final  int maxRowId;
@override final  int totalHandleCount;

/// Create a copy of HandleSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandleSnapshotCopyWith<_HandleSnapshot> get copyWith => __$HandleSnapshotCopyWithImpl<_HandleSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandleSnapshot&&(identical(other.maxRowId, maxRowId) || other.maxRowId == maxRowId)&&(identical(other.totalHandleCount, totalHandleCount) || other.totalHandleCount == totalHandleCount));
}


@override
int get hashCode => Object.hash(runtimeType,maxRowId,totalHandleCount);

@override
String toString() {
  return 'HandleSnapshot(maxRowId: $maxRowId, totalHandleCount: $totalHandleCount)';
}


}

/// @nodoc
abstract mixin class _$HandleSnapshotCopyWith<$Res> implements $HandleSnapshotCopyWith<$Res> {
  factory _$HandleSnapshotCopyWith(_HandleSnapshot value, $Res Function(_HandleSnapshot) _then) = __$HandleSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int maxRowId, int totalHandleCount
});




}
/// @nodoc
class __$HandleSnapshotCopyWithImpl<$Res>
    implements _$HandleSnapshotCopyWith<$Res> {
  __$HandleSnapshotCopyWithImpl(this._self, this._then);

  final _HandleSnapshot _self;
  final $Res Function(_HandleSnapshot) _then;

/// Create a copy of HandleSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxRowId = null,Object? totalHandleCount = null,}) {
  return _then(_HandleSnapshot(
maxRowId: null == maxRowId ? _self.maxRowId : maxRowId // ignore: cast_nullable_to_non_nullable
as int,totalHandleCount: null == totalHandleCount ? _self.totalHandleCount : totalHandleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
