import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/vehicle.dart';
import '../db/database_helper.dart';
import '../services/notification_service.dart';

enum VehicleFilter { all, expired, soon, valid, bus, truck }

class VehicleProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Vehicle> _vehicles = [];
  String _searchQuery = '';
  VehicleFilter _filter = VehicleFilter.all;
  String _sortBy = 'expiry';

  // Cached filtered/sorted results
  List<Vehicle>? _cachedVehicles;
  int? _cachedTotalCount;
  int? _cachedExpiredCount;
  int? _cachedDueSoonCount;
  int? _cachedValidCount;

  void _invalidateCache() {
    _cachedVehicles = null;
    _cachedTotalCount = null;
    _cachedExpiredCount = null;
    _cachedDueSoonCount = null;
    _cachedValidCount = null;
  }

  List<Vehicle> get vehicles {
    if (_cachedVehicles != null) return _cachedVehicles!;
    _cachedVehicles = _getFilteredVehicles();
    return _cachedVehicles!;
  }

  List<Vehicle> _getFilteredVehicles() {
    List<Vehicle> result = List.from(_vehicles);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((v) => v.reg.toLowerCase().contains(query)).toList();
    }

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

  int get totalCount {
    _cachedTotalCount ??= _vehicles.length;
    return _cachedTotalCount!;
  }

  int get expiredCount {
    _cachedExpiredCount ??= _vehicles.where((v) => v.status == 'expired').length;
    return _cachedExpiredCount!;
  }

  int get dueSoonCount {
    _cachedDueSoonCount ??= _vehicles.where((v) => v.status == 'soon').length;
    return _cachedDueSoonCount!;
  }

  int get validCount {
    _cachedValidCount ??= _vehicles.where((v) => v.status == 'valid').length;
    return _cachedValidCount!;
  }

  int get busCount => _vehicles.where((v) => v.type == 'bus').length;
  int get truckCount => _vehicles.where((v) => v.type == 'truck').length;

  String get searchQuery => _searchQuery;
  VehicleFilter get filter => _filter;
  String get sortBy => _sortBy;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _invalidateCache();
    notifyListeners();
  }

  void setFilter(VehicleFilter filter) {
    _filter = filter;
    _invalidateCache();
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _invalidateCache();
    notifyListeners();
  }

  Future<void> load() async {
    _vehicles = await _db.getAll();
    _invalidateCache();
    // Schedule notifications on next frame to avoid blocking
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NotificationService.scheduleVehicleNotifications(_vehicles);
    });
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final id = await _db.insert(vehicle);
    final newVehicle = vehicle.copyWith(id: id);
    _vehicles.add(newVehicle);
    _invalidateCache();
    // Schedule notifications on next frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NotificationService.scheduleVehicleNotifications(_vehicles);
    });
    notifyListeners();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _db.update(vehicle);
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
    }
    _invalidateCache();
    // Schedule notifications on next frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NotificationService.scheduleVehicleNotifications(_vehicles);
    });
    notifyListeners();
  }

  Future<void> deleteVehicle(int id) async {
    await _db.delete(id);
    _vehicles.removeWhere((v) => v.id == id);
    _invalidateCache();
    // Schedule notifications on next frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NotificationService.scheduleVehicleNotifications(_vehicles);
    });
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

  Vehicle? getVehicleById(int id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
}