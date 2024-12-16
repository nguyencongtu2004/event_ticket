import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String toDDMMYYYY() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  String toShortDay() {
    return DateFormat('d MMM').format(this);
  }

  String toFullDate() {
    return DateFormat('dd/MM/yyyy - HH:mm').format(this);
  }

  String toHHMM() {
    return DateFormat('HH:mm').format(this);
  }
}

extension DoubleFormatting on double {
  String toCurrency({String locale = 'vi_VN', String symbol = '₫'}) {
    return NumberFormat.currency(locale: locale, symbol: symbol).format(this);
  }
}
