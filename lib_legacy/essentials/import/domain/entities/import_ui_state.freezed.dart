// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImportDatabaseStats {

 int get totalRecords; int get contacts; int get messages; int get chats; int get handles; DateTime? get lastModified;
/// Create a copy of ImportDatabaseStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportDatabaseStatsCopyWith<ImportDatabaseStats> get copyWith => _$ImportDatabaseStatsCopyWithImpl<ImportDatabaseStats>(this as ImportDatabaseStats, _$identity);

  /// Serializes this ImportDatabaseStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportDatabaseStats&&(identical(other.totalRecords, totalRecords) || other.totalRecords == totalRecords)&&(identical(other.contacts, contacts) || other.contacts == contacts)&&(identical(other.messages, messages) || other.messages == messages)&&(identical(other.chats, chats) || other.chats == chats)&&(identical(other.handles, handles) || other.handles == handles)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRecords,contacts,messages,chats,handles,lastModified);

@override
String toString() {
  return 'ImportDatabaseStats(totalRecords: $totalRecords, contacts: $contacts, messages: $messages, chats: $chats, handles: $handles, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $ImportDatabaseStatsCopyWith<$Res>  {
  factory $ImportDatabaseStatsCopyWith(ImportDatabaseStats value, $Res Function(ImportDatabaseStats) _then) = _$ImportDatabaseStatsCopyWithImpl;
@useResult
$Res call({
 int totalRecords, int contacts, int messages, int chats, int handles, DateTime? lastModified
});




}
/// @nodoc
class _$ImportDatabaseStatsCopyWithImpl<$Res>
    implements $ImportDatabaseStatsCopyWith<$Res> {
  _$ImportDatabaseStatsCopyWithImpl(this._self, this._then);

  final ImportDatabaseStats _self;
  final $Res Function(ImportDatabaseStats) _then;

/// Create a copy of ImportDatabaseStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRecords = null,Object? contacts = null,Object? messages = null,Object? chats = null,Object? handles = null,Object? lastModified = freezed,}) {
  return _then(_self.copyWith(
totalRecords: null == totalRecords ? _self.totalRecords : totalRecords // ignore: cast_nullable_to_non_nullable
as int,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as int,chats: null == chats ? _self.chats : chats // ignore: cast_nullable_to_non_nullable
as int,handles: null == handles ? _self.handles : handles // ignore: cast_nullable_to_non_nullable
as int,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportDatabaseStats].
extension ImportDatabaseStatsPatterns on ImportDatabaseStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportDatabaseStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportDatabaseStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportDatabaseStats value)  $default,){
final _that = this;
switch (_that) {
case _ImportDatabaseStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportDatabaseStats value)?  $default,){
final _that = this;
switch (_that) {
case _ImportDatabaseStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalRecords,  int contacts,  int messages,  int chats,  int handles,  DateTime? lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportDatabaseStats() when $default != null:
return $default(_that.totalRecords,_that.contacts,_that.messages,_that.chats,_that.handles,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalRecords,  int contacts,  int messages,  int chats,  int handles,  DateTime? lastModified)  $default,) {final _that = this;
switch (_that) {
case _ImportDatabaseStats():
return $default(_that.totalRecords,_that.contacts,_that.messages,_that.chats,_that.handles,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalRecords,  int contacts,  int messages,  int chats,  int handles,  DateTime? lastModified)?  $default,) {final _that = this;
switch (_that) {
case _ImportDatabaseStats() when $default != null:
return $default(_that.totalRecords,_that.contacts,_that.messages,_that.chats,_that.handles,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportDatabaseStats implements ImportDatabaseStats {
  const _ImportDatabaseStats({required this.totalRecords, required this.contacts, required this.messages, required this.chats, required this.handles, this.lastModified});
  factory _ImportDatabaseStats.fromJson(Map<String, dynamic> json) => _$ImportDatabaseStatsFromJson(json);

@override final  int totalRecords;
@override final  int contacts;
@override final  int messages;
@override final  int chats;
@override final  int handles;
@override final  DateTime? lastModified;

/// Create a copy of ImportDatabaseStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportDatabaseStatsCopyWith<_ImportDatabaseStats> get copyWith => __$ImportDatabaseStatsCopyWithImpl<_ImportDatabaseStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportDatabaseStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportDatabaseStats&&(identical(other.totalRecords, totalRecords) || other.totalRecords == totalRecords)&&(identical(other.contacts, contacts) || other.contacts == contacts)&&(identical(other.messages, messages) || other.messages == messages)&&(identical(other.chats, chats) || other.chats == chats)&&(identical(other.handles, handles) || other.handles == handles)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRecords,contacts,messages,chats,handles,lastModified);

@override
String toString() {
  return 'ImportDatabaseStats(totalRecords: $totalRecords, contacts: $contacts, messages: $messages, chats: $chats, handles: $handles, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$ImportDatabaseStatsCopyWith<$Res> implements $ImportDatabaseStatsCopyWith<$Res> {
  factory _$ImportDatabaseStatsCopyWith(_ImportDatabaseStats value, $Res Function(_ImportDatabaseStats) _then) = __$ImportDatabaseStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalRecords, int contacts, int messages, int chats, int handles, DateTime? lastModified
});




}
/// @nodoc
class __$ImportDatabaseStatsCopyWithImpl<$Res>
    implements _$ImportDatabaseStatsCopyWith<$Res> {
  __$ImportDatabaseStatsCopyWithImpl(this._self, this._then);

  final _ImportDatabaseStats _self;
  final $Res Function(_ImportDatabaseStats) _then;

/// Create a copy of ImportDatabaseStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRecords = null,Object? contacts = null,Object? messages = null,Object? chats = null,Object? handles = null,Object? lastModified = freezed,}) {
  return _then(_ImportDatabaseStats(
totalRecords: null == totalRecords ? _self.totalRecords : totalRecords // ignore: cast_nullable_to_non_nullable
as int,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as int,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as int,chats: null == chats ? _self.chats : chats // ignore: cast_nullable_to_non_nullable
as int,handles: null == handles ? _self.handles : handles // ignore: cast_nullable_to_non_nullable
as int,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ImportUiState {

 bool get isImporting; ImportStage get currentStage; double get progress;// 0.0 to 1.0
 String? get statusMessage; String? get errorMessage; DateTime? get lastImportDate; ImportDatabaseStats? get importDbStats; ImportDatabaseStats? get workingDbStats;// Sub-stage progress tracking
 double? get stageProgress;// 0.0 to 1.0 within current stage
 int? get stageCurrent;// Current item being processed
 int? get stageTotal;
/// Create a copy of ImportUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportUiStateCopyWith<ImportUiState> get copyWith => _$ImportUiStateCopyWithImpl<ImportUiState>(this as ImportUiState, _$identity);

  /// Serializes this ImportUiState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportUiState&&(identical(other.isImporting, isImporting) || other.isImporting == isImporting)&&(identical(other.currentStage, currentStage) || other.currentStage == currentStage)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.lastImportDate, lastImportDate) || other.lastImportDate == lastImportDate)&&(identical(other.importDbStats, importDbStats) || other.importDbStats == importDbStats)&&(identical(other.workingDbStats, workingDbStats) || other.workingDbStats == workingDbStats)&&(identical(other.stageProgress, stageProgress) || other.stageProgress == stageProgress)&&(identical(other.stageCurrent, stageCurrent) || other.stageCurrent == stageCurrent)&&(identical(other.stageTotal, stageTotal) || other.stageTotal == stageTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isImporting,currentStage,progress,statusMessage,errorMessage,lastImportDate,importDbStats,workingDbStats,stageProgress,stageCurrent,stageTotal);

@override
String toString() {
  return 'ImportUiState(isImporting: $isImporting, currentStage: $currentStage, progress: $progress, statusMessage: $statusMessage, errorMessage: $errorMessage, lastImportDate: $lastImportDate, importDbStats: $importDbStats, workingDbStats: $workingDbStats, stageProgress: $stageProgress, stageCurrent: $stageCurrent, stageTotal: $stageTotal)';
}


}

/// @nodoc
abstract mixin class $ImportUiStateCopyWith<$Res>  {
  factory $ImportUiStateCopyWith(ImportUiState value, $Res Function(ImportUiState) _then) = _$ImportUiStateCopyWithImpl;
@useResult
$Res call({
 bool isImporting, ImportStage currentStage, double progress, String? statusMessage, String? errorMessage, DateTime? lastImportDate, ImportDatabaseStats? importDbStats, ImportDatabaseStats? workingDbStats, double? stageProgress, int? stageCurrent, int? stageTotal
});


$ImportDatabaseStatsCopyWith<$Res>? get importDbStats;$ImportDatabaseStatsCopyWith<$Res>? get workingDbStats;

}
/// @nodoc
class _$ImportUiStateCopyWithImpl<$Res>
    implements $ImportUiStateCopyWith<$Res> {
  _$ImportUiStateCopyWithImpl(this._self, this._then);

  final ImportUiState _self;
  final $Res Function(ImportUiState) _then;

/// Create a copy of ImportUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isImporting = null,Object? currentStage = null,Object? progress = null,Object? statusMessage = freezed,Object? errorMessage = freezed,Object? lastImportDate = freezed,Object? importDbStats = freezed,Object? workingDbStats = freezed,Object? stageProgress = freezed,Object? stageCurrent = freezed,Object? stageTotal = freezed,}) {
  return _then(_self.copyWith(
isImporting: null == isImporting ? _self.isImporting : isImporting // ignore: cast_nullable_to_non_nullable
as bool,currentStage: null == currentStage ? _self.currentStage : currentStage // ignore: cast_nullable_to_non_nullable
as ImportStage,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,lastImportDate: freezed == lastImportDate ? _self.lastImportDate : lastImportDate // ignore: cast_nullable_to_non_nullable
as DateTime?,importDbStats: freezed == importDbStats ? _self.importDbStats : importDbStats // ignore: cast_nullable_to_non_nullable
as ImportDatabaseStats?,workingDbStats: freezed == workingDbStats ? _self.workingDbStats : workingDbStats // ignore: cast_nullable_to_non_nullable
as ImportDatabaseStats?,stageProgress: freezed == stageProgress ? _self.stageProgress : stageProgress // ignore: cast_nullable_to_non_nullable
as double?,stageCurrent: freezed == stageCurrent ? _self.stageCurrent : stageCurrent // ignore: cast_nullable_to_non_nullable
as int?,stageTotal: freezed == stageTotal ? _self.stageTotal : stageTotal // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of ImportUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportDatabaseStatsCopyWith<$Res>? get importDbStats {
    if (_self.importDbStats == null) {
    return null;
  }

  return $ImportDatabaseStatsCopyWith<$Res>(_self.importDbStats!, (value) {
    return _then(_self.copyWith(importDbStats: value));
  });
}/// Create a copy of ImportUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportDatabaseStatsCopyWith<$Res>? get workingDbStats {
    if (_self.workingDbStats == null) {
    return null;
  }

  return $ImportDatabaseStatsCopyWith<$Res>(_self.workingDbStats!, (value) {
    return _then(_self.copyWith(workingDbStats: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImportUiState].
extension ImportUiStatePatterns on ImportUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportUiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportUiState value)  $default,){
final _that = this;
switch (_that) {
case _ImportUiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportUiState value)?  $default,){
final _that = this;
switch (_that) {
case _ImportUiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isImporting,  ImportStage currentStage,  double progress,  String? statusMessage,  String? errorMessage,  DateTime? lastImportDate,  ImportDatabaseStats? importDbStats,  ImportDatabaseStats? workingDbStats,  double? stageProgress,  int? stageCurrent,  int? stageTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportUiState() when $default != null:
return $default(_that.isImporting,_that.currentStage,_that.progress,_that.statusMessage,_that.errorMessage,_that.lastImportDate,_that.importDbStats,_that.workingDbStats,_that.stageProgress,_that.stageCurrent,_that.stageTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isImporting,  ImportStage currentStage,  double progress,  String? statusMessage,  String? errorMessage,  DateTime? lastImportDate,  ImportDatabaseStats? importDbStats,  ImportDatabaseStats? workingDbStats,  double? stageProgress,  int? stageCurrent,  int? stageTotal)  $default,) {final _that = this;
switch (_that) {
case _ImportUiState():
return $default(_that.isImporting,_that.currentStage,_that.progress,_that.statusMessage,_that.errorMessage,_that.lastImportDate,_that.importDbStats,_that.workingDbStats,_that.stageProgress,_that.stageCurrent,_that.stageTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isImporting,  ImportStage currentStage,  double progress,  String? statusMessage,  String? errorMessage,  DateTime? lastImportDate,  ImportDatabaseStats? importDbStats,  ImportDatabaseStats? workingDbStats,  double? stageProgress,  int? stageCurrent,  int? stageTotal)?  $default,) {final _that = this;
switch (_that) {
case _ImportUiState() when $default != null:
return $default(_that.isImporting,_that.currentStage,_that.progress,_that.statusMessage,_that.errorMessage,_that.lastImportDate,_that.importDbStats,_that.workingDbStats,_that.stageProgress,_that.stageCurrent,_that.stageTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportUiState implements ImportUiState {
  const _ImportUiState({this.isImporting = false, this.currentStage = ImportStage.idle, this.progress = 0.0, this.statusMessage, this.errorMessage, this.lastImportDate, this.importDbStats, this.workingDbStats, this.stageProgress, this.stageCurrent, this.stageTotal});
  factory _ImportUiState.fromJson(Map<String, dynamic> json) => _$ImportUiStateFromJson(json);

@override@JsonKey() final  bool isImporting;
@override@JsonKey() final  ImportStage currentStage;
@override@JsonKey() final  double progress;
// 0.0 to 1.0
@override final  String? statusMessage;
@override final  String? errorMessage;
@override final  DateTime? lastImportDate;
@override final  ImportDatabaseStats? importDbStats;
@override final  ImportDatabaseStats? workingDbStats;
// Sub-stage progress tracking
@override final  double? stageProgress;
// 0.0 to 1.0 within current stage
@override final  int? stageCurrent;
// Current item being processed
@override final  int? stageTotal;

/// Create a copy of ImportUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportUiStateCopyWith<_ImportUiState> get copyWith => __$ImportUiStateCopyWithImpl<_ImportUiState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportUiStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportUiState&&(identical(other.isImporting, isImporting) || other.isImporting == isImporting)&&(identical(other.currentStage, currentStage) || other.currentStage == currentStage)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.lastImportDate, lastImportDate) || other.lastImportDate == lastImportDate)&&(identical(other.importDbStats, importDbStats) || other.importDbStats == importDbStats)&&(identical(other.workingDbStats, workingDbStats) || other.workingDbStats == workingDbStats)&&(identical(other.stageProgress, stageProgress) || other.stageProgress == stageProgress)&&(identical(other.stageCurrent, stageCurrent) || other.stageCurrent == stageCurrent)&&(identical(other.stageTotal, stageTotal) || other.stageTotal == stageTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isImporting,currentStage,progress,statusMessage,errorMessage,lastImportDate,importDbStats,workingDbStats,stageProgress,stageCurrent,stageTotal);

@override
String toString() {
  return 'ImportUiState(isImporting: $isImporting, currentStage: $currentStage, progress: $progress, statusMessage: $statusMessage, errorMessage: $errorMessage, lastImportDate: $lastImportDate, importDbStats: $importDbStats, workingDbStats: $workingDbStats, stageProgress: $stageProgress, stageCurrent: $stageCurrent, stageTotal: $stageTotal)';
}


}

/// @nodoc
abstract mixin class _$ImportUiStateCopyWith<$Res> implements $ImportUiStateCopyWith<$Res> {
  factory _$ImportUiStateCopyWith(_ImportUiState value, $Res Function(_ImportUiState) _then) = __$ImportUiStateCopyWithImpl;
@override @useResult
$Res call({
 bool isImporting, ImportStage currentStage, double progress, String? statusMessage, String? errorMessage, DateTime? lastImportDate, ImportDatabaseStats? importDbStats, ImportDatabaseStats? workingDbStats, double? stageProgress, int? stageCurrent, int? stageTotal
});


@override $ImportDatabaseStatsCopyWith<$Res>? get importDbStats;@override $ImportDatabaseStatsCopyWith<$Res>? get workingDbStats;

}
/// @nodoc
class __$ImportUiStateCopyWithImpl<$Res>
    implements _$ImportUiStateCopyWith<$Res> {
  __$ImportUiStateCopyWithImpl(this._self, this._then);

  final _ImportUiState _self;
  final $Res Function(_ImportUiState) _then;

/// Create a copy of ImportUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isImporting = null,Object? currentStage = null,Object? progress = null,Object? statusMessage = freezed,Object? errorMessage = freezed,Object? lastImportDate = freezed,Object? importDbStats = freezed,Object? workingDbStats = freezed,Object? stageProgress = freezed,Object? stageCurrent = freezed,Object? stageTotal = freezed,}) {
  return _then(_ImportUiState(
isImporting: null == isImporting ? _self.isImporting : isImporting // ignore: cast_nullable_to_non_nullable
as bool,currentStage: null == currentStage ? _self.currentStage : currentStage // ignore: cast_nullable_to_non_nullable
as ImportStage,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,lastImportDate: freezed == lastImportDate ? _self.lastImportDate : lastImportDate // ignore: cast_nullable_to_non_nullable
as DateTime?,importDbStats: freezed == importDbStats ? _self.importDbStats : importDbStats // ignore: cast_nullable_to_non_nullable
as ImportDatabaseStats?,workingDbStats: freezed == workingDbStats ? _self.workingDbStats : workingDbStats // ignore: cast_nullable_to_non_nullable
as ImportDatabaseStats?,stageProgress: freezed == stageProgress ? _self.stageProgress : stageProgress // ignore: cast_nullable_to_non_nullable
as double?,stageCurrent: freezed == stageCurrent ? _self.stageCurrent : stageCurrent // ignore: cast_nullable_to_non_nullable
as int?,stageTotal: freezed == stageTotal ? _self.stageTotal : stageTotal // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of ImportUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportDatabaseStatsCopyWith<$Res>? get importDbStats {
    if (_self.importDbStats == null) {
    return null;
  }

  return $ImportDatabaseStatsCopyWith<$Res>(_self.importDbStats!, (value) {
    return _then(_self.copyWith(importDbStats: value));
  });
}/// Create a copy of ImportUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportDatabaseStatsCopyWith<$Res>? get workingDbStats {
    if (_self.workingDbStats == null) {
    return null;
  }

  return $ImportDatabaseStatsCopyWith<$Res>(_self.workingDbStats!, (value) {
    return _then(_self.copyWith(workingDbStats: value));
  });
}
}

// dart format on
