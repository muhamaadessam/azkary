import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayZekrWidget extends StatefulWidget {
  const OverlayZekrWidget({super.key});

  @override
  State<OverlayZekrWidget> createState() => _OverlayZekrWidgetState();
}

class _OverlayZekrWidgetState extends State<OverlayZekrWidget> {
  String _zekrText = 'صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ';
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _initData();
    _dismissTimer = Timer(const Duration(seconds: 15), () {
      FlutterOverlayWindow.closeOverlay();
    });
  }

  void _initData() {
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data != null && data is String && data.isNotEmpty) {
        setState(() {
          _zekrText = data;
        });
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              margin: const EdgeInsets.only(right: 16, left: 32),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF0),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFC08A28), width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x45000000),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _zekrText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Traditional',
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F6B55),
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
