import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// AudioHandler per Stereo 98 DAB+
/// Gestisce background audio e notifiche media con just_audio + audio_service.
class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer(
    audioLoadConfiguration: AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: const Duration(seconds: 15),
        maxBufferDuration: const Duration(seconds: 50),
        bufferForPlaybackDuration: const Duration(seconds: 5),
        bufferForPlaybackAfterRebufferDuration: const Duration(seconds: 10),
      ),
    ),
  );

  AudioPlayer get player => _player;

  RadioAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        // Solo play/pause — niente altro per radio live
        if (_player.playing) MediaControl.pause else MediaControl.play,
      ],
      // Solo play e pause, niente stop/skip
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

  /// Aggiorna i metadati visualizzati nella notifica
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
    await _player.pause();
    // Usiamo pause invece di stop per non mandare il player in idle
    // Così al prossimo play non serve rifare setUrl
  }

  Future<void> fullStop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
