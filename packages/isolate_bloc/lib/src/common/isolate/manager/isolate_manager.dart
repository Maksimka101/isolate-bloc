import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_base.dart';
import 'package:isolate_bloc/src/common/bloc/isolate_bloc_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolated_api_wrappers.dart';

/// Manager which works in Isolate, respond on [IsolateBlocEvent]s from UI Isolate,
/// manages [IsolateBlocBase]s and implements [register] and [getBloc] functions.
class IsolateManager {
  /// Creates isolate manager and set [instance].
  ///
  /// Don't forget to call [initialize] to subscribe on messages and call [Initializer].
  factory IsolateManager({
    required IIsolateMessenger messenger,
  }) {
    return instance = IsolateManager._internal(messenger);
  }

  IsolateManager._internal(this._messenger);

  /// Instance of last created manager.
  static IsolateManager? instance;

  final IIsolateMessenger _messenger;

  final InitialStates _initialStates = {};
  final _createdBlocs = <String, IsolateBlocBase>{};
  final _freeBlocs = <Type, IsolateBlocBase>{};
  final _blocCreators = <Type, IsolateBlocCreator>{};
  final _createdBlocsSubscriptions = <String, StreamSubscription>{};
  final _isolatedBlocWrappersSubscriptions =
      <IsolateBlocBase, List<StreamSubscription>>{};
  final _isolatedBlocWrappers = <IsolateBlocBase, List<IsolateBlocWrapper>>{};

  final _initializeCompleter = Completer();
  StreamSubscription<IsolateEvent>? _serviceEventsSubscription;

  /// Finish initialization by calling [Initializer] and sends initial states to the [UIIsolateManager].
  ///
  /// Throws [InitializerException] when some exception is thrown in [Initializer] in debug mode.
  Future<void> initialize(Initializer userInitializer) async {
    _serviceEventsSubscription = _messenger.messagesStream
        .where((event) => event is IsolateBlocEvent)
        .cast<IsolateBlocEvent>()
        .listen(_listenForMessagesFormUi);

    try {
      await userInitializer();
    } catch (e, stackTrace) {
      // Throw exception only in debug mode.
      if (kDebugMode) {
        throw InitializerException(e, stackTrace);
      }
    }

    _initializeCompleter.complete();
    _messenger.send(IsolateBlocsInitialized(_initialStates));
  }

  /// {@macro register}
  void registerBloc<T extends IsolateBlocBase<Object?, S>, S>(
    IsolateBlocCreator creator, {
    S? initialState,
  }) {
    if (initialState == null) {
      final bloc = creator();
      _initialStates[T] = bloc.state;
      _freeBlocs[T] = bloc;
    } else {
      _initialStates[T] = initialState;
    }
    _blocCreators[T] = creator;
  }

  /// {@macro get_bloc}
  IsolateBlocWrapper<S>
      getBlocWrapper<B extends IsolateBlocBase<Object?, S>, S>() {
    late IsolateBlocWrapper<S> wrapper;
    B? isolateBloc;
    _getBloc<B>().then((bloc) {
      isolateBloc = bloc;
      final blocId = bloc.id;

      if (blocId != null) {
        _createdBlocsSubscriptions[blocId] = bloc.stream.listen(
          // ignore: invalid_use_of_protected_member
          wrapper.stateReceiver,
        );
      } else {
        _isolatedBlocWrappersSubscriptions[bloc] ??= [];
        _isolatedBlocWrappers[bloc] ??= [];

        _isolatedBlocWrappersSubscriptions[bloc]!.add(
          // ignore: invalid_use_of_protected_member
          bloc.stream.listen(wrapper.stateReceiver),
        );
        _isolatedBlocWrappers[bloc]!.add(wrapper);
      }
      // ignore: invalid_use_of_protected_member
      wrapper.onBlocCreated();
    });

    void onBLocClose(_) => {};
    void eventReceiver(Object? event) {
      isolateBloc?.add(event);
    }

    return wrapper = IsolateBlocWrapper.isolate(
      eventReceiver,
      onBLocClose,
      _initialStates[B] as S?,
    );
  }

  /// Disposes resources.
  Future<void> dispose() async {
    await _serviceEventsSubscription?.cancel();
  }

  /// Listens and respond on [IsolateBlocEvent]s from [UIIsolateManager].
  void _listenForMessagesFormUi(IsolateBlocEvent event) {
    switch (event.runtimeType) {
      case IsolateBlocTransitionEvent:
        final transitionEvent = event as IsolateBlocTransitionEvent;
        _receiveBlocEvent(transitionEvent.blocId, transitionEvent.event);
        break;
      case CreateIsolateBlocEvent:
        final createEvent = event as CreateIsolateBlocEvent;
        _createBloc(createEvent.blocType, createEvent.blocId);
        break;
      case CloseIsolateBlocEvent:
        final closeEvent = event as CloseIsolateBlocEvent;
        _closeBloc(closeEvent.blocId);
        break;
    }
  }

  /// Receives bloc's [uuid] and [event].
  /// Finds [IsolateBlocBase] by id and adds [event] to it.
  void _receiveBlocEvent(String uuid, Object? event) {
    final bloc = _createdBlocs[uuid];
    if (bloc == null) {
      throw Exception("Failed to receive event. Bloc doesn't exist");
    } else {
      bloc.add(event);
    }
  }

  /// Creates [IsolateBlocBase] and connects it to the [IsolateBlocWrapper].
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

  /// Gets bloc by [uuid] and closes it.
  void _closeBloc(String uuid) {
    final bloc = _createdBlocs.remove(uuid);
    if (bloc == null) {
      throw Exception("Failed to close bloc because it wasn't created yet.");
    } else {
      _createdBlocsSubscriptions[uuid]?.cancel();

      final subscriptions = _isolatedBlocWrappersSubscriptions[bloc] ?? [];
      for (final sub in subscriptions) {
        sub.cancel();
      }

      final wrappers = _isolatedBlocWrappers[bloc] ?? <IsolateBlocWrapper>[];
      for (final wrapper in wrappers) {
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
        return blocCreator();
      }
    }
  }

  Future<T> _getBloc<T extends IsolateBlocBase>() async {
    await _initializeCompleter.future;
    final blocsT = _createdBlocs.values.whereType<T>().toList();
    if (blocsT.isNotEmpty) {
      return blocsT.first;
    } else if (_freeBlocs.containsKey(T)) {
      return _freeBlocs[T]! as T;
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

/// Signature for function which creates [IsolateBlocBase].
typedef IsolateBlocCreator<E, S> = IsolateBlocBase<E, S> Function();

/// This exception indicates that bloc wasn't registered.
///
/// Ensure that you call `register<Bloc, State>(...) in [Initializer] function.
class BlocUnregisteredException implements Exception {
  BlocUnregisteredException(this._blocType);

  final Type _blocType;

  @override
  String toString() {
    return 'You are trying to create $_blocType which is not registered.\n'
        'Ensure that you call `register<$_blocType, ${_blocType}State>(...) '
        'in Initializer function';
  }
}

/// This exception indicates that some exception was thrown in [Initializer] function.
///
/// Throws only in debug mode.
class InitializerException {
  InitializerException(this._error, this._stackTrace);

  final dynamic _error;
  final StackTrace _stackTrace;

  @override
  String toString() {
    return '''
           Error in user's Initializer function.
           Error message: ${_error.toString()}
           Stacktrace: $_stackTrace
           ''';
  }
}
