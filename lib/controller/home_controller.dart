import 'dart:async';
import 'dart:convert';

import 'package:animate_icons/animate_icons.dart';
import 'package:assets_audio_player_updated/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  final assetsAudioPlayer = AssetsAudioPlayer();

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
    controller = AnimateIconController();

    await assetsAudioPlayer.open(
      Audio.liveStream(streamUrl),
      showNotification: true,
      autoStart: false,
      notificationSettings: NotificationSettings(
        stopEnabled: false,
        nextEnabled: false,
        prevEnabled: false,
        customPlayPauseAction: (playing) {
          isPressed.value = playing.isPlaying.value;
          assetsAudioPlayer.playOrPause();
          update();
        },
      ),
    );

    assetsAudioPlayer.isPlaying.listen((playing) {
      isPressed.value = playing;
      update();
    });

    // Timer separati e indipendenti
    getNowPlaying();
    getPalinsesto();

    timer = Timer.periodic(const Duration(seconds: 10), (t) => getNowPlaying());
    _palinsestoTimer = Timer.periodic(const Duration(seconds: 60), (t) => getPalinsesto());

    _artworkRetryTimer = Timer.periodic(
      const Duration(minutes: 3),
      (t) => _refreshArtworkWithFade(shimmer: true),
    );

    update();
  }

  @override
  void dispose() {
    timer?.cancel();
    _palinsestoTimer?.cancel();
    _artworkRetryTimer?.cancel();
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  // Metadata da RadioBOSS diretto
  Future<void> getNowPlaying() async {
    try {
      final response = await http.get(
        Uri.parse(radiobossStatusUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
        }

        if (newTitle.isNotEmpty) titleValue.value = newTitle;
        if (newArtist.isNotEmpty) artistValue.value = newArtist;
        update();
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] RadioBOSS error: $e');
    }
  }

  Future<void> getPalinsesto() async {
    try {
      final response = await http.get(Uri.parse(palinsestoUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final palinsesto = data['palinsesto'] as List?;

        if (palinsesto != null) {
          final now = DateTime.now();
          final dayNames = ['Lunedì','Martedì','Mercoledì','Giovedì','Venerdì','Sabato','Domenica'];
          final today = dayNames[now.weekday - 1];

          for (final giorno in palinsesto) {
            if (giorno['giorno']?.toString() == today) {
              final shows = giorno['shows'] as List? ?? [];
              bool foundCurrent = false;

              for (int i = 0; i < shows.length; i++) {
                final show = shows[i];
                final start = show['orario_inizio']?.toString().split(':');
                final end = show['orario_fine']?.toString().split(':');

                if (start != null && end != null && start.length >= 2 && end.length >= 2) {
                  final startMin = int.parse(start[0]) * 60 + int.parse(start[1]);
                  final endMin = int.parse(end[0]) * 60 + int.parse(end[1]);
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
              break;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Palinsesto error: $e');
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
      .replaceAll('&#8220;', '"')
      .replaceAll('&#8221;', '"')
      .replaceAll('&#8211;', '–')
      .replaceAll('&#8212;', '—')
      .replaceAll('&#038;', '&')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&hellip;', '…')
      .replaceAll('[&hellip;]', '…')
      .replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
