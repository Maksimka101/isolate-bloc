import 'isolated_bloc_manager.dart';
import 'platform_channel/isolated_platform_channel_middleware.dart';
import 'service_events.dart';

/// Listen for [ServiceEvent]s in Isolate
class IsolatedConnector {
  /// Create new IsolatedConnector which communicate with [IsolateConnector].
  IsolatedConnector(this.sendEvent, this._eventsStream) {
    _eventsStream.listen(_listener);
  }

  /// Function for sending events to [IsolateConnector].
  final void Function(ServiceEvent) sendEvent;
  final Stream<ServiceEvent> _eventsStream;

  void _listener(ServiceEvent event) {
    if (event is IsolateBlocTransitionEvent) {
      IsolatedBlocManager.instance
          .blocEventReceiver(event.blocUuid, event.event);
    } else if (event is CreateIsolateBlocEvent) {
      IsolatedBlocManager.instance.createBloc(event.blocType);
    } else if (event is CloseIsolateBlocEvent) {
      IsolatedBlocManager.instance.closeBloc(event.blocUuid);
    } else if (event is PlatformChannelResponseEvent) {
      IsolatedPlatformChannelMiddleware.instance
          .platformChannelResponse(event.id, event.data);
    } else if (event is InvokeMethodChannelEvent) {
      IsolatedPlatformChannelMiddleware.instance
          .handlePlatformMessage(event.channel, event.id, event.data);
    }
  }
}
