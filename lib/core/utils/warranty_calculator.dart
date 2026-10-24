/// Warranty status classification for products.
enum WarrantyStatus {
  active,
  expiringSoon,
  expired,
  unknown,
}

/// Result object holding calculated warranty metrics.
class WarrantyResult {
  final WarrantyStatus status;
  final int? remainingDays;
  final int? totalDays;
  final double progress; // 0.0 (just started) to 1.0 (expired)
  final String statusLabel;

  const WarrantyResult({
    required this.status,
    required this.remainingDays,
    required this.totalDays,
    required this.progress,
    required this.statusLabel,
  });

  bool get isActive => status == WarrantyStatus.active || status == WarrantyStatus.expiringSoon;
  bool get isExpiringSoon => status == WarrantyStatus.expiringSoon;
  bool get isExpired => status == WarrantyStatus.expired;
  bool get isUnknown => status == WarrantyStatus.unknown;
}

/// Pure utility class for robust date-based warranty calculations and boundary condition handling.
class WarrantyCalculator {
  WarrantyCalculator._();

  /// Default threshold in days to flag a warranty as "expiring soon".
  static const int defaultExpiringSoonThresholdDays = 30;

  /// Calculates complete warranty status given start date, end date, and an optional reference date.
  /// Uses [referenceDate] (defaults to current date at 00:00:00) to allow deterministic unit testing.
  static WarrantyResult calculate({
    DateTime? startDate,
    DateTime? endDate,
    int expiringSoonThresholdDays = defaultExpiringSoonThresholdDays,
    DateTime? referenceDate,
  }) {
    if (endDate == null) {
      return const WarrantyResult(
        status: WarrantyStatus.unknown,
        remainingDays: null,
        totalDays: null,
        progress: 0.0,
        statusLabel: 'No Warranty',
      );
    }

    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    final normalizedStart = startDate != null
        ? DateTime(startDate.year, startDate.month, startDate.day)
        : null;

    // Boundary check: End date is strictly before today => Expired
    final difference = normalizedEnd.difference(today).inDays;

    if (difference < 0) {
      return WarrantyResult(
        status: WarrantyStatus.expired,
        remainingDays: difference, // negative value indicating how many days ago it expired
        totalDays: normalizedStart != null
            ? normalizedEnd.difference(normalizedStart).inDays
            : null,
        progress: 1.0,
        statusLabel: 'Expired ${difference.abs()} ${difference.abs() == 1 ? 'day' : 'days'} ago',
      );
    }

    // Boundary check: End date is today (difference == 0) => Expiring today
    if (difference == 0) {
      return const WarrantyResult(
        status: WarrantyStatus.expiringSoon,
        remainingDays: 0,
        totalDays: null,
        progress: 1.0,
        statusLabel: 'Expires Today',
      );
    }

    // Calculate total duration and progress if start date is available
    double calculatedProgress = 0.0;
    int? totalDays;
    if (normalizedStart != null) {
      totalDays = normalizedEnd.difference(normalizedStart).inDays;
      if (totalDays > 0) {
        final elapsed = today.difference(normalizedStart).inDays;
        calculatedProgress = (elapsed / totalDays).clamp(0.0, 1.0);
      }
    }

    // Flag as Expiring Soon if within configured threshold
    if (difference <= expiringSoonThresholdDays) {
      return WarrantyResult(
        status: WarrantyStatus.expiringSoon,
        remainingDays: difference,
        totalDays: totalDays,
        progress: calculatedProgress,
        statusLabel: 'Expires in $difference ${difference == 1 ? 'day' : 'days'}',
      );
    }

    // Active
    return WarrantyResult(
      status: WarrantyStatus.active,
      remainingDays: difference,
      totalDays: totalDays,
      progress: calculatedProgress,
      statusLabel: '$difference days remaining',
    );
  }
}
