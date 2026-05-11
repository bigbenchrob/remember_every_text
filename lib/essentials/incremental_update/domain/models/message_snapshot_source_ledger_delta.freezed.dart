// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_snapshot_source_ledger_delta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageSnapshotSourceLedgerDelta {

 int get rowIdDelta; int get messageCountDelta;
/// Create a copy of MessageSnapshotSourceLedgerDelta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSnapshotSourceLedgerDeltaCopyWith<MessageSnapshotSourceLedgerDelta> get copyWith => _$MessageSnapshotSourceLedgerDeltaCopyWithImpl<MessageSnapshotSourceLedgerDelta>(this as MessageSnapshotSourceLedgerDelta, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSnapshotSourceLedgerDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.messageCountDelta, messageCountDelta) || other.messageCountDelta == messageCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,messageCountDelta);

@override
String toString() {
  return 'MessageSnapshotSourceLedgerDelta(rowIdDelta: $rowIdDelta, messageCountDelta: $messageCountDelta)';
}


}

/// @nodoc
abstract mixin class $MessageSnapshotSourceLedgerDeltaCopyWith<$Res>  {
  factory $MessageSnapshotSourceLedgerDeltaCopyWith(MessageSnapshotSourceLedgerDelta value, $Res Function(MessageSnapshotSourceLedgerDelta) _then) = _$MessageSnapshotSourceLedgerDeltaCopyWithImpl;
@useResult
$Res call({
 int rowIdDelta, int messageCountDelta
});




}
/// @nodoc
class _$MessageSnapshotSourceLedgerDeltaCopyWithImpl<$Res>
    implements $MessageSnapshotSourceLedgerDeltaCopyWith<$Res> {
  _$MessageSnapshotSourceLedgerDeltaCopyWithImpl(this._self, this._then);

  final MessageSnapshotSourceLedgerDelta _self;
  final $Res Function(MessageSnapshotSourceLedgerDelta) _then;

/// Create a copy of MessageSnapshotSourceLedgerDelta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowIdDelta = null,Object? messageCountDelta = null,}) {
  return _then(_self.copyWith(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,messageCountDelta: null == messageCountDelta ? _self.messageCountDelta : messageCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageSnapshotSourceLedgerDelta].
extension MessageSnapshotSourceLedgerDeltaPatterns on MessageSnapshotSourceLedgerDelta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageSnapshotSourceLedgerDelta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageSnapshotSourceLedgerDelta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageSnapshotSourceLedgerDelta value)  $default,){
final _that = this;
switch (_that) {
case _MessageSnapshotSourceLedgerDelta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageSnapshotSourceLedgerDelta value)?  $default,){
final _that = this;
switch (_that) {
case _MessageSnapshotSourceLedgerDelta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowIdDelta,  int messageCountDelta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageSnapshotSourceLedgerDelta() when $default != null:
return $default(_that.rowIdDelta,_that.messageCountDelta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowIdDelta,  int messageCountDelta)  $default,) {final _that = this;
switch (_that) {
case _MessageSnapshotSourceLedgerDelta():
return $default(_that.rowIdDelta,_that.messageCountDelta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowIdDelta,  int messageCountDelta)?  $default,) {final _that = this;
switch (_that) {
case _MessageSnapshotSourceLedgerDelta() when $default != null:
return $default(_that.rowIdDelta,_that.messageCountDelta);case _:
  return null;

}
}

}

/// @nodoc


class _MessageSnapshotSourceLedgerDelta extends MessageSnapshotSourceLedgerDelta {
  const _MessageSnapshotSourceLedgerDelta({required this.rowIdDelta, required this.messageCountDelta}): super._();
  

@override final  int rowIdDelta;
@override final  int messageCountDelta;

/// Create a copy of MessageSnapshotSourceLedgerDelta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSnapshotSourceLedgerDeltaCopyWith<_MessageSnapshotSourceLedgerDelta> get copyWith => __$MessageSnapshotSourceLedgerDeltaCopyWithImpl<_MessageSnapshotSourceLedgerDelta>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSnapshotSourceLedgerDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.messageCountDelta, messageCountDelta) || other.messageCountDelta == messageCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,messageCountDelta);

@override
String toString() {
  return 'MessageSnapshotSourceLedgerDelta(rowIdDelta: $rowIdDelta, messageCountDelta: $messageCountDelta)';
}


}

/// @nodoc
abstract mixin class _$MessageSnapshotSourceLedgerDeltaCopyWith<$Res> implements $MessageSnapshotSourceLedgerDeltaCopyWith<$Res> {
  factory _$MessageSnapshotSourceLedgerDeltaCopyWith(_MessageSnapshotSourceLedgerDelta value, $Res Function(_MessageSnapshotSourceLedgerDelta) _then) = __$MessageSnapshotSourceLedgerDeltaCopyWithImpl;
@override @useResult
$Res call({
 int rowIdDelta, int messageCountDelta
});




}
/// @nodoc
class __$MessageSnapshotSourceLedgerDeltaCopyWithImpl<$Res>
    implements _$MessageSnapshotSourceLedgerDeltaCopyWith<$Res> {
  __$MessageSnapshotSourceLedgerDeltaCopyWithImpl(this._self, this._then);

  final _MessageSnapshotSourceLedgerDelta _self;
  final $Res Function(_MessageSnapshotSourceLedgerDelta) _then;

/// Create a copy of MessageSnapshotSourceLedgerDelta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowIdDelta = null,Object? messageCountDelta = null,}) {
  return _then(_MessageSnapshotSourceLedgerDelta(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,messageCountDelta: null == messageCountDelta ? _self.messageCountDelta : messageCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
