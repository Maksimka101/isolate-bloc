import 'dart:async';

import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_event.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/i_isolated_method_channel_middleware.dart';

/// Manager which works in Isolate
class IsolateManager {
  IsolateManager._internal(
    this._messenger,
    this._userInitializer,
    this._methodChannelMiddleware,
  );

  factory IsolateManager({
    required IIsolateMessenger messenger,
    required Initializer userInitializer,
    required IIsolatedMethodChannelMiddleware methodChannelMiddleware,
  }) {
    return instance = IsolateManager._internal(
      messenger,
      userInitializer,
      methodChannelMiddleware,
    );
  }

  static IsolateManager? instance;

  final IIsolateMessenger _messenger;
  final Initializer _userInitializer;
  final IIsolatedMethodChannelMiddleware _methodChannelMiddleware;

  final InitialStates _initialStates = {};
  final _createdBlocs = <String, IsolateBlocBase>{};
  final _freeBlocs = <Type, IsolateBlocBase>{};
  final _blocCreators = <Type, IsolateBlocCreator>{};
  final _createdBlocsSubscriptions = <String, StreamSubscription>{};
  final _isolatedBlocWrappersSubscriptions = <IsolateBlocBase, List<StreamSubscription>>{};
  final _isolatedBlocWrappers = <IsolateBlocBase, List<IsolateBlocWrapper>>{};

  final _initializeCompleter = Completer();
  StreamSubscription<IsolateBlocEvent>? _serviceEventsSubscription;

  /// Finish initialization and send initial states to the [BlocManager].
  Future<void> initialize() async {
    _serviceEventsSubscription = _messenger.messagesStream
        .where((event) => event is IsolateBlocEvent)
        .cast<IsolateBlocEvent>()
        .listen(_listenForMessagesFormUi);

    try {
      await _userInitializer();
    } catch (e, stacktrace) {
      // Throw exception only in debug mode
      assert(() {
        throw Exception('''Error in user's Initializer function.
Error message: ${e.toString()}
Stacktrace: $stacktrace''');
      }());
    }

    _initializeCompleter.complete();
    _messenger.send(IsolateBlocsInitialized(_initialStates));
  }

  /// Register [IsolateCubit].
  /// You can create [IsolateCubit] and get [IsolateBlocWrapper] from
  /// [BlocManager].createBloc only if you register this [IsolateCubit].
  ///
  /// If [initialState] is not provided bloc will be created immediately.
  /// So if you don't want to create bloc while initialization please provide [initialState]
  void register<T extends IsolateBlocBase<Object?, S>, S>(IsolateBlocCreator creator, S? initialState) {
    if (initialState == null) {
      final bloc = creator();
      _initialStates[T] = bloc.state;
      _freeBlocs[T] = bloc;
    } else {
      _initialStates[T] = initialState;
    }
    _blocCreators[T] = creator;
  }

  /// Use this function to get [IsolateBlocBase] in [Isolate].
  ///
  /// To get bloc in UI [Isolate] use [IsolateBlocProvider] which returns [IsolateBlocWrapper].
  ///
  /// This function works this way: firstly it is wait for user's [Initializer] function
  /// secondly it is looks for created bloc with type BlocA. If it is finds any, so it
  /// returns this bloc's [IsolateBlocWrapper]. Else it is creates a new bloc and
  /// add to the pull of free blocs. So when UI will call `create()`, it will not create a new bloc but
  /// return free bloc from pull.
  IsolateBlocWrapper<S> getBlocWrapper<B extends IsolateBlocBase<Object?, S>, S>() {
    late IsolateBlocWrapper<S> wrapper;
    B? isolateBloc;
    _getBloc<B>().then((bloc) {
      isolateBloc = bloc;
      final blocId = bloc.id;

      if (blocId != null) {
        // ignore: invalid_use_of_protected_member
        _createdBlocsSubscriptions[blocId] = bloc.stream.listen(wrapper.stateReceiver);
      } else {
        _isolatedBlocWrappersSubscriptions[bloc] ??= [];
        _isolatedBlocWrappers[bloc] ??= [];

        // ignore: invalid_use_of_protected_member
        _isolatedBlocWrappersSubscriptions[bloc]!.add(bloc.stream.listen(wrapper.stateReceiver));
        _isolatedBlocWrappers[bloc]!.add(wrapper);
      }
      // ignore: invalid_use_of_protected_member
      wrapper.onBlocCreated();
    });
    void onBLocClose(_) => isolateBloc?.close();
    void eventReceiver(Object? event) {
      isolateBloc?.add(event);
    }

    wrapper = IsolateBlocWrapper.isolate(eventReceiver, onBLocClose);

    return wrapper;
  }

  Future<void> dispose() async {
    await _serviceEventsSubscription?.cancel();
  }

  void _listenForMessagesFormUi(IsolateBlocEvent event) {
    switch (event.runtimeType) {
      case IsolateBlocTransitionEvent:
        event = event as IsolateBlocTransitionEvent;
        _receiveBlocEvent(event.blocId, event.event);
        break;
      case CreateIsolateBlocEvent:
        event = event as CreateIsolateBlocEvent;
        _createBloc(event.blocType, event.blocId);
        break;
      case CloseIsolateBlocEvent:
        event = event as CloseIsolateBlocEvent;
        _closeBloc(event.blocId);
        break;
      case PlatformChannelResponseEvent:
        event = event as PlatformChannelResponseEvent;
        _methodChannelMiddleware.platformChannelResponse(event.id, event.data);
        break;
      case InvokeMethodChannelEvent:
        event = event as InvokeMethodChannelEvent;
        _methodChannelMiddleware.handlePlatformMessage(
          event.channel,
          event.id,
          event.data,
        );
        break;
    }
  }

  /// Receive bloc's [uuid] and [event].
  /// Find [IsolateBlocBase] by id and add [event] to it.
  void _receiveBlocEvent(String uuid, Object? event) {
    final bloc = _createdBlocs[uuid];
    if (bloc == null) {
      throw Exception("Failed to receive event. Bloc doesn't exist");
    } else {
      bloc.add(event);
    }
  }

  /// Creates [IsolateBlocBase] and connect it to the [IsolateBlocWrapper].
  void _createBloc(Type blocType, String id) {
    final bloc = _getFreeBlocByType(blocType);
    if (bloc != null) {
      _createdBlocs[id] = bloc;
      bloc.id = id;
      _createdBlocsSubscriptions[id] = bloc.stream.listen(
        (state) => _messenger.send(
          IsolateBlocTransitionEvent(id, state),
        ),
      );

      _messenger.send(IsolateBlocCreatedEvent(id));
    }
  }

  /// Get bloc by [uuid] and close it and it's resources
  void _closeBloc(String uuid) {
    final bloc = _createdBlocs.remove(uuid);
    if (bloc == null) {
      throw Exception("Failed to close bloc because it wasn't created yet.");
    } else {
      _createdBlocsSubscriptions[uuid]?.cancel();

      for (final sub in _isolatedBlocWrappersSubscriptions[bloc] ?? <StreamSubscription>[]) {
        sub.cancel();
      }
      for (final wrapper in _isolatedBlocWrappers[bloc] ?? <IsolateBlocWrapper>[]) {
        wrapper.close();
      }
      bloc.close();
    }
  }

  /// Returns new bloc from cached in [_freeBlocs] or create new one.
  IsolateBlocBase? _getFreeBlocByType(Type type) {
    if (_freeBlocs.containsKey(type)) {
      return _freeBlocs.remove(type)!;
    } else {
      final blocCreator = _blocCreators[type];
      if (blocCreator == null) {
        throw BlocUnregisteredException(type);
      } else {
        return blocCreator.call();
      }
    }
  }

  Future<T> _getBloc<T extends IsolateBlocBase>() async {
    await _initializeCompleter.future;
    final blocsT = _createdBlocs.values.whereType<T>();
    if (blocsT.isNotEmpty) {
      return blocsT.first;
    } else if (_freeBlocs.containsKey(T)) {
      return _freeBlocs[T] as T;
    } else {
      final blocCreator = _blocCreators[T];
      if (blocCreator == null) {
        throw BlocUnregisteredException(T);
      } else {
        return _freeBlocs[T] = blocCreator() as T;
      }
    }
  }
}

/// Signature for function which creates [IsolateCubit].
typedef IsolateBlocCreator<E, S> = IsolateBlocBase<E, S> Function();

class BlocUnregisteredException implements Exception {
  BlocUnregisteredException(this.blocType);

  final Type blocType;

  @override
  String toString() {
    return 'You trying to create $blocType which is not registered.\n'
        'Ensure that you call `register<$blocType, ${blocType}State>(...) in Initializer function';
  }
}
