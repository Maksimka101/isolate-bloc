import 'package:equatable/equatable.dart';
import 'package:isolate_bloc/isolate_bloc.dart';

class SettingsCubit extends IsolateCubit<SettingsEvent, SettingsState> {
  SettingsCubit()
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

class SettingsState extends Equatable {
  final TemperatureUnits temperatureUnits;

  const SettingsState({required this.temperatureUnits});

  @override
  List<Object> get props => [temperatureUnits];
}

enum TemperatureUnits { fahrenheit, celsius }

class TemperatureUnitsToggled extends SettingsEvent {
  @override
  List<Object> get props => [];
}
