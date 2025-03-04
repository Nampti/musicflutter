import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicflutter/data/modal/song.dart';
import 'package:musicflutter/ui/ad/InterstitialAdWidget.dart';
import 'package:musicflutter/ui/home/viewmodal.dart';
import 'package:musicflutter/ui/now_playing/playing.dart';
import 'package:musicflutter/ui/now_playing/audio_player_manager.dart';

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
  int _currentIndex = 0;

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
      builder: (context) {
        return const Text('Bottom Sheet');
      },
    );
  }

  void navigate(Song song) {
    _currentPlayingSong = song;
    final audioManager = AudioPlayerManager();

    // Chỉ setUrl và play nếu là bài hát mới hoặc chưa phát
    if (audioManager.songUrl != song.source) {
      audioManager.stop();
      audioManager.setUrl(song.source).then((_) {
        audioManager.player.play();
      });
    } else if (!audioManager.player.playing) {
      audioManager.player.play(); // Tiếp tục phát nếu đã tạm dừng
    }

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

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Show interstitial ad at natural break points
    if (index == 1 || index == 2) {
      // Show interstitial ad when switching to Discovery or Account tab
      showDialog(
        context: context,
        builder: (context) => const InterstitialAdWidget(),
      );
    }
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
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    _currentPlayingSong!.image,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/itune.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _currentPlayingSong!.artist,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
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
                        AudioPlayerManager().pause();
                      } else {
                        AudioPlayerManager().play();
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
                    AudioPlayerManager().stop();
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
        parent._onTabChanged;
      },
    );
  }
}
