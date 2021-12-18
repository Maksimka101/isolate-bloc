<p align="center">
<img src="https://github.com/Maksimka101/isolate-bloc/blob/master/docs/assets/isolate_bloc_logo.svg?raw=true" height="200" alt="Bloc" />
</p>

<p align="center">
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://codecov.io/gh/Maksimka101/isolate-bloc">
  <img src="https://codecov.io/gh/Maksimka101/isolate-bloc/branch/master/graph/badge.svg?token=EGP3H8NWCV"/>
</a>
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
I recommend you to read about Isolates to get to know their weaknesses and strengths.
- [Performance of isolates](https://cretezy.com/2020/flutter-fast-json) (before Flutter 2.8) 
- [Lightweight isolates](https://github.com/dart-lang/sdk/issues/36097) (since Flutter 2.8) 
- [New kinds of objects that can be sent between isolates](https://github.com/dart-lang/sdk/issues/46623) (since Flutter 2.8) 

In brief, isolates share memory, so immutable objects are not copied when transferred to another isolate.
You can now use them without being afraid but you shouldn't forget that there are still 
some limitations and overhead costs.

## Bloc and Cubit
<p align="center">
<img src="https://github.com/Maksimka101/isolate-bloc/blob/master/docs/assets/isolate_bloc_scheme.svg?raw=true" height="200" alt="Data flow scheme" />
</p>

In Bloc, events are processed strictly in turn. It gets an event and responds to it with a stream of states in `mapEventToState`. Until the stream ends, the processing of a new event will not begin. 

In Cubit, events are received in `onEventReceived` and processed asynchronously, and the state is returned by the `emit` function.

## Creating
### IsolateCubit
```dart
/// Cubit for counter with `CounterEvent` and `int` state.
class CounterCubit extends IsolateCubit<CountEvent, int> {
  /// The initial state of the `CounterCubit` is 0.
  CounterCubit() : super(0);

  /// When `CountEvent` is received, the current state
  /// of the bloc is accessed via `state` and
  /// a new `state` is emitted via `emit`.
  @override
  void onEventReceived(CountEvent event) {
    emit(event == CountEvent.increment ? state+1 : state-1);
  }
}
```

### IsolateBloc
```dart
class CounterBloc extends IsolateBloc<CountEvent, int> {
  /// The initial state of the `CounterBloc` is 0.
  CounterBloc() : super(0);

  /// When `CountEvent` is received, the current state
  /// of the bloc is accessed via `state` and
  /// and a new state is emitted via `yield`.
  Stream<int> mapEventToState(CountEvent event) async* {
    yield event == CountEvent.increment ? state+1 : state-1;
  }
}
```

## Registering a Bloc or Cubit
To be able to create Bloc you need to register it. You can do with the `register` function.

```dart
void main() async {
  await initialize(isolatedFunc);
  ...
}

/// Global function which is used to register blocs or cubits and called in Isolate
void isolatedFunc() {
  /// Register a bloc or cubit to be able to create it in main Isolate
  register<CounterBloc, int>(create: () => CounterBloc());
}
```

`register` function will create one instance of all registered blocs to get their initial states.
To prevent this you may provide initial state to the `register` function.

```dart
register<CounterBloc, int>(
  create: () => CounterBloc(), 
  initialState: 0,
)
```

## Using Bloc or Cubit in UI
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
IsolateBlocWrapper works like a client for IsolateBloc. It receives IsolateBloc's 
states and sends events added by `wrapperInstance.add(YourEvent())`. So you can 
listen for origin bloc's state with `wrapperInstance.listen((state) { })` and add 
events as shown above. `createBloc<BlocA, BlocAState>()` function creates IsolateBloc in 
Isolate and returns IsolateBlocWrapper. 

```dart
// Create counter bloc and receive it's wrapper
IsolateBlocWrapper wrapper = createBloc<CounterBloc, int>();

 // Wrapper's initial state is the same as CounterBloc's initial state 
assert(wrapper.state == 0);

 // This event will be sent to the CounterBloc
wrapper.add(CounterEvent.increment);

wrapper.listen((state) => print('CounterBloc state: $state'));
```

## Initialization
To create Isolate and register Blocs you need to call `initialize` and provide initialization (isolated) function. This function will be executed in Isolate and it MUST be a GLOBAL or STATIC. 

```dart
void main() async {
  /// Initialize
  await initialize(isolatedFunc);
  ...
}

/// Global function is used to register blocs and called in Isolate
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

## Use a Bloc
```dart
IsolateBlocBuilder<CounterBloc, int>(
  buildWhen: (state, newState) {
    /// return true/false to determine whether or not
    /// to rebuild the widget with state
  builder: (context, state) {
    /// return widget here based on CounterBloc's state
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

## Observer Blocs
To observe single bloc or cubit you can override `onError`, `onEvent`, `onChange` and `onTransition` methods.

```dart
class CounterBloc extends IsolateBloc<CountEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) {...}
  
  @override
  void onError(Object error, StackTrace stackTrace) {...}
  
  @override
  void onEvent(CounterEvent event) {...}
 
  @override
  void onTransition(Transition<CounterEvent, int> transition) {...}
 
}
```

Or you can use `IsolateBlocObserver` to observe all blocs or cubits.

```dart
void isolatedFunc() {
  IsolateBloc.observer = SimpleBlocObserver();
  register(create: () => CounterBloc());
}

class SimpleBlocObserver extends IsolateBlocObserver {
  void onCreate(IsolateBlocBase bloc) {
    super.onCreate(bloc);
    print('New instance of ${bloc.runtimeType} created');
  }

  void onEvent(IsolateBlocBase bloc, Object? event) {
    super.onEvent(bloc, event);
    print('${event.runtimeType} is added to ${bloc.runtimeType}');
  }

  void onChange(IsolateBlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('State is emitted in ${bloc.runtimeType}. New state is ${change.nextState}');
  }

  void onTransition(IsolateBloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print("${bloc.runtimeType}'s state updated. "
          'New state is ${transition.nextState}, '
          'event is ${transition.event}');
  }

  void onError(IsolateBlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('Error thrown in ${bloc.runtimeType}. Error is $error');
  }

  void onClose(IsolateBlocBase bloc) {
    super.onClose(bloc);
    print('${bloc.runtimeType} is closed');
  }
}
```

## Use Bloc in another Bloc
You can use Bloc in another Bloc. To do this you need to use `getBloc<BlocA, BlocAState>()` 
function which returns `IsolateBlocWrapper<BlocAState>` .

This function works this way:
  * waits for user's [Initializer] function
  * looks for created bloc with BlocA type
    * if it finds any, so returns this bloc's [IsolateBlocWrapper]
    * otherwise it creates a new bloc and adds to the pull of free blocs.
      So when UI will call `create()`, it won't create a new bloc but return free bloc from pull.

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
If you want to use platform channels (MethodChannels) or libraries which use them in your Blocs or repositories you must provide `PlatformChannelSetup` with MethodChannel names in `initialize`.

Below you can see example of how to add `url_launcher` library support.
```dart
await initialize(
  isolatedFunc,
  methodChannelSetup: MethodChannelSetup(
    methodChannelNames: [
      'plugins.flutter.io/url_launcher',
    ],
  ),
);
```

By default, channels have already been added for flutter fire, flutter developers libraries 
and popular community libraries. All out of box supported libraries you can see [here](https://github.com/Maksimka101/isolate-bloc/blob/master/packages/isolate_bloc/lib/src/common/isolate/method_channel/libraries.dart)
(look at `Library.name`).

# Limitations
If you will try to send one of the following objects you will get 
`Illegal argument in isolate message` runtime exception.

## Lambda functions
Your event/state cannot contain anonymous functions (something like this `final callback = () {}`).
Because of it you can't send `BuildContext` or `ThemeData`.

## StackTrace
If you will try to send exception with StackTrace you will also get runtime exception. 

## ReceivePort
Just don't send this object.

# Examples
 - [Counter](https://github.com/Maksimka101/isolate-bloc/tree/master/packages/isolate_bloc/example)
 - [Weather](https://github.com/Maksimka101/isolate-bloc/tree/master/examples/weather_app)
 
# Articles
 - [Flutter. Как прокачать ваш BLoC](https://habr.com/ru/post/516764/) (ru)

# Helpers
 - [Live templates](https://github.com/Maksimka101/isolate-bloc/tree/master/docs/intellij_idea_live_template.md)
 
# Gratitude
Special thanks to [Felix Angelov](https://github.com/felangel) for the reference in the form of [bloc](https://github.com/felangel/bloc) package
