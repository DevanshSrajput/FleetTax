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
      Navigator.pop(context); // Also pop the dashboard to refresh

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment recorded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final provider = context.read<VehicleProvider>();
    final vehicle = provider.getVehicleById(widget.vehicleId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark as Paid'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (vehicle != null) ...[
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      vehicle.type == 'bus'
                          ? Icons.directions_bus
                          : Icons.local_shipping,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    vehicle.reg.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${vehicle.type.toUpperCase()} - ${vehicle.taxPeriod}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Payment Date
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Payment Date',
                  prefixIcon: Icon(Icons.event),
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateFormat.format(_paymentDate)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tax Period
            DropdownButtonFormField<String>(
              value: _selectedTaxPeriod,
              decoration: const InputDecoration(
                labelText: 'Tax Period',
                prefixIcon: Icon(Icons.calendar_month),
                border: OutlineInputBorder(),
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
            const SizedBox(height: 16),

            // Receipt Reference
            TextFormField(
              controller: _receiptRefController,
              decoration: const InputDecoration(
                labelText: 'Receipt Reference (optional)',
                hintText: 'e.g., RECPT-2025-001234',
                prefixIcon: Icon(Icons.receipt),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The expiry date will be recalculated based on the payment date and tax period.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mark Paid Button
            FilledButton.icon(
              onPressed: _markAsPaid,
              icon: const Icon(Icons.payments),
              label: const Text('Confirm Payment'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}