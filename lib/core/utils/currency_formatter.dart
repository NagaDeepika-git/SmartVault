import 'package:intl/intl.dart';

/// Centralized currency formatting utilities for products, purchases, and service records.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _compactCurrency = NumberFormat.compactSimpleCurrency();

  /// Formats currency with custom symbol and decimal places (e.g. "$1,499.00").
  static String format(double? amount, {String symbol = '\$', int decimalDigits = 2}) {
    if (amount == null) return '$symbol 0.00';
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigits);
    return formatter.format(amount);
  }

  /// Formats large numbers compactly (e.g. "$1.5K", "$24M").
  static String formatCompact(double? amount, {String symbol = '\$'}) {
    if (amount == null) return '$symbol 0';
    if (amount.abs() < 1000) {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
    return _compactCurrency.format(amount).replaceAll('\$', symbol);
  }

  /// Safely parses user currency text input into a double.
  static double? parseAmount(String? text) {
    if (text == null) return null;
    final clean = text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean);
  }
}
