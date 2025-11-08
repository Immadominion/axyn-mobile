import 'package:intl/intl.dart';

class TimeFormatter {
  TimeFormatter._();

  static String relative(DateTime timestamp, {DateTime? reference}) {
    final DateTime now = reference ?? DateTime.now();
    final Duration difference = now.difference(timestamp);

    if (difference.isNegative) {
      return _formatFutureDuration(difference.abs());
    }

    if (difference.inSeconds < 45) {
      return 'just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return DateFormat.MMMd().format(timestamp);
  }

  static String _formatFutureDuration(Duration duration) {
    if (duration.inSeconds < 45) {
      return 'in moments';
    }
    if (duration.inMinutes < 60) {
      return 'in ${duration.inMinutes}m';
    }
    if (duration.inHours < 24) {
      return 'in ${duration.inHours}h';
    }
    if (duration.inDays < 7) {
      return 'in ${duration.inDays}d';
    }
    return DateFormat.MMMd().format(DateTime.now().add(duration));
  }
}
