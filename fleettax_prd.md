# FleetTax — Flutter Android App PRD & Build Guide

> Vahan 4.0 road tax tracker for bus and truck fleet owners  
> Platform: Android · Flutter · SQLite (local) · v1.0

---

## 1. Product Overview

| Field | Detail |
|---|---|
| App name | FleetTax |
| Platform | Android (Flutter) · min SDK 21 (Android 5.0+) |
| Storage | SQLite on-device via `sqflite` |
| Notifications | Local push via `flutter_local_notifications` + `workmanager` |
| State management | Provider pattern |
| Backend | None — fully offline |

FleetTax lets fleet owners track Vahan road tax payment deadlines across all buses and trucks. Sends daily push notifications from 10 days before expiry until the tax is marked as paid.

---

## 2. Feature List — v1

### Core features

| Feature | Description |
|---|---|
| Add vehicle | Reg number, type (bus/truck), tax period (monthly/quarterly/yearly), last paid date, optional notes |
| Expiry calculation | Auto-computes validity end from last paid date + tax period. Shows days remaining. |
| Dashboard | Stats bar (total / expired / due soon / valid). Vehicle list with colour-coded status cards. |
| Filter + search | Filter by status (expired / due soon / valid) and type (bus / truck). Search by reg number. |
| Mark paid | Enter new payment date + period + receipt ref. Recalculates expiry immediately. |
| Edit / delete | Edit any vehicle detail. Delete with confirmation dialog. |

### Notifications

| Feature | Description |
|---|---|
| Daily alert | Push notification fires daily from T−10 days to expiry date. Stops when marked paid. Uses WorkManager background task — fires even when app is closed. |

### UX extras

| Feature | Description |
|---|---|
| Vahan quick-launch | Button opens `https://vahan.parivahan.gov.in` in browser to pay tax directly |
| Sort options | Sort by expiry soonest / reg number / vehicle type |

### Out of scope (v1)

- No cloud sync
- No PDF receipt upload
- No multi-user / login
- No insurance / fitness certificate tracking *(planned v2)*

---

## 3. Architecture

### File structure

```
lib/
  main.dart                    ← app entry, notification init
  models/
    vehicle.dart               ← Vehicle data class + expiry logic
  db/
    database_helper.dart       ← SQLite CRUD operations
  services/
    notification_service.dart  ← schedule / cancel alerts
    workmanager_service.dart   ← background daily check task
  providers/
    vehicle_provider.dart      ← state + business logic
  screens/
    dashboard_screen.dart      ← main list view
    add_edit_screen.dart       ← add / edit vehicle form
    mark_paid_screen.dart      ← payment entry screen
  widgets/
    vehicle_card.dart          ← single vehicle tile widget
    stats_bar.dart             ← top summary numbers row
    filter_chips.dart          ← filter chip row
android/                       ← Android-specific config
pubspec.yaml                   ← dependencies
```

### SQLite schema

```sql
CREATE TABLE vehicles (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  reg         TEXT NOT NULL,
  type        TEXT NOT NULL,       -- 'bus' | 'truck'
  tax_period  TEXT NOT NULL,       -- 'monthly' | 'quarterly' | 'yearly'
  last_paid   TEXT NOT NULL,       -- ISO date '2025-05-01'
  notes       TEXT,
  receipt_ref TEXT,
  created_at  TEXT NOT NULL
)
```

### Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.3
  path: ^1.9.0
  provider: ^6.1.2
  flutter_local_notifications: ^17.2.3
  workmanager: ^0.5.2
  intl: ^0.19.0
  url_launcher: ^6.3.1
  permission_handler: ^11.3.1
```

| Package | Purpose |
|---|---|
| `sqflite` | SQLite local database |
| `path` | DB file path helper |
| `provider` | State management |
| `flutter_local_notifications` | Local push notifications |
| `workmanager` | Background daily check task |
| `intl` | Date formatting (DD MMM YYYY) |
| `url_launcher` | Open Vahan website |
| `permission_handler` | Request notification permission at runtime |

---

## 4. One-Time Setup (Steps 1–5)

### Step 1 — Install Flutter SDK

1. Go to **flutter.dev/docs/get-started/install** and pick your OS (Windows / Mac / Linux)
2. Download the ZIP and extract to `C:\flutter` (Windows) or `~/flutter` (Mac/Linux)
3. Add `flutter/bin` to your PATH environment variable

> **Windows:** Search "Edit environment variables" → System variables → Path → New → paste path to `flutter\bin`

### Step 2 — Install Android Studio

1. Download from **developer.android.com/studio**
2. During install, check: Android SDK, Android SDK Platform, Android Virtual Device
3. Open Android Studio → More Actions → SDK Manager → install **Android 13 (API 33)** SDK Platform

### Step 3 — Run flutter doctor

```bash
flutter doctor
```

Fix every ✗ it shows. Common fixes:

```bash
# Accept Android licenses
flutter doctor --android-licenses

# If cmdline-tools missing: Android Studio → SDK Manager → SDK Tools → Android SDK Command-line Tools → install
```

All items should show ✓ before proceeding.

### Step 4 — Install VS Code

1. Download from **code.visualstudio.com**
2. Open VS Code → Extensions (`Ctrl+Shift+X`) → search "Flutter" → Install
3. The Flutter extension auto-installs Dart too

### Step 5 — Create the project

```bash
flutter create fleettax --org com.yourname
cd fleettax
code .
```

VS Code opens the project. Starting point is `lib/main.dart`.

---

## 5. Building the App (Steps 6–12)

### Step 6 — Add dependencies

Open `pubspec.yaml`. Replace the `dependencies:` section with:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.3
  path: ^1.9.0
  provider: ^6.1.2
  flutter_local_notifications: ^17.2.3
  workmanager: ^0.5.2
  intl: ^0.19.0
  url_launcher: ^6.3.1
  permission_handler: ^11.3.1
```

Then run:

```bash
flutter pub get
```

### Step 7 — Android permissions

Open `android/app/src/main/AndroidManifest.xml`.

Add inside `<manifest>` tag, **before** `<application>`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

Add inside `<application>` tag (WorkManager receiver):

```xml
<receiver
  android:name="be.tramckrijte.workmanager.WorkmanagerPlugin"
  android:exported="true">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
  </intent-filter>
</receiver>
```

### Step 8 — Vehicle model

Create `lib/models/vehicle.dart`:

```dart
class Vehicle {
  final int? id;
  final String reg;
  final String type;       // 'bus' or 'truck'
  final String taxPeriod;  // 'monthly', 'quarterly', 'yearly'
  final String lastPaid;   // 'YYYY-MM-DD'
  final String? notes;
  final String? receiptRef;

  Vehicle({
    this.id,
    required this.reg,
    required this.type,
    required this.taxPeriod,
    required this.lastPaid,
    this.notes,
    this.receiptRef,
  });

  DateTime get expiryDate {
    final d = DateTime.parse(lastPaid);
    if (taxPeriod == 'monthly')
      return DateTime(d.year, d.month + 1, d.day);
    if (taxPeriod == 'quarterly')
      return DateTime(d.year, d.month + 3, d.day);
    return DateTime(d.year + 1, d.month, d.day);
  }

  int get daysLeft =>
      expiryDate.difference(DateTime.now()).inDays;

  String get status {
    if (daysLeft < 0) return 'expired';
    if (daysLeft <= 10) return 'soon';
    return 'valid';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'reg': reg,
    'type': type,
    'tax_period': taxPeriod,
    'last_paid': lastPaid,
    'notes': notes,
    'receipt_ref': receiptRef,
    'created_at': DateTime.now().toIso8601String(),
  };

  factory Vehicle.fromMap(Map<String, dynamic> m) => Vehicle(
    id: m['id'],
    reg: m['reg'],
    type: m['type'],
    taxPeriod: m['tax_period'],
    lastPaid: m['last_paid'],
    notes: m['notes'],
    receiptRef: m['receipt_ref'],
  );
}
```

### Step 9 — Database helper

Create `lib/db/database_helper.dart`:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';

class DatabaseHelper {
  static final _instance = DatabaseHelper._();
  static Database? _db;
  factory DatabaseHelper() => _instance;
  DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'fleettax.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, v) => db.execute('''
        CREATE TABLE vehicles(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reg TEXT NOT NULL,
          type TEXT NOT NULL,
          tax_period TEXT NOT NULL,
          last_paid TEXT NOT NULL,
          notes TEXT,
          receipt_ref TEXT,
          created_at TEXT NOT NULL
        )
      '''),
    );
  }

  Future<int> insert(Vehicle v) async =>
      (await database).insert('vehicles', v.toMap());

  Future<int> update(Vehicle v) async =>
      (await database).update(
        'vehicles', v.toMap(),
        where: 'id=?', whereArgs: [v.id],
      );

  Future<int> delete(int id) async =>
      (await database).delete(
        'vehicles',
        where: 'id=?', whereArgs: [id],
      );

  Future<List<Vehicle>> getAll() async {
    final rows = await (await database)
        .query('vehicles', orderBy: 'last_paid DESC');
    return rows.map(Vehicle.fromMap).toList();
  }
}
```

### Step 10 — Notification service

Create `lib/services/notification_service.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _n = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _n.initialize(InitializationSettings(android: android));
  }

  static Future<void> showAlert(int id, String reg, int daysLeft) async {
    final msg = daysLeft < 0
        ? 'Tax EXPIRED ${daysLeft.abs()} days ago!'
        : 'Tax expires in $daysLeft day(s)';
    await _n.show(
      id,
      'FleetTax: $reg',
      msg,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'tax_alerts',
          'Tax Alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> cancelAll() => _n.cancelAll();
}
```

### Step 11 — WorkManager background task

Create `lib/services/workmanager_service.dart`:

```dart
import 'package:workmanager/workmanager.dart';
import '../db/database_helper.dart';
import 'notification_service.dart';

const taskName = 'daily_tax_check';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, data) async {
    final vehicles = await DatabaseHelper().getAll();
    for (final v in vehicles) {
      if (v.daysLeft <= 10) {
        await NotificationService.showAlert(v.id!, v.reg, v.daysLeft);
      }
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
    frequency: Duration(hours: 24),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}
```

### Step 12 — Wire up main.dart

Replace `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/vehicle_provider.dart';
import 'services/notification_service.dart';
import 'services/workmanager_service.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.request();
  await NotificationService.init();
  await initWorkManager();
  runApp(const FleetTaxApp());
}

class FleetTaxApp extends StatelessWidget {
  const FleetTaxApp({super.key});

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider(
        create: (_) => VehicleProvider()..load(),
        child: MaterialApp(
          title: 'FleetTax',
          theme: ThemeData(
            colorSchemeSeed: Color(0xFF1D9E75),
            useMaterial3: true,
          ),
          home: DashboardScreen(),
        ),
      );
}
```

> After main.dart, generate each remaining file one by one. Ask Claude: *"generate dashboard_screen.dart"*, *"generate vehicle_card.dart"*, etc.

---

## 6. Testing & Running

### A — Create Android emulator

1. Open Android Studio → Device Manager (right sidebar)
2. `+` Create Virtual Device → Pixel 7 → Next
3. Download API 33 (Android 13) → Finish
4. Start emulator (green play button)

### B — Run app on emulator

```bash
flutter devices        # should list the emulator
flutter run            # builds and launches app
```

First run takes 2–3 minutes. After that:

| Key | Action |
|---|---|
| `r` | Hot reload (applies code changes instantly) |
| `R` | Full restart |
| `q` | Quit |

### C — Run on real phone (recommended for notifications)

1. On your Android phone: **Settings → About → tap "Build number" 7 times**
2. **Developer options → enable USB debugging**
3. Connect phone via USB to PC

```bash
flutter devices                    # phone appears in list
flutter run -d <device-id>
```

### D — Test notifications manually

Add a vehicle with last paid date = today minus 25 days on a quarterly period (should show as expired). Then trigger WorkManager immediately for testing — add this temp button in dashboard:

```dart
ElevatedButton(
  onPressed: () => Workmanager().registerOneOffTask(
    'test_now', 'daily_tax_check'),
  child: Text('Test: trigger notifications'),
)
```

Remove this button before building the release APK.

### E — Build release APK

```bash
flutter build apk --release
```

APK location:
```
build/app/outputs/flutter-apk/app-release.apk
```

Share via WhatsApp / USB / Google Drive. On target phone: enable **"Install from unknown sources"** in settings before installing.

---

## 7. Common Errors & Fixes

| Error | Fix |
|---|---|
| `SDK not found` | Run `flutter doctor` → follow its instructions. Usually needs Android SDK path set in Android Studio. |
| Notifications not showing | On Android 13+, runtime permission required. Ensure `Permission.notification.request()` is called in `main()`. |
| WorkManager not firing | Background tasks are rate-limited by Android. Use `registerOneOffTask` for immediate testing. On Xiaomi/OnePlus/Oppo: allow background activity in battery settings for FleetTax. |
| `MissingPluginException` | Run `flutter clean` → `flutter pub get` → restart with `flutter run`. |
| App crashes on launch | Check `flutter logs` in terminal for the full error trace. Most common: missing `await` before async init calls in `main()`. |

---

## 8. Next Steps After v1

Possible v2 additions:

- Insurance expiry tracking (separate table, same notification logic)
- Fitness certificate (FC) expiry
- Google Drive backup / restore of SQLite file
- PDF receipt photo capture per payment
- Multi-owner / driver assignment per vehicle
- Play Store publishing (requires signing key + Google Developer account ₹2,500 one-time)

---

*Generated for FleetTax v1.0 · Flutter · SQLite · Android*
