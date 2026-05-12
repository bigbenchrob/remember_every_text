// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_assessment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncAssessment {

 MessageSyncState get syncAssessment;
/// Create a copy of SyncAssessment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncAssessmentCopyWith<SyncAssessment> get copyWith => _$SyncAssessmentCopyWithImpl<SyncAssessment>(this as SyncAssessment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncAssessment&&(identical(other.syncAssessment, syncAssessment) || other.syncAssessment == syncAssessment));
}


@override
int get hashCode => Object.hash(runtimeType,syncAssessment);

@override
String toString() {
  return 'SyncAssessment(syncAssessment: $syncAssessment)';
}


}

/// @nodoc
abstract mixin class $SyncAssessmentCopyWith<$Res>  {
  factory $SyncAssessmentCopyWith(SyncAssessment value, $Res Function(SyncAssessment) _then) = _$SyncAssessmentCopyWithImpl;
@useResult
$Res call({
 MessageSyncState syncAssessment
});


$MessageSyncStateCopyWith<$Res> get syncAssessment;

}
/// @nodoc
class _$SyncAssessmentCopyWithImpl<$Res>
    implements $SyncAssessmentCopyWith<$Res> {
  _$SyncAssessmentCopyWithImpl(this._self, this._then);

  final SyncAssessment _self;
  final $Res Function(SyncAssessment) _then;

/// Create a copy of SyncAssessment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? syncAssessment = null,}) {
  return _then(_self.copyWith(
syncAssessment: null == syncAssessment ? _self.syncAssessment : syncAssessment // ignore: cast_nullable_to_non_nullable
as MessageSyncState,
  ));
}
/// Create a copy of SyncAssessment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSyncStateCopyWith<$Res> get syncAssessment {
  
  return $MessageSyncStateCopyWith<$Res>(_self.syncAssessment, (value) {
    return _then(_self.copyWith(syncAssessment: value));
  });
}
}


/// Adds pattern-matching-related methods to [SyncAssessment].
extension SyncAssessmentPatterns on SyncAssessment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncAssessment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncAssessment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncAssessment value)  $default,){
final _that = this;
switch (_that) {
case _SyncAssessment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncAssessment value)?  $default,){
final _that = this;
switch (_that) {
case _SyncAssessment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MessageSyncState syncAssessment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncAssessment() when $default != null:
return $default(_that.syncAssessment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MessageSyncState syncAssessment)  $default,) {final _that = this;
switch (_that) {
case _SyncAssessment():
return $default(_that.syncAssessment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MessageSyncState syncAssessment)?  $default,) {final _that = this;
switch (_that) {
case _SyncAssessment() when $default != null:
return $default(_that.syncAssessment);case _:
  return null;

}
}

}

/// @nodoc


class _SyncAssessment extends SyncAssessment {
  const _SyncAssessment({required this.syncAssessment}): super._();
  

@override final  MessageSyncState syncAssessment;

/// Create a copy of SyncAssessment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncAssessmentCopyWith<_SyncAssessment> get copyWith => __$SyncAssessmentCopyWithImpl<_SyncAssessment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncAssessment&&(identical(other.syncAssessment, syncAssessment) || other.syncAssessment == syncAssessment));
}


@override
int get hashCode => Object.hash(runtimeType,syncAssessment);

@override
String toString() {
  return 'SyncAssessment(syncAssessment: $syncAssessment)';
}


}

/// @nodoc
abstract mixin class _$SyncAssessmentCopyWith<$Res> implements $SyncAssessmentCopyWith<$Res> {
  factory _$SyncAssessmentCopyWith(_SyncAssessment value, $Res Function(_SyncAssessment) _then) = __$SyncAssessmentCopyWithImpl;
@override @useResult
$Res call({
 MessageSyncState syncAssessment
});


@override $MessageSyncStateCopyWith<$Res> get syncAssessment;

}
/// @nodoc
class __$SyncAssessmentCopyWithImpl<$Res>
    implements _$SyncAssessmentCopyWith<$Res> {
  __$SyncAssessmentCopyWithImpl(this._self, this._then);

  final _SyncAssessment _self;
  final $Res Function(_SyncAssessment) _then;

/// Create a copy of SyncAssessment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? syncAssessment = null,}) {
  return _then(_SyncAssessment(
syncAssessment: null == syncAssessment ? _self.syncAssessment : syncAssessment // ignore: cast_nullable_to_non_nullable
as MessageSyncState,
  ));
}

/// Create a copy of SyncAssessment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSyncStateCopyWith<$Res> get syncAssessment {
  
  return $MessageSyncStateCopyWith<$Res>(_self.syncAssessment, (value) {
    return _then(_self.copyWith(syncAssessment: value));
  });
}
}

// dart format on
