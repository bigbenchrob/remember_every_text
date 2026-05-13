// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_migration_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageMigrationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageMigrationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageMigrationState()';
}


}

/// @nodoc
class $MessageMigrationStateCopyWith<$Res>  {
$MessageMigrationStateCopyWith(MessageMigrationState _, $Res Function(MessageMigrationState) __);
}


/// Adds pattern-matching-related methods to [MessageMigrationState].
extension MessageMigrationStatePatterns on MessageMigrationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MessageMigrationProjectionCaughtUp value)?  projectionCaughtUp,TResult Function( MessageMigrationLedgerAheadOfProjection value)?  ledgerAheadOfProjection,TResult Function( MessageMigrationProjectionAheadOfLedger value)?  projectionAheadOfLedger,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MessageMigrationProjectionCaughtUp() when projectionCaughtUp != null:
return projectionCaughtUp(_that);case MessageMigrationLedgerAheadOfProjection() when ledgerAheadOfProjection != null:
return ledgerAheadOfProjection(_that);case MessageMigrationProjectionAheadOfLedger() when projectionAheadOfLedger != null:
return projectionAheadOfLedger(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MessageMigrationProjectionCaughtUp value)  projectionCaughtUp,required TResult Function( MessageMigrationLedgerAheadOfProjection value)  ledgerAheadOfProjection,required TResult Function( MessageMigrationProjectionAheadOfLedger value)  projectionAheadOfLedger,}){
final _that = this;
switch (_that) {
case MessageMigrationProjectionCaughtUp():
return projectionCaughtUp(_that);case MessageMigrationLedgerAheadOfProjection():
return ledgerAheadOfProjection(_that);case MessageMigrationProjectionAheadOfLedger():
return projectionAheadOfLedger(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MessageMigrationProjectionCaughtUp value)?  projectionCaughtUp,TResult? Function( MessageMigrationLedgerAheadOfProjection value)?  ledgerAheadOfProjection,TResult? Function( MessageMigrationProjectionAheadOfLedger value)?  projectionAheadOfLedger,}){
final _that = this;
switch (_that) {
case MessageMigrationProjectionCaughtUp() when projectionCaughtUp != null:
return projectionCaughtUp(_that);case MessageMigrationLedgerAheadOfProjection() when ledgerAheadOfProjection != null:
return ledgerAheadOfProjection(_that);case MessageMigrationProjectionAheadOfLedger() when projectionAheadOfLedger != null:
return projectionAheadOfLedger(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  projectionCaughtUp,TResult Function()?  ledgerAheadOfProjection,TResult Function()?  projectionAheadOfLedger,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MessageMigrationProjectionCaughtUp() when projectionCaughtUp != null:
return projectionCaughtUp();case MessageMigrationLedgerAheadOfProjection() when ledgerAheadOfProjection != null:
return ledgerAheadOfProjection();case MessageMigrationProjectionAheadOfLedger() when projectionAheadOfLedger != null:
return projectionAheadOfLedger();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  projectionCaughtUp,required TResult Function()  ledgerAheadOfProjection,required TResult Function()  projectionAheadOfLedger,}) {final _that = this;
switch (_that) {
case MessageMigrationProjectionCaughtUp():
return projectionCaughtUp();case MessageMigrationLedgerAheadOfProjection():
return ledgerAheadOfProjection();case MessageMigrationProjectionAheadOfLedger():
return projectionAheadOfLedger();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  projectionCaughtUp,TResult? Function()?  ledgerAheadOfProjection,TResult? Function()?  projectionAheadOfLedger,}) {final _that = this;
switch (_that) {
case MessageMigrationProjectionCaughtUp() when projectionCaughtUp != null:
return projectionCaughtUp();case MessageMigrationLedgerAheadOfProjection() when ledgerAheadOfProjection != null:
return ledgerAheadOfProjection();case MessageMigrationProjectionAheadOfLedger() when projectionAheadOfLedger != null:
return projectionAheadOfLedger();case _:
  return null;

}
}

}

/// @nodoc


class MessageMigrationProjectionCaughtUp implements MessageMigrationState {
  const MessageMigrationProjectionCaughtUp();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageMigrationProjectionCaughtUp);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageMigrationState.projectionCaughtUp()';
}


}




/// @nodoc


class MessageMigrationLedgerAheadOfProjection implements MessageMigrationState {
  const MessageMigrationLedgerAheadOfProjection();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageMigrationLedgerAheadOfProjection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageMigrationState.ledgerAheadOfProjection()';
}


}




/// @nodoc


class MessageMigrationProjectionAheadOfLedger implements MessageMigrationState {
  const MessageMigrationProjectionAheadOfLedger();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageMigrationProjectionAheadOfLedger);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageMigrationState.projectionAheadOfLedger()';
}


}




// dart format on
