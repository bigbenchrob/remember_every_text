// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_snapshot_delta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatSnapshotDelta {

 int get rowIdDelta; int get chatCountDelta;
/// Create a copy of ChatSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatSnapshotDeltaCopyWith<ChatSnapshotDelta> get copyWith => _$ChatSnapshotDeltaCopyWithImpl<ChatSnapshotDelta>(this as ChatSnapshotDelta, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSnapshotDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.chatCountDelta, chatCountDelta) || other.chatCountDelta == chatCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,chatCountDelta);

@override
String toString() {
  return 'ChatSnapshotDelta(rowIdDelta: $rowIdDelta, chatCountDelta: $chatCountDelta)';
}


}

/// @nodoc
abstract mixin class $ChatSnapshotDeltaCopyWith<$Res>  {
  factory $ChatSnapshotDeltaCopyWith(ChatSnapshotDelta value, $Res Function(ChatSnapshotDelta) _then) = _$ChatSnapshotDeltaCopyWithImpl;
@useResult
$Res call({
 int rowIdDelta, int chatCountDelta
});




}
/// @nodoc
class _$ChatSnapshotDeltaCopyWithImpl<$Res>
    implements $ChatSnapshotDeltaCopyWith<$Res> {
  _$ChatSnapshotDeltaCopyWithImpl(this._self, this._then);

  final ChatSnapshotDelta _self;
  final $Res Function(ChatSnapshotDelta) _then;

/// Create a copy of ChatSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowIdDelta = null,Object? chatCountDelta = null,}) {
  return _then(_self.copyWith(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,chatCountDelta: null == chatCountDelta ? _self.chatCountDelta : chatCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatSnapshotDelta].
extension ChatSnapshotDeltaPatterns on ChatSnapshotDelta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatSnapshotDelta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatSnapshotDelta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatSnapshotDelta value)  $default,){
final _that = this;
switch (_that) {
case _ChatSnapshotDelta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatSnapshotDelta value)?  $default,){
final _that = this;
switch (_that) {
case _ChatSnapshotDelta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowIdDelta,  int chatCountDelta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatSnapshotDelta() when $default != null:
return $default(_that.rowIdDelta,_that.chatCountDelta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowIdDelta,  int chatCountDelta)  $default,) {final _that = this;
switch (_that) {
case _ChatSnapshotDelta():
return $default(_that.rowIdDelta,_that.chatCountDelta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowIdDelta,  int chatCountDelta)?  $default,) {final _that = this;
switch (_that) {
case _ChatSnapshotDelta() when $default != null:
return $default(_that.rowIdDelta,_that.chatCountDelta);case _:
  return null;

}
}

}

/// @nodoc


class _ChatSnapshotDelta extends ChatSnapshotDelta {
  const _ChatSnapshotDelta({required this.rowIdDelta, required this.chatCountDelta}): super._();
  

@override final  int rowIdDelta;
@override final  int chatCountDelta;

/// Create a copy of ChatSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatSnapshotDeltaCopyWith<_ChatSnapshotDelta> get copyWith => __$ChatSnapshotDeltaCopyWithImpl<_ChatSnapshotDelta>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatSnapshotDelta&&(identical(other.rowIdDelta, rowIdDelta) || other.rowIdDelta == rowIdDelta)&&(identical(other.chatCountDelta, chatCountDelta) || other.chatCountDelta == chatCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,rowIdDelta,chatCountDelta);

@override
String toString() {
  return 'ChatSnapshotDelta(rowIdDelta: $rowIdDelta, chatCountDelta: $chatCountDelta)';
}


}

/// @nodoc
abstract mixin class _$ChatSnapshotDeltaCopyWith<$Res> implements $ChatSnapshotDeltaCopyWith<$Res> {
  factory _$ChatSnapshotDeltaCopyWith(_ChatSnapshotDelta value, $Res Function(_ChatSnapshotDelta) _then) = __$ChatSnapshotDeltaCopyWithImpl;
@override @useResult
$Res call({
 int rowIdDelta, int chatCountDelta
});




}
/// @nodoc
class __$ChatSnapshotDeltaCopyWithImpl<$Res>
    implements _$ChatSnapshotDeltaCopyWith<$Res> {
  __$ChatSnapshotDeltaCopyWithImpl(this._self, this._then);

  final _ChatSnapshotDelta _self;
  final $Res Function(_ChatSnapshotDelta) _then;

/// Create a copy of ChatSnapshotDelta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowIdDelta = null,Object? chatCountDelta = null,}) {
  return _then(_ChatSnapshotDelta(
rowIdDelta: null == rowIdDelta ? _self.rowIdDelta : rowIdDelta // ignore: cast_nullable_to_non_nullable
as int,chatCountDelta: null == chatCountDelta ? _self.chatCountDelta : chatCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
