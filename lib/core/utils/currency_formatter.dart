import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _usd = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\u0024',
    decimalDigits: 2,
  );

  static final NumberFormat _usdCompact = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: '\u0024',
  );

  static String usd(double value) => _usd.format(value);

  static String usdCompact(double value) => _usdCompact.format(value);

  static String token(double value, {String token = 'USDC'}) {
    return '${usd(value)} $token';
  }
}
