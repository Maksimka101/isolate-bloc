import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

part 'method_channel_bloc.freezed.dart';

class MethodChannelBloc
    extends IsolateBloc<MethodChannelEvent, MethodChannelState> {
  MethodChannelBloc() : super(const _Initial());

  @override
  Stream<MethodChannelState> mapEventToState(MethodChannelEvent event) async* {
    yield* event.map(
      loadAsset: _mapLoadAssetToState,
    );
  }

  Stream<MethodChannelState> _mapLoadAssetToState(_LoadAsset event) async* {
    try {
      final data = await rootBundle.loadString(event.name, cache: false);
      yield MethodChannelState.assetLoaded(data);
    } catch (e) {
      yield MethodChannelState.error("Failed to load asset.\nError: $e");
    }
  }
}

@freezed
class MethodChannelEvent with _$MethodChannelEvent {
  const factory MethodChannelEvent.loadAsset({
    required String name,
  }) = _LoadAsset;
}

@freezed
class MethodChannelState with _$MethodChannelState {
  const factory MethodChannelState.initial() = _Initial;

  const factory MethodChannelState.assetLoaded(String assetData) = _AssetLoaded;

  const factory MethodChannelState.error(String message) = _Error;
}
