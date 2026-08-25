import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AudioFeedbackType {
  notification,
  cashReceipt,
  alert,
}

class AudioFeedbackService {
  AudioFeedbackService._internal();
  static final AudioFeedbackService instance = AudioFeedbackService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    } catch (e) {
      debugPrint('AudioFeedbackService initialization error: $e');
    }
  }

  /// Plays a pleasant notification chime based on event type
  Future<void> playNotificationSound({
    AudioFeedbackType type = AudioFeedbackType.notification,
  }) async {
    try {
      String assetPath;
      switch (type) {
        case AudioFeedbackType.cashReceipt:
          assetPath = 'sounds/cash_chime.wav';
          break;
        case AudioFeedbackType.alert:
          assetPath = 'sounds/alert_chime.wav';
          break;
        case AudioFeedbackType.notification:
          assetPath = 'sounds/notification_chime.wav';
          break;
      }

      await _player.stop();
      await _player.play(AssetSource(assetPath), volume: 0.9);
    } catch (e) {
      debugPrint('Audio feedback playback suppressed or failed: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
