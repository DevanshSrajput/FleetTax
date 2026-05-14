import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';

class VehicleCard extends StatefulWidget {
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

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.vehicle.daysLeft < 0) return const Color(0xFFBA1A1A);
    if (widget.vehicle.daysLeft <= 10) return const Color(0xFF8B5E00);
    return const Color(0xFF1B8B47);
  }

  String _getStatusText() {
    final daysLeft = widget.vehicle.daysLeft;
    if (daysLeft < 0) {
      return 'Expired ${daysLeft.abs()} days ago';
    } else if (daysLeft == 0) {
      return 'Expires today!';
    } else if (daysLeft == 1) {
      return 'Expires tomorrow';
    } else if (daysLeft <= 10) {
      return 'Due in $daysLeft days';
    } else {
      return 'Valid $daysLeft days';
    }
  }

  String _getExpiryText(DateFormat dateFormat) {
    final expiryFormatted = dateFormat.format(widget.vehicle.expiryDate);
    if (widget.vehicle.daysLeft < 0) {
      return 'Expired on $expiryFormatted';
    } else {
      return 'Expires: $expiryFormatted';
    }
  }

  IconData _getVehicleIcon() {
    return widget.vehicle.type == 'bus'
        ? Icons.directions_bus
        : Icons.local_shipping;
  }

  String _getTaxPeriodLabel() {
    switch (widget.vehicle.taxPeriod) {
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'yearly':
        return 'Yearly';
      default:
        return widget.vehicle.taxPeriod;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();
    final dateFormat = DateFormat('dd MMM yyyy');

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 1,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: statusColor, width: 5),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Status indicator avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getVehicleIcon(),
                          color: statusColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Vehicle info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vehicle.reg.toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildInfoChip(
                                  context: context,
                                  icon: widget.vehicle.type == 'bus'
                                      ? Icons.directions_bus
                                      : Icons.local_shipping,
                                  label: widget.vehicle.type.toUpperCase(),
                                ),
                                const SizedBox(width: 12),
                                _buildInfoChip(
                                  context: context,
                                  icon: Icons.calendar_month,
                                  label: _getTaxPeriodLabel(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Last paid: ${dateFormat.format(DateTime.parse(widget.vehicle.lastPaid))}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getExpiryText(dateFormat),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Notes section
                if (widget.vehicle.notes != null &&
                    widget.vehicle.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.vehicle.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (widget.vehicle.receiptRef != null &&
                    widget.vehicle.receiptRef!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Receipt: ${widget.vehicle.receiptRef}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: widget.onMarkPaid,
                        icon: const Icon(Icons.payments, size: 18),
                        label: const Text('Mark Paid'),
                        style: FilledButton.styleFrom(
                          foregroundColor: const Color(0xFF1B8B47),
                          backgroundColor: const Color(0xFF1B8B47).withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: widget.onEdit,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 4),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onDelete,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFBA1A1A),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 18),
                            SizedBox(width: 4),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}