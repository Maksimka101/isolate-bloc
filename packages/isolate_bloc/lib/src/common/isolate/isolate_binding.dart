import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

mixin MockSchedulerBinding on BindingBase implements SchedulerBinding {
  @override
  void initInstances() {
    super.initInstances();
  }

  @override
  var schedulingStrategy = defaultSchedulingStrategy;

  @override
  void addPersistentFrameCallback(callback) {}

  @override
  void addPostFrameCallback(callback) {}

  @override
  void addTimingsCallback(
      void Function(List<ui.FrameTiming> timings) callback) {}

  @override
  void cancelFrameCallbackWithId(int id) {}

  @override
  Duration get currentFrameTimeStamp => throw UnimplementedError();

  @override
  Duration get currentSystemFrameTimeStamp => throw UnimplementedError();

  @override
  bool debugAssertNoTransientCallbacks(String reason) {
    throw UnimplementedError();
  }

  @override
  Future<void> get endOfFrame => throw UnimplementedError();

  @override
  void ensureFrameCallbacksRegistered() {}

  @override
  void ensureVisualUpdate() {}

  @override
  bool get framesEnabled => throw UnimplementedError();

  @override
  void handleAppLifecycleStateChanged(ui.AppLifecycleState state) {}

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {}

  @override
  void handleDrawFrame() {}

  @override
  bool handleEventLoopCallback() {
    throw UnimplementedError();
  }

  @override
  bool get hasScheduledFrame => throw UnimplementedError();

  @override
  ui.AppLifecycleState get lifecycleState => ui.AppLifecycleState.resumed;

  @override
  void removeTimingsCallback(
      void Function(List<ui.FrameTiming> timings) callback) {}

  @override
  void resetEpoch() {}

  @override
  void scheduleForcedFrame() {}

  @override
  void scheduleFrame() {}

  @override
  int scheduleFrameCallback(callback, {bool rescheduling = false}) {
    throw UnimplementedError();
  }

  @override
  Future<T> scheduleTask<T>(
    TaskCallback<T> task,
    Priority priority, {
    String? debugLabel,
    Flow? flow,
  }) {
    throw UnimplementedError();
  }

  @override
  void scheduleWarmUpFrame() {}

  @override
  SchedulerPhase get schedulerPhase => throw UnimplementedError();

  @override
  int get transientCallbackCount => throw UnimplementedError();
}

class IsolateBinding extends BindingBase
    with MockSchedulerBinding, ServicesBinding {}
