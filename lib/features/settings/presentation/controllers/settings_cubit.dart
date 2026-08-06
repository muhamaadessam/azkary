import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        const SettingsState(
          fontSize: 25.0,
          hapticsEnabled: true,
          isDarkMode: false,
          periodicAzkarEnabled: true,
          periodicAzkarInterval: 30,
        ),
      ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble('fontSize') ?? 25.0;
    final hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final periodicAzkarEnabled = prefs.getBool('periodicAzkarEnabled') ?? true;
    final periodicAzkarInterval = prefs.getInt('periodicAzkarInterval') ?? 30;
    final autoPlayAudio = prefs.getBool('autoPlayAudio') ?? false;

    emit(
      SettingsState(
        fontSize: fontSize,
        hapticsEnabled: hapticsEnabled,
        isDarkMode: isDarkMode,
        periodicAzkarEnabled: periodicAzkarEnabled,
        periodicAzkarInterval: periodicAzkarInterval,
        autoPlayAudio: autoPlayAudio,
      ),
    );

    await CapsuleService().schedulePeriodicCapsule(
      enabled: periodicAzkarEnabled,
      intervalMinutes: periodicAzkarInterval,
    );
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

  Future<void> toggleAutoPlayAudio(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoPlayAudio', enabled);
    emit(state.copyWith(autoPlayAudio: enabled));
  }

  Future<void> togglePeriodicAzkar(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('periodicAzkarEnabled', enabled);
    emit(state.copyWith(periodicAzkarEnabled: enabled));

    await CapsuleService().schedulePeriodicCapsule(
      enabled: enabled,
      intervalMinutes: state.periodicAzkarInterval,
    );
  }

  Future<void> updatePeriodicAzkarInterval(int intervalMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('periodicAzkarInterval', intervalMinutes);
    emit(state.copyWith(periodicAzkarInterval: intervalMinutes));

    if (state.periodicAzkarEnabled) {
      await CapsuleService().schedulePeriodicCapsule(
        enabled: true,
        intervalMinutes: intervalMinutes,
      );
    }
  }
}
