import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import '../models/vehicle.dart';
import '../db/database_helper.dart';

const String expiryCheckTask = 'expiryCheckTask';

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == expiryCheckTask) {
      try {
        final db = DatabaseHelper();
        final vehicles = await db.getAll();
        await NotificationService.scheduleVehicleNotifications(vehicles);
      } catch (e) {
        // Silent fail for background task
      }
    }
    return Future.value(true);
  });
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<bool> initialize() async {
    // Create notification channel for Android 8.0+
    const androidChannel = AndroidNotificationChannel(
      'fleet_tax_expiry',
      'Tax Expiry Alerts',
      description: 'Notifications for vehicle tax expiry',
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
      // Request notification permission for Android 13+
      await androidPlugin.requestNotificationsPermission();
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false,
    );

    return true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could open specific vehicle details
  }

  static Future<void> scheduleExpiryCheck() async {
    await Workmanager().registerPeriodicTask(
      'expiryCheck',
      expiryCheckTask,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> scheduleVehicleNotifications(List<Vehicle> vehicles) async {
    // Cancel existing notifications first
    await _notifications.cancelAll();

    final now = DateTime.now();
    final notificationIds = <int>[];

    for (final vehicle in vehicles) {
      final expiryDate = vehicle.expiryDate;
      final daysLeft = vehicle.daysLeft;

      // Notify if expired or expiring within 5 days
      if (daysLeft <= 5) {
        final androidDetails = AndroidNotificationDetails(
          'fleet_tax_expiry',
          'Tax Expiry Alerts',
          channelDescription: 'Notifications for vehicle tax expiry',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(''),
        );

        final notificationDetails = NotificationDetails(android: androidDetails);

        String title;
        String body;

        if (daysLeft < 0) {
          title = 'Tax Expired';
          body = '${vehicle.reg} tax has expired ${-daysLeft} days ago';
        } else if (daysLeft == 0) {
          title = 'Tax Expires Today';
          body = '${vehicle.reg} tax expires today!';
        } else {
          title = 'Tax Expiring Soon';
          body = '${vehicle.reg} tax expires in $daysLeft days';
        }

        final id = vehicle.id ?? vehicle.reg.hashCode;
        notificationIds.add(id);

        await _notifications.show(
          id,
          title,
          body,
          notificationDetails,
        );
      }
    }

    return Future.value(notificationIds);
  }
}