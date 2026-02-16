import 'dart:io';
import 'package:flutter/foundation.dart';

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

  /// Get file metadata (title, duration, etc.)
  Future<Map<String, String>> getFileMetadata(String filePath) async {
    try {
      final file = File(filePath);
      final name = file.path.split(Platform.pathSeparator).last;
      final parts = name.split('.');
      final title = parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.') : name;

      return {
        'title': title,
        'artist': 'Unknown',
        'path': filePath,
      };
    } catch (e) {
      debugPrint('Error getting metadata: $e');
      return {};
    }
  }
}
