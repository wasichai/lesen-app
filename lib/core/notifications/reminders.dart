import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Un recordatorio diario, local al dispositivo: el backend no tiene avisos push (hueco documentado en
/// `docs/architecture/api-integration.md`).
class Reminder {
  const Reminder({required this.id, required this.hour, required this.minute, required this.title, required this.body});

  final int id;
  final int hour;
  final int minute;
  final String title;
  final String body;
}

abstract interface class ReminderScheduler {
  /// Pide permiso (solo al activar un recordatorio). `false` si la persona no lo concede.
  Future<bool> requestPermission();
  Future<void> scheduleDaily(Reminder reminder);
  Future<void> cancel(int id);
}

/// Los recordatorios con flutter_local_notifications, sin alarmas exactas (no hace falta precisión al minuto).
class LocalReminderScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;
    return false;
  }

  @override
  Future<void> scheduleDaily(Reminder r) async {
    await _init();
    await _plugin.zonedSchedule(
      id: r.id,
      title: r.title,
      body: r.body,
      scheduledDate: nextOccurrence(DateTime.now(), r.hour, r.minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'com.wasichai.lesen.reminders',
          'Recordatorios',
          channelDescription: 'Un aviso al día para leer o repasar, si lo activas',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _init();
    await _plugin.cancel(id: id);
  }
}

/// La próxima vez que el reloj local marque `hour:minute`, expresada en UTC (la base de datos de zonas no hace falta:
/// el desfase de hoy sirve; con el cambio de hora, el aviso se corre una hora hasta reprogramarlo).
@visibleForTesting
tz.TZDateTime nextOccurrence(DateTime now, int hour, int minute) {
  var local = DateTime(now.year, now.month, now.day, hour, minute);
  if (!local.isAfter(now)) local = local.add(const Duration(days: 1));
  return tz.TZDateTime.from(local.toUtc(), tz.UTC);
}

class FakeReminderScheduler implements ReminderScheduler {
  final scheduled = <int, Reminder>{};
  bool grant = true;

  @override
  Future<bool> requestPermission() async => grant;

  @override
  Future<void> scheduleDaily(Reminder reminder) async => scheduled[reminder.id] = reminder;

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);
}

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) => LocalReminderScheduler());
