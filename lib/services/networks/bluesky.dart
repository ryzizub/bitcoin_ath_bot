import 'dart:io';

import 'package:atproto/atproto.dart';
import 'package:bitcoin_ath_bot/services/networks/network.dart';
import 'package:bitcoin_ath_bot/utils/utils.dart';
import 'package:bluesky/bluesky.dart';
import 'package:mason_logger/mason_logger.dart';

class BlueskyService extends NetworkService {
  BlueskyService(this._logger);

  final Logger _logger;

  @override
  Future<void> sendPrice(int price) async {
    _logger.infoBluesky('Sending message...');

    try {
      final session = await createSession(
        identifier: Platform.environment['BLUESKY_IDENTIFIER']!,
        password: Platform.environment['BLUESKY_PASSWORD']!,
      );

      final bluesky = Bluesky.fromSession(session.data);

      final message = TextUtils.priceText(price);

      await bluesky.feed.post(text: message);

      _logger.info('Message sent successfully');
    } catch (e) {
      _logger.err('Failed to send message: $e');
    }
  }
}
