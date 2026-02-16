import 'package:isar/isar.dart';

part 'artist.g.dart';

@collection
class Artist {
  Id id = Isar.autoIncrement;

  /// 艺术家名称
  late String name;

  /// 艺术家的歌曲数量
  int songCount = 0;

  /// 艺术家的专辑数量
  int albumCount = 0;

  /// 创建时间
  late DateTime dateAdded;

  Artist({
    required this.name,
    this.songCount = 0,
    this.albumCount = 0,
    required this.dateAdded,
  });
}
