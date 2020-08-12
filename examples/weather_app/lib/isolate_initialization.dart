import 'package:http/http.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:weather_app/blocs/settings_bloc.dart';
import 'package:weather_app/blocs/theme_bloc.dart';
import 'package:weather_app/blocs/weather_bloc.dart';
import 'package:weather_app/repositories/repositories.dart';

import 'blocs/bloc_observer.dart';

void isolateInitialization() {
  IsolateBloc.observer = SimpleBlocObserver();
  var weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(
      httpClient: Client(),
    ),
  );

  register(create: () => WeatherBloc(weatherRepository: weatherRepository));
  register(create: () => SettingsBloc());
  register(create: () => ThemeBloc(weatherBlocInjector: getBloc));
}
