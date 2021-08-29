import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:weather_app/blocs/theme_cubit.dart';
import 'package:weather_app/blocs/weather_bloc.dart';
import 'package:weather_app/utils/theme_utils.dart';
import 'package:weather_app/widgets/widgets.dart';

class Weather extends StatefulWidget {
  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Completer<void>? _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Weather'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Settings(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final city = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CitySelection(),
                ),
              );
              if (city != null) {
                IsolateBlocProvider.of<WeatherBloc, WeatherState>(context)
                    .add(WeatherRequested(city: city));
              }
            },
          )
        ],
      ),
      body: Center(
        child: IsolateBlocListener<ThemeCubit, ThemeState>(
          listener: (context, state) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();
          },
          child: IsolateBlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoadInProgress) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is WeatherLoadSuccess) {
                final weather = state.weather;

                return IsolateBlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    return GradientContainer(
                      color: mapThemeStateToColor(themeState),
                      child: RefreshIndicator(
                        onRefresh: () {
                          IsolateBlocProvider.of<WeatherBloc, WeatherState>(
                                  context)
                              .add(
                            WeatherRefreshRequested(city: weather.location),
                          );
                          return _refreshCompleter!.future;
                        },
                        child: ListView(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: Location(location: weather.location),
                              ),
                            ),
                            Center(
                              child: LastUpdated(dateTime: weather.lastUpdated),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 50.0),
                              child: Center(
                                child: CombinedWeatherTemperature(
                                  weather: weather,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              if (state is WeatherLoadFailure) {
                return Text(
                  'Something went wrong!',
                  style: TextStyle(color: Colors.red),
                );
              }
              return Center(child: Text('Please Select a Location'));
            },
          ),
        ),
      ),
    );
  }
}
