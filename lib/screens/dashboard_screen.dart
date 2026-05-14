import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/vehicle_provider.dart';
import '../services/notification_service.dart';
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
    final Uri url = Uri.parse('https://vahan.parivahan.gov.in/vahanservice/vahan/ui/statevalidation/homepage.xhtml');
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD600),
                  border: Border(bottom: BorderSide(color: black, width: borderWidth)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo and Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: black, width: borderWidth),
                            boxShadow: const [
                              BoxShadow(color: black, offset: Offset(3, 3), blurRadius: 0),
                            ],
                          ),
                          child: const Image(
                            image: AssetImage('FleetTax.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Title with gradient
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: black, width: 2),
                                boxShadow: const [
                                  BoxShadow(color: black, offset: Offset(2, 2), blurRadius: 0),
                                ],
                              ),
                              child: const Text(
                                'FLEETTAX',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  letterSpacing: 2,
                                  color: black,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0044),
                              border: Border.all(color: black, width: 2),
                            ),
                            child: const Text(
                              'TAX TRACKER',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Action Buttons Row
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.sort,
                          label: 'SORT',
                          onPressed: _showSortOptions,
                        ),
                        const SizedBox(width: 6),
                        _ActionButton(
                          icon: Icons.notifications_active,
                          label: 'ALERT',
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
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.open_in_new,
                          label: 'VAHAN',
                          onPressed: _openVahanWebsite,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          // Stats Summary Strip
          SliverToBoxAdapter(
            child: Consumer<VehicleProvider>(
              builder: (context, provider, child) {
                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: black, width: borderWidth),
                    boxShadow: const [
                      BoxShadow(color: black, offset: Offset(4, 4), blurRadius: 0),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickStat(
                        icon: Icons.directions_bus,
                        value: provider.totalCount.toString(),
                        label: 'Vehicles',
                        color: const Color(0xFFFFD600),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: black,
                      ),
                      _QuickStat(
                        icon: Icons.warning_amber,
                        value: provider.dueSoonCount.toString(),
                        label: 'Due Soon',
                        color: const Color(0xFFFF6B00),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: black,
                      ),
                      _QuickStat(
                        icon: Icons.error_outline,
                        value: provider.expiredCount.toString(),
                        label: 'Expired',
                        color: const Color(0xFFFF0044),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: black,
                      ),
                      _QuickStat(
                        icon: Icons.check_circle_outline,
                        value: provider.validCount.toString(),
                        label: 'Valid',
                        color: const Color(0xFF00D676),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Filter Chips
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: FilterChips(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // Search and Filter Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: black,
                      border: Border.all(color: black, width: 2),
                    ),
                    child: const Text(
                      'SEARCH',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Color(0xFFFFD600),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Filter by registration number...',
                        prefixIcon: const Icon(Icons.search, color: black, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: black, size: 18),
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
                          borderSide: const BorderSide(color: black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: const BorderSide(color: black, width: 3),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        context.read<VehicleProvider>().setSearchQuery(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // Vehicle List
          Consumer<VehicleProvider>(
            builder: (context, provider, child) {
              final vehicles = provider.vehicles;

              if (provider.totalCount == 0) {
                return SliverFillRemaining(
                  child: Center(
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
                  ),
                );
              }

              if (vehicles.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
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
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vehicle = vehicles[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
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
                    childCount: vehicles.length,
                  ),
                ),
              );
            },
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

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  static const black = Color(0xFF000000);

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: black, width: 2),
          ),
          child: Icon(icon, color: black, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: black,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF000000);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: black, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: black, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  color: black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}