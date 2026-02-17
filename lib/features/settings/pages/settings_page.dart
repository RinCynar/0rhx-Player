import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/providers/theme_provider.dart';
import '../../library/providers/library_provider.dart';
import '../../library/widgets/folder_picker_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _audioQuality = 'High';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header with back button
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // Settings list
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                   children: [
                     _buildSettingItem(
                       context,
                       'Theme',
                       'Choose light or dark mode',
                       () => _showThemeDialog(context),
                     ),
                     _buildSettingItem(
                       context,
                       'Audio Quality',
                       'Current: $_audioQuality',
                       () => _showAudioQualityDialog(context),
                     ),
                     _buildSettingItem(
                       context,
                       'Library Folders',
                       'Manage music folders',
                       () => _showLibraryFoldersDialog(context),
                     ),
                     _buildSettingItem(
                       context,
                       'Notifications',
                       _notificationsEnabled ? 'Enabled' : 'Disabled',
                       () => _showNotificationsDialog(context),
                     ),
                     _buildSettingItem(
                       context,
                       'About',
                       'App version and information',
                       () => _showAboutDialog(context),
                     ),
                   ],
                 ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Light'),
                  trailing: themeProvider.themeMode == ThemeMode.light
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    themeProvider.setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Dark'),
                  trailing: themeProvider.themeMode == ThemeMode.dark
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    themeProvider.setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAudioQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Low', 'Medium', 'High', 'Very High']
              .map(
                (quality) => ListTile(
                  title: Text(quality),
                  trailing: _audioQuality == quality
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    setState(() => _audioQuality = quality);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showLibraryFoldersDialog(BuildContext context) {
    final libraryProvider = context.read<LibraryProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Library Folders'),
        content: Consumer<LibraryProvider>(
          builder: (context, provider, _) {
            return SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (provider.musicDirectories.isEmpty)
                    const Text('No folders added')
                  else
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.musicDirectories.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(provider.musicDirectories[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                libraryProvider.removeMusicFolder(provider.musicDirectories[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => FolderPickerDialog(
                          onFolderSelected: (folderPath) {
                            libraryProvider.addMusicFolder(folderPath);
                          },
                        ),
                      );
                    },
                    child: const Text('Add Folder'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  this.setState(() {});
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '0rhx Player',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 0rhx Player. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text('A beautiful local music player built with Flutter and Material You.'),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.arrow_forward,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
