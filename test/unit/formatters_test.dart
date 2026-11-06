import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/core/utils/currency_formatter.dart';
import 'package:smart_vault/core/utils/date_formatter.dart';

void main() {
  group('Formatters Unit Tests', () {
    test('CurrencyFormatter formats double values accurately', () {
      expect(CurrencyFormatter.format(1499.00, symbol: '\$'), '\$1,499.00');
      expect(CurrencyFormatter.format(0.0, symbol: '€'), '€0.00');
      expect(CurrencyFormatter.format(null, symbol: '£'), '£ 0.00');
      expect(CurrencyFormatter.format(49.999, symbol: '₹', decimalDigits: 2), '₹50.00');
    });

    test('CurrencyFormatter parses user text accurately', () {
      expect(CurrencyFormatter.parseAmount('\$1,499.50'), 1499.50);
      expect(CurrencyFormatter.parseAmount('€ 250'), 250.0);
      expect(CurrencyFormatter.parseAmount(''), isNull);
      expect(CurrencyFormatter.parseAmount(null), isNull);
    });

    test('DateFormatter formats standard and relative dates correctly', () {
      final ref = DateTime(2026, 10, 24);
      final date = DateTime(2026, 10, 24);

      expect(DateFormatter.formatDate(date), 'Oct 24, 2026');
      expect(DateFormatter.formatDate(null), 'N/A');
      expect(DateFormatter.formatDate(null, fallback: 'None'), 'None');

      expect(DateFormatter.formatRelative(date, referenceDate: ref), 'Today');
      expect(
        DateFormatter.formatRelative(ref.add(const Duration(days: 1)), referenceDate: ref),
        'Tomorrow',
      );
      expect(
        DateFormatter.formatRelative(ref.subtract(const Duration(days: 1)), referenceDate: ref),
        'Yesterday',
      );
      expect(
        DateFormatter.formatRelative(ref.add(const Duration(days: 4)), referenceDate: ref),
        'In 4 days',
      );
    });
  });
}
