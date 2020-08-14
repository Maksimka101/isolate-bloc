import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc_test/src/mock_initialize.dart';

import 'initializers.dart';

void main() {
  group('Simple tests', () {
    test('Test initializeMock function', () async {
      try {
        await initializeMock(Initializers.empty);
        expect(true, true);
      } catch (e) {
        expect(false, true, reason: 'Error while initialization');
      }
    });
  });
}
