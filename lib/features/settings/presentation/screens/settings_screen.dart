import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/settings_cubit.dart';
import '../controllers/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 4,
                shadowColor: const Color(0x330F3D34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: SwitchListTile(
                  title: const Text('الوضع الليلي (Dark Mode)'),
                  subtitle: const Text('تغيير ألوان التطبيق لتريح العين في الظلام'),
                  value: state.isDarkMode,
                  activeThumbColor: theme.colorScheme.secondary,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleDarkMode(value);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shadowColor: const Color(0x330F3D34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: SwitchListTile(
                  title: const Text('الاهتزاز (Haptic Feedback)'),
                  subtitle: const Text('تفعيل الاهتزاز عند التفاعل مع أزرار التسبيح'),
                  value: state.hapticsEnabled,
                  activeThumbColor: theme.colorScheme.secondary,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleHaptics(value);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shadowColor: const Color(0x330F3D34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'حجم خط الأذكار',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('صغير', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Slider(
                              value: state.fontSize,
                              min: 16.0,
                              max: 40.0,
                              activeColor: theme.colorScheme.secondary,
                              onChanged: (value) {
                                context.read<SettingsCubit>().updateFontSize(value);
                              },
                            ),
                          ),
                          const Text('كبير', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Traditional',
                            fontSize: state.fontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFC08A28),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'عينة لتجربة حجم الخط',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Traditional',
                            fontSize: state.fontSize,
                            fontWeight: FontWeight.bold,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
