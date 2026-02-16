import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/player_state.dart';

class PlayerControlBar extends StatelessWidget {
  const PlayerControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, _) {
        final state = playerProvider.playerState;
        final isPlaying = state.state == PlaybackState.playing;

        return Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Track info
              if (state.currentTrackTitle != null)
                Column(
                  children: [
                    Text(
                      state.currentTrackTitle ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (state.currentTrackArtist != null)
                      Text(
                        state.currentTrackArtist ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              // Progress bar
              _ProgressBar(state: state, playerProvider: playerProvider),
              const SizedBox(height: 8),
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous button
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      // TODO: Implement previous track
                    },
                  ),
                  // Play/Pause button
                  FloatingActionButton.small(
                    onPressed: () {
                      playerProvider.togglePlayPause();
                    },
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  // Next button
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      // TODO: Implement next track
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatefulWidget {
  final PlayerState state;
  final PlayerProvider playerProvider;

  const _ProgressBar({
    required this.state,
    required this.playerProvider,
  });

  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar> {
  bool _isDragging = false;
  late double _dragValue;

  @override
  Widget build(BuildContext context) {
    final position = _isDragging ? _dragValue : widget.state.currentPosition.inMilliseconds.toDouble();
    final duration = widget.state.duration.inMilliseconds.toDouble();
    final progress = duration > 0 ? position / duration : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              setState(() {
                _isDragging = true;
                _dragValue = value * duration;
              });
            },
            onChangeEnd: (value) {
              final newPosition = Duration(milliseconds: _dragValue.toInt());
              widget.playerProvider.seek(newPosition);
              setState(() {
                _isDragging = false;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(
                  _isDragging
                      ? Duration(milliseconds: _dragValue.toInt())
                      : widget.state.currentPosition,
                ),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                _formatDuration(widget.state.duration),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
