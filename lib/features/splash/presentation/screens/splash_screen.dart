import 'dart:async';

import 'package:flutter/material.dart';

import '../../../azkar/presentation/screens/home_screen.dart';

// THESIS: a quiet emerald opening that feels like opening a small, cherished mushaf.
// OWN-WORLD: emerald field, warm gold mark, ivory type, restrained ornament.
// STORY: the logo settles, then the user enters their daily ورد without delay.
// FIRST VIEWPORT: centered mark, name, and one calm supporting line.
// FORM: short native-feeling reveal with one scale/fade moment, no loading chrome.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _exitTimer = Timer(const Duration(milliseconds: 1750), _openHome);
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F6B55),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _Glow(size: 280, color: const Color(0x33C08A28)),
          ),
          Positioned(
            bottom: -160,
            left: -100,
            child: _Glow(size: 360, color: const Color(0x221B493C)),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 218,
                      height: 218,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFC08A28),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 28,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_icon_foreground.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'أذكاري',
                      style: TextStyle(
                        color: Color(0xFFFFFBF0),
                        fontFamily: 'Traditional',
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'وردك اليومي بهدوء',
                      style: TextStyle(
                        color: const Color(0xFFFFFBF0).withValues(alpha: 0.72),
                        fontFamily: 'Traditional',
                        fontSize: 19,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.45,
              spreadRadius: size * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}
