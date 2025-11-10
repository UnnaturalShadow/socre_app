import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    // Preload sounds if you like:
    // await _player.setSource(AssetSource('sounds/startup.wav'));
  }

  static Future<void> play(String soundName) async {
    try {
      await _player.play(AssetSource('sounds/$soundName.wav'));
    } catch (e) {
      // Fail silently if sound missing (for dev testing)
    }
  }

  static Future<void> playOpeningDitty() async {
    await _player.play(AssetSource('assets/sounds/opening_ditty.mp3'));
  }

  static Future<void> playButtonSound() async {
    await _player.play(AssetSource('assets/sounds/button_press.mp3'));
  }

  static Future<void> playSaveSound() async {
    await _player.play(AssetSource('assets/sounds/save_sound.mp3'));
  }
}
