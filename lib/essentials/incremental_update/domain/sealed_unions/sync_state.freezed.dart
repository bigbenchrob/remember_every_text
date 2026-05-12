// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageSyncState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSyncState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageSyncState()';
}


}

/// @nodoc
class $MessageSyncStateCopyWith<$Res>  {
$MessageSyncStateCopyWith(MessageSyncState _, $Res Function(MessageSyncState) __);
}


/// Adds pattern-matching-related methods to [MessageSyncState].
extension MessageSyncStatePatterns on MessageSyncState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MessageSyncCursorsMatch value)?  sourceAndLedgerCursorsMatch,TResult Function( MessageSyncSourceAheadOfLedger value)?  sourceAheadOfLedger,TResult Function( MessageSyncLedgerAheadOfSource value)?  ledgerAheadOfSource,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MessageSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch(_that);case MessageSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger(_that);case MessageSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MessageSyncCursorsMatch value)  sourceAndLedgerCursorsMatch,required TResult Function( MessageSyncSourceAheadOfLedger value)  sourceAheadOfLedger,required TResult Function( MessageSyncLedgerAheadOfSource value)  ledgerAheadOfSource,}){
final _that = this;
switch (_that) {
case MessageSyncCursorsMatch():
return sourceAndLedgerCursorsMatch(_that);case MessageSyncSourceAheadOfLedger():
return sourceAheadOfLedger(_that);case MessageSyncLedgerAheadOfSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MessageSyncCursorsMatch value)?  sourceAndLedgerCursorsMatch,TResult? Function( MessageSyncSourceAheadOfLedger value)?  sourceAheadOfLedger,TResult? Function( MessageSyncLedgerAheadOfSource value)?  ledgerAheadOfSource,}){
final _that = this;
switch (_that) {
case MessageSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch(_that);case MessageSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger(_that);case MessageSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
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
case MessageSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch();case MessageSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger();case MessageSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
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
case MessageSyncCursorsMatch():
return sourceAndLedgerCursorsMatch();case MessageSyncSourceAheadOfLedger():
return sourceAheadOfLedger();case MessageSyncLedgerAheadOfSource():
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
case MessageSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch();case MessageSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger();case MessageSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
return ledgerAheadOfSource();case _:
  return null;

}
}

}

/// @nodoc


class MessageSyncCursorsMatch implements MessageSyncState {
  const MessageSyncCursorsMatch();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSyncCursorsMatch);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageSyncState.sourceAndLedgerCursorsMatch()';
}


}




/// @nodoc


class MessageSyncSourceAheadOfLedger implements MessageSyncState {
  const MessageSyncSourceAheadOfLedger();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSyncSourceAheadOfLedger);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageSyncState.sourceAheadOfLedger()';
}


}




/// @nodoc


class MessageSyncLedgerAheadOfSource implements MessageSyncState {
  const MessageSyncLedgerAheadOfSource();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSyncLedgerAheadOfSource);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageSyncState.ledgerAheadOfSource()';
}


}




// dart format on
