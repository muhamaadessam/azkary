import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final double fontSize;
  final bool hapticsEnabled;
  final bool isDarkMode;
  final bool periodicAzkarEnabled;
  final int periodicAzkarInterval;
  final bool autoPlayAudio;

  const SettingsState({
    required this.fontSize,
    required this.hapticsEnabled,
    required this.isDarkMode,
    this.periodicAzkarEnabled = true,
    this.periodicAzkarInterval = 30,
    this.autoPlayAudio = false,
  });

  SettingsState copyWith({
    double? fontSize,
    bool? hapticsEnabled,
    bool? isDarkMode,
    bool? periodicAzkarEnabled,
    int? periodicAzkarInterval,
    bool? autoPlayAudio,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      periodicAzkarEnabled: periodicAzkarEnabled ?? this.periodicAzkarEnabled,
      periodicAzkarInterval:
          periodicAzkarInterval ?? this.periodicAzkarInterval,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
    );
  }

  @override
  List<Object> get props => [
    fontSize,
    hapticsEnabled,
    isDarkMode,
    periodicAzkarEnabled,
    periodicAzkarInterval,
    autoPlayAudio,
  ];
}
