// ignore_for_file: no-equal-arguments
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/method_channel_events.dart';

void main() {
  test('Events creating', () {
    const InvokePlatformChannelEvent(null, '', '');

    const PlatformChannelResponseEvent(null, '');

    const InvokeMethodChannelEvent(null, '', '');

    const MethodChannelResponseEvent(null, '');
  });

  test('test equality', () {
    expect(
      const InvokePlatformChannelEvent(null, '', ''),
      const InvokePlatformChannelEvent(null, '', ''),
    );

    expect(
      const PlatformChannelResponseEvent(null, ''),
      const PlatformChannelResponseEvent(null, ''),
    );

    expect(
      const InvokeMethodChannelEvent(null, '', ''),
      const InvokeMethodChannelEvent(null, '', ''),
    );

    expect(
      const MethodChannelResponseEvent(null, ''),
      const MethodChannelResponseEvent(null, ''),
    );
  });
}
