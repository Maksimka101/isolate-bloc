import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_cubit.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_connector.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/abstract_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_manager/isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolated_bloc_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolated_connector.dart';
import 'package:isolate_bloc/src/common/isolate/platform_channel/platform_channel_setup.dart';
import 'package:isolate_bloc/src/common/isolate/service_events.dart';

/// Signature for initialization function which would be run in [Isolate] to
/// initialize your blocs and repository.
/// Initializer must be a global or static function.
typedef Initializer = Function();

typedef IsolateManagerCreator = Future<IsolateManager> Function(
  IsolateRun,
  Initializer,
  List<String> channels,
);

/// Maintain [IsolateBlocWrapper]s
class BlocManager {
  BlocManager._(
    this._initialStates,
    this._isolateConnector,
    this._isolateManager,
  );

  static BlocManager? instance;

  final IsolateConnector _isolateConnector;
  final IsolateManager _isolateManager;
  final Map<Type, Object?> _initialStates;
  final _freeWrappers = <Type, List<IsolateBlocWrapper>>{};
  final _wrappers = <String, IsolateBlocWrapper>{};

  /// Creates [Isolate], run user's [Initializer] and perform other tasks that are
  /// necessary for this library to work.
  /// Ensure that your app or interactions with this library starts with this
  /// function.
  /// If already initialized kills previous [Isolate] and reinitialize.
  static Future<void> initialize(
    Initializer initializer,
    IsolateManagerFactory managerFactory,
    MethodChannels platformChannels,
  ) async {
    instance?.dispose();

    final isolateManager = await managerFactory.create(
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

  /// Start creating [IsolateBlocBase] and return [IsolateBlocWrapper].
  IsolateBlocWrapper<State> createBloc<T extends IsolateBlocBase, State>() {
    void onBlocClose(String? uuid) {
      if (uuid != null) {
        _isolateConnector.sendEvent(CloseIsolateBlocEvent(uuid));
      }
    }

    final initialState = _initialStates[T];
    final messageReceiver = _isolateConnector.sendEvent;

    final blocWrapper = IsolateBlocWrapper<State>(
      state: initialState as State,
      eventReceiver: messageReceiver,
      onBlocClose: onBlocClose,
    );

    _freeWrappers[T] ??= [];
    _freeWrappers[T]!.add(blocWrapper);
    _isolateConnector.sendEvent(CreateIsolateBlocEvent(T));
    return blocWrapper;
  }

  /// Finish [IsolateBlocBase] creating which started by call [createBloc].
  /// Connect [IsolateBlocBase] to it's [IsolateBlocWrapper].
  void bindFreeWrapper(Type blocType, String id) {
    if (_freeWrappers.containsKey(blocType) && _freeWrappers[blocType]!.isNotEmpty) {
      // ignore: invalid_use_of_protected_member
      _wrappers[id] = _freeWrappers[blocType]!.removeAt(0)..connectToBloc(id);
    } else {
      throw Exception('No free bloc wrapper for $blocType');
    }
  }

  /// Call when new state from [IsolateBlocBase] received.
  /// Find wrapper by bloc id and add new state to it.
  void blocStateReceiver(String blocId, Object? state) {
    // ignore: invalid_use_of_protected_member
    _wrappers[blocId]?.stateReceiver(state);
  }

  static Future<void> _isolatedBlocRunner(
    IsolateMessenger messenger,
    Initializer userInitializer,
  ) async {
    final isolateBlocManager = IsolatedBlocManager.initialize(
      IsolatedConnector(
        messenger.add,
        Stream.castFrom<Object, ServiceEvent>(
          messenger.where((event) => event is ServiceEvent),
        ),
      ),
    );

    try {
      await userInitializer();
    } catch (e, stacktrace) {
      print("Error in user's Initializer function.");
      print('Error message: ${e.toString()}');
      print('Last stacktrace: $stacktrace');
    }

    isolateBlocManager.initializeCompleted();
  }

  /// Free all resources and kill [Isolate] with [IsolateBlocBase]s.
  void dispose() {
    _isolateManager.isolate.kill();
    _isolateConnector.dispose();
  }
}
