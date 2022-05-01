import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/src/common/isolate/method_channel/method_channel_setup.dart';

void main() {
  test("'MethodChannelSetup' returns correct array", () {
    const emptySetup = MethodChannelSetup();
    expect(emptySetup.methodChannels, isEmpty);

    final channels = ['first', 'second'];
    final nonEmptySetup = MethodChannelSetup(methodChannelNames: channels);
    expect(nonEmptySetup.methodChannels, equals(channels));
  });
}
