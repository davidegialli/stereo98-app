// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});
  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  List<Map<String, dynamic>> _podcasts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPodcast();
  }

  Future<void> _fetchPodcast() async {
    try {
      final response = await http.get(
        Uri.parse('https://stereo98.com/wp-json/stereo98/v1/podcast?per_page=50'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = List<Map<String, dynamic>>.from(data['podcast'] ?? []);
        setState(() {
          _podcasts = list;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // ✅ Nessuna freccia indietro automatica
        automaticallyImplyLeading: false,
        title: const Text('Podcast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        // ✅ Tasto X in alto a destra per tornare alla home
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
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
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD85D9D)))
            : _podcasts.isEmpty
                ? const Center(child: Text('Nessun podcast disponibile', style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: _podcasts.length,
                    itemBuilder: (context, i) {
                      final p = _podcasts[i];
                      final image = p['immagine'] ?? '';
                      final title = _fixText(p['titolo'] ?? '');
                      final dj = _fixText(p['dj'] ?? '');
                      final date = p['podcast_date'] ?? p['data_pubblicazione'] ?? '';
                      final audioUrl = p['audio_url'] ?? p['resource_url'] ?? '';
                      final webUrl = p['url'] ?? '';

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD85D9D).withOpacity(0.15),
                              const Color(0xFF4EC8E8).withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFD85D9D).withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10.w),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: image.isNotEmpty
                                ? Image.network(image, width: 60.w, height: 60.h, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _placeholder())
                                : _placeholder(),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dj.isNotEmpty)
                                Text(dj, style: const TextStyle(color: Color(0xFF4EC8E8), fontSize: 12)),
                              if (date.isNotEmpty)
                                Text(date, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_filled, color: Color(0xFFD85D9D), size: 36),
                            onPressed: () async {
                              final url = Uri.parse(audioUrl.isNotEmpty ? audioUrl : webUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60.w, height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xFFD85D9D).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.podcasts, color: Colors.white),
    );
  }

  String _fixText(String text) {
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
