// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'environment_readiness_view_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EnvironmentReadinessSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvironmentReadinessSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EnvironmentReadinessSpec()';
}


}

/// @nodoc
class $EnvironmentReadinessSpecCopyWith<$Res>  {
$EnvironmentReadinessSpecCopyWith(EnvironmentReadinessSpec _, $Res Function(EnvironmentReadinessSpec) __);
}


/// Adds pattern-matching-related methods to [EnvironmentReadinessSpec].
extension EnvironmentReadinessSpecPatterns on EnvironmentReadinessSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ReadinessPanel value)?  readinessPanel,TResult Function( _PipelineIncidentPanel value)?  pipelineIncidentPanel,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadinessPanel() when readinessPanel != null:
return readinessPanel(_that);case _PipelineIncidentPanel() when pipelineIncidentPanel != null:
return pipelineIncidentPanel(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ReadinessPanel value)  readinessPanel,required TResult Function( _PipelineIncidentPanel value)  pipelineIncidentPanel,}){
final _that = this;
switch (_that) {
case _ReadinessPanel():
return readinessPanel(_that);case _PipelineIncidentPanel():
return pipelineIncidentPanel(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ReadinessPanel value)?  readinessPanel,TResult? Function( _PipelineIncidentPanel value)?  pipelineIncidentPanel,}){
final _that = this;
switch (_that) {
case _ReadinessPanel() when readinessPanel != null:
return readinessPanel(_that);case _PipelineIncidentPanel() when pipelineIncidentPanel != null:
return pipelineIncidentPanel(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  readinessPanel,TResult Function()?  pipelineIncidentPanel,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadinessPanel() when readinessPanel != null:
return readinessPanel();case _PipelineIncidentPanel() when pipelineIncidentPanel != null:
return pipelineIncidentPanel();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  readinessPanel,required TResult Function()  pipelineIncidentPanel,}) {final _that = this;
switch (_that) {
case _ReadinessPanel():
return readinessPanel();case _PipelineIncidentPanel():
return pipelineIncidentPanel();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  readinessPanel,TResult? Function()?  pipelineIncidentPanel,}) {final _that = this;
switch (_that) {
case _ReadinessPanel() when readinessPanel != null:
return readinessPanel();case _PipelineIncidentPanel() when pipelineIncidentPanel != null:
return pipelineIncidentPanel();case _:
  return null;

}
}

}

/// @nodoc


class _ReadinessPanel implements EnvironmentReadinessSpec {
  const _ReadinessPanel();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadinessPanel);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EnvironmentReadinessSpec.readinessPanel()';
}


}




/// @nodoc


class _PipelineIncidentPanel implements EnvironmentReadinessSpec {
  const _PipelineIncidentPanel();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PipelineIncidentPanel);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EnvironmentReadinessSpec.pipelineIncidentPanel()';
}


}




// dart format on
