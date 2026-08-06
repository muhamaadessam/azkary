import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:azkary/features/settings/presentation/controllers/settings_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('azkary/capsule_scheduler'),
          (methodCall) async => null,
        );
  });

  test('toggleAutoPlayAudio updates state and saves to SharedPreferences', () async {
    final cubit = SettingsCubit();
    expect(cubit.state.autoPlayAudio, isFalse);

    await cubit.toggleAutoPlayAudio(true);
    expect(cubit.state.autoPlayAudio, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('autoPlayAudio'), isTrue);

    await cubit.close();
  });
}
