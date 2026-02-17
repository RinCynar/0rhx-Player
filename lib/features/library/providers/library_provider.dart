import 'package:flutter/material.dart';
import '../services/file_scanner_service.dart';
import '../services/database_service.dart';
import '../models/song.dart';

class LibraryProvider extends ChangeNotifier {
  final FileScannerService _scannerService = FileScannerService();
  final DatabaseService _dbService = DatabaseService();

  final List<String> _musicDirectories = [];
  final List<Song> _songs = [];
  bool _isScanning = false;
  String? _errorMessage;
  bool _isInitialized = false;

  List<String> get musicDirectories => _musicDirectories;
  List<Song> get songs => _songs;
  bool get isScanning => _isScanning;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  int get audioFileCount => _songs.length;

  /// 兼容旧 API
  List<Map<String, String>> get audioFiles =>
      _songs.map((song) => {'title': song.title, 'artist': song.artist ?? 'Unknown', 'path': song.filePath}).toList();

  /// 初始化库（加载已保存的歌曲）
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _dbService.initialize();
      _songs.addAll(await _dbService.getAllSongs());
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Database initialization failed: $e';
      _isInitialized = false;
      notifyListeners();
    }
  }

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
      // 确保数据库已初始化
      if (!_isInitialized) {
        await initialize();
      }

      _songs.clear();
      final newSongs = <Song>[];
      
      // Guard: 无扫描目录时返回
      if (_musicDirectories.isEmpty) {
        debugPrint('No music directories configured');
        _isScanning = false;
        notifyListeners();
        return;
      }

      for (final directory in _musicDirectories) {
        try {
          final files = await _scannerService.scanDirectory(directory);
          debugPrint('Found ${files.length} files in $directory');
          
          for (final filePath in files) {
            try {
              final metadata = await _scannerService.getFileMetadata(filePath);
              
              // Guard: 无效的元数据时跳过
              if (metadata.isEmpty || (metadata['title'] ?? '').isEmpty) {
                debugPrint('Skipping file with invalid metadata: $filePath');
                continue;
              }
              
              // 计算时长字符串（MM:SS）
              final durationMs = int.tryParse(metadata['duration'] ?? '0') ?? 0;
              final seconds = durationMs ~/ 1000;
              final minutes = seconds ~/ 60;
              final remainingSeconds = seconds % 60;
              final durationStr = '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
              
              // 创建 Song 对象并添加到列表
              final song = Song(
                title: metadata['title'] ?? 'Unknown',
                filePath: filePath,
                artist: metadata['artist'],
                album: metadata['album'],
                genre: metadata['genre'],
                duration: durationStr,
                durationMs: durationMs,
                dateAdded: DateTime.now(),
              );
              newSongs.add(song);
            } catch (e) {
              debugPrint('Error processing file $filePath: $e');
              // 继续处理下一个文件
            }
          }
        } catch (e) {
          debugPrint('Error scanning directory $directory: $e');
          // 继续处理下一个目录
        }
      }

      // 批量保存到数据库（去重：通过文件路径）
      if (newSongs.isNotEmpty) {
        try {
          await _dbService.addSongs(newSongs);
        } catch (e) {
          _errorMessage = 'Database save failed: $e';
          debugPrint('Database save error: $e');
        }
      }

      _songs.addAll(newSongs);
      debugPrint('Scanned ${_songs.length} audio files total');
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error scanning library: $e';
      debugPrint('Scan error: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Internal rescan without modifying directory list
  Future<void> _rescanLibrary() async {
    _songs.clear();
    await scanLibrary();
  }

  /// Get song by index
  Song? getSong(int index) {
    if (index >= 0 && index < _songs.length) {
      return _songs[index];
    }
    return null;
  }

  /// Get audio file by index (兼容旧 API)
  Map<String, String>? getAudioFile(int index) {
    final song = getSong(index);
    if (song != null) {
      return {
        'title': song.title,
        'artist': song.artist ?? 'Unknown',
        'path': song.filePath,
      };
    }
    return null;
  }

  /// Search songs by title or artist
  List<Song> searchSongs(String query) {
    final lowerQuery = query.toLowerCase();
    return _songs
        .where((song) =>
            song.title.toLowerCase().contains(lowerQuery) ||
            (song.artist?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  /// Search audio files (兼容旧 API)
  List<Map<String, String>> searchAudioFiles(String query) {
    return searchSongs(query)
        .map((song) => {
              'title': song.title,
              'artist': song.artist ?? 'Unknown',
              'path': song.filePath,
            })
        .toList();
  }
}
