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
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.vehicle.daysLeft < 0) return const Color(0xFFFF0044); // Bold red
    if (widget.vehicle.daysLeft <= 10) return const Color(0xFFFF6B00); // Bold orange
    return const Color(0xFF00D676); // Bold green
  }

  String _getStatusText() {
    final daysLeft = widget.vehicle.daysLeft;
    if (daysLeft < 0) {
      return 'EXPIRED ${daysLeft.abs()} DAYS';
    } else if (daysLeft == 0) {
      return 'EXPIRES TODAY!';
    } else if (daysLeft == 1) {
      return 'EXPIRES TOMORROW';
    } else if (daysLeft <= 10) {
      return 'DUE IN $daysLeft DAYS';
    } else {
      return '$daysLeft DAYS LEFT';
    }
  }

  String _getExpiryText(DateFormat dateFormat) {
    final expiryFormatted = dateFormat.format(widget.vehicle.expiryDate);
    if (widget.vehicle.daysLeft < 0) {
      return 'EXPIRED: $expiryFormatted';
    } else {
      return 'EXPIRES: $expiryFormatted';
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
        return 'MONTHLY';
      case 'quarterly':
        return 'QUARTERLY';
      case 'yearly':
        return 'YEARLY';
      default:
        return widget.vehicle.taxPeriod.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final dateFormat = DateFormat('dd MMM yyyy');

    // Neo-brutalism colors
    const black = Color(0xFF000000);
    const borderWidth = 3.0;

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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: black, width: borderWidth),
            boxShadow: const [
              BoxShadow(color: black, offset: Offset(4, 4), blurRadius: 0),
            ],
          ),
          child: Column(
            children: [
              // Header with status stripe
              Container(
                decoration: BoxDecoration(
                  color: statusColor,
                  border: const Border(bottom: BorderSide(color: black, width: borderWidth)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.vehicle.reg.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1.5,
                        color: black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: black, width: 2),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          color: black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Vehicle icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        border: Border.all(color: black, width: 2),
                      ),
                      child: Icon(
                        _getVehicleIcon(),
                        color: black,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Vehicle info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildTag(
                                widget.vehicle.type.toUpperCase(),
                                Icons.directions_car,
                              ),
                              const SizedBox(width: 8),
                              _buildTag(
                                _getTaxPeriodLabel(),
                                Icons.calendar_month,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'LAST PAID: ${dateFormat.format(DateTime.parse(widget.vehicle.lastPaid))}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getExpiryText(dateFormat),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Notes
              if (widget.vehicle.notes != null && widget.vehicle.notes!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: black, width: 2)),
                  ),
                  child: Text(
                    'NOTE: ${widget.vehicle.notes}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              // Action buttons
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: black, width: borderWidth)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onMarkPaid,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          side: const BorderSide(color: black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payments, size: 16),
                            SizedBox(width: 4),
                            Text('MARK PAID', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 36,
                      color: black,
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onEdit,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD600),
                          side: const BorderSide(color: black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 4),
                            Text('EDIT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 36,
                      color: black,
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onDelete,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0044),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, size: 16),
                            SizedBox(width: 4),
                            Text('DELETE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, IconData icon) {
    const black = Color(0xFF000000);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: black, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: black),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}