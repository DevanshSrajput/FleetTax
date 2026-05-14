import 'package:workmanager/workmanager.dart';
import '../db/database_helper.dart';
import 'notification_service.dart';

const String taskName = 'daily_tax_check';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final vehicles = await DatabaseHelper().getAll();
      for (final vehicle in vehicles) {
        if (vehicle.id != null && vehicle.daysLeft <= 10) {
          await NotificationService.showAlert(
            vehicle.id!,
            vehicle.reg,
            vehicle.daysLeft,
          );
        }
      }
    } catch (e) {
      // Log error but don't crash the background task
    }
    return true;
  });
}

Future<void> initWorkManager() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  await Workmanager().registerPeriodicTask(
    taskName,
    taskName,
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

Future<void> triggerImmediateCheck() async {
  await Workmanager().registerOneOffTask(
    'immediate_tax_check',
    taskName,
  );
}