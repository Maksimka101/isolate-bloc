import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/i_isolate_messenger.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_factory/isolate/io_isolate_factory.dart';
import 'package:isolate_bloc/src/common/isolate/manager/ui_isolate_manager.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_middleware/ui_method_channel_middleware.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_setup.dart';
import 'package:path/path.dart' as path;

final _syncFilePath = path.join('.', 'syncFile.json');
final _syncFile = File(_syncFilePath);

void main() {
  late IOIsolateFactory isolateFactory;
  late MethodChannels methodChannels;
  late IsolateRun isolateRun;
  late Initializer initializer;

  setUp(() async {
    methodChannels = ['test_method_channel'];
    isolateRun = _isolateRun;
    initializer = _initializer;

    isolateFactory = IOIsolateFactory();

    await _writeSyncFile({});
  });

  tearDown(() async {
    await _syncFile.delete();
  });

  test('test isolate creating', () async {
    await isolateFactory.create(isolateRun, initializer, methodChannels);

    await Future.delayed(const Duration(seconds: 1));
    var map = await _readSyncFile();

    expect(map['isolate_run'], isTrue);
    expect(map['method_channel_initialized'], isTrue);
    expect(UIMethodChannelMiddleware.instance, isNotNull);
  });

  test('test isolate communication', () async {
    var isolateCreateResult = await isolateFactory.create(
      isolateRun,
      initializer,
      methodChannels,
    );

    isolateCreateResult.messenger
        .send(const IsolateBlocTransitionEvent('', 'test message'));
    final answer =
        await isolateCreateResult.messenger.messagesStream.firstWhere(
      (element) => element is IsolateBlocTransitionEvent,
    ) as IsolateBlocTransitionEvent;

    expect(answer.blocId, 'isolate');
    expect(answer.event, 'answer');
  });

  test('throw exception with not global or static Initializer', () async {
    initializer = () {};
    await expectLater(
        isolateFactory.create(isolateRun, initializer, methodChannels),
        throwsA(isNotNull));
  });
}

/// User's initializer function
Future<void> _initializer() async {}

Future<void> _isolateRun(
  IIsolateMessenger messenger,
  Initializer __,
) async {
  messenger.messagesStream.listen((event) {
    if (event is IsolateBlocTransitionEvent && event.event == 'test message') {
      messenger.send(const IsolateBlocTransitionEvent('isolate', 'answer'));
    }
  });

  var map = await _readSyncFile();
  map['isolate_run'] = true;
  map['method_channel_initialized'] =
      IsolatedMethodChannelMiddleware.instance != null;
  await _writeSyncFile(map);
}

Future<Map<String, dynamic>> _readSyncFile() {
  return _syncFile
      .readAsString()
      .then((value) => jsonDecode(value) as Map<String, dynamic>);
}

Future<void> _writeSyncFile(Map<String, dynamic> map) async {
  await _syncFile.writeAsString(jsonEncode(map), flush: true);
}
