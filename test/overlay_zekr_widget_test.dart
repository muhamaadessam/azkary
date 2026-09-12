import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azkary/features/azkar/presentation/widgets/overlay_zekr_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('x-slayer/overlay_channel'),
          (methodCall) async => null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('x-slayer/overlay'),
          (methodCall) async => null,
        );
  });

  testWidgets('OverlayZekrWidget renders without SingleChildScrollView and with flexible height',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OverlayZekrWidget(),
      ),
    );
    await tester.pump();

    // Verify there is no SingleChildScrollView inside
    expect(find.byType(SingleChildScrollView), findsNothing);

    // Verify Text is rendered
    expect(find.byType(Text), findsOneWidget);

    // Find the Container and verify constraints has maxWidth 640 (800 * 0.80) and no maxHeight
    final containerFinder = find.byWidgetPredicate((widget) =>
        widget is Container &&
        widget.constraints != null &&
        widget.constraints!.maxWidth == 640.0 &&
        widget.constraints!.maxHeight == double.infinity);
    expect(containerFinder, findsOneWidget);

    // Tap to dismiss
    await tester.tap(containerFinder);
    await tester.pump();

    // Fast-forward timer to avoid pending timers
    await tester.pump(const Duration(seconds: 16));
  });

  testWidgets('OverlayZekrWidget limits maxWidth to 80% of screen width on narrow screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(300, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: OverlayZekrWidget(),
      ),
    );
    await tester.pump();

    // On a 300px wide screen, 80% is 240px
    final containerFinder = find.byWidgetPredicate((widget) =>
        widget is Container &&
        widget.constraints != null &&
        widget.constraints!.maxWidth == 240.0 &&
        widget.constraints!.maxHeight == double.infinity);
    expect(containerFinder, findsOneWidget);

    await tester.pump(const Duration(seconds: 16));
  });
}
