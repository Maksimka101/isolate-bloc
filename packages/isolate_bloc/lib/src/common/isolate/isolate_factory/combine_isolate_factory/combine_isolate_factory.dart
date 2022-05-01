import 'package:combine/combine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/combine_isolate_factory/combine_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/combine_isolate_factory/combine_isolate_wrapper.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';

/// Isolate factory implementation which is using `combine` package to create Isolate
/// and deal with method channels.
class CombineIsolateFactory extends IIsolateFactory {
  CombineIsolateFactory([this.combineIsolateFactory]);

  final IsolateFactory? combineIsolateFactory;

  @override
  Future<IsolateCreateResult> create(
    IsolateRun isolateRun,
    Initializer initializer,
  ) async {
    final isolateFactory = combineIsolateFactory ?? effectiveIsolateFactory;
    if (ServicesBinding.instance == null) {
      WidgetsFlutterBinding.ensureInitialized();
    }

    final isolate = await isolateFactory.create((context) {
      isolateRun(CombineIsolateMessenger(context.messenger), initializer);
    });

    return IsolateCreateResult(
      CombineIsolateWrapper(isolate),
      CombineIsolateMessenger(isolate.messenger),
    );
  }
}
