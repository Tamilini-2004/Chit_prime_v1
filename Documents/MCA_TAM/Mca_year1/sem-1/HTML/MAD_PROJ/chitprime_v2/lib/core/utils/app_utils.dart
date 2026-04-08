import 'package:intl/intl.dart';

class AppUtils {
  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _month = DateFormat('MMM yyyy');

  static String formatCurrency(num amount) => _currency.format(amount);
  static String formatDate(DateTime d) => _date.format(d);
  static String formatDateTime(DateTime d) => _dateTime.format(d);
  static String formatMonth(DateTime d) => _month.format(d);

  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  static String maskAccount(String acc) => 'XXXX${acc.substring(acc.length > 4 ? acc.length - 4 : 0)}';
  static String maskAadhaar(String a) => 'XXXX XXXX ${a.substring(a.length > 4 ? a.length - 4 : 0)}';
  static String maskPan(String p) => p.length >= 5 ? '${p.substring(0, 2)}XXXXXXX${p[p.length - 1]}' : p;

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  static String countdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String creditRating(int score) {
    if (score >= 800) return 'Excellent';
    if (score >= 650) return 'Good';
    if (score >= 500) return 'Fair';
    return 'Poor';
  }

  static String generateTxnId() => 'TXN${DateTime.now().millisecondsSinceEpoch}';
  static String generatePayoutId() => 'PAY-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  static String generateGroupCode() => 'CP-${DateTime.now().year}-${(1000 + DateTime.now().millisecond).toString()}';
}
