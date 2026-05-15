// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatSnapshot {

 int get maxRowId; int get totalChatCount;
/// Create a copy of ChatSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatSnapshotCopyWith<ChatSnapshot> get copyWith => _$ChatSnapshotCopyWithImpl<ChatSnapshot>(this as ChatSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSnapshot&&(identical(other.maxRowId, maxRowId) || other.maxRowId == maxRowId)&&(identical(other.totalChatCount, totalChatCount) || other.totalChatCount == totalChatCount));
}


@override
int get hashCode => Object.hash(runtimeType,maxRowId,totalChatCount);

@override
String toString() {
  return 'ChatSnapshot(maxRowId: $maxRowId, totalChatCount: $totalChatCount)';
}


}

/// @nodoc
abstract mixin class $ChatSnapshotCopyWith<$Res>  {
  factory $ChatSnapshotCopyWith(ChatSnapshot value, $Res Function(ChatSnapshot) _then) = _$ChatSnapshotCopyWithImpl;
@useResult
$Res call({
 int maxRowId, int totalChatCount
});




}
/// @nodoc
class _$ChatSnapshotCopyWithImpl<$Res>
    implements $ChatSnapshotCopyWith<$Res> {
  _$ChatSnapshotCopyWithImpl(this._self, this._then);

  final ChatSnapshot _self;
  final $Res Function(ChatSnapshot) _then;

/// Create a copy of ChatSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxRowId = null,Object? totalChatCount = null,}) {
  return _then(_self.copyWith(
maxRowId: null == maxRowId ? _self.maxRowId : maxRowId // ignore: cast_nullable_to_non_nullable
as int,totalChatCount: null == totalChatCount ? _self.totalChatCount : totalChatCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatSnapshot].
extension ChatSnapshotPatterns on ChatSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ChatSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ChatSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int maxRowId,  int totalChatCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatSnapshot() when $default != null:
return $default(_that.maxRowId,_that.totalChatCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int maxRowId,  int totalChatCount)  $default,) {final _that = this;
switch (_that) {
case _ChatSnapshot():
return $default(_that.maxRowId,_that.totalChatCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int maxRowId,  int totalChatCount)?  $default,) {final _that = this;
switch (_that) {
case _ChatSnapshot() when $default != null:
return $default(_that.maxRowId,_that.totalChatCount);case _:
  return null;

}
}

}

/// @nodoc


class _ChatSnapshot implements ChatSnapshot {
  const _ChatSnapshot({required this.maxRowId, required this.totalChatCount});
  

@override final  int maxRowId;
@override final  int totalChatCount;

/// Create a copy of ChatSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatSnapshotCopyWith<_ChatSnapshot> get copyWith => __$ChatSnapshotCopyWithImpl<_ChatSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSnapshot&&(identical(other.maxRowId, maxRowId) || other.maxRowId == maxRowId)&&(identical(other.totalChatCount, totalChatCount) || other.totalChatCount == totalChatCount));
}


@override
int get hashCode => Object.hash(runtimeType,maxRowId,totalChatCount);

@override
String toString() {
  return 'ChatSnapshot(maxRowId: $maxRowId, totalChatCount: $totalChatCount)';
}


}

/// @nodoc
abstract mixin class _$ChatSnapshotCopyWith<$Res> implements $ChatSnapshotCopyWith<$Res> {
  factory _$ChatSnapshotCopyWith(_ChatSnapshot value, $Res Function(_ChatSnapshot) _then) = __$ChatSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int maxRowId, int totalChatCount
});




}
/// @nodoc
class __$ChatSnapshotCopyWithImpl<$Res>
    implements _$ChatSnapshotCopyWith<$Res> {
  __$ChatSnapshotCopyWithImpl(this._self, this._then);

  final _ChatSnapshot _self;
  final $Res Function(_ChatSnapshot) _then;

/// Create a copy of ChatSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxRowId = null,Object? totalChatCount = null,}) {
  return _then(_ChatSnapshot(
maxRowId: null == maxRowId ? _self.maxRowId : maxRowId // ignore: cast_nullable_to_non_nullable
as int,totalChatCount: null == totalChatCount ? _self.totalChatCount : totalChatCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
