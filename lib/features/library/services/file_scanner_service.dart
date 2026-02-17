import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';

class FileScannerService {
  final List<String> supportedFormats = ['.mp3', '.flac', '.wav', '.aac', '.m4a'];

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
        if (entity is File) {
          final ext = entity.path.toLowerCase().split('.').last;
          if (supportedFormats.contains('.$ext')) {
            results.add(entity.path);
          }
        } else if (entity is Directory) {
          // Recursively scan subdirectories
          await _scanRecursive(entity, results);
        }
      }
    } catch (e) {
      debugPrint('Error scanning directory: $e');
    }
  }

  /// Get file metadata using metadata_god library
  Future<Map<String, String>> getFileMetadata(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = file.path.split(Platform.pathSeparator).last;
      final parts = fileName.split('.');
      final defaultTitle = parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.') : fileName;

      // Try to extract metadata using metadata_god
      try {
        final metadata = await MetadataGod.readMetadata(file: filePath);
        
        if (metadata != null) {
          // Extract duration in milliseconds
          int durationMs = (metadata.durationMs ?? 0).toInt();

          return {
            'title': (metadata.title?.isNotEmpty ?? false) ? metadata.title! : defaultTitle,
            'artist': (metadata.artist?.isNotEmpty ?? false) ? metadata.artist! : 'Unknown',
            'duration': durationMs.toString(),
            'album': (metadata.album?.isNotEmpty ?? false) ? metadata.album! : 'Unknown',
            'genre': (metadata.genre?.isNotEmpty ?? false) ? metadata.genre! : 'Unknown',
            'path': filePath,
          };
        }
      } catch (e) {
        debugPrint('Metadata extraction failed for $filePath: $e, using filename fallback');
      }

      // Fallback to filename-based metadata if extraction fails
      return {
        'title': defaultTitle,
        'artist': 'Unknown',
        'duration': '0',
        'album': 'Unknown',
        'genre': 'Unknown',
        'path': filePath,
      };
    } catch (e) {
      debugPrint('Error getting metadata: $e');
      return {};
    }
  }
}
