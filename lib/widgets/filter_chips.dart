import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF000000);

    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildChip(
                context: context,
                label: 'ALL',
                isSelected: provider.filter == VehicleFilter.all,
                onSelected: () => provider.setFilter(VehicleFilter.all),
                color: const Color(0xFFFFD600),
              ),
              const SizedBox(width: 6),
              _buildChip(
                context: context,
                label: 'EXPIRED',
                isSelected: provider.filter == VehicleFilter.expired,
                onSelected: () => provider.setFilter(VehicleFilter.expired),
                color: const Color(0xFFFF0044),
              ),
              const SizedBox(width: 6),
              _buildChip(
                context: context,
                label: 'DUE SOON',
                isSelected: provider.filter == VehicleFilter.soon,
                onSelected: () => provider.setFilter(VehicleFilter.soon),
                color: const Color(0xFFFF6B00),
              ),
              const SizedBox(width: 6),
              _buildChip(
                context: context,
                label: 'VALID',
                isSelected: provider.filter == VehicleFilter.valid,
                onSelected: () => provider.setFilter(VehicleFilter.valid),
                color: const Color(0xFF00D676),
              ),
              const SizedBox(width: 6),
              _buildChip(
                context: context,
                label: 'BUS',
                isSelected: provider.filter == VehicleFilter.bus,
                onSelected: () => provider.setFilter(VehicleFilter.bus),
                color: const Color(0xFF00D9FF),
                icon: Icons.directions_bus,
              ),
              const SizedBox(width: 6),
              _buildChip(
                context: context,
                label: 'TRUCK',
                isSelected: provider.filter == VehicleFilter.truck,
                onSelected: () => provider.setFilter(VehicleFilter.truck),
                color: const Color(0xFFFF6B35),
                icon: Icons.local_shipping,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Color color,
    IconData? icon,
  }) {
    const black = Color(0xFF000000);
    const borderWidth = 2.0;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: black, width: borderWidth),
          boxShadow: isSelected
              ? []
              : const [
                  BoxShadow(color: black, offset: Offset(2, 2), blurRadius: 0),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: black,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: isSelected ? black : black.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}