import 'package:uuid/uuid.dart';

/// Categories of reminders in SmartVault.
enum ReminderType {
  warrantyExpiry('Warranty Expiration'),
  documentExpiry('Document Expiration'),
  maintenance('Scheduled Maintenance'),
  serviceAppointment('Service Appointment');

  final String label;
  const ReminderType(this.label);

  static ReminderType fromString(String? value) {
    if (value == null) return ReminderType.maintenance;
    return ReminderType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ReminderType.maintenance,
    );
  }
}

/// Reminder entity for tracking upcoming expirations, service tasks, and renewals.
class ReminderModel {
  final String id;
  final String title;
  final String? description;
  final ReminderType type;
  final DateTime targetDate;
  final String? relatedId; // Document ID or Product ID
  final String? relatedType; // 'document' or 'product'
  final bool isCompleted;
  final DateTime createdAt;

  ReminderModel({
    String? id,
    required this.title,
    this.description,
    required this.type,
    required this.targetDate,
    this.relatedId,
    this.relatedType,
    this.isCompleted = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return !isCompleted && target.isBefore(today);
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    DateTime? targetDate,
    String? relatedId,
    String? relatedType,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetDate: targetDate ?? this.targetDate,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'target_date': targetDate.toIso8601String(),
      'related_id': relatedId,
      'related_type': relatedType,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: ReminderType.fromString(map['type'] as String?),
      targetDate: DateTime.parse(map['target_date'] as String),
      relatedId: map['related_id'] as String?,
      relatedType: map['related_type'] as String?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }
}
