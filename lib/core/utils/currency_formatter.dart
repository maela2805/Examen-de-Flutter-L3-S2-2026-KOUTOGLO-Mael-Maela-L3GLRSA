import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'fr_FR');

  static String format(num amount) {
    return '${_formatter.format(amount)} XOF';
  }

  static String formatNumber(num amount) {
    return _formatter.format(amount);
  }

  static String formatSigned(num amount, {bool isCredit = false}) {
    final sign = isCredit ? '+' : '-';
    return '$sign${_formatter.format(amount.abs())} XOF';
  }
}

class DateFormatter {
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
  static final DateFormat _dateOnly = DateFormat('dd MMM yyyy', 'fr_FR');
  static final DateFormat _timeOnly = DateFormat('HH:mm', 'fr_FR');

  static String formatDateTime(DateTime date) => _dateTime.format(date);

  static String formatDate(DateTime date) => _dateOnly.format(date);

  static String formatTime(DateTime date) => _timeOnly.format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays} jour(s)';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours} heure(s)';
    if (diff.inMinutes > 0) return 'Il y a ${diff.inMinutes} min';
    return 'À l\'instant';
  }
}
