// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QuestionInput {
  CategoricalQuestion get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CategoricalQuestion field0) categorical,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CategoricalQuestion field0)? categorical,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CategoricalQuestion field0)? categorical,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QuestionInput_Categorical value) categorical,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QuestionInput_Categorical value)? categorical,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QuestionInput_Categorical value)? categorical,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of QuestionInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionInputCopyWith<QuestionInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionInputCopyWith<$Res> {
  factory $QuestionInputCopyWith(
          QuestionInput value, $Res Function(QuestionInput) then) =
      _$QuestionInputCopyWithImpl<$Res, QuestionInput>;
  @useResult
  $Res call({CategoricalQuestion field0});
}

/// @nodoc
class _$QuestionInputCopyWithImpl<$Res, $Val extends QuestionInput>
    implements $QuestionInputCopyWith<$Res> {
  _$QuestionInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_value.copyWith(
      field0: null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as CategoricalQuestion,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionInput_CategoricalImplCopyWith<$Res>
    implements $QuestionInputCopyWith<$Res> {
  factory _$$QuestionInput_CategoricalImplCopyWith(
          _$QuestionInput_CategoricalImpl value,
          $Res Function(_$QuestionInput_CategoricalImpl) then) =
      __$$QuestionInput_CategoricalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CategoricalQuestion field0});
}

/// @nodoc
class __$$QuestionInput_CategoricalImplCopyWithImpl<$Res>
    extends _$QuestionInputCopyWithImpl<$Res, _$QuestionInput_CategoricalImpl>
    implements _$$QuestionInput_CategoricalImplCopyWith<$Res> {
  __$$QuestionInput_CategoricalImplCopyWithImpl(
      _$QuestionInput_CategoricalImpl _value,
      $Res Function(_$QuestionInput_CategoricalImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuestionInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$QuestionInput_CategoricalImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as CategoricalQuestion,
    ));
  }
}

/// @nodoc

class _$QuestionInput_CategoricalImpl extends QuestionInput_Categorical {
  const _$QuestionInput_CategoricalImpl(this.field0) : super._();

  @override
  final CategoricalQuestion field0;

  @override
  String toString() {
    return 'QuestionInput.categorical(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionInput_CategoricalImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of QuestionInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionInput_CategoricalImplCopyWith<_$QuestionInput_CategoricalImpl>
      get copyWith => __$$QuestionInput_CategoricalImplCopyWithImpl<
          _$QuestionInput_CategoricalImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CategoricalQuestion field0) categorical,
  }) {
    return categorical(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CategoricalQuestion field0)? categorical,
  }) {
    return categorical?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CategoricalQuestion field0)? categorical,
    required TResult orElse(),
  }) {
    if (categorical != null) {
      return categorical(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QuestionInput_Categorical value) categorical,
  }) {
    return categorical(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QuestionInput_Categorical value)? categorical,
  }) {
    return categorical?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QuestionInput_Categorical value)? categorical,
    required TResult orElse(),
  }) {
    if (categorical != null) {
      return categorical(this);
    }
    return orElse();
  }
}

abstract class QuestionInput_Categorical extends QuestionInput {
  const factory QuestionInput_Categorical(final CategoricalQuestion field0) =
      _$QuestionInput_CategoricalImpl;
  const QuestionInput_Categorical._() : super._();

  @override
  CategoricalQuestion get field0;

  /// Create a copy of QuestionInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionInput_CategoricalImplCopyWith<_$QuestionInput_CategoricalImpl>
      get copyWith => throw _privateConstructorUsedError;
}
