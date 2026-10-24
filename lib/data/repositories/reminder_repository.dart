import '../datasources/local_database_service.dart';
import '../models/reminder_model.dart';

/// Repository interface and local database implementation for Reminder management.
abstract class ReminderRepository {
  Future<List<ReminderModel>> getAllReminders();
  Future<List<ReminderModel>> getPendingReminders();
  Future<List<ReminderModel>> getCompletedReminders();
  Future<ReminderModel?> getReminderById(String id);
  Future<void> createReminder(ReminderModel reminder);
  Future<void> updateReminder(ReminderModel reminder);
  Future<void> deleteReminder(String id);
  Future<void> toggleCompleted(String id, bool isCompleted);
}

class LocalReminderRepository implements ReminderRepository {
  final LocalDatabaseService _dbService;

  LocalReminderRepository({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService.instance;

  @override
  Future<List<ReminderModel>> getAllReminders() async {
    final maps = await _dbService.query(
      LocalDatabaseService.tableReminders,
      orderBy: 'target_date',
      descending: false,
    );
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  @override
  Future<List<ReminderModel>> getPendingReminders() async {
    final all = await getAllReminders();
    return all.where((r) => !r.isCompleted).toList();
  }

  @override
  Future<List<ReminderModel>> getCompletedReminders() async {
    final all = await getAllReminders();
    return all.where((r) => r.isCompleted).toList();
  }

  @override
  Future<ReminderModel?> getReminderById(String id) async {
    final all = await getAllReminders();
    try {
      return all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createReminder(ReminderModel reminder) async {
    await _dbService.insert(
      LocalDatabaseService.tableReminders,
      reminder.toMap(),
    );
  }

  @override
  Future<void> updateReminder(ReminderModel reminder) async {
    await _dbService.update(
      LocalDatabaseService.tableReminders,
      reminder.toMap(),
      id: reminder.id,
    );
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _dbService.delete(
      LocalDatabaseService.tableReminders,
      id: id,
    );
  }

  @override
  Future<void> toggleCompleted(String id, bool isCompleted) async {
    final reminder = await getReminderById(id);
    if (reminder != null) {
      final updated = reminder.copyWith(isCompleted: isCompleted);
      await updateReminder(updated);
    }
  }
}
