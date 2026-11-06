import 'package:flutter_test/flutter_test.dart';
import 'package:smart_vault/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('required validator correctly flags empty and valid inputs', () {
      expect(Validators.required(null, 'Title'), 'Title is required');
      expect(Validators.required('', 'Title'), 'Title is required');
      expect(Validators.required('   ', 'Title'), 'Title is required');
      expect(Validators.required('Degree Certificate', 'Title'), isNull);
    });

    test('numeric validator checks positive and zero rules', () {
      expect(Validators.numeric(null, 'Price'), 'Price is required');
      expect(Validators.numeric('', 'Price'), 'Price is required');
      expect(Validators.numeric('abc', 'Price'), 'Please enter a valid numeric value for Price');
      expect(Validators.numeric('-15', 'Price'), 'Price cannot be negative');
      expect(Validators.numeric('0', 'Price', allowZero: false), 'Price must be greater than zero');
      expect(Validators.numeric('0', 'Price', allowZero: true), isNull);
      expect(Validators.numeric('149.99', 'Price'), isNull);
    });

    test('optionalNumeric allows empty but validates non-empty inputs', () {
      expect(Validators.optionalNumeric(null, 'Price'), isNull);
      expect(Validators.optionalNumeric('', 'Price'), isNull);
      expect(Validators.optionalNumeric('   ', 'Price'), isNull);
      expect(Validators.optionalNumeric('abc', 'Price'), 'Please enter a valid numeric value for Price');
      expect(Validators.optionalNumeric('299.50', 'Price'), isNull);
    });

    test('pin validator requires exactly 4 digits', () {
      expect(Validators.pin(null), 'PIN is required');
      expect(Validators.pin(''), 'PIN is required');
      expect(Validators.pin('12'), 'PIN must be exactly 4 digits');
      expect(Validators.pin('12345'), 'PIN must be exactly 4 digits');
      expect(Validators.pin('12a4'), 'PIN must be exactly 4 digits');
      expect(Validators.pin('1234'), isNull);
    });

    test('dateOrder validator ensures end date is after start date', () {
      final start = DateTime(2025, 1, 1);
      final validEnd = DateTime(2026, 1, 1);
      final invalidEnd = DateTime(2024, 1, 1);

      expect(Validators.dateOrder(start: start, end: validEnd), isNull);
      expect(Validators.dateOrder(start: null, end: validEnd), isNull);
      expect(Validators.dateOrder(start: start, end: null), isNull);
      expect(
        Validators.dateOrder(start: start, end: invalidEnd),
        'End date must be after start date',
      );
    });
  });
}
