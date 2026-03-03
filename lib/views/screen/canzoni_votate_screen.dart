// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stereo98/controller/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class CanzoniVotateScreen extends StatefulWidget {
  const CanzoniVotateScreen({super.key});
  @override
  State<CanzoniVotateScreen> createState() => _CanzoniVotateScreenState();
}

class _CanzoniVotateScreenState extends State<CanzoniVotateScreen> {
  List<Map<String, dynamic>> _canzoni = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchVotate();
  }

  Future<void> _fetchVotate() async {
    try {
      final controller = Get.find<HomeController>();
      final deviceId = controller.deviceId;
      final response = await http.get(
        Uri.parse('https://stereo98.com/wp-json/stereo98/v1/likes?device_id=$deviceId&_t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final lista = data['likes'] as List? ?? [];
        setState(() {
          _canzoni = lista.map((e) => Map<String, dynamic>.from(e)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _openAppleMusic(String artista, String titolo) async {
    final query = Uri.encodeComponent('$artista $titolo');
    final url = Uri.parse('https://music.apple.com/search?term=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Le Mie Canzoni',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
            : _canzoni.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_border, color: Colors.white24, size: 60),
                        SizedBox(height: 16),
                        Text('Nessuna canzone votata', style: TextStyle(color: Colors.white54, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Vota le canzoni con ⭐ durante l\'ascolto', style: TextStyle(color: Colors.white30, fontSize: 13)),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFFD85D9D),
                    backgroundColor: const Color(0xFF1A0A1E),
                    onRefresh: _fetchVotate,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _canzoni.length,
                      itemBuilder: (context, i) {
                        final brano = _canzoni[i];
                        final artista = brano['artista']?.toString() ?? '';
                        final titolo = brano['titolo']?.toString() ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)],
                            ),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFD85D9D).withOpacity(0.2),
                                ),
                                child: const Icon(Icons.star, color: Color(0xFFD85D9D), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(titolo,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(artista,
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _openAppleMusic(artista, titolo),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)],
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_arrow, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text('Ascolta', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
