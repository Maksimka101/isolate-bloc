# Live template for Intellij IDEA
You can read about live template [here](https://www.jetbrains.com/help/idea/using-live-templates.html#live_templates_types).
Also, you can see how it works [here](https://youtu.be/jKOTFWuC3tM).

## Simple live template
```dart
import 'package:equatable/equatable.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

abstract class $BlocName$BlocEvent {
  const $BlocName$BlocEvent();
}

abstract class $BlocName$$EventName$Event {
  const $BlocName$$EventName$Event();
}

abstract class $BlocName$BlocState extends Equatable {
  const $BlocName$BlocState();

  @override
  List<Object> get props => [];
}

class $BlocName$InitialEvent extends $BlocName$BlocState {
  const $BlocName$InitialEvent();
}

class $BlocName$Bloc extends IsolateBloc<$BlocName$BlocEvent, $BlocName$BlocState> {
  $BlocName$Bloc() : super(const $BlocName$InitialEvent());

  @override
  void onEventReceived($BlocName$BlocEvent event) {
    switch (event.runtimeType) {
      case $BlocName$$EventName$Event:
        _on$EventName$Event(event as $BlocName$$EventName$Event);
        break;
    }
  }

  Future<void> _on$EventName$Event($BlocName$$EventName$Event event) async {
    $END$
  }
}
```
Template variables

![Template variables](https://github.com/Maksimka101/isolate-bloc/blob/master/docs/assets/simple_live_template.png?raw=true)


## Live template for usage with freezed
About freezed package you can read [here](https://pub.dev/packages/freezed).
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

part '$fileNameWithoutExtension$.freezed.dart';

@freezed
abstract class $BlocName$Event with _$$$BlocName$Event {
  const factory $BlocName$Event.$EventNameCaml$() = $EventName$;
}

@freezed
abstract class $BlocName$State with _$$$BlocName$State {
  const factory $BlocName$State.initial() = Initial;
}

class $BlocName$
    extends IsolateBloc<$BlocName$Event, $BlocName$State> {
  $BlocName$() : super(const Initial());

  @override
  void onEventReceived($BlocName$Event event) {
    event.map(
      $EventNameCaml$: _on$EventName$Event,
    );
  }

  Future<void> _on$EventName$Event($EventName$ event) async {
    $END$
  }
}
```
Template variables

![Template variables](https://github.com/Maksimka101/isolate-bloc/blob/master/docs/assets/freezed_live_template.png?raw=true)
