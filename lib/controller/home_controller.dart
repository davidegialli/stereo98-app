import 'dart:async';
import 'dart:convert';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:stereo98/services/audio_handler.dart';

class HomeController extends GetxController {
  late final RadioAudioHandler _audioHandler;
  AudioPlayer get player => _audioHandler.player;

  Timer? timer;
  Timer? _palinsestoTimer;
  Timer? _artworkRetryTimer;

  var isPressed = false.obs;
  var isLoading = false.obs;
  late AnimateIconController controller;
  var isDarkMode = false.obs;

  var titleValue = ''.obs;
  var artistValue = ''.obs;
  var showName = ''.obs;
  var showImage = ''.obs;
  var showDescription = ''.obs;
  var nextShowName = ''.obs;
  var nextShowTime = ''.obs;
  var artworkUrl = 'https://c40.radioboss.fm/w/artwork/83.jpg'.obs;
  var artworkOpacity = 1.0.obs;
  var artworkShimmer = false.obs;
  var whatsappNumber = ''.obs;
  var whatsappStudio = ''.obs;

  static const String streamUrl = 'https://c40.radioboss.fm:8083/stream';
  static const String radiobossStatusUrl = 'https://c40.radioboss.fm:8083/status-json.xsl';
  static const String radiobossArtworkUrl = 'https://c40.radioboss.fm/w/artwork/83.jpg';
  static const String palinsestoUrl = 'https://stereo98.com/wp-json/stereo98/v1/palinsesto';

  static const Map<String, String> _studioNomi = {
    '+393532156811': 'Studio Piemonte',
    '+393883758240': 'Studio Lazio',
  };

  @override
  void onInit() async {
    super.onInit();
    _audioHandler = Get.find<RadioAudioHandler>();
    controller = AnimateIconController();

    // PRIMA: lancia subito le chiamate API (non bloccanti)
    getNowPlaying();
    getPalinsesto();

    // Timer per aggiornamenti periodici
    timer = Timer.periodic(const Duration(seconds: 10), (t) => getNowPlaying());
    _palinsestoTimer = Timer.periodic(const Duration(seconds: 30), (t) => getPalinsesto());

    _artworkRetryTimer = Timer.periodic(
      const Duration(minutes: 3),
      (t) => _refreshArtworkWithFade(shimmer: true),
    );

    // DOPO: inizializza sorgente audio (può essere lento)
    try {
      await player.setUrl(streamUrl);
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Error setting audio source: $e');
    }

    // Aggiorna notifica con info radio di default
    _audioHandler.updateNowPlaying(
      title: 'Stereo 98 DAB+',
      artist: 'In diretta',
      artworkUri: Uri.parse(radiobossArtworkUrl),
    );

    // Ascolta cambi stato player per aggiornare bottone play/stop
    player.playerStateStream.listen((state) {
      isPressed.value = state.playing;
      update();
    });

    // Riconnessione automatica su errori di rete/stream
    player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        if (kDebugMode) print('[Stereo98] Player error: $error');
        _reconnectStream();
      },
    );

    update();
  }

  /// Avvia lo streaming (ricarica sorgente se necessario)
  Future<void> playStream() async {
    try {
      if (player.processingState == ProcessingState.idle ||
          player.processingState == ProcessingState.completed) {
        await player.setUrl(streamUrl);
      }
      await _audioHandler.play();
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Play error: $e');
      _reconnectStream();
    }
  }

  /// Ferma lo streaming
  Future<void> stopStream() async {
    try {
      await player.stop();
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Stop error: $e');
    }
  }

  /// Imposta il volume (0.0 - 1.0)
  Future<void> setVolume(double value) async {
    await player.setVolume(value);
  }

  /// Riconnessione automatica dopo errore di rete
  Future<void> _reconnectStream() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      await player.setUrl(streamUrl);
      if (isPressed.value) {
        await _audioHandler.play();
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Reconnect error: $e');
      Future.delayed(const Duration(seconds: 5), () => _reconnectStream());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _palinsestoTimer?.cancel();
    _artworkRetryTimer?.cancel();
    _audioHandler.dispose();
    super.dispose();
  }

  // ==========================================================================
  // API LOGIC — INVARIATA RISPETTO ALLA VERSIONE PRECEDENTE
  // ==========================================================================

  Future<void> getNowPlaying() async {
    try {
      final response = await http.get(
        Uri.parse(radiobossStatusUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Fix: decodifica esplicita UTF-8
        final data = json.decode(utf8.decode(response.bodyBytes));
        String title = 'Stereo 98 DAB+';
        String artist = 'In diretta';

        if (data['icestats'] != null && data['icestats']['source'] != null) {
          final source = data['icestats']['source'];
          String fullTitle = source is List
              ? source[0]['title'] ?? ''
              : source['title'] ?? '';

          if (fullTitle.isNotEmpty) {
            if (fullTitle.contains(' - ')) {
              final parts = fullTitle.split(' - ');
              artist = parts[0].trim();
              title = parts.sublist(1).join(' - ').trim();
            } else {
              title = fullTitle.trim();
              artist = 'Stereo 98 DAB+';
            }
          }
        }

        final newTitle = _fixEncoding(title);
        final newArtist = _fixEncoding(artist);

        if (newTitle.isNotEmpty &&
            (titleValue.value != newTitle || artistValue.value != newArtist)) {
          _refreshArtworkWithFade();

          // Aggiorna metadati notifica con canzone corrente
          _audioHandler.updateNowPlaying(
            title: newTitle,
            artist: newArtist,
            artworkUri: Uri.parse('$radiobossArtworkUrl?t=${DateTime.now().millisecondsSinceEpoch}'),
          );
        }

        if (newTitle.isNotEmpty) titleValue.value = newTitle;
        if (newArtist.isNotEmpty) artistValue.value = newArtist;
        update();
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] RadioBOSS error: $e');
      Future.delayed(const Duration(seconds: 3), () => getNowPlaying());
    }
  }

  Future<void> getPalinsesto() async {
    try {
      final response = await http.get(Uri.parse(palinsestoUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Fix: decodifica esplicita UTF-8 per caratteri accentati
        final data = json.decode(utf8.decode(response.bodyBytes));
        final palinsesto = data['palinsesto'] as List?;

        if (palinsesto != null) {
          final now = DateTime.now();
          // Fix: usa indice numerico invece di confronto stringa giorni
          final dayIndex = now.weekday - 1;

          if (dayIndex < palinsesto.length) {
            final giorno = palinsesto[dayIndex];
            final shows = giorno['shows'] as List? ?? [];
            bool foundCurrent = false;

            for (int i = 0; i < shows.length; i++) {
              final show = shows[i];
              final start = show['orario_inizio']?.toString().split(':');
              final end = show['orario_fine']?.toString().split(':');

              if (start != null && end != null && start.length >= 2 && end.length >= 2) {
                final startMin = int.parse(start[0]) * 60 + int.parse(start[1]);
                // Fix: gestione show che finiscono a mezzanotte (00:00 = 1440)
                var endMin = int.parse(end[0]) * 60 + int.parse(end[1]);
                if (endMin == 0) endMin = 1440;
                final nowMin = now.hour * 60 + now.minute;

                if (nowMin >= startMin && nowMin < endMin) {
                  showName.value = _fixEncoding(show['show_nome'] ?? '');
                  showImage.value = show['show_immagine']?.toString() ?? '';
                  foundCurrent = true;

                  final wa = show['whatsapp']?.toString() ?? '';
                  whatsappNumber.value = wa;
                  whatsappStudio.value = wa.isNotEmpty ? (_studioNomi[wa] ?? '') : '';

                  final desc = _fixEncoding(show['show_descrizione'] ?? '');
                  showDescription.value = desc;

                  if (i + 1 < shows.length) {
                    final next = shows[i + 1];
                    nextShowName.value = _fixEncoding(next['show_nome'] ?? '');
                    nextShowTime.value = next['orario_inizio'] ?? '';
                  } else {
                    nextShowName.value = '';
                    nextShowTime.value = '';
                  }
                  break;
                }
              }
            }

            if (!foundCurrent) {
              showName.value = '';
              showImage.value = '';
              showDescription.value = '';
              whatsappNumber.value = '';
              whatsappStudio.value = '';
              nextShowName.value = '';
              nextShowTime.value = '';
              final nowMin = now.hour * 60 + now.minute;
              for (final show in shows) {
                final start = show['orario_inizio']?.toString().split(':');
                if (start != null && start.length >= 2) {
                  final startMin = int.parse(start[0]) * 60 + int.parse(start[1]);
                  if (startMin > nowMin) {
                    nextShowName.value = _fixEncoding(show['show_nome'] ?? '');
                    nextShowTime.value = show['orario_inizio'] ?? '';
                    break;
                  }
                }
              }
            }

            update();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Palinsesto error: $e');
      Future.delayed(const Duration(seconds: 3), () => getPalinsesto());
    }
  }

  Future<void> _refreshArtworkWithFade({bool shimmer = false}) async {
    if (shimmer) {
      artworkShimmer.value = true;
      update();
      await Future.delayed(const Duration(milliseconds: 1200));
      artworkUrl.value = '$radiobossArtworkUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      await Future.delayed(const Duration(milliseconds: 300));
      artworkShimmer.value = false;
      update();
    } else {
      artworkOpacity.value = 0.0;
      update();
      await Future.delayed(const Duration(milliseconds: 400));
      artworkUrl.value = '$radiobossArtworkUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      update();
      await Future.delayed(const Duration(milliseconds: 300));
      artworkOpacity.value = 1.0;
      update();
    }
  }

  String _fixEncoding(String text) {
    return text
      .replaceAll('&#8217;', "'")
      .replaceAll('&#8216;', "'")
      .replaceAll('&#8220;', '\u201C')
      .replaceAll('&#8221;', '\u201D')
      .replaceAll('&#8211;', '\u2013')
      .replaceAll('&#8212;', '\u2014')
      .replaceAll('&#038;', '&')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll("&apos;", "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('[&hellip;]', '\u2026')
      .replaceAll('&hellip;', '\u2026')
      .replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
