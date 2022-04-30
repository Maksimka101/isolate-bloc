import 'package:flutter/material.dart';
import 'package:integration_tests/application/method_channel_scenario/method_channel_bloc.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

class MethodChannelScenarioScreen extends StatefulWidget {
  const MethodChannelScenarioScreen({Key? key}) : super(key: key);

  @override
  State<MethodChannelScenarioScreen> createState() =>
      _MethodChannelScenarioScreenState();
}

class _MethodChannelScenarioScreenState
    extends State<MethodChannelScenarioScreen> {
  @override
  Widget build(BuildContext context) {
    return IsolateBlocProvider<MethodChannelBloc, MethodChannelState>(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Method Channel Scenario"),
        ),
        body: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                IsolateBlocBuilder<MethodChannelBloc, MethodChannelState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => const Text("Nothing is loaded"),
                      error: (message) => Text(message),
                      assetLoaded: (assetData) {
                        return Column(
                          children: [
                            const Text("Asset is loaded!"),
                            Text(assetData),
                          ],
                        );
                      },
                    );
                  },
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () => context
                        .isolateBloc<MethodChannelBloc, MethodChannelState>()
                        .add(
                          const MethodChannelEvent.loadAsset(
                            name: 'assets/test_text_asset.txt',
                          ),
                        ),
                    child: const Text("Load text asset"),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
