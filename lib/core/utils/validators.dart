/// Reusable form field validators for SmartVault.
/// Ensures rigorous input validation with helpful error messages across all forms.
class Validators {
  Validators._();

  /// Validates that a string field is not null or empty.
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates numeric inputs (such as prices, costs, and durations).
  static String? numeric(String? value, String fieldName, {bool allowZero = true}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final clean = value.trim().replaceAll(RegExp(r'[\$,€£¥\s]'), '');
    final number = double.tryParse(clean);
    if (number == null) {
      return 'Please enter a valid numeric value for $fieldName';
    }
    if (!allowZero && number <= 0) {
      return '$fieldName must be greater than zero';
    }
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  /// Validates optional numeric inputs. If empty, passes; if filled, validates numeric.
  static String? optionalNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return null;
    return numeric(value, fieldName);
  }

  /// Validates a 4-digit PIN for security lock.
  static String? pin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN is required';
    }
    final regex = RegExp(r'^[0-9]{4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'PIN must be exactly 4 digits';
    }
    return null;
  }

  /// Validates date sequence (e.g. warranty start vs end date).
  static String? dateOrder({
    required DateTime? start,
    required DateTime? end,
    String message = 'End date must be after start date',
  }) {
    if (start != null && end != null) {
      final normStart = DateTime(start.year, start.month, start.day);
      final normEnd = DateTime(end.year, end.month, end.day);
      if (normEnd.isBefore(normStart)) {
        return message;
      }
    }
    return null;
  }
}
