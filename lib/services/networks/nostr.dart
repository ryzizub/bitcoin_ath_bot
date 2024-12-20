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
    'wss://relay.primal.net/',
  ];

  @override
  Future<void> sendPrice(int price) async {
    final publicKey = Nip19.encodePubkey(
      Keychain(Platform.environment['NOSTR']!).public,
    );

    _logger
      ..infoNostr('Sending message...')
      ..infoNostr('Account: $publicKey');

    final content = Event.from(
      kind: 1,
      tags: [],
      content: TextUtils.priceText(price),
      privkey: Platform.environment['NOSTR']!,
    );

    await Future.forEach(setOfRelays, (relayUrl) async {
      try {
        _logger.info('Sending message to nostr: $relayUrl ${content.id}');
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
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    await websocket.close();
  }
}
