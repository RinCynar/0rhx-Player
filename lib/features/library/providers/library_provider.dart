import 'package:flutter/material.dart';
import '../services/file_scanner_service.dart';

class LibraryProvider extends ChangeNotifier {
  final FileScannerService _scannerService = FileScannerService();

  final List<String> _musicDirectories = [];
  final List<Map<String, String>> _audioFiles = [];
  bool _isScanning = false;
  String? _errorMessage;

  List<String> get musicDirectories => _musicDirectories;
  List<Map<String, String>> get audioFiles => _audioFiles;
  bool get isScanning => _isScanning;
  String? get errorMessage => _errorMessage;
  int get audioFileCount => _audioFiles.length;

  /// Add a folder to watch for music
  Future<void> addMusicFolder(String folderPath) async {
    if (_musicDirectories.contains(folderPath)) {
      _errorMessage = 'Folder already added';
      notifyListeners();
      return;
    }

    _musicDirectories.add(folderPath);
    _errorMessage = null;
    notifyListeners();

    // Scan the newly added folder
    await scanLibrary();
  }

  /// Remove a folder from watch list
  void removeMusicFolder(String folderPath) {
    _musicDirectories.remove(folderPath);
    _errorMessage = null;
    notifyListeners();
    
    // Rescan library without this folder
    _rescanLibrary();
  }

  /// Scan all music directories and build audio file list
  Future<void> scanLibrary() async {
    _isScanning = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _audioFiles.clear();

      for (final directory in _musicDirectories) {
        final files = await _scannerService.scanDirectory(directory);
        
        for (final filePath in files) {
          final metadata = await _scannerService.getFileMetadata(filePath);
          _audioFiles.add({
            ...metadata,
            'path': filePath,
          });
        }
      }

      debugPrint('Scanned ${_audioFiles.length} audio files');
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error scanning library: $e';
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Internal rescan without modifying directory list
  void _rescanLibrary() {
    _audioFiles.clear();
    notifyListeners();
  }

  /// Get audio file by index
  Map<String, String>? getAudioFile(int index) {
    if (index >= 0 && index < _audioFiles.length) {
      return _audioFiles[index];
    }
    return null;
  }

  /// Search audio files
  List<Map<String, String>> searchAudioFiles(String query) {
    final lowerQuery = query.toLowerCase();
    return _audioFiles
        .where((file) =>
            (file['title']?.toLowerCase().contains(lowerQuery) ?? false) ||
            (file['artist']?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }
}
