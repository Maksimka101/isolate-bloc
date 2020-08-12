import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

class SettingsBloc extends IsolateBloc<SettingsEvent, SettingsState> {
  SettingsBloc()
      : super(SettingsState(temperatureUnits: TemperatureUnits.celsius));

  @override
  void onEventReceived(SettingsEvent event) {
    if (event is TemperatureUnitsToggled) {
      emit(
        SettingsState(
          temperatureUnits: state.temperatureUnits == TemperatureUnits.celsius
              ? TemperatureUnits.fahrenheit
              : TemperatureUnits.celsius,
        ),
      );
    }
  }
}

abstract class SettingsEvent extends Equatable {}

class TemperatureUnitsToggled extends SettingsEvent {
  @override
  List<Object> get props => [];
}

enum TemperatureUnits { fahrenheit, celsius }

class SettingsState extends Equatable {
  final TemperatureUnits temperatureUnits;

  const SettingsState({@required this.temperatureUnits})
      : assert(temperatureUnits != null);

  @override
  List<Object> get props => [temperatureUnits];
}
