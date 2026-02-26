// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PalinsestoScreen extends StatefulWidget {
  const PalinsestoScreen({super.key});
  @override
  State<PalinsestoScreen> createState() => _PalinsestoScreenState();
}

class _PalinsestoScreenState extends State<PalinsestoScreen> {
  List<dynamic> _palinsesto = [];
  bool _loading = true;
  int _selectedDay = 0;

  final List<String> _giorni = ['Lunedì','Martedì','Mercoledì','Giovedì','Venerdì','Sabato','Domenica'];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now().weekday - 1;
    _fetchPalinsesto();
  }

  Future<void> _fetchPalinsesto() async {
    try {
      final response = await http.get(
        Uri.parse('https://stereo98.com/wp-json/stereo98/v1/palinsesto'),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _palinsesto = data['palinsesto'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  bool _isLive(String start, String end) {
    try {
      final now = DateTime.now();
      final s = start.split(':');
      final e = end.split(':');
      final startMin = int.parse(s[0]) * 60 + int.parse(s[1]);
      var endMin = int.parse(e[0]) * 60 + int.parse(e[1]);
      if (endMin == 0) endMin = 1440; // Fix: mezzanotte = 1440
      final nowMin = now.hour * 60 + now.minute;
      return nowMin >= startMin && nowMin < endMin;
    } catch (_) { return false; }
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
        title: const Text('Palinsesto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: Column(
          children: [
            // 🔥 Giorni della settimana — dimensioni fisse, funziona in entrambe le orientazioni
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: _giorni.length,
                itemBuilder: (context, i) {
                  final isSelected = _selectedDay == i;
                  final isToday = DateTime.now().weekday - 1 == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: isSelected ? const LinearGradient(
                          colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)],
                        ) : null,
                        color: isSelected ? null : Colors.transparent,
                        border: Border.all(
                          color: isToday && !isSelected
                              ? const Color(0xFFD85D9D)
                              : Colors.white.withOpacity(0.3),
                          width: isToday && !isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        _giorni[i].substring(0, 3),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 🔥 Lista show
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFD85D9D)))
                  : _buildShowList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowList() {
    if (_palinsesto.isEmpty) {
      return const Center(child: Text('Nessun palinsesto disponibile', style: TextStyle(color: Colors.white)));
    }
    List<dynamic> shows = [];
    if (_selectedDay < _palinsesto.length) {
      shows = _palinsesto[_selectedDay]['shows'] ?? [];
    }
    if (shows.isEmpty) {
      return const Center(child: Text('Nessuno show programmato', style: TextStyle(color: Colors.white)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: shows.length,
      itemBuilder: (context, i) {
        final show = shows[i];
        final nome = _fixText(show['show_nome'] ?? '');
        final image = show['show_immagine'] ?? '';
        final start = show['orario_inizio'] ?? '';
        final end = show['orario_fine'] ?? '';
        final isLive = _isLive(start, end) && DateTime.now().weekday - 1 == _selectedDay;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: isLive
                  ? [const Color(0xFFD85D9D).withOpacity(0.3), const Color(0xFF4EC8E8).withOpacity(0.15)]
                  : [const Color(0xFFD85D9D).withOpacity(0.08), const Color(0xFF4EC8E8).withOpacity(0.04)],
            ),
            border: Border.all(
              color: isLive ? const Color(0xFFD85D9D) : const Color(0xFFD85D9D).withOpacity(0.2),
              width: isLive ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image.isNotEmpty
                  ? Image.network(image, width: 55, height: 55, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            title: Row(
              children: [
                if (isLive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD85D9D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(nome,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            subtitle: Text(
              '$start - $end',
              style: const TextStyle(color: Color(0xFF4EC8E8), fontSize: 13),
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      width: 55, height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFD85D9D).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.tv, color: Colors.white),
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
