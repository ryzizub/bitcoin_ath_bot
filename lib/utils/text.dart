import 'package:bitcoin_ath_bot/utils/price.dart';

class TextUtils {
  static String priceText(int price) {
    return 'Current ATH: ${PriceUtils.formatPrice(price)}';
  }
}
