import 'package:flutter/material.dart';
import 'package:weather_app/blocs/theme_bloc.dart';

Color mapThemeStateToColor(ThemeState state) {
  Color color;
  switch (state) {
    case ThemeState.clear:
      color = Colors.yellow;
      break;
    case ThemeState.snow:
      color = Colors.lightBlue;
      break;
    case ThemeState.cloud:
      color = Colors.grey;
      break;
    case ThemeState.rain:
      color = Colors.indigo;
      break;
    case ThemeState.thunderstorm:
      color = Colors.deepPurple;
      break;
    case ThemeState.initial:
      color = Colors.lightBlue;
      break;
  }
  return color;
}

ThemeData mapThemeStateToTheme(ThemeState state) {
  ThemeData theme;
  switch (state) {
    case ThemeState.clear:
      theme = ThemeData(
        primaryColor: Colors.orangeAccent,
      );
      break;
    case ThemeState.snow:
      theme = ThemeData(
        primaryColor: Colors.lightBlueAccent,
      );
      break;
    case ThemeState.cloud:
      theme = ThemeData(
        primaryColor: Colors.blueGrey,
      );
      break;
    case ThemeState.rain:
      theme = ThemeData(
        primaryColor: Colors.indigoAccent,
      );
      break;
    case ThemeState.thunderstorm:
      theme = ThemeData(
        primaryColor: Colors.deepPurpleAccent,
      );
      break;
    case ThemeState.initial:
      theme = ThemeData.light();
      break;
  }
  return theme;
}
