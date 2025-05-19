// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_token_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthTokenModel _$AuthTokenModelFromJson(Map<String, dynamic> json) {
  return _AuthTokenModel.fromJson(json);
}

/// @nodoc
mixin _$AuthTokenModel {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this AuthTokenModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthTokenModelCopyWith<AuthTokenModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthTokenModelCopyWith<$Res> {
  factory $AuthTokenModelCopyWith(
          AuthTokenModel value, $Res Function(AuthTokenModel) then) =
      _$AuthTokenModelCopyWithImpl<$Res, AuthTokenModel>;
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      DateTime expiresAt,
      String userId});
}

/// @nodoc
class _$AuthTokenModelCopyWithImpl<$Res, $Val extends AuthTokenModel>
    implements $AuthTokenModelCopyWith<$Res> {
  _$AuthTokenModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthTokenModelImplCopyWith<$Res>
    implements $AuthTokenModelCopyWith<$Res> {
  factory _$$AuthTokenModelImplCopyWith(_$AuthTokenModelImpl value,
          $Res Function(_$AuthTokenModelImpl) then) =
      __$$AuthTokenModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      DateTime expiresAt,
      String userId});
}

/// @nodoc
class __$$AuthTokenModelImplCopyWithImpl<$Res>
    extends _$AuthTokenModelCopyWithImpl<$Res, _$AuthTokenModelImpl>
    implements _$$AuthTokenModelImplCopyWith<$Res> {
  __$$AuthTokenModelImplCopyWithImpl(
      _$AuthTokenModelImpl _value, $Res Function(_$AuthTokenModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
    Object? userId = null,
  }) {
    return _then(_$AuthTokenModelImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthTokenModelImpl extends _AuthTokenModel {
  const _$AuthTokenModelImpl(
      {required this.accessToken,
      required this.refreshToken,
      required this.expiresAt,
      required this.userId})
      : super._();

  factory _$AuthTokenModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthTokenModelImplFromJson(json);

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final DateTime expiresAt;
  @override
  final String userId;

  @override
  String toString() {
    return 'AuthTokenModel(accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthTokenModelImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, refreshToken, expiresAt, userId);

  /// Create a copy of AuthTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthTokenModelImplCopyWith<_$AuthTokenModelImpl> get copyWith =>
      __$$AuthTokenModelImplCopyWithImpl<_$AuthTokenModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthTokenModelImplToJson(
      this,
    );
  }
}

abstract class _AuthTokenModel extends AuthTokenModel {
  const factory _AuthTokenModel(
      {required final String accessToken,
      required final String refreshToken,
      required final DateTime expiresAt,
      required final String userId}) = _$AuthTokenModelImpl;
  const _AuthTokenModel._() : super._();

  factory _AuthTokenModel.fromJson(Map<String, dynamic> json) =
      _$AuthTokenModelImpl.fromJson;

  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  DateTime get expiresAt;
  @override
  String get userId;

  /// Create a copy of AuthTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthTokenModelImplCopyWith<_$AuthTokenModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
