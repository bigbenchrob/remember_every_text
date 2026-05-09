// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_ledger_message_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImportLedgerMessageSnapshot {

 int get maxRowId; int get totalMessageCount;
/// Create a copy of ImportLedgerMessageSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportLedgerMessageSnapshotCopyWith<ImportLedgerMessageSnapshot> get copyWith => _$ImportLedgerMessageSnapshotCopyWithImpl<ImportLedgerMessageSnapshot>(this as ImportLedgerMessageSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportLedgerMessageSnapshot&&(identical(other.maxRowId, maxRowId) || other.maxRowId == maxRowId)&&(identical(other.totalMessageCount, totalMessageCount) || other.totalMessageCount == totalMessageCount));
}


@override
int get hashCode => Object.hash(runtimeType,maxRowId,totalMessageCount);

@override
String toString() {
  return 'ImportLedgerMessageSnapshot(maxRowId: $maxRowId, totalMessageCount: $totalMessageCount)';
}


}

/// @nodoc
abstract mixin class $ImportLedgerMessageSnapshotCopyWith<$Res>  {
  factory $ImportLedgerMessageSnapshotCopyWith(ImportLedgerMessageSnapshot value, $Res Function(ImportLedgerMessageSnapshot) _then) = _$ImportLedgerMessageSnapshotCopyWithImpl;
@useResult
$Res call({
 int maxRowId, int totalMessageCount
});




}
/// @nodoc
class _$ImportLedgerMessageSnapshotCopyWithImpl<$Res>
    implements $ImportLedgerMessageSnapshotCopyWith<$Res> {
  _$ImportLedgerMessageSnapshotCopyWithImpl(this._self, this._then);

  final ImportLedgerMessageSnapshot _self;
  final $Res Function(ImportLedgerMessageSnapshot) _then;

/// Create a copy of ImportLedgerMessageSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxRowId = null,Object? totalMessageCount = null,}) {
  return _then(_self.copyWith(
maxRowId: null == maxRowId ? _self.maxRowId : maxRowId // ignore: cast_nullable_to_non_nullable
as int,totalMessageCount: null == totalMessageCount ? _self.totalMessageCount : totalMessageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportLedgerMessageSnapshot].
extension ImportLedgerMessageSnapshotPatterns on ImportLedgerMessageSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportLedgerMessageSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportLedgerMessageSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportLedgerMessageSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ImportLedgerMessageSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportLedgerMessageSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ImportLedgerMessageSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int maxRowId,  int totalMessageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportLedgerMessageSnapshot() when $default != null:
return $default(_that.maxRowId,_that.totalMessageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int maxRowId,  int totalMessageCount)  $default,) {final _that = this;
switch (_that) {
case _ImportLedgerMessageSnapshot():
return $default(_that.maxRowId,_that.totalMessageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int maxRowId,  int totalMessageCount)?  $default,) {final _that = this;
switch (_that) {
case _ImportLedgerMessageSnapshot() when $default != null:
return $default(_that.maxRowId,_that.totalMessageCount);case _:
  return null;

}
}

}

/// @nodoc


class _ImportLedgerMessageSnapshot extends ImportLedgerMessageSnapshot {
  const _ImportLedgerMessageSnapshot({required this.maxRowId, required this.totalMessageCount}): super._();
  

@override final  int maxRowId;
@override final  int totalMessageCount;

/// Create a copy of ImportLedgerMessageSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportLedgerMessageSnapshotCopyWith<_ImportLedgerMessageSnapshot> get copyWith => __$ImportLedgerMessageSnapshotCopyWithImpl<_ImportLedgerMessageSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportLedgerMessageSnapshot&&(identical(other.maxRowId, maxRowId) || other.maxRowId == maxRowId)&&(identical(other.totalMessageCount, totalMessageCount) || other.totalMessageCount == totalMessageCount));
}


@override
int get hashCode => Object.hash(runtimeType,maxRowId,totalMessageCount);

@override
String toString() {
  return 'ImportLedgerMessageSnapshot(maxRowId: $maxRowId, totalMessageCount: $totalMessageCount)';
}


}

/// @nodoc
abstract mixin class _$ImportLedgerMessageSnapshotCopyWith<$Res> implements $ImportLedgerMessageSnapshotCopyWith<$Res> {
  factory _$ImportLedgerMessageSnapshotCopyWith(_ImportLedgerMessageSnapshot value, $Res Function(_ImportLedgerMessageSnapshot) _then) = __$ImportLedgerMessageSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int maxRowId, int totalMessageCount
});




}
/// @nodoc
class __$ImportLedgerMessageSnapshotCopyWithImpl<$Res>
    implements _$ImportLedgerMessageSnapshotCopyWith<$Res> {
  __$ImportLedgerMessageSnapshotCopyWithImpl(this._self, this._then);

  final _ImportLedgerMessageSnapshot _self;
  final $Res Function(_ImportLedgerMessageSnapshot) _then;

/// Create a copy of ImportLedgerMessageSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxRowId = null,Object? totalMessageCount = null,}) {
  return _then(_ImportLedgerMessageSnapshot(
maxRowId: null == maxRowId ? _self.maxRowId : maxRowId // ignore: cast_nullable_to_non_nullable
as int,totalMessageCount: null == totalMessageCount ? _self.totalMessageCount : totalMessageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
