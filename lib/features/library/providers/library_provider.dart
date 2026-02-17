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
  List<Map<String, String>> get audioFiles => _songs
      .map(
        (song) => {
          'title': song.title,
          'artist': song.artist ?? 'Unknown',
          'path': song.filePath,
        },
      )
      .toList();

  /// 初始化库（加载已保存的歌曲）
  Future<void> initialize() async {
    debugPrint('[LIBRARY] initialize() called, _isInitialized=$_isInitialized');
    if (_isInitialized) {
      debugPrint('[LIBRARY] Already initialized, returning');
      return;
    }

    try {
      debugPrint('[LIBRARY] Calling DatabaseService.initialize()...');
      await _dbService.initialize();
      debugPrint('[LIBRARY] Database initialized, loading songs...');

      final songs = await _dbService.getAllSongs();
      debugPrint('[LIBRARY] Loaded ${songs.length} songs from database');

      _songs.addAll(songs);
      _isInitialized = true;
      _errorMessage = null;
      debugPrint('[LIBRARY] Library initialization completed');
      notifyListeners();
    } catch (e) {
      // 数据库失败时，使用内存模式
      debugPrint('[LIBRARY] Database error: $e, using in-memory mode');
      _isInitialized = true;
      _errorMessage = 'Database unavailable: running in memory-only mode';
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

      final List<String> allFilePaths = [];
      for (final directory in _musicDirectories) {
        try {
          final files = await _scannerService.scanDirectory(directory);
          allFilePaths.addAll(files);
        } catch (e) {
          debugPrint('Error scanning directory $directory: $e');
        }
      }

      if (allFilePaths.isEmpty) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      // Extract metadata in batch (runs in background isolate)
      final metadataList = await _scannerService.getMultipleFilesMetadata(
        allFilePaths,
      );

      final currentNewSongs = <Song>[];
      for (int i = 0; i < metadataList.length; i++) {
        final metadata = metadataList[i];
        final filePath = allFilePaths[i];

        if (metadata.isEmpty || (metadata['title'] ?? '').isEmpty) continue;

        // 计算时长字符串（MM:SS）
        final durationMs = int.tryParse(metadata['duration'] ?? '0') ?? 0;
        final seconds = durationMs ~/ 1000;
        final minutes = seconds ~/ 60;
        final remainingSeconds = seconds % 60;
        final durationStr =
            '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';

        final song = Song(
          title: metadata['title'] ?? 'Unknown',
          filePath: filePath,
          artist: metadata['artist'],
          album: metadata['album'],
          genre: metadata['genre'],
          duration: durationStr,
          durationMs: durationMs,
          coverArtPath: metadata['coverArtPath'],
          dateAdded: DateTime.now(),
        );
        currentNewSongs.add(song);

        // 每 20 个文件通知一次 UI，或者最后一次
        if (currentNewSongs.length % 20 == 0 || i == metadataList.length - 1) {
          _songs.clear();
          _songs.addAll(currentNewSongs);
          notifyListeners();
        }
      }

      // 批量保存到数据库（去重：通过文件路径）
      if (currentNewSongs.isNotEmpty) {
        try {
          await _dbService.addSongs(currentNewSongs);
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
        .where(
          (song) =>
              song.title.toLowerCase().contains(lowerQuery) ||
              (song.artist?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList();
  }

  /// Search audio files (兼容旧 API)
  List<Map<String, String>> searchAudioFiles(String query) {
    return searchSongs(query)
        .map(
          (song) => {
            'title': song.title,
            'artist': song.artist ?? 'Unknown',
            'path': song.filePath,
          },
        )
        .toList();
  }
}
