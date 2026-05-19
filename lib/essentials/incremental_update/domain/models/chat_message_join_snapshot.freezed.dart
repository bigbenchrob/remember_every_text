// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_join_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatMessageJoinSnapshot {

 int get maxRowId; int get totalJoinCount; int get maxMessageRowId; int get maxChatRowId; bool get sourceScopedObservationAvailable;
/// Create a copy of ChatMessageJoinSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageJoinSnapshotCopyWith<ChatMessageJoinSnapshot> get copyWith => _$ChatMessageJoinSnapshotCopyWithImpl<ChatMessageJoinSnapshot>(this as ChatMessageJoinSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageJoinSnapshot&&(identical(other.maxRowId, maxRowId) || other.maxRowId == maxRowId)&&(identical(other.totalJoinCount, totalJoinCount) || other.totalJoinCount == totalJoinCount)&&(identical(other.maxMessageRowId, maxMessageRowId) || other.maxMessageRowId == maxMessageRowId)&&(identical(other.maxChatRowId, maxChatRowId) || other.maxChatRowId == maxChatRowId)&&(identical(other.sourceScopedObservationAvailable, sourceScopedObservationAvailable) || other.sourceScopedObservationAvailable == sourceScopedObservationAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,maxRowId,totalJoinCount,maxMessageRowId,maxChatRowId,sourceScopedObservationAvailable);

@override
String toString() {
  return 'ChatMessageJoinSnapshot(maxRowId: $maxRowId, totalJoinCount: $totalJoinCount, maxMessageRowId: $maxMessageRowId, maxChatRowId: $maxChatRowId, sourceScopedObservationAvailable: $sourceScopedObservationAvailable)';
}


}

/// @nodoc
abstract mixin class $ChatMessageJoinSnapshotCopyWith<$Res>  {
  factory $ChatMessageJoinSnapshotCopyWith(ChatMessageJoinSnapshot value, $Res Function(ChatMessageJoinSnapshot) _then) = _$ChatMessageJoinSnapshotCopyWithImpl;
@useResult
$Res call({
 int maxRowId, int totalJoinCount, int maxMessageRowId, int maxChatRowId, bool sourceScopedObservationAvailable
});




}
/// @nodoc
class _$ChatMessageJoinSnapshotCopyWithImpl<$Res>
    implements $ChatMessageJoinSnapshotCopyWith<$Res> {
  _$ChatMessageJoinSnapshotCopyWithImpl(this._self, this._then);

  final ChatMessageJoinSnapshot _self;
  final $Res Function(ChatMessageJoinSnapshot) _then;

/// Create a copy of ChatMessageJoinSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxRowId = null,Object? totalJoinCount = null,Object? maxMessageRowId = null,Object? maxChatRowId = null,Object? sourceScopedObservationAvailable = null,}) {
  return _then(_self.copyWith(
maxRowId: null == maxRowId ? _self.maxRowId : maxRowId // ignore: cast_nullable_to_non_nullable
as int,totalJoinCount: null == totalJoinCount ? _self.totalJoinCount : totalJoinCount // ignore: cast_nullable_to_non_nullable
as int,maxMessageRowId: null == maxMessageRowId ? _self.maxMessageRowId : maxMessageRowId // ignore: cast_nullable_to_non_nullable
as int,maxChatRowId: null == maxChatRowId ? _self.maxChatRowId : maxChatRowId // ignore: cast_nullable_to_non_nullable
as int,sourceScopedObservationAvailable: null == sourceScopedObservationAvailable ? _self.sourceScopedObservationAvailable : sourceScopedObservationAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageJoinSnapshot].
extension ChatMessageJoinSnapshotPatterns on ChatMessageJoinSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageJoinSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageJoinSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageJoinSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int maxRowId,  int totalJoinCount,  int maxMessageRowId,  int maxChatRowId,  bool sourceScopedObservationAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshot() when $default != null:
return $default(_that.maxRowId,_that.totalJoinCount,_that.maxMessageRowId,_that.maxChatRowId,_that.sourceScopedObservationAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int maxRowId,  int totalJoinCount,  int maxMessageRowId,  int maxChatRowId,  bool sourceScopedObservationAvailable)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshot():
return $default(_that.maxRowId,_that.totalJoinCount,_that.maxMessageRowId,_that.maxChatRowId,_that.sourceScopedObservationAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int maxRowId,  int totalJoinCount,  int maxMessageRowId,  int maxChatRowId,  bool sourceScopedObservationAvailable)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshot() when $default != null:
return $default(_that.maxRowId,_that.totalJoinCount,_that.maxMessageRowId,_that.maxChatRowId,_that.sourceScopedObservationAvailable);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessageJoinSnapshot implements ChatMessageJoinSnapshot {
  const _ChatMessageJoinSnapshot({required this.maxRowId, required this.totalJoinCount, required this.maxMessageRowId, required this.maxChatRowId, required this.sourceScopedObservationAvailable});
  

@override final  int maxRowId;
@override final  int totalJoinCount;
@override final  int maxMessageRowId;
@override final  int maxChatRowId;
@override final  bool sourceScopedObservationAvailable;

/// Create a copy of ChatMessageJoinSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageJoinSnapshotCopyWith<_ChatMessageJoinSnapshot> get copyWith => __$ChatMessageJoinSnapshotCopyWithImpl<_ChatMessageJoinSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageJoinSnapshot&&(identical(other.maxRowId, maxRowId) || other.maxRowId == maxRowId)&&(identical(other.totalJoinCount, totalJoinCount) || other.totalJoinCount == totalJoinCount)&&(identical(other.maxMessageRowId, maxMessageRowId) || other.maxMessageRowId == maxMessageRowId)&&(identical(other.maxChatRowId, maxChatRowId) || other.maxChatRowId == maxChatRowId)&&(identical(other.sourceScopedObservationAvailable, sourceScopedObservationAvailable) || other.sourceScopedObservationAvailable == sourceScopedObservationAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,maxRowId,totalJoinCount,maxMessageRowId,maxChatRowId,sourceScopedObservationAvailable);

@override
String toString() {
  return 'ChatMessageJoinSnapshot(maxRowId: $maxRowId, totalJoinCount: $totalJoinCount, maxMessageRowId: $maxMessageRowId, maxChatRowId: $maxChatRowId, sourceScopedObservationAvailable: $sourceScopedObservationAvailable)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageJoinSnapshotCopyWith<$Res> implements $ChatMessageJoinSnapshotCopyWith<$Res> {
  factory _$ChatMessageJoinSnapshotCopyWith(_ChatMessageJoinSnapshot value, $Res Function(_ChatMessageJoinSnapshot) _then) = __$ChatMessageJoinSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int maxRowId, int totalJoinCount, int maxMessageRowId, int maxChatRowId, bool sourceScopedObservationAvailable
});




}
/// @nodoc
class __$ChatMessageJoinSnapshotCopyWithImpl<$Res>
    implements _$ChatMessageJoinSnapshotCopyWith<$Res> {
  __$ChatMessageJoinSnapshotCopyWithImpl(this._self, this._then);

  final _ChatMessageJoinSnapshot _self;
  final $Res Function(_ChatMessageJoinSnapshot) _then;

/// Create a copy of ChatMessageJoinSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxRowId = null,Object? totalJoinCount = null,Object? maxMessageRowId = null,Object? maxChatRowId = null,Object? sourceScopedObservationAvailable = null,}) {
  return _then(_ChatMessageJoinSnapshot(
maxRowId: null == maxRowId ? _self.maxRowId : maxRowId // ignore: cast_nullable_to_non_nullable
as int,totalJoinCount: null == totalJoinCount ? _self.totalJoinCount : totalJoinCount // ignore: cast_nullable_to_non_nullable
as int,maxMessageRowId: null == maxMessageRowId ? _self.maxMessageRowId : maxMessageRowId // ignore: cast_nullable_to_non_nullable
as int,maxChatRowId: null == maxChatRowId ? _self.maxChatRowId : maxChatRowId // ignore: cast_nullable_to_non_nullable
as int,sourceScopedObservationAvailable: null == sourceScopedObservationAvailable ? _self.sourceScopedObservationAvailable : sourceScopedObservationAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
