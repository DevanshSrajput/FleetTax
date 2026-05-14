import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildChip(
                context: context,
                label: 'All',
                isSelected: provider.filter == VehicleFilter.all,
                onSelected: () => provider.setFilter(VehicleFilter.all),
              ),
              const SizedBox(width: 8),
              _buildChip(
                context: context,
                label: 'Expired',
                isSelected: provider.filter == VehicleFilter.expired,
                onSelected: () => provider.setFilter(VehicleFilter.expired),
                color: const Color(0xFFBA1A1A),
              ),
              const SizedBox(width: 8),
              _buildChip(
                context: context,
                label: 'Due Soon',
                isSelected: provider.filter == VehicleFilter.soon,
                onSelected: () => provider.setFilter(VehicleFilter.soon),
                color: const Color(0xFF8B5E00),
              ),
              const SizedBox(width: 8),
              _buildChip(
                context: context,
                label: 'Valid',
                isSelected: provider.filter == VehicleFilter.valid,
                onSelected: () => provider.setFilter(VehicleFilter.valid),
                color: const Color(0xFF1B8B47),
              ),
              const SizedBox(width: 8),
              _buildChip(
                context: context,
                label: 'Bus',
                isSelected: provider.filter == VehicleFilter.bus,
                onSelected: () => provider.setFilter(VehicleFilter.bus),
                icon: Icons.directions_bus,
              ),
              const SizedBox(width: 8),
              _buildChip(
                context: context,
                label: 'Truck',
                isSelected: provider.filter == VehicleFilter.truck,
                onSelected: () => provider.setFilter(VehicleFilter.truck),
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
    Color? color,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: chipColor,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: isSelected
          ? BorderSide.none
          : BorderSide(color: chipColor.withValues(alpha: 0.4)),
      backgroundColor: theme.colorScheme.surface,
      elevation: isSelected ? 0 : 1,
      shadowColor: Colors.black12,
    );
  }
}