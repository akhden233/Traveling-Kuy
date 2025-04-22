import 'package:intl/intl.dart';

class Formatters {
    static final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static String Date(DateTime date){
    return DateFormat('dd MMMM YYYY').format(date);
  }
}