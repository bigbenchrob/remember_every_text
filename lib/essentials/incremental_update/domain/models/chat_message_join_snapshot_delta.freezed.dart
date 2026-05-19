// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_join_snapshot_delta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatMessageJoinSnapshotDelta {

 int get rowIdDelta; int get joinCountDelta; int get messageRowIdDelta; int get chatRowIdDelta; bool get ledgerSourceScopedObservationAvailable;
/// Create a copy of ChatMessageJoinSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageJoinSnapshotDeltaCopyWith<ChatMessageJoinSnapshotDelta> get copyWith => _$ChatMessageJoinSnapshotDeltaCopyWithImpl<ChatMessageJoinSnapshotDelta>(this as ChatMessageJoinSnapshotDelta, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageJoinSnapshotDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.joinCountDelta, joinCountDelta) || other.joinCountDelta == joinCountDelta)&&(identical(other.messageRowIdDelta, messageRowIdDelta) || other.messageRowIdDelta == messageRowIdDelta)&&(identical(other.chatRowIdDelta, chatRowIdDelta) || other.chatRowIdDelta == chatRowIdDelta)&&(identical(other.ledgerSourceScopedObservationAvailable, ledgerSourceScopedObservationAvailable) || other.ledgerSourceScopedObservationAvailable == ledgerSourceScopedObservationAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,joinCountDelta,messageRowIdDelta,chatRowIdDelta,ledgerSourceScopedObservationAvailable);

@override
String toString() {
  return 'ChatMessageJoinSnapshotDelta(rowIdDelta: $rowIdDelta, joinCountDelta: $joinCountDelta, messageRowIdDelta: $messageRowIdDelta, chatRowIdDelta: $chatRowIdDelta, ledgerSourceScopedObservationAvailable: $ledgerSourceScopedObservationAvailable)';
}


}

/// @nodoc
abstract mixin class $ChatMessageJoinSnapshotDeltaCopyWith<$Res>  {
  factory $ChatMessageJoinSnapshotDeltaCopyWith(ChatMessageJoinSnapshotDelta value, $Res Function(ChatMessageJoinSnapshotDelta) _then) = _$ChatMessageJoinSnapshotDeltaCopyWithImpl;
@useResult
$Res call({
 int rowIdDelta, int joinCountDelta, int messageRowIdDelta, int chatRowIdDelta, bool ledgerSourceScopedObservationAvailable
});




}
/// @nodoc
class _$ChatMessageJoinSnapshotDeltaCopyWithImpl<$Res>
    implements $ChatMessageJoinSnapshotDeltaCopyWith<$Res> {
  _$ChatMessageJoinSnapshotDeltaCopyWithImpl(this._self, this._then);

  final ChatMessageJoinSnapshotDelta _self;
  final $Res Function(ChatMessageJoinSnapshotDelta) _then;

/// Create a copy of ChatMessageJoinSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowIdDelta = null,Object? joinCountDelta = null,Object? messageRowIdDelta = null,Object? chatRowIdDelta = null,Object? ledgerSourceScopedObservationAvailable = null,}) {
  return _then(_self.copyWith(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,joinCountDelta: null == joinCountDelta ? _self.joinCountDelta : joinCountDelta // ignore: cast_nullable_to_non_nullable
as int,messageRowIdDelta: null == messageRowIdDelta ? _self.messageRowIdDelta : messageRowIdDelta // ignore: cast_nullable_to_non_nullable
as int,chatRowIdDelta: null == chatRowIdDelta ? _self.chatRowIdDelta : chatRowIdDelta // ignore: cast_nullable_to_non_nullable
as int,ledgerSourceScopedObservationAvailable: null == ledgerSourceScopedObservationAvailable ? _self.ledgerSourceScopedObservationAvailable : ledgerSourceScopedObservationAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessageJoinSnapshotDelta].
extension ChatMessageJoinSnapshotDeltaPatterns on ChatMessageJoinSnapshotDelta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessageJoinSnapshotDelta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshotDelta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessageJoinSnapshotDelta value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshotDelta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessageJoinSnapshotDelta value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshotDelta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowIdDelta,  int joinCountDelta,  int messageRowIdDelta,  int chatRowIdDelta,  bool ledgerSourceScopedObservationAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshotDelta() when $default != null:
return $default(_that.rowIdDelta,_that.joinCountDelta,_that.messageRowIdDelta,_that.chatRowIdDelta,_that.ledgerSourceScopedObservationAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowIdDelta,  int joinCountDelta,  int messageRowIdDelta,  int chatRowIdDelta,  bool ledgerSourceScopedObservationAvailable)  $default,) {final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshotDelta():
return $default(_that.rowIdDelta,_that.joinCountDelta,_that.messageRowIdDelta,_that.chatRowIdDelta,_that.ledgerSourceScopedObservationAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowIdDelta,  int joinCountDelta,  int messageRowIdDelta,  int chatRowIdDelta,  bool ledgerSourceScopedObservationAvailable)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessageJoinSnapshotDelta() when $default != null:
return $default(_that.rowIdDelta,_that.joinCountDelta,_that.messageRowIdDelta,_that.chatRowIdDelta,_that.ledgerSourceScopedObservationAvailable);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessageJoinSnapshotDelta extends ChatMessageJoinSnapshotDelta {
  const _ChatMessageJoinSnapshotDelta({required this.rowIdDelta, required this.joinCountDelta, required this.messageRowIdDelta, required this.chatRowIdDelta, required this.ledgerSourceScopedObservationAvailable}): super._();
  

@override final  int rowIdDelta;
@override final  int joinCountDelta;
@override final  int messageRowIdDelta;
@override final  int chatRowIdDelta;
@override final  bool ledgerSourceScopedObservationAvailable;

/// Create a copy of ChatMessageJoinSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageJoinSnapshotDeltaCopyWith<_ChatMessageJoinSnapshotDelta> get copyWith => __$ChatMessageJoinSnapshotDeltaCopyWithImpl<_ChatMessageJoinSnapshotDelta>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessageJoinSnapshotDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.joinCountDelta, joinCountDelta) || other.joinCountDelta == joinCountDelta)&&(identical(other.messageRowIdDelta, messageRowIdDelta) || other.messageRowIdDelta == messageRowIdDelta)&&(identical(other.chatRowIdDelta, chatRowIdDelta) || other.chatRowIdDelta == chatRowIdDelta)&&(identical(other.ledgerSourceScopedObservationAvailable, ledgerSourceScopedObservationAvailable) || other.ledgerSourceScopedObservationAvailable == ledgerSourceScopedObservationAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,joinCountDelta,messageRowIdDelta,chatRowIdDelta,ledgerSourceScopedObservationAvailable);

@override
String toString() {
  return 'ChatMessageJoinSnapshotDelta(rowIdDelta: $rowIdDelta, joinCountDelta: $joinCountDelta, messageRowIdDelta: $messageRowIdDelta, chatRowIdDelta: $chatRowIdDelta, ledgerSourceScopedObservationAvailable: $ledgerSourceScopedObservationAvailable)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageJoinSnapshotDeltaCopyWith<$Res> implements $ChatMessageJoinSnapshotDeltaCopyWith<$Res> {
  factory _$ChatMessageJoinSnapshotDeltaCopyWith(_ChatMessageJoinSnapshotDelta value, $Res Function(_ChatMessageJoinSnapshotDelta) _then) = __$ChatMessageJoinSnapshotDeltaCopyWithImpl;
@override @useResult
$Res call({
 int rowIdDelta, int joinCountDelta, int messageRowIdDelta, int chatRowIdDelta, bool ledgerSourceScopedObservationAvailable
});




}
/// @nodoc
class __$ChatMessageJoinSnapshotDeltaCopyWithImpl<$Res>
    implements _$ChatMessageJoinSnapshotDeltaCopyWith<$Res> {
  __$ChatMessageJoinSnapshotDeltaCopyWithImpl(this._self, this._then);

  final _ChatMessageJoinSnapshotDelta _self;
  final $Res Function(_ChatMessageJoinSnapshotDelta) _then;

/// Create a copy of ChatMessageJoinSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowIdDelta = null,Object? joinCountDelta = null,Object? messageRowIdDelta = null,Object? chatRowIdDelta = null,Object? ledgerSourceScopedObservationAvailable = null,}) {
  return _then(_ChatMessageJoinSnapshotDelta(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,joinCountDelta: null == joinCountDelta ? _self.joinCountDelta : joinCountDelta // ignore: cast_nullable_to_non_nullable
as int,messageRowIdDelta: null == messageRowIdDelta ? _self.messageRowIdDelta : messageRowIdDelta // ignore: cast_nullable_to_non_nullable
as int,chatRowIdDelta: null == chatRowIdDelta ? _self.chatRowIdDelta : chatRowIdDelta // ignore: cast_nullable_to_non_nullable
as int,ledgerSourceScopedObservationAvailable: null == ledgerSourceScopedObservationAvailable ? _self.ledgerSourceScopedObservationAvailable : ledgerSourceScopedObservationAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
