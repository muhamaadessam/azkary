import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final double fontSize;
  final bool hapticsEnabled;
  final bool isDarkMode;

  const SettingsState({
    required this.fontSize,
    required this.hapticsEnabled,
    required this.isDarkMode,
  });

  SettingsState copyWith({
    double? fontSize,
    bool? hapticsEnabled,
    bool? isDarkMode,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object> get props => [fontSize, hapticsEnabled, isDarkMode];
}
