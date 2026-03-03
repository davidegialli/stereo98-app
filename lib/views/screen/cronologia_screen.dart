// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stereo98/controller/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class CronologiaScreen extends StatelessWidget {
  const CronologiaScreen({super.key});

  void _openAppleMusic(String artista, String titolo) async {
    try {
      final query = Uri.encodeComponent('$artista $titolo');
      final apiUrl = Uri.parse('https://itunes.apple.com/search?term=$query&media=music&limit=1&country=it');
      final response = await http.get(apiUrl).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        if (results.isNotEmpty) {
          final trackUrl = results[0]['trackViewUrl']?.toString() ?? '';
          if (trackUrl.isNotEmpty) {
            final url = Uri.parse(trackUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
              return;
            }
          }
        }
      }
    } catch (_) {}

    final fallback = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent('$artista $titolo apple music')}');
    if (await canLaunchUrl(fallback)) {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.close(1),
        ),
        title: const Text(
          'Hai ascoltato',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white54),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  title: const Text('Cancella cronologia', style: TextStyle(color: Colors.white)),
                  content: const Text('Vuoi cancellare tutta la cronologia?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Annulla', style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.clearCronologia();
                        Get.back();
                      },
                      child: const Text('Cancella', style: TextStyle(color: Color(0xFFD85D9D))),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A10), Color(0xFF000000), Color(0xFF0A0A1A)],
          ),
        ),
        child: Obx(() {
          final lista = controller.cronologia;
          if (lista.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: Colors.white24, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'Nessun brano ascoltato',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'I brani appariranno qui durante l\'ascolto',
                    style: TextStyle(color: Colors.white30, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final brano = lista[i];
              final artista = brano['artista'] ?? '';
              final titolo = brano['titolo'] ?? '';
              final ora = brano['ora'] ?? '';
              final isFirst = i == 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: isFirst
                      ? [const Color(0xFFD85D9D).withOpacity(0.2), const Color(0xFF4EC8E8).withOpacity(0.08)]
                      : [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)],
                  ),
                  border: Border.all(
                    color: isFirst
                      ? const Color(0xFFD85D9D).withOpacity(0.4)
                      : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    // Numero o icona LIVE per il primo
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFirst
                          ? const Color(0xFFD85D9D).withOpacity(0.3)
                          : Colors.white.withOpacity(0.08),
                      ),
                      child: Center(
                        child: isFirst
                          ? const Icon(Icons.music_note, color: Color(0xFFD85D9D), size: 18)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13, fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info brano
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titolo,
                            style: TextStyle(
                              color: isFirst ? Colors.white : Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artista,
                            style: TextStyle(
                              color: isFirst ? const Color(0xFF4EC8E8) : Colors.white54,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Orario + Apple Music
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ora,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _openAppleMusic(artista, titolo),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)],
                              ),
                            ),
                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
