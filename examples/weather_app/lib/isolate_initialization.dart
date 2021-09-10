import 'package:http/http.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:weather_app/blocs/settings_cubit.dart';
import 'package:weather_app/blocs/theme_cubit.dart';
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

  register<WeatherBloc, WeatherState>(create: () => WeatherBloc(weatherRepository: weatherRepository));
  register<SettingsCubit, SettingsState>(create: () => SettingsCubit());
  register<ThemeCubit, ThemeState>(
    create: () => ThemeCubit(
      weatherBloc: getBloc<WeatherBloc, WeatherState>(),
    ),
  );
}
