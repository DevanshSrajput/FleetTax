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

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Vehicle updated successfully'
                : 'Vehicle added successfully',
          ),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Registration Number
            TextFormField(
              controller: _regController,
              decoration: InputDecoration(
                labelText: 'Registration Number',
                hintText: 'e.g., DL01AB1234',
                prefixIcon: const Icon(Icons.numbers),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter registration number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Vehicle Type
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Vehicle Type',
                prefixIcon: const Icon(Icons.directions_car),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
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

            // Last Paid Date
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: _selectLastPaidDate,
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
                              'Last Paid Date',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(_lastPaidDate),
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

            // Permit Expiry Date Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Official Permit Expiry (from Vahan 4)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the exact expiry date shown on vahan.parivahan.gov.in. This takes priority over calculated tax period.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectPermitExpiryDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_available,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _permitExpiryDate != null
                                    ? dateFormat.format(_permitExpiryDate!)
                                    : 'Not set (use calculated)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _permitExpiryDate != null
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (_permitExpiryDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: _clearPermitExpiry,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            else
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any additional notes...',
                prefixIcon: const Icon(Icons.note),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // Save Button
            FilledButton.icon(
              onPressed: _saveVehicle,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Save Changes' : 'Add Vehicle'),
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