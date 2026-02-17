import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/providers/player_provider.dart';
import '../../library/providers/library_provider.dart';
import '../../library/models/song.dart';
import '../../library/widgets/song_cover_image.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Menu button
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
            ),
          ),
          // Current playing track card
          Expanded(
            child: Consumer2<PlayerProvider, LibraryProvider>(
              builder: (context, playerProvider, libraryProvider, _) {
                final currentTrackTitle =
                    playerProvider.currentTrackTitle ?? 'Now Playing';
                final currentTrackArtist =
                    playerProvider.currentTrackArtist ?? 'Artists';

                // Get current playing song for cover art
                final currentSong = libraryProvider.songs.isNotEmpty
                    ? libraryProvider.songs.first
                    : null;

                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: _buildNowPlayingCard(
                            context,
                            currentSong,
                            currentTrackTitle,
                            currentTrackArtist,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.2),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              tabs: const [
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Played'),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Nexts'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPlayedTab(context),
                      _buildNextsTab(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingCard(
    BuildContext context,
    Song? currentSong,
    String currentTrackTitle,
    String currentTrackArtist,
  ) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.4),
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Cover art or placeholder
          currentSong != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SongCoverImage(
                    coverArtPath: currentSong.coverArtPath,
                    width: double.infinity,
                    height: 200,
                    borderRadius: 0,
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.music_note,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
          // Title and artist overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTrackTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  currentTrackArtist,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayedTab(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, _) {
        final songs = libraryProvider.songs;

        if (songs.isEmpty) {
          return Center(
            child: Text(
              'No played songs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return _buildPlaylistItem(
              context,
              song,
              key: ValueKey('played_${song.filePath}'),
            );
          },
        );
      },
    );
  }

  Widget _buildNextsTab(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, _) {
        final songs = libraryProvider.songs;

        if (songs.isEmpty || songs.length <= 1) {
          return Center(
            child: Text(
              'No upcoming songs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          itemCount: songs.length - 1,
          itemBuilder: (context, index) {
            // Offset by 1 to skip first song
            final song = songs[index + 1];
            return _buildPlaylistItem(
              context,
              song,
              key: ValueKey('next_${song.filePath}'),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistItem(BuildContext context, Song song, {Key? key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Cover art image
            SongCoverImage(
              coverArtPath: song.coverArtPath,
              width: 50,
              height: 50,
              borderRadius: 6,
            ),
            const SizedBox(width: 12),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Rating and like button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
