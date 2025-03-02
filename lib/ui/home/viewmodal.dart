import 'dart:async';

import 'package:musicflutter/data/modal/song.dart';
import 'package:musicflutter/data/responsitory/responsitory.dart';
class MusicAppViewModal {
  StreamController<List<Song>> songStream = StreamController();
  void loadSong()
  {
    final repository = DefaultRepository();
    repository.loadData().then((value) => songStream.add(value!));
  }

  void playSong(Song song) {
    print('Playing song: ${song.title}');
  }


}