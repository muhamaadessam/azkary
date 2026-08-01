import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/azkar_entity.dart';
import '../../../settings/presentation/controllers/settings_cubit.dart';
import 'zekr_widget.dart';

class AzkarVerticalSlider extends StatefulWidget {
  const AzkarVerticalSlider({
    super.key,
    required this.azkarList,
    required this.onTapCounter,
    required this.totalAzkarCount,
  });

  final List<AzkarEntity> azkarList;
  final void Function(AzkarEntity azkar) onTapCounter;
  final int totalAzkarCount;

  @override
  State<AzkarVerticalSlider> createState() => _AzkarVerticalSliderState();
}

class _AzkarVerticalSliderState extends State<AzkarVerticalSlider>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _pageController.addListener(_onScroll);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  void _onScroll() {
    if (_pageController.hasClients) {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  int get _activeCurrentIndex {
    return _currentPage.round().clamp(0, widget.azkarList.isEmpty ? 0 : widget.azkarList.length - 1);
  }

  void _handleTapActiveItem() {
    if (widget.azkarList.isEmpty) return;
    final index = _activeCurrentIndex;
    final activeAzkar = widget.azkarList[index];

    final haptics = context.read<SettingsCubit>().state.hapticsEnabled;
    if (haptics) {
      HapticFeedback.lightImpact();
    }

    _animController.forward().then((_) {
      _animController.reverse();
    });

    widget.onTapCounter(activeAzkar);

    // If this tap will complete the repeat count (meaning repeat is now 1 before tap)
    if (activeAzkar.repeat == 1 && index < widget.azkarList.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _pageController.hasClients) {
          _pageController.animateToPage(
            index + 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.totalAzkarCount;
    final activeIndex = _activeCurrentIndex;
    final activeAzkar = widget.azkarList.isNotEmpty ? widget.azkarList[activeIndex] : null;

    final completedCount = widget.azkarList.where((e) => e.repeat == 0).length;

    return Column(
      children: [
        // Top Progress Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Row(
            children: [
              Text(
                'الذكر ${activeIndex + 1} من $total',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : (completedCount / total),
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Vertical Card Slider Carousel
        Expanded(
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.azkarList.length,
            itemBuilder: (context, index) {
              final azkar = widget.azkarList[index];
              final difference = (index - _currentPage);
              final scale = (1.0 - (difference.abs() * 0.12)).clamp(0.85, 1.0);
              final opacity = (1.0 - (difference.abs() * 0.55)).clamp(0.35, 1.0);

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: index == activeIndex
                              ? (azkar.isQuran
                                  ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                                  : const Color(0x220F3D34))
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: index == activeIndex ? 12 : 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: azkar.isQuran
                            ? theme.colorScheme.secondary.withValues(alpha: 0.5)
                            : theme.colorScheme.primary.withValues(alpha: 0.1),
                        width: azkar.isQuran ? 1.5 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: _handleTapActiveItem,
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (azkar.isQuran) ...[
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                azkar.surah ?? 'آية قرآنية',
                                                style: TextStyle(
                                                  color: theme.colorScheme.secondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ] else ...[
                                      Icon(
                                        Icons.auto_awesome,
                                        color: theme.colorScheme.secondary,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: ZekrText(
                                        text: azkar.zekr,
                                        isQuran: azkar.isQuran,
                                      ),
                                    ),
                                    if (azkar.bless.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                          ),
                                        ),
                                        child: Text(
                                          azkar.bless,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ] else
                                      const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Fixed Bottom Tasbeeh Action Panel (Thumb Accessible)
        if (activeAzkar != null)
          Material(
            elevation: 12,
            color: theme.colorScheme.surface,
            shadowColor: Colors.black38,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: InkWell(
                onTap: _handleTapActiveItem,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Label & Instructions
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.touch_app_rounded,
                                color: theme.colorScheme.secondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'اضغط للتسبيح',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'المس بأي مكان للتكرار',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
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
                                width: 68,
                                height: 68,
                                child: CircularProgressIndicator(
                                  value: activeAzkar.counter == 0
                                      ? 1.0
                                      : activeAzkar.repeat / activeAzkar.counter,
                                  strokeWidth: 5,
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Container(
                                width: 56,
                                height: 56,
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
                                      '${activeAzkar.repeat}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      'من ${activeAzkar.counter}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 10,
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
