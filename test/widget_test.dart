import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azkary/features/azkar/domain/entities/azkar_entity.dart';
import 'package:azkary/features/azkar/presentation/widgets/zekr_widget.dart';
import 'package:azkary/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:azkary/main.dart';

void main() {
  testWidgets('home shows azkar choices', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('أذكاري'), findsOneWidget);
    expect(find.text('أذكار الصباح'), findsOneWidget);
    expect(find.text('أذكار المساء'), findsOneWidget);
  });

  testWidgets('zekr separates basmala and shows verse numbers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyAppShell(
        child: BlocProvider(
          create: (_) => SettingsCubit(),
          child: ZekrWidget(
            azkar: AzkarEntity(
              zekr:
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ قُلْ هُوَ ٱللَّهُ أَحَدٌ، ٱللَّهُ ٱلصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ.',
              counter: 3,
              repeat: 3,
              bless: '',
            ),
          ),
        ),
      ),
    );

    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), findsOneWidget);
    expect(find.text('١'), findsOneWidget);
    expect(find.text('٤'), findsOneWidget);
  });
}

class MyAppShell extends StatelessWidget {
  const MyAppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    );
  }
}
