import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer(
    audioLoadConfiguration: AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: const Duration(seconds: 5),
        maxBufferDuration: const Duration(seconds: 10),
        bufferForPlaybackDuration: const Duration(seconds: 3),
        bufferForPlaybackAfterRebufferDuration: const Duration(seconds: 5),
      ),
    ),
  );

  AudioPlayer get player => _player;
  bool _wasPlayingBeforeInterruption = false;

  RadioAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _initAudioSession();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));

    // Gestione interruzioni (telefonata, navigatore, ecc.)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        _wasPlayingBeforeInterruption = _player.playing;
        if (_player.playing) {
          _player.pause();
        }
      } else {
        if (_wasPlayingBeforeInterruption) {
          _player.play();
          _wasPlayingBeforeInterruption = false;
        }
      }
    });

    // Cuffie scollegate → pausa
    session.becomingNoisyEventStream.listen((_) {
      if (_player.playing) {
        _player.pause();
      }
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        if (_player.playing) MediaControl.pause else MediaControl.play,
      ],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
      },
      androidCompactActionIndices: const [0],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
    );
  }

  void updateNowPlaying({
    required String title,
    required String artist,
    Uri? artworkUri,
  }) {
    mediaItem.add(MediaItem(
      id: 'stereo98_live',
      album: 'Stereo 98 DAB+',
      title: title,
      artist: artist,
      artUri: artworkUri,
    ));
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  // Quando l'utente swipe-via la notifica, Android chiama questo
  @override
  Future<void> onTaskRemoved() async {
    await _player.stop();
    await super.onTaskRemoved();
  }

  Future<void> fullStop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
