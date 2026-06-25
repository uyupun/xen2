import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'katsu_settings_provider.g.dart';

class KatsuSettingsState {
  final bool pavlokEnabled;
  final int stimulusValue;
  final bool vibrationEnabled;

  const KatsuSettingsState({
    this.pavlokEnabled = true,
    this.stimulusValue = 40,
    this.vibrationEnabled = true,
  });

  KatsuSettingsState copyWith({
    bool? pavlokEnabled,
    int? stimulusValue,
    bool? vibrationEnabled,
  }) {
    return KatsuSettingsState(
      pavlokEnabled: pavlokEnabled ?? this.pavlokEnabled,
      stimulusValue: stimulusValue ?? this.stimulusValue,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

@Riverpod(keepAlive: true)
class KatsuSettings extends _$KatsuSettings {
  @override
  KatsuSettingsState build() => const KatsuSettingsState();

  void setPavlokEnabled(bool value) =>
      state = state.copyWith(pavlokEnabled: value);

  void setStimulusValue(int value) =>
      state = state.copyWith(stimulusValue: value);

  void setVibrationEnabled(bool value) =>
      state = state.copyWith(vibrationEnabled: value);
}
