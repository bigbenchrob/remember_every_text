// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topology_projection_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TopologyProjectionPreviewFact {

 String get sourceId; String get sourceKind; int get sourceJoinRowId; int get sourceChatRowId; int get sourceMessageRowId; int? get ledgerMessageId; String? get ledgerMessageGuid; int? get ledgerChatId; String? get ledgerChatGuid; List<int> get workingMessageIds; List<int> get workingChatIds;
/// Create a copy of TopologyProjectionPreviewFact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopologyProjectionPreviewFactCopyWith<TopologyProjectionPreviewFact> get copyWith => _$TopologyProjectionPreviewFactCopyWithImpl<TopologyProjectionPreviewFact>(this as TopologyProjectionPreviewFact, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopologyProjectionPreviewFact&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceKind, sourceKind) || other.sourceKind == sourceKind)&&(identical(other.sourceJoinRowId, sourceJoinRowId) || other.sourceJoinRowId == sourceJoinRowId)&&(identical(other.sourceChatRowId, sourceChatRowId) || other.sourceChatRowId == sourceChatRowId)&&(identical(other.sourceMessageRowId, sourceMessageRowId) || other.sourceMessageRowId == sourceMessageRowId)&&(identical(other.ledgerMessageId, ledgerMessageId) || other.ledgerMessageId == ledgerMessageId)&&(identical(other.ledgerMessageGuid, ledgerMessageGuid) || other.ledgerMessageGuid == ledgerMessageGuid)&&(identical(other.ledgerChatId, ledgerChatId) || other.ledgerChatId == ledgerChatId)&&(identical(other.ledgerChatGuid, ledgerChatGuid) || other.ledgerChatGuid == ledgerChatGuid)&&const DeepCollectionEquality().equals(other.workingMessageIds, workingMessageIds)&&const DeepCollectionEquality().equals(other.workingChatIds, workingChatIds));
}


@override
int get hashCode => Object.hash(runtimeType,sourceId,sourceKind,sourceJoinRowId,sourceChatRowId,sourceMessageRowId,ledgerMessageId,ledgerMessageGuid,ledgerChatId,ledgerChatGuid,const DeepCollectionEquality().hash(workingMessageIds),const DeepCollectionEquality().hash(workingChatIds));

@override
String toString() {
  return 'TopologyProjectionPreviewFact(sourceId: $sourceId, sourceKind: $sourceKind, sourceJoinRowId: $sourceJoinRowId, sourceChatRowId: $sourceChatRowId, sourceMessageRowId: $sourceMessageRowId, ledgerMessageId: $ledgerMessageId, ledgerMessageGuid: $ledgerMessageGuid, ledgerChatId: $ledgerChatId, ledgerChatGuid: $ledgerChatGuid, workingMessageIds: $workingMessageIds, workingChatIds: $workingChatIds)';
}


}

/// @nodoc
abstract mixin class $TopologyProjectionPreviewFactCopyWith<$Res>  {
  factory $TopologyProjectionPreviewFactCopyWith(TopologyProjectionPreviewFact value, $Res Function(TopologyProjectionPreviewFact) _then) = _$TopologyProjectionPreviewFactCopyWithImpl;
@useResult
$Res call({
 String sourceId, String sourceKind, int sourceJoinRowId, int sourceChatRowId, int sourceMessageRowId, int? ledgerMessageId, String? ledgerMessageGuid, int? ledgerChatId, String? ledgerChatGuid, List<int> workingMessageIds, List<int> workingChatIds
});




}
/// @nodoc
class _$TopologyProjectionPreviewFactCopyWithImpl<$Res>
    implements $TopologyProjectionPreviewFactCopyWith<$Res> {
  _$TopologyProjectionPreviewFactCopyWithImpl(this._self, this._then);

  final TopologyProjectionPreviewFact _self;
  final $Res Function(TopologyProjectionPreviewFact) _then;

/// Create a copy of TopologyProjectionPreviewFact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceId = null,Object? sourceKind = null,Object? sourceJoinRowId = null,Object? sourceChatRowId = null,Object? sourceMessageRowId = null,Object? ledgerMessageId = freezed,Object? ledgerMessageGuid = freezed,Object? ledgerChatId = freezed,Object? ledgerChatGuid = freezed,Object? workingMessageIds = null,Object? workingChatIds = null,}) {
  return _then(_self.copyWith(
sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceKind: null == sourceKind ? _self.sourceKind : sourceKind // ignore: cast_nullable_to_non_nullable
as String,sourceJoinRowId: null == sourceJoinRowId ? _self.sourceJoinRowId : sourceJoinRowId // ignore: cast_nullable_to_non_nullable
as int,sourceChatRowId: null == sourceChatRowId ? _self.sourceChatRowId : sourceChatRowId // ignore: cast_nullable_to_non_nullable
as int,sourceMessageRowId: null == sourceMessageRowId ? _self.sourceMessageRowId : sourceMessageRowId // ignore: cast_nullable_to_non_nullable
as int,ledgerMessageId: freezed == ledgerMessageId ? _self.ledgerMessageId : ledgerMessageId // ignore: cast_nullable_to_non_nullable
as int?,ledgerMessageGuid: freezed == ledgerMessageGuid ? _self.ledgerMessageGuid : ledgerMessageGuid // ignore: cast_nullable_to_non_nullable
as String?,ledgerChatId: freezed == ledgerChatId ? _self.ledgerChatId : ledgerChatId // ignore: cast_nullable_to_non_nullable
as int?,ledgerChatGuid: freezed == ledgerChatGuid ? _self.ledgerChatGuid : ledgerChatGuid // ignore: cast_nullable_to_non_nullable
as String?,workingMessageIds: null == workingMessageIds ? _self.workingMessageIds : workingMessageIds // ignore: cast_nullable_to_non_nullable
as List<int>,workingChatIds: null == workingChatIds ? _self.workingChatIds : workingChatIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [TopologyProjectionPreviewFact].
extension TopologyProjectionPreviewFactPatterns on TopologyProjectionPreviewFact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopologyProjectionPreviewFact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopologyProjectionPreviewFact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopologyProjectionPreviewFact value)  $default,){
final _that = this;
switch (_that) {
case _TopologyProjectionPreviewFact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopologyProjectionPreviewFact value)?  $default,){
final _that = this;
switch (_that) {
case _TopologyProjectionPreviewFact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceId,  String sourceKind,  int sourceJoinRowId,  int sourceChatRowId,  int sourceMessageRowId,  int? ledgerMessageId,  String? ledgerMessageGuid,  int? ledgerChatId,  String? ledgerChatGuid,  List<int> workingMessageIds,  List<int> workingChatIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopologyProjectionPreviewFact() when $default != null:
return $default(_that.sourceId,_that.sourceKind,_that.sourceJoinRowId,_that.sourceChatRowId,_that.sourceMessageRowId,_that.ledgerMessageId,_that.ledgerMessageGuid,_that.ledgerChatId,_that.ledgerChatGuid,_that.workingMessageIds,_that.workingChatIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceId,  String sourceKind,  int sourceJoinRowId,  int sourceChatRowId,  int sourceMessageRowId,  int? ledgerMessageId,  String? ledgerMessageGuid,  int? ledgerChatId,  String? ledgerChatGuid,  List<int> workingMessageIds,  List<int> workingChatIds)  $default,) {final _that = this;
switch (_that) {
case _TopologyProjectionPreviewFact():
return $default(_that.sourceId,_that.sourceKind,_that.sourceJoinRowId,_that.sourceChatRowId,_that.sourceMessageRowId,_that.ledgerMessageId,_that.ledgerMessageGuid,_that.ledgerChatId,_that.ledgerChatGuid,_that.workingMessageIds,_that.workingChatIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceId,  String sourceKind,  int sourceJoinRowId,  int sourceChatRowId,  int sourceMessageRowId,  int? ledgerMessageId,  String? ledgerMessageGuid,  int? ledgerChatId,  String? ledgerChatGuid,  List<int> workingMessageIds,  List<int> workingChatIds)?  $default,) {final _that = this;
switch (_that) {
case _TopologyProjectionPreviewFact() when $default != null:
return $default(_that.sourceId,_that.sourceKind,_that.sourceJoinRowId,_that.sourceChatRowId,_that.sourceMessageRowId,_that.ledgerMessageId,_that.ledgerMessageGuid,_that.ledgerChatId,_that.ledgerChatGuid,_that.workingMessageIds,_that.workingChatIds);case _:
  return null;

}
}

}

/// @nodoc


class _TopologyProjectionPreviewFact implements TopologyProjectionPreviewFact {
  const _TopologyProjectionPreviewFact({required this.sourceId, required this.sourceKind, required this.sourceJoinRowId, required this.sourceChatRowId, required this.sourceMessageRowId, this.ledgerMessageId, this.ledgerMessageGuid, this.ledgerChatId, this.ledgerChatGuid, final  List<int> workingMessageIds = const <int>[], final  List<int> workingChatIds = const <int>[]}): _workingMessageIds = workingMessageIds,_workingChatIds = workingChatIds;
  

@override final  String sourceId;
@override final  String sourceKind;
@override final  int sourceJoinRowId;
@override final  int sourceChatRowId;
@override final  int sourceMessageRowId;
@override final  int? ledgerMessageId;
@override final  String? ledgerMessageGuid;
@override final  int? ledgerChatId;
@override final  String? ledgerChatGuid;
 final  List<int> _workingMessageIds;
@override@JsonKey() List<int> get workingMessageIds {
  if (_workingMessageIds is EqualUnmodifiableListView) return _workingMessageIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workingMessageIds);
}

 final  List<int> _workingChatIds;
@override@JsonKey() List<int> get workingChatIds {
  if (_workingChatIds is EqualUnmodifiableListView) return _workingChatIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workingChatIds);
}


/// Create a copy of TopologyProjectionPreviewFact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopologyProjectionPreviewFactCopyWith<_TopologyProjectionPreviewFact> get copyWith => __$TopologyProjectionPreviewFactCopyWithImpl<_TopologyProjectionPreviewFact>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopologyProjectionPreviewFact&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceKind, sourceKind) || other.sourceKind == sourceKind)&&(identical(other.sourceJoinRowId, sourceJoinRowId) || other.sourceJoinRowId == sourceJoinRowId)&&(identical(other.sourceChatRowId, sourceChatRowId) || other.sourceChatRowId == sourceChatRowId)&&(identical(other.sourceMessageRowId, sourceMessageRowId) || other.sourceMessageRowId == sourceMessageRowId)&&(identical(other.ledgerMessageId, ledgerMessageId) || other.ledgerMessageId == ledgerMessageId)&&(identical(other.ledgerMessageGuid, ledgerMessageGuid) || other.ledgerMessageGuid == ledgerMessageGuid)&&(identical(other.ledgerChatId, ledgerChatId) || other.ledgerChatId == ledgerChatId)&&(identical(other.ledgerChatGuid, ledgerChatGuid) || other.ledgerChatGuid == ledgerChatGuid)&&const DeepCollectionEquality().equals(other._workingMessageIds, _workingMessageIds)&&const DeepCollectionEquality().equals(other._workingChatIds, _workingChatIds));
}


@override
int get hashCode => Object.hash(runtimeType,sourceId,sourceKind,sourceJoinRowId,sourceChatRowId,sourceMessageRowId,ledgerMessageId,ledgerMessageGuid,ledgerChatId,ledgerChatGuid,const DeepCollectionEquality().hash(_workingMessageIds),const DeepCollectionEquality().hash(_workingChatIds));

@override
String toString() {
  return 'TopologyProjectionPreviewFact(sourceId: $sourceId, sourceKind: $sourceKind, sourceJoinRowId: $sourceJoinRowId, sourceChatRowId: $sourceChatRowId, sourceMessageRowId: $sourceMessageRowId, ledgerMessageId: $ledgerMessageId, ledgerMessageGuid: $ledgerMessageGuid, ledgerChatId: $ledgerChatId, ledgerChatGuid: $ledgerChatGuid, workingMessageIds: $workingMessageIds, workingChatIds: $workingChatIds)';
}


}

/// @nodoc
abstract mixin class _$TopologyProjectionPreviewFactCopyWith<$Res> implements $TopologyProjectionPreviewFactCopyWith<$Res> {
  factory _$TopologyProjectionPreviewFactCopyWith(_TopologyProjectionPreviewFact value, $Res Function(_TopologyProjectionPreviewFact) _then) = __$TopologyProjectionPreviewFactCopyWithImpl;
@override @useResult
$Res call({
 String sourceId, String sourceKind, int sourceJoinRowId, int sourceChatRowId, int sourceMessageRowId, int? ledgerMessageId, String? ledgerMessageGuid, int? ledgerChatId, String? ledgerChatGuid, List<int> workingMessageIds, List<int> workingChatIds
});




}
/// @nodoc
class __$TopologyProjectionPreviewFactCopyWithImpl<$Res>
    implements _$TopologyProjectionPreviewFactCopyWith<$Res> {
  __$TopologyProjectionPreviewFactCopyWithImpl(this._self, this._then);

  final _TopologyProjectionPreviewFact _self;
  final $Res Function(_TopologyProjectionPreviewFact) _then;

/// Create a copy of TopologyProjectionPreviewFact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceId = null,Object? sourceKind = null,Object? sourceJoinRowId = null,Object? sourceChatRowId = null,Object? sourceMessageRowId = null,Object? ledgerMessageId = freezed,Object? ledgerMessageGuid = freezed,Object? ledgerChatId = freezed,Object? ledgerChatGuid = freezed,Object? workingMessageIds = null,Object? workingChatIds = null,}) {
  return _then(_TopologyProjectionPreviewFact(
sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceKind: null == sourceKind ? _self.sourceKind : sourceKind // ignore: cast_nullable_to_non_nullable
as String,sourceJoinRowId: null == sourceJoinRowId ? _self.sourceJoinRowId : sourceJoinRowId // ignore: cast_nullable_to_non_nullable
as int,sourceChatRowId: null == sourceChatRowId ? _self.sourceChatRowId : sourceChatRowId // ignore: cast_nullable_to_non_nullable
as int,sourceMessageRowId: null == sourceMessageRowId ? _self.sourceMessageRowId : sourceMessageRowId // ignore: cast_nullable_to_non_nullable
as int,ledgerMessageId: freezed == ledgerMessageId ? _self.ledgerMessageId : ledgerMessageId // ignore: cast_nullable_to_non_nullable
as int?,ledgerMessageGuid: freezed == ledgerMessageGuid ? _self.ledgerMessageGuid : ledgerMessageGuid // ignore: cast_nullable_to_non_nullable
as String?,ledgerChatId: freezed == ledgerChatId ? _self.ledgerChatId : ledgerChatId // ignore: cast_nullable_to_non_nullable
as int?,ledgerChatGuid: freezed == ledgerChatGuid ? _self.ledgerChatGuid : ledgerChatGuid // ignore: cast_nullable_to_non_nullable
as String?,workingMessageIds: null == workingMessageIds ? _self._workingMessageIds : workingMessageIds // ignore: cast_nullable_to_non_nullable
as List<int>,workingChatIds: null == workingChatIds ? _self._workingChatIds : workingChatIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

/// @nodoc
mixin _$TopologyProjectionPreviewResult {

 String get sourceId; String get sourceKind; int get sourceJoinRowId; int get sourceChatRowId; int get sourceMessageRowId; TopologyProjectionPreviewStatus get status; int? get ledgerMessageId; String? get ledgerMessageGuid; int? get ledgerChatId; String? get ledgerChatGuid; List<int> get workingMessageIds; List<int> get workingChatIds;
/// Create a copy of TopologyProjectionPreviewResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopologyProjectionPreviewResultCopyWith<TopologyProjectionPreviewResult> get copyWith => _$TopologyProjectionPreviewResultCopyWithImpl<TopologyProjectionPreviewResult>(this as TopologyProjectionPreviewResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopologyProjectionPreviewResult&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceKind, sourceKind) || other.sourceKind == sourceKind)&&(identical(other.sourceJoinRowId, sourceJoinRowId) || other.sourceJoinRowId == sourceJoinRowId)&&(identical(other.sourceChatRowId, sourceChatRowId) || other.sourceChatRowId == sourceChatRowId)&&(identical(other.sourceMessageRowId, sourceMessageRowId) || other.sourceMessageRowId == sourceMessageRowId)&&(identical(other.status, status) || other.status == status)&&(identical(other.ledgerMessageId, ledgerMessageId) || other.ledgerMessageId == ledgerMessageId)&&(identical(other.ledgerMessageGuid, ledgerMessageGuid) || other.ledgerMessageGuid == ledgerMessageGuid)&&(identical(other.ledgerChatId, ledgerChatId) || other.ledgerChatId == ledgerChatId)&&(identical(other.ledgerChatGuid, ledgerChatGuid) || other.ledgerChatGuid == ledgerChatGuid)&&const DeepCollectionEquality().equals(other.workingMessageIds, workingMessageIds)&&const DeepCollectionEquality().equals(other.workingChatIds, workingChatIds));
}


@override
int get hashCode => Object.hash(runtimeType,sourceId,sourceKind,sourceJoinRowId,sourceChatRowId,sourceMessageRowId,status,ledgerMessageId,ledgerMessageGuid,ledgerChatId,ledgerChatGuid,const DeepCollectionEquality().hash(workingMessageIds),const DeepCollectionEquality().hash(workingChatIds));

@override
String toString() {
  return 'TopologyProjectionPreviewResult(sourceId: $sourceId, sourceKind: $sourceKind, sourceJoinRowId: $sourceJoinRowId, sourceChatRowId: $sourceChatRowId, sourceMessageRowId: $sourceMessageRowId, status: $status, ledgerMessageId: $ledgerMessageId, ledgerMessageGuid: $ledgerMessageGuid, ledgerChatId: $ledgerChatId, ledgerChatGuid: $ledgerChatGuid, workingMessageIds: $workingMessageIds, workingChatIds: $workingChatIds)';
}


}

/// @nodoc
abstract mixin class $TopologyProjectionPreviewResultCopyWith<$Res>  {
  factory $TopologyProjectionPreviewResultCopyWith(TopologyProjectionPreviewResult value, $Res Function(TopologyProjectionPreviewResult) _then) = _$TopologyProjectionPreviewResultCopyWithImpl;
@useResult
$Res call({
 String sourceId, String sourceKind, int sourceJoinRowId, int sourceChatRowId, int sourceMessageRowId, TopologyProjectionPreviewStatus status, int? ledgerMessageId, String? ledgerMessageGuid, int? ledgerChatId, String? ledgerChatGuid, List<int> workingMessageIds, List<int> workingChatIds
});


$TopologyProjectionPreviewStatusCopyWith<$Res> get status;

}
/// @nodoc
class _$TopologyProjectionPreviewResultCopyWithImpl<$Res>
    implements $TopologyProjectionPreviewResultCopyWith<$Res> {
  _$TopologyProjectionPreviewResultCopyWithImpl(this._self, this._then);

  final TopologyProjectionPreviewResult _self;
  final $Res Function(TopologyProjectionPreviewResult) _then;

/// Create a copy of TopologyProjectionPreviewResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceId = null,Object? sourceKind = null,Object? sourceJoinRowId = null,Object? sourceChatRowId = null,Object? sourceMessageRowId = null,Object? status = null,Object? ledgerMessageId = freezed,Object? ledgerMessageGuid = freezed,Object? ledgerChatId = freezed,Object? ledgerChatGuid = freezed,Object? workingMessageIds = null,Object? workingChatIds = null,}) {
  return _then(_self.copyWith(
sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceKind: null == sourceKind ? _self.sourceKind : sourceKind // ignore: cast_nullable_to_non_nullable
as String,sourceJoinRowId: null == sourceJoinRowId ? _self.sourceJoinRowId : sourceJoinRowId // ignore: cast_nullable_to_non_nullable
as int,sourceChatRowId: null == sourceChatRowId ? _self.sourceChatRowId : sourceChatRowId // ignore: cast_nullable_to_non_nullable
as int,sourceMessageRowId: null == sourceMessageRowId ? _self.sourceMessageRowId : sourceMessageRowId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TopologyProjectionPreviewStatus,ledgerMessageId: freezed == ledgerMessageId ? _self.ledgerMessageId : ledgerMessageId // ignore: cast_nullable_to_non_nullable
as int?,ledgerMessageGuid: freezed == ledgerMessageGuid ? _self.ledgerMessageGuid : ledgerMessageGuid // ignore: cast_nullable_to_non_nullable
as String?,ledgerChatId: freezed == ledgerChatId ? _self.ledgerChatId : ledgerChatId // ignore: cast_nullable_to_non_nullable
as int?,ledgerChatGuid: freezed == ledgerChatGuid ? _self.ledgerChatGuid : ledgerChatGuid // ignore: cast_nullable_to_non_nullable
as String?,workingMessageIds: null == workingMessageIds ? _self.workingMessageIds : workingMessageIds // ignore: cast_nullable_to_non_nullable
as List<int>,workingChatIds: null == workingChatIds ? _self.workingChatIds : workingChatIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}
/// Create a copy of TopologyProjectionPreviewResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TopologyProjectionPreviewStatusCopyWith<$Res> get status {
  
  return $TopologyProjectionPreviewStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [TopologyProjectionPreviewResult].
extension TopologyProjectionPreviewResultPatterns on TopologyProjectionPreviewResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopologyProjectionPreviewResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopologyProjectionPreviewResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopologyProjectionPreviewResult value)  $default,){
final _that = this;
switch (_that) {
case _TopologyProjectionPreviewResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopologyProjectionPreviewResult value)?  $default,){
final _that = this;
switch (_that) {
case _TopologyProjectionPreviewResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceId,  String sourceKind,  int sourceJoinRowId,  int sourceChatRowId,  int sourceMessageRowId,  TopologyProjectionPreviewStatus status,  int? ledgerMessageId,  String? ledgerMessageGuid,  int? ledgerChatId,  String? ledgerChatGuid,  List<int> workingMessageIds,  List<int> workingChatIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopologyProjectionPreviewResult() when $default != null:
return $default(_that.sourceId,_that.sourceKind,_that.sourceJoinRowId,_that.sourceChatRowId,_that.sourceMessageRowId,_that.status,_that.ledgerMessageId,_that.ledgerMessageGuid,_that.ledgerChatId,_that.ledgerChatGuid,_that.workingMessageIds,_that.workingChatIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceId,  String sourceKind,  int sourceJoinRowId,  int sourceChatRowId,  int sourceMessageRowId,  TopologyProjectionPreviewStatus status,  int? ledgerMessageId,  String? ledgerMessageGuid,  int? ledgerChatId,  String? ledgerChatGuid,  List<int> workingMessageIds,  List<int> workingChatIds)  $default,) {final _that = this;
switch (_that) {
case _TopologyProjectionPreviewResult():
return $default(_that.sourceId,_that.sourceKind,_that.sourceJoinRowId,_that.sourceChatRowId,_that.sourceMessageRowId,_that.status,_that.ledgerMessageId,_that.ledgerMessageGuid,_that.ledgerChatId,_that.ledgerChatGuid,_that.workingMessageIds,_that.workingChatIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceId,  String sourceKind,  int sourceJoinRowId,  int sourceChatRowId,  int sourceMessageRowId,  TopologyProjectionPreviewStatus status,  int? ledgerMessageId,  String? ledgerMessageGuid,  int? ledgerChatId,  String? ledgerChatGuid,  List<int> workingMessageIds,  List<int> workingChatIds)?  $default,) {final _that = this;
switch (_that) {
case _TopologyProjectionPreviewResult() when $default != null:
return $default(_that.sourceId,_that.sourceKind,_that.sourceJoinRowId,_that.sourceChatRowId,_that.sourceMessageRowId,_that.status,_that.ledgerMessageId,_that.ledgerMessageGuid,_that.ledgerChatId,_that.ledgerChatGuid,_that.workingMessageIds,_that.workingChatIds);case _:
  return null;

}
}

}

/// @nodoc


class _TopologyProjectionPreviewResult implements TopologyProjectionPreviewResult {
  const _TopologyProjectionPreviewResult({required this.sourceId, required this.sourceKind, required this.sourceJoinRowId, required this.sourceChatRowId, required this.sourceMessageRowId, required this.status, this.ledgerMessageId, this.ledgerMessageGuid, this.ledgerChatId, this.ledgerChatGuid, final  List<int> workingMessageIds = const <int>[], final  List<int> workingChatIds = const <int>[]}): _workingMessageIds = workingMessageIds,_workingChatIds = workingChatIds;
  

@override final  String sourceId;
@override final  String sourceKind;
@override final  int sourceJoinRowId;
@override final  int sourceChatRowId;
@override final  int sourceMessageRowId;
@override final  TopologyProjectionPreviewStatus status;
@override final  int? ledgerMessageId;
@override final  String? ledgerMessageGuid;
@override final  int? ledgerChatId;
@override final  String? ledgerChatGuid;
 final  List<int> _workingMessageIds;
@override@JsonKey() List<int> get workingMessageIds {
  if (_workingMessageIds is EqualUnmodifiableListView) return _workingMessageIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workingMessageIds);
}

 final  List<int> _workingChatIds;
@override@JsonKey() List<int> get workingChatIds {
  if (_workingChatIds is EqualUnmodifiableListView) return _workingChatIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workingChatIds);
}


/// Create a copy of TopologyProjectionPreviewResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopologyProjectionPreviewResultCopyWith<_TopologyProjectionPreviewResult> get copyWith => __$TopologyProjectionPreviewResultCopyWithImpl<_TopologyProjectionPreviewResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopologyProjectionPreviewResult&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceKind, sourceKind) || other.sourceKind == sourceKind)&&(identical(other.sourceJoinRowId, sourceJoinRowId) || other.sourceJoinRowId == sourceJoinRowId)&&(identical(other.sourceChatRowId, sourceChatRowId) || other.sourceChatRowId == sourceChatRowId)&&(identical(other.sourceMessageRowId, sourceMessageRowId) || other.sourceMessageRowId == sourceMessageRowId)&&(identical(other.status, status) || other.status == status)&&(identical(other.ledgerMessageId, ledgerMessageId) || other.ledgerMessageId == ledgerMessageId)&&(identical(other.ledgerMessageGuid, ledgerMessageGuid) || other.ledgerMessageGuid == ledgerMessageGuid)&&(identical(other.ledgerChatId, ledgerChatId) || other.ledgerChatId == ledgerChatId)&&(identical(other.ledgerChatGuid, ledgerChatGuid) || other.ledgerChatGuid == ledgerChatGuid)&&const DeepCollectionEquality().equals(other._workingMessageIds, _workingMessageIds)&&const DeepCollectionEquality().equals(other._workingChatIds, _workingChatIds));
}


@override
int get hashCode => Object.hash(runtimeType,sourceId,sourceKind,sourceJoinRowId,sourceChatRowId,sourceMessageRowId,status,ledgerMessageId,ledgerMessageGuid,ledgerChatId,ledgerChatGuid,const DeepCollectionEquality().hash(_workingMessageIds),const DeepCollectionEquality().hash(_workingChatIds));

@override
String toString() {
  return 'TopologyProjectionPreviewResult(sourceId: $sourceId, sourceKind: $sourceKind, sourceJoinRowId: $sourceJoinRowId, sourceChatRowId: $sourceChatRowId, sourceMessageRowId: $sourceMessageRowId, status: $status, ledgerMessageId: $ledgerMessageId, ledgerMessageGuid: $ledgerMessageGuid, ledgerChatId: $ledgerChatId, ledgerChatGuid: $ledgerChatGuid, workingMessageIds: $workingMessageIds, workingChatIds: $workingChatIds)';
}


}

/// @nodoc
abstract mixin class _$TopologyProjectionPreviewResultCopyWith<$Res> implements $TopologyProjectionPreviewResultCopyWith<$Res> {
  factory _$TopologyProjectionPreviewResultCopyWith(_TopologyProjectionPreviewResult value, $Res Function(_TopologyProjectionPreviewResult) _then) = __$TopologyProjectionPreviewResultCopyWithImpl;
@override @useResult
$Res call({
 String sourceId, String sourceKind, int sourceJoinRowId, int sourceChatRowId, int sourceMessageRowId, TopologyProjectionPreviewStatus status, int? ledgerMessageId, String? ledgerMessageGuid, int? ledgerChatId, String? ledgerChatGuid, List<int> workingMessageIds, List<int> workingChatIds
});


@override $TopologyProjectionPreviewStatusCopyWith<$Res> get status;

}
/// @nodoc
class __$TopologyProjectionPreviewResultCopyWithImpl<$Res>
    implements _$TopologyProjectionPreviewResultCopyWith<$Res> {
  __$TopologyProjectionPreviewResultCopyWithImpl(this._self, this._then);

  final _TopologyProjectionPreviewResult _self;
  final $Res Function(_TopologyProjectionPreviewResult) _then;

/// Create a copy of TopologyProjectionPreviewResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceId = null,Object? sourceKind = null,Object? sourceJoinRowId = null,Object? sourceChatRowId = null,Object? sourceMessageRowId = null,Object? status = null,Object? ledgerMessageId = freezed,Object? ledgerMessageGuid = freezed,Object? ledgerChatId = freezed,Object? ledgerChatGuid = freezed,Object? workingMessageIds = null,Object? workingChatIds = null,}) {
  return _then(_TopologyProjectionPreviewResult(
sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceKind: null == sourceKind ? _self.sourceKind : sourceKind // ignore: cast_nullable_to_non_nullable
as String,sourceJoinRowId: null == sourceJoinRowId ? _self.sourceJoinRowId : sourceJoinRowId // ignore: cast_nullable_to_non_nullable
as int,sourceChatRowId: null == sourceChatRowId ? _self.sourceChatRowId : sourceChatRowId // ignore: cast_nullable_to_non_nullable
as int,sourceMessageRowId: null == sourceMessageRowId ? _self.sourceMessageRowId : sourceMessageRowId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TopologyProjectionPreviewStatus,ledgerMessageId: freezed == ledgerMessageId ? _self.ledgerMessageId : ledgerMessageId // ignore: cast_nullable_to_non_nullable
as int?,ledgerMessageGuid: freezed == ledgerMessageGuid ? _self.ledgerMessageGuid : ledgerMessageGuid // ignore: cast_nullable_to_non_nullable
as String?,ledgerChatId: freezed == ledgerChatId ? _self.ledgerChatId : ledgerChatId // ignore: cast_nullable_to_non_nullable
as int?,ledgerChatGuid: freezed == ledgerChatGuid ? _self.ledgerChatGuid : ledgerChatGuid // ignore: cast_nullable_to_non_nullable
as String?,workingMessageIds: null == workingMessageIds ? _self._workingMessageIds : workingMessageIds // ignore: cast_nullable_to_non_nullable
as List<int>,workingChatIds: null == workingChatIds ? _self._workingChatIds : workingChatIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

/// Create a copy of TopologyProjectionPreviewResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TopologyProjectionPreviewStatusCopyWith<$Res> get status {
  
  return $TopologyProjectionPreviewStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}

/// @nodoc
mixin _$TopologyProjectionPreviewSummary {

 int get totalRowCount; Map<String, int> get countsByStatus; List<TopologyProjectionPreviewResult> get sampleResults;
/// Create a copy of TopologyProjectionPreviewSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopologyProjectionPreviewSummaryCopyWith<TopologyProjectionPreviewSummary> get copyWith => _$TopologyProjectionPreviewSummaryCopyWithImpl<TopologyProjectionPreviewSummary>(this as TopologyProjectionPreviewSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopologyProjectionPreviewSummary&&(identical(other.totalRowCount, totalRowCount) || other.totalRowCount == totalRowCount)&&const DeepCollectionEquality().equals(other.countsByStatus, countsByStatus)&&const DeepCollectionEquality().equals(other.sampleResults, sampleResults));
}


@override
int get hashCode => Object.hash(runtimeType,totalRowCount,const DeepCollectionEquality().hash(countsByStatus),const DeepCollectionEquality().hash(sampleResults));

@override
String toString() {
  return 'TopologyProjectionPreviewSummary(totalRowCount: $totalRowCount, countsByStatus: $countsByStatus, sampleResults: $sampleResults)';
}


}

/// @nodoc
abstract mixin class $TopologyProjectionPreviewSummaryCopyWith<$Res>  {
  factory $TopologyProjectionPreviewSummaryCopyWith(TopologyProjectionPreviewSummary value, $Res Function(TopologyProjectionPreviewSummary) _then) = _$TopologyProjectionPreviewSummaryCopyWithImpl;
@useResult
$Res call({
 int totalRowCount, Map<String, int> countsByStatus, List<TopologyProjectionPreviewResult> sampleResults
});




}
/// @nodoc
class _$TopologyProjectionPreviewSummaryCopyWithImpl<$Res>
    implements $TopologyProjectionPreviewSummaryCopyWith<$Res> {
  _$TopologyProjectionPreviewSummaryCopyWithImpl(this._self, this._then);

  final TopologyProjectionPreviewSummary _self;
  final $Res Function(TopologyProjectionPreviewSummary) _then;

/// Create a copy of TopologyProjectionPreviewSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRowCount = null,Object? countsByStatus = null,Object? sampleResults = null,}) {
  return _then(_self.copyWith(
totalRowCount: null == totalRowCount ? _self.totalRowCount : totalRowCount // ignore: cast_nullable_to_non_nullable
as int,countsByStatus: null == countsByStatus ? _self.countsByStatus : countsByStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>,sampleResults: null == sampleResults ? _self.sampleResults : sampleResults // ignore: cast_nullable_to_non_nullable
as List<TopologyProjectionPreviewResult>,
  ));
}

}


/// Adds pattern-matching-related methods to [TopologyProjectionPreviewSummary].
extension TopologyProjectionPreviewSummaryPatterns on TopologyProjectionPreviewSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopologyProjectionPreviewSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopologyProjectionPreviewSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopologyProjectionPreviewSummary value)  $default,){
final _that = this;
switch (_that) {
case _TopologyProjectionPreviewSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopologyProjectionPreviewSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TopologyProjectionPreviewSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalRowCount,  Map<String, int> countsByStatus,  List<TopologyProjectionPreviewResult> sampleResults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopologyProjectionPreviewSummary() when $default != null:
return $default(_that.totalRowCount,_that.countsByStatus,_that.sampleResults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalRowCount,  Map<String, int> countsByStatus,  List<TopologyProjectionPreviewResult> sampleResults)  $default,) {final _that = this;
switch (_that) {
case _TopologyProjectionPreviewSummary():
return $default(_that.totalRowCount,_that.countsByStatus,_that.sampleResults);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalRowCount,  Map<String, int> countsByStatus,  List<TopologyProjectionPreviewResult> sampleResults)?  $default,) {final _that = this;
switch (_that) {
case _TopologyProjectionPreviewSummary() when $default != null:
return $default(_that.totalRowCount,_that.countsByStatus,_that.sampleResults);case _:
  return null;

}
}

}

/// @nodoc


class _TopologyProjectionPreviewSummary implements TopologyProjectionPreviewSummary {
  const _TopologyProjectionPreviewSummary({required this.totalRowCount, required final  Map<String, int> countsByStatus, final  List<TopologyProjectionPreviewResult> sampleResults = const <TopologyProjectionPreviewResult>[]}): _countsByStatus = countsByStatus,_sampleResults = sampleResults;
  

@override final  int totalRowCount;
 final  Map<String, int> _countsByStatus;
@override Map<String, int> get countsByStatus {
  if (_countsByStatus is EqualUnmodifiableMapView) return _countsByStatus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_countsByStatus);
}

 final  List<TopologyProjectionPreviewResult> _sampleResults;
@override@JsonKey() List<TopologyProjectionPreviewResult> get sampleResults {
  if (_sampleResults is EqualUnmodifiableListView) return _sampleResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sampleResults);
}


/// Create a copy of TopologyProjectionPreviewSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopologyProjectionPreviewSummaryCopyWith<_TopologyProjectionPreviewSummary> get copyWith => __$TopologyProjectionPreviewSummaryCopyWithImpl<_TopologyProjectionPreviewSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopologyProjectionPreviewSummary&&(identical(other.totalRowCount, totalRowCount) || other.totalRowCount == totalRowCount)&&const DeepCollectionEquality().equals(other._countsByStatus, _countsByStatus)&&const DeepCollectionEquality().equals(other._sampleResults, _sampleResults));
}


@override
int get hashCode => Object.hash(runtimeType,totalRowCount,const DeepCollectionEquality().hash(_countsByStatus),const DeepCollectionEquality().hash(_sampleResults));

@override
String toString() {
  return 'TopologyProjectionPreviewSummary(totalRowCount: $totalRowCount, countsByStatus: $countsByStatus, sampleResults: $sampleResults)';
}


}

/// @nodoc
abstract mixin class _$TopologyProjectionPreviewSummaryCopyWith<$Res> implements $TopologyProjectionPreviewSummaryCopyWith<$Res> {
  factory _$TopologyProjectionPreviewSummaryCopyWith(_TopologyProjectionPreviewSummary value, $Res Function(_TopologyProjectionPreviewSummary) _then) = __$TopologyProjectionPreviewSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalRowCount, Map<String, int> countsByStatus, List<TopologyProjectionPreviewResult> sampleResults
});




}
/// @nodoc
class __$TopologyProjectionPreviewSummaryCopyWithImpl<$Res>
    implements _$TopologyProjectionPreviewSummaryCopyWith<$Res> {
  __$TopologyProjectionPreviewSummaryCopyWithImpl(this._self, this._then);

  final _TopologyProjectionPreviewSummary _self;
  final $Res Function(_TopologyProjectionPreviewSummary) _then;

/// Create a copy of TopologyProjectionPreviewSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRowCount = null,Object? countsByStatus = null,Object? sampleResults = null,}) {
  return _then(_TopologyProjectionPreviewSummary(
totalRowCount: null == totalRowCount ? _self.totalRowCount : totalRowCount // ignore: cast_nullable_to_non_nullable
as int,countsByStatus: null == countsByStatus ? _self._countsByStatus : countsByStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>,sampleResults: null == sampleResults ? _self._sampleResults : sampleResults // ignore: cast_nullable_to_non_nullable
as List<TopologyProjectionPreviewResult>,
  ));
}


}

// dart format on
