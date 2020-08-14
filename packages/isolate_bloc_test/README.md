# Overview

A testing library which make it easy to test isolate_bloc.

## Mock initialization

To initialize isolate_bloc library you must call `initialize` function, but it is create
new isolate and spend some time to do it. To be able to use blocs without creating a new Isolate you
can use `initializeMock` function.

Example:
```dart
test('Test correct initial state', () async {
  await initializeMock(initializer);
  expect(await createBloc<SimpleBloc, String>().first, '');
});

void initializer() {
  register(create: () => SimpleBloc());
}

class SimpleBloc extends IsolateBloc<Object, String> {
  SimpleBloc() : super('');

  @override
  void onEventReceived(Object event) {
    emit('data');
  }
}
```
