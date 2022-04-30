import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:integration_tests/presentation/method_channel_scenario/method_channel_scenario_screen.dart';

class ScenariosListScreen extends StatelessWidget {
  const ScenariosListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scenarios List"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Method channel scenario"),
            onTap: () => _openScreen(
              context,
              const MethodChannelScenarioScreen(),
            ),
          )
        ],
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }
}
