import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;

  AudioPlayerManager._internal();

  final AudioPlayer player = AudioPlayer();
  late Stream<DurationState> durationState;
  String? songUrl;

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
    if (songUrl != null) await player.setUrl(songUrl!);
  }

  Future<void> setUrl(String url) async {
    songUrl = url;
    await player.stop(); // Dừng bài hiện tại
    await player.setUrl(url);
  }

  void stop() {
    player.stop();
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
