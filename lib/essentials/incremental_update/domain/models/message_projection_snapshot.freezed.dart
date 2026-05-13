// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_projection_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageProjectionSnapshot {

 int get maxMessageId; int get totalMessageCount;
/// Create a copy of MessageProjectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageProjectionSnapshotCopyWith<MessageProjectionSnapshot> get copyWith => _$MessageProjectionSnapshotCopyWithImpl<MessageProjectionSnapshot>(this as MessageProjectionSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageProjectionSnapshot&&(identical(other.maxMessageId, maxMessageId) || other.maxMessageId == maxMessageId)&&(identical(other.totalMessageCount, totalMessageCount) || other.totalMessageCount == totalMessageCount));
}


@override
int get hashCode => Object.hash(runtimeType,maxMessageId,totalMessageCount);

@override
String toString() {
  return 'MessageProjectionSnapshot(maxMessageId: $maxMessageId, totalMessageCount: $totalMessageCount)';
}


}

/// @nodoc
abstract mixin class $MessageProjectionSnapshotCopyWith<$Res>  {
  factory $MessageProjectionSnapshotCopyWith(MessageProjectionSnapshot value, $Res Function(MessageProjectionSnapshot) _then) = _$MessageProjectionSnapshotCopyWithImpl;
@useResult
$Res call({
 int maxMessageId, int totalMessageCount
});




}
/// @nodoc
class _$MessageProjectionSnapshotCopyWithImpl<$Res>
    implements $MessageProjectionSnapshotCopyWith<$Res> {
  _$MessageProjectionSnapshotCopyWithImpl(this._self, this._then);

  final MessageProjectionSnapshot _self;
  final $Res Function(MessageProjectionSnapshot) _then;

/// Create a copy of MessageProjectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxMessageId = null,Object? totalMessageCount = null,}) {
  return _then(_self.copyWith(
maxMessageId: null == maxMessageId ? _self.maxMessageId : maxMessageId // ignore: cast_nullable_to_non_nullable
as int,totalMessageCount: null == totalMessageCount ? _self.totalMessageCount : totalMessageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageProjectionSnapshot].
extension MessageProjectionSnapshotPatterns on MessageProjectionSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageProjectionSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageProjectionSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageProjectionSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _MessageProjectionSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageProjectionSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _MessageProjectionSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int maxMessageId,  int totalMessageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageProjectionSnapshot() when $default != null:
return $default(_that.maxMessageId,_that.totalMessageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int maxMessageId,  int totalMessageCount)  $default,) {final _that = this;
switch (_that) {
case _MessageProjectionSnapshot():
return $default(_that.maxMessageId,_that.totalMessageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int maxMessageId,  int totalMessageCount)?  $default,) {final _that = this;
switch (_that) {
case _MessageProjectionSnapshot() when $default != null:
return $default(_that.maxMessageId,_that.totalMessageCount);case _:
  return null;

}
}

}

/// @nodoc


class _MessageProjectionSnapshot implements MessageProjectionSnapshot {
  const _MessageProjectionSnapshot({required this.maxMessageId, required this.totalMessageCount});
  

@override final  int maxMessageId;
@override final  int totalMessageCount;

/// Create a copy of MessageProjectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageProjectionSnapshotCopyWith<_MessageProjectionSnapshot> get copyWith => __$MessageProjectionSnapshotCopyWithImpl<_MessageProjectionSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageProjectionSnapshot&&(identical(other.maxMessageId, maxMessageId) || other.maxMessageId == maxMessageId)&&(identical(other.totalMessageCount, totalMessageCount) || other.totalMessageCount == totalMessageCount));
}


@override
int get hashCode => Object.hash(runtimeType,maxMessageId,totalMessageCount);

@override
String toString() {
  return 'MessageProjectionSnapshot(maxMessageId: $maxMessageId, totalMessageCount: $totalMessageCount)';
}


}

/// @nodoc
abstract mixin class _$MessageProjectionSnapshotCopyWith<$Res> implements $MessageProjectionSnapshotCopyWith<$Res> {
  factory _$MessageProjectionSnapshotCopyWith(_MessageProjectionSnapshot value, $Res Function(_MessageProjectionSnapshot) _then) = __$MessageProjectionSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int maxMessageId, int totalMessageCount
});




}
/// @nodoc
class __$MessageProjectionSnapshotCopyWithImpl<$Res>
    implements _$MessageProjectionSnapshotCopyWith<$Res> {
  __$MessageProjectionSnapshotCopyWithImpl(this._self, this._then);

  final _MessageProjectionSnapshot _self;
  final $Res Function(_MessageProjectionSnapshot) _then;

/// Create a copy of MessageProjectionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxMessageId = null,Object? totalMessageCount = null,}) {
  return _then(_MessageProjectionSnapshot(
maxMessageId: null == maxMessageId ? _self.maxMessageId : maxMessageId // ignore: cast_nullable_to_non_nullable
as int,totalMessageCount: null == totalMessageCount ? _self.totalMessageCount : totalMessageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
