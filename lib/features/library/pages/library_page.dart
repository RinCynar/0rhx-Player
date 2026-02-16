import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../widgets/folder_picker_dialog.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, _) {
        if (libraryProvider.musicDirectories.isEmpty) {
          return _buildEmptyState(context, libraryProvider);
        }

        return Column(
          children: [
            // Directory list header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Music Library',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showFolderPicker(context, libraryProvider);
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Add Folder'),
                  ),
                ],
              ),
            ),
            // Folders and audio files list
            Expanded(
              child: libraryProvider.isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : _buildLibraryContent(context, libraryProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, LibraryProvider libraryProvider) {
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
            'Add a folder to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showFolderPicker(context, libraryProvider);
            },
            icon: const Icon(Icons.folder_open),
            label: const Text('Add Music Folder'),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryContent(BuildContext context, LibraryProvider libraryProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Music directories
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Folders (${libraryProvider.musicDirectories.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...libraryProvider.musicDirectories.map((dir) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(dir.split(Platform.pathSeparator).last),
                      subtitle: Text(dir),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          libraryProvider.removeMusicFolder(dir);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Audio files
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio Files (${libraryProvider.audioFileCount})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (libraryProvider.audioFiles.isEmpty)
                  Text(
                    'No audio files found. Try scanning a folder.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: libraryProvider.audioFiles.length,
                    itemBuilder: (context, index) {
                      final file = libraryProvider.audioFiles[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.music_note,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            file['title'] ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file['artist'] ?? 'Unknown Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                file['path'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {
                              // TODO: Play this file
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFolderPicker(BuildContext context, LibraryProvider libraryProvider) {
    showDialog(
      context: context,
      builder: (context) => FolderPickerDialog(
        onFolderSelected: (folderPath) async {
          await libraryProvider.addMusicFolder(folderPath);
        },
      ),
    );
  }
}
