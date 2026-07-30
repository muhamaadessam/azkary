import 'package:azkary/features/azkar/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أذكاري',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Traditional',
        scaffoldBackgroundColor: const Color(0xFFF4EFE2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F6B55),
          primary: const Color(0xFF0F6B55),
          secondary: const Color(0xFFC08A28),
          surface: const Color(0xFFFFFBF0),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF0F6B55),
          foregroundColor: Color(0xFFFFFBF0),
          titleTextStyle: TextStyle(
            fontFamily: 'Traditional',
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
