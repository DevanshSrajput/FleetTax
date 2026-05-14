import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';

class AddEditScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddEditScreen({super.key, this.vehicle});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'truck';
  String _selectedTaxPeriod = 'yearly';
  DateTime _lastPaidDate = DateTime.now();
  DateTime? _permitExpiryDate;

  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _regController.text = widget.vehicle!.reg;
      _selectedType = widget.vehicle!.type;
      _selectedTaxPeriod = widget.vehicle!.taxPeriod;
      _lastPaidDate = DateTime.parse(widget.vehicle!.lastPaid);
      _notesController.text = widget.vehicle!.notes ?? '';
      if (widget.vehicle!.permitExpiry != null &&
          widget.vehicle!.permitExpiry!.isNotEmpty) {
        _permitExpiryDate = DateTime.parse(widget.vehicle!.permitExpiry!);
      }
    }
  }

  @override
  void dispose() {
    _regController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectLastPaidDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPaidDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lastPaidDate = picked;
      });
    }
  }

  Future<void> _selectPermitExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _permitExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _permitExpiryDate = picked;
      });
    }
  }

  void _clearPermitExpiry() {
    setState(() {
      _permitExpiryDate = null;
    });
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<VehicleProvider>();
      final dateFormat = DateFormat('yyyy-MM-dd');

      String? permitExpiryString;
      if (_permitExpiryDate != null) {
        permitExpiryString = dateFormat.format(_permitExpiryDate!);
      }

      if (isEditing) {
        final updatedVehicle = widget.vehicle!.copyWith(
          reg: _regController.text.trim().toUpperCase(),
          type: _selectedType,
          taxPeriod: _selectedTaxPeriod,
          lastPaid: dateFormat.format(_lastPaidDate),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          permitExpiry: permitExpiryString,
        );
        provider.updateVehicle(updatedVehicle);
      } else {
        final newVehicle = Vehicle(
          reg: _regController.text.trim().toUpperCase(),
          type: _selectedType,
          taxPeriod: _selectedTaxPeriod,
          lastPaid: dateFormat.format(_lastPaidDate),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: DateTime.now().toIso8601String(),
          permitExpiry: permitExpiryString,
        );
        provider.addVehicle(newVehicle);
      }

      // Show snackbar BEFORE popping, as context becomes invalid after pop
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Vehicle updated successfully'
                : 'Vehicle added successfully',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF00E676),
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF000000);
    const borderWidth = 3.0;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'EDIT VEHICLE' : 'ADD VEHICLE',
          style: const TextStyle(
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
            // Registration Number
            TextFormField(
              controller: _regController,
              decoration: InputDecoration(
                labelText: 'REGISTRATION NUMBER',
                hintText: 'e.g., DL01AB1234',
                prefixIcon: const Icon(Icons.numbers, color: black),
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
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter registration number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Vehicle Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'VEHICLE TYPE',
                prefixIcon: const Icon(Icons.directions_car, color: black),
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
                DropdownMenuItem(value: 'truck', child: Text('TRUCK', style: TextStyle(fontWeight: FontWeight.w800))),
                DropdownMenuItem(value: 'bus', child: Text('BUS', style: TextStyle(fontWeight: FontWeight.w800))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
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

            // Last Paid Date
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: black, width: borderWidth),
              ),
              child: InkWell(
                onTap: _selectLastPaidDate,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD600),
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
                              'LAST PAID DATE',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(_lastPaidDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
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

            // Permit Expiry Date
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600).withValues(alpha: 0.2),
                border: Border.all(color: black, width: borderWidth),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD600),
                            border: Border.all(color: black, width: 2),
                          ),
                          child: const Icon(Icons.verified_user, color: black, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'OFFICIAL PERMIT EXPIRY (FROM VAHAN 4)',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the exact expiry date shown on vahan.parivahan.gov.in. This takes priority over calculated tax period.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectPermitExpiryDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: black, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_available, color: black),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _permitExpiryDate != null
                                    ? dateFormat.format(_permitExpiryDate!)
                                    : 'NOT SET (USE CALCULATED)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _permitExpiryDate != null
                                      ? black
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                            if (_permitExpiryDate != null)
                              GestureDetector(
                                onTap: _clearPermitExpiry,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF0044),
                                    border: Border.all(color: black, width: 2),
                                  ),
                                  child: const Icon(Icons.clear, color: Colors.white, size: 16),
                                ),
                              )
                            else
                              const Icon(Icons.arrow_forward_ios, color: black, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'NOTES (OPTIONAL)',
                hintText: 'Any additional notes...',
                prefixIcon: const Icon(Icons.note, color: black),
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
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: black, offset: Offset(4, 4), blurRadius: 0),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD600),
                  foregroundColor: black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  side: const BorderSide(color: black, width: borderWidth),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isEditing ? Icons.save : Icons.add, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'SAVE CHANGES' : 'ADD VEHICLE',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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