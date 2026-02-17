import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../library/providers/library_provider.dart';
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
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                    ? <dynamic>[]
                    : libraryProvider.searchSongs(_searchQuery);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search results heading
                        Text(
                          'Search',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),

                        // Search results grid
                        if (_searchQuery.isNotEmpty)
                          Column(
                            children: [
                              SizedBox(
                                height: 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final song = searchResults[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _buildSmallSongCard(context, song),
                                    );
                                  },
                                ),
                              ),
                              if (searchResults.length > 4)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Show all',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                            ],
                          ),

                        // Featured section
                        _buildSectionHeader(context, 'Featured'),
                        const SizedBox(height: 12),
                        if (_searchQuery.isEmpty)
                          _buildFeaturedSection(context, libraryProvider)
                        else if (searchResults.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'No results found for "$_searchQuery"',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final song = searchResults[index];
                              return _buildListItem(context, song);
                            },
                          ),
                      ],
                    ),
                  ),
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

  Widget _buildFeaturedSection(
      BuildContext context, LibraryProvider libraryProvider) {
    final songs = libraryProvider.songs.take(3).toList();

    if (songs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No songs available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return _buildListItem(context, songs[index]);
      },
    );
  }

  Widget _buildListItem(BuildContext context, dynamic song) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon/Placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
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
                size: 20,
              ),
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
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
