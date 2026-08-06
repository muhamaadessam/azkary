import 'package:flutter_test/flutter_test.dart';

import 'package:azkary/features/azkar/presentation/controllers/azkar_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'morning adhkar attach audio without inventing missing recordings',
    () async {
      final cubit = AzkarCubit();
      addTearDown(cubit.close);

      await cubit.getAzkarSabah();

      expect(cubit.state.azkarSabahList.first.audioUrl, endsWith('/75.mp3'));
      expect(cubit.state.azkarSabahList[22].audioUrl, isNull);

      await cubit.getAzkarSleep();
      expect(cubit.state.azkarSleepList.first.audioUrl, endsWith('/102.mp3'));

      await cubit.getAzkarPostPrayer();
      expect(
        cubit.state.azkarPostPrayerList.last.audioUrl,
        endsWith('/71.mp3'),
      );
    },
  );

  test('adhkar text keeps the verified corrections', () async {
    final cubit = AzkarCubit();
    addTearDown(cubit.close);

    await cubit.getAzkarSabah();
    final morning = cubit.state.azkarSabahList;
    expect(morning.first.zekr, contains('اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ'));
    expect(morning.first.bless, isEmpty);
    expect(morning[7].zekr, contains('أَنَّ مُحَمَّداً'));
    expect(morning[21].repeat, 1);
    expect(morning.last.bless, isEmpty);

    await cubit.getAzkarMassa();
    final evening = cubit.state.azkarMassaList;
    expect(evening[5].zekr, contains('اللَّيْلَةِ'));
    expect(evening[5].bless, isEmpty);
    expect(evening[9].bless, contains('أدى شكر ليلته'));

    await cubit.getAzkarPostPrayer();
    final afterPrayer = cubit.state.azkarPostPrayerList;
    expect(afterPrayer.last.zekr, contains('اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ'));
    expect(afterPrayer[6].bless, isEmpty);
  });
}
