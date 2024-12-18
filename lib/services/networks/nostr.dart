import 'dart:io';

import 'package:bitcoin_ath_bot/services/networks/network.dart';
import 'package:bitcoin_ath_bot/utils/utils.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:nostr/nostr.dart';

class NostrService extends NetworkService {
  NostrService(this._logger);

  final Logger _logger;

  final setOfRelays = [
    'wss://relay.nostr.band/',
    'wss://relay.plebstr.com/',
    'wss://eden.nostr.land/',
    'wss://relay.damus.io/',
    'wss://bitcoiner.social/',
    'wss://relay.ryzizub.com/',
  ];

  @override
  Future<void> sendPrice(int price) async {
    final text = 'Current ATH: ${PriceUtils.formatPrice(price)}';

    _logger.info('Sending event to Nostr...');

    final content = Event.from(
      kind: 1,
      tags: [],
      content: text,
      privkey: const String.fromEnvironment('NOSTR'),
    );

    await Future.forEach(setOfRelays, (relayUrl) async {
      try {
        await sendEvent(content, relayUrl);
      } catch (e) {
        _logger.err('Error sending event to $relayUrl: $e');
      }
    });
  }

  Future<void> sendEvent(Event event, String relayUrl) async {
    final websocket = await WebSocket.connect(
      relayUrl,
    );
    websocket.add(event.serialize());
    await websocket.close();
  }
}
