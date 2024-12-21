import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String toDDMMYYYY() {
    return DateFormat('dd/MM/yyyy').format(toVietnamTime());
  }

  String toShortDay() {
    return DateFormat('d MMM').format(toVietnamTime());
  }

  String toFullDate() {
    return DateFormat('dd/MM/yyyy - HH:mm').format(toVietnamTime());
  }

  String toHHMM() {
    return DateFormat('HH:mm').format(toVietnamTime());
  }

  // Convert to Vietnam time
  DateTime toVietnamTime() {
    return toUtc().add(const Duration(hours: 7));
  }
}

extension DoubleFormatting on double {
  String toCurrency({String locale = 'vi_VN', String symbol = '₫'}) {
    return NumberFormat.currency(locale: locale, symbol: symbol).format(this);
  }
}
