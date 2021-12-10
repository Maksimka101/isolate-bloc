// ignore_for_file: no-equal-arguments
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';

void main() {
  test('Events creating', () {
    const CloseIsolateBlocEvent('');

    const IsolateBlocsInitialized({});

    const IsolateBlocCreatedEvent('');

    const CreateIsolateBlocEvent(Object, '');

    const IsolateBlocTransitionEvent('', '');
  });

  test('test equality', () {
    expect(const CloseIsolateBlocEvent(''), const CloseIsolateBlocEvent(''));

    expect(
      const IsolateBlocsInitialized({}),
      const IsolateBlocsInitialized({}),
    );

    expect(
      const IsolateBlocCreatedEvent(''),
      const IsolateBlocCreatedEvent(''),
    );

    expect(
      const CreateIsolateBlocEvent(Object, ''),
      const CreateIsolateBlocEvent(Object, ''),
    );

    expect(
      const IsolateBlocTransitionEvent('', ''),
      const IsolateBlocTransitionEvent('', ''),
    );
  });
}
