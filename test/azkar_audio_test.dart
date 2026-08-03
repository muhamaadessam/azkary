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
}
