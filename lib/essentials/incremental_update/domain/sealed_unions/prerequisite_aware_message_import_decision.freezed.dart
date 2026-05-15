// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prerequisite_aware_message_import_decision.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrerequisiteAwareMessageImportDecision {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrerequisiteAwareMessageImportDecision);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrerequisiteAwareMessageImportDecision()';
}


}

/// @nodoc
class $PrerequisiteAwareMessageImportDecisionCopyWith<$Res>  {
$PrerequisiteAwareMessageImportDecisionCopyWith(PrerequisiteAwareMessageImportDecision _, $Res Function(PrerequisiteAwareMessageImportDecision) __);
}


/// Adds pattern-matching-related methods to [PrerequisiteAwareMessageImportDecision].
extension PrerequisiteAwareMessageImportDecisionPatterns on PrerequisiteAwareMessageImportDecision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PrerequisiteAwareMessageImportDecisionDoNothing value)?  doNothing,TResult Function( PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport value)?  considerIncrementalImport,TResult Function( PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites value)?  blockedPendingPrerequisites,TResult Function( PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead value)?  blockAndReportLedgerAhead,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PrerequisiteAwareMessageImportDecisionDoNothing() when doNothing != null:
return doNothing(_that);case PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport() when considerIncrementalImport != null:
return considerIncrementalImport(_that);case PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites() when blockedPendingPrerequisites != null:
return blockedPendingPrerequisites(_that);case PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead() when blockAndReportLedgerAhead != null:
return blockAndReportLedgerAhead(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PrerequisiteAwareMessageImportDecisionDoNothing value)  doNothing,required TResult Function( PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport value)  considerIncrementalImport,required TResult Function( PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites value)  blockedPendingPrerequisites,required TResult Function( PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead value)  blockAndReportLedgerAhead,}){
final _that = this;
switch (_that) {
case PrerequisiteAwareMessageImportDecisionDoNothing():
return doNothing(_that);case PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport():
return considerIncrementalImport(_that);case PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites():
return blockedPendingPrerequisites(_that);case PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead():
return blockAndReportLedgerAhead(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PrerequisiteAwareMessageImportDecisionDoNothing value)?  doNothing,TResult? Function( PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport value)?  considerIncrementalImport,TResult? Function( PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites value)?  blockedPendingPrerequisites,TResult? Function( PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead value)?  blockAndReportLedgerAhead,}){
final _that = this;
switch (_that) {
case PrerequisiteAwareMessageImportDecisionDoNothing() when doNothing != null:
return doNothing(_that);case PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport() when considerIncrementalImport != null:
return considerIncrementalImport(_that);case PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites() when blockedPendingPrerequisites != null:
return blockedPendingPrerequisites(_that);case PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead() when blockAndReportLedgerAhead != null:
return blockAndReportLedgerAhead(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  doNothing,TResult Function()?  considerIncrementalImport,TResult Function( List<MessageImportBlocker> blockers)?  blockedPendingPrerequisites,TResult Function()?  blockAndReportLedgerAhead,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PrerequisiteAwareMessageImportDecisionDoNothing() when doNothing != null:
return doNothing();case PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport() when considerIncrementalImport != null:
return considerIncrementalImport();case PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites() when blockedPendingPrerequisites != null:
return blockedPendingPrerequisites(_that.blockers);case PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead() when blockAndReportLedgerAhead != null:
return blockAndReportLedgerAhead();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  doNothing,required TResult Function()  considerIncrementalImport,required TResult Function( List<MessageImportBlocker> blockers)  blockedPendingPrerequisites,required TResult Function()  blockAndReportLedgerAhead,}) {final _that = this;
switch (_that) {
case PrerequisiteAwareMessageImportDecisionDoNothing():
return doNothing();case PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport():
return considerIncrementalImport();case PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites():
return blockedPendingPrerequisites(_that.blockers);case PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead():
return blockAndReportLedgerAhead();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  doNothing,TResult? Function()?  considerIncrementalImport,TResult? Function( List<MessageImportBlocker> blockers)?  blockedPendingPrerequisites,TResult? Function()?  blockAndReportLedgerAhead,}) {final _that = this;
switch (_that) {
case PrerequisiteAwareMessageImportDecisionDoNothing() when doNothing != null:
return doNothing();case PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport() when considerIncrementalImport != null:
return considerIncrementalImport();case PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites() when blockedPendingPrerequisites != null:
return blockedPendingPrerequisites(_that.blockers);case PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead() when blockAndReportLedgerAhead != null:
return blockAndReportLedgerAhead();case _:
  return null;

}
}

}

/// @nodoc


class PrerequisiteAwareMessageImportDecisionDoNothing implements PrerequisiteAwareMessageImportDecision {
  const PrerequisiteAwareMessageImportDecisionDoNothing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrerequisiteAwareMessageImportDecisionDoNothing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrerequisiteAwareMessageImportDecision.doNothing()';
}


}




/// @nodoc


class PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport implements PrerequisiteAwareMessageImportDecision {
  const PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrerequisiteAwareMessageImportDecisionConsiderIncrementalImport);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrerequisiteAwareMessageImportDecision.considerIncrementalImport()';
}


}




/// @nodoc


class PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites implements PrerequisiteAwareMessageImportDecision {
  const PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites({required final  List<MessageImportBlocker> blockers}): _blockers = blockers;
  

 final  List<MessageImportBlocker> _blockers;
 List<MessageImportBlocker> get blockers {
  if (_blockers is EqualUnmodifiableListView) return _blockers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockers);
}


/// Create a copy of PrerequisiteAwareMessageImportDecision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisitesCopyWith<PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites> get copyWith => _$PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisitesCopyWithImpl<PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites&&const DeepCollectionEquality().equals(other._blockers, _blockers));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_blockers));

@override
String toString() {
  return 'PrerequisiteAwareMessageImportDecision.blockedPendingPrerequisites(blockers: $blockers)';
}


}

/// @nodoc
abstract mixin class $PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisitesCopyWith<$Res> implements $PrerequisiteAwareMessageImportDecisionCopyWith<$Res> {
  factory $PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisitesCopyWith(PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites value, $Res Function(PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites) _then) = _$PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisitesCopyWithImpl;
@useResult
$Res call({
 List<MessageImportBlocker> blockers
});




}
/// @nodoc
class _$PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisitesCopyWithImpl<$Res>
    implements $PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisitesCopyWith<$Res> {
  _$PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisitesCopyWithImpl(this._self, this._then);

  final PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites _self;
  final $Res Function(PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites) _then;

/// Create a copy of PrerequisiteAwareMessageImportDecision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? blockers = null,}) {
  return _then(PrerequisiteAwareMessageImportDecisionBlockedPendingPrerequisites(
blockers: null == blockers ? _self._blockers : blockers // ignore: cast_nullable_to_non_nullable
as List<MessageImportBlocker>,
  ));
}


}

/// @nodoc


class PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead implements PrerequisiteAwareMessageImportDecision {
  const PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrerequisiteAwareMessageImportDecisionBlockAndReportLedgerAhead);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PrerequisiteAwareMessageImportDecision.blockAndReportLedgerAhead()';
}


}




// dart format on
