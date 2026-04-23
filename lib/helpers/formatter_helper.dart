import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FormatterHelper {
  FormatterHelper._();

  static const String formatDate = "dd MMM yyyy";
  static const String formatDateTime = "dd MMM yyyy, HH:mm";

  static String _dateTimeToString(DateTime value, {String format = formatDate}) {
    return DateFormat(format).format(value);
  }

  static String _timestampToString(int value, {String format = formatDate}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value);
    return _dateTimeToString(date, format: format);
  }

  static DateTime _stringToDateTime(String value, {String format = formatDate}) {
    return DateFormat(format).parse(value);
  }

  static int _stringToTimestamp(String dateString, {String format = formatDate}) {
    DateTime date = _stringToDateTime(dateString, format: format);
    return date.millisecondsSinceEpoch;
  }

  static bool _isExpired(int? value, {bool includeToday = false, bool showMessage = false}) {
    if (value == null) return false;

    DateTime date = DateTime.fromMillisecondsSinceEpoch(value);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, includeToday ? now.day + 1 : now.day);

    bool isExpired = date.isBefore(today);

    if (isExpired && showMessage) MessageHelper.error(message: Globalization.msgMemberExpired.tr);

    return isExpired;
  }
}

extension BooleanFormatting on int {
  bool get isExpired => FormatterHelper._isExpired(this);
  bool get isExpiredMsg => FormatterHelper._isExpired(this, showMessage: true);
}

extension DateTimeFormatting on DateTime {
  String get dtToStr => FormatterHelper._dateTimeToString(this);
}

extension StringFormatting on String {
  DateTime get strToDT => FormatterHelper._stringToDateTime(this);
  int get strToTS => FormatterHelper._stringToTimestamp(this);
}

extension TimestampFormatting on int {
  String get tsToStr => FormatterHelper._timestampToString(this);
  String get tsToStrDateTime => FormatterHelper._timestampToString(this, format: FormatterHelper.formatDateTime);
}
