import 'package:flutter/material.dart';
import 'package:musicflutter/data/modal/song.dart';
import 'package:musicflutter/ui/home/viewmodal.dart';

class NowPlaying extends StatelessWidget {
  final Song playingSong;
  final List<Song> songs;

  const NowPlaying({super.key, required this.playingSong, required this.songs});

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong);
  }
}
class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key, required this.songs, required this.playingSong});

  final List<Song> songs;
  final Song playingSong;
  

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}
class _NowPlayingPageState extends State<NowPlayingPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: const Center(
        child: Text('Now Playing'),
      ),
    );
  }
  
   
  
}