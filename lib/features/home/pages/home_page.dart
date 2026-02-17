import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../library/providers/library_provider.dart';
import '../../player/providers/player_provider.dart';
import '../../theme/providers/theme_provider.dart';
import '../../settings/pages/settings_page.dart';
import '../../library/widgets/song_cover_image.dart';

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
        titleTextStyle: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libraryProvider, _) {
          if (!libraryProvider.isInitialized || libraryProvider.songs.isEmpty) {
            return _buildEmptyState(context, libraryProvider);
          }

          return CustomScrollView(
            slivers: [
              // Daily Mix section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionHeader(context, 'Daily Mix'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHorizontalSongScroll(context, libraryProvider),
                ),
              ),

              // Section title
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionHeader(context, 'Section title'),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _buildArtistGridSliver(context, libraryProvider),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    LibraryProvider libraryProvider,
  ) {
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
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalSongScroll(
    BuildContext context,
    LibraryProvider libraryProvider,
  ) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: libraryProvider.songs.length,
        itemBuilder: (context, index) {
          final song = libraryProvider.songs[index];
          return Padding(
            key: ValueKey('song_${song.filePath}'),
            padding: const EdgeInsets.only(right: 12),
            child: _buildSmallSongCard(context, song),
          );
        },
      ),
    );
  }

  Widget _buildSmallSongCard(BuildContext context, dynamic song) {
    return SizedBox(
      width: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            ),
            child: InkWell(
              onTap: () => _playSong(context, song),
              customBorder: const CircleBorder(),
              child: Center(
                child: ClipOval(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: SongCoverImage(
                      coverArtPath: song.coverArtPath,
                      width: 100,
                      height: 100,
                      borderRadius: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistGridSliver(
    BuildContext context,
    LibraryProvider libraryProvider,
  ) {
    final songs = libraryProvider.songs;

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return _buildArtistCard(context, song);
      },
    );
  }

  Widget _buildArtistCard(BuildContext context, dynamic song) {
    return Card(
      key: ValueKey('artist_song_${song.filePath}'),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () => _playSong(context, song),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: SongCoverImage(
                coverArtPath: song.coverArtPath,
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.artist ?? 'Artist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.play_arrow_rounded),
                      onPressed: () => _playSong(context, song),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
