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
      final blocManager = IsolatedBlocManager.instance;
      if (blocManager == null) {
        print("Failed to receive event in Isolate. Bloc manager is null");
      } else {
        blocManager.blocEventReceiver(event.blocUuid, event.event);
      }
    } else if (event is CreateIsolateBlocEvent) {
      final blocManager = IsolatedBlocManager.instance;
      if (blocManager == null) {
        print("Failed to create IsolateBloc. Bloc manager is null");
      } else {
        blocManager.createBloc(event.blocType);
      }
    } else if (event is CloseIsolateBlocEvent) {
      final blocManager = IsolatedBlocManager.instance;
      if (blocManager == null) {
        print("Failed to close IsolateBloc. Bloc manager is null");
      } else {
        blocManager.closeBloc(event.blocUuid);
      }
    } else if (event is PlatformChannelResponseEvent) {
      final middleware = IsolatedPlatformChannelMiddleware.instance;
      if (middleware == null) {
        print(
          "Failed to receive platform channel data. "
          "Platform channel middleware is null",
        );
      } else {
        middleware.platformChannelResponse(event.id, event.data);
      }
    } else if (event is InvokeMethodChannelEvent) {
      final middleware = IsolatedPlatformChannelMiddleware.instance;
      if (middleware == null) {
        print(
          "Failed to send platform channel data. "
          "Platform channel middleware is null",
        );
      } else {
        middleware.handlePlatformMessage(
          event.channel,
          event.id,
          event.data,
        );
      }
    }
  }
}
