import 'bloc/isolate_bloc.dart';
import 'bloc/isolate_bloc_wrapper.dart';
import 'isolate/bloc_manager.dart';
import 'isolate/isolate_manager/isolate/isolate_manager.dart'
    if (dart.library.html) 'isolate/isolate_manager/web/isolate_manager.dart';
import 'isolate/isolated_bloc_manager.dart';
import 'isolate/platform_channel/platform_channel_setup.dart';

/// Signature for [IsolateBlocWrapper] injection.
typedef BlocInjector<Bloc extends IsolateBloc<Object, State>,
        State extends Object>
    = IsolateBlocWrapper<State> Function<Bloc extends IsolateBloc, State>();

/// Register [IsolateBloc].
/// You can create [IsolateBloc] and get [IsolateBlocWrapper] from
/// [createBloc] only if you register this [IsolateBloc].
void register<Event extends Object, State extends Object>({
  required IsolateBlocCreator<Event, State> create,
}) {
  IsolatedBlocManager.instance?.register<Event, State>(create);
}

/// Start creating [IsolateBloc] and return [IsolateBlocWrapper].
IsolateBlocWrapper<State>? createBloc<BlocT extends IsolateBloc<Object, State>,
    State extends Object>() {
  final blocManager = BlocManager.instance;
  if (blocManager == null) {
    print(
      '$BlocManager must not be null. '
      'Call `await $initialize()` and call this function',
    );
  } else {
    return blocManager.createBloc<BlocT, State>();
  }
}

/// Initialize [Isolate], ServiceEventListener in both Isolates and run [Initializer].
/// If already initialized and [reCreate] is true kill previous [Isolate] and reinitialize everything.
Future<void> initialize(
  Initializer userInitializer, {
  PlatformChannelSetup? platformChannelSetup,
  bool reCreate = false,
}) async {
  platformChannelSetup ??= PlatformChannelSetup();
  assert(
    !reCreate && BlocManager.instance == null,
    'You can initialize only once. '
    'Call `initialize(..., reCreate: true)` if you want to reinitialize.',
  );
  return BlocManager.initialize(
    userInitializer,
    IsolateManagerImpl.createIsolate,
    platformChannelSetup.methodChannels,
  );
}

/// Use this function to get [IsolateBloc] in [Isolate].
/// To get bloc in UI Isolate use IsolateBlocProvider which returns [IsolateBlocWrapper].
/// This function works this way: firstly it is wait for user's [Initializer] function
/// secondly it is looks for created bloc with type BlocA. If it is finds any, so it
/// returns this bloc's [IsolateBlocWrapper]. Else it is creates a new bloc and
/// add to the pull of free blocs. So when UI will call `create()`, it will not create a new bloc but
/// return free bloc from pull.
IsolateBlocWrapper<State>?
    getBloc<Bloc extends IsolateBloc<Object, State>, State extends Object>() {
  final blocManager = IsolatedBlocManager.instance;
  if (blocManager == null) {
    print(
      '$IsolatedBlocManager instance is null. '
      'Make sure that you call this function from $Initializer.',
    );
  } else {
    return blocManager.getBlocWrapper<Bloc, State>();
  }
}
