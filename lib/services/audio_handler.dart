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
    // Propaga stato del player ad audio_service (notifiche, lock screen, ecc.)
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
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
  void updateMediaItem({
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
      isLiveStream: true,
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
    return super.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
