// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stereo98/controller/home_controller.dart';
import 'package:stereo98/utils/theme_helper.dart';
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
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.s98Text),
          onPressed: () => Get.close(1),
        ),
        title: Text(
          'Hai ascoltato',
          style: TextStyle(color: context.s98Text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.s98TextMuted),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  backgroundColor: context.s98DialogBg,
                  title: Text('Cancella cronologia', style: TextStyle(color: context.s98Text)),
                  content: Text('Vuoi cancellare tutta la cronologia?', style: TextStyle(color: context.s98TextSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Annulla', style: TextStyle(color: context.s98TextMuted)),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).cardColor,
              Theme.of(context).canvasColor,
            ],
          ),
        ),
        child: Obx(() {
          final lista = controller.cronologia;
          if (lista.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: context.s98TextDisabled, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Nessun brano ascoltato',
                    style: TextStyle(color: context.s98TextMuted, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'I brani appariranno qui durante l\'ascolto',
                    style: TextStyle(color: context.s98TextFaint, fontSize: 13),
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
                      : [context.s98Surface(0.06), context.s98Surface(0.02)],
                  ),
                  border: Border.all(
                    color: isFirst
                      ? const Color(0xFFD85D9D).withOpacity(0.4)
                      : context.s98Surface(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFirst
                          ? const Color(0xFFD85D9D).withOpacity(0.3)
                          : context.s98Surface(0.08),
                      ),
                      child: Center(
                        child: isFirst
                          ? const Icon(Icons.music_note, color: Color(0xFFD85D9D), size: 18)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: context.s98TextMuted,
                                fontSize: 13, fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titolo,
                            style: TextStyle(
                              color: isFirst ? context.s98Text : context.s98Text.withOpacity(0.9),
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
                              color: isFirst ? const Color(0xFF4EC8E8) : context.s98TextMuted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ora,
                          style: TextStyle(
                            color: context.s98TextFaint,
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
