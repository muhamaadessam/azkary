import 'package:azkary/features/azkar/presentation/controllers/azkar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/zekr_widget.dart';

class AzkarMassaScreen extends StatefulWidget {
  const AzkarMassaScreen({super.key});

  @override
  State<AzkarMassaScreen> createState() => _AzkarMassaScreenState();
}

class _AzkarMassaScreenState extends State<AzkarMassaScreen> {
  @override
  void initState() {
    context.read<AzkarCubit>().getAzkarMassa();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        final cubit = context.read<AzkarCubit>();
        final azkarList = state.azkarMassaList;
        if (state.status == AzkarStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == AzkarStatus.error) {
          return Center(child: Text(state.error));
        }
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('أذكار المساء')),
            body: Center(
              child: ZekrWidget(
                azkar: azkarList.first,
                onTap: () {
                  cubit.changeCounterForAzkarMassa(azkarList.first);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
