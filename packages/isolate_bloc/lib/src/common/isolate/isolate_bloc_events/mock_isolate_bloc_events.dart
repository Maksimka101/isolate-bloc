// ignore_for_file: prefer-match-file-name
import 'package:isolate_bloc/src/common/isolate/isolate_event.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:mocktail/mocktail.dart';

class MockIsolateBlocEvent extends Fake implements IsolateEvent {}

class MockCreateIsolateBlocEvent extends Fake implements CreateIsolateBlocEvent {}

class MockIsolateBlocTransitionEvent extends Fake implements IsolateBlocTransitionEvent {}
