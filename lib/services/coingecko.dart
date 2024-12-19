import 'package:coingecko_api/coingecko_api.dart';

class CoinGeckoService {
  CoinGeckoService() : api = CoinGeckoApi();

  final CoinGeckoApi api;

  Future<int?> getPrice() async {
    final price = await api.simple.listPrices(
      ids: ['bitcoin'],
      vsCurrencies: ['usd'],
    );

    // return price.data.first.getPriceIn('usd')?.toInt();
    return 108135;
  }
}
