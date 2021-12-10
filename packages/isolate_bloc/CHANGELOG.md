## [2.0.1] 
 - Fix analyzer issues.
 - Add exports of `IOIsolateFactory` and `WebIsolateFactory`

## [2.0.0]
 - **BREAKING**: update `register` function. 
   - Now it requires registered bloc generic parameters. For example `register(create: () => CounterBloc())` changed to `register<CounterBloc, CounterEvent>(create: () => CounterBloc())`
   - You can set bloc's initial state `register<CounterBloc, CounterEvent>(create: () => CounterBloc(), initialState: InitialCounterEvent())`
 - **BREAKING**: `PlatformChannelSetup` renamed to `MethodChannelSetup` so  `initialize(initializer,`**`platformChannelSetup: PlatformChannelSetup()`**`)` changed to `initialize(initializer,`**`methodChannelSetup: MethodChannelSetup()`**`)`
 - **BREAKING**: `IsolateCubit` is introduced and `IsolateBloc`'s api moved to the `IsolateCubit`. You can just rename your old IsolateBlocs to IsolateCubit
 - `IsolateBlocProvider` now has `lazy` parameter

## [1.0.4]
 - Add tests and fix bug.

## [1.0.3]
 - Update error message on error in `Initializer` function.
 - Add live template for Android Studio or Intellij IDEA.

## [1.0.2]
 - Fix this two issues: [first](https://github.com/Maksimka101/isolate-bloc/issues/2), [second](https://github.com/Maksimka101/isolate-bloc/issues/1).
 - Add error message on error in `Initializer` function.

## [1.0.1]
 - Fix error in `getBloc()`

## [1.0.0]
 - First stable release. Now api won't be changed without big need.
 - Change readme due to stable release.

## [0.4.1]
 - Fix web

## [0.4.0+1]
 - Fix dependencies.

## [0.4.0]
 - Add platform channels (`MethodChannel`) support.

## [0.3.1]
 - Move `initializeMock` function to isolate_bloc_test library.

## [0.3.0]
 - Add flutter web support.
 - Update readme.

## [0.2.0]
 - Add `initializeMock` function for testing.
 - Delete `getBloc` function and rename `getBlocWrapper` to `getBloc`. 

## [0.1.2] 
 - Add and update documentation for everything.

## [0.1.1]
 - Add Weather app example.
 - Now context extension for IsolateBlocProvider have second generic type with state 
    info `context.isolateBloc<BlocA, BlocAState>()`

## [0.1.0] 
- Add tests.  
- Add `getBloc` and `getBlocWrapper` for in Isolate DI.
- Add `MultiIsolateBlocProvider` and `IsolateBlocConsumer` widgets.
- Make better description in the README.md.
- Change some APIs.

## [0.0.1] 
- Initial version.
