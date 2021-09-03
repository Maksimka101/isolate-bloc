import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';

/// Class for isolate bloc events
abstract class IsolateBlocEvent {}

/// Event with [IsolateBloc]'s state or or with event from [IsolateBlocWrapper]
class IsolateBlocTransitionEvent extends IsolateBlocEvent {
  IsolateBlocTransitionEvent(this.blocUuid, this.event);

  final String blocUuid;
  final Object? event;
}

/// Request to create new [IsolateBloc]
class CreateIsolateBlocEvent extends IsolateBlocEvent {
  CreateIsolateBlocEvent(this.blocType);

  final Type blocType;
}

/// Event to bind [IsolateBlocWrapper] to the [IsolateBloc] when second one is created
class IsolateBlocCreatedEvent extends IsolateBlocEvent {
  IsolateBlocCreatedEvent(this.blocType, this.blocUuid);

  final String blocUuid;
  final Type blocType;
}

/// When every [IsolateBloc]s are initialized
class IsolateBlocsInitialized extends IsolateBlocEvent {
  IsolateBlocsInitialized(this.initialStates);

  final InitialStates initialStates;
}

/// Event to close IsolateBloc. Called by [IsolateBlocWrapper.close()]
class CloseIsolateBlocEvent extends IsolateBlocEvent {
  CloseIsolateBlocEvent(this.blocUuid);

  final String blocUuid;
}

/// Event to invoke [MethodChannel] in main isolate.
class InvokePlatformChannelEvent extends IsolateBlocEvent {
  InvokePlatformChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;
}

/// Event with response from [MethodChannel]
class PlatformChannelResponseEvent extends IsolateBlocEvent {
  PlatformChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;
}

/// Event to invoke [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
class InvokeMethodChannelEvent extends IsolateBlocEvent {
  InvokeMethodChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;
}

/// Event with response from [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
class MethodChannelResponseEvent extends IsolateBlocEvent {
  MethodChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;
}
