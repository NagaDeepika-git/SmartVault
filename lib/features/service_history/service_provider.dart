import 'package:flutter/foundation.dart';
import '../../core/errors/error_handler.dart';
import '../../data/models/service_record_model.dart';
import '../../data/repositories/service_repository.dart';

/// Central state manager for product service records and maintenance history.
class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _repository;

  List<ServiceRecordModel> _records = [];
  bool _isLoading = false;
  String? _errorMessage;

  ServiceProvider({ServiceRepository? repository})
      : _repository = repository ?? LocalServiceRepository();

  List<ServiceRecordModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ServiceRecordModel> recordsForProduct(String productId) {
    return _records.where((r) => r.productId == productId).toList();
  }

  double totalCostForProduct(String productId) {
    return _records
        .where((r) => r.productId == productId)
        .fold<double>(0.0, (sum, r) => sum + r.cost);
  }

  double get totalOverallServiceCost {
    return _records.fold<double>(0.0, (sum, r) => sum + r.cost);
  }

  Future<void> loadRecordsForProduct(String productId) async {
    await loadAllRecords();
  }

  Future<void> loadAllRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _repository.getAllServiceRecords();
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('loadAllRecords', error: e, stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRecord(ServiceRecordModel record) async {
    try {
      await _repository.createServiceRecord(record);
      _records.insert(0, record);
      notifyListeners();
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('createRecord', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRecord(ServiceRecordModel record) async {
    try {
      await _repository.updateServiceRecord(record);
      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = record;
        notifyListeners();
      }
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('updateRecord', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      await _repository.deleteServiceRecord(id);
      _records.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('deleteRecord', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }
}
