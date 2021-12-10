import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/ui_method_channel_middleware.dart';

/// Class for isolate events
@immutable
abstract class IsolateEvent extends Equatable {
  const IsolateEvent();

  @override
  List<Object?> get props => [];
}

/// Events for communication between [UIIsolateManager] and [IsolateManager]
@immutable
abstract class IsolateBlocEvent extends IsolateEvent {
  const IsolateBlocEvent();
}

/// Events for communication between [UIMethodChannelMiddleware] and [IsolatedMethodChannelMiddleware]
@immutable
abstract class MethodChannelEvent extends IsolateEvent {
  const MethodChannelEvent();
}
