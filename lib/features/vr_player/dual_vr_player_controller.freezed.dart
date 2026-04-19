// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dual_vr_player_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DualVrPlayerController {

 VoidCallback get onPlay; VoidCallback get onPause;
/// Create a copy of DualVrPlayerController
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DualVrPlayerControllerCopyWith<DualVrPlayerController> get copyWith => _$DualVrPlayerControllerCopyWithImpl<DualVrPlayerController>(this as DualVrPlayerController, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DualVrPlayerController&&(identical(other.onPlay, onPlay) || other.onPlay == onPlay)&&(identical(other.onPause, onPause) || other.onPause == onPause));
}


@override
int get hashCode => Object.hash(runtimeType,onPlay,onPause);

@override
String toString() {
  return 'DualVrPlayerController(onPlay: $onPlay, onPause: $onPause)';
}


}

/// @nodoc
abstract mixin class $DualVrPlayerControllerCopyWith<$Res>  {
  factory $DualVrPlayerControllerCopyWith(DualVrPlayerController value, $Res Function(DualVrPlayerController) _then) = _$DualVrPlayerControllerCopyWithImpl;
@useResult
$Res call({
 void Function() onPlay, void Function() onPause
});




}
/// @nodoc
class _$DualVrPlayerControllerCopyWithImpl<$Res>
    implements $DualVrPlayerControllerCopyWith<$Res> {
  _$DualVrPlayerControllerCopyWithImpl(this._self, this._then);

  final DualVrPlayerController _self;
  final $Res Function(DualVrPlayerController) _then;

/// Create a copy of DualVrPlayerController
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? onPlay = null,Object? onPause = null,}) {
  return _then(DualVrPlayerController(
onPlay: null == onPlay ? _self.onPlay : onPlay // ignore: cast_nullable_to_non_nullable
as void Function(),onPause: null == onPause ? _self.onPause : onPause // ignore: cast_nullable_to_non_nullable
as void Function(),
  ));
}

}


/// Adds pattern-matching-related methods to [DualVrPlayerController].
extension DualVrPlayerControllerPatterns on DualVrPlayerController {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
