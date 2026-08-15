// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_flow_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SidebarFlowState implements DiagnosticableTreeMixin {

 TopChatMenuChoice get topMenuChoice; int? get chosenContactId; int? get selectedHandleId; int? get selectedConversationId; int? get selectedConversationAnchorMessageId; String? get selectedConversationSearchQuery; int? get selectedHandleEvidenceId; SidebarFlowHandleEvidenceKind? get selectedHandleEvidenceKind; StrayHandleInvestigationId? get selectedHandleEvidenceInvestigationId; StrayHandleInvestigationId? get strayHandleInvestigationId; StrayHandleInvestigation? get strayHandleInvestigation; SettingsMenuActionId? get persistentSettingsContext; DateTime? get scrollToDate; SidebarFlowMessageScope get messageScope; SidebarFlowContactProjection get contactProjection;
/// Create a copy of SidebarFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarFlowStateCopyWith<SidebarFlowState> get copyWith => _$SidebarFlowStateCopyWithImpl<SidebarFlowState>(this as SidebarFlowState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SidebarFlowState'))
    ..add(DiagnosticsProperty('topMenuChoice', topMenuChoice))..add(DiagnosticsProperty('chosenContactId', chosenContactId))..add(DiagnosticsProperty('selectedHandleId', selectedHandleId))..add(DiagnosticsProperty('selectedConversationId', selectedConversationId))..add(DiagnosticsProperty('selectedConversationAnchorMessageId', selectedConversationAnchorMessageId))..add(DiagnosticsProperty('selectedConversationSearchQuery', selectedConversationSearchQuery))..add(DiagnosticsProperty('selectedHandleEvidenceId', selectedHandleEvidenceId))..add(DiagnosticsProperty('selectedHandleEvidenceKind', selectedHandleEvidenceKind))..add(DiagnosticsProperty('selectedHandleEvidenceInvestigationId', selectedHandleEvidenceInvestigationId))..add(DiagnosticsProperty('strayHandleInvestigationId', strayHandleInvestigationId))..add(DiagnosticsProperty('strayHandleInvestigation', strayHandleInvestigation))..add(DiagnosticsProperty('persistentSettingsContext', persistentSettingsContext))..add(DiagnosticsProperty('scrollToDate', scrollToDate))..add(DiagnosticsProperty('messageScope', messageScope))..add(DiagnosticsProperty('contactProjection', contactProjection));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarFlowState&&(identical(other.topMenuChoice, topMenuChoice) || other.topMenuChoice == topMenuChoice)&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId)&&(identical(other.selectedHandleId, selectedHandleId) || other.selectedHandleId == selectedHandleId)&&(identical(other.selectedConversationId, selectedConversationId) || other.selectedConversationId == selectedConversationId)&&(identical(other.selectedConversationAnchorMessageId, selectedConversationAnchorMessageId) || other.selectedConversationAnchorMessageId == selectedConversationAnchorMessageId)&&(identical(other.selectedConversationSearchQuery, selectedConversationSearchQuery) || other.selectedConversationSearchQuery == selectedConversationSearchQuery)&&(identical(other.selectedHandleEvidenceId, selectedHandleEvidenceId) || other.selectedHandleEvidenceId == selectedHandleEvidenceId)&&(identical(other.selectedHandleEvidenceKind, selectedHandleEvidenceKind) || other.selectedHandleEvidenceKind == selectedHandleEvidenceKind)&&(identical(other.selectedHandleEvidenceInvestigationId, selectedHandleEvidenceInvestigationId) || other.selectedHandleEvidenceInvestigationId == selectedHandleEvidenceInvestigationId)&&(identical(other.strayHandleInvestigationId, strayHandleInvestigationId) || other.strayHandleInvestigationId == strayHandleInvestigationId)&&(identical(other.strayHandleInvestigation, strayHandleInvestigation) || other.strayHandleInvestigation == strayHandleInvestigation)&&(identical(other.persistentSettingsContext, persistentSettingsContext) || other.persistentSettingsContext == persistentSettingsContext)&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate)&&(identical(other.messageScope, messageScope) || other.messageScope == messageScope)&&(identical(other.contactProjection, contactProjection) || other.contactProjection == contactProjection));
}


@override
int get hashCode => Object.hash(runtimeType,topMenuChoice,chosenContactId,selectedHandleId,selectedConversationId,selectedConversationAnchorMessageId,selectedConversationSearchQuery,selectedHandleEvidenceId,selectedHandleEvidenceKind,selectedHandleEvidenceInvestigationId,strayHandleInvestigationId,strayHandleInvestigation,persistentSettingsContext,scrollToDate,messageScope,contactProjection);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SidebarFlowState(topMenuChoice: $topMenuChoice, chosenContactId: $chosenContactId, selectedHandleId: $selectedHandleId, selectedConversationId: $selectedConversationId, selectedConversationAnchorMessageId: $selectedConversationAnchorMessageId, selectedConversationSearchQuery: $selectedConversationSearchQuery, selectedHandleEvidenceId: $selectedHandleEvidenceId, selectedHandleEvidenceKind: $selectedHandleEvidenceKind, selectedHandleEvidenceInvestigationId: $selectedHandleEvidenceInvestigationId, strayHandleInvestigationId: $strayHandleInvestigationId, strayHandleInvestigation: $strayHandleInvestigation, persistentSettingsContext: $persistentSettingsContext, scrollToDate: $scrollToDate, messageScope: $messageScope, contactProjection: $contactProjection)';
}


}

/// @nodoc
abstract mixin class $SidebarFlowStateCopyWith<$Res>  {
  factory $SidebarFlowStateCopyWith(SidebarFlowState value, $Res Function(SidebarFlowState) _then) = _$SidebarFlowStateCopyWithImpl;
@useResult
$Res call({
 TopChatMenuChoice topMenuChoice, int? chosenContactId, int? selectedHandleId, int? selectedConversationId, int? selectedConversationAnchorMessageId, String? selectedConversationSearchQuery, int? selectedHandleEvidenceId, SidebarFlowHandleEvidenceKind? selectedHandleEvidenceKind, StrayHandleInvestigationId? selectedHandleEvidenceInvestigationId, StrayHandleInvestigationId? strayHandleInvestigationId, StrayHandleInvestigation? strayHandleInvestigation, SettingsMenuActionId? persistentSettingsContext, DateTime? scrollToDate, SidebarFlowMessageScope messageScope, SidebarFlowContactProjection contactProjection
});




}
/// @nodoc
class _$SidebarFlowStateCopyWithImpl<$Res>
    implements $SidebarFlowStateCopyWith<$Res> {
  _$SidebarFlowStateCopyWithImpl(this._self, this._then);

  final SidebarFlowState _self;
  final $Res Function(SidebarFlowState) _then;

/// Create a copy of SidebarFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topMenuChoice = null,Object? chosenContactId = freezed,Object? selectedHandleId = freezed,Object? selectedConversationId = freezed,Object? selectedConversationAnchorMessageId = freezed,Object? selectedConversationSearchQuery = freezed,Object? selectedHandleEvidenceId = freezed,Object? selectedHandleEvidenceKind = freezed,Object? selectedHandleEvidenceInvestigationId = freezed,Object? strayHandleInvestigationId = freezed,Object? strayHandleInvestigation = freezed,Object? persistentSettingsContext = freezed,Object? scrollToDate = freezed,Object? messageScope = null,Object? contactProjection = null,}) {
  return _then(_self.copyWith(
topMenuChoice: null == topMenuChoice ? _self.topMenuChoice : topMenuChoice // ignore: cast_nullable_to_non_nullable
as TopChatMenuChoice,chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,selectedHandleId: freezed == selectedHandleId ? _self.selectedHandleId : selectedHandleId // ignore: cast_nullable_to_non_nullable
as int?,selectedConversationId: freezed == selectedConversationId ? _self.selectedConversationId : selectedConversationId // ignore: cast_nullable_to_non_nullable
as int?,selectedConversationAnchorMessageId: freezed == selectedConversationAnchorMessageId ? _self.selectedConversationAnchorMessageId : selectedConversationAnchorMessageId // ignore: cast_nullable_to_non_nullable
as int?,selectedConversationSearchQuery: freezed == selectedConversationSearchQuery ? _self.selectedConversationSearchQuery : selectedConversationSearchQuery // ignore: cast_nullable_to_non_nullable
as String?,selectedHandleEvidenceId: freezed == selectedHandleEvidenceId ? _self.selectedHandleEvidenceId : selectedHandleEvidenceId // ignore: cast_nullable_to_non_nullable
as int?,selectedHandleEvidenceKind: freezed == selectedHandleEvidenceKind ? _self.selectedHandleEvidenceKind : selectedHandleEvidenceKind // ignore: cast_nullable_to_non_nullable
as SidebarFlowHandleEvidenceKind?,selectedHandleEvidenceInvestigationId: freezed == selectedHandleEvidenceInvestigationId ? _self.selectedHandleEvidenceInvestigationId : selectedHandleEvidenceInvestigationId // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigationId?,strayHandleInvestigationId: freezed == strayHandleInvestigationId ? _self.strayHandleInvestigationId : strayHandleInvestigationId // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigationId?,strayHandleInvestigation: freezed == strayHandleInvestigation ? _self.strayHandleInvestigation : strayHandleInvestigation // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigation?,persistentSettingsContext: freezed == persistentSettingsContext ? _self.persistentSettingsContext : persistentSettingsContext // ignore: cast_nullable_to_non_nullable
as SettingsMenuActionId?,scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,messageScope: null == messageScope ? _self.messageScope : messageScope // ignore: cast_nullable_to_non_nullable
as SidebarFlowMessageScope,contactProjection: null == contactProjection ? _self.contactProjection : contactProjection // ignore: cast_nullable_to_non_nullable
as SidebarFlowContactProjection,
  ));
}

}


/// Adds pattern-matching-related methods to [SidebarFlowState].
extension SidebarFlowStatePatterns on SidebarFlowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SidebarFlowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SidebarFlowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SidebarFlowState value)  $default,){
final _that = this;
switch (_that) {
case _SidebarFlowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SidebarFlowState value)?  $default,){
final _that = this;
switch (_that) {
case _SidebarFlowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TopChatMenuChoice topMenuChoice,  int? chosenContactId,  int? selectedHandleId,  int? selectedConversationId,  int? selectedConversationAnchorMessageId,  String? selectedConversationSearchQuery,  int? selectedHandleEvidenceId,  SidebarFlowHandleEvidenceKind? selectedHandleEvidenceKind,  StrayHandleInvestigationId? selectedHandleEvidenceInvestigationId,  StrayHandleInvestigationId? strayHandleInvestigationId,  StrayHandleInvestigation? strayHandleInvestigation,  SettingsMenuActionId? persistentSettingsContext,  DateTime? scrollToDate,  SidebarFlowMessageScope messageScope,  SidebarFlowContactProjection contactProjection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SidebarFlowState() when $default != null:
return $default(_that.topMenuChoice,_that.chosenContactId,_that.selectedHandleId,_that.selectedConversationId,_that.selectedConversationAnchorMessageId,_that.selectedConversationSearchQuery,_that.selectedHandleEvidenceId,_that.selectedHandleEvidenceKind,_that.selectedHandleEvidenceInvestigationId,_that.strayHandleInvestigationId,_that.strayHandleInvestigation,_that.persistentSettingsContext,_that.scrollToDate,_that.messageScope,_that.contactProjection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TopChatMenuChoice topMenuChoice,  int? chosenContactId,  int? selectedHandleId,  int? selectedConversationId,  int? selectedConversationAnchorMessageId,  String? selectedConversationSearchQuery,  int? selectedHandleEvidenceId,  SidebarFlowHandleEvidenceKind? selectedHandleEvidenceKind,  StrayHandleInvestigationId? selectedHandleEvidenceInvestigationId,  StrayHandleInvestigationId? strayHandleInvestigationId,  StrayHandleInvestigation? strayHandleInvestigation,  SettingsMenuActionId? persistentSettingsContext,  DateTime? scrollToDate,  SidebarFlowMessageScope messageScope,  SidebarFlowContactProjection contactProjection)  $default,) {final _that = this;
switch (_that) {
case _SidebarFlowState():
return $default(_that.topMenuChoice,_that.chosenContactId,_that.selectedHandleId,_that.selectedConversationId,_that.selectedConversationAnchorMessageId,_that.selectedConversationSearchQuery,_that.selectedHandleEvidenceId,_that.selectedHandleEvidenceKind,_that.selectedHandleEvidenceInvestigationId,_that.strayHandleInvestigationId,_that.strayHandleInvestigation,_that.persistentSettingsContext,_that.scrollToDate,_that.messageScope,_that.contactProjection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TopChatMenuChoice topMenuChoice,  int? chosenContactId,  int? selectedHandleId,  int? selectedConversationId,  int? selectedConversationAnchorMessageId,  String? selectedConversationSearchQuery,  int? selectedHandleEvidenceId,  SidebarFlowHandleEvidenceKind? selectedHandleEvidenceKind,  StrayHandleInvestigationId? selectedHandleEvidenceInvestigationId,  StrayHandleInvestigationId? strayHandleInvestigationId,  StrayHandleInvestigation? strayHandleInvestigation,  SettingsMenuActionId? persistentSettingsContext,  DateTime? scrollToDate,  SidebarFlowMessageScope messageScope,  SidebarFlowContactProjection contactProjection)?  $default,) {final _that = this;
switch (_that) {
case _SidebarFlowState() when $default != null:
return $default(_that.topMenuChoice,_that.chosenContactId,_that.selectedHandleId,_that.selectedConversationId,_that.selectedConversationAnchorMessageId,_that.selectedConversationSearchQuery,_that.selectedHandleEvidenceId,_that.selectedHandleEvidenceKind,_that.selectedHandleEvidenceInvestigationId,_that.strayHandleInvestigationId,_that.strayHandleInvestigation,_that.persistentSettingsContext,_that.scrollToDate,_that.messageScope,_that.contactProjection);case _:
  return null;

}
}

}

/// @nodoc


class _SidebarFlowState extends SidebarFlowState with DiagnosticableTreeMixin {
  const _SidebarFlowState({this.topMenuChoice = defaultTopChatMenuChoice, this.chosenContactId, this.selectedHandleId, this.selectedConversationId, this.selectedConversationAnchorMessageId, this.selectedConversationSearchQuery, this.selectedHandleEvidenceId, this.selectedHandleEvidenceKind, this.selectedHandleEvidenceInvestigationId, this.strayHandleInvestigationId, this.strayHandleInvestigation, this.persistentSettingsContext, this.scrollToDate, this.messageScope = SidebarFlowMessageScope.regular, this.contactProjection = SidebarFlowContactProjection.allMessages}): super._();
  

@override@JsonKey() final  TopChatMenuChoice topMenuChoice;
@override final  int? chosenContactId;
@override final  int? selectedHandleId;
@override final  int? selectedConversationId;
@override final  int? selectedConversationAnchorMessageId;
@override final  String? selectedConversationSearchQuery;
@override final  int? selectedHandleEvidenceId;
@override final  SidebarFlowHandleEvidenceKind? selectedHandleEvidenceKind;
@override final  StrayHandleInvestigationId? selectedHandleEvidenceInvestigationId;
@override final  StrayHandleInvestigationId? strayHandleInvestigationId;
@override final  StrayHandleInvestigation? strayHandleInvestigation;
@override final  SettingsMenuActionId? persistentSettingsContext;
@override final  DateTime? scrollToDate;
@override@JsonKey() final  SidebarFlowMessageScope messageScope;
@override@JsonKey() final  SidebarFlowContactProjection contactProjection;

/// Create a copy of SidebarFlowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SidebarFlowStateCopyWith<_SidebarFlowState> get copyWith => __$SidebarFlowStateCopyWithImpl<_SidebarFlowState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SidebarFlowState'))
    ..add(DiagnosticsProperty('topMenuChoice', topMenuChoice))..add(DiagnosticsProperty('chosenContactId', chosenContactId))..add(DiagnosticsProperty('selectedHandleId', selectedHandleId))..add(DiagnosticsProperty('selectedConversationId', selectedConversationId))..add(DiagnosticsProperty('selectedConversationAnchorMessageId', selectedConversationAnchorMessageId))..add(DiagnosticsProperty('selectedConversationSearchQuery', selectedConversationSearchQuery))..add(DiagnosticsProperty('selectedHandleEvidenceId', selectedHandleEvidenceId))..add(DiagnosticsProperty('selectedHandleEvidenceKind', selectedHandleEvidenceKind))..add(DiagnosticsProperty('selectedHandleEvidenceInvestigationId', selectedHandleEvidenceInvestigationId))..add(DiagnosticsProperty('strayHandleInvestigationId', strayHandleInvestigationId))..add(DiagnosticsProperty('strayHandleInvestigation', strayHandleInvestigation))..add(DiagnosticsProperty('persistentSettingsContext', persistentSettingsContext))..add(DiagnosticsProperty('scrollToDate', scrollToDate))..add(DiagnosticsProperty('messageScope', messageScope))..add(DiagnosticsProperty('contactProjection', contactProjection));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SidebarFlowState&&(identical(other.topMenuChoice, topMenuChoice) || other.topMenuChoice == topMenuChoice)&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId)&&(identical(other.selectedHandleId, selectedHandleId) || other.selectedHandleId == selectedHandleId)&&(identical(other.selectedConversationId, selectedConversationId) || other.selectedConversationId == selectedConversationId)&&(identical(other.selectedConversationAnchorMessageId, selectedConversationAnchorMessageId) || other.selectedConversationAnchorMessageId == selectedConversationAnchorMessageId)&&(identical(other.selectedConversationSearchQuery, selectedConversationSearchQuery) || other.selectedConversationSearchQuery == selectedConversationSearchQuery)&&(identical(other.selectedHandleEvidenceId, selectedHandleEvidenceId) || other.selectedHandleEvidenceId == selectedHandleEvidenceId)&&(identical(other.selectedHandleEvidenceKind, selectedHandleEvidenceKind) || other.selectedHandleEvidenceKind == selectedHandleEvidenceKind)&&(identical(other.selectedHandleEvidenceInvestigationId, selectedHandleEvidenceInvestigationId) || other.selectedHandleEvidenceInvestigationId == selectedHandleEvidenceInvestigationId)&&(identical(other.strayHandleInvestigationId, strayHandleInvestigationId) || other.strayHandleInvestigationId == strayHandleInvestigationId)&&(identical(other.strayHandleInvestigation, strayHandleInvestigation) || other.strayHandleInvestigation == strayHandleInvestigation)&&(identical(other.persistentSettingsContext, persistentSettingsContext) || other.persistentSettingsContext == persistentSettingsContext)&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate)&&(identical(other.messageScope, messageScope) || other.messageScope == messageScope)&&(identical(other.contactProjection, contactProjection) || other.contactProjection == contactProjection));
}


@override
int get hashCode => Object.hash(runtimeType,topMenuChoice,chosenContactId,selectedHandleId,selectedConversationId,selectedConversationAnchorMessageId,selectedConversationSearchQuery,selectedHandleEvidenceId,selectedHandleEvidenceKind,selectedHandleEvidenceInvestigationId,strayHandleInvestigationId,strayHandleInvestigation,persistentSettingsContext,scrollToDate,messageScope,contactProjection);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SidebarFlowState(topMenuChoice: $topMenuChoice, chosenContactId: $chosenContactId, selectedHandleId: $selectedHandleId, selectedConversationId: $selectedConversationId, selectedConversationAnchorMessageId: $selectedConversationAnchorMessageId, selectedConversationSearchQuery: $selectedConversationSearchQuery, selectedHandleEvidenceId: $selectedHandleEvidenceId, selectedHandleEvidenceKind: $selectedHandleEvidenceKind, selectedHandleEvidenceInvestigationId: $selectedHandleEvidenceInvestigationId, strayHandleInvestigationId: $strayHandleInvestigationId, strayHandleInvestigation: $strayHandleInvestigation, persistentSettingsContext: $persistentSettingsContext, scrollToDate: $scrollToDate, messageScope: $messageScope, contactProjection: $contactProjection)';
}


}

/// @nodoc
abstract mixin class _$SidebarFlowStateCopyWith<$Res> implements $SidebarFlowStateCopyWith<$Res> {
  factory _$SidebarFlowStateCopyWith(_SidebarFlowState value, $Res Function(_SidebarFlowState) _then) = __$SidebarFlowStateCopyWithImpl;
@override @useResult
$Res call({
 TopChatMenuChoice topMenuChoice, int? chosenContactId, int? selectedHandleId, int? selectedConversationId, int? selectedConversationAnchorMessageId, String? selectedConversationSearchQuery, int? selectedHandleEvidenceId, SidebarFlowHandleEvidenceKind? selectedHandleEvidenceKind, StrayHandleInvestigationId? selectedHandleEvidenceInvestigationId, StrayHandleInvestigationId? strayHandleInvestigationId, StrayHandleInvestigation? strayHandleInvestigation, SettingsMenuActionId? persistentSettingsContext, DateTime? scrollToDate, SidebarFlowMessageScope messageScope, SidebarFlowContactProjection contactProjection
});




}
/// @nodoc
class __$SidebarFlowStateCopyWithImpl<$Res>
    implements _$SidebarFlowStateCopyWith<$Res> {
  __$SidebarFlowStateCopyWithImpl(this._self, this._then);

  final _SidebarFlowState _self;
  final $Res Function(_SidebarFlowState) _then;

/// Create a copy of SidebarFlowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topMenuChoice = null,Object? chosenContactId = freezed,Object? selectedHandleId = freezed,Object? selectedConversationId = freezed,Object? selectedConversationAnchorMessageId = freezed,Object? selectedConversationSearchQuery = freezed,Object? selectedHandleEvidenceId = freezed,Object? selectedHandleEvidenceKind = freezed,Object? selectedHandleEvidenceInvestigationId = freezed,Object? strayHandleInvestigationId = freezed,Object? strayHandleInvestigation = freezed,Object? persistentSettingsContext = freezed,Object? scrollToDate = freezed,Object? messageScope = null,Object? contactProjection = null,}) {
  return _then(_SidebarFlowState(
topMenuChoice: null == topMenuChoice ? _self.topMenuChoice : topMenuChoice // ignore: cast_nullable_to_non_nullable
as TopChatMenuChoice,chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,selectedHandleId: freezed == selectedHandleId ? _self.selectedHandleId : selectedHandleId // ignore: cast_nullable_to_non_nullable
as int?,selectedConversationId: freezed == selectedConversationId ? _self.selectedConversationId : selectedConversationId // ignore: cast_nullable_to_non_nullable
as int?,selectedConversationAnchorMessageId: freezed == selectedConversationAnchorMessageId ? _self.selectedConversationAnchorMessageId : selectedConversationAnchorMessageId // ignore: cast_nullable_to_non_nullable
as int?,selectedConversationSearchQuery: freezed == selectedConversationSearchQuery ? _self.selectedConversationSearchQuery : selectedConversationSearchQuery // ignore: cast_nullable_to_non_nullable
as String?,selectedHandleEvidenceId: freezed == selectedHandleEvidenceId ? _self.selectedHandleEvidenceId : selectedHandleEvidenceId // ignore: cast_nullable_to_non_nullable
as int?,selectedHandleEvidenceKind: freezed == selectedHandleEvidenceKind ? _self.selectedHandleEvidenceKind : selectedHandleEvidenceKind // ignore: cast_nullable_to_non_nullable
as SidebarFlowHandleEvidenceKind?,selectedHandleEvidenceInvestigationId: freezed == selectedHandleEvidenceInvestigationId ? _self.selectedHandleEvidenceInvestigationId : selectedHandleEvidenceInvestigationId // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigationId?,strayHandleInvestigationId: freezed == strayHandleInvestigationId ? _self.strayHandleInvestigationId : strayHandleInvestigationId // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigationId?,strayHandleInvestigation: freezed == strayHandleInvestigation ? _self.strayHandleInvestigation : strayHandleInvestigation // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigation?,persistentSettingsContext: freezed == persistentSettingsContext ? _self.persistentSettingsContext : persistentSettingsContext // ignore: cast_nullable_to_non_nullable
as SettingsMenuActionId?,scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,messageScope: null == messageScope ? _self.messageScope : messageScope // ignore: cast_nullable_to_non_nullable
as SidebarFlowMessageScope,contactProjection: null == contactProjection ? _self.contactProjection : contactProjection // ignore: cast_nullable_to_non_nullable
as SidebarFlowContactProjection,
  ));
}


}

// dart format on
