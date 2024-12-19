import 'package:mason_logger/mason_logger.dart';

extension LoggerX on Logger {
  void infoNostr(String? message) {
    info('Nostr: $message');
  }

  void errNostr(String? message) {
    err('Nostr: $message');
  }

  void infoBluesky(String? message) {
    info('Bluesky: $message');
  }

  void errBluesky(String? message) {
    err('Bluesky: $message');
  }

  void infoMastodon(String? message) {
    info('Mastodon: $message');
  }

  void errMastodon(String? message) {
    err('Mastodon: $message');
  }
}
