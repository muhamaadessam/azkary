import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/azkar_cubit.dart';
import '../widgets/azkar_vertical_slider.dart';
import '../widgets/islamic_background.dart';

class AzkarPostPrayerScreen extends StatefulWidget {
  const AzkarPostPrayerScreen({super.key});

  @override
  State<AzkarPostPrayerScreen> createState() => _AzkarPostPrayerScreenState();
}

class _AzkarPostPrayerScreenState extends State<AzkarPostPrayerScreen> {
  @override
  void initState() {
    context.read<AzkarCubit>().getAzkarPostPrayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        final cubit = context.read<AzkarCubit>();
        final azkarList = state.azkarPostPrayerList;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('أذكار بعد الصلاة')),
            body: IslamicBackground(
              child: Center(
                child: switch (state.status) {
                  AzkarStatus.loading => const CircularProgressIndicator(),
                  AzkarStatus.error => _Message(text: state.error),
                  _ when azkarList.isEmpty => const _Message(
                    text: 'تمت أذكار بعد الصلاة',
                  ),
                  _ => AzkarVerticalSlider(
                    azkarList: azkarList,
                    totalAzkarCount: state.totalPostPrayerAzkar,
                    onTapCounter: (azkar) =>
                        cubit.changeCounterForAzkarPostPrayer(azkar),
                  ),
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
