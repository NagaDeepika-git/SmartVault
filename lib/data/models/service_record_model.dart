import 'package:uuid/uuid.dart';

/// Service and repair history record associated with a tracked product.
class ServiceRecordModel {
  final String id;
  final String productId;
  final DateTime serviceDate;
  final String serviceProvider;
  final String issueDescription;
  final double cost;
  final String? resolution;
  final DateTime? nextMaintenanceDate;
  final String? receiptPath;
  final bool isSample;
  final DateTime createdAt;

  ServiceRecordModel({
    String? id,
    required this.productId,
    required this.serviceDate,
    required this.serviceProvider,
    required this.issueDescription,
    required this.cost,
    this.resolution,
    this.nextMaintenanceDate,
    this.receiptPath,
    this.isSample = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get hasReceipt => receiptPath != null && receiptPath!.isNotEmpty;

  ServiceRecordModel copyWith({
    String? id,
    String? productId,
    DateTime? serviceDate,
    String? serviceProvider,
    String? issueDescription,
    double? cost,
    String? resolution,
    DateTime? nextMaintenanceDate,
    String? receiptPath,
    bool? isSample,
    DateTime? createdAt,
  }) {
    return ServiceRecordModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      serviceDate: serviceDate ?? this.serviceDate,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      issueDescription: issueDescription ?? this.issueDescription,
      cost: cost ?? this.cost,
      resolution: resolution ?? this.resolution,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      receiptPath: receiptPath ?? this.receiptPath,
      isSample: isSample ?? this.isSample,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'service_date': serviceDate.toIso8601String(),
      'service_provider': serviceProvider,
      'issue_description': issueDescription,
      'cost': cost,
      'resolution': resolution,
      'next_maintenance_date': nextMaintenanceDate?.toIso8601String(),
      'receipt_path': receiptPath,
      'is_sample': isSample ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ServiceRecordModel.fromMap(Map<String, dynamic> map) {
    return ServiceRecordModel(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      serviceDate: DateTime.parse(map['service_date'] as String),
      serviceProvider: map['service_provider'] as String,
      issueDescription: map['issue_description'] as String,
      cost: (map['cost'] as num).toDouble(),
      resolution: map['resolution'] as String?,
      nextMaintenanceDate: map['next_maintenance_date'] != null
          ? DateTime.tryParse(map['next_maintenance_date'] as String)
          : null,
      receiptPath: map['receipt_path'] as String?,
      isSample: (map['is_sample'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }
}
