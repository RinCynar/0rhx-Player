import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FolderPickerDialog extends StatefulWidget {
  final Function(String) onFolderSelected;

  const FolderPickerDialog({
    super.key,
    required this.onFolderSelected,
  });

  @override
  State<FolderPickerDialog> createState() => _FolderPickerDialogState();
}

class _FolderPickerDialogState extends State<FolderPickerDialog> {
  late String _currentPath;
  List<FileSystemEntity> _directories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start from user's home directory or Documents
    _currentPath = _getInitialPath();
    _loadDirectories();
  }

  String _getInitialPath() {
    if (Platform.isWindows) {
      // Get Music folder on Windows
      final username = Platform.environment['USERNAME'] ?? 'User';
      return 'C:\\Users\\$username\\Music';
    } else if (Platform.isLinux) {
      return Platform.environment['HOME'] ?? '/home';
    } else {
      return '/';
    }
  }

  Future<void> _pickFolderWithFilePicker() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      widget.onFolderSelected(selectedDirectory);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadDirectories() async {
    setState(() => _isLoading = true);
    try {
      final directory = Directory(_currentPath);
      if (await directory.exists()) {
        final entities = await directory.list().toList();
        _directories = entities
            .whereType<Directory>()
            .toList();
        _directories.sort((a, b) => a.path.compareTo(b.path));
      }
    } catch (e) {
      debugPrint('Error loading directories: $e');
    }
    setState(() => _isLoading = false);
  }

  void _navigateToFolder(String path) {
    setState(() {
      _currentPath = path;
      _directories = [];
    });
    _loadDirectories();
  }

  void _goBack() {
    final parent = File(_currentPath).parent.path;
    if (parent != _currentPath) {
      _navigateToFolder(parent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Music Folder'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          children: [
            // Current path display
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                _currentPath,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
            // Directory list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _directories.isEmpty
                      ? Center(
                          child: Text(
                            'No folders found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _directories.length,
                          itemBuilder: (context, index) {
                            final dir = _directories[index];
                            final name = dir.path.split(Platform.pathSeparator).last;
                            return ListTile(
                              leading: const Icon(Icons.folder),
                              title: Text(name),
                              onTap: () {
                                _navigateToFolder(dir.path);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _goBack,
          child: const Text('Back'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _pickFolderWithFilePicker,
          icon: const Icon(Icons.folder_open),
          label: const Text('Browse'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFolderSelected(_currentPath);
            Navigator.pop(context);
          },
          child: const Text('Select This Folder'),
        ),
      ],
    );
  }
}
