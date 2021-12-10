// ignore_for_file: prefer-match-file-name
import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';

/// Event with [IsolateBloc]'s state or or with event from [IsolateBlocWrapper]
@immutable
class IsolateBlocTransitionEvent extends IsolateBlocEvent {
  const IsolateBlocTransitionEvent(this.blocId, this.event);

  final String blocId;
  final Object? event;

  @override
  List<Object?> get props => [blocId, event];
}

/// Request to create new [IsolateBloc]
@immutable
class CreateIsolateBlocEvent extends IsolateBlocEvent {
  const CreateIsolateBlocEvent(this.blocType, this.blocId);

  final Type blocType;
  final String blocId;

  @override
  List<Object?> get props => [blocType, blocId];
}

/// Event to bind [IsolateBlocWrapper] to the [IsolateBloc] when second one is created
@immutable
class IsolateBlocCreatedEvent extends IsolateBlocEvent {
  const IsolateBlocCreatedEvent(this.blocId);

  final String blocId;

  @override
  List<Object?> get props => [blocId];
}

/// When every [IsolateBloc]s are initialized
@immutable
class IsolateBlocsInitialized extends IsolateBlocEvent {
  const IsolateBlocsInitialized(this.initialStates);

  final InitialStates initialStates;

  @override
  List<Object?> get props => [initialStates];
}

@immutable
/// Event to close IsolateBloc. Called by [IsolateBlocWrapper.close()]
class CloseIsolateBlocEvent extends IsolateBlocEvent {
  const CloseIsolateBlocEvent(this.blocId);

  final String blocId;

  @override
  List<Object?> get props => [blocId];
}
