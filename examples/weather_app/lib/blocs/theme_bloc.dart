import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:weather_app/blocs/weather_bloc.dart';
import 'package:weather_app/models/models.dart';

class ThemeBloc extends IsolateBloc<WeatherState, ThemeState> {
  final IsolateBlocWrapper<WeatherState> weatherBloc;
  late StreamSubscription<WeatherState> _weatherStateSubscription;

  ThemeBloc({
    required this.weatherBloc,
  }) : super(ThemeState.initial) {
    _weatherStateSubscription = weatherBloc.stream.listen(onEventReceived);
  }

  @override
  void onEventReceived(WeatherState event) {
    if (event is WeatherInitial) {
      emit(ThemeState.initial);
    } else if (event is WeatherLoadInProgress) {
      emit(ThemeState.initial);
    } else if (event is WeatherLoadFailure) {
      emit(ThemeState.initial);
    } else if (event is WeatherLoadSuccess) {
      emit(_mapWeatherCondition(event.weather.condition));
    }
  }

  ThemeState _mapWeatherCondition(WeatherCondition? condition) {
    ThemeState state;
    switch (condition) {
      case WeatherCondition.clear:
      case WeatherCondition.lightCloud:
        state = ThemeState.clear;
        break;
      case WeatherCondition.hail:
      case WeatherCondition.snow:
      case WeatherCondition.sleet:
        state = ThemeState.snow;
        break;
      case WeatherCondition.heavyCloud:
        state = ThemeState.cloud;
        break;
      case WeatherCondition.heavyRain:
      case WeatherCondition.lightRain:
      case WeatherCondition.showers:
        state = ThemeState.rain;
        break;
      case WeatherCondition.thunderstorm:
        state = ThemeState.thunderstorm;
        break;
      case WeatherCondition.unknown:
      case null:
        state = ThemeState.initial;
        break;
    }
    return state;
  }

  @override
  Future<void> close() {
    _weatherStateSubscription?.cancel();
    return super.close();
  }
}

enum ThemeState {
  clear,
  snow,
  cloud,
  rain,
  thunderstorm,
  initial,
}
