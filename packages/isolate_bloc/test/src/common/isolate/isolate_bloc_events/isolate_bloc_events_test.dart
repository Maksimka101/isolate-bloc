// ignore_for_file: no-equal-arguments
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/src/common/isolate/isolate_bloc_events/isolate_bloc_events.dart';

void main() {
  test('Events creating', () {
    CloseIsolateBlocEvent('');

    IsolateBlocsInitialized({});

    IsolateBlocCreatedEvent('');

    CreateIsolateBlocEvent(Object, '');

    IsolateBlocTransitionEvent('', '');
  });

  test('test equality', () {
    expect(CloseIsolateBlocEvent(''), CloseIsolateBlocEvent(''));

    expect(IsolateBlocsInitialized({}), IsolateBlocsInitialized({}));

    expect(IsolateBlocCreatedEvent(''), IsolateBlocCreatedEvent(''));

    expect(CreateIsolateBlocEvent(Object, ''), CreateIsolateBlocEvent(Object, ''));

    expect(IsolateBlocTransitionEvent('', ''), IsolateBlocTransitionEvent('', ''));
  });
}
