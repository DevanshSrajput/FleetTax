import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/vehicle_provider.dart';

class MarkPaidScreen extends StatefulWidget {
  final int vehicleId;

  const MarkPaidScreen({super.key, required this.vehicleId});

  @override
  State<MarkPaidScreen> createState() => _MarkPaidScreenState();
}

class _MarkPaidScreenState extends State<MarkPaidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiptRefController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  String _selectedTaxPeriod = 'yearly';

  @override
  void initState() {
    super.initState();
    final provider = context.read<VehicleProvider>();
    final vehicle = provider.getVehicleById(widget.vehicleId);
    if (vehicle != null) {
      _selectedTaxPeriod = vehicle.taxPeriod;
    }
  }

  @override
  void dispose() {
    _receiptRefController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  void _markAsPaid() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<VehicleProvider>();
      final dateFormat = DateFormat('yyyy-MM-dd');

      provider.markAsPaid(
        vehicleId: widget.vehicleId,
        paymentDate: dateFormat.format(_paymentDate),
        taxPeriod: _selectedTaxPeriod,
        receiptRef: _receiptRefController.text.trim().isEmpty
            ? null
            : _receiptRefController.text.trim(),
      );

      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment recorded successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1B8B47),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final provider = context.read<VehicleProvider>();
    final vehicle = provider.getVehicleById(widget.vehicleId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark as Paid'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (vehicle != null) ...[
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          vehicle.type == 'bus'
                              ? Icons.directions_bus
                              : Icons.local_shipping,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.reg.toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${vehicle.type.toUpperCase()} - ${vehicle.taxPeriod}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Payment Date
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Date',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(_paymentDate),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tax Period
            DropdownButtonFormField<String>(
              initialValue: _selectedTaxPeriod,
              decoration: InputDecoration(
                labelText: 'Tax Period',
                prefixIcon: const Icon(Icons.calendar_month),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
              ),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTaxPeriod = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Receipt Reference
            TextFormField(
              controller: _receiptRefController,
              decoration: InputDecoration(
                labelText: 'Receipt Reference (optional)',
                hintText: 'e.g., RECPT-2025-001234',
                prefixIcon: const Icon(Icons.receipt),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The expiry date will be recalculated based on the payment date and tax period.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Mark Paid Button
            FilledButton.icon(
              onPressed: _markAsPaid,
              icon: const Icon(Icons.payments),
              label: const Text('Confirm Payment'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}