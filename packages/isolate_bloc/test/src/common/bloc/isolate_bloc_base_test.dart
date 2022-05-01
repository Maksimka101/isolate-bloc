import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../blocs/emitted_cubit.dart';
import '../../../blocs/error_cubit.dart';
import '../../../mock/mock_isolate_bloc_observer.dart';
import '../../../test_utils/initialize.dart';

void main() {
  setUp(() async {
    testInitializePlatform(TestInitializePlatform.web);

    await testInitialize(() {
      register<ErrorCubit, dynamic>(create: ErrorCubit.new);
      register<EmittedCubit, dynamic>(create: EmittedCubit.new);
    });

    registerFallbackValue(ErrorCubit());
    registerFallbackValue(StackTrace.empty);
  });

  test(
    "Uncaught error in bloc triggers 'onError' in 'IsolateBlocObserver' "
    "and throws 'BlocUnhandledErrorException'",
    () async {
      final mockIsolateBlocObserver = MockIsolateBlocObserver();
      await runZonedGuarded(
        () async {
          await testInitialize(() {
            IsolateBloc.observer = mockIsolateBlocObserver;
            register<ErrorCubit, dynamic>(create: ErrorCubit.new);
          });

          final errorBloc = createBloc<ErrorCubit, dynamic>();
          errorBloc.add("event");
        },
        (error, stack) {
          expect(error, isA<BlocUnhandledErrorException>());
          error.toString();
          verify(
            // ignore: invalid_use_of_protected_member
            () => mockIsolateBlocObserver.onError(
              any(that: isA<ErrorCubit>()),
              any(that: isA<ExpectedException>()),
              any(),
            ),
          ).called(1);
        },
      );
    },
  );

  test("IsolateBlocBase.emitted is changed on emit", () {
    final cubit = createBloc<EmittedCubit, dynamic>();
    cubit.add("event");
  });
}
