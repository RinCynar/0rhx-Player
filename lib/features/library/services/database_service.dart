import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rhx_player/features/library/models/song.dart';
import 'package:rhx_player/features/library/models/album.dart';
import 'package:rhx_player/features/library/models/artist.dart';

/// Isar 数据库管理服务
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Isar _isar;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  /// 初始化数据库
  Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [SongSchema, AlbumSchema, ArtistSchema],
        directory: dir.path,
        inspector: false, // 禁用检查器以加快启动
      );
    } catch (e) {
      throw Exception('Database initialization failed: $e');
    }
  }

  /// 获取 Isar 实例
  Isar get db => _isar;

  /// 关闭数据库
  Future<void> close() async {
    await _isar.close();
  }

  // ========== Song 操作 ==========

  /// 添加或更新歌曲
  Future<int> addSong(Song song) async {
    return _isar.writeTxn(() async {
      return _isar.songs.put(song);
    });
  }

  /// 批量添加歌曲
  Future<List<int>> addSongs(List<Song> songs) async {
    return _isar.writeTxn(() async {
      return _isar.songs.putAll(songs);
    });
  }

  /// 获取所有歌曲
  Future<List<Song>> getAllSongs() async {
    return _isar.songs.where().findAll();
  }

  /// 按标题搜索歌曲
  Future<List<Song>> searchSongsByTitle(String title) async {
    final songs = await _isar.songs.where().findAll();
    return songs
        .where((s) => s.title.toLowerCase().contains(title.toLowerCase()))
        .toList();
  }

  /// 删除歌曲
  Future<bool> deleteSong(int id) async {
    return _isar.writeTxn(() async {
      return _isar.songs.delete(id);
    });
  }

  /// 清空所有歌曲
  Future<void> clearAllSongs() async {
    await _isar.writeTxn(() async {
      await _isar.songs.clear();
    });
  }

  // ========== Album 操作 ==========

  /// 添加或更新专辑
  Future<int> addAlbum(Album album) async {
    return _isar.writeTxn(() async {
      return _isar.albums.put(album);
    });
  }

  /// 批量添加专辑
  Future<List<int>> addAlbums(List<Album> albums) async {
    return _isar.writeTxn(() async {
      return _isar.albums.putAll(albums);
    });
  }

  /// 获取所有专辑
  Future<List<Album>> getAllAlbums() async {
    return _isar.albums.where().findAll();
  }

  /// 按艺术家获取专辑
  Future<List<Album>> getAlbumsByArtist(String artist) async {
    final albums = await _isar.albums.where().findAll();
    return albums
        .where((a) => a.artist?.toLowerCase() == artist.toLowerCase())
        .toList();
  }

  /// 删除专辑
  Future<bool> deleteAlbum(int id) async {
    return _isar.writeTxn(() async {
      return _isar.albums.delete(id);
    });
  }

  // ========== Artist 操作 ==========

  /// 添加或更新艺术家
  Future<int> addArtist(Artist artist) async {
    return _isar.writeTxn(() async {
      return _isar.artists.put(artist);
    });
  }

  /// 批量添加艺术家
  Future<List<int>> addArtists(List<Artist> artists) async {
    return _isar.writeTxn(() async {
      return _isar.artists.putAll(artists);
    });
  }

  /// 获取所有艺术家
  Future<List<Artist>> getAllArtists() async {
    return _isar.artists.where().findAll();
  }

  /// 删除艺术家
  Future<bool> deleteArtist(int id) async {
    return _isar.writeTxn(() async {
      return _isar.artists.delete(id);
    });
  }

  // ========== 数据库统计 ==========

  /// 获取数据库统计信息
  Future<Map<String, int>> getStatistics() async {
    final songs = await _isar.songs.count();
    final albums = await _isar.albums.count();
    final artists = await _isar.artists.count();

    return {
      'songs': songs,
      'albums': albums,
      'artists': artists,
    };
  }
}
