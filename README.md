<div align="center">

# 🚍 FleetTax

**Vahan road tax tracker for bus & truck fleet owners**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)](https://github.com/DevanshSrajput/FleetTax/releases)

<img src="FleetTax.png" alt="FleetTax Banner" width="600"/>

</div>

---

## 📖 About

**FleetTax** is a fully offline Android app built with Flutter that helps fleet owners track **Vahan road tax payment deadlines** for their buses and trucks. It automatically calculates expiry dates, sends daily push notifications starting 10 days before tax expires, and provides a one-tap shortcut to pay tax directly on the Vahan portal.

No internet, no login, no cloud — just your vehicle data stored securely on-device via SQLite.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🚗 **Add / Edit Vehicles** | Store reg number, vehicle type (bus/truck), tax period, last payment date, and optional notes |
| 📅 **Auto Expiry Calculation** | Computes validity end date from last paid date + period (monthly / quarterly / yearly) |
| 📊 **Dashboard** | Stats bar (total / expired / due soon / valid) with colour-coded vehicle cards |
| 🔍 **Filter & Search** | Filter by status or vehicle type; search by registration number |
| ✅ **Mark as Paid** | Log new payment with date, period, and receipt reference — expiry recalculated instantly |
| 🔔 **Daily Push Notifications** | Alerts fire every day from T−10 days until tax is marked paid, even when app is closed |
| 🌐 **Vahan Quick-Launch** | One tap opens `vahan.parivahan.gov.in` in browser to pay tax online |
| 🗂️ **Sort Options** | Sort by expiry soonest / reg number / vehicle type |
| 📴 **Fully Offline** | All data stored locally with SQLite — no internet required |

---

## 🎨 UI Design

FleetTax uses a **neo-brutalism** design language — bold yellow/orange/cyan accent colours, heavy black borders, sharp corners, and high-contrast typography for fast readability in bright outdoor conditions.

| Status | Colour |
|---|---|
| 🔴 Expired | Bold Red `#FF0044` |
| 🟠 Due Soon (≤10 days) | Bold Orange `#FF6B35` |
| 🟢 Valid | Bold Green `#00E676` |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart 3.x) |
| State Management | Provider |
| Local Database | SQLite via `sqflite` |
| Notifications | `flutter_local_notifications` |
| Background Tasks | `workmanager` (daily expiry check) |
| Date Formatting | `intl` |
| URL Launch | `url_launcher` |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point, theme, notification init
├── models/
│   └── vehicle.dart             # Vehicle data class + expiry logic
├── db/
│   └── database_helper.dart     # SQLite CRUD operations
├── services/
│   ├── notification_service.dart  # Schedule / cancel local alerts
│   └── workmanager_service.dart   # Background daily check task
├── providers/
│   └── vehicle_provider.dart    # State + business logic (Provider)
├── screens/
│   ├── dashboard_screen.dart    # Main vehicle list view
│   ├── add_edit_screen.dart     # Add / edit vehicle form
│   └── mark_paid_screen.dart    # Payment entry screen
└── widgets/
    ├── vehicle_card.dart        # Single vehicle tile widget
    ├── stats_bar.dart           # Top summary numbers row
    └── filter_chips.dart        # Filter chip row
```

---

## 🗄️ Database Schema

```sql
CREATE TABLE vehicles (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  reg         TEXT NOT NULL,          -- Vehicle registration number
  type        TEXT NOT NULL,          -- 'bus' | 'truck'
  tax_period  TEXT NOT NULL,          -- 'monthly' | 'quarterly' | 'yearly'
  last_paid   TEXT NOT NULL,          -- ISO date e.g. '2025-05-01'
  notes       TEXT,
  receipt_ref TEXT,
  created_at  TEXT NOT NULL
);
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.11
- [Android Studio](https://developer.android.com/studio) with Android SDK 33+ installed
- A physical Android device **or** an Android emulator (API 33 recommended)

### 1 — Clone the repo

```bash
git clone https://github.com/DevanshSrajput/FleetTax.git
cd FleetTax
```

### 2 — Install dependencies

```bash
flutter pub get
```

### 3 — Verify setup

```bash
flutter doctor
```

All items should show ✓ before proceeding. Fix any issues it reports.

### 4 — Run on emulator / device

```bash
flutter devices          # list available devices
flutter run              # build and launch
```

> **First run** takes 2–3 minutes to compile. Subsequent runs are instant with hot-reload (`r`).

### 5 — Build release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🔔 Notifications Setup

FleetTax uses **WorkManager** to schedule a daily background check. For notifications to fire reliably:

- **Android 13+**: The app requests `POST_NOTIFICATIONS` permission on first launch. Accept it.
- **Xiaomi / OnePlus / Oppo / Samsung**: Allow background activity for FleetTax in your device's battery/power settings.

### Required Android permissions (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 🐛 Common Issues & Fixes

| Error | Fix |
|---|---|
| `SDK not found` | Run `flutter doctor` and follow its instructions |
| Notifications not showing | Ensure `POST_NOTIFICATIONS` permission was granted at runtime |
| WorkManager not firing | On Chinese OEM phones, allow background activity in battery settings |
| `MissingPluginException` | Run `flutter clean && flutter pub get`, then restart |
| App crashes on launch | Run `flutter logs` to see the full trace; usually a missing `await` in `main()` |

---

## 🗺️ Roadmap

- [x] Vehicle CRUD (add / edit / delete)
- [x] Tax expiry calculation (monthly / quarterly / yearly)
- [x] Dashboard with stats & colour-coded cards
- [x] Filter, search, and sort
- [x] Mark paid with receipt reference
- [x] Daily push notifications via WorkManager
- [x] Vahan portal quick-launch
- [ ] Insurance & fitness certificate (FC) tracking *(v2)*
- [ ] Google Drive backup / restore of SQLite database *(v2)*
- [ ] PDF receipt photo capture per payment *(v2)*
- [ ] Multi-owner / driver assignment per vehicle *(v2)*
- [ ] Play Store release *(v2)*

---

## 🤝 Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

Made with ❤️ using Flutter · Built for Indian fleet owners

</div>
