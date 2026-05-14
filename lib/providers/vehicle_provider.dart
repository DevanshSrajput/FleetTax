import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import '../db/database_helper.dart';
import '../services/notification_service.dart';

enum VehicleFilter { all, expired, soon, valid, bus, truck }

class VehicleProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Vehicle> _vehicles = [];
  String _searchQuery = '';
  VehicleFilter _filter = VehicleFilter.all;
  String _sortBy = 'expiry'; // 'expiry', 'reg', 'type'

  List<Vehicle> get vehicles => _getFilteredVehicles();

  List<Vehicle> _getFilteredVehicles() {
    List<Vehicle> result = List.from(_vehicles);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((v) => v.reg.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply status/type filter
    switch (_filter) {
      case VehicleFilter.expired:
        result = result.where((v) => v.status == 'expired').toList();
        break;
      case VehicleFilter.soon:
        result = result.where((v) => v.status == 'soon').toList();
        break;
      case VehicleFilter.valid:
        result = result.where((v) => v.status == 'valid').toList();
        break;
      case VehicleFilter.bus:
        result = result.where((v) => v.type == 'bus').toList();
        break;
      case VehicleFilter.truck:
        result = result.where((v) => v.type == 'truck').toList();
        break;
      case VehicleFilter.all:
        break;
    }

    // Apply sorting
    switch (_sortBy) {
      case 'expiry':
        result.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
        break;
      case 'reg':
        result.sort((a, b) => a.reg.compareTo(b.reg));
        break;
      case 'type':
        result.sort((a, b) => a.type.compareTo(b.type));
        break;
    }

    return result;
  }

  // Stats
  int get totalCount => _vehicles.length;
  int get expiredCount =>
      _vehicles.where((v) => v.status == 'expired').length;
  int get dueSoonCount => _vehicles.where((v) => v.status == 'soon').length;
  int get validCount => _vehicles.where((v) => v.status == 'valid').length;

  int get busCount => _vehicles.where((v) => v.type == 'bus').length;
  int get truckCount => _vehicles.where((v) => v.type == 'truck').length;

  String get searchQuery => _searchQuery;
  VehicleFilter get filter => _filter;
  String get sortBy => _sortBy;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(VehicleFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  Future<void> load() async {
    _vehicles = await _db.getAll();
    await _checkAndNotify();
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final id = await _db.insert(vehicle);
    final newVehicle = vehicle.copyWith(id: id);
    _vehicles.add(newVehicle);
    await _checkAndNotify();
    notifyListeners();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _db.update(vehicle);
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
    }
    await _checkAndNotify();
    notifyListeners();
  }

  Future<void> deleteVehicle(int id) async {
    await _db.delete(id);
    _vehicles.removeWhere((v) => v.id == id);
    await NotificationService.cancel(id);
    notifyListeners();
  }

  Future<void> markAsPaid({
    required int vehicleId,
    required String paymentDate,
    required String taxPeriod,
    String? receiptRef,
  }) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      final updatedVehicle = _vehicles[index].copyWith(
        lastPaid: paymentDate,
        taxPeriod: taxPeriod,
        receiptRef: receiptRef,
      );
      await updateVehicle(updatedVehicle);
    }
  }

  Future<void> _checkAndNotify() async {
    for (final vehicle in _vehicles) {
      if (vehicle.id != null && vehicle.daysLeft <= 10) {
        await NotificationService.showAlert(
          vehicle.id!,
          vehicle.reg,
          vehicle.daysLeft,
        );
      }
    }
  }

  Vehicle? getVehicleById(int id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
}