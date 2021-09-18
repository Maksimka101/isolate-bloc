// ignore_for_file: no-equal-arguments
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/method_channel_events.dart';

void main() {
  test('Events creating', () {
    InvokePlatformChannelEvent(null, '', '');

    PlatformChannelResponseEvent(null, '');

    InvokeMethodChannelEvent(null, '', '');

    MethodChannelResponseEvent(null, '');
  });

  test('test equality', () {
    expect(InvokePlatformChannelEvent(null, '', ''),
        InvokePlatformChannelEvent(null, '', ''));

    expect(PlatformChannelResponseEvent(null, ''),
        PlatformChannelResponseEvent(null, ''));

    expect(InvokeMethodChannelEvent(null, '', ''),
        InvokeMethodChannelEvent(null, '', ''));

    expect(MethodChannelResponseEvent(null, ''),
        MethodChannelResponseEvent(null, ''));
  });
}
