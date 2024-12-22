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

  String toTimeAgo() {
    final now = DateTime.now().toVietnamTime();
    final difference = now.difference(toVietnamTime());

    if (difference.inDays >= 7) {
      int weeks = difference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'Just now';
    }
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
