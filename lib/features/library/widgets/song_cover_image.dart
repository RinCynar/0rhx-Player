import 'dart:io';
import 'package:flutter/material.dart';

/// Widget to display a song's cover art with fallback to placeholder
class SongCoverImage extends StatefulWidget {
  final String? coverArtPath;
  final double size;
  final double? width;
  final double? height;
  final double borderRadius;

  const SongCoverImage({
    super.key,
    this.coverArtPath,
    this.size = 100,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  State<SongCoverImage> createState() => _SongCoverImageState();
}

class _SongCoverImageState extends State<SongCoverImage> {
  late Future<bool> _fileExistsFuture;
  static final Map<String, bool> _existenceCache = {};

  @override
  void initState() {
    super.initState();
    _fileExistsFuture = _checkFileExists();
  }

  @override
  void didUpdateWidget(SongCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coverArtPath != widget.coverArtPath) {
      _fileExistsFuture = _checkFileExists();
    }
  }

  Future<bool> _checkFileExists() async {
    final path = widget.coverArtPath;
    if (path == null || path.isEmpty) {
      return false;
    }

    // Check memory cache first
    if (_existenceCache.containsKey(path)) {
      return _existenceCache[path]!;
    }

    try {
      final exists = await File(path).exists();
      _existenceCache[path] = exists;
      return exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayWidth = widget.width ?? widget.size;
    final displayHeight = widget.height ?? widget.size;

    return Container(
      width: displayWidth,
      height: displayHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: FutureBuilder<bool>(
        future: _fileExistsFuture,
        builder: (context, snapshot) {
          // If file exists and we have a path, show the image
          if (snapshot.hasData &&
              snapshot.data == true &&
              widget.coverArtPath != null) {
            // Calculate cache size (standard DPI is usually 2 or 3 on modern displays)
            // We'll use a conservative 2.0 multiplier for better quality
            // Ensure width is finite before calling toInt()
            int? cacheSize;
            final width = widget.width ?? widget.size;
            if (width.isFinite && width > 0) {
              cacheSize = (width * 2.0).toInt();
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Image.file(
                File(widget.coverArtPath!),
                fit: BoxFit.cover,
                cacheWidth: cacheSize,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(context);
                },
              ),
            );
          }

          // Fallback to placeholder
          return _buildPlaceholder(context);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Icon(
      Icons.music_note,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
      size: _getPlaceholderIconSize(),
    );
  }

  double _getPlaceholderIconSize() {
    final size = (widget.width ?? widget.size);
    if (size < 50) return 20;
    if (size < 100) return 30;
    if (size < 200) return 40;
    return 80;
  }
}
