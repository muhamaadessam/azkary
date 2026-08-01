import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/azkar_cubit.dart';
import '../widgets/azkar_vertical_slider.dart';
import '../widgets/islamic_background.dart';

class AzkarSleepScreen extends StatefulWidget {
  const AzkarSleepScreen({super.key});

  @override
  State<AzkarSleepScreen> createState() => _AzkarSleepScreenState();
}

class _AzkarSleepScreenState extends State<AzkarSleepScreen> {
  @override
  void initState() {
    context.read<AzkarCubit>().getAzkarSleep();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        final cubit = context.read<AzkarCubit>();
        final azkarList = state.azkarSleepList;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('أذكار النوم')),
            body: IslamicBackground(
              child: Center(
                child: switch (state.status) {
                  AzkarStatus.loading => const CircularProgressIndicator(),
                  AzkarStatus.error => _Message(text: state.error),
                  _ when azkarList.isEmpty => const _Message(
                    text: 'تمت أذكار النوم',
                  ),
                  _ => AzkarVerticalSlider(
                    azkarList: azkarList,
                    totalAzkarCount: state.totalSleepAzkar,
                    onTapCounter: (azkar) =>
                        cubit.changeCounterForAzkarSleep(azkar),
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
