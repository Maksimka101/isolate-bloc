import 'package:equatable/equatable.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/ui_method_channel_middleware.dart';

/// Class for isolate events
abstract class IsolateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Events for communication between [UIIsolateManager] and [IsolateManager]
abstract class IsolateBlocEvent extends IsolateEvent {}

/// Events for communication between [UIMethodChannelMiddleware] and [IsolatedMethodChannelMiddleware]
abstract class MethodChannelEvent extends IsolateEvent {}
