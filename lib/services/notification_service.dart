import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);
  }

  static Future<void> showAlert(int id, String reg, int daysLeft) async {
    String msg;
    if (daysLeft < 0) {
      msg = 'Tax EXPIRED ${daysLeft.abs()} days ago!';
    } else if (daysLeft == 0) {
      msg = 'Tax expires TODAY!';
    } else if (daysLeft == 1) {
      msg = 'Tax expires TOMORROW!';
    } else {
      msg = 'Tax expires in $daysLeft days';
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'tax_alerts',
      'Tax Alerts',
      channelDescription: 'Notifications for vehicle road tax expiry alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      id,
      'FleetTax: $reg',
      msg,
      notificationDetails,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}