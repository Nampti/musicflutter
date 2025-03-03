import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicflutter/data/modal/song.dart';
import 'package:musicflutter/ui/discovery/discovery.dart';
import 'package:musicflutter/ui/home/viewmodal.dart';
import 'package:musicflutter/ui/now_playing/playing.dart';
import 'package:musicflutter/ui/settings/settings.dart';
import 'package:musicflutter/ui/user/user.dart';
import 'package:musicflutter/ui/now_playing/audio_player_manager.dart'; // Import singleton

class MusicAppp extends StatelessWidget {
  const MusicAppp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Music App')),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.album),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModal _viewModal;
  Song? _currentPlayingSong;
  bool _isMiniPlayerVisible = false;

  @override
  void initState() {
    super.initState();
    _viewModal = MusicAppViewModal();
    _viewModal.loadSong();
    observeData();
  }

  @override
  void dispose() {
    _viewModal.songStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          getBody(),
          if (_isMiniPlayerVisible && _currentPlayingSong != null)
            _buildMiniPlayer(),
        ],
      ),
    );
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(child: CircularProgressIndicator());
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _songItemSection(song: songs[index], parent: this);
  }

  void observeData() {
    _viewModal.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.grey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Modal Bottom Sheet'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close Bottom Sheet'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigate(Song song) {
    _currentPlayingSong = song;
    // Stop any existing playback before navigating
    AudioPlayerManager().stop();
    AudioPlayerManager().setUrl(song.source).then((_) {
      AudioPlayerManager().player.play();
    });

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => NowPlaying(songs: songs, playingSong: song),
      ),
    ).then((value) {
      if (value is Song) {
        setState(() {
          _currentPlayingSong = value;
          _isMiniPlayerVisible = true;
        });
      }
    });
  }

  Widget _buildMiniPlayer() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          if (_currentPlayingSong != null) {
            navigate(_currentPlayingSong!);
          }
        },
        child: Container(
          height: 60,
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/itune.png',
                    image: _currentPlayingSong!.image,
                    width: 44,
                    height: 44,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/itune.png',
                        width: 44,
                        height: 44,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPlayingSong!.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _currentPlayingSong!.artist,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder<PlayerState>(
                stream: AudioPlayerManager().player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final playing = playerState?.playing ?? false;
                  return IconButton(
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (playing) {
                        AudioPlayerManager().player.pause();
                      } else {
                        AudioPlayerManager().player.play();
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isMiniPlayerVisible = false;
                    _currentPlayingSong = null;
                    AudioPlayerManager()
                        .stop(); // Stop music when closing MiniPlayer
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _songItemSection extends StatelessWidget {
  const _songItemSection({required this.song, required this.parent});
  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 24, right: 16),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itune.png',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/itune.png', width: 48, height: 48);
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        onPressed: () {
          parent.showBottomSheet();
        },
        icon: const Icon(Icons.more_horiz),
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
