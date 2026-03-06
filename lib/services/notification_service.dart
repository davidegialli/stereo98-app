import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Rome'));

    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    _initialized = true;
  }

  Future<void> scheduleShowReminder({
    required int showId,
    required String showName,
    required int weekday,
    required int startHour,
    required int startMinute,
    required int minutesBefore,
  }) async {
    try {
      if (!_initialized) await init();

      final now = tz.TZDateTime.now(tz.local);

      var showTime = tz.TZDateTime(
        tz.local,
        now.year, now.month, now.day,
        startHour, startMinute,
      );

      int daysUntil = weekday - now.weekday;
      if (daysUntil < 0) daysUntil += 7;
      if (daysUntil == 0 && showTime.isBefore(now)) daysUntil = 7;
      showTime = showTime.add(Duration(days: daysUntil));

      var scheduledDate = showTime.subtract(Duration(minutes: minutesBefore));

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      await _plugin.cancel(showId);

      const androidDetails = AndroidNotificationDetails(
        'stereo98_shows',
        'Programmi Stereo 98',
        channelDescription: 'Promemoria programmi preferiti',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.zonedSchedule(
        showId,
        'Stereo 98 DAB+',
        '$showName tra $minutesBefore minuti!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Errore schedule: $e');
    }
  }

  /// Test: notifica IMMEDIATA
  Future<void> testNotification() async {
    try {
      if (!_initialized) await init();
      await _plugin.cancel(99999);

      const androidDetails = AndroidNotificationDetails(
        'stereo98_shows',
        'Programmi Stereo 98',
        channelDescription: 'Promemoria programmi preferiti',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        99999,
        'Stereo 98 DAB+',
        'Test notifica immediata - funziona!',
        details,
      );
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Errore test: $e');
    }
  }

  /// Test: notifica PROGRAMMATA tra 2 minuti
  Future<void> testScheduledNotification() async {
    try {
      if (!_initialized) await init();
      await _plugin.cancel(99998);

      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(minutes: 2));

      const androidDetails = AndroidNotificationDetails(
        'stereo98_shows',
        'Programmi Stereo 98',
        channelDescription: 'Promemoria programmi preferiti',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.zonedSchedule(
        99998,
        'Stereo 98 DAB+',
        'Test programmato 2min - funziona!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Errore test scheduled: $e');
    }
  }

  Future<void> cancelShowReminder(int showId) async {
    await _plugin.cancel(showId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static int generateShowId(String showName, int weekday, String startTime) {
    return '${showName.toLowerCase().trim()}|$weekday|$startTime'.hashCode.abs() % 100000;
  }
}
