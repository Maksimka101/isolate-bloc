import 'package:flutter/material.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:weather_app/blocs/settings_bloc.dart';
import 'package:weather_app/blocs/theme_bloc.dart';
import 'package:weather_app/blocs/weather_bloc.dart';
import 'package:weather_app/utils/theme_utils.dart';

import 'isolate_initialization.dart';
import 'widgets/weather.dart';

Future<void> runWeatherApp() async {
  await initialize(isolateInitialization);
  runApp(
    MultiIsolateBlocProvider(
      providers: [
        IsolateBlocProvider<ThemeBloc, ThemeState>(),
        IsolateBlocProvider<SettingsBloc, SettingsState>(),
        IsolateBlocProvider<WeatherBloc, WeatherState>(),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IsolateBlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Flutter weather',
          theme: mapThemeStateToTheme(themeState),
          home: Weather(),
        );
      },
    );
  }
}
