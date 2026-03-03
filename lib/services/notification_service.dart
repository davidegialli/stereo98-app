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
    _initialized = true;
    if (kDebugMode) print('[Stereo98] NotificationService initialized');
  }

  /// Programma notifica per un programma del palinsesto
  /// [showId] — identificativo unico (hash del nome + giorno + orario)
  /// [showName] — nome del programma
  /// [weekday] — 1=Lunedì, 7=Domenica
  /// [startHour], [startMinute] — orario inizio
  /// [minutesBefore] — quanti minuti prima notificare
  Future<void> scheduleShowReminder({
    required int showId,
    required String showName,
    required int weekday,
    required int startHour,
    required int startMinute,
    required int minutesBefore,
  }) async {
    if (!_initialized) await init();

    final now = tz.TZDateTime.now(tz.local);

    // Trova la prossima occorrenza di questo giorno/orario
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      startHour, startMinute,
    ).subtract(Duration(minutes: minutesBefore));

    // Aggiusta al giorno corretto della settimana
    // weekday: 1=Lun...7=Dom, DateTime.weekday: 1=Mon...7=Sun
    int daysUntil = weekday - now.weekday;
    if (daysUntil < 0) daysUntil += 7;
    if (daysUntil == 0 && scheduledDate.isBefore(now)) daysUntil = 7;
    scheduledDate = scheduledDate.add(Duration(days: daysUntil));

    // Se è nel passato, sposta alla settimana prossima
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    final androidDetails = AndroidNotificationDetails(
      'stereo98_palinsesto',
      'Palinsesto Stereo 98',
      channelDescription: 'Promemoria programmi preferiti',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: Color(0xFFD85D9D),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      showId,
      '📻 Stereo 98 DAB+',
      '$showName tra $minutesBefore minuti!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    if (kDebugMode) {
      print('[Stereo98] Notifica programmata: "$showName" → $scheduledDate (${minutesBefore}min prima)');
    }
  }

  /// Cancella notifica per un programma
  Future<void> cancelShowReminder(int showId) async {
    await _plugin.cancel(showId);
    if (kDebugMode) print('[Stereo98] Notifica cancellata: ID $showId');
  }

  /// Cancella tutte le notifiche palinsesto
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    if (kDebugMode) print('[Stereo98] Tutte le notifiche cancellate');
  }

  /// Genera un ID stabile per un programma + giorno
  static int generateShowId(String showName, int weekday, String startTime) {
    return '${showName.toLowerCase().trim()}|$weekday|$startTime'.hashCode.abs() % 100000;
  }
}
