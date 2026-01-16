import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // --- FUNGSI BARU: BATALKAN SEMUA NOTIFIKASI DENGAN AMAN ---
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint("Semua notifikasi berhasil dibatalkan.");
    } catch (e) {
      // Error ditangkap disini agar aplikasi tidak crash (Layar Merah)
      debugPrint("Gagal membatalkan notifikasi (Mungkin karena berjalan di Web): $e");
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour, 
    required int minute, 
    required String reminderType
  }) async {
    String title = 'Bagaimana Perasaanmu? ❤️';
    String body = 'Jangan lupa catat mood kamu hari ini.';

    if (reminderType == 'gratitude') {
      title = 'Momen Syukur Hari Ini 🌟';
      body = 'Apa hal kecil yang membuatmu tersenyum hari ini?';
    } else if (reminderType == 'reflection') {
      title = 'Refleksi Diri 🧘';
      body = 'Mari luangkan waktu sejenak untuk meninjau harimu.';
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(        
        0,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Pengingat harian MoodQ',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        // GANTI BAGIAN INI:
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, 
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      debugPrint("Notifikasi dijadwalkan: $hour:$minute - $reminderType");
    } catch (e) {
      debugPrint("Gagal menjadwalkan notifikasi: $e");
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}