import 'package:flutter/foundation.dart';
import '../../core/errors/error_handler.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';

/// Central state manager for reminders and expiration notifications.
class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _repository;

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  ReminderProvider({ReminderRepository? repository})
      : _repository = repository ?? LocalReminderRepository();

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ReminderModel> get pendingReminders =>
      _reminders.where((r) => !r.isCompleted).toList();

  List<ReminderModel> get completedReminders =>
      _reminders.where((r) => r.isCompleted).toList();

  int get pendingCount => pendingReminders.length;
  int get overdueCount => pendingReminders.where((r) => r.isOverdue).length;

  Future<void> loadReminders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reminders = await _repository.getAllReminders();
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('loadReminders', error: e, stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReminder(ReminderModel reminder) async {
    try {
      await _repository.createReminder(reminder);
      _reminders.add(reminder);
      _reminders.sort((a, b) => a.targetDate.compareTo(b.targetDate));
      notifyListeners();
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('createReminder', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleComplete(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final newState = !_reminders[index].isCompleted;
      final updated = _reminders[index].copyWith(isCompleted: newState);
      _reminders[index] = updated;
      notifyListeners();

      try {
        await _repository.toggleCompleted(id, newState);
        return true;
      } catch (e, stack) {
        // Revert on failure
        _reminders[index] = _reminders[index].copyWith(isCompleted: !newState);
        _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
        ErrorHandler.logSafe('toggleComplete', error: e, stackTrace: stack);
        notifyListeners();
        return false;
      }
    }
    return false;
  }

  Future<bool> deleteReminder(String id) async {
    try {
      await _repository.deleteReminder(id);
      _reminders.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e, stack) {
      _errorMessage = ErrorHandler.getUserFriendlyMessage(e);
      ErrorHandler.logSafe('deleteReminder', error: e, stackTrace: stack);
      notifyListeners();
      return false;
    }
  }
}
