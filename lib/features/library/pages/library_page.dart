import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../models/song.dart';
import '../widgets/folder_picker_dialog.dart';
import '../../player/providers/player_provider.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
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
      appBar: AppBar(
        title: const Text('Library'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar for filtering
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTabButton(context, 'Titles', 0),
                const SizedBox(width: 12),
                _buildTabButton(context, 'Artists', 1),
                const SizedBox(width: 12),
                _buildTabButton(context, 'Albums', 2),
                const SizedBox(width: 12),
                _buildTabButton(context, 'Folders', 3),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: Consumer<LibraryProvider>(
              builder: (context, libraryProvider, _) {
                if (!libraryProvider.isInitialized) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (libraryProvider.isScanning) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _buildTabContent(context, libraryProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String label, int index) {
    final isActive = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (isActive)
              Icon(
                Icons.check,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            if (isActive) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
      BuildContext context, LibraryProvider libraryProvider) {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Titles tab
        _buildTitlesTab(context, libraryProvider),
        // Artists tab
        _buildArtistsTab(context, libraryProvider),
        // Albums tab
        _buildAlbumsTab(context, libraryProvider),
        // Folders tab
        _buildFoldersTab(context, libraryProvider),
      ],
    );
  }

  Widget _buildTitlesTab(
      BuildContext context, LibraryProvider libraryProvider) {
    final songs = libraryProvider.songs;

    if (songs.isEmpty) {
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
              'No Songs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a folder to discover music',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => FolderPickerDialog(
                    onFolderSelected: (folderPath) async {
                      await libraryProvider.addMusicFolder(folderPath);
                    },
                  ),
                );
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Add Music Folder'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return _buildSongCard(context, song);
        },
      ),
    );
  }

  Widget _buildArtistsTab(
      BuildContext context, LibraryProvider libraryProvider) {
    // TODO: Implement artists view
    return Center(
      child: Text(
        'Artists View',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildAlbumsTab(
      BuildContext context, LibraryProvider libraryProvider) {
    // TODO: Implement albums view
    return Center(
      child: Text(
        'Albums View',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildFoldersTab(
      BuildContext context, LibraryProvider libraryProvider) {
    final folders = libraryProvider.musicDirectories;

    if (folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Folders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add a folder to scan for music',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => FolderPickerDialog(
                    onFolderSelected: (folderPath) async {
                      await libraryProvider.addMusicFolder(folderPath);
                    },
                  ),
                );
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Add Folder'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folderPath = folders[index];
          final folderName = folderPath.split('\\').last;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.folder),
              title: Text(folderName),
              subtitle: Text(
                folderPath,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  libraryProvider.removeMusicFolder(folderPath);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSongCard(BuildContext context, Song song) {
    final dateText = _getDateText(song.dateAdded);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          _playSong(context, song);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder image
              Container(
                width: double.infinity,
                height: 100,
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
              const SizedBox(height: 8),
              // Title
              Text(
                song.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              // Updated date
              Text(
                dateText,
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
      ),
    );
  }

  String _getDateText(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Updated today';
    } else if (date == yesterday) {
      return 'Updated yesterday';
    } else {
      final daysAgo = today.difference(date).inDays;
      return 'Updated $daysAgo days ago';
    }
  }

  void _playSong(BuildContext context, Song song) {
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.loadTrack(
      song.filePath,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
    );
    playerProvider.play();
  }
}
