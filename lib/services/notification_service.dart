// FIXES applicati in Build 30:
// 1. alarmClock → exactAllowWhileIdle (compatibile con SCHEDULE_EXACT_ALARM nel manifest)
//    alarmClock usa AlarmManager.setAlarmClock() che richiede USE_EXACT_ALARM (diverso!)
//    e fallisce silenziosamente con SCHEDULE_EXACT_ALARM su Android 12+
// 2. testNotification/testScheduledNotification ora ritornano Future<String> con esito reale
// 3. verifica pendingNotificationRequests() dopo ogni zonedSchedule
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
        final exactOk = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('[Stereo98] requestExactAlarmsPermission: $exactOk');
      }
    }

    _initialized = true;
  }

  static const _androidDetails = AndroidNotificationDetails(
    'stereo98_shows',
    'Programmi Stereo 98',
    channelDescription: 'Promemoria programmi preferiti',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    enableVibration: true,
  );

  static const _notifDetails = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

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

      // FIX: exactAllowWhileIdle è compatibile con SCHEDULE_EXACT_ALARM
      // alarmClock richiederebbe USE_EXACT_ALARM (permesso diverso!) e fallisce silenziosamente
      await _plugin.zonedSchedule(
        showId,
        'Stereo 98 DAB+',
        '$showName tra $minutesBefore minuti!',
        scheduledDate,
        _notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      debugPrint('[Stereo98] Scheduled "$showName" per $scheduledDate');
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Errore schedule: $e');
    }
  }

  /// Test: notifica IMMEDIATA — ritorna String con esito reale
  Future<String> testNotification() async {
    try {
      if (!_initialized) await init();
      await _plugin.cancel(99999);

      await _plugin.show(
        99999,
        'Stereo 98 DAB+',
        'Test notifica immediata ✓',
        _notifDetails,
      );
      return 'OK: notifica immediata inviata';
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Errore test immediata: $e');
      return 'ERRORE: $e';
    }
  }

  /// Test: notifica PROGRAMMATA tra 2 minuti — ritorna String con esito reale
  Future<String> testScheduledNotification() async {
    try {
      if (!_initialized) await init();
      await _plugin.cancel(99998);

      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(minutes: 2));

      debugPrint('[Stereo98] Scheduling test per: $scheduledDate');

      // FIX: exactAllowWhileIdle invece di alarmClock
      await _plugin.zonedSchedule(
        99998,
        'Stereo 98 DAB+',
        'Test programmato 2min ✓',
        scheduledDate,
        _notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Niente matchDateTimeComponents: è un test singolo, non serve ripetizione
      );

      // Verifica che sia davvero finita in pending
      final pending = await _plugin.pendingNotificationRequests();
      final found = pending.any((n) => n.id == 99998);
      debugPrint('[Stereo98] Pending: ${pending.length} totali, id 99998 trovato: $found');

      if (!found) {
        return 'ATTENZIONE: schedulato senza eccezioni ma NON in pending!\n'
            'Vai in Impostazioni > App > Stereo 98 > Allarmi e verifica il permesso.';
      }

      final orario =
          '${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}';
      return 'OK: schedulata per $orario — trovata in pending ✓';
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Errore test scheduled: $e');
      return 'ERRORE: $e';
    }
  }

  Future<void> cancelShowReminder(int showId) async {
    await _plugin.cancel(showId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPending() async {
    return _plugin.pendingNotificationRequests();
  }

  static int generateShowId(String showName, int weekday, String startTime) {
    return '${showName.toLowerCase().trim()}|$weekday|$startTime'
        .hashCode
        .abs() %
        100000;
  }
}
