import 'package:flutter/material.dart';

class IslamicBackground extends StatelessWidget {
  const IslamicBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.08, // Very subtle opacity
            child: Image.asset(
              'assets/images/islamic_bg.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF4EFE2).withValues(alpha: 0.8), // App background color with opacity
                  const Color(0xFFF4EFE2).withValues(alpha: 0.4),
                  const Color(0xFFF4EFE2).withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}
