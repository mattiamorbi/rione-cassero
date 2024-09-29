import 'package:intl/intl.dart';

class DateTimeHelper {
  static DateFormat defaultFormat = DateFormat('dd/MM/yyyy');

  static DateTime getDateTime(String date) {
    return defaultFormat.parse(date);
  }

  static String getString(DateTime date) {
    return defaultFormat.format(date);
  }
}
