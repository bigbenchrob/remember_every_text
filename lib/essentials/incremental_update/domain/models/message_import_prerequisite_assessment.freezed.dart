// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_import_prerequisite_assessment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageImportPrerequisiteAssessment {

 List<MessageImportBlocker> get blockers;
/// Create a copy of MessageImportPrerequisiteAssessment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageImportPrerequisiteAssessmentCopyWith<MessageImportPrerequisiteAssessment> get copyWith => _$MessageImportPrerequisiteAssessmentCopyWithImpl<MessageImportPrerequisiteAssessment>(this as MessageImportPrerequisiteAssessment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageImportPrerequisiteAssessment&&const DeepCollectionEquality().equals(other.blockers, blockers));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(blockers));

@override
String toString() {
  return 'MessageImportPrerequisiteAssessment(blockers: $blockers)';
}


}

/// @nodoc
abstract mixin class $MessageImportPrerequisiteAssessmentCopyWith<$Res>  {
  factory $MessageImportPrerequisiteAssessmentCopyWith(MessageImportPrerequisiteAssessment value, $Res Function(MessageImportPrerequisiteAssessment) _then) = _$MessageImportPrerequisiteAssessmentCopyWithImpl;
@useResult
$Res call({
 List<MessageImportBlocker> blockers
});




}
/// @nodoc
class _$MessageImportPrerequisiteAssessmentCopyWithImpl<$Res>
    implements $MessageImportPrerequisiteAssessmentCopyWith<$Res> {
  _$MessageImportPrerequisiteAssessmentCopyWithImpl(this._self, this._then);

  final MessageImportPrerequisiteAssessment _self;
  final $Res Function(MessageImportPrerequisiteAssessment) _then;

/// Create a copy of MessageImportPrerequisiteAssessment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blockers = null,}) {
  return _then(_self.copyWith(
blockers: null == blockers ? _self.blockers : blockers // ignore: cast_nullable_to_non_nullable
as List<MessageImportBlocker>,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageImportPrerequisiteAssessment].
extension MessageImportPrerequisiteAssessmentPatterns on MessageImportPrerequisiteAssessment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageImportPrerequisiteAssessment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageImportPrerequisiteAssessment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageImportPrerequisiteAssessment value)  $default,){
final _that = this;
switch (_that) {
case _MessageImportPrerequisiteAssessment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageImportPrerequisiteAssessment value)?  $default,){
final _that = this;
switch (_that) {
case _MessageImportPrerequisiteAssessment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MessageImportBlocker> blockers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageImportPrerequisiteAssessment() when $default != null:
return $default(_that.blockers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MessageImportBlocker> blockers)  $default,) {final _that = this;
switch (_that) {
case _MessageImportPrerequisiteAssessment():
return $default(_that.blockers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MessageImportBlocker> blockers)?  $default,) {final _that = this;
switch (_that) {
case _MessageImportPrerequisiteAssessment() when $default != null:
return $default(_that.blockers);case _:
  return null;

}
}

}

/// @nodoc


class _MessageImportPrerequisiteAssessment extends MessageImportPrerequisiteAssessment {
  const _MessageImportPrerequisiteAssessment({required final  List<MessageImportBlocker> blockers}): _blockers = blockers,super._();
  

 final  List<MessageImportBlocker> _blockers;
@override List<MessageImportBlocker> get blockers {
  if (_blockers is EqualUnmodifiableListView) return _blockers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockers);
}


/// Create a copy of MessageImportPrerequisiteAssessment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageImportPrerequisiteAssessmentCopyWith<_MessageImportPrerequisiteAssessment> get copyWith => __$MessageImportPrerequisiteAssessmentCopyWithImpl<_MessageImportPrerequisiteAssessment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageImportPrerequisiteAssessment&&const DeepCollectionEquality().equals(other._blockers, _blockers));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_blockers));

@override
String toString() {
  return 'MessageImportPrerequisiteAssessment(blockers: $blockers)';
}


}

/// @nodoc
abstract mixin class _$MessageImportPrerequisiteAssessmentCopyWith<$Res> implements $MessageImportPrerequisiteAssessmentCopyWith<$Res> {
  factory _$MessageImportPrerequisiteAssessmentCopyWith(_MessageImportPrerequisiteAssessment value, $Res Function(_MessageImportPrerequisiteAssessment) _then) = __$MessageImportPrerequisiteAssessmentCopyWithImpl;
@override @useResult
$Res call({
 List<MessageImportBlocker> blockers
});




}
/// @nodoc
class __$MessageImportPrerequisiteAssessmentCopyWithImpl<$Res>
    implements _$MessageImportPrerequisiteAssessmentCopyWith<$Res> {
  __$MessageImportPrerequisiteAssessmentCopyWithImpl(this._self, this._then);

  final _MessageImportPrerequisiteAssessment _self;
  final $Res Function(_MessageImportPrerequisiteAssessment) _then;

/// Create a copy of MessageImportPrerequisiteAssessment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blockers = null,}) {
  return _then(_MessageImportPrerequisiteAssessment(
blockers: null == blockers ? _self._blockers : blockers // ignore: cast_nullable_to_non_nullable
as List<MessageImportBlocker>,
  ));
}


}

// dart format on
