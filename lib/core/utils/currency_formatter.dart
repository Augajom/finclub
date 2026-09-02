/// Utility to format monetary and currency values
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats a double value to standard currency string (e.g. 12500.5 -> "12,500.50")
  static String format(double amount, {String symbol = '฿', bool showSymbol = true}) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final formatted = '$integerPart.${parts[1]}';
    return showSymbol ? '$symbol $formatted' : formatted;
  }
}
