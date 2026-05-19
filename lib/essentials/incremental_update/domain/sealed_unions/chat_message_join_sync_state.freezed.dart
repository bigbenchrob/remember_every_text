// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_join_sync_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatMessageJoinSyncState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageJoinSyncState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatMessageJoinSyncState()';
}


}

/// @nodoc
class $ChatMessageJoinSyncStateCopyWith<$Res>  {
$ChatMessageJoinSyncStateCopyWith(ChatMessageJoinSyncState _, $Res Function(ChatMessageJoinSyncState) __);
}


/// Adds pattern-matching-related methods to [ChatMessageJoinSyncState].
extension ChatMessageJoinSyncStatePatterns on ChatMessageJoinSyncState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatMessageJoinSourceAndLedgerTopologyMatch value)?  sourceAndLedgerTopologyMatch,TResult Function( ChatMessageJoinSourceTopologyAheadOfLedger value)?  sourceTopologyAheadOfLedger,TResult Function( ChatMessageJoinLedgerTopologyAheadOfSource value)?  ledgerTopologyAheadOfSource,TResult Function( ChatMessageJoinTopologyNotYetImported value)?  topologyNotYetImported,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatMessageJoinSourceAndLedgerTopologyMatch() when sourceAndLedgerTopologyMatch != null:
return sourceAndLedgerTopologyMatch(_that);case ChatMessageJoinSourceTopologyAheadOfLedger() when sourceTopologyAheadOfLedger != null:
return sourceTopologyAheadOfLedger(_that);case ChatMessageJoinLedgerTopologyAheadOfSource() when ledgerTopologyAheadOfSource != null:
return ledgerTopologyAheadOfSource(_that);case ChatMessageJoinTopologyNotYetImported() when topologyNotYetImported != null:
return topologyNotYetImported(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatMessageJoinSourceAndLedgerTopologyMatch value)  sourceAndLedgerTopologyMatch,required TResult Function( ChatMessageJoinSourceTopologyAheadOfLedger value)  sourceTopologyAheadOfLedger,required TResult Function( ChatMessageJoinLedgerTopologyAheadOfSource value)  ledgerTopologyAheadOfSource,required TResult Function( ChatMessageJoinTopologyNotYetImported value)  topologyNotYetImported,}){
final _that = this;
switch (_that) {
case ChatMessageJoinSourceAndLedgerTopologyMatch():
return sourceAndLedgerTopologyMatch(_that);case ChatMessageJoinSourceTopologyAheadOfLedger():
return sourceTopologyAheadOfLedger(_that);case ChatMessageJoinLedgerTopologyAheadOfSource():
return ledgerTopologyAheadOfSource(_that);case ChatMessageJoinTopologyNotYetImported():
return topologyNotYetImported(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatMessageJoinSourceAndLedgerTopologyMatch value)?  sourceAndLedgerTopologyMatch,TResult? Function( ChatMessageJoinSourceTopologyAheadOfLedger value)?  sourceTopologyAheadOfLedger,TResult? Function( ChatMessageJoinLedgerTopologyAheadOfSource value)?  ledgerTopologyAheadOfSource,TResult? Function( ChatMessageJoinTopologyNotYetImported value)?  topologyNotYetImported,}){
final _that = this;
switch (_that) {
case ChatMessageJoinSourceAndLedgerTopologyMatch() when sourceAndLedgerTopologyMatch != null:
return sourceAndLedgerTopologyMatch(_that);case ChatMessageJoinSourceTopologyAheadOfLedger() when sourceTopologyAheadOfLedger != null:
return sourceTopologyAheadOfLedger(_that);case ChatMessageJoinLedgerTopologyAheadOfSource() when ledgerTopologyAheadOfSource != null:
return ledgerTopologyAheadOfSource(_that);case ChatMessageJoinTopologyNotYetImported() when topologyNotYetImported != null:
return topologyNotYetImported(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  sourceAndLedgerTopologyMatch,TResult Function()?  sourceTopologyAheadOfLedger,TResult Function()?  ledgerTopologyAheadOfSource,TResult Function()?  topologyNotYetImported,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatMessageJoinSourceAndLedgerTopologyMatch() when sourceAndLedgerTopologyMatch != null:
return sourceAndLedgerTopologyMatch();case ChatMessageJoinSourceTopologyAheadOfLedger() when sourceTopologyAheadOfLedger != null:
return sourceTopologyAheadOfLedger();case ChatMessageJoinLedgerTopologyAheadOfSource() when ledgerTopologyAheadOfSource != null:
return ledgerTopologyAheadOfSource();case ChatMessageJoinTopologyNotYetImported() when topologyNotYetImported != null:
return topologyNotYetImported();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  sourceAndLedgerTopologyMatch,required TResult Function()  sourceTopologyAheadOfLedger,required TResult Function()  ledgerTopologyAheadOfSource,required TResult Function()  topologyNotYetImported,}) {final _that = this;
switch (_that) {
case ChatMessageJoinSourceAndLedgerTopologyMatch():
return sourceAndLedgerTopologyMatch();case ChatMessageJoinSourceTopologyAheadOfLedger():
return sourceTopologyAheadOfLedger();case ChatMessageJoinLedgerTopologyAheadOfSource():
return ledgerTopologyAheadOfSource();case ChatMessageJoinTopologyNotYetImported():
return topologyNotYetImported();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  sourceAndLedgerTopologyMatch,TResult? Function()?  sourceTopologyAheadOfLedger,TResult? Function()?  ledgerTopologyAheadOfSource,TResult? Function()?  topologyNotYetImported,}) {final _that = this;
switch (_that) {
case ChatMessageJoinSourceAndLedgerTopologyMatch() when sourceAndLedgerTopologyMatch != null:
return sourceAndLedgerTopologyMatch();case ChatMessageJoinSourceTopologyAheadOfLedger() when sourceTopologyAheadOfLedger != null:
return sourceTopologyAheadOfLedger();case ChatMessageJoinLedgerTopologyAheadOfSource() when ledgerTopologyAheadOfSource != null:
return ledgerTopologyAheadOfSource();case ChatMessageJoinTopologyNotYetImported() when topologyNotYetImported != null:
return topologyNotYetImported();case _:
  return null;

}
}

}

/// @nodoc


class ChatMessageJoinSourceAndLedgerTopologyMatch implements ChatMessageJoinSyncState {
  const ChatMessageJoinSourceAndLedgerTopologyMatch();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageJoinSourceAndLedgerTopologyMatch);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatMessageJoinSyncState.sourceAndLedgerTopologyMatch()';
}


}




/// @nodoc


class ChatMessageJoinSourceTopologyAheadOfLedger implements ChatMessageJoinSyncState {
  const ChatMessageJoinSourceTopologyAheadOfLedger();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageJoinSourceTopologyAheadOfLedger);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatMessageJoinSyncState.sourceTopologyAheadOfLedger()';
}


}




/// @nodoc


class ChatMessageJoinLedgerTopologyAheadOfSource implements ChatMessageJoinSyncState {
  const ChatMessageJoinLedgerTopologyAheadOfSource();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageJoinLedgerTopologyAheadOfSource);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatMessageJoinSyncState.ledgerTopologyAheadOfSource()';
}


}




/// @nodoc


class ChatMessageJoinTopologyNotYetImported implements ChatMessageJoinSyncState {
  const ChatMessageJoinTopologyNotYetImported();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessageJoinTopologyNotYetImported);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatMessageJoinSyncState.topologyNotYetImported()';
}


}




// dart format on
