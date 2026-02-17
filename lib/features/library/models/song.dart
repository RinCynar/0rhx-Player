import 'package:isar/isar.dart';

part 'song.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;

  /// 歌曲标题
  late String title;

  /// 歌曲文件路径
  late String filePath;

  /// 艺术家名称
  String? artist;

  /// 专辑名称
  String? album;

  /// 流派/风格
  String? genre;

  /// 歌曲时长（格式化为 MM:SS）
  late String duration;

  /// 歌曲时长（毫秒）
  late int durationMs;

  /// 是否收藏
  bool isFavorite = false;

  /// 播放计数
  int playCount = 0;

  /// 最后播放时间
  DateTime? lastPlayedAt;

  /// 添加时间
  late DateTime dateAdded;

  /// 修改时间
  DateTime? dateModified;

  /// 封面艺术文件路径（在应用缓存目录中）
  String? coverArtPath;

  Song({
    required this.title,
    required this.filePath,
    this.artist,
    this.album,
    this.genre,
    required this.duration,
    required this.durationMs,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayedAt,
    required this.dateAdded,
    this.dateModified,
    this.coverArtPath,
  });
}
