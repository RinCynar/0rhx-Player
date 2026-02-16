import 'package:flutter/material.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Playlist',
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}
