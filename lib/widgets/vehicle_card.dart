import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onMarkPaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onMarkPaid,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor() {
    if (vehicle.daysLeft < 0) return Colors.red;
    if (vehicle.daysLeft <= 10) return Colors.amber;
    return Colors.green;
  }

  String _getStatusText() {
    if (vehicle.daysLeft < 0) {
      return 'Expired ${vehicle.daysLeft.abs()} days ago';
    } else if (vehicle.daysLeft == 0) {
      return 'Expires today!';
    } else if (vehicle.daysLeft == 1) {
      return 'Expires tomorrow';
    } else if (vehicle.daysLeft <= 10) {
      return 'Due in ${vehicle.daysLeft} days';
    } else {
      return 'Valid ${vehicle.daysLeft} days';
    }
  }

  String _getExpiryText(DateFormat dateFormat) {
    final expiryFormatted = dateFormat.format(vehicle.expiryDate);
    if (vehicle.daysLeft < 0) {
      return 'Expired on $expiryFormatted';
    } else {
      return 'Expires: $expiryFormatted';
    }
  }

  IconData _getVehicleIcon() {
    return vehicle.type == 'bus' ? Icons.directions_bus : Icons.local_shipping;
  }

  String _getTaxPeriodLabel() {
    switch (vehicle.taxPeriod) {
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'yearly':
        return 'Yearly';
      default:
        return vehicle.taxPeriod;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: statusColor, width: 5),
          ),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.15),
                child: Icon(
                  _getVehicleIcon(),
                  color: statusColor,
                ),
              ),
              title: Text(
                vehicle.reg.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: vehicle.type == 'bus'
                            ? Icons.directions_bus
                            : Icons.local_shipping,
                        label: vehicle.type.toUpperCase(),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.calendar_today,
                        label: _getTaxPeriodLabel(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last paid: ${dateFormat.format(DateTime.parse(vehicle.lastPaid))}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getExpiryText(dateFormat),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            if (vehicle.notes != null && vehicle.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    vehicle.notes!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            if (vehicle.receiptRef != null && vehicle.receiptRef!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Receipt: ${vehicle.receiptRef}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.payments, size: 18),
                    label: const Text('Mark Paid'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}