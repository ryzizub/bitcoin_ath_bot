import 'package:bitcoin_ath_bot/services/coingecko.dart';
import 'package:bitcoin_ath_bot/services/local_storage.dart';
import 'package:mason_logger/mason_logger.dart';

class PriceRepository {
  PriceRepository({
    required this.localStorageService,
    CoinGeckoService? coinGeckoService,
    Logger? logger,
  })  : _coinGeckoService = coinGeckoService ?? CoinGeckoService(),
        _logger = logger ?? Logger();

  final CoinGeckoService _coinGeckoService;
  final Logger _logger;
  LocalStorageService localStorageService;

  Future<int?> getUpdatedATHOrNull() async {
    final price = await _coinGeckoService.getPrice();

    if (price == null) {
      _logger.err('No price found');
      return null;
    } else {
      _logger.info('Price found: $price');
    }

    final currentATH = await localStorageService.getATH();

    if (currentATH == null || price > currentATH) {
      await localStorageService.saveATH(price);
      return price;
    }

    return null;
  }
}
