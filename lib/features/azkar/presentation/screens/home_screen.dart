import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/azkar_audio_catalog.dart';
import '../../../../core/services/azkar_audio_service.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../controllers/azkar_cubit.dart';
import '../widgets/islamic_background.dart';
import 'azkar_massa_screen.dart';
import 'azkar_sabah_screen.dart';
import 'azkar_sleep_screen.dart';
import 'azkar_post_prayer_screen.dart';
import 'misbaha_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('أذكاري'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'الإعدادات',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: IslamicBackground(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  Text(
                    'اذكر الله بقلب حاضر',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر وردك وابدأ العد بهدوء',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _AzkarHomeCard(
                    title: 'أذكار الصباح',
                    subtitle: 'بداية مطمئنة لليوم',
                    icon: Icons.wb_sunny_outlined,
                    audioGroup: AzkarAudioGroup.morning,
                    onTap: () => _open(context, const AzkarSabahScreen()),
                  ),
                  const SizedBox(height: 16),
                  _AzkarHomeCard(
                    title: 'أذكار المساء',
                    subtitle: 'سكينة قبل ختام اليوم',
                    icon: Icons.nightlight_outlined,
                    audioGroup: AzkarAudioGroup.evening,
                    onTap: () => _open(context, const AzkarMassaScreen()),
                  ),
                  const SizedBox(height: 16),
                  _AzkarHomeCard(
                    title: 'أذكار النوم',
                    subtitle: 'حصن قبل المنام',
                    icon: Icons.bedtime_outlined,
                    audioGroup: AzkarAudioGroup.sleep,
                    onTap: () => _open(context, const AzkarSleepScreen()),
                  ),
                  const SizedBox(height: 16),
                  _AzkarHomeCard(
                    title: 'أذكار بعد الصلاة',
                    subtitle: 'ختام الصلوات المكتوبة',
                    icon: Icons.mosque_outlined,
                    audioGroup: AzkarAudioGroup.postPrayer,
                    onTap: () => _open(context, const AzkarPostPrayerScreen()),
                  ),
                  const SizedBox(height: 16),
                  _AzkarHomeCard(
                    title: 'المسبحة الإلكترونية',
                    subtitle: 'تسبيح حر بدون قيود',
                    icon: Icons.touch_app_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MisbahaScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BlocProvider(create: (context) => AzkarCubit(), child: screen),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.05);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class _AzkarHomeCard extends StatelessWidget {
  const _AzkarHomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.audioGroup,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final AzkarAudioGroup? audioGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F3D34),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: const Color(0xFFFFFBF0), size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                if (audioGroup != null)
                  _GroupDownloadButton(group: audioGroup!),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 24,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupDownloadButton extends StatefulWidget {
  const _GroupDownloadButton({required this.group});

  final AzkarAudioGroup group;

  @override
  State<_GroupDownloadButton> createState() => _GroupDownloadButtonState();
}

class _GroupDownloadButtonState extends State<_GroupDownloadButton> {
  double? _progress;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final downloaded = await AzkarAudioService.areAllDownloaded(
      AzkarAudioCatalog.available(widget.group),
    );
    if (mounted) setState(() => _isDownloaded = downloaded);
  }

  Future<void> _download() async {
    if (_progress != null) return;
    final urls = AzkarAudioCatalog.available(widget.group);
    if (urls.isEmpty) return;

    setState(() => _progress = 0);
    try {
      for (var i = 0; i < urls.length; i++) {
        await AzkarAudioService.download(urls[i]);
        if (mounted) setState(() => _progress = (i + 1) / urls.length);
      }
      if (mounted) setState(() => _isDownloaded = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحميل المجموعة كاملة')),
        );
      }
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _progress == null
        ? IconButton(
            tooltip: _isDownloaded
                ? 'تم تحميل المجموعة كاملة'
                : 'تحميل المجموعة كاملة',
            onPressed: _isDownloaded ? null : _download,
            icon: Icon(
              _isDownloaded
                  ? Icons.check_circle_rounded
                  : Icons.download_rounded,
            ),
          )
        : SizedBox(
            width: 40,
            height: 40,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircularProgressIndicator(value: _progress),
            ),
          );
  }
}
