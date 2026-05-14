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

      // Show snackbar BEFORE popping, as context becomes invalid after pop
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment recorded successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF00E676),
        ),
      );

      // Wait a frame for snackbar to register, then pop
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context); // Pop to dashboard
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF000000);
    const borderWidth = 3.0;
    final dateFormat = DateFormat('dd MMM yyyy');
    final provider = context.read<VehicleProvider>();
    final vehicle = provider.getVehicleById(widget.vehicleId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MARK AS PAID',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (vehicle != null) ...[
              // Vehicle Info Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: black, width: borderWidth),
                  boxShadow: const [
                    BoxShadow(color: black, offset: Offset(4, 4), blurRadius: 0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD600),
                          border: Border.all(color: black, width: borderWidth),
                        ),
                        child: Icon(
                          vehicle.type == 'bus'
                              ? Icons.directions_bus
                              : Icons.local_shipping,
                          color: black,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.reg.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: black, width: 2),
                              ),
                              child: Text(
                                '${vehicle.type.toUpperCase()} - ${vehicle.taxPeriod.toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
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
              const SizedBox(height: 20),
            ],

            // Payment Date
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: black, width: borderWidth),
              ),
              child: InkWell(
                onTap: _selectDate,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D9FF),
                          border: Border.all(color: black, width: 2),
                        ),
                        child: const Icon(Icons.event, color: black),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PAYMENT DATE',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(_paymentDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: black, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tax Period
            DropdownButtonFormField<String>(
              value: _selectedTaxPeriod,
              decoration: InputDecoration(
                labelText: 'TAX PERIOD',
                prefixIcon: const Icon(Icons.calendar_month, color: black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: const BorderSide(color: black, width: borderWidth),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: const BorderSide(color: black, width: borderWidth),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: const BorderSide(color: black, width: borderWidth),
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              items: const [
                DropdownMenuItem(value: 'monthly', child: Text('MONTHLY', style: TextStyle(fontWeight: FontWeight.w800))),
                DropdownMenuItem(value: 'quarterly', child: Text('QUARTERLY', style: TextStyle(fontWeight: FontWeight.w800))),
                DropdownMenuItem(value: 'yearly', child: Text('YEARLY', style: TextStyle(fontWeight: FontWeight.w800))),
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
              decoration: InputDecoration(
                labelText: 'RECEIPT REFERENCE (OPTIONAL)',
                hintText: 'e.g., RECPT-2025-001234',
                prefixIcon: const Icon(Icons.receipt, color: black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: const BorderSide(color: black, width: borderWidth),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: const BorderSide(color: black, width: borderWidth),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: const BorderSide(color: black, width: borderWidth),
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 20),

            // Info Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600).withValues(alpha: 0.2),
                border: Border.all(color: black, width: borderWidth),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD600),
                        border: Border.all(color: black, width: 2),
                      ),
                      child: const Icon(Icons.info_outline, color: black, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'The expiry date will be recalculated based on the payment date and tax period.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mark Paid Button
            Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: black, offset: Offset(4, 4), blurRadius: 0),
                ],
              ),
              child: ElevatedButton(
                onPressed: _markAsPaid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  side: const BorderSide(color: black, width: borderWidth),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payments, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'CONFIRM PAYMENT',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}