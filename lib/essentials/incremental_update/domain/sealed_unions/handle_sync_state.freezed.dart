// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'handle_sync_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HandleSyncState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleSyncState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandleSyncState()';
}


}

/// @nodoc
class $HandleSyncStateCopyWith<$Res>  {
$HandleSyncStateCopyWith(HandleSyncState _, $Res Function(HandleSyncState) __);
}


/// Adds pattern-matching-related methods to [HandleSyncState].
extension HandleSyncStatePatterns on HandleSyncState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HandleSyncCursorsMatch value)?  sourceAndLedgerCursorsMatch,TResult Function( HandleSyncSourceAheadOfLedger value)?  sourceAheadOfLedger,TResult Function( HandleSyncLedgerAheadOfSource value)?  ledgerAheadOfSource,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HandleSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch(_that);case HandleSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger(_that);case HandleSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
return ledgerAheadOfSource(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HandleSyncCursorsMatch value)  sourceAndLedgerCursorsMatch,required TResult Function( HandleSyncSourceAheadOfLedger value)  sourceAheadOfLedger,required TResult Function( HandleSyncLedgerAheadOfSource value)  ledgerAheadOfSource,}){
final _that = this;
switch (_that) {
case HandleSyncCursorsMatch():
return sourceAndLedgerCursorsMatch(_that);case HandleSyncSourceAheadOfLedger():
return sourceAheadOfLedger(_that);case HandleSyncLedgerAheadOfSource():
return ledgerAheadOfSource(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HandleSyncCursorsMatch value)?  sourceAndLedgerCursorsMatch,TResult? Function( HandleSyncSourceAheadOfLedger value)?  sourceAheadOfLedger,TResult? Function( HandleSyncLedgerAheadOfSource value)?  ledgerAheadOfSource,}){
final _that = this;
switch (_that) {
case HandleSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch(_that);case HandleSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger(_that);case HandleSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
return ledgerAheadOfSource(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  sourceAndLedgerCursorsMatch,TResult Function()?  sourceAheadOfLedger,TResult Function()?  ledgerAheadOfSource,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HandleSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch();case HandleSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger();case HandleSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
return ledgerAheadOfSource();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  sourceAndLedgerCursorsMatch,required TResult Function()  sourceAheadOfLedger,required TResult Function()  ledgerAheadOfSource,}) {final _that = this;
switch (_that) {
case HandleSyncCursorsMatch():
return sourceAndLedgerCursorsMatch();case HandleSyncSourceAheadOfLedger():
return sourceAheadOfLedger();case HandleSyncLedgerAheadOfSource():
return ledgerAheadOfSource();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  sourceAndLedgerCursorsMatch,TResult? Function()?  sourceAheadOfLedger,TResult? Function()?  ledgerAheadOfSource,}) {final _that = this;
switch (_that) {
case HandleSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch();case HandleSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger();case HandleSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
return ledgerAheadOfSource();case _:
  return null;

}
}

}

/// @nodoc


class HandleSyncCursorsMatch implements HandleSyncState {
  const HandleSyncCursorsMatch();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleSyncCursorsMatch);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandleSyncState.sourceAndLedgerCursorsMatch()';
}


}




/// @nodoc


class HandleSyncSourceAheadOfLedger implements HandleSyncState {
  const HandleSyncSourceAheadOfLedger();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleSyncSourceAheadOfLedger);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandleSyncState.sourceAheadOfLedger()';
}


}




/// @nodoc


class HandleSyncLedgerAheadOfSource implements HandleSyncState {
  const HandleSyncLedgerAheadOfSource();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleSyncLedgerAheadOfSource);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandleSyncState.ledgerAheadOfSource()';
}


}




// dart format on
