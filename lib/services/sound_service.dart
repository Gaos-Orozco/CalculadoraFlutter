import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  Future<void> playStartup() async {
    await _play(
      'sounds/startup.mp3',
      0.55,
    );
  }

  Future<void> playTap() async {
    await _play(
      'sounds/tap.mp3',
      0.35,
    );
  }

  Future<void> playSuccess() async {
    await _play(
      'sounds/success.mp3',
      0.50,
    );
  }

  Future<void> playError() async {
    await _play(
      'sounds/error.mp3',
      0.50,
    );
  }

  Future<void> _play(
    String file,
    double volume,
  ) async {
    try {
      final player = AudioPlayer();

      await player.play(
        AssetSource(file),
        volume: volume,
      );

      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint(
        'Error reproduciendo sonido: $e',
      );
    }
  }

  Future<void> dispose() async {}
}