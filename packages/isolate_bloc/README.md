<p align="center">
<img src="https://github.com/Maksimka101/isolate-bloc/blob/master/docs/assets/isolate_bloc_logo.svg?raw=true" height="200" alt="Bloc" />
</p>

<p align="center">
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://pub.dev/packages/isolate_bloc"><img src="https://img.shields.io/pub/v/isolate_bloc.svg" alt="Pub"></a>
</p>

---

# Overview 
The goal of this package is to make it easy to work with `BLoC` and `Isolate`.

The main difference from another BLoC pattern implementations is what blocs 
work in [Isolate](https://medium.com/dartlang/dart-asynchronous-programming-isolates-and-event-loops-bffc3e296a6a) 
and don't slow down UI. 

This package works on all flutter platforms.

You can read about BLoC pattern [here](https://www.didierboelens.com/2018/08/reactive-programming-streams-bloc/).

# Attention
This package now in beta and you should use it in pet projects only. 
If you find a bug or want some new feature please create a new issue.

## Creating a Bloc
```dart
class CounterBloc extends IsolateBloc<CountEvent, int> {
  /// The initial state of the `CounterBloc` is 0.
  CounterBloc() : super(0);

  /// When `CountEvent` is received, the current state
  /// of the bloc is accessed via `state` and
  /// a new `state` is emitted via `emit`.
  @override
  void onEventReceived(CountEvent event) {
    emit(event == CountEvent.increment ? state+1 : state-1);
  }
}
```

## Registering a Bloc
```dart
void main() async {
  await initialize(isolatedFunc);
  ...
}

/// Global function which is used to register blocs and called in Isolate
void isolatedFunc() {
  /// Register a bloc to be able to create it in main Isolate
  register(create: () => CounterBloc());
}
```

## Using Bloc in UI
```dart
YourWidget(
  /// Create CounterBloc and provide it down to the widget tree
  child: IsolateBlocProvider<CounterBloc, int>(
    child: CounterScreen(),
  ),
)
...
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: Center(
        /// Listen for CounterBloc State
        child: IsolateBlocListener<CounterBloc, int>(
          listener: (context, state) => print("New bloc state: $state"),
          /// Build widget based on CounterBloc's State
          child: IsolateBlocBuilder<CounterBloc, int>(
            builder: (context, state) {
              return Text('You tapped $state times');
            },
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'Increment',
            /// Get bloc using extension and add new event
            onPressed: () => context.isolateBloc<CounterBloc, int>().add(CountEvent.increment),
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'Decrement',
            /// Get bloc using provider class and add new event
            onPressed: () => IsolateBlocProvider.of<CounterBloc, int>(context).add(CountEvent.decrement),
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

# All Api
# IsolateBlocWrapper
IsolateBlocWrapper work like a client for IsolateBloc. It receives IsolateBloc's 
states and send events added by `wrapperInstance.add(YourEvent())`. So you can 
listen for origin bloc's state with `wrapperInstance.listen((state) { })` and add 
events as shown above.
createBloc function create IsolateBloc in Isolate and return IsolateBlocWrapper. 

## Initialization
Initialize all services required to work with IsolateBloc and register an `IsolateBloc`. 
isolatedFunc may be a future and MUST be a GLOBAL or STATIC function.
```dart
void main() async {
  /// Initialize
  await initialize(isolatedFunc);
  ...
}

/// Global function which is used to register blocs and called in Isolate
void isolatedFunc() {
  /// Register a bloc to be able to create it in main Isolate
  register(create: () => CounterBloc());
}
```

## Create new Bloc instance
To create a new instance of bloc you can use Widget or function.
```dart
/// Create with Widget
IsolateBlocProvider<BlocA, BlocAState>(
    child: ChildA(),
)
/// Create multiple blocs with Widget
MultiIsolateBlocProvider(
  providers: [
    IsolateBlocProvider<BlocA, BlocAState>(),
    IsolateBlocProvider<BlocB, BlocBState>(),
    IsolateBlocProvider<BlocC, BlocCState>(),
  ],
  child: ChildA(),
)
/// Create with function
final blocA = createBloc<BlocA, BlocAState>();
```

## Get a Bloc
```dart
IsolateBlocBuilder<CounterBloc, int>(
  buildWhen: (state, newState) {
    /// return true/false to determine whether or not
    /// to rebuild the widget with state
  builder: (context, state) {
    /// return widget here based on BlocA's state
  },
)

IsolateBlocListener<CounterBloc, int>(
  listenWhen: (state, newState) {
    /// return true/false to determine whether or not
    /// to listen for state
  },
  listener: (context, state) {
    /// listen for state
  },
  child: ChildWidget(),
)

IsolateBlocConsumer<CounterHistoryBloc, List<int>>(
  listenWhen: (state, newState) {
    /// return true/false to determine whether or not
    /// to listen for state
  },
  listener: (context, state) {
    /// listen for state
  },
  buildWhen: (state, newState) {
    /// return true/false to determine whether or not
    /// to rebuild the widget with state
  },
  builder: (context, state) {
    /// return widget here based on BlocA's state
  },
)
```

## Create Bloc Observer
```dart
void isolatedFunc() {
  IsolateBloc.observer = SimpleBlocObserver();
  register(create: () => CounterBloc());
}

class SimpleBlocObserver extends IsolateBlocObserver {
  void onEvent(IsolateBloc bloc, Object event) {
    print("New $event for $bloc");
    super.onEvent(bloc, event);
  }

  void onTransition(IsolateBloc bloc, Transition transition) {
    print("New state ${transition.nextState} from $bloc");
    super.onTransition(bloc, transition);
  }

  void onError(IsolateBloc bloc, Object error, StackTrace stackTrace) {
    print("$error in $bloc");
    super.onError(bloc, error, stackTrace);
  }
}
```

## Use Bloc in another Bloc
You can use Bloc in another Bloc. You need to use `getBloc<BlocA, BlocAState>()` 
function which return `IsolateBlocWrapper<BlocAState>` to do so.

`getBloc<BlocA, State>()` function works this way: firstly it is wait for user's initialization 
function secondly it is looks for created bloc with type BlocA. If it is finds any, so it 
returns this bloc. Else it checks whether the pool of free blocs contains the BlocA and 
return this bloc. Else it is creates a new BlocA and add to the pull of free blocs. 
So when UI will call `create<BlocA, BlocAState>()`, it will not create a new bloc but
return free bloc from pull. 
```dart
void isolatedFunc() {
  register(create: () => CounterBloc());
  register(create: () => CounterHistoryBloc(getBloc<CounterBloc, int>()));
}

class CounterBloc extends IsolateBloc<CountEvent, int> {
  CounterBloc() : super(0);

  @override
  void onEventReceived(CountEvent event) {
    emit(event == CountEvent.increment ? state + 1 : state - 1);
  }
}

class CounterHistoryBloc extends IsolateBloc<int, List<int>> {
  final IsolateBlocWrapper<int> counterBloc;
  final _history = <int>[];

  CounterHistoryBloc(this.counterBloc) : super([]) {
    counterBloc.listen(onEventReceived);
  }

  @override
  void onEventReceived(int event) {
    emit(_history..add(event));
  }
}
```

## Use platform channels
If you want to use platform channels (MethodChannels) or libraries which use them 
in your IsolateBlocs or repositories you must add MethodChannel name in 
`initialize`.

Below you can see example of how to add `url_launcher` library support.
```dart
await initialize(
  isolatedFunc,
  platformChannelSetup: PlatformChannelSetup(
    methodChannelNames: [
      'plugins.flutter.io/url_launcher',
    ],
  ),
);
```

By default, channels have already been added for flutter fire, flutter developers libraries 
and popular community libraries. All out of box supported libraries you can see [here](https://github.com/Maksimka101/isolate-bloc/blob/master/packages/isolate_bloc/lib/src/common/isolate/platform_channel/libraries.dart)
(look at `Library.name`).

# Limitations
If you will try to send one of the following items you will get 
`Illegal argument in isolate message` runtime exception.

## Lambda functions
Your event/state cannot contain anonymous functions (something like this `final callback = () {}`).
Because of it you can't send BuildContext or ThemeData.

## StackTrace
If you will try to send exception with StackTrace you will also get runtime exception. 

## ReceivePort
Just don't send this object.

# Examples
 - [Counter](https://github.com/Maksimka101/isolate-bloc/tree/master/packages/isolate_bloc/example)
 - [Weather](https://github.com/Maksimka101/isolate-bloc/tree/master/examples/weather_app)
 
