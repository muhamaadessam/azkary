import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/azkar_entity.dart';
import '../../../settings/presentation/controllers/settings_cubit.dart';

class ZekrWidget extends StatefulWidget {
  const ZekrWidget({super.key, required this.azkar, this.onTap});

  final AzkarEntity azkar;
  final void Function()? onTap;

  @override
  State<ZekrWidget> createState() => _ZekrWidgetState();
}

class _ZekrWidgetState extends State<ZekrWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final haptics = context.read<SettingsCubit>().state.hapticsEnabled;
    if (haptics) {
      HapticFeedback.lightImpact();
    }
    _controller.forward().then((_) {
      _controller.reverse();
    });
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isQuran = widget.azkar.isQuran;

    return Column(
      children: [
        // Main Scrollable Zekr Content Card (Full Height & Full Width)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Stack(
                  children: [
                    // Background Card Preview (Stack Deck Effect)
                    Positioned.fill(
                      child: Transform.translate(
                        offset: const Offset(0, 10),
                        child: Transform.scale(
                          scaleX: 0.94,
                          scaleY: 0.98,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Active Zekr Content Card (Full Width & Full Height)
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                            minWidth: constraints.maxWidth,
                          ),
                          child: Material(
                            color: theme.colorScheme.surface,
                            elevation: isQuran ? 8 : 4,
                            shadowColor: isQuran
                                ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                                : const Color(0x220F3D34),
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: double.infinity,
                              decoration: isQuran
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.surface,
                                          theme.colorScheme.secondary.withValues(alpha: 0.04),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    )
                                  : null,
                              child: InkWell(
                                onTap: _handleTap,
                                borderRadius: BorderRadius.circular(22),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      if (isQuran) ...[
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.menu_book_rounded,
                                                  color: theme.colorScheme.secondary,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  widget.azkar.surah ?? 'آية قرآنية',
                                                  style: TextStyle(
                                                    color: theme.colorScheme.secondary,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ] else ...[
                                        Icon(
                                          Icons.auto_awesome,
                                          color: theme.colorScheme.secondary,
                                          size: 30,
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      ZekrText(
                                        text: widget.azkar.zekr,
                                        isQuran: isQuran,
                                      ),
                                      if (widget.azkar.bless.isNotEmpty) ...[
                                        const SizedBox(height: 24),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                            ),
                                          ),
                                          child: Text(
                                            widget.azkar.bless,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontSize: 18,
                                              height: 1.45,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Fixed Bottom Tasbeeh Counter Bar (Thumb Accessible, Pinned at Bottom of Screen)
        Material(
          elevation: 12,
          color: theme.colorScheme.surface,
          shadowColor: Colors.black38,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: InkWell(
              onTap: _handleTap,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Label & Instructions
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.touch_app_rounded,
                              color: theme.colorScheme.secondary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'اضغط للتسبيح',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'المس بأي مكان للتكرار',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Fixed Animated Thumb Counter Button
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 72,
                              height: 72,
                              child: CircularProgressIndicator(
                                value: widget.azkar.counter == 0
                                    ? 1.0
                                    : widget.azkar.repeat / widget.azkar.counter,
                                strokeWidth: 5,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${widget.azkar.repeat}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'من ${widget.azkar.counter}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

@visibleForTesting
class ZekrText extends StatelessWidget {
  const ZekrText({
    super.key,
    required this.text,
    this.isQuran = false,
  });

  final String text;
  final bool isQuran;

  static const _basmala = 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم';
  static const _istiadha = 'أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSize = context.watch<SettingsCubit>().state.fontSize;
    var cleaned = text.trim();

    bool hasIstiadha = false;
    if (cleaned.contains('أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ') ||
        cleaned.contains('أعوذ بالله من الشيطان الرجيم')) {
      hasIstiadha = true;
      cleaned = cleaned
          .replaceFirst('أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ', '')
          .replaceFirst('أعوذ بالله من الشيطان الرجيم', '')
          .trim();
    }

    // Extract trailing reference if present (e.g. -آية الكرسي,البقرة ,255. or [البقرة 285 - 286].)
    String? referenceText;
    final refRegExp = RegExp(r'(-آية الكرسي.*|\s*\[البقرة.*\]\s*)$');
    final match = refRegExp.firstMatch(cleaned);
    if (match != null) {
      referenceText = match.group(0)?.replaceAll(RegExp(r'^[-\s]+|[.\s]+$'), '');
      cleaned = cleaned.substring(0, match.start).trim();
    }

    // Strip wrapping single quotes from verse text if present
    if (cleaned.startsWith("'") && cleaned.endsWith("'")) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    }

    final hasBasmala = cleaned.startsWith(_basmala);
    final body = hasBasmala
        ? cleaned.substring(_basmala.length).trim()
        : cleaned;

    final verses = _numberedVerses(body);

    // If Quranic and doesn't have verse numbers, wrap body in ﴿ ﴾
    final formattedBody = (isQuran && verses == null && !body.startsWith('﴿'))
        ? '﴿ $body ﴾'
        : body;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIstiadha) ...[
          Text(
            _istiadha,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: fontSize * 0.85,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (hasBasmala) ...[
          Text(
            _basmala,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontSize: fontSize,
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
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: fontSize,
              height: 1.7,
              fontWeight: FontWeight.w700,
            ),
            children: verses == null
                ? [TextSpan(text: formattedBody)]
                : [
                    if (isQuran) const TextSpan(text: '﴿ '),
                    for (var i = 0; i < verses.length; i++) ...[
                      TextSpan(text: verses[i].text),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: _VerseNumber(number: verses[i].number),
                      ),
                      if (i < verses.length - 1) const TextSpan(text: ' '),
                    ],
                    if (isQuran) const TextSpan(text: ' ﴾'),
                  ],
          ),
        ),
        if (referenceText != null && referenceText.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            referenceText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontSize: fontSize * 0.75,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  static List<_Verse>? _numberedVerses(String text) {
    final (count, startVerseNumber) = switch (text) {
      String s when s.startsWith('قُلْ هُوَ ٱللَّهُ أَحَدٌ') => (4, 1),
      String s when s.startsWith('قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ') => (5, 1),
      String s when s.startsWith('قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ') => (6, 1),
      String s when s.startsWith('آمَنَ الرَّسُولُ') => (2, 285),
      String s when s.startsWith('الله لا إلـه') || s.startsWith('اللَّهُ لَا إِلَٰهَ') => (1, 255),
      _ => (0, 0),
    };
    if (count == 0) return null;

    if (startVerseNumber == 255) {
      return [_Verse(text.trim(), 255)];
    }

    final parts = text.split('،');
    if (parts.length < count) return null;

    return parts.take(count).indexed.map((entry) {
      final number = entry.$1 + startVerseNumber;
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
        painter: _VerseSealPainter(
          surfaceColor: Theme.of(context).colorScheme.surface,
          secondaryColor: Theme.of(context).colorScheme.secondary,
        ),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: Text(
              _arabicNumber(number),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
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
  _VerseSealPainter({required this.surfaceColor, required this.secondaryColor});

  final Color surfaceColor;
  final Color secondaryColor;

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
        ..color = surfaceColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      seal,
      Paint()
        ..color = secondaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      center,
      size.width * .28,
      Paint()
        ..color = secondaryColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
