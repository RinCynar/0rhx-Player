import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../library/providers/library_provider.dart';
import '../../library/models/song.dart';
import '../../library/widgets/song_cover_image.dart';
import '../../player/providers/player_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Hinted search text',
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                prefixIcon: const Icon(Icons.menu),
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Content area
          Expanded(
            child: Consumer<LibraryProvider>(
              builder: (context, libraryProvider, _) {
                final searchResults = _searchQuery.isEmpty
                    ? <Song>[]
                    : libraryProvider.searchSongs(_searchQuery);

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // Horizontal results grid (if any)
                    if (_searchQuery.isNotEmpty && searchResults.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: searchResults.length > 5
                                      ? 5
                                      : searchResults.length,
                                  itemBuilder: (context, index) {
                                    final song = searchResults[index];
                                    return Padding(
                                      key: ValueKey(
                                        'search_horiz_${song.filePath}',
                                      ),
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _buildSmallSongCard(context, song),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                    // Featured or List results
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _buildSectionHeader(context, 'Featured'),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),

                    if (_searchQuery.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: _buildFeaturedSectionSliver(
                          context,
                          libraryProvider,
                        ),
                      )
                    else if (searchResults.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No results found for "$_searchQuery"',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final song = searchResults[index];
                            return _buildListItem(
                              context,
                              song,
                              key: ValueKey('search_list_${song.filePath}'),
                            );
                          }, childCount: searchResults.length),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                );
              },
            ),
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
                SongCoverImage(
                  coverArtPath: song.coverArtPath,
                  width: double.infinity,
                  height: 70,
                  borderRadius: 8,
                ),
                const SizedBox(height: 8),
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

  Widget _buildFeaturedSectionSliver(
    BuildContext context,
    LibraryProvider libraryProvider,
  ) {
    final songs = libraryProvider.songs.take(3).toList();

    if (songs.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'No songs available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return _buildListItem(context, songs[index]);
      }, childCount: songs.length),
    );
  }

  Widget _buildListItem(BuildContext context, dynamic song, {Key? key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            // Menu button
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _playSong(context, song);
              },
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
