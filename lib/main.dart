import 'package:bitcoin_ath_bot/repository/price.dart';
import 'package:bitcoin_ath_bot/services/local_storage.dart';
import 'package:bitcoin_ath_bot/services/networks/networks.dart';
import 'package:mason_logger/mason_logger.dart';

Future<void> main() async {
  final logger = Logger()..info('Bitcoin ATH Bot started');

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  logger.info('Local Storage Service initialized');

  final priceRepository =
      PriceRepository(localStorageService: localStorageService);

  logger.info('Price Repository initialized');

  final price = await priceRepository.getUpdatedATHOrNull();

  if (price != null) {
    logger.info('New ATH: $price');

    await NostrService(logger).sendPrice(price);
    await BlueskyService(logger).sendPrice(price);
    await MastodonService(logger).sendPrice(price);
  } else {
    logger.info('No new ATH');
  }

  logger.info('Bitcoin ATH Bot finished');
}
