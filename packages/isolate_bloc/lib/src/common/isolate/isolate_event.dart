import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

/// Class for isolate events.
@immutable
abstract class IsolateEvent extends Equatable {
  const IsolateEvent();

  @override
  List<Object?> get props => [];
}

/// Events for communication between [UIIsolateManager] and [IsolateManager].
@immutable
abstract class IsolateBlocEvent extends IsolateEvent {
  const IsolateBlocEvent();
}
