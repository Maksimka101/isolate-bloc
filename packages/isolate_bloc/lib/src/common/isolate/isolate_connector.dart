import 'dart:async';

import 'package:isolate_bloc/src/common/isolate/bloc_manager.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';


/// Listen for [ServiceEvent]s from isolate
class IsolateConnector {
  /// Create new isolate connector which communicate with [IsolatedConnector].
  IsolateConnector(this.sendEvent, this._eventsStream) {
    _eventSubscription = _eventsStream.listen(_listener);
  }

  /// Function for sending events to [IsolatedConnector].
  final void Function(ServiceEvent) sendEvent;
  final Stream<ServiceEvent> _eventsStream;
  late StreamSubscription<ServiceEvent> _eventSubscription;
  final _initializeCompleter = Completer<Map<Type, Object?>>();

  /// Return [Map] with [IsolateBloc] type to it's initial state.
  /// ```dart
  /// Map.of({
  ///   IsolateBlocType: IsolateBlocState,
  /// })
  /// ```
  Future<Map<Type, Object?>> get initialStates async {
    return _initializeCompleter.future;
  }

  void _listener(ServiceEvent event) {
    if (event is IsolateBlocsInitialized) {
      _initializeCompleter.complete(event.initialStates);
    } else if (event is IsolateBlocCreatedEvent) {
      final blocManager = BlocManager.instance;
      if (blocManager == null) {
        print("BlocManager is null. Maybe you forgot to initialize?");
      } else {
        blocManager.bindFreeWrapper(event.blocType, event.blocUuid);
      }
    } else if (event is IsolateBlocTransitionEvent) {
      final blocManager = BlocManager.instance;
      if (blocManager == null) {
        print("BlocManager is null. Maybe you forgot to initialize?");
      } else {
        blocManager.blocStateReceiver(event.blocUuid, event.event);
      }
    } else if (event is InvokePlatformChannelEvent) {
      final methodChannelMiddleware = MethodChannelMiddleware.instance;
      if (methodChannelMiddleware == null) {
        print(
            "MethodChannelMiddleware is null. Maybe you forgot to initialize?");
      } else {
        methodChannelMiddleware.send(event.channel, event.data, event.id);
      }
    } else if (event is MethodChannelResponseEvent) {
      final methodChannelMiddleware = MethodChannelMiddleware.instance;
      if (methodChannelMiddleware == null) {
        print(
            "MethodChannelMiddleware is null. Maybe you forgot to initialize?");
      } else {
        methodChannelMiddleware.methodChannelResponse(event.id, event.data);
      }
    }
  }

  /// Free all resources.
  void dispose() {
    _eventSubscription.cancel();
  }
}
