import 'package:equatable/equatable.dart';

enum PlaybackState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

class PlayerState extends Equatable {
  final PlaybackState state;
  final Duration currentPosition;
  final Duration duration;
  final double volume;
  final bool isMuted;
  final String? currentTrackTitle;
  final String? currentTrackArtist;
  final String? errorMessage;

  const PlayerState({
    this.state = PlaybackState.stopped,
    this.currentPosition = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isMuted = false,
    this.currentTrackTitle,
    this.currentTrackArtist,
    this.errorMessage,
  });

  PlayerState copyWith({
    PlaybackState? state,
    Duration? currentPosition,
    Duration? duration,
    double? volume,
    bool? isMuted,
    String? currentTrackTitle,
    String? currentTrackArtist,
    String? errorMessage,
  }) {
    return PlayerState(
      state: state ?? this.state,
      currentPosition: currentPosition ?? this.currentPosition,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      currentTrackTitle: currentTrackTitle ?? this.currentTrackTitle,
      currentTrackArtist: currentTrackArtist ?? this.currentTrackArtist,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        state,
        currentPosition,
        duration,
        volume,
        isMuted,
        currentTrackTitle,
        currentTrackArtist,
        errorMessage,
      ];
}
