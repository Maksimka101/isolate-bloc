import 'package:flutter/services.dart';

/// Class for not user events
abstract class ServiceEvent {}

/// Event with [IsolateBloc]'s state or or with event from [IsolateBlocWrapper]
class IsolateBlocTransitionEvent<Event> extends ServiceEvent {
  IsolateBlocTransitionEvent(this.blocUuid, this.event);

  final String blocUuid;
  final Event event;
}

/// Request to create new [IsolateBloc]
class CreateIsolateBlocEvent extends ServiceEvent {
  CreateIsolateBlocEvent(this.blocType);

  final Type blocType;
}

/// Event to bind [IsolateBlocWrapper] to the [IsolateBloc] when second one is created
class IsolateBlocCreatedEvent extends ServiceEvent {
  IsolateBlocCreatedEvent(this.blocType, this.blocUuid);

  final String blocUuid;
  final Type blocType;
}

/// When every [IsolateBloc]s are initialized
class IsolateBlocsInitialized extends ServiceEvent {
  IsolateBlocsInitialized(this.initialStates);

  final Map<Type, Object> initialStates;
}

/// Event to close IsolateBloc. Called by [IsolateBlocWrapper.close()]
class CloseIsolateBlocEvent extends ServiceEvent {
  CloseIsolateBlocEvent(this.blocUuid);

  final String blocUuid;
}

/// Event to invoke [MethodChannel] in main isolate.
class InvokePlatformChannelEvent extends ServiceEvent {
  InvokePlatformChannelEvent(this.data, this.channel, this.id);

  final ByteData data;
  final String channel;
  final String id;
}

/// Event with response from [MethodChannel]
class PlatformChannelResponseEvent extends ServiceEvent {
  PlatformChannelResponseEvent(this.data, this.id);

  final ByteData data;
  final String id;
}

/// Event to invoke [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
class InvokeMethodChannelEvent extends ServiceEvent {
  InvokeMethodChannelEvent(this.data, this.channel, this.id);

  final ByteData data;
  final String channel;
  final String id;
}

/// Event with response from [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
class MethodChannelResponseEvent extends ServiceEvent {
  MethodChannelResponseEvent(this.data, this.id);

  final ByteData data;
  final String id;
}
