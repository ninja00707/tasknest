// ignore_for_file: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:tasknest/core/theme/common_date_format.dart';
// Use: CommonDateFormat.formatDateTime(date);

class CommonDateFormat {
  /// Standard format: Jan 10, 2024 14:30
  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  /// Date only: Jan 10, 2024
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Time only: 14:30
  static String formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('HH:mm').format(date);
  }

  /// Short format: Jan 10, 14:30
  /// Often used in timelines or compact lists
  static String formatShortDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, HH:mm').format(date);
  }

  static DateTime? parse(String? dateStr) =>
      dateStr != null ? DateTime.tryParse(dateStr) : null;
}
