import 'package:isar/isar.dart';

part 'album.g.dart';

@collection
class Album {
  Id id = Isar.autoIncrement;

  /// 专辑名称
  late String name;

  /// 艺术家名称
  String? artist;

  /// 发行年份
  int? releaseYear;

  /// 专辑中的歌曲数量
  int songCount = 0;

  /// 专辑封面路径（如果有）
  String? coverPath;

  /// 创建时间
  late DateTime dateAdded;

  Album({
    required this.name,
    this.artist,
    this.releaseYear,
    this.songCount = 0,
    this.coverPath,
    required this.dateAdded,
  });
}
