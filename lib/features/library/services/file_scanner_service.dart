import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path_provider/path_provider.dart';

class FileScannerService {
  final List<String> supportedFormats = [
    '.mp3',
    '.flac',
    '.wav',
    '.aac',
    '.m4a',
  ];
  late Directory _cacheDir;
  bool _cacheInitialized = false;

  /// Initialize cache directory for cover art
  Future<void> _initCacheDir() async {
    if (_cacheInitialized) return;
    try {
      _cacheDir = await getApplicationCacheDirectory();
      final coversDir = Directory('${_cacheDir.path}/covers');
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }
      _cacheInitialized = true;
    } catch (e) {
      debugPrint('Error initializing cache directory: $e');
    }
  }

  /// Scan directory for audio files
  Future<List<String>> scanDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      final audioFiles = <String>[];

      if (!await directory.exists()) {
        debugPrint('Directory does not exist: $directoryPath');
        return audioFiles;
      }

      // Recursively scan all subdirectories
      await _scanRecursive(directory, audioFiles);

      debugPrint('Found ${audioFiles.length} audio files');
      return audioFiles;
    } catch (e) {
      debugPrint('Error scanning directory: $e');
      return [];
    }
  }

  Future<void> _scanRecursive(Directory directory, List<String> results) async {
    try {
      final entities = await directory.list().toList();

      for (final entity in entities) {
        try {
          if (entity is File) {
            final ext = entity.path.toLowerCase().split('.').last;
            if (supportedFormats.contains('.$ext')) {
              results.add(entity.path);
            }
          } else if (entity is Directory) {
            // Recursively scan subdirectories
            await _scanRecursive(entity, results);
          }
        } catch (e) {
          // 跳过无法访问的文件/目录，继续扫描
          debugPrint('Error accessing entity ${entity.path}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error listing directory contents: $e');
      // 非致命错误，允许扫描继续
    }
  }

  /// Get file metadata from audio file using audio_metadata_reader
  Future<Map<String, dynamic>> getFileMetadata(String filePath) async {
    try {
      await _initCacheDir();
      return await compute(_extractMetadataStatic, {
        'filePath': filePath,
        'cacheDirPath': _cacheDir.path,
      });
    } catch (e) {
      debugPrint('Error getting metadata: $e');
      return {};
    }
  }

  /// Batch extract metadata for multiple files
  Future<List<Map<String, dynamic>>> getMultipleFilesMetadata(
    List<String> filePaths,
  ) async {
    try {
      await _initCacheDir();
      return await compute(_extractBatchMetadataStatic, {
        'filePaths': filePaths,
        'cacheDirPath': _cacheDir.path,
      });
    } catch (e) {
      debugPrint('Error getting batch metadata: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> _extractBatchMetadataStatic(
    Map<String, dynamic> params,
  ) async {
    final List<String> filePaths = params['filePaths'];
    final String cacheDirPath = params['cacheDirPath'];
    final results = <Map<String, dynamic>>[];

    for (final path in filePaths) {
      results.add(
        await _extractMetadataStatic({
          'filePath': path,
          'cacheDirPath': cacheDirPath,
        }),
      );
    }
    return results;
  }

  static Future<Map<String, dynamic>> _extractMetadataStatic(
    Map<String, dynamic> params,
  ) async {
    final String filePath = params['filePath'];
    final String cacheDirPath = params['cacheDirPath'];

    try {
      final file = File(filePath);
      final fileName = file.path.split(Platform.pathSeparator).last;
      final parts = fileName.split('.');
      final defaultTitle = parts.length > 1
          ? parts.sublist(0, parts.length - 1).join('.')
          : fileName;

      try {
        final metadata = readMetadata(file, getImage: true);

        String title =
            _getMetadataStringStatic(metadata, 'title') ?? defaultTitle;
        String artist =
            _getMetadataStringStatic(metadata, 'artist') ?? 'Unknown';
        String album = _getMetadataStringStatic(metadata, 'album') ?? 'Unknown';
        String genre = _getMetadataStringStatic(metadata, 'genre') ?? 'Unknown';
        String duration = _getMetadataDurationStatic(metadata);
        final Uint8List? coverArtBytes = _getMetadataImageStatic(metadata);
        String? coverArtPath;

        if (coverArtBytes != null && coverArtBytes.isNotEmpty) {
          try {
            coverArtPath = await _saveCoverArtStatic(
              filePath,
              coverArtBytes,
              cacheDirPath,
            );
          } catch (e) {
            // Log in debug if possible, but we don't have debugPrint easily in compute without extra effort
          }
        }

        return {
          'title': title,
          'artist': artist,
          'duration': duration,
          'album': album,
          'genre': genre,
          'path': filePath,
          'coverArtPath': coverArtPath,
        };
      } catch (e) {
        return {
          'title': defaultTitle,
          'artist': 'Unknown',
          'duration': '0',
          'album': 'Unknown',
          'genre': 'Unknown',
          'path': filePath,
          'coverArtPath': null,
        };
      }
    } catch (e) {
      return {};
    }
  }

  static String? _getMetadataStringStatic(dynamic metadata, String field) {
    try {
      if (metadata == null) return null;
      switch (field.toLowerCase()) {
        case 'title':
          if (metadata.title is String) return metadata.title;
          if (metadata.songName is String) return metadata.songName;
          break;
        case 'artist':
          if (metadata.artist is String) return metadata.artist;
          if (metadata.trackArtist is String) return metadata.trackArtist;
          break;
        case 'album':
          if (metadata.album is String) return metadata.album;
          if (metadata.albumName is String) return metadata.albumName;
          break;
        case 'genre':
          if (metadata.genre is String) return metadata.genre;
          if (metadata.genres is List && (metadata.genres as List).isNotEmpty) {
            return (metadata.genres as List).first.toString();
          }
          break;
      }
    } catch (_) {}
    return null;
  }

  static String _getMetadataDurationStatic(dynamic metadata) {
    try {
      if (metadata == null) return '0';
      if (metadata.duration is Duration) {
        return metadata.duration.inMilliseconds.toString();
      } else if (metadata.durationMs is int) {
        return metadata.durationMs.toString();
      }
    } catch (_) {}
    return '0';
  }

  static Uint8List? _getMetadataImageStatic(dynamic metadata) {
    try {
      if (metadata == null) return null;
      if (metadata.pictures != null && (metadata.pictures as List).isNotEmpty) {
        final picture = (metadata.pictures as List).first;
        try {
          if (picture.bytes is Uint8List) return picture.bytes as Uint8List;
        } catch (_) {}
        try {
          if (picture.pictureData is Uint8List) {
            return picture.pictureData as Uint8List;
          }
        } catch (_) {}
        try {
          if (picture.data is Uint8List) return picture.data as Uint8List;
        } catch (_) {}
      }
      try {
        if (metadata.image is Uint8List) return metadata.image as Uint8List;
      } catch (_) {}
      try {
        if (metadata.coverImage is Uint8List) {
          return metadata.coverImage as Uint8List;
        }
      } catch (_) {}
    } catch (_) {}
    return null;
  }

  static Future<String?> _saveCoverArtStatic(
    String audioFilePath,
    Uint8List imageBytes,
    String cacheDirPath,
  ) async {
    try {
      final fileName =
          '${audioFilePath.hashCode.toUnsigned(32).toRadixString(16)}.jpg';
      final coverFile = File('$cacheDirPath/covers/$fileName');
      if (!await coverFile.exists()) {
        await coverFile.writeAsBytes(imageBytes);
      }
      return coverFile.path;
    } catch (_) {
      return null;
    }
  }
}
