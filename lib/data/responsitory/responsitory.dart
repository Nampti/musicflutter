import 'package:musicflutter/data/modal/song.dart';
import 'package:musicflutter/data/source/source.dart';

abstract interface class Responsitory {
  Future<List<Song>?> loadData();
}
class DefaultRepository implements Responsitory {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    try {
      final remoteSongs = await _remoteDataSource.loadData();
      if (remoteSongs != null) {
        songs.addAll(remoteSongs);
      } else {
        throw Exception('Remote data is null');
      }
    } catch (e) {
      // If remote data fails, load local data
      final localSongs = await _localDataSource.loadData();
      if (localSongs != null) {
        songs.addAll(localSongs);
      }
    }
    return songs;
  }
}