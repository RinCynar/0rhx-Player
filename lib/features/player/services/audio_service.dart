import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/player_state.dart' as models;

class AudioService {
  late AudioPlayer _audioPlayer;
  
  AudioService() {
    _audioPlayer = AudioPlayer();
  }

  /// Get the underlying AudioPlayer instance
  AudioPlayer get audioPlayer => _audioPlayer;

  /// Initialize audio player
  Future<void> initialize() async {
    try {
      // Set audio session category for proper mixing with other apps
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse('')),
        initialPosition: Duration.zero,
        preload: false,
      ).then((_) {
        // Clear the empty source
        _audioPlayer.stop();
      }).catchError((_) {
        // Ignore error from empty source
      });
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
  }

  /// Load audio file from path
  Future<void> loadAudio(String filePath) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.file(filePath),
        initialPosition: Duration.zero,
      );
    } catch (e) {
      debugPrint('Error loading audio: $e');
      rethrow;
    }
  }

  /// Play audio
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      rethrow;
    }
  }

  /// Pause audio
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
      rethrow;
    }
  }

  /// Stop audio and reset position
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
      rethrow;
    }
  }

  /// Seek to specific duration
  Future<void> seek(Duration duration) async {
    try {
      await _audioPlayer.seek(duration);
    } catch (e) {
      debugPrint('Error seeking: $e');
      rethrow;
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Error setting volume: $e');
      rethrow;
    }
  }

  /// Get current position stream
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  /// Get playback state stream
  Stream<models.PlayerState> get playerStateStream {
    return _audioPlayer.playerStateStream.map((state) {
      return models.PlayerState(
        state: _mapPlaybackState(state.playing, state.processingState),
        currentPosition: _audioPlayer.position,
        duration: _audioPlayer.duration ?? Duration.zero,
      );
    });
  }

  /// Get duration stream
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  /// Get current playback state
  models.PlayerState getCurrentState() {
    final state = _audioPlayer.playerState;
    return models.PlayerState(
      state: _mapPlaybackState(state.playing, state.processingState),
      currentPosition: _audioPlayer.position,
      duration: _audioPlayer.duration ?? Duration.zero,
      volume: _audioPlayer.volume,
    );
  }

  /// Get current position
  Duration getCurrentPosition() {
    return _audioPlayer.position;
  }

  /// Get duration
  Duration? getDuration() {
    return _audioPlayer.duration;
  }

  /// Check if currently playing
  bool isPlaying() {
    return _audioPlayer.playing;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  /// Map just_audio states to our PlayerState
  models.PlaybackState _mapPlaybackState(bool playing, ProcessingState processingState) {
    if (processingState == ProcessingState.loading) {
      return models.PlaybackState.loading;
    }
    if (processingState == ProcessingState.idle) {
      return models.PlaybackState.stopped;
    }
    if (processingState == ProcessingState.ready) {
      return playing ? models.PlaybackState.playing : models.PlaybackState.paused;
    }
    return models.PlaybackState.stopped;
  }
}
