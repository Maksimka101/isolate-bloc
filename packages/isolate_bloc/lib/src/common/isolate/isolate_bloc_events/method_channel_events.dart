// ignore_for_file: prefer-match-file-name
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';

/// Event to invoke [MethodChannel] in main isolate.
@immutable
class InvokePlatformChannelEvent extends MethodChannelEvent {
  const InvokePlatformChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;

  @override
  List<Object?> get props => [data, channel, id];
}

/// Event with response from [MethodChannel]
@immutable
class PlatformChannelResponseEvent extends MethodChannelEvent {
  const PlatformChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;

  @override
  List<Object?> get props => [data, id];
}

/// Event to invoke [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
@immutable
class InvokeMethodChannelEvent extends MethodChannelEvent {
  const InvokeMethodChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;

  @override
  List<Object?> get props => [data, channel, id];
}

/// Event with response from [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
@immutable
class MethodChannelResponseEvent extends MethodChannelEvent {
  const MethodChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;

  @override
  List<Object?> get props => [data, id];
}
