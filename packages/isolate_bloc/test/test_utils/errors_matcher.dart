import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

T? expectError<T>(T Function() errorAction, Matcher errorMatcher) {
  return runZonedGuarded(
    errorAction,
    (error, stack) {
      expect(error, errorMatcher);
    },
  );
}
