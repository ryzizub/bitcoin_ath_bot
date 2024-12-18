import 'package:intl/intl.dart';

class PriceUtils {
  static String formatPrice(int price) {
    final numberFormat = NumberFormat.currency(locale: 'en_US');

    return numberFormat.format(price);
  }
}
