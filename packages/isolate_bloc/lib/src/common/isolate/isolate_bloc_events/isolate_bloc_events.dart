// ignore_for_file: prefer-match-file-name
import 'package:flutter/services.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_event.dart';

/// Event with [IsolateBloc]'s state or or with event from [IsolateBlocWrapper]
class IsolateBlocTransitionEvent extends IsolateBlocEvent {
  IsolateBlocTransitionEvent(this.blocId, this.event);

  final String blocId;
  final Object? event;

  @override
  List<Object?> get props => [blocId, event];
}

/// Request to create new [IsolateBloc]
class CreateIsolateBlocEvent extends IsolateBlocEvent {
  CreateIsolateBlocEvent(this.blocType, this.blocId);

  final Type blocType;
  final String blocId;

  @override
  List<Object?> get props => [blocType, blocId];
}

/// Event to bind [IsolateBlocWrapper] to the [IsolateBloc] when second one is created
class IsolateBlocCreatedEvent extends IsolateBlocEvent {
  IsolateBlocCreatedEvent(this.blocId);

  final String blocId;

  @override
  List<Object?> get props => [blocId];
}

/// When every [IsolateBloc]s are initialized
class IsolateBlocsInitialized extends IsolateBlocEvent {
  IsolateBlocsInitialized(this.initialStates);

  final InitialStates initialStates;

  @override
  List<Object?> get props => [initialStates];
}

/// Event to close IsolateBloc. Called by [IsolateBlocWrapper.close()]
class CloseIsolateBlocEvent extends IsolateBlocEvent {
  CloseIsolateBlocEvent(this.blocId);

  final String blocId;

  @override
  List<Object?> get props => [blocId];
}

/// Event to invoke [MethodChannel] in main isolate.
class InvokePlatformChannelEvent extends IsolateBlocEvent {
  InvokePlatformChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;

  @override
  List<Object?> get props => [data, channel, id];
}

/// Event with response from [MethodChannel]
class PlatformChannelResponseEvent extends IsolateBlocEvent {
  PlatformChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;

  @override
  List<Object?> get props => [data, id];
}

/// Event to invoke [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
class InvokeMethodChannelEvent extends IsolateBlocEvent {
  InvokeMethodChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;

  @override
  List<Object?> get props => [data, channel, id];
}

/// Event with response from [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
class MethodChannelResponseEvent extends IsolateBlocEvent {
  MethodChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;

  @override
  List<Object?> get props => [data, id];
}
