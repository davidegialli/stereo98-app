import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:animate_icons/animate_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stereo98/services/audio_handler.dart';

class HomeController extends GetxController {
  late final RadioAudioHandler _audioHandler;
  AudioPlayer get player => _audioHandler.player;

  Timer? timer;
  Timer? _palinsestoTimer;
  Timer? _artworkRetryTimer;
  Timer? _rdsTimer;
  Timer? _sleepTimer;
  Timer? _sleepTickTimer;
  Timer? _premioCheckTimer;

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
  var rdsMessaggi = <Map<String, String>>[].obs;
  var rdsDismissed = <int>{}.obs;

  // Sleep Timer
  var sleepTimerMinutes = 0.obs;
  var sleepTimerRemaining = 0.obs;

  // ⭐ Voto Chart (server)
  var currentSongVoted = false.obs;
  var fanCode = ''.obs;
  var fanNome = ''.obs;
  var fanTotalVotes = 0.obs;
  var fanPosizione = Rxn<int>();

  // ❤️ Preferiti locali (GetStorage)
  var currentSongFavorited = false.obs;
  var localFavorites = <Map<String, String>>[].obs;

  // 🎁 Premio
  var premioMessaggio = ''.obs;
  var premioPending = false.obs;

  // Chart
  var chart = <Map<String, dynamic>>[].obs;

  bool _isStartingPlay = false;
  late String _deviceId;
  late GetStorage _box;

  static const String streamUrl = 'https://c40.radioboss.fm:8083/stream';
  static const String radiobossStatusUrl = 'https://c40.radioboss.fm:8083/status-json.xsl';
  static const String radiobossArtworkUrl = 'https://c40.radioboss.fm/w/artwork/83.jpg';
  static const String palinsestoUrl = 'https://stereo98.com/wp-json/stereo98/v1/palinsesto';
  static const String rdsApiUrl = 'https://stereo98.com/wp-json/stereo98/v1/rds';
  static const String likeApiUrl = 'https://stereo98.com/wp-json/stereo98/v1/like';
  static const String likesApiUrl = 'https://stereo98.com/wp-json/stereo98/v1/likes';
  static const String chartApiUrl = 'https://stereo98.com/wp-json/stereo98/v1/chart';
  static const String fanApiUrl = 'https://stereo98.com/wp-json/stereo98/v1/fan';

  static const Map<String, String> _studioNomi = {
    '+393532156811': 'Studio Piemonte',
    '+393883758240': 'Studio Lazio',
  };

  @override
  void onInit() {
    super.onInit();
    _audioHandler = Get.find<RadioAudioHandler>();
    controller = AnimateIconController();
    _box = GetStorage();

    _initDeviceId();
    _loadLocalFavorites();

    getNowPlaying();
    getPalinsesto();
    getRds();

    timer = Timer.periodic(const Duration(seconds: 10), (t) => getNowPlaying());
    _palinsestoTimer = Timer.periodic(const Duration(seconds: 30), (t) => getPalinsesto());
    _rdsTimer = Timer.periodic(const Duration(seconds: 30), (t) => getRds());
    _premioCheckTimer = Timer.periodic(const Duration(seconds: 60), (t) => getFanProfile());

    _artworkRetryTimer = Timer.periodic(
      const Duration(minutes: 3),
      (t) {
        _refreshArtworkWithFade(shimmer: true);
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

  // ==========================================================================
  // DEVICE ID
  // ==========================================================================
  void _initDeviceId() {
    String? stored = _box.read('stereo98_device_id');
    if (stored == null || stored.isEmpty) {
      stored = _generateDeviceId();
      _box.write('stereo98_device_id', stored);
    }
    _deviceId = stored;
    if (kDebugMode) print('[Stereo98] Device ID: $_deviceId');

    Future.delayed(const Duration(seconds: 2), () {
      getFanProfile();
      getChart();
      _saveOneSignalPlayerId();
    });

    // Check voto canzone corrente dopo che getNowPlaying ha caricato (3s)
    Future.delayed(const Duration(seconds: 4), () {
      _checkIfCurrentSongVoted();
      _checkIfCurrentSongFavorited();
    });
  }

  String _generateDeviceId() {
    final rand = Random.secure();
    final bytes = List.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String get deviceId => _deviceId;

  // ==========================================================================
  // ONESIGNAL PLAYER ID
  // ==========================================================================
  Future<void> _saveOneSignalPlayerId() async {
    // Prova subito
    final playerId = OneSignal.User.pushSubscription.id;
    if (playerId != null && playerId.isNotEmpty) {
      _sendPlayerIdToServer(playerId);
    }

    // Ascolta cambiamenti (se il permesso viene dato dopo)
    OneSignal.User.pushSubscription.addObserver((state) {
      final id = state.current.id;
      if (id != null && id.isNotEmpty) {
        _sendPlayerIdToServer(id);
      }
    });
  }

  Future<void> _sendPlayerIdToServer(String playerId) async {
    try {
      await http.post(
        Uri.parse(fanApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': _deviceId,
          'onesignal_player_id': playerId,
        }),
      ).timeout(const Duration(seconds: 10));
      if (kDebugMode) print('[Stereo98] OneSignal player_id salvato: $playerId');
    } catch (e) {
      if (kDebugMode) print('[Stereo98] OneSignal save error: $e');
    }
  }

  // ==========================================================================
  // SLEEP TIMER
  // ==========================================================================
  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();

    if (minutes <= 0) {
      sleepTimerMinutes.value = 0;
      sleepTimerRemaining.value = 0;
      return;
    }

    sleepTimerMinutes.value = minutes;
    sleepTimerRemaining.value = minutes * 60;

    _sleepTickTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (sleepTimerRemaining.value <= 0) {
        t.cancel();
        return;
      }
      sleepTimerRemaining.value--;
    });

    _sleepTimer = Timer(Duration(minutes: minutes), () {
      stopStream();
      sleepTimerMinutes.value = 0;
      sleepTimerRemaining.value = 0;
      _sleepTickTimer?.cancel();
      if (kDebugMode) print('[Stereo98] Sleep timer: stream stopped');
    });
  }

  void cancelSleepTimer() => setSleepTimer(0);

  String get sleepTimerFormatted {
    final secs = sleepTimerRemaining.value;
    if (secs <= 0) return '';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ==========================================================================
  // ❤️ PREFERITI LOCALI (GetStorage — nessun server)
  // ==========================================================================
  void _loadLocalFavorites() {
    final stored = _box.read<List>('stereo98_favorites');
    if (stored != null) {
      localFavorites.value = stored
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    }
  }

  void _saveLocalFavorites() {
    _box.write('stereo98_favorites', localFavorites.toList());
  }

  void toggleFavorite() {
    final artista = artistValue.value;
    final titolo = titleValue.value;
    if (artista.isEmpty && titolo.isEmpty) return;

    final key = _branoKey(artista, titolo);
    final idx = localFavorites.indexWhere((f) =>
        _branoKey(f['artista'] ?? '', f['titolo'] ?? '') == key);

    if (idx >= 0) {
      localFavorites.removeAt(idx);
      currentSongFavorited.value = false;
    } else {
      localFavorites.insert(0, {'artista': artista, 'titolo': titolo});
      currentSongFavorited.value = true;
    }
    _saveLocalFavorites();
    update();
  }

  void _checkIfCurrentSongFavorited() {
    final artista = artistValue.value;
    final titolo = titleValue.value;
    if (artista.isEmpty && titolo.isEmpty) {
      currentSongFavorited.value = false;
      return;
    }
    final key = _branoKey(artista, titolo);
    currentSongFavorited.value = localFavorites.any((f) =>
        _branoKey(f['artista'] ?? '', f['titolo'] ?? '') == key);
  }

  String _branoKey(String artista, String titolo) {
    return '${artista.toLowerCase().trim()}|${titolo.toLowerCase().trim()}';
  }

  // ==========================================================================
  // ⭐ VOTO CHART (server — solo con play attivo)
  // ==========================================================================
  Future<void> toggleVote() async {
    if (!isPressed.value) return;

    final artista = artistValue.value;
    final titolo = titleValue.value;
    if (artista.isEmpty && titolo.isEmpty) return;

    final wasVoted = currentSongVoted.value;
    currentSongVoted.toggle();
    // Aggiorna contatore ottimisticamente
    if (currentSongVoted.value) {
      fanTotalVotes.value++;
    } else if (fanTotalVotes.value > 0) {
      fanTotalVotes.value--;
    }
    update();

    try {
      final response = await http.post(
        Uri.parse(likeApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': _deviceId,
          'artista': artista,
          'titolo': titolo,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) print('[Stereo98] VOTE RESPONSE: $data');
        currentSongVoted.value = data['liked'] == true;
        if (data['fan_code'] != null) {
          fanCode.value = data['fan_code'];
        }
        // Aggiorna dati reali dal server
        getChart();
        getFanProfile();
      } else {
        // Rollback
        currentSongVoted.value = wasVoted;
        fanTotalVotes.value += wasVoted ? 1 : -1;
      }
    } catch (e) {
      // Rollback
      currentSongVoted.value = wasVoted;
      fanTotalVotes.value += wasVoted ? 1 : -1;
      if (kDebugMode) print('[Stereo98] Vote error: $e');
    }
    update();
  }

  Future<void> _checkIfCurrentSongVoted() async {
    final artista = artistValue.value;
    final titolo = titleValue.value;
    if (artista.isEmpty && titolo.isEmpty) {
      currentSongVoted.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$likesApiUrl?device_id=$_deviceId&_t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final lista = data['likes'] as List?;
        final key = _branoKey(artista, titolo);
        if (kDebugMode) print('[Stereo98] CHECK VOTE: cerco "$key" in ${lista?.length ?? 0} likes');
        if (lista != null) {
          final found = lista.any((p) =>
              _branoKey(p['artista'] ?? '', p['titolo'] ?? '') == key);
          currentSongVoted.value = found;
          if (kDebugMode) print('[Stereo98] CHECK VOTE: trovato=$found');
        }
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Check vote error: $e');
    }
    update();
  }

  Future<void> getChart({String periodo = 'settimana'}) async {
    try {
      final response = await http.get(
        Uri.parse('$chartApiUrl?periodo=$periodo&device_id=$_deviceId&limit=20&_t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final lista = data['chart'] as List?;
        if (lista != null) {
          chart.value = lista.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Chart error: $e');
    }
  }

  // ==========================================================================
  // FAN PROFILE + PREMIO
  // ==========================================================================
  Future<void> getFanProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$fanApiUrl?device_id=$_deviceId&_t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) print('[Stereo98] FAN API RESPONSE: $data');
        fanCode.value = data['fan_code']?.toString() ?? '';
        final nome = data['nome']?.toString() ?? '';
        if (nome.isNotEmpty) {
          fanNome.value = nome;
          _box.write('stereo98_fan_nome', nome);
        } else if (fanNome.value.isEmpty) {
          fanNome.value = _box.read('stereo98_fan_nome') ?? '';
        }
        fanTotalVotes.value = data['totale_likes'] ?? 0;
        if (kDebugMode) print('[Stereo98] VOTI TOTALI: ${fanTotalVotes.value}');
        fanPosizione.value = data['posizione_classifica'];

        // Salva localmente come backup
        if (fanNome.value.isNotEmpty) {
          _box.write('stereo98_fan_nome', fanNome.value);
        }
        if (fanCode.value.isNotEmpty) {
          _box.write('stereo98_fan_code', fanCode.value);
        }

        // PREMIO
        final premio = data['premio']?.toString() ?? '';
        if (kDebugMode) print('[Stereo98] PREMIO dalla API: "$premio" (pending attuale: ${premioPending.value})');
        if (premio.isNotEmpty) {
          premioMessaggio.value = premio;
          premioPending.value = true;
          if (kDebugMode) print('[Stereo98] >>> PREMIO ATTIVO! premioPending = true');
        }
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Fan profile error: $e');
      // Fallback locale
      if (fanNome.value.isEmpty) {
        fanNome.value = _box.read('stereo98_fan_nome') ?? '';
      }
      if (fanCode.value.isEmpty) {
        fanCode.value = _box.read('stereo98_fan_code') ?? '';
      }
    }
  }

  Future<void> updateFanNome(String nome) async {
    try {
      await http.post(
        Uri.parse(fanApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': _deviceId,
          'nome': nome,
        }),
      ).timeout(const Duration(seconds: 10));
      fanNome.value = nome;
      _box.write('stereo98_fan_nome', nome);
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Update nome error: $e');
    }
  }

  void dismissPremio() {
    premioPending.value = false;
    premioMessaggio.value = '';
    update();
    _confirmPremioLetto();
  }

  Future<void> _confirmPremioLetto() async {
    try {
      await http.post(
        Uri.parse('$fanApiUrl/letto'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'device_id': _deviceId}),
      ).timeout(const Duration(seconds: 10));
      if (kDebugMode) print('[Stereo98] Premio confermato come letto');
    } catch (e) {
      if (kDebugMode) print('[Stereo98] Premio letto error: $e');
    }
  }

  // ==========================================================================
  // PLAYER
  // ==========================================================================
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
    _sleepTimer?.cancel();
    _sleepTickTimer?.cancel();
    _premioCheckTimer?.cancel();
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

        if (newTitle.isNotEmpty &&
            (titleValue.value != newTitle || artistValue.value != newArtist)) {
          _refreshArtworkWithFade();

          titleValue.value = newTitle;
          artistValue.value = newArtist;

          _checkIfCurrentSongFavorited();
          _checkIfCurrentSongVoted();
        }

        // Aggiorna sempre la notifica per mantenerla sincronizzata
        _updateNotification();

        update();
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] RadioBOSS error: $e');
      Future.delayed(const Duration(seconds: 3), () => getNowPlaying());
    }
  }

  Future<void> getPalinsesto() async {
    try {
      final response = await http.get(
        Uri.parse('$palinsestoUrl?_t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      ).timeout(const Duration(seconds: 15));

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
        final attivo = data['attivo'] == true;
        final lista = data['messaggi'] as List?;

        if (attivo && lista != null && lista.isNotEmpty) {
          final nuovi = <Map<String, String>>[];
          for (final m in lista) {
            nuovi.add({
              'testo': m['testo']?.toString() ?? '',
              'tipo': m['tipo']?.toString() ?? 'scroll',
              'url': m['url']?.toString() ?? '',
            });
          }

          final vecchiTesti = rdsMessaggi.map((m) => m['testo']).toList();
          final nuoviTesti = nuovi.map((m) => m['testo']).toList();
          if (vecchiTesti.toString() != nuoviTesti.toString()) {
            rdsDismissed.clear();
          }

          rdsAttivo.value = true;
          rdsMessaggi.value = nuovi;
        } else {
          rdsAttivo.value = false;
          rdsMessaggi.clear();
        }

        update();
      }
    } catch (e) {
      if (kDebugMode) print('[Stereo98] RDS error: $e');
    }
  }

  void dismissRdsPopup(int index) {
    rdsDismissed.add(index);
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
