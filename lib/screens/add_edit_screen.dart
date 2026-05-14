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
    }
  }

  @override
  void dispose() {
    _regController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
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

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<VehicleProvider>();
      final dateFormat = DateFormat('yyyy-MM-dd');

      if (isEditing) {
        final updatedVehicle = widget.vehicle!.copyWith(
          reg: _regController.text.trim().toUpperCase(),
          type: _selectedType,
          taxPeriod: _selectedTaxPeriod,
          lastPaid: dateFormat.format(_lastPaidDate),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
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
        );
        provider.addVehicle(newVehicle);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Vehicle updated successfully'
                : 'Vehicle added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Registration Number
            TextFormField(
              controller: _regController,
              decoration: const InputDecoration(
                labelText: 'Registration Number',
                hintText: 'e.g., DL01AB1234',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'truck', child: Text('Truck')),
                DropdownMenuItem(value: 'bus', child: Text('Bus')),
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

            // Last Paid Date
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Last Paid Date',
                  prefixIcon: Icon(Icons.event),
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateFormat.format(_lastPaidDate)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any additional notes...',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            FilledButton.icon(
              onPressed: _saveVehicle,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Save Changes' : 'Add Vehicle'),
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