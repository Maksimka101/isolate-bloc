import 'package:flutter/material.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:weather_app/blocs/settings_bloc.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: <Widget>[
          IsolateBlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return ListTile(
                title: Text(
                  'Temperature Units',
                ),
                isThreeLine: true,
                subtitle:
                    Text('Use metric measurements for temperature units.'),
                trailing: Switch(
                  value: state.temperatureUnits == TemperatureUnits.celsius,
                  onChanged: (_) =>
                      IsolateBlocProvider.of<SettingsBloc, SettingsState>(
                              context)
                          .add(TemperatureUnitsToggled()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
