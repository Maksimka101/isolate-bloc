import '../bloc/isolate_bloc.dart';
import 'isolate_manager/abstract_isolate_manager.dart';
import 'isolate_manager/isolate_messenger.dart';
import 'isolated_bloc_manager.dart';
import '../bloc/isolate_bloc_wrapper.dart';
import 'isolated_connector.dart';
import 'isolate_connector.dart';
import 'service_events.dart';

/// Signature for initialization function which would be run in [Isolate] to
/// initialize your blocs and repository.
/// Initializer must be a global or static function.
typedef Initializer = Function();

typedef IsolateManagerCreator = Future<IsolateManager> Function(
    IsolateRun, Initializer);

/// Maintain [IsolateBlocWrapper]s
class BlocManager {
  static BlocManager instance;

  final IsolateConnector _isolateConnector;
  final IsolateManager _isolateManager;
  final Map<Type, Object> _initialStates;
  final _freeWrappers = <Type, IsolateBlocWrapper>{};
  final _wrappers = <String, IsolateBlocWrapper>{};

  BlocManager._(
      this._initialStates, this._isolateConnector, this._isolateManager);

  /// Create [Isolate], run user [Initializer] and perform other tasks that are
  /// necessary for this library to work.
  /// Ensure that your app or interactions with this library starts with this
  /// function.
  /// If already initialized kill previous [Isolate] and reinitialize everything.
  static Future<void> initialize(
      Initializer initializer, IsolateManagerCreator createIsolate) async {
    assert(
      '$initializer'.contains(' static'),
      '$Initializer must be a static or global function',
    );

    if (instance != null) {
      await instance.dispose();
    }

    final isolateManager =
        await createIsolate(_isolatedBlocRunner, initializer);

    final isolateConnector = IsolateConnector(
      isolateManager.messenger.sendMessage,
      Stream.castFrom<Object, ServiceEvent>(
        isolateManager.messenger.receiveMessages
            .where((event) => event is ServiceEvent),
      ),
    );

    var initialStates = await isolateConnector.initialStates;
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
    final onBlocClose =
        (uuid) => _isolateConnector.sendEvent(CloseIsolateBlocEvent(uuid));
    var blocWrapper =
        IsolateBlocWrapper<State>(initialState, messageReceiver, onBlocClose);
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

  static void _isolatedBlocRunner(
    IsolateMessenger messenger,
    Initializer userInitializer,
  ) async {
    var isolateBlocManager = IsolatedBlocManager.initialize(
      IsolatedConnector(
        messenger.sendMessage,
        Stream.castFrom<Object, ServiceEvent>(
            messenger.receiveMessages.where((event) => event is ServiceEvent)),
      ),
    );

    await userInitializer();

    isolateBlocManager.initializeCompleted();
  }

  /// Free all resources and kill [Isolate] with [IsolateBloc]s.
  void dispose() {
    _isolateManager.isolate.kill();
    _isolateConnector.dispose();
  }
}
