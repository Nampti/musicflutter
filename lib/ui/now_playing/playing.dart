import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicflutter/data/modal/song.dart';
import 'package:rxdart/rxdart.dart';
import 'package:musicflutter/ui/now_playing/audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  final Song playingSong;
  final List<Song> songs;

  const NowPlaying({super.key, required this.playingSong, required this.songs});

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(songs: songs, playingSong: playingSong);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final List<Song> songs;
  final Song playingSong;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  int _currentIndex = 0;
  bool _isRepeat = false;
  bool _isShuffle = false;

  @override
  void initState() {
    super.initState();
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _currentIndex = widget.songs.indexOf(widget.playingSong);
    _audioPlayerManager = AudioPlayerManager(); // Sử dụng singleton
    _audioPlayerManager.init().then((_) {
      // Kiểm tra nếu bài hát hiện tại đang phát, tiếp tục từ vị trí hiện tại
      if (_audioPlayerManager.songUrl == widget.playingSong.source &&
          _audioPlayerManager.player.playing) {
        _imageAnimController.repeat(); // Tiếp tục animation
      } else if (_audioPlayerManager.songUrl == widget.playingSong.source &&
          !_audioPlayerManager.player.playing) {
        _audioPlayerManager.player
            .play(); // Tiếp tục từ vị trí hiện tại nếu tạm dừng
        _imageAnimController.repeat();
      } else {
        _audioPlayerManager.stop(); // Dừng nếu không khớp
        _audioPlayerManager.setUrl(widget.playingSong.source).then((_) {
          _audioPlayerManager.player.play();
          _imageAnimController.repeat();
        });
      }

      _audioPlayerManager.player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (_isRepeat) {
            _audioPlayerManager.player.seek(Duration.zero);
            _audioPlayerManager.player.play();
          } else {
            _playNextSong();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _imageAnimController.dispose();
    // Không dispose AudioPlayerManager để giữ trạng thái cho MiniPlayer
    super.dispose();
  }

  void _playNextSong() {
    if (_isShuffle) {
      _currentIndex = Random().nextInt(widget.songs.length);
    } else {
      _currentIndex = (_currentIndex + 1) % widget.songs.length;
    }
    _playSongAtIndex(_currentIndex);
  }

  void _playPreviousSong() {
    _currentIndex =
        (_currentIndex - 1) < 0 ? widget.songs.length - 1 : _currentIndex - 1;
    _playSongAtIndex(_currentIndex);
  }

  void _playSongAtIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
    _audioPlayerManager.stop();
    _audioPlayerManager.setUrl(widget.songs[index].source).then((_) {
      _audioPlayerManager.player.play();
      _imageAnimController.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.songs[_currentIndex]);
        return false;
      },
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Now Playing'),
          trailing: Icon(CupertinoIcons.ellipsis),
        ),
        child: Material(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildImage(),
                  _buildSongInfo(isDarkMode),
                  _buildProgressBar(isDarkMode),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/itune.png',
            image: widget.songs[_currentIndex].image,
            width: screenWidth - delta,
            height: screenWidth - delta,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/itune.png',
                width: screenWidth - delta,
                height: screenWidth - delta,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 64, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
            color:
                isDarkMode
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
          ),
          Column(
            children: [
              Text(
                widget.songs[_currentIndex].title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.songs[_currentIndex].artist,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            color:
                isDarkMode
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;

          return Column(
            children: [
              Slider(
                value: progress.inSeconds.toDouble(),
                min: 0.0,
                max: total.inSeconds.toDouble(),
                activeColor:
                    isDarkMode
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                inactiveColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                onChanged: (value) {
                  _audioPlayerManager.player.seek(
                    Duration(seconds: value.toInt()),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(progress),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                  Text(
                    _formatDuration(total),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color:
                            _isRepeat
                                ? (isDarkMode
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary)
                                : (isDarkMode ? Colors.grey[400] : Colors.grey),
                      ),
                      iconSize: 24,
                      onPressed: () {
                        setState(() {
                          _isRepeat = !_isRepeat;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 32,
                      color:
                          isDarkMode
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                      onPressed: _playPreviousSong,
                    ),
                    const SizedBox(width: 24),
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayerManager.player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final playing = playerState?.playing ?? false;
                        return IconButton(
                          icon: Icon(
                            playing ? Icons.pause_circle : Icons.play_circle,
                          ),
                          iconSize: 48,
                          color: isDarkMode ? Colors.teal[200] : Colors.teal,
                          onPressed: () {
                            if (playing) {
                              _audioPlayerManager.player.pause();
                              _imageAnimController.stop();
                            } else {
                              _audioPlayerManager.player.play();
                              _imageAnimController.repeat();
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 32,
                      color:
                          isDarkMode
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                      onPressed: _playNextSong,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color:
                            _isShuffle
                                ? (isDarkMode
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary)
                                : (isDarkMode ? Colors.grey[400] : Colors.grey),
                      ),
                      iconSize: 24,
                      onPressed: () {
                        setState(() {
                          _isShuffle = !_isShuffle;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
