import 'package:intl/intl.dart';

/// Centralized date formatting and ISO conversion utilities.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _standardDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _shortDate = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthYear = DateFormat('MMM yyyy');
  static final DateFormat _dateTime = DateFormat('MMM dd, yyyy • hh:mm a');

  /// Formats date to "Oct 24, 2026" or returns fallback if null.
  static String formatDate(DateTime? date, {String fallback = 'N/A'}) {
    if (date == null) return fallback;
    return _standardDate.format(date);
  }

  /// Formats date to "24/10/2026".
  static String formatShortDate(DateTime? date, {String fallback = 'N/A'}) {
    if (date == null) return fallback;
    return _shortDate.format(date);
  }

  /// Formats month and year to "Oct 2026".
  static String formatMonthYear(DateTime? date, {String fallback = 'N/A'}) {
    if (date == null) return fallback;
    return _monthYear.format(date);
  }

  /// Formats to "Oct 24, 2026 • 11:30 AM".
  static String formatDateTime(DateTime? dateTime, {String fallback = 'N/A'}) {
    if (dateTime == null) return fallback;
    return _dateTime.format(dateTime);
  }

  /// Human-friendly relative date representation (e.g. "Today", "Tomorrow", "In 5 days", "3 days ago").
  static String formatRelative(DateTime? date, {DateTime? referenceDate}) {
    if (date == null) return 'No Date';

    final ref = referenceDate ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Tomorrow';
    if (diffDays == -1) return 'Yesterday';
    if (diffDays > 1 && diffDays < 7) return 'In $diffDays days';
    if (diffDays >= 7 && diffDays < 30) {
      final weeks = (diffDays / 7).floor();
      return 'In $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    }
    if (diffDays < -1 && diffDays > -7) return '${diffDays.abs()} days ago';
    if (diffDays <= -7 && diffDays > -30) {
      final weeks = (diffDays.abs() / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }

    return _standardDate.format(date);
  }
}
