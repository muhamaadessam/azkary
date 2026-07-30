import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/azkar_entity.dart';

class ZekrWidget extends StatelessWidget {
  const ZekrWidget({super.key, required this.azkar, this.onTap});

  final AzkarEntity azkar;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 10,
        shadowColor: const Color(0x330F3D34),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.secondary,
                  size: 28,
                ),
                const SizedBox(height: 12),
                ZekrText(text: azkar.zekr),
                if (azkar.bless.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    azkar.bless,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF5A6B62),
                      fontSize: 20,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.secondary,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330F3D34),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${azkar.repeat}/${azkar.counter}',
                      style: const TextStyle(
                        color: Color(0xFFFFFBF0),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'اضغط للتسبيح',
                  style: TextStyle(color: Color(0xFF5A6B62), fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class ZekrText extends StatelessWidget {
  const ZekrText({super.key, required this.text});

  final String text;

  static const _basmala = 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم';

  @override
  Widget build(BuildContext context) {
    final cleaned = text.trim();
    final body = cleaned.startsWith(_basmala)
        ? cleaned.substring(_basmala.length).trim()
        : cleaned;
    final verses = _numberedVerses(body);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (body != cleaned) ...[
          const Text(
            _basmala,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFC08A28),
              fontSize: 25,
              height: 1.7,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        RichText(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFF173F35),
              fontFamily: 'Traditional',
              fontSize: 28,
              height: 1.7,
              fontWeight: FontWeight.w700,
            ),
            children: verses == null
                ? [TextSpan(text: body)]
                : [
                    for (final verse in verses) ...[
                      TextSpan(text: verse.text),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: _VerseNumber(number: verse.number),
                      ),
                      const TextSpan(text: ' '),
                    ],
                  ],
          ),
        ),
      ],
    );
  }

  static List<_Verse>? _numberedVerses(String text) {
    final count = switch (text) {
      String s when s.startsWith('قُلْ هُوَ ٱللَّهُ أَحَدٌ') => 4,
      String s when s.startsWith('قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ') => 5,
      String s when s.startsWith('قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ') => 6,
      _ => 0,
    };
    if (count == 0) return null;

    return text.split('،').take(count).indexed.map((entry) {
      final number = entry.$1 + 1;
      final verse = entry.$2.trim().replaceFirst(RegExp(r'[.]$'), '');
      return _Verse(verse, number);
    }).toList();
  }
}

class _Verse {
  const _Verse(this.text, this.number);

  final String text;
  final int number;
}

class _VerseNumber extends StatelessWidget {
  const _VerseNumber({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CustomPaint(
        painter: _VerseSealPainter(),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: Text(
              _arabicNumber(number),
              style: const TextStyle(
                color: Color(0xFF0F6B55),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _arabicNumber(int value) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return value.toString().split('').map((digit) {
      return digits[int.parse(digit)];
    }).join();
  }
}

class _VerseSealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final points = <Offset>[];

    for (var i = 0; i < 16; i++) {
      final radius = i.isEven ? size.width * .48 : size.width * .36;
      final angle = -1.5708 + i * 0.3927;
      points.add(
        center + Offset(radius * math.cos(angle), radius * math.sin(angle)),
      );
    }

    final seal = Path()..addPolygon(points, true);
    canvas.drawPath(
      seal,
      Paint()
        ..color = const Color(0xFFFFF7DD)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      seal,
      Paint()
        ..color = const Color(0xFFC08A28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      center,
      size.width * .28,
      Paint()
        ..color = const Color(0x33C08A28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
