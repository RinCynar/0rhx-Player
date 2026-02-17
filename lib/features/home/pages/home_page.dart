import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../library/providers/library_provider.dart';
import '../../player/providers/player_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('0thx Player'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        titleTextStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libraryProvider, _) {
          if (!libraryProvider.isInitialized || libraryProvider.songs.isEmpty) {
            return _buildEmptyState(context, libraryProvider);
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Mix section
                  _buildSectionHeader(context, 'Daily Mix'),
                  const SizedBox(height: 12),
                  _buildHorizontalSongScroll(context, libraryProvider),
                  const SizedBox(height: 32),

                  // Section title
                  _buildSectionHeader(context, 'Section title'),
                  const SizedBox(height: 12),
                  _buildArtistGrid(context, libraryProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, LibraryProvider libraryProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Music Library',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Go to Library to add music folders',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildHorizontalSongScroll(
      BuildContext context, LibraryProvider libraryProvider) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: libraryProvider.songs.length,
        itemBuilder: (context, index) {
          final song = libraryProvider.songs[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildSmallSongCard(context, song),
          );
        },
      ),
    );
  }

  Widget _buildSmallSongCard(BuildContext context, dynamic song) {
    return Card(
      child: InkWell(
        onTap: () {
          _playSong(context, song);
        },
        child: SizedBox(
          width: 120,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder image
                Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtistGrid(
      BuildContext context, LibraryProvider libraryProvider) {
    final songs = libraryProvider.songs;
    final displayCount = (songs.length / 2).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        final song = songs[index];
        return _buildArtistCard(context, song);
      },
    );
  }

  Widget _buildArtistCard(BuildContext context, dynamic song) {
    return Card(
      child: InkWell(
        onTap: () {
          _playSong(context, song);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Placeholder image
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
                ),
                child: Icon(
                  Icons.music_note,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.5),
                  size: 40,
                ),
              ),
              // Artist info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
              // Play button
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.play_circle),
                  onPressed: () {
                    _playSong(context, song);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playSong(BuildContext context, dynamic song) {
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.loadTrack(
      song.filePath,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
    );
    playerProvider.play();
  }
}
