import 'package:intl/intl.dart';

class FormatterHelper {
  FormatterHelper._();

  static const String formatDate = "dd MMM yyyy";
  static const String formatDateTime = "dd MMM yyyy, HH:mm";

  static String dateTimeToString(DateTime value, {String format = formatDate}) {
    return DateFormat(format).format(value);
  }

  static String timestampToString(int value, {String format = formatDate}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value);
    return dateTimeToString(date, format: format);
  }

  static DateTime stringToDateTime(String value, {String format = formatDate}) {
    return DateFormat(format).parse(value);
  }

  static int stringToTimestamp(String dateString, {String format = formatDate}) {
    DateTime date = stringToDateTime(dateString, format: format);
    return date.millisecondsSinceEpoch;
  }

  static String displayCarousel(Duration value) {
    final hours = value.inHours.toString().padLeft(2, "0");
    final minutes = (value.inMinutes % 60).toString().padLeft(2, "0");
    final seconds = (value.inSeconds % 60).toString().padLeft(2, "0");

    return "${hours}h:${minutes}m:${seconds}s";
  }
}
