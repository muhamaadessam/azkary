import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide NotificationVisibility;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/capsule_azkar.dart';
import '../database/capsule_azkar_database.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse details) {
  CapsuleService().showOverlayWindow(zekrText: details.payload);
}

class CapsuleService {
  static final CapsuleService _instance = CapsuleService._internal();
  static const MethodChannel _scheduler = MethodChannel(
    'azkary/capsule_scheduler',
  );
  static const int _legacyPeriodicStartId = 100;
  static const int _legacyPeriodicCount = 50;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory CapsuleService() {
    return _instance;
  }

  CapsuleService._internal();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    await _cancelLegacyPeriodicNotifications();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        showOverlayWindow(zekrText: details.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _cancelLegacyPeriodicNotifications() async {
    for (
      var id = _legacyPeriodicStartId;
      id < _legacyPeriodicStartId + _legacyPeriodicCount;
      id++
    ) {
      await _notificationsPlugin.cancel(id: id);
    }
  }

  Future<bool> checkOverlayPermission() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  Future<void> requestOverlayPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }

  Future<void> showOverlayWindow({String? zekrText}) async {
    String zekr = zekrText ?? '';
    if (zekr.isEmpty) {
      try {
        final dbZekr =
            await CapsuleAzkarDatabase.instance.getRandomEnabledZekr();
        zekr = dbZekr?.text ?? CapsuleAzkar.random();
      } catch (_) {
        zekr = CapsuleAzkar.random();
      }
    }
    var hasPermission = await checkOverlayPermission();

    if (!hasPermission) {
      await requestOverlayPermission();
      hasPermission = await checkOverlayPermission();
    }

    if (!hasPermission) {
      return;
    }

    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }

    final density = WidgetsBinding
            .instance.platformDispatcher.views.firstOrNull?.devicePixelRatio ??
        3.0;
    final overlayHeight = (180 * density).round();

    await FlutterOverlayWindow.showOverlay(
      height: overlayHeight,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.centerRight,
      flag: OverlayFlag.focusPointer,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
    );

    await FlutterOverlayWindow.shareData(zekr);
  }

  Future<void> closeOverlayWindow() async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      payload: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_azkar_channel',
          'أذكار الصباح والمساء',
          channelDescription: 'تذكير بأذكار الصباح والمساء',
          icon: 'app_icon_notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> schedulePeriodicCapsule({
    required bool enabled,
    required int intervalMinutes,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    await _scheduler.invokeMethod<void>('schedulePeriodicCapsule', {
      'enabled': enabled,
      'intervalMinutes': intervalMinutes,
    });
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
