import '../bloc/isolate_bloc.dart';
import '../bloc/isolate_bloc_wrapper.dart';
import 'isolate_connector.dart';
import 'isolate_manager/abstract_isolate_manager.dart';
import 'isolate_manager/isolate_messenger.dart';
import 'isolated_bloc_manager.dart';
import 'isolated_connector.dart';
import 'service_events.dart';

/// Signature for initialization function which would be run in [Isolate] to
/// initialize your blocs and repository.
/// Initializer must be a global or static function.
typedef Initializer = Function();

typedef IsolateManagerCreator = Future<IsolateManager> Function(
  IsolateRun,
  Initializer, [
  List<String> channels,
]);

/// Maintain [IsolateBlocWrapper]s
class BlocManager {
  BlocManager._(
      this._initialStates, this._isolateConnector, this._isolateManager);

  static BlocManager instance;

  final IsolateConnector _isolateConnector;
  final IsolateManager _isolateManager;
  final Map<Type, Object> _initialStates;
  final _freeWrappers = <Type, IsolateBlocWrapper>{};
  final _wrappers = <String, IsolateBlocWrapper>{};

  /// Create [Isolate], run user [Initializer] and perform other tasks that are
  /// necessary for this library to work.
  /// Ensure that your app or interactions with this library starts with this
  /// function.
  /// If already initialized kill previous [Isolate] and reinitialize everything.
  static Future<void> initialize(
    Initializer initializer,
    IsolateManagerCreator createIsolate,
    List<String> platformChannels,
  ) async {
    if (instance != null) {
      instance.dispose();
    }

    final isolateManager = await createIsolate(
      _isolatedBlocRunner,
      initializer,
      platformChannels,
    );

    final isolateConnector = IsolateConnector(
      isolateManager.messenger.add,
      Stream.castFrom<Object, ServiceEvent>(
        isolateManager.messenger.where((event) => event is ServiceEvent),
      ),
    );

    final initialStates = await isolateConnector.initialStates;
    instance = BlocManager._(
      initialStates,
      isolateConnector,
      isolateManager,
    );
  }

  /// Start creating [IsolateBloc] and return [IsolateBlocWrapper].
  IsolateBlocWrapper<State> createBloc<T extends IsolateBloc, State>() {
    final initialState = _initialStates[T];
    final messageReceiver = _isolateConnector.sendEvent;
    final onBlocClose = (String uuid) =>
        _isolateConnector.sendEvent(CloseIsolateBlocEvent(uuid));
    final blocWrapper = IsolateBlocWrapper<State>(
        initialState as State, messageReceiver, onBlocClose);
    _freeWrappers[T] = blocWrapper;
    _isolateConnector.sendEvent(CreateIsolateBlocEvent(T));
    return blocWrapper;
  }

  /// Finish [IsolateBloc] creating which started by call [createBloc].
  /// Connect [IsolateBloc] to it's [IsolateBlocWrapper].
  void bindFreeWrapper(Type blocType, String id) {
    assert(_freeWrappers.containsKey(blocType),
        'No free bloc wrapper for $blocType');
    _wrappers[id] = _freeWrappers.remove(blocType)..connectToBloc(id);
  }

  /// Call when new state from [IsolateBloc] received.
  /// Find wrapper by bloc id and add new state to it.
  void blocStateReceiver(String blocId, Object state) {
    _wrappers[blocId].stateReceiver(state);
  }

  static Future<void> _isolatedBlocRunner(
    IsolateMessenger messenger,
    Initializer userInitializer,
  ) async {
    final isolateBlocManager = IsolatedBlocManager.initialize(
      IsolatedConnector(
        messenger.add,
        Stream.castFrom<Object, ServiceEvent>(
            messenger.where((event) => event is ServiceEvent)),
      ),
    );

    try {
      await userInitializer();
    } catch (e) {
      print("Error in user's $Initializer function.");
      print('Error message: ${e.toString()}');
      print('Last stacktrace: ${StackTrace.current}');
    }

    isolateBlocManager.initializeCompleted();
  }

  /// Free all resources and kill [Isolate] with [IsolateBloc]s.
  void dispose() {
    _isolateManager.isolate.kill();
    _isolateConnector.dispose();
  }
}
