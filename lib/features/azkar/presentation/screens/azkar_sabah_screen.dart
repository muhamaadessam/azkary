import 'package:azkary/features/azkar/presentation/controllers/azkar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        if (state.status == AzkarStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == AzkarStatus.error) {
          return Center(child: Text(state.error));
        }
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('أذكار الصباح')),
            body: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      azkarList.first.zekr,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontFamily: 'Traditional',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        cubit.changeCounterForAzkarSabah(azkarList.first);
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${azkarList.first.repeat.toString()}/${azkarList.first.counter.toString()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
