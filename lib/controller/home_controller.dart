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
  Timer? _rdsTimer;

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

  // RDS
  var rdsAttivo = false.obs;
  var rdsTesto = ''.obs;
  var rdsTipo = 'scroll'.obs;
  var rdsUrl = ''.obs;
  var rdsPopupDismissed = false.obs;

  bool _isStartingPlay = false;

  static const String streamUrl = 'https://c40.radioboss.fm:8083/stream';
  static const String radiobossStatusUrl = 'https://c40.radioboss.fm:8083/status-json.xsl';
  static const String radiobossArtworkUrl = 'https://c40.radioboss.fm/w/artwork/83.jpg';
  static const String palinsestoUrl = 'https://stereo98.com/wp-json/stereo98/v1/palinsesto';
  static const String rdsApiUrl = 'https://stereo98.com/wp-json/stereo98/v1/rds';

  static const Map<String, String> _studioNomi = {
    '+393532156811': 'Studio Piemonte',
    '+393883758240': 'Studio Lazio',
  };

  @override
  void onInit() {
    super.onInit();
    _audioHandler = Get.find<RadioAudioHandler>();
    controller = AnimateIconController();

    getNowPlaying();
    getPalinsesto();
    getRds();

    timer = Timer.periodic(const Duration(seconds: 10), (t) => getNowPlaying());
    _palinsestoTimer = Timer.periodic(const Duration(seconds: 30), (t) => getPalinsesto());
    _rdsTimer = Timer.periodic(const Duration(seconds: 30), (t) => getRds());

    _artworkRetryTimer = Timer.periodic(
      const Duration(minutes: 3),
      (t) {
        _refreshArtworkWithFade(shimmer: true);
        // Aggiorna anche notifica ogni 3 minuti
        _updateNotification();
      },
    );

    _initPlayer();

    player.playerStateStream.listen((state) {
      if (!_isStartingPlay) {
        isPressed.value = state.playing;
        update();
      }
    });

    player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        if (kDebugMode) print('[Stereo98] Player error: $error');
        _isStartingPlay = false;
        _reconnectStream();
      },
    );

    update();
  }

  Future<void> _initPlayer() async {
    try {
      await player.setUrl(streamUrl);
      if (kDebugMode) print('[Stereo98] Player source ready');
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Error setting audio source: $e');
    }
    _audioHandler.updateNowPlaying(
      title: 'Stereo 98 DAB+',
      artist: 'In diretta',
      artworkUri: Uri.parse(radiobossArtworkUrl),
    );
  }

  /// Aggiorna notifica con metadati correnti
  void _updateNotification() {
    _audioHandler.updateNowPlaying(
      title: titleValue.value.isNotEmpty ? titleValue.value : 'Stereo 98 DAB+',
      artist: artistValue.value.isNotEmpty ? artistValue.value : 'In diretta',
      artworkUri: Uri.parse('$radiobossArtworkUrl?t=${DateTime.now().millisecondsSinceEpoch}'),
    );
  }

  Future<void> playStream() async {
    _isStartingPlay = true;
    isPressed.value = true;
    update();

    try {
      await player.setUrl(streamUrl);
      await _audioHandler.play();
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Play error: $e');
      isPressed.value = false;
      update();
      _reconnectStream();
    } finally {
      _isStartingPlay = false;
    }
  }

  Future<void> stopStream() async {
    isPressed.value = false;
    update();

    try {
      await _audioHandler.pause();
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Stop error: $e');
    }
  }

  Future<void> setVolume(double value) async {
    await player.setVolume(value);
  }

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
    _rdsTimer?.cancel();
    _audioHandler.dispose();
    super.dispose();
  }

  // ==========================================================================
  // API
  // ==========================================================================

  Future<void> getNowPlaying() async {
    try {
      final response = await http.get(
        Uri.parse(radiobossStatusUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
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

        // Solo a cambio canzone: aggiorna artwork + notifica
        if (newTitle.isNotEmpty &&
            (titleValue.value != newTitle || artistValue.value != newArtist)) {
          _refreshArtworkWithFade();

          titleValue.value = newTitle;
          artistValue.value = newArtist;

          // Aggiorna notifica SOLO al cambio canzone
          _updateNotification();
        }

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
        final data = json.decode(utf8.decode(response.bodyBytes));
        final palinsesto = data['palinsesto'] as List?;

        if (palinsesto != null) {
          final now = DateTime.now();
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

  Future<void> getRds() async {
    try {
      final response = await http.get(
        Uri.parse('$rdsApiUrl?_t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Cache-Control': 'no-cache'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final nuovoTesto = data['testo']?.toString() ?? '';
        final nuovoAttivo = data['attivo'] == true;
        final nuovoTipo = data['tipo']?.toString() ?? 'scroll';
        final nuovoUrl = data['url']?.toString() ?? '';

        if (nuovoTesto != rdsTesto.value) {
          rdsPopupDismissed.value = false;
        }

        rdsAttivo.value = nuovoAttivo && nuovoTesto.isNotEmpty;
        rdsTesto.value = nuovoTesto;
        rdsTipo.value = nuovoTipo;
        rdsUrl.value = nuovoUrl;
        update();
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] RDS error: $e');
    }
  }

  void dismissRdsPopup() {
    rdsPopupDismissed.value = true;
    update();
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
