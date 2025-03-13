import 'package:intl/intl.dart';

class Formatters {
  static String Currency(double amount){
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(amount);
  }

  static String Date(DateTime date){
    return DateFormat('dd MMMM YYYY').format(date);
  }
}