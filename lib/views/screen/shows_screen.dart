// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ShowsScreen extends StatefulWidget {
  const ShowsScreen({super.key});
  @override
  State<ShowsScreen> createState() => _ShowsScreenState();
}

class _ShowsScreenState extends State<ShowsScreen> {
  List<dynamic> _shows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchShows();
  }

  Future<void> _fetchShows() async {
    try {
      final response = await http.get(
        Uri.parse('https://stereo98.com/wp-json/stereo98/v1/shows'),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _shows = data['shows'] ?? [];
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Shows', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            : _shows.isEmpty
                ? const Center(child: Text('Nessuno show disponibile', style: TextStyle(color: Colors.white)))
                : OrientationBuilder(
                    builder: (context, orientation) {
                      // ✅ Più colonne in landscape per sfruttare lo spazio
                      final crossAxisCount = orientation == Orientation.landscape ? 4 : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _shows.length,
                        itemBuilder: (context, i) {
                          final show = _shows[i];
                          final nome = _fixText(show['nome'] ?? '');
                          final image = show['immagine'] ?? '';
                          final conduttore = _fixText(show['conduttore'] ?? '');
                          final palinsesto = show['palinsesto'] ?? '';

                          return GestureDetector(
                            onTap: () => _showDetail(context, show),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFD85D9D).withOpacity(0.15),
                                    const Color(0xFF4EC8E8).withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFFD85D9D).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Immagine show
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: image.isNotEmpty
                                          ? Image.network(
                                              image,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _placeholder(),
                                            )
                                          : _placeholder(),
                                    ),
                                  ),
                                  // Info show
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nome,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (conduttore.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            conduttore,
                                            style: const TextStyle(color: Color(0xFF4EC8E8), fontSize: 11),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        if (palinsesto.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.schedule, color: Color(0xFFD85D9D), size: 10),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Text(
                                                  palinsesto,
                                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }

  void _showDetail(BuildContext context, Map show) {
    final nome = _fixText(show['nome'] ?? '');
    final image = show['immagine'] ?? '';
    final conduttore = _fixText(show['conduttore'] ?? '');
    final descrizione = _fixText(show['descrizione_breve'] ?? show['descrizione'] ?? '');
    final palinsesto = show['palinsesto'] ?? '';

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        // ✅ In landscape: quasi full screen per avere abbastanza spazio
        height: isLandscape
            ? MediaQuery.of(context).size.height * 0.85
            : MediaQuery.of(context).size.height * 0.7,
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0A10), Color(0xFF0A0A1A)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: Color(0xFFD85D9D), width: 2),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(image,
                          height: isLandscape ? 140 : 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                      ),
                    const SizedBox(height: 16),
                    Text(nome, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    if (conduttore.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mic, color: Color(0xFF4EC8E8), size: 16),
                          const SizedBox(width: 6),
                          Text(conduttore, style: const TextStyle(color: Color(0xFF4EC8E8), fontSize: 16)),
                        ],
                      ),
                    ],
                    if (palinsesto.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD85D9D).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD85D9D).withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, color: Color(0xFFD85D9D), size: 14),
                            const SizedBox(width: 6),
                            Text(palinsesto, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                    if (descrizione.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(descrizione, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5), textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFD85D9D).withOpacity(0.2),
      child: const Center(child: Icon(Icons.mic, color: Colors.white, size: 40)),
    );
  }

  // 🔥 Fix encoding HTML entities
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
      .replaceAll('[…]', '…')
      .replaceAll(RegExp(r'<[^>]*>'), ''); // rimuove tag HTML
  }
}
