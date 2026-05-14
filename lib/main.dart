import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vehicle_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await NotificationService.scheduleExpiryCheck();
  runApp(const FleetTaxApp());
}

class FleetTaxApp extends StatelessWidget {
  const FleetTaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Neo-brutalism colors
    const primaryColor = Color(0xFFFFD600); // Bold yellow
    const secondaryColor = Color(0xFFFF6B35); // Bold orange
    const accentColor = Color(0xFF00D9FF); // Bold cyan
    const errorColor = Color(0xFFFF0044); // Bold red
    const backgroundColor = Color(0xFFF5F5F5); // Light gray
    const surfaceColor = Color(0xFFFFFFFF); // White
    const blackColor = Color(0xFF000000); // Pure black
    const borderWidth = 3.0;

    return ChangeNotifierProvider(
      create: (_) => VehicleProvider()..load(),
      child: MaterialApp(
        title: 'Fleet Tax',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            secondary: secondaryColor,
            tertiary: accentColor,
            error: errorColor,
            surface: surfaceColor,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: backgroundColor,
          fontFamily: 'Roboto',

          // AppBar - blocky with heavy border
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: blackColor,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: blackColor,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            actionsIconTheme: const IconThemeData(
              color: blackColor,
              size: 26,
            ),
          ),

          // Card - heavy border, blocky shadow
          cardTheme: CardThemeData(
            color: surfaceColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: const BorderSide(color: blackColor, width: borderWidth),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          ),

          // FloatingActionButton - bold with offset shadow
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
            foregroundColor: blackColor,
            elevation: 4,
            highlightElevation: 8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),

          // Input decoration - heavy border, no rounding
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: const BorderSide(color: blackColor, width: borderWidth),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: const BorderSide(color: blackColor, width: borderWidth),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: const BorderSide(color: blackColor, width: borderWidth + 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: const BorderSide(color: errorColor, width: borderWidth),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              color: blackColor,
            ),
          ),

          // Elevated button - blocky, heavy border
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: blackColor,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              side: const BorderSide(color: blackColor, width: borderWidth),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),

          // Filled button
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: blackColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              side: const BorderSide(color: blackColor, width: borderWidth),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),

          // Text button
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: blackColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              side: const BorderSide(color: blackColor, width: 2),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),

          // Outlined button
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: blackColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              side: const BorderSide(color: blackColor, width: borderWidth),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),

          // Bottom sheet
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),

          // Dialog
          dialogTheme: DialogThemeData(
            backgroundColor: surfaceColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: blackColor, width: borderWidth),
            ),
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: blackColor,
            ),
          ),

          // Chip
          chipTheme: ChipThemeData(
            backgroundColor: surfaceColor,
            selectedColor: primaryColor,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              color: blackColor,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: blackColor, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),

          // Snackbar
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: blackColor,
            contentTextStyle: TextStyle(
              color: surfaceColor,
              fontWeight: FontWeight.w700,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),

          // Divider
          dividerTheme: const DividerThemeData(
            color: blackColor,
            thickness: 2,
          ),

          // List tile
          listTileTheme: const ListTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),

          // Icon
          iconTheme: const IconThemeData(
            color: blackColor,
            size: 24,
          ),

          // Text theme
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.w900, color: blackColor),
            displayMedium: TextStyle(fontWeight: FontWeight.w900, color: blackColor),
            displaySmall: TextStyle(fontWeight: FontWeight.w900, color: blackColor),
            headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: blackColor),
            headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: blackColor),
            headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: blackColor),
            titleLarge: TextStyle(fontWeight: FontWeight.w800, color: blackColor),
            titleMedium: TextStyle(fontWeight: FontWeight.w700, color: blackColor),
            titleSmall: TextStyle(fontWeight: FontWeight.w700, color: blackColor),
            bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: blackColor),
            bodyMedium: TextStyle(fontWeight: FontWeight.w500, color: blackColor),
            bodySmall: TextStyle(fontWeight: FontWeight.w500, color: blackColor),
            labelLarge: TextStyle(fontWeight: FontWeight.w700, color: blackColor),
            labelMedium: TextStyle(fontWeight: FontWeight.w700, color: blackColor),
            labelSmall: TextStyle(fontWeight: FontWeight.w700, color: blackColor),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}