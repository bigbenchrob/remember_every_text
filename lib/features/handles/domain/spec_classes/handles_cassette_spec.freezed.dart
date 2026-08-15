// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'handles_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HandlesCassetteSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandlesCassetteSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandlesCassetteSpec()';
}


}

/// @nodoc
class $HandlesCassetteSpecCopyWith<$Res>  {
$HandlesCassetteSpecCopyWith(HandlesCassetteSpec _, $Res Function(HandlesCassetteSpec) __);
}


/// Adds pattern-matching-related methods to [HandlesCassetteSpec].
extension HandlesCassetteSpecPatterns on HandlesCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _HandlesStrayReviewSpec value)?  strayHandlesReview,TResult Function( _HandlesModeSwitcherSpec value)?  strayHandlesModeSwitcher,TResult Function( _HandlesTypeSwitcherSpec value)?  strayHandlesTypeSwitcher,TResult Function( _HandlesInvestigationSwitcherSpec value)?  strayHandlesInvestigationSwitcher,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandlesStrayReviewSpec() when strayHandlesReview != null:
return strayHandlesReview(_that);case _HandlesModeSwitcherSpec() when strayHandlesModeSwitcher != null:
return strayHandlesModeSwitcher(_that);case _HandlesTypeSwitcherSpec() when strayHandlesTypeSwitcher != null:
return strayHandlesTypeSwitcher(_that);case _HandlesInvestigationSwitcherSpec() when strayHandlesInvestigationSwitcher != null:
return strayHandlesInvestigationSwitcher(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _HandlesStrayReviewSpec value)  strayHandlesReview,required TResult Function( _HandlesModeSwitcherSpec value)  strayHandlesModeSwitcher,required TResult Function( _HandlesTypeSwitcherSpec value)  strayHandlesTypeSwitcher,required TResult Function( _HandlesInvestigationSwitcherSpec value)  strayHandlesInvestigationSwitcher,}){
final _that = this;
switch (_that) {
case _HandlesStrayReviewSpec():
return strayHandlesReview(_that);case _HandlesModeSwitcherSpec():
return strayHandlesModeSwitcher(_that);case _HandlesTypeSwitcherSpec():
return strayHandlesTypeSwitcher(_that);case _HandlesInvestigationSwitcherSpec():
return strayHandlesInvestigationSwitcher(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _HandlesStrayReviewSpec value)?  strayHandlesReview,TResult? Function( _HandlesModeSwitcherSpec value)?  strayHandlesModeSwitcher,TResult? Function( _HandlesTypeSwitcherSpec value)?  strayHandlesTypeSwitcher,TResult? Function( _HandlesInvestigationSwitcherSpec value)?  strayHandlesInvestigationSwitcher,}){
final _that = this;
switch (_that) {
case _HandlesStrayReviewSpec() when strayHandlesReview != null:
return strayHandlesReview(_that);case _HandlesModeSwitcherSpec() when strayHandlesModeSwitcher != null:
return strayHandlesModeSwitcher(_that);case _HandlesTypeSwitcherSpec() when strayHandlesTypeSwitcher != null:
return strayHandlesTypeSwitcher(_that);case _HandlesInvestigationSwitcherSpec() when strayHandlesInvestigationSwitcher != null:
return strayHandlesInvestigationSwitcher(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( StrayHandleInvestigation investigation,  StrayHandleFilter? filter)?  strayHandlesReview,TResult Function( StrayHandleInvestigation investigation,  StrayHandleFilter? filter)?  strayHandlesModeSwitcher,TResult Function( StrayHandleFilter selectedFilter)?  strayHandlesTypeSwitcher,TResult Function( StrayHandleInvestigation selectedInvestigation)?  strayHandlesInvestigationSwitcher,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandlesStrayReviewSpec() when strayHandlesReview != null:
return strayHandlesReview(_that.investigation,_that.filter);case _HandlesModeSwitcherSpec() when strayHandlesModeSwitcher != null:
return strayHandlesModeSwitcher(_that.investigation,_that.filter);case _HandlesTypeSwitcherSpec() when strayHandlesTypeSwitcher != null:
return strayHandlesTypeSwitcher(_that.selectedFilter);case _HandlesInvestigationSwitcherSpec() when strayHandlesInvestigationSwitcher != null:
return strayHandlesInvestigationSwitcher(_that.selectedInvestigation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( StrayHandleInvestigation investigation,  StrayHandleFilter? filter)  strayHandlesReview,required TResult Function( StrayHandleInvestigation investigation,  StrayHandleFilter? filter)  strayHandlesModeSwitcher,required TResult Function( StrayHandleFilter selectedFilter)  strayHandlesTypeSwitcher,required TResult Function( StrayHandleInvestigation selectedInvestigation)  strayHandlesInvestigationSwitcher,}) {final _that = this;
switch (_that) {
case _HandlesStrayReviewSpec():
return strayHandlesReview(_that.investigation,_that.filter);case _HandlesModeSwitcherSpec():
return strayHandlesModeSwitcher(_that.investigation,_that.filter);case _HandlesTypeSwitcherSpec():
return strayHandlesTypeSwitcher(_that.selectedFilter);case _HandlesInvestigationSwitcherSpec():
return strayHandlesInvestigationSwitcher(_that.selectedInvestigation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( StrayHandleInvestigation investigation,  StrayHandleFilter? filter)?  strayHandlesReview,TResult? Function( StrayHandleInvestigation investigation,  StrayHandleFilter? filter)?  strayHandlesModeSwitcher,TResult? Function( StrayHandleFilter selectedFilter)?  strayHandlesTypeSwitcher,TResult? Function( StrayHandleInvestigation selectedInvestigation)?  strayHandlesInvestigationSwitcher,}) {final _that = this;
switch (_that) {
case _HandlesStrayReviewSpec() when strayHandlesReview != null:
return strayHandlesReview(_that.investigation,_that.filter);case _HandlesModeSwitcherSpec() when strayHandlesModeSwitcher != null:
return strayHandlesModeSwitcher(_that.investigation,_that.filter);case _HandlesTypeSwitcherSpec() when strayHandlesTypeSwitcher != null:
return strayHandlesTypeSwitcher(_that.selectedFilter);case _HandlesInvestigationSwitcherSpec() when strayHandlesInvestigationSwitcher != null:
return strayHandlesInvestigationSwitcher(_that.selectedInvestigation);case _:
  return null;

}
}

}

/// @nodoc


class _HandlesStrayReviewSpec implements HandlesCassetteSpec {
  const _HandlesStrayReviewSpec({required this.investigation, this.filter});
  

 final  StrayHandleInvestigation investigation;
 final  StrayHandleFilter? filter;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandlesStrayReviewSpecCopyWith<_HandlesStrayReviewSpec> get copyWith => __$HandlesStrayReviewSpecCopyWithImpl<_HandlesStrayReviewSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandlesStrayReviewSpec&&(identical(other.investigation, investigation) || other.investigation == investigation)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,investigation,filter);

@override
String toString() {
  return 'HandlesCassetteSpec.strayHandlesReview(investigation: $investigation, filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$HandlesStrayReviewSpecCopyWith<$Res> implements $HandlesCassetteSpecCopyWith<$Res> {
  factory _$HandlesStrayReviewSpecCopyWith(_HandlesStrayReviewSpec value, $Res Function(_HandlesStrayReviewSpec) _then) = __$HandlesStrayReviewSpecCopyWithImpl;
@useResult
$Res call({
 StrayHandleInvestigation investigation, StrayHandleFilter? filter
});




}
/// @nodoc
class __$HandlesStrayReviewSpecCopyWithImpl<$Res>
    implements _$HandlesStrayReviewSpecCopyWith<$Res> {
  __$HandlesStrayReviewSpecCopyWithImpl(this._self, this._then);

  final _HandlesStrayReviewSpec _self;
  final $Res Function(_HandlesStrayReviewSpec) _then;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? investigation = null,Object? filter = freezed,}) {
  return _then(_HandlesStrayReviewSpec(
investigation: null == investigation ? _self.investigation : investigation // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigation,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as StrayHandleFilter?,
  ));
}


}

/// @nodoc


class _HandlesModeSwitcherSpec implements HandlesCassetteSpec {
  const _HandlesModeSwitcherSpec({required this.investigation, this.filter});
  

 final  StrayHandleInvestigation investigation;
 final  StrayHandleFilter? filter;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandlesModeSwitcherSpecCopyWith<_HandlesModeSwitcherSpec> get copyWith => __$HandlesModeSwitcherSpecCopyWithImpl<_HandlesModeSwitcherSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandlesModeSwitcherSpec&&(identical(other.investigation, investigation) || other.investigation == investigation)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,investigation,filter);

@override
String toString() {
  return 'HandlesCassetteSpec.strayHandlesModeSwitcher(investigation: $investigation, filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$HandlesModeSwitcherSpecCopyWith<$Res> implements $HandlesCassetteSpecCopyWith<$Res> {
  factory _$HandlesModeSwitcherSpecCopyWith(_HandlesModeSwitcherSpec value, $Res Function(_HandlesModeSwitcherSpec) _then) = __$HandlesModeSwitcherSpecCopyWithImpl;
@useResult
$Res call({
 StrayHandleInvestigation investigation, StrayHandleFilter? filter
});




}
/// @nodoc
class __$HandlesModeSwitcherSpecCopyWithImpl<$Res>
    implements _$HandlesModeSwitcherSpecCopyWith<$Res> {
  __$HandlesModeSwitcherSpecCopyWithImpl(this._self, this._then);

  final _HandlesModeSwitcherSpec _self;
  final $Res Function(_HandlesModeSwitcherSpec) _then;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? investigation = null,Object? filter = freezed,}) {
  return _then(_HandlesModeSwitcherSpec(
investigation: null == investigation ? _self.investigation : investigation // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigation,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as StrayHandleFilter?,
  ));
}


}

/// @nodoc


class _HandlesTypeSwitcherSpec implements HandlesCassetteSpec {
  const _HandlesTypeSwitcherSpec({this.selectedFilter = StrayHandleFilter.phones});
  

@JsonKey() final  StrayHandleFilter selectedFilter;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandlesTypeSwitcherSpecCopyWith<_HandlesTypeSwitcherSpec> get copyWith => __$HandlesTypeSwitcherSpecCopyWithImpl<_HandlesTypeSwitcherSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandlesTypeSwitcherSpec&&(identical(other.selectedFilter, selectedFilter) || other.selectedFilter == selectedFilter));
}


@override
int get hashCode => Object.hash(runtimeType,selectedFilter);

@override
String toString() {
  return 'HandlesCassetteSpec.strayHandlesTypeSwitcher(selectedFilter: $selectedFilter)';
}


}

/// @nodoc
abstract mixin class _$HandlesTypeSwitcherSpecCopyWith<$Res> implements $HandlesCassetteSpecCopyWith<$Res> {
  factory _$HandlesTypeSwitcherSpecCopyWith(_HandlesTypeSwitcherSpec value, $Res Function(_HandlesTypeSwitcherSpec) _then) = __$HandlesTypeSwitcherSpecCopyWithImpl;
@useResult
$Res call({
 StrayHandleFilter selectedFilter
});




}
/// @nodoc
class __$HandlesTypeSwitcherSpecCopyWithImpl<$Res>
    implements _$HandlesTypeSwitcherSpecCopyWith<$Res> {
  __$HandlesTypeSwitcherSpecCopyWithImpl(this._self, this._then);

  final _HandlesTypeSwitcherSpec _self;
  final $Res Function(_HandlesTypeSwitcherSpec) _then;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedFilter = null,}) {
  return _then(_HandlesTypeSwitcherSpec(
selectedFilter: null == selectedFilter ? _self.selectedFilter : selectedFilter // ignore: cast_nullable_to_non_nullable
as StrayHandleFilter,
  ));
}


}

/// @nodoc


class _HandlesInvestigationSwitcherSpec implements HandlesCassetteSpec {
  const _HandlesInvestigationSwitcherSpec({this.selectedInvestigation = StrayHandleInvestigation.identifySources});


@JsonKey() final  StrayHandleInvestigation selectedInvestigation;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandlesInvestigationSwitcherSpecCopyWith<_HandlesInvestigationSwitcherSpec> get copyWith => __$HandlesInvestigationSwitcherSpecCopyWithImpl<_HandlesInvestigationSwitcherSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandlesInvestigationSwitcherSpec&&(identical(other.selectedInvestigation, selectedInvestigation) || other.selectedInvestigation == selectedInvestigation));
}


@override
int get hashCode => Object.hash(runtimeType,selectedInvestigation);

@override
String toString() {
  return 'HandlesCassetteSpec.strayHandlesInvestigationSwitcher(selectedInvestigation: $selectedInvestigation)';
}


}

/// @nodoc
abstract mixin class _$HandlesInvestigationSwitcherSpecCopyWith<$Res> implements $HandlesCassetteSpecCopyWith<$Res> {
  factory _$HandlesInvestigationSwitcherSpecCopyWith(_HandlesInvestigationSwitcherSpec value, $Res Function(_HandlesInvestigationSwitcherSpec) _then) = __$HandlesInvestigationSwitcherSpecCopyWithImpl;
@useResult
$Res call({
 StrayHandleInvestigation selectedInvestigation
});




}
/// @nodoc
class __$HandlesInvestigationSwitcherSpecCopyWithImpl<$Res>
    implements _$HandlesInvestigationSwitcherSpecCopyWith<$Res> {
  __$HandlesInvestigationSwitcherSpecCopyWithImpl(this._self, this._then);

  final _HandlesInvestigationSwitcherSpec _self;
  final $Res Function(_HandlesInvestigationSwitcherSpec) _then;

/// Create a copy of HandlesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedInvestigation = null,}) {
  return _then(_HandlesInvestigationSwitcherSpec(
selectedInvestigation: null == selectedInvestigation ? _self.selectedInvestigation : selectedInvestigation // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigation,
  ));
}


}

// dart format on
