import 'package:azkary/features/azkar/presentation/controllers/azkar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/azkar_vertical_slider.dart';
import '../widgets/islamic_background.dart';

class AzkarSabahScreen extends StatefulWidget {
  const AzkarSabahScreen({super.key});

  @override
  State<AzkarSabahScreen> createState() => _AzkarSabahScreenState();
}

class _AzkarSabahScreenState extends State<AzkarSabahScreen> {
  @override
  void initState() {
    context.read<AzkarCubit>().getAzkarSabah();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        final cubit = context.read<AzkarCubit>();
        final azkarList = state.azkarSabahList;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('أذكار الصباح')),
            body: IslamicBackground(
              child: Center(
                child: switch (state.status) {
                  AzkarStatus.loading => const CircularProgressIndicator(),
                  AzkarStatus.error => _Message(text: state.error),
                  _ when azkarList.isEmpty => const _Message(
                    text: 'تمت أذكار الصباح',
                  ),
                  _ => AzkarVerticalSlider(
                    azkarList: azkarList,
                    totalAzkarCount: state.totalSabahAzkar,
                    onTapCounter: (azkar) =>
                        cubit.changeCounterForAzkarSabah(azkar),
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
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
