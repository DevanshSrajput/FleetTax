import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../services/notification_service.dart';
import '../widgets/stats_bar.dart';
import '../widgets/filter_chips.dart';
import '../widgets/vehicle_card.dart';
import 'add_edit_screen.dart';
import 'mark_paid_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openVahanWebsite() async {
    final Uri url = Uri.parse('https://vahan.parivahan.gov.in');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Vahan website'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFFFF0044),
          ),
        );
      }
    }
  }

  void _showSortOptions() {
    const black = Color(0xFF000000);
    final provider = context.read<VehicleProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: black, width: 3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFFD600),
              padding: const EdgeInsets.all(12),
              child: const Text(
                'SORT BY',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 0, thickness: 3, color: black),
            ListTile(
              leading: const Icon(Icons.timer, color: black),
              title: const Text('EXPIRY (SOONEST FIRST)', style: TextStyle(fontWeight: FontWeight.w800)),
              trailing: provider.sortBy == 'expiry'
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D676),
                        border: Border.all(color: black, width: 2),
                      ),
                      child: const Icon(Icons.check, color: black, size: 16),
                    )
                  : null,
              onTap: () {
                provider.setSortBy('expiry');
                Navigator.pop(context);
              },
            ),
            const Divider(height: 0, thickness: 1, color: black),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha, color: black),
              title: const Text('REGISTRATION NUMBER', style: TextStyle(fontWeight: FontWeight.w800)),
              trailing: provider.sortBy == 'reg'
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D676),
                        border: Border.all(color: black, width: 2),
                      ),
                      child: const Icon(Icons.check, color: black, size: 16),
                    )
                  : null,
              onTap: () {
                provider.setSortBy('reg');
                Navigator.pop(context);
              },
            ),
            const Divider(height: 0, thickness: 1, color: black),
            ListTile(
              leading: const Icon(Icons.category, color: black),
              title: const Text('VEHICLE TYPE', style: TextStyle(fontWeight: FontWeight.w800)),
              trailing: provider.sortBy == 'type'
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D676),
                        border: Border.all(color: black, width: 2),
                      ),
                      child: const Icon(Icons.check, color: black, size: 16),
                    )
                  : null,
              onTap: () {
                provider.setSortBy('type');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int vehicleId, String reg) {
    const black = Color(0xFF000000);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0044),
                border: Border.all(color: black, width: 2),
              ),
              child: const Icon(Icons.delete_forever, color: black),
            ),
            const SizedBox(width: 12),
            const Text('DELETE VEHICLE', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text('Are you sure you want to delete $reg?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: black, width: 2),
            ),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<VehicleProvider>().deleteVehicle(vehicleId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vehicle deleted'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFFFF0044),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0044),
              foregroundColor: Colors.white,
              side: const BorderSide(color: black, width: 2),
            ),
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF000000);
    const borderWidth = 3.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: black, width: 2),
              ),
              child: const Icon(Icons.local_shipping, color: black, size: 22),
            ),
            const SizedBox(width: 8),
            const Text(
              'FLEETTAX',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notification',
            onPressed: () async {
              final provider = context.read<VehicleProvider>();
              await NotificationService.scheduleVehicleNotifications(provider.vehicles);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications triggered!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Test Expiry (3 days)',
            onPressed: () async {
              final provider = context.read<VehicleProvider>();
              final testVehicle = Vehicle(
                reg: 'TEST-001',
                type: 'truck',
                taxPeriod: 'yearly',
                lastPaid: DateTime.now().subtract(const Duration(days: 333)).toIso8601String().split('T')[0],
                createdAt: DateTime.now().toIso8601String(),
              );
              await provider.addVehicle(testVehicle);
              await NotificationService.scheduleVehicleNotifications(provider.vehicles);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test vehicle added and notification triggered!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF00E676),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Vahan Website',
            onPressed: _openVahanWebsite,
          ),
        ],
      ),
      body: Column(
        children: [
          const StatsBar(),
          const SizedBox(height: 8),
          const FilterChips(),
          const SizedBox(height: 8),
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by registration number...',
                prefixIcon: const Icon(Icons.search, color: black),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: black),
                        onPressed: () {
                          _searchController.clear();
                          context.read<VehicleProvider>().setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: const BorderSide(color: black, width: borderWidth),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: const BorderSide(color: black, width: borderWidth + 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                context.read<VehicleProvider>().setSearchQuery(value);
              },
            ),
          ),
          const SizedBox(height: 8),
          // Vehicle List
          Expanded(
            child: Consumer<VehicleProvider>(
              builder: (context, provider, child) {
                final vehicles = provider.vehicles;

                if (provider.totalCount == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD600),
                              border: Border.all(color: black, width: borderWidth),
                              boxShadow: const [
                                BoxShadow(color: black, offset: Offset(4, 4), blurRadius: 0),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_bus_outlined,
                              size: 56,
                              color: black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: black, width: 2),
                            ),
                            child: const Text(
                              'NO VEHICLES YET',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tap + to add your first vehicle',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (vehicles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: black, width: borderWidth),
                              boxShadow: const [
                                BoxShadow(color: black, offset: Offset(3, 3), blurRadius: 0),
                              ],
                            ),
                            child: const Icon(
                              Icons.search_off,
                              size: 48,
                              color: black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'NO MATCHING VEHICLES',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try a different filter or search term',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: VehicleCard(
                        vehicle: vehicle,
                        onMarkPaid: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MarkPaidScreen(
                                vehicleId: vehicle.id!,
                              ),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditScreen(vehicle: vehicle),
                            ),
                          );
                        },
                        onDelete: () {
                          _confirmDelete(vehicle.id!, vehicle.reg);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          border: Border(),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditScreen()),
            );
          },
          backgroundColor: const Color(0xFFFFD600),
          foregroundColor: black,
          icon: const Icon(Icons.add, size: 28),
          label: const Text(
            'ADD VEHICLE',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
          elevation: 4,
          highlightElevation: 8,
        ),
      ),
    );
  }
}