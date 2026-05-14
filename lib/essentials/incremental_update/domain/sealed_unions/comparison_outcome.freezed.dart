// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comparison_outcome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComparisonOutcome {

 String get legacy; String get shadow;
/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonOutcomeCopyWith<ComparisonOutcome> get copyWith => _$ComparisonOutcomeCopyWithImpl<ComparisonOutcome>(this as ComparisonOutcome, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonOutcome&&(identical(other.legacy, legacy) || other.legacy == legacy)&&(identical(other.shadow, shadow) || other.shadow == shadow));
}


@override
int get hashCode => Object.hash(runtimeType,legacy,shadow);

@override
String toString() {
  return 'ComparisonOutcome(legacy: $legacy, shadow: $shadow)';
}


}

/// @nodoc
abstract mixin class $ComparisonOutcomeCopyWith<$Res>  {
  factory $ComparisonOutcomeCopyWith(ComparisonOutcome value, $Res Function(ComparisonOutcome) _then) = _$ComparisonOutcomeCopyWithImpl;
@useResult
$Res call({
 String legacy, String shadow
});




}
/// @nodoc
class _$ComparisonOutcomeCopyWithImpl<$Res>
    implements $ComparisonOutcomeCopyWith<$Res> {
  _$ComparisonOutcomeCopyWithImpl(this._self, this._then);

  final ComparisonOutcome _self;
  final $Res Function(ComparisonOutcome) _then;

/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? legacy = null,Object? shadow = null,}) {
  return _then(_self.copyWith(
legacy: null == legacy ? _self.legacy : legacy // ignore: cast_nullable_to_non_nullable
as String,shadow: null == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ComparisonOutcome].
extension ComparisonOutcomePatterns on ComparisonOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ComparisonOutcomeMatch value)?  match,TResult Function( ComparisonOutcomeMismatch value)?  mismatch,TResult Function( ComparisonOutcomePhaseSkew value)?  phaseSkew,TResult Function( ComparisonOutcomeNotComparable value)?  notComparable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ComparisonOutcomeMatch() when match != null:
return match(_that);case ComparisonOutcomeMismatch() when mismatch != null:
return mismatch(_that);case ComparisonOutcomePhaseSkew() when phaseSkew != null:
return phaseSkew(_that);case ComparisonOutcomeNotComparable() when notComparable != null:
return notComparable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ComparisonOutcomeMatch value)  match,required TResult Function( ComparisonOutcomeMismatch value)  mismatch,required TResult Function( ComparisonOutcomePhaseSkew value)  phaseSkew,required TResult Function( ComparisonOutcomeNotComparable value)  notComparable,}){
final _that = this;
switch (_that) {
case ComparisonOutcomeMatch():
return match(_that);case ComparisonOutcomeMismatch():
return mismatch(_that);case ComparisonOutcomePhaseSkew():
return phaseSkew(_that);case ComparisonOutcomeNotComparable():
return notComparable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ComparisonOutcomeMatch value)?  match,TResult? Function( ComparisonOutcomeMismatch value)?  mismatch,TResult? Function( ComparisonOutcomePhaseSkew value)?  phaseSkew,TResult? Function( ComparisonOutcomeNotComparable value)?  notComparable,}){
final _that = this;
switch (_that) {
case ComparisonOutcomeMatch() when match != null:
return match(_that);case ComparisonOutcomeMismatch() when mismatch != null:
return mismatch(_that);case ComparisonOutcomePhaseSkew() when phaseSkew != null:
return phaseSkew(_that);case ComparisonOutcomeNotComparable() when notComparable != null:
return notComparable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String legacy,  String shadow)?  match,TResult Function( String legacy,  String shadow,  String reason)?  mismatch,TResult Function( String legacy,  String shadow,  String reason)?  phaseSkew,TResult Function( String legacy,  String shadow,  String reason)?  notComparable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ComparisonOutcomeMatch() when match != null:
return match(_that.legacy,_that.shadow);case ComparisonOutcomeMismatch() when mismatch != null:
return mismatch(_that.legacy,_that.shadow,_that.reason);case ComparisonOutcomePhaseSkew() when phaseSkew != null:
return phaseSkew(_that.legacy,_that.shadow,_that.reason);case ComparisonOutcomeNotComparable() when notComparable != null:
return notComparable(_that.legacy,_that.shadow,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String legacy,  String shadow)  match,required TResult Function( String legacy,  String shadow,  String reason)  mismatch,required TResult Function( String legacy,  String shadow,  String reason)  phaseSkew,required TResult Function( String legacy,  String shadow,  String reason)  notComparable,}) {final _that = this;
switch (_that) {
case ComparisonOutcomeMatch():
return match(_that.legacy,_that.shadow);case ComparisonOutcomeMismatch():
return mismatch(_that.legacy,_that.shadow,_that.reason);case ComparisonOutcomePhaseSkew():
return phaseSkew(_that.legacy,_that.shadow,_that.reason);case ComparisonOutcomeNotComparable():
return notComparable(_that.legacy,_that.shadow,_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String legacy,  String shadow)?  match,TResult? Function( String legacy,  String shadow,  String reason)?  mismatch,TResult? Function( String legacy,  String shadow,  String reason)?  phaseSkew,TResult? Function( String legacy,  String shadow,  String reason)?  notComparable,}) {final _that = this;
switch (_that) {
case ComparisonOutcomeMatch() when match != null:
return match(_that.legacy,_that.shadow);case ComparisonOutcomeMismatch() when mismatch != null:
return mismatch(_that.legacy,_that.shadow,_that.reason);case ComparisonOutcomePhaseSkew() when phaseSkew != null:
return phaseSkew(_that.legacy,_that.shadow,_that.reason);case ComparisonOutcomeNotComparable() when notComparable != null:
return notComparable(_that.legacy,_that.shadow,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class ComparisonOutcomeMatch implements ComparisonOutcome {
  const ComparisonOutcomeMatch({required this.legacy, required this.shadow});
  

@override final  String legacy;
@override final  String shadow;

/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonOutcomeMatchCopyWith<ComparisonOutcomeMatch> get copyWith => _$ComparisonOutcomeMatchCopyWithImpl<ComparisonOutcomeMatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonOutcomeMatch&&(identical(other.legacy, legacy) || other.legacy == legacy)&&(identical(other.shadow, shadow) || other.shadow == shadow));
}


@override
int get hashCode => Object.hash(runtimeType,legacy,shadow);

@override
String toString() {
  return 'ComparisonOutcome.match(legacy: $legacy, shadow: $shadow)';
}


}

/// @nodoc
abstract mixin class $ComparisonOutcomeMatchCopyWith<$Res> implements $ComparisonOutcomeCopyWith<$Res> {
  factory $ComparisonOutcomeMatchCopyWith(ComparisonOutcomeMatch value, $Res Function(ComparisonOutcomeMatch) _then) = _$ComparisonOutcomeMatchCopyWithImpl;
@override @useResult
$Res call({
 String legacy, String shadow
});




}
/// @nodoc
class _$ComparisonOutcomeMatchCopyWithImpl<$Res>
    implements $ComparisonOutcomeMatchCopyWith<$Res> {
  _$ComparisonOutcomeMatchCopyWithImpl(this._self, this._then);

  final ComparisonOutcomeMatch _self;
  final $Res Function(ComparisonOutcomeMatch) _then;

/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? legacy = null,Object? shadow = null,}) {
  return _then(ComparisonOutcomeMatch(
legacy: null == legacy ? _self.legacy : legacy // ignore: cast_nullable_to_non_nullable
as String,shadow: null == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ComparisonOutcomeMismatch implements ComparisonOutcome {
  const ComparisonOutcomeMismatch({required this.legacy, required this.shadow, required this.reason});
  

@override final  String legacy;
@override final  String shadow;
 final  String reason;

/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonOutcomeMismatchCopyWith<ComparisonOutcomeMismatch> get copyWith => _$ComparisonOutcomeMismatchCopyWithImpl<ComparisonOutcomeMismatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonOutcomeMismatch&&(identical(other.legacy, legacy) || other.legacy == legacy)&&(identical(other.shadow, shadow) || other.shadow == shadow)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,legacy,shadow,reason);

@override
String toString() {
  return 'ComparisonOutcome.mismatch(legacy: $legacy, shadow: $shadow, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ComparisonOutcomeMismatchCopyWith<$Res> implements $ComparisonOutcomeCopyWith<$Res> {
  factory $ComparisonOutcomeMismatchCopyWith(ComparisonOutcomeMismatch value, $Res Function(ComparisonOutcomeMismatch) _then) = _$ComparisonOutcomeMismatchCopyWithImpl;
@override @useResult
$Res call({
 String legacy, String shadow, String reason
});




}
/// @nodoc
class _$ComparisonOutcomeMismatchCopyWithImpl<$Res>
    implements $ComparisonOutcomeMismatchCopyWith<$Res> {
  _$ComparisonOutcomeMismatchCopyWithImpl(this._self, this._then);

  final ComparisonOutcomeMismatch _self;
  final $Res Function(ComparisonOutcomeMismatch) _then;

/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? legacy = null,Object? shadow = null,Object? reason = null,}) {
  return _then(ComparisonOutcomeMismatch(
legacy: null == legacy ? _self.legacy : legacy // ignore: cast_nullable_to_non_nullable
as String,shadow: null == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ComparisonOutcomePhaseSkew implements ComparisonOutcome {
  const ComparisonOutcomePhaseSkew({required this.legacy, required this.shadow, required this.reason});
  

@override final  String legacy;
@override final  String shadow;
 final  String reason;

/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonOutcomePhaseSkewCopyWith<ComparisonOutcomePhaseSkew> get copyWith => _$ComparisonOutcomePhaseSkewCopyWithImpl<ComparisonOutcomePhaseSkew>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonOutcomePhaseSkew&&(identical(other.legacy, legacy) || other.legacy == legacy)&&(identical(other.shadow, shadow) || other.shadow == shadow)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,legacy,shadow,reason);

@override
String toString() {
  return 'ComparisonOutcome.phaseSkew(legacy: $legacy, shadow: $shadow, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ComparisonOutcomePhaseSkewCopyWith<$Res> implements $ComparisonOutcomeCopyWith<$Res> {
  factory $ComparisonOutcomePhaseSkewCopyWith(ComparisonOutcomePhaseSkew value, $Res Function(ComparisonOutcomePhaseSkew) _then) = _$ComparisonOutcomePhaseSkewCopyWithImpl;
@override @useResult
$Res call({
 String legacy, String shadow, String reason
});




}
/// @nodoc
class _$ComparisonOutcomePhaseSkewCopyWithImpl<$Res>
    implements $ComparisonOutcomePhaseSkewCopyWith<$Res> {
  _$ComparisonOutcomePhaseSkewCopyWithImpl(this._self, this._then);

  final ComparisonOutcomePhaseSkew _self;
  final $Res Function(ComparisonOutcomePhaseSkew) _then;

/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? legacy = null,Object? shadow = null,Object? reason = null,}) {
  return _then(ComparisonOutcomePhaseSkew(
legacy: null == legacy ? _self.legacy : legacy // ignore: cast_nullable_to_non_nullable
as String,shadow: null == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ComparisonOutcomeNotComparable implements ComparisonOutcome {
  const ComparisonOutcomeNotComparable({required this.legacy, required this.shadow, required this.reason});
  

@override final  String legacy;
@override final  String shadow;
 final  String reason;

/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonOutcomeNotComparableCopyWith<ComparisonOutcomeNotComparable> get copyWith => _$ComparisonOutcomeNotComparableCopyWithImpl<ComparisonOutcomeNotComparable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonOutcomeNotComparable&&(identical(other.legacy, legacy) || other.legacy == legacy)&&(identical(other.shadow, shadow) || other.shadow == shadow)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,legacy,shadow,reason);

@override
String toString() {
  return 'ComparisonOutcome.notComparable(legacy: $legacy, shadow: $shadow, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ComparisonOutcomeNotComparableCopyWith<$Res> implements $ComparisonOutcomeCopyWith<$Res> {
  factory $ComparisonOutcomeNotComparableCopyWith(ComparisonOutcomeNotComparable value, $Res Function(ComparisonOutcomeNotComparable) _then) = _$ComparisonOutcomeNotComparableCopyWithImpl;
@override @useResult
$Res call({
 String legacy, String shadow, String reason
});




}
/// @nodoc
class _$ComparisonOutcomeNotComparableCopyWithImpl<$Res>
    implements $ComparisonOutcomeNotComparableCopyWith<$Res> {
  _$ComparisonOutcomeNotComparableCopyWithImpl(this._self, this._then);

  final ComparisonOutcomeNotComparable _self;
  final $Res Function(ComparisonOutcomeNotComparable) _then;

/// Create a copy of ComparisonOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? legacy = null,Object? shadow = null,Object? reason = null,}) {
  return _then(ComparisonOutcomeNotComparable(
legacy: null == legacy ? _self.legacy : legacy // ignore: cast_nullable_to_non_nullable
as String,shadow: null == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
