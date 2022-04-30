// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'method_channel_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$MethodChannelEventTearOff {
  const _$MethodChannelEventTearOff();

  _LoadAsset loadAsset({required String name}) {
    return _LoadAsset(
      name: name,
    );
  }
}

/// @nodoc
const $MethodChannelEvent = _$MethodChannelEventTearOff();

/// @nodoc
mixin _$MethodChannelEvent {
  String get name => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name) loadAsset,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String name)? loadAsset,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name)? loadAsset,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadAsset value) loadAsset,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_LoadAsset value)? loadAsset,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadAsset value)? loadAsset,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MethodChannelEventCopyWith<MethodChannelEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MethodChannelEventCopyWith<$Res> {
  factory $MethodChannelEventCopyWith(
          MethodChannelEvent value, $Res Function(MethodChannelEvent) then) =
      _$MethodChannelEventCopyWithImpl<$Res>;
  $Res call({String name});
}

/// @nodoc
class _$MethodChannelEventCopyWithImpl<$Res>
    implements $MethodChannelEventCopyWith<$Res> {
  _$MethodChannelEventCopyWithImpl(this._value, this._then);

  final MethodChannelEvent _value;
  // ignore: unused_field
  final $Res Function(MethodChannelEvent) _then;

  @override
  $Res call({
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$LoadAssetCopyWith<$Res>
    implements $MethodChannelEventCopyWith<$Res> {
  factory _$LoadAssetCopyWith(
          _LoadAsset value, $Res Function(_LoadAsset) then) =
      __$LoadAssetCopyWithImpl<$Res>;
  @override
  $Res call({String name});
}

/// @nodoc
class __$LoadAssetCopyWithImpl<$Res>
    extends _$MethodChannelEventCopyWithImpl<$Res>
    implements _$LoadAssetCopyWith<$Res> {
  __$LoadAssetCopyWithImpl(_LoadAsset _value, $Res Function(_LoadAsset) _then)
      : super(_value, (v) => _then(v as _LoadAsset));

  @override
  _LoadAsset get _value => super._value as _LoadAsset;

  @override
  $Res call({
    Object? name = freezed,
  }) {
    return _then(_LoadAsset(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_LoadAsset implements _LoadAsset {
  const _$_LoadAsset({required this.name});

  @override
  final String name;

  @override
  String toString() {
    return 'MethodChannelEvent.loadAsset(name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoadAsset &&
            const DeepCollectionEquality().equals(other.name, name));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(name));

  @JsonKey(ignore: true)
  @override
  _$LoadAssetCopyWith<_LoadAsset> get copyWith =>
      __$LoadAssetCopyWithImpl<_LoadAsset>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name) loadAsset,
  }) {
    return loadAsset(name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String name)? loadAsset,
  }) {
    return loadAsset?.call(name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name)? loadAsset,
    required TResult orElse(),
  }) {
    if (loadAsset != null) {
      return loadAsset(name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadAsset value) loadAsset,
  }) {
    return loadAsset(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_LoadAsset value)? loadAsset,
  }) {
    return loadAsset?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadAsset value)? loadAsset,
    required TResult orElse(),
  }) {
    if (loadAsset != null) {
      return loadAsset(this);
    }
    return orElse();
  }
}

abstract class _LoadAsset implements MethodChannelEvent {
  const factory _LoadAsset({required String name}) = _$_LoadAsset;

  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$LoadAssetCopyWith<_LoadAsset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
class _$MethodChannelStateTearOff {
  const _$MethodChannelStateTearOff();

  _Initial initial() {
    return const _Initial();
  }

  _AssetLoaded assetLoaded(String assetData) {
    return _AssetLoaded(
      assetData,
    );
  }

  _Error error(String message) {
    return _Error(
      message,
    );
  }
}

/// @nodoc
const $MethodChannelState = _$MethodChannelStateTearOff();

/// @nodoc
mixin _$MethodChannelState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(String assetData) assetLoaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String assetData)? assetLoaded,
    TResult Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String assetData)? assetLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_AssetLoaded value) assetLoaded,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_AssetLoaded value)? assetLoaded,
    TResult Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_AssetLoaded value)? assetLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MethodChannelStateCopyWith<$Res> {
  factory $MethodChannelStateCopyWith(
          MethodChannelState value, $Res Function(MethodChannelState) then) =
      _$MethodChannelStateCopyWithImpl<$Res>;
}

/// @nodoc
class _$MethodChannelStateCopyWithImpl<$Res>
    implements $MethodChannelStateCopyWith<$Res> {
  _$MethodChannelStateCopyWithImpl(this._value, this._then);

  final MethodChannelState _value;
  // ignore: unused_field
  final $Res Function(MethodChannelState) _then;
}

/// @nodoc
abstract class _$InitialCopyWith<$Res> {
  factory _$InitialCopyWith(_Initial value, $Res Function(_Initial) then) =
      __$InitialCopyWithImpl<$Res>;
}

/// @nodoc
class __$InitialCopyWithImpl<$Res>
    extends _$MethodChannelStateCopyWithImpl<$Res>
    implements _$InitialCopyWith<$Res> {
  __$InitialCopyWithImpl(_Initial _value, $Res Function(_Initial) _then)
      : super(_value, (v) => _then(v as _Initial));

  @override
  _Initial get _value => super._value as _Initial;
}

/// @nodoc

class _$_Initial implements _Initial {
  const _$_Initial();

  @override
  String toString() {
    return 'MethodChannelState.initial()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(String assetData) assetLoaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String assetData)? assetLoaded,
    TResult Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String assetData)? assetLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_AssetLoaded value) assetLoaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_AssetLoaded value)? assetLoaded,
    TResult Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_AssetLoaded value)? assetLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements MethodChannelState {
  const factory _Initial() = _$_Initial;
}

/// @nodoc
abstract class _$AssetLoadedCopyWith<$Res> {
  factory _$AssetLoadedCopyWith(
          _AssetLoaded value, $Res Function(_AssetLoaded) then) =
      __$AssetLoadedCopyWithImpl<$Res>;
  $Res call({String assetData});
}

/// @nodoc
class __$AssetLoadedCopyWithImpl<$Res>
    extends _$MethodChannelStateCopyWithImpl<$Res>
    implements _$AssetLoadedCopyWith<$Res> {
  __$AssetLoadedCopyWithImpl(
      _AssetLoaded _value, $Res Function(_AssetLoaded) _then)
      : super(_value, (v) => _then(v as _AssetLoaded));

  @override
  _AssetLoaded get _value => super._value as _AssetLoaded;

  @override
  $Res call({
    Object? assetData = freezed,
  }) {
    return _then(_AssetLoaded(
      assetData == freezed
          ? _value.assetData
          : assetData // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_AssetLoaded implements _AssetLoaded {
  const _$_AssetLoaded(this.assetData);

  @override
  final String assetData;

  @override
  String toString() {
    return 'MethodChannelState.assetLoaded(assetData: $assetData)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AssetLoaded &&
            const DeepCollectionEquality().equals(other.assetData, assetData));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(assetData));

  @JsonKey(ignore: true)
  @override
  _$AssetLoadedCopyWith<_AssetLoaded> get copyWith =>
      __$AssetLoadedCopyWithImpl<_AssetLoaded>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(String assetData) assetLoaded,
    required TResult Function(String message) error,
  }) {
    return assetLoaded(assetData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String assetData)? assetLoaded,
    TResult Function(String message)? error,
  }) {
    return assetLoaded?.call(assetData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String assetData)? assetLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (assetLoaded != null) {
      return assetLoaded(assetData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_AssetLoaded value) assetLoaded,
    required TResult Function(_Error value) error,
  }) {
    return assetLoaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_AssetLoaded value)? assetLoaded,
    TResult Function(_Error value)? error,
  }) {
    return assetLoaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_AssetLoaded value)? assetLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (assetLoaded != null) {
      return assetLoaded(this);
    }
    return orElse();
  }
}

abstract class _AssetLoaded implements MethodChannelState {
  const factory _AssetLoaded(String assetData) = _$_AssetLoaded;

  String get assetData;
  @JsonKey(ignore: true)
  _$AssetLoadedCopyWith<_AssetLoaded> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$ErrorCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) then) =
      __$ErrorCopyWithImpl<$Res>;
  $Res call({String message});
}

/// @nodoc
class __$ErrorCopyWithImpl<$Res> extends _$MethodChannelStateCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(_Error _value, $Res Function(_Error) _then)
      : super(_value, (v) => _then(v as _Error));

  @override
  _Error get _value => super._value as _Error;

  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_Error(
      message == freezed
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_Error implements _Error {
  const _$_Error(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'MethodChannelState.error(message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Error &&
            const DeepCollectionEquality().equals(other.message, message));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(message));

  @JsonKey(ignore: true)
  @override
  _$ErrorCopyWith<_Error> get copyWith =>
      __$ErrorCopyWithImpl<_Error>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(String assetData) assetLoaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String assetData)? assetLoaded,
    TResult Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String assetData)? assetLoaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_AssetLoaded value) assetLoaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_AssetLoaded value)? assetLoaded,
    TResult Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_AssetLoaded value)? assetLoaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements MethodChannelState {
  const factory _Error(String message) = _$_Error;

  String get message;
  @JsonKey(ignore: true)
  _$ErrorCopyWith<_Error> get copyWith => throw _privateConstructorUsedError;
}
