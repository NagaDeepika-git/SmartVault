import '../datasources/local_database_service.dart';
import '../models/service_record_model.dart';

/// Repository interface and local database implementation for Service and Repair records.
abstract class ServiceRepository {
  Future<List<ServiceRecordModel>> getAllServiceRecords();
  Future<List<ServiceRecordModel>> getServiceRecordsByProductId(String productId);
  Future<ServiceRecordModel?> getServiceRecordById(String id);
  Future<void> createServiceRecord(ServiceRecordModel record);
  Future<void> updateServiceRecord(ServiceRecordModel record);
  Future<void> deleteServiceRecord(String id);
  Future<double> getTotalServiceCost({String? productId});
}

class LocalServiceRepository implements ServiceRepository {
  final LocalDatabaseService _dbService;

  LocalServiceRepository({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService.instance;

  @override
  Future<List<ServiceRecordModel>> getAllServiceRecords() async {
    final maps = await _dbService.query(
      LocalDatabaseService.tableServiceRecords,
      orderBy: 'service_date',
      descending: true,
    );
    return maps.map((map) => ServiceRecordModel.fromMap(map)).toList();
  }

  @override
  Future<List<ServiceRecordModel>> getServiceRecordsByProductId(String productId) async {
    final all = await getAllServiceRecords();
    return all.where((r) => r.productId == productId).toList();
  }

  @override
  Future<ServiceRecordModel?> getServiceRecordById(String id) async {
    final all = await getAllServiceRecords();
    try {
      return all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createServiceRecord(ServiceRecordModel record) async {
    await _dbService.insert(
      LocalDatabaseService.tableServiceRecords,
      record.toMap(),
    );
  }

  @override
  Future<void> updateServiceRecord(ServiceRecordModel record) async {
    await _dbService.update(
      LocalDatabaseService.tableServiceRecords,
      record.toMap(),
      id: record.id,
    );
  }

  @override
  Future<void> deleteServiceRecord(String id) async {
    await _dbService.delete(
      LocalDatabaseService.tableServiceRecords,
      id: id,
    );
  }

  @override
  Future<double> getTotalServiceCost({String? productId}) async {
    final records = productId != null
        ? await getServiceRecordsByProductId(productId)
        : await getAllServiceRecords();
    return records.fold<double>(0.0, (sum, item) => sum + item.cost);
  }
}
