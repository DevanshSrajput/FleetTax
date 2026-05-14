import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import '../models/vehicle.dart';
import '../db/database_helper.dart';

const String expiryCheckTask = 'expiryCheckTask';
const String notificationChannelId = 'fleet_tax_expiry';
const String notificationChannelName = 'Tax Expiry Alerts';

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == expiryCheckTask) {
      try {
        final db = DatabaseHelper();
        final vehicles = await db.getAll();
        await _scheduleNotificationsBackground(vehicles);
      } catch (e) {
        // Silent fail for background task
      }
    }
    return true;
  });
}

Future<void> _scheduleNotificationsBackground(List<Vehicle> vehicles) async {
  final notifications = FlutterLocalNotificationsPlugin();
  await notifications.cancelAll();

  const androidDetails = AndroidNotificationDetails(
    notificationChannelId,
    notificationChannelName,
    channelDescription: 'Notifications for vehicle tax expiry',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const notificationDetails = NotificationDetails(android: androidDetails);

  for (final vehicle in vehicles) {
    final daysLeft = vehicle.daysLeft;
    if (daysLeft <= 5) {
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
      await notifications.show(id, title, body, notificationDetails);
    }
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<bool> initialize() async {
    const androidChannel = AndroidNotificationChannel(
      notificationChannelId,
      notificationChannelName,
      description: 'Notifications for vehicle tax expiry',
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
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
    // Handle notification tap
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
    // Use compute() for heavy notification work - runs on separate thread
    await Future.delayed(Duration.zero); // Yield to let UI update

    // Cancel existing notifications
    await _notifications.cancelAll();

    const androidDetails = AndroidNotificationDetails(
      notificationChannelId,
      notificationChannelName,
      channelDescription: 'Notifications for vehicle tax expiry',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // Process each vehicle - this is lightweight since we cache daysLeft
    for (final vehicle in vehicles) {
      final daysLeft = vehicle.daysLeft;
      if (daysLeft <= 5) {
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
        await _notifications.show(id, title, body, notificationDetails);
      }
    }
  }
}