// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament_integrity_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TournamentIntegrityCode {
  Enum get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TournamentErrorCode field0) error,
    required TResult Function(TournamentWarningCode field0) warning,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TournamentErrorCode field0)? error,
    TResult? Function(TournamentWarningCode field0)? warning,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TournamentErrorCode field0)? error,
    TResult Function(TournamentWarningCode field0)? warning,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TournamentIntegrityCode_Error value) error,
    required TResult Function(TournamentIntegrityCode_Warning value) warning,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TournamentIntegrityCode_Error value)? error,
    TResult? Function(TournamentIntegrityCode_Warning value)? warning,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TournamentIntegrityCode_Error value)? error,
    TResult Function(TournamentIntegrityCode_Warning value)? warning,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TournamentIntegrityCodeCopyWith<$Res> {
  factory $TournamentIntegrityCodeCopyWith(TournamentIntegrityCode value,
          $Res Function(TournamentIntegrityCode) then) =
      _$TournamentIntegrityCodeCopyWithImpl<$Res, TournamentIntegrityCode>;
}

/// @nodoc
class _$TournamentIntegrityCodeCopyWithImpl<$Res,
        $Val extends TournamentIntegrityCode>
    implements $TournamentIntegrityCodeCopyWith<$Res> {
  _$TournamentIntegrityCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TournamentIntegrityCode
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TournamentIntegrityCode_ErrorImplCopyWith<$Res> {
  factory _$$TournamentIntegrityCode_ErrorImplCopyWith(
          _$TournamentIntegrityCode_ErrorImpl value,
          $Res Function(_$TournamentIntegrityCode_ErrorImpl) then) =
      __$$TournamentIntegrityCode_ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TournamentErrorCode field0});
}

/// @nodoc
class __$$TournamentIntegrityCode_ErrorImplCopyWithImpl<$Res>
    extends _$TournamentIntegrityCodeCopyWithImpl<$Res,
        _$TournamentIntegrityCode_ErrorImpl>
    implements _$$TournamentIntegrityCode_ErrorImplCopyWith<$Res> {
  __$$TournamentIntegrityCode_ErrorImplCopyWithImpl(
      _$TournamentIntegrityCode_ErrorImpl _value,
      $Res Function(_$TournamentIntegrityCode_ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of TournamentIntegrityCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$TournamentIntegrityCode_ErrorImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as TournamentErrorCode,
    ));
  }
}

/// @nodoc

class _$TournamentIntegrityCode_ErrorImpl
    extends TournamentIntegrityCode_Error {
  const _$TournamentIntegrityCode_ErrorImpl(this.field0) : super._();

  @override
  final TournamentErrorCode field0;

  @override
  String toString() {
    return 'TournamentIntegrityCode.error(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TournamentIntegrityCode_ErrorImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of TournamentIntegrityCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TournamentIntegrityCode_ErrorImplCopyWith<
          _$TournamentIntegrityCode_ErrorImpl>
      get copyWith => __$$TournamentIntegrityCode_ErrorImplCopyWithImpl<
          _$TournamentIntegrityCode_ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TournamentErrorCode field0) error,
    required TResult Function(TournamentWarningCode field0) warning,
  }) {
    return error(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TournamentErrorCode field0)? error,
    TResult? Function(TournamentWarningCode field0)? warning,
  }) {
    return error?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TournamentErrorCode field0)? error,
    TResult Function(TournamentWarningCode field0)? warning,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TournamentIntegrityCode_Error value) error,
    required TResult Function(TournamentIntegrityCode_Warning value) warning,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TournamentIntegrityCode_Error value)? error,
    TResult? Function(TournamentIntegrityCode_Warning value)? warning,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TournamentIntegrityCode_Error value)? error,
    TResult Function(TournamentIntegrityCode_Warning value)? warning,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class TournamentIntegrityCode_Error extends TournamentIntegrityCode {
  const factory TournamentIntegrityCode_Error(
      final TournamentErrorCode field0) = _$TournamentIntegrityCode_ErrorImpl;
  const TournamentIntegrityCode_Error._() : super._();

  @override
  TournamentErrorCode get field0;

  /// Create a copy of TournamentIntegrityCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TournamentIntegrityCode_ErrorImplCopyWith<
          _$TournamentIntegrityCode_ErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TournamentIntegrityCode_WarningImplCopyWith<$Res> {
  factory _$$TournamentIntegrityCode_WarningImplCopyWith(
          _$TournamentIntegrityCode_WarningImpl value,
          $Res Function(_$TournamentIntegrityCode_WarningImpl) then) =
      __$$TournamentIntegrityCode_WarningImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TournamentWarningCode field0});
}

/// @nodoc
class __$$TournamentIntegrityCode_WarningImplCopyWithImpl<$Res>
    extends _$TournamentIntegrityCodeCopyWithImpl<$Res,
        _$TournamentIntegrityCode_WarningImpl>
    implements _$$TournamentIntegrityCode_WarningImplCopyWith<$Res> {
  __$$TournamentIntegrityCode_WarningImplCopyWithImpl(
      _$TournamentIntegrityCode_WarningImpl _value,
      $Res Function(_$TournamentIntegrityCode_WarningImpl) _then)
      : super(_value, _then);

  /// Create a copy of TournamentIntegrityCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$TournamentIntegrityCode_WarningImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as TournamentWarningCode,
    ));
  }
}

/// @nodoc

class _$TournamentIntegrityCode_WarningImpl
    extends TournamentIntegrityCode_Warning {
  const _$TournamentIntegrityCode_WarningImpl(this.field0) : super._();

  @override
  final TournamentWarningCode field0;

  @override
  String toString() {
    return 'TournamentIntegrityCode.warning(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TournamentIntegrityCode_WarningImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of TournamentIntegrityCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TournamentIntegrityCode_WarningImplCopyWith<
          _$TournamentIntegrityCode_WarningImpl>
      get copyWith => __$$TournamentIntegrityCode_WarningImplCopyWithImpl<
          _$TournamentIntegrityCode_WarningImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TournamentErrorCode field0) error,
    required TResult Function(TournamentWarningCode field0) warning,
  }) {
    return warning(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TournamentErrorCode field0)? error,
    TResult? Function(TournamentWarningCode field0)? warning,
  }) {
    return warning?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TournamentErrorCode field0)? error,
    TResult Function(TournamentWarningCode field0)? warning,
    required TResult orElse(),
  }) {
    if (warning != null) {
      return warning(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TournamentIntegrityCode_Error value) error,
    required TResult Function(TournamentIntegrityCode_Warning value) warning,
  }) {
    return warning(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TournamentIntegrityCode_Error value)? error,
    TResult? Function(TournamentIntegrityCode_Warning value)? warning,
  }) {
    return warning?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TournamentIntegrityCode_Error value)? error,
    TResult Function(TournamentIntegrityCode_Warning value)? warning,
    required TResult orElse(),
  }) {
    if (warning != null) {
      return warning(this);
    }
    return orElse();
  }
}

abstract class TournamentIntegrityCode_Warning extends TournamentIntegrityCode {
  const factory TournamentIntegrityCode_Warning(
          final TournamentWarningCode field0) =
      _$TournamentIntegrityCode_WarningImpl;
  const TournamentIntegrityCode_Warning._() : super._();

  @override
  TournamentWarningCode get field0;

  /// Create a copy of TournamentIntegrityCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TournamentIntegrityCode_WarningImplCopyWith<
          _$TournamentIntegrityCode_WarningImpl>
      get copyWith => throw _privateConstructorUsedError;
}
