import 'package:azkary/features/azkar/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/notification_service.dart';
import 'features/settings/presentation/controllers/settings_cubit.dart';
import 'features/settings/presentation/controllers/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationService = NotificationService();
  await notificationService.init();
  
  // Schedule morning azkar at 7:00 AM
  await notificationService.scheduleDailyNotification(
    id: 1,
    title: 'أذكار الصباح',
    body: 'حان الآن موعد أذكار الصباح، ابدأ يومك بذكر الله.',
    hour: 7,
    minute: 0,
  );
  
  // Schedule evening azkar at 5:00 PM (17:00)
  await notificationService.scheduleDailyNotification(
    id: 2,
    title: 'أذكار المساء',
    body: 'حان الآن موعد أذكار المساء، اختم يومك بسكينة.',
    hour: 17,
    minute: 0,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'أذكاري',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    // Light Theme Colors
    final primaryLight = const Color(0xFF0F6B55);
    final secondaryLight = const Color(0xFFC08A28);
    final backgroundLight = const Color(0xFFF4EFE2);
    final surfaceLight = const Color(0xFFFFFBF0);
    final textLight = const Color(0xFF173F35);
    final textSecondaryLight = const Color(0xFF5A6B62);
    
    // Dark Theme Colors
    final primaryDark = const Color(0xFF1B493C); 
    final secondaryDark = const Color(0xFFD4A373); 
    final backgroundDark = const Color(0xFF121212);
    final surfaceDark = const Color(0xFF1E1E1E);
    final textDark = const Color(0xFFE0E0E0);
    final textSecondaryDark = const Color(0xFFAAAAAA);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Traditional',
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? backgroundDark : backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: isDark ? primaryDark : primaryLight,
        primary: isDark ? primaryDark : primaryLight,
        secondary: isDark ? secondaryDark : secondaryLight,
        surface: isDark ? surfaceDark : surfaceLight,
        onSurface: isDark ? textDark : textLight,
        onSurfaceVariant: isDark ? textSecondaryDark : textSecondaryLight,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? surfaceDark : primaryLight,
        foregroundColor: isDark ? Colors.white : surfaceLight,
        titleTextStyle: TextStyle(
          fontFamily: 'Traditional',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : surfaceLight,
        ),
      ),
    );
  }
}
