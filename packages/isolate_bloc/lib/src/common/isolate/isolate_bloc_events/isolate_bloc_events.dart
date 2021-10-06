// ignore_for_file: prefer-match-file-name
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';

/// Event with [IsolateBloc]'s state or or with event from [IsolateBlocWrapper]
class IsolateBlocTransitionEvent extends IsolateBlocEvent {
  IsolateBlocTransitionEvent(this.blocId, this.event);

  final String blocId;
  final Object? event;

  @override
  List<Object?> get props => [blocId, event];
}

/// Request to create new [IsolateBloc]
class CreateIsolateBlocEvent extends IsolateBlocEvent {
  CreateIsolateBlocEvent(this.blocType, this.blocId);

  final Type blocType;
  final String blocId;

  @override
  List<Object?> get props => [blocType, blocId];
}

/// Event to bind [IsolateBlocWrapper] to the [IsolateBloc] when second one is created
class IsolateBlocCreatedEvent extends IsolateBlocEvent {
  IsolateBlocCreatedEvent(this.blocId);

  final String blocId;

  @override
  List<Object?> get props => [blocId];
}

/// When every [IsolateBloc]s are initialized
class IsolateBlocsInitialized extends IsolateBlocEvent {
  IsolateBlocsInitialized(this.initialStates);

  final InitialStates initialStates;

  @override
  List<Object?> get props => [initialStates];
}

/// Event to close IsolateBloc. Called by [IsolateBlocWrapper.close()]
class CloseIsolateBlocEvent extends IsolateBlocEvent {
  CloseIsolateBlocEvent(this.blocId);

  final String blocId;

  @override
  List<Object?> get props => [blocId];
}
