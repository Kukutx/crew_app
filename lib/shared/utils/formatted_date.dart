import 'package:intl/intl.dart';

class FormattedDate {
  static final DateFormat _date = DateFormat('MM月dd日 HH:mm');
  static final DateFormat _relativeFormat = DateFormat('MM月dd日');

  static String format(DateTime date) => _date.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} 分钟前';
      }
      return '${difference.inHours} 小时前';
    }
    if (difference.inDays == 1) {
      return '昨天 · ${DateFormat('HH:mm').format(date)}';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    }
    return _relativeFormat.format(date);
  }

  static String formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
