import 'package:intl/intl.dart';

class Format {
  Format._();

  static String formatPrice(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price);
  }

  static String formatDDMMYYYY(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy', Intl.defaultLocale).format(dateTime);
  }

  static String formatShortDay(DateTime dateTime) {
    return DateFormat('d MMM', Intl.defaultLocale).format(dateTime);
  }

  static String formatHHMM(DateTime dateTime) {
    return DateFormat('HH:mm', Intl.defaultLocale).format(dateTime);
  }

  static String formatDDMMYYYYHHMM(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy - HH:mm', Intl.defaultLocale)
        .format(dateTime);
  }
}
