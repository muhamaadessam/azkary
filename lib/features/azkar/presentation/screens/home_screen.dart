import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/azkar_cubit.dart';
import '../widgets/islamic_background.dart';
import 'azkar_massa_screen.dart';
import 'azkar_sabah_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('أذكاري')),
        body: IslamicBackground(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 18),
                const Text(
                  'اذكر الله بقلب حاضر',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF173F35),
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اختر وردك وابدأ العد بهدوء',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF5A6B62), fontSize: 21),
                ),
                const SizedBox(height: 28),
                _AzkarHomeCard(
                  title: 'أذكار الصباح',
                  subtitle: 'بداية مطمئنة لليوم',
                  icon: Icons.wb_sunny_outlined,
                  onTap: () => _open(context, const AzkarSabahScreen()),
                ),
                const SizedBox(height: 16),
                _AzkarHomeCard(
                  title: 'أذكار المساء',
                  subtitle: 'سكينة قبل ختام اليوم',
                  icon: Icons.nightlight_outlined,
                  onTap: () => _open(context, const AzkarMassaScreen()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BlocProvider(create: (context) => AzkarCubit(), child: screen),
      ),
    );
  }
}

class _AzkarHomeCard extends StatelessWidget {
  const _AzkarHomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      shadowColor: const Color(0x260F3D34),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.secondary),
                ),
                child: Icon(icon, color: const Color(0xFFFFFBF0), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF173F35),
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF5A6B62),
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: theme.colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
