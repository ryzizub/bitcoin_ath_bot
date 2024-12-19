import 'package:bitcoin_ath_bot/services/networks/network.dart';
import 'package:bitcoin_ath_bot/utils/utils.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mastodon_api/mastodon_api.dart';

class MastodonService extends NetworkService {
  MastodonService(this._logger);

  final Logger _logger;

  @override
  Future<void> sendPrice(int price) async {
    _logger.infoMastodon('Sending message...');

    try {
      final mastodon = MastodonApi(
        instance: 'mastodon.social',
        // ignore: avoid_redundant_argument_values
        bearerToken: const String.fromEnvironment('MASTODON_BEARER_TOKEN'),
        retryConfig: RetryConfig(
          maxAttempts: 5,
          jitter: Jitter(
            minInSeconds: 2,
            maxInSeconds: 5,
          ),
          onExecute: (event) => _logger.infoMastodon(
            'Retry after ${event.intervalInSeconds} seconds... '
            '[${event.retryCount} times]',
          ),
        ),
      );

      final message = TextUtils.priceText(price);

      await mastodon.v1.statuses.createStatus(
        text: message,
      );

      _logger.info('Message sent successfully');
    } catch (e) {
      _logger.err('Failed to send message: $e');
    }
  }
}
