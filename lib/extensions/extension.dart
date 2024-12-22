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

  String toTimeAgo({bool isShortFormat = true}) {
    final now = DateTime.now().toVietnamTime();
    final difference = now.difference(toVietnamTime());

    var format = '';

    if (difference.inDays >= 7) {
      int weeks = difference.inDays ~/ 7;
      format = '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (difference.inDays > 0) {
      format =
          '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      format =
          '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      format =
          '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      format = 'Just now';
    }

    if (isShortFormat) {
      return format;
    } else {
      return format == 'Just now' ? format : '$format ago';
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
