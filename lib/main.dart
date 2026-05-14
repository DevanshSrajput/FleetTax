import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/vehicle_provider.dart';
import 'services/notification_service.dart';
import 'services/workmanager_service.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request notification permission
  await Permission.notification.request();

  // Initialize notification service
  await NotificationService.init();

  // Initialize WorkManager for background tasks
  await initWorkManager();

  runApp(const FleetTaxApp());
}

class FleetTaxApp extends StatelessWidget {
  const FleetTaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VehicleProvider()..load(),
      child: MaterialApp(
        title: 'FleetTax',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF1D9E75),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}