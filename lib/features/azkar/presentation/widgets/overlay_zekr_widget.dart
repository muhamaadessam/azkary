import 'dart:async';
// import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import '../../../../core/data/capsule_azkar.dart';

class OverlayZekrWidget extends StatefulWidget {
  const OverlayZekrWidget({super.key});

  @override
  State<OverlayZekrWidget> createState() => _OverlayZekrWidgetState();
}

class _OverlayZekrWidgetState extends State<OverlayZekrWidget> {
  String _zekrText = CapsuleAzkar.random();
  Timer? _dismissTimer;
  StreamSubscription<dynamic>? _overlaySubscription;

  @override
  void initState() {
    super.initState();
    _initData();
    _dismissTimer = Timer(const Duration(seconds: 15), () {
      FlutterOverlayWindow.closeOverlay();
    });
  }

  void _initData() {
    try {
      _overlaySubscription = FlutterOverlayWindow.overlayListener.listen((
        data,
      ) {
        if (data is String && data.isNotEmpty && mounted) {
          setState(() {
            _zekrText = data == CapsuleAzkar.randomToken
                ? CapsuleAzkar.random()
                : data;
          });
        }
      });
    } catch (_) {
      // Ignore if stream has already been listened to (single-subscription)
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _overlaySubscription?.cancel();
    super.dispose();
  }

  double _getFontSize(String text) {
    if (text.length > 130) return 16.0;
    if (text.length > 80) return 18.0;
    if (text.length > 40) return 19.5;
    return 21.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth * 0.80;
    // final maxWidth = math.min(screenWidth * 0.85, 300.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              FlutterOverlayWindow.closeOverlay();
            },
            child: Container(
              margin: const EdgeInsets.only(
                right: 16,
                left: 28,
                top: 14,
                bottom: 14,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF0),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFC08A28), width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x220F3D34),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0x18000000),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _zekrText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Traditional',
                  fontSize: _getFontSize(_zekrText),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F6B55),
                  height: 1.55,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
