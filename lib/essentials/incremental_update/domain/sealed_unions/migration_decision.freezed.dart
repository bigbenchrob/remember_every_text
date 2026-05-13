// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'migration_decision.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MigrationDecision {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationDecision);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MigrationDecision()';
}


}

/// @nodoc
class $MigrationDecisionCopyWith<$Res>  {
$MigrationDecisionCopyWith(MigrationDecision _, $Res Function(MigrationDecision) __);
}


/// Adds pattern-matching-related methods to [MigrationDecision].
extension MigrationDecisionPatterns on MigrationDecision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MigrationDecisionDoNothing value)?  doNothing,TResult Function( MigrationDecisionConsiderShadowMigration value)?  considerShadowMigration,TResult Function( MigrationDecisionBlockAndReportProjectionAhead value)?  blockAndReportProjectionAhead,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MigrationDecisionDoNothing() when doNothing != null:
return doNothing(_that);case MigrationDecisionConsiderShadowMigration() when considerShadowMigration != null:
return considerShadowMigration(_that);case MigrationDecisionBlockAndReportProjectionAhead() when blockAndReportProjectionAhead != null:
return blockAndReportProjectionAhead(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MigrationDecisionDoNothing value)  doNothing,required TResult Function( MigrationDecisionConsiderShadowMigration value)  considerShadowMigration,required TResult Function( MigrationDecisionBlockAndReportProjectionAhead value)  blockAndReportProjectionAhead,}){
final _that = this;
switch (_that) {
case MigrationDecisionDoNothing():
return doNothing(_that);case MigrationDecisionConsiderShadowMigration():
return considerShadowMigration(_that);case MigrationDecisionBlockAndReportProjectionAhead():
return blockAndReportProjectionAhead(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MigrationDecisionDoNothing value)?  doNothing,TResult? Function( MigrationDecisionConsiderShadowMigration value)?  considerShadowMigration,TResult? Function( MigrationDecisionBlockAndReportProjectionAhead value)?  blockAndReportProjectionAhead,}){
final _that = this;
switch (_that) {
case MigrationDecisionDoNothing() when doNothing != null:
return doNothing(_that);case MigrationDecisionConsiderShadowMigration() when considerShadowMigration != null:
return considerShadowMigration(_that);case MigrationDecisionBlockAndReportProjectionAhead() when blockAndReportProjectionAhead != null:
return blockAndReportProjectionAhead(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  doNothing,TResult Function()?  considerShadowMigration,TResult Function()?  blockAndReportProjectionAhead,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MigrationDecisionDoNothing() when doNothing != null:
return doNothing();case MigrationDecisionConsiderShadowMigration() when considerShadowMigration != null:
return considerShadowMigration();case MigrationDecisionBlockAndReportProjectionAhead() when blockAndReportProjectionAhead != null:
return blockAndReportProjectionAhead();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  doNothing,required TResult Function()  considerShadowMigration,required TResult Function()  blockAndReportProjectionAhead,}) {final _that = this;
switch (_that) {
case MigrationDecisionDoNothing():
return doNothing();case MigrationDecisionConsiderShadowMigration():
return considerShadowMigration();case MigrationDecisionBlockAndReportProjectionAhead():
return blockAndReportProjectionAhead();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  doNothing,TResult? Function()?  considerShadowMigration,TResult? Function()?  blockAndReportProjectionAhead,}) {final _that = this;
switch (_that) {
case MigrationDecisionDoNothing() when doNothing != null:
return doNothing();case MigrationDecisionConsiderShadowMigration() when considerShadowMigration != null:
return considerShadowMigration();case MigrationDecisionBlockAndReportProjectionAhead() when blockAndReportProjectionAhead != null:
return blockAndReportProjectionAhead();case _:
  return null;

}
}

}

/// @nodoc


class MigrationDecisionDoNothing implements MigrationDecision {
  const MigrationDecisionDoNothing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationDecisionDoNothing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MigrationDecision.doNothing()';
}


}




/// @nodoc


class MigrationDecisionConsiderShadowMigration implements MigrationDecision {
  const MigrationDecisionConsiderShadowMigration();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationDecisionConsiderShadowMigration);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MigrationDecision.considerShadowMigration()';
}


}




/// @nodoc


class MigrationDecisionBlockAndReportProjectionAhead implements MigrationDecision {
  const MigrationDecisionBlockAndReportProjectionAhead();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationDecisionBlockAndReportProjectionAhead);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MigrationDecision.blockAndReportProjectionAhead()';
}


}




// dart format on
