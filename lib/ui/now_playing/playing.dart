import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicflutter/data/modal/song.dart';
import 'package:rxdart/rxdart.dart';

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
  int _currentIndex = 0; // Chỉ số bài hát hiện tại
  bool _isRepeat = false; // Trạng thái lặp lại
  bool _isShuffle = false; // Trạng thái phát ngẫu nhiên

  @override
  void initState() {
    super.initState();
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _currentIndex = widget.songs.indexOf(widget.playingSong);
    _audioPlayerManager = AudioPlayerManager(
      songUrl: widget.playingSong.source,
    );
    _audioPlayerManager.init().then((_) {
      _audioPlayerManager.player.play();
      _imageAnimController.repeat();

      // Set up completion listener for auto-advancing to next song
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
    _audioPlayerManager.dispose();
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

    // Stop current playback
    _audioPlayerManager.player.stop();

    // Set new URL instead of recreating the player
    _audioPlayerManager.setUrl(widget.songs[index].source).then((_) {
      _audioPlayerManager.player.play();
      _imageAnimController.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
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
                  // Thay Row bằng Wrap
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8.0, // Khoảng cách ngang giữa các nút
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
                      iconSize: 24, // Giảm kích thước icon
                      onPressed: () {
                        setState(() {
                          _isRepeat = !_isRepeat;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 32,
                      color:
                          isDarkMode
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                      onPressed: _playPreviousSong,
                    ),
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayerManager.player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final playing = playerState?.playing ?? false;
                        return IconButton(
                          icon: Icon(
                            playing ? Icons.pause_circle : Icons.play_circle,
                          ),
                          iconSize: 48, // Giảm từ 64 xuống 48
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
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

                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 32,
                      color:
                          isDarkMode
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                      onPressed: _playNextSong,
                    ),
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
                      iconSize: 24, // Giảm kích thước icon
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

class AudioPlayerManager {
  AudioPlayerManager({required this.songUrl});

  final AudioPlayer player = AudioPlayer();
  late Stream<DurationState> durationState;
  String songUrl;

  Future<void> init() async {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
    await player.setUrl(songUrl);
  }

  Future<void> setUrl(String url) async {
    songUrl = url;
    await player.setUrl(url);
  }

  void dispose() {
    player.dispose();
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration? total;
}
