// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Step {

 int get id;
/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepCopyWith<Step> get copyWith => _$StepCopyWithImpl<Step>(this as Step, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Step&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'Step(id: $id)';
}


}

/// @nodoc
abstract mixin class $StepCopyWith<$Res>  {
  factory $StepCopyWith(Step value, $Res Function(Step) _then) = _$StepCopyWithImpl;
@useResult
$Res call({
 int id
});




}
/// @nodoc
class _$StepCopyWithImpl<$Res>
    implements $StepCopyWith<$Res> {
  _$StepCopyWithImpl(this._self, this._then);

  final Step _self;
  final $Res Function(Step) _then;

/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Step].
extension StepPatterns on Step {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TellStep value)?  tell,TResult Function( AskStep value)?  ask,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TellStep() when tell != null:
return tell(_that);case AskStep() when ask != null:
return ask(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TellStep value)  tell,required TResult Function( AskStep value)  ask,}){
final _that = this;
switch (_that) {
case TellStep():
return tell(_that);case AskStep():
return ask(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TellStep value)?  tell,TResult? Function( AskStep value)?  ask,}){
final _that = this;
switch (_that) {
case TellStep() when tell != null:
return tell(_that);case AskStep() when ask != null:
return ask(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int id,  String text,  bool advancesAutomatically,  Duration holdDuration)?  tell,TResult Function( int id,  String question)?  ask,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TellStep() when tell != null:
return tell(_that.id,_that.text,_that.advancesAutomatically,_that.holdDuration);case AskStep() when ask != null:
return ask(_that.id,_that.question);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int id,  String text,  bool advancesAutomatically,  Duration holdDuration)  tell,required TResult Function( int id,  String question)  ask,}) {final _that = this;
switch (_that) {
case TellStep():
return tell(_that.id,_that.text,_that.advancesAutomatically,_that.holdDuration);case AskStep():
return ask(_that.id,_that.question);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int id,  String text,  bool advancesAutomatically,  Duration holdDuration)?  tell,TResult? Function( int id,  String question)?  ask,}) {final _that = this;
switch (_that) {
case TellStep() when tell != null:
return tell(_that.id,_that.text,_that.advancesAutomatically,_that.holdDuration);case AskStep() when ask != null:
return ask(_that.id,_that.question);case _:
  return null;

}
}

}

/// @nodoc


class TellStep implements Step {
  const TellStep({required this.id, required this.text, required this.advancesAutomatically, required this.holdDuration});


@override final  int id;
 final  String text;
 final  bool advancesAutomatically;
 final  Duration holdDuration;

/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TellStepCopyWith<TellStep> get copyWith => _$TellStepCopyWithImpl<TellStep>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TellStep&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.advancesAutomatically, advancesAutomatically) || other.advancesAutomatically == advancesAutomatically)&&(identical(other.holdDuration, holdDuration) || other.holdDuration == holdDuration));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,advancesAutomatically,holdDuration);

@override
String toString() {
  return 'Step.tell(id: $id, text: $text, advancesAutomatically: $advancesAutomatically, holdDuration: $holdDuration)';
}


}

/// @nodoc
abstract mixin class $TellStepCopyWith<$Res> implements $StepCopyWith<$Res> {
  factory $TellStepCopyWith(TellStep value, $Res Function(TellStep) _then) = _$TellStepCopyWithImpl;
@override @useResult
$Res call({
 int id, String text, bool advancesAutomatically, Duration holdDuration
});




}
/// @nodoc
class _$TellStepCopyWithImpl<$Res>
    implements $TellStepCopyWith<$Res> {
  _$TellStepCopyWithImpl(this._self, this._then);

  final TellStep _self;
  final $Res Function(TellStep) _then;

/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? advancesAutomatically = null,Object? holdDuration = null,}) {
  return _then(TellStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,advancesAutomatically: null == advancesAutomatically ? _self.advancesAutomatically : advancesAutomatically // ignore: cast_nullable_to_non_nullable
as bool,holdDuration: null == holdDuration ? _self.holdDuration : holdDuration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class AskStep implements Step {
  const AskStep({required this.id, required this.question});


@override final  int id;
 final  String question;

/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AskStepCopyWith<AskStep> get copyWith => _$AskStepCopyWithImpl<AskStep>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AskStep&&(identical(other.id, id) || other.id == id)&&(identical(other.question, question) || other.question == question));
}


@override
int get hashCode => Object.hash(runtimeType,id,question);

@override
String toString() {
  return 'Step.ask(id: $id, question: $question)';
}


}

/// @nodoc
abstract mixin class $AskStepCopyWith<$Res> implements $StepCopyWith<$Res> {
  factory $AskStepCopyWith(AskStep value, $Res Function(AskStep) _then) = _$AskStepCopyWithImpl;
@override @useResult
$Res call({
 int id, String question
});




}
/// @nodoc
class _$AskStepCopyWithImpl<$Res>
    implements $AskStepCopyWith<$Res> {
  _$AskStepCopyWithImpl(this._self, this._then);

  final AskStep _self;
  final $Res Function(AskStep) _then;

/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? question = null,}) {
  return _then(AskStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
