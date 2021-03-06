import 'dart:async';

import 'bloc_manager.dart';
import 'platform_channel/platform_channel_middleware.dart';
import 'service_events.dart';

/// Listen for [ServiceEvent]s from isolate
class IsolateConnector {
  /// Create new isolate connector which communicate with [IsolatedConnector].
  IsolateConnector(this.sendEvent, this._eventsStream) {
    _eventSubscription = _eventsStream.listen(_listener);
  }

  /// Function for sending events to [IsolatedConnector].
  final void Function(ServiceEvent) sendEvent;
  final Stream<ServiceEvent> _eventsStream;
  StreamSubscription<ServiceEvent> _eventSubscription;
  final _initializeCompleter = Completer<Map<Type, Object>>();

  /// Return [Map] with [IsolateBloc] type to it's initial state.
  /// ```dart
  /// Map.of({
  ///   IsolateBlocType: IsolateBlocState,
  /// })
  /// ```
  Future<Map<Type, Object>> get initialStates async {
    return _initializeCompleter.future;
  }

  void _listener(ServiceEvent event) {
    if (event is IsolateBlocsInitialized) {
      _initializeCompleter.complete(event.initialStates);
    } else if (event is IsolateBlocCreatedEvent) {
      BlocManager.instance.bindFreeWrapper(event.blocType, event.blocUuid);
    } else if (event is IsolateBlocTransitionEvent) {
      BlocManager.instance.blocStateReceiver(event.blocUuid, event.event);
    } else if (event is InvokePlatformChannelEvent) {
      MethodChannelMiddleware.instance
          .send(event.channel, event.data, event.id);
    } else if (event is MethodChannelResponseEvent) {
      MethodChannelMiddleware.instance
          .methodChannelResponse(event.id, event.data);
    }
  }

  /// Free all resources.
  void dispose() {
    _eventSubscription?.cancel();
  }
}
