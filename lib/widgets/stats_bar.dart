import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Neo-brutalism colors
    const black = Color(0xFF000000);
    const borderWidth = 3.0;

    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'TOTAL',
                  value: provider.totalCount,
                  color: const Color(0xFFFFD600),
                  icon: Icons.directions_bus,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _StatTile(
                  label: 'EXPIRED',
                  value: provider.expiredCount,
                  color: const Color(0xFFFF0044),
                  icon: Icons.error,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _StatTile(
                  label: 'DUE SOON',
                  value: provider.dueSoonCount,
                  color: const Color(0xFFFF6B00),
                  icon: Icons.warning,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _StatTile(
                  label: 'VALID',
                  value: provider.validCount,
                  color: const Color(0xFF00D676),
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF000000);
    const borderWidth = 3.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: black, width: borderWidth),
        boxShadow: const [
          BoxShadow(color: black, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: black, width: 2),
            ),
            child: Icon(icon, color: black, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 9,
              color: black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}