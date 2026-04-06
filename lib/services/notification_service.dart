import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    print('Notification init skipped for release build compatibility.');
  }

  Future<void> showTestNotification() async {
    print('Test notification executed stubs for release build.');
  }

  Future<void> scheduleDailyReminder() async {
    print('Daily reminder executed stubs for release build.');
  }
}
