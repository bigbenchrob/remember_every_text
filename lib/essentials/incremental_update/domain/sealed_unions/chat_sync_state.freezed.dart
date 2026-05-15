// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_sync_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatSyncState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSyncState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatSyncState()';
}


}

/// @nodoc
class $ChatSyncStateCopyWith<$Res>  {
$ChatSyncStateCopyWith(ChatSyncState _, $Res Function(ChatSyncState) __);
}


/// Adds pattern-matching-related methods to [ChatSyncState].
extension ChatSyncStatePatterns on ChatSyncState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatSyncCursorsMatch value)?  sourceAndLedgerCursorsMatch,TResult Function( ChatSyncSourceAheadOfLedger value)?  sourceAheadOfLedger,TResult Function( ChatSyncLedgerAheadOfSource value)?  ledgerAheadOfSource,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch(_that);case ChatSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger(_that);case ChatSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatSyncCursorsMatch value)  sourceAndLedgerCursorsMatch,required TResult Function( ChatSyncSourceAheadOfLedger value)  sourceAheadOfLedger,required TResult Function( ChatSyncLedgerAheadOfSource value)  ledgerAheadOfSource,}){
final _that = this;
switch (_that) {
case ChatSyncCursorsMatch():
return sourceAndLedgerCursorsMatch(_that);case ChatSyncSourceAheadOfLedger():
return sourceAheadOfLedger(_that);case ChatSyncLedgerAheadOfSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatSyncCursorsMatch value)?  sourceAndLedgerCursorsMatch,TResult? Function( ChatSyncSourceAheadOfLedger value)?  sourceAheadOfLedger,TResult? Function( ChatSyncLedgerAheadOfSource value)?  ledgerAheadOfSource,}){
final _that = this;
switch (_that) {
case ChatSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch(_that);case ChatSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger(_that);case ChatSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
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
case ChatSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch();case ChatSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger();case ChatSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
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
case ChatSyncCursorsMatch():
return sourceAndLedgerCursorsMatch();case ChatSyncSourceAheadOfLedger():
return sourceAheadOfLedger();case ChatSyncLedgerAheadOfSource():
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
case ChatSyncCursorsMatch() when sourceAndLedgerCursorsMatch != null:
return sourceAndLedgerCursorsMatch();case ChatSyncSourceAheadOfLedger() when sourceAheadOfLedger != null:
return sourceAheadOfLedger();case ChatSyncLedgerAheadOfSource() when ledgerAheadOfSource != null:
return ledgerAheadOfSource();case _:
  return null;

}
}

}

/// @nodoc


class ChatSyncCursorsMatch implements ChatSyncState {
  const ChatSyncCursorsMatch();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSyncCursorsMatch);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatSyncState.sourceAndLedgerCursorsMatch()';
}


}




/// @nodoc


class ChatSyncSourceAheadOfLedger implements ChatSyncState {
  const ChatSyncSourceAheadOfLedger();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSyncSourceAheadOfLedger);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatSyncState.sourceAheadOfLedger()';
}


}




/// @nodoc


class ChatSyncLedgerAheadOfSource implements ChatSyncState {
  const ChatSyncLedgerAheadOfSource();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatSyncLedgerAheadOfSource);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatSyncState.ledgerAheadOfSource()';
}


}




// dart format on
