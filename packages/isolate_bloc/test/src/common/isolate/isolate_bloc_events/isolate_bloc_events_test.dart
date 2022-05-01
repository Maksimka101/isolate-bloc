// ignore_for_file: no-equal-arguments
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';

void main() {
  test('test equality', () {
    expect(const CloseIsolateBlocEvent('').props, isNotEmpty);

    expect(const IsolateBlocsInitialized({}).props, isNotEmpty);

    expect(const IsolateBlocCreatedEvent('').props, isNotEmpty);

    expect(const CreateIsolateBlocEvent(Object, '').props, isNotEmpty);

    expect(const IsolateBlocTransitionEvent('', '').props, isNotEmpty);
  });
}
