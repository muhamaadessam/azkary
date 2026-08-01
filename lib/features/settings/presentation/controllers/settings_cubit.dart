import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(const SettingsState(
          fontSize: 25.0,
          hapticsEnabled: true,
          isDarkMode: false,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble('fontSize') ?? 25.0;
    final hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;

    emit(SettingsState(
      fontSize: fontSize,
      hapticsEnabled: hapticsEnabled,
      isDarkMode: isDarkMode,
    ));
  }

  Future<void> updateFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
    emit(state.copyWith(fontSize: size));
  }

  Future<void> toggleHaptics(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticsEnabled', enabled);
    emit(state.copyWith(hapticsEnabled: enabled));
  }

  Future<void> toggleDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }
}
