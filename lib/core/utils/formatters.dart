import 'package:intl/intl.dart';

class AppFormatters {
  const AppFormatters._();

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _dateTime = DateFormat('dd MMM, hh:mm a');
  static final _day = DateFormat('EEE, dd MMM');

  static String currency(num value) => _currency.format(value);
  static String shortDate(DateTime date) => _day.format(date);
  static String orderTimestamp(DateTime date) => _dateTime.format(date);
}
