import 'package:flutter/material.dart';
import '../models/player_state.dart';
import '../services/audio_service.dart';

class PlayerProvider extends ChangeNotifier {
  late AudioService _audioService;
  PlayerState _playerState = const PlayerState();

  PlayerState get playerState => _playerState;

  bool get isPlaying => _playerState.state == PlaybackState.playing;
  bool get isPaused => _playerState.state == PlaybackState.paused;
  bool get isStopped => _playerState.state == PlaybackState.stopped;
  bool get isLoading => _playerState.state == PlaybackState.loading;

  String? get currentTrackTitle => _playerState.currentTrackTitle;
  String? get currentTrackArtist => _playerState.currentTrackArtist;
  Duration get currentPosition => _playerState.currentPosition;
  Duration get duration => _playerState.duration;

  PlayerProvider() {
    _audioService = AudioService();
    _initializeAudioService();
  }

  Future<void> _initializeAudioService() async {
    await _audioService.initialize();
    _listenToPlayerState();
    _listenToPosition();
  }

  void _listenToPlayerState() {
    _audioService.playerStateStream.listen((state) {
      _playerState = state;
      notifyListeners();
    });
  }

  void _listenToPosition() {
    _audioService.positionStream.listen((position) {
      _playerState = _playerState.copyWith(currentPosition: position);
      notifyListeners();
    });
  }

  Future<void> loadTrack(String filePath, {String? title, String? artist}) async {
    _playerState = _playerState.copyWith(
      state: PlaybackState.loading,
      currentTrackTitle: title,
      currentTrackArtist: artist,
    );
    notifyListeners();

    try {
      await _audioService.loadAudio(filePath);
      _playerState = _playerState.copyWith(
        state: PlaybackState.paused,
        duration: _audioService.getDuration() ?? Duration.zero,
      );
      notifyListeners();
    } catch (e) {
      _playerState = _playerState.copyWith(
        state: PlaybackState.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> play() async {
    // Guard: 无有效曲目时不播放
    if (currentTrackTitle == null || currentTrackTitle!.isEmpty) {
      _playerState = _playerState.copyWith(
        state: PlaybackState.error,
        errorMessage: 'No track loaded',
      );
      notifyListeners();
      return;
    }

    try {
      await _audioService.play();
      _playerState = _playerState.copyWith(state: PlaybackState.playing);
      notifyListeners();
    } catch (e) {
      _playerState = _playerState.copyWith(
        state: PlaybackState.error,
        errorMessage: 'Play failed: $e',
      );
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _audioService.pause();
      _playerState = _playerState.copyWith(state: PlaybackState.paused);
      notifyListeners();
    } catch (e) {
      _playerState = _playerState.copyWith(
        state: PlaybackState.error,
        errorMessage: 'Pause failed: $e',
      );
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _audioService.stop();
      _playerState = _playerState.copyWith(
        state: PlaybackState.stopped,
        currentPosition: Duration.zero,
      );
      notifyListeners();
    } catch (e) {
      _playerState = _playerState.copyWith(
        state: PlaybackState.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
      _playerState = _playerState.copyWith(currentPosition: position);
      notifyListeners();
    } catch (e) {
      _playerState = _playerState.copyWith(
        state: PlaybackState.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioService.setVolume(volume);
      _playerState = _playerState.copyWith(volume: volume);
      notifyListeners();
    } catch (e) {
      _playerState = _playerState.copyWith(
        state: PlaybackState.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  @override
  Future<void> dispose() async {
    await _audioService.dispose();
    super.dispose();
  }
}
