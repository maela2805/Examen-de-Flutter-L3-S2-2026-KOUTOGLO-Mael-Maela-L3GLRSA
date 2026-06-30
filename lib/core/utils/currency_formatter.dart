import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'fr_FR');

  /// Formate un montant en XOF : 125000 → "125 000 XOF"
  static String format(num amount) {
    return '${_formatter.format(amount)} XOF';
  }

  /// Formate sans devise : 125000 → "125 000"
  static String formatNumber(num amount) {
    return _formatter.format(amount);
  }

  /// Formate avec signe + ou - : 5000 → "+5 000 XOF"
  static String formatSigned(num amount, {bool isCredit = false}) {
    final sign = isCredit ? '+' : '-';
    return '$sign${_formatter.format(amount.abs())} XOF';
  }
}

class DateFormatter {
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
  static final DateFormat _dateOnly = DateFormat('dd MMM yyyy', 'fr_FR');
  static final DateFormat _timeOnly = DateFormat('HH:mm', 'fr_FR');

  /// "15/06/2026 14:30"
  static String formatDateTime(DateTime date) => _dateTime.format(date);

  /// "15 Juin 2026"
  static String formatDate(DateTime date) => _dateOnly.format(date);

  /// "14:30"
  static String formatTime(DateTime date) => _timeOnly.format(date);

  /// Calcule le délai relatif : "Il y a 2 heures"
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Il y a ${diff.inDays} jour(s)';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours} heure(s)';
    if (diff.inMinutes > 0) return 'Il y a ${diff.inMinutes} min';
    return 'À l\'instant';
  }
}
