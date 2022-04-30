import 'package:flutter/material.dart';
import 'package:integration_tests/isolate_initialization.dart';
import 'package:integration_tests/presentation/scenarios_list_screen.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

Future<void> main() async {
  await initialize(isolateInitialization);

  runApp(
    const MaterialApp(
      home: ScenariosListScreen(),
    ),
  );
}
