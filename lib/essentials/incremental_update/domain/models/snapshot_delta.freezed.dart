// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'snapshot_delta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageSnapshotDelta {

 int get rowIdDelta; int get messageCountDelta;
/// Create a copy of MessageSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSnapshotDeltaCopyWith<MessageSnapshotDelta> get copyWith => _$MessageSnapshotDeltaCopyWithImpl<MessageSnapshotDelta>(this as MessageSnapshotDelta, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSnapshotDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.messageCountDelta, messageCountDelta) || other.messageCountDelta == messageCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,messageCountDelta);

@override
String toString() {
  return 'MessageSnapshotDelta(rowIdDelta: $rowIdDelta, messageCountDelta: $messageCountDelta)';
}


}

/// @nodoc
abstract mixin class $MessageSnapshotDeltaCopyWith<$Res>  {
  factory $MessageSnapshotDeltaCopyWith(MessageSnapshotDelta value, $Res Function(MessageSnapshotDelta) _then) = _$MessageSnapshotDeltaCopyWithImpl;
@useResult
$Res call({
 int rowIdDelta, int messageCountDelta
});




}
/// @nodoc
class _$MessageSnapshotDeltaCopyWithImpl<$Res>
    implements $MessageSnapshotDeltaCopyWith<$Res> {
  _$MessageSnapshotDeltaCopyWithImpl(this._self, this._then);

  final MessageSnapshotDelta _self;
  final $Res Function(MessageSnapshotDelta) _then;

/// Create a copy of MessageSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowIdDelta = null,Object? messageCountDelta = null,}) {
  return _then(_self.copyWith(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,messageCountDelta: null == messageCountDelta ? _self.messageCountDelta : messageCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageSnapshotDelta].
extension MessageSnapshotDeltaPatterns on MessageSnapshotDelta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageSnapshotDelta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageSnapshotDelta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageSnapshotDelta value)  $default,){
final _that = this;
switch (_that) {
case _MessageSnapshotDelta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageSnapshotDelta value)?  $default,){
final _that = this;
switch (_that) {
case _MessageSnapshotDelta() when $default != null:
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
case _MessageSnapshotDelta() when $default != null:
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
case _MessageSnapshotDelta():
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
case _MessageSnapshotDelta() when $default != null:
return $default(_that.rowIdDelta,_that.messageCountDelta);case _:
  return null;

}
}

}

/// @nodoc


class _MessageSnapshotDelta extends MessageSnapshotDelta {
  const _MessageSnapshotDelta({required this.rowIdDelta, required this.messageCountDelta}): super._();
  

@override final  int rowIdDelta;
@override final  int messageCountDelta;

/// Create a copy of MessageSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSnapshotDeltaCopyWith<_MessageSnapshotDelta> get copyWith => __$MessageSnapshotDeltaCopyWithImpl<_MessageSnapshotDelta>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSnapshotDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.messageCountDelta, messageCountDelta) || other.messageCountDelta == messageCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,messageCountDelta);

@override
String toString() {
  return 'MessageSnapshotDelta(rowIdDelta: $rowIdDelta, messageCountDelta: $messageCountDelta)';
}


}

/// @nodoc
abstract mixin class _$MessageSnapshotDeltaCopyWith<$Res> implements $MessageSnapshotDeltaCopyWith<$Res> {
  factory _$MessageSnapshotDeltaCopyWith(_MessageSnapshotDelta value, $Res Function(_MessageSnapshotDelta) _then) = __$MessageSnapshotDeltaCopyWithImpl;
@override @useResult
$Res call({
 int rowIdDelta, int messageCountDelta
});




}
/// @nodoc
class __$MessageSnapshotDeltaCopyWithImpl<$Res>
    implements _$MessageSnapshotDeltaCopyWith<$Res> {
  __$MessageSnapshotDeltaCopyWithImpl(this._self, this._then);

  final _MessageSnapshotDelta _self;
  final $Res Function(_MessageSnapshotDelta) _then;

/// Create a copy of MessageSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowIdDelta = null,Object? messageCountDelta = null,}) {
  return _then(_MessageSnapshotDelta(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,messageCountDelta: null == messageCountDelta ? _self.messageCountDelta : messageCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
