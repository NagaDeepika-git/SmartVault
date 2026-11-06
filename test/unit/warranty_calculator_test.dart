import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/core/utils/warranty_calculator.dart';

void main() {
  group('WarrantyCalculator Unit Tests', () {
    final fixedRef = DateTime(2026, 10, 24);

    test('Null warranty expiration returns unknown status', () {
      final result = WarrantyCalculator.calculate(
        startDate: DateTime(2025, 1, 1),
        endDate: null,
        referenceDate: fixedRef,
      );

      expect(result.status, WarrantyStatus.unknown);
      expect(result.remainingDays, isNull);
      expect(result.progress, 0.0);
      expect(result.statusLabel, 'No Warranty');
    });

    test('Warranty expiring far in future (>30 days) returns active', () {
      final startDate = DateTime(2026, 1, 1);
      final endDate = DateTime(2027, 1, 1);
      final result = WarrantyCalculator.calculate(
        startDate: startDate,
        endDate: endDate,
        referenceDate: fixedRef,
      );

      expect(result.status, WarrantyStatus.active);
      expect(result.isActive, true);
      expect(result.isExpired, false);
      expect(result.remainingDays, greaterThan(30));
      expect(result.progress, inInclusiveRange(0.0, 1.0));
      expect(result.statusLabel, contains('days remaining'));
    });

    test('Warranty expiring in exactly 30 days returns expiringSoon', () {
      final startDate = DateTime(2025, 10, 24);
      final endDate = fixedRef.add(const Duration(days: 30));
      final result = WarrantyCalculator.calculate(
        startDate: startDate,
        endDate: endDate,
        referenceDate: fixedRef,
      );

      expect(result.status, WarrantyStatus.expiringSoon);
      expect(result.isExpiringSoon, true);
      expect(result.remainingDays, 30);
    });

    test('Warranty expiring in 5 days returns expiringSoon', () {
      final startDate = DateTime(2025, 10, 24);
      final endDate = fixedRef.add(const Duration(days: 5));
      final result = WarrantyCalculator.calculate(
        startDate: startDate,
        endDate: endDate,
        referenceDate: fixedRef,
      );

      expect(result.status, WarrantyStatus.expiringSoon);
      expect(result.remainingDays, 5);
      expect(result.statusLabel, 'Expires in 5 days');
    });

    test('Warranty expiring today (0 days remaining) returns expiringSoon', () {
      final startDate = DateTime(2025, 10, 24);
      final endDate = fixedRef; // same day
      final result = WarrantyCalculator.calculate(
        startDate: startDate,
        endDate: endDate,
        referenceDate: fixedRef,
      );

      expect(result.status, WarrantyStatus.expiringSoon);
      expect(result.remainingDays, 0);
      expect(result.statusLabel, 'Expires Today');
    });

    test('Warranty expired in the past returns expired', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2025, 1, 1);
      final result = WarrantyCalculator.calculate(
        startDate: startDate,
        endDate: endDate,
        referenceDate: fixedRef,
      );

      expect(result.status, WarrantyStatus.expired);
      expect(result.isExpired, true);
      expect(result.progress, 1.0);
      expect(result.statusLabel, contains('Expired'));
    });

    test('Custom warning threshold honors custom window', () {
      final startDate = DateTime(2025, 1, 1);
      final endDate = fixedRef.add(const Duration(days: 45));

      // With default 30 days: active
      final defaultResult = WarrantyCalculator.calculate(
        startDate: startDate,
        endDate: endDate,
        referenceDate: fixedRef,
        expiringSoonThresholdDays: 30,
      );
      expect(defaultResult.status, WarrantyStatus.active);

      // With custom 60 days: expiringSoon
      final customResult = WarrantyCalculator.calculate(
        startDate: startDate,
        endDate: endDate,
        referenceDate: fixedRef,
        expiringSoonThresholdDays: 60,
      );
      expect(customResult.status, WarrantyStatus.expiringSoon);
    });
  });
}
