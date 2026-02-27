// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/size.dart';
import 'package:stereo98/utils/strings.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = 'Versione ${info.version} (${info.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = (MediaQuery.of(context).size.shortestSide * 0.35).clamp(100.0, 160.0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.close(1),
        ),
        title: Text(
          Strings.aboutUs.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            addVerticalSpace(20),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD85D9D).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            addVerticalSpace(24),
            const Center(
              child: Text(
                'Stereo 98 DAB+',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            addVerticalSpace(6),
            Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)],
                ).createShader(bounds),
                child: const Text(
                  'La tua radio preferita',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            addVerticalSpace(30),
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)],
                ),
              ),
            ),
            addVerticalSpace(24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFD85D9D).withOpacity(0.07),
                border: Border.all(color: const Color(0xFFD85D9D).withOpacity(0.2)),
              ),
              child: const Text(
                'Stereo 98 DAB+ è la radio che ti accompagna ogni giorno con la migliore musica, '
                'informazione e intrattenimento. Presente sul digitale terrestre DAB+ e in streaming '
                'su tutto il territorio nazionale.\n\n'
                'Ascoltaci in diretta, segui i nostri programmi e resta sempre connesso con la nostra community.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),
            addVerticalSpace(24),
            _infoRow(Icons.radio, 'Frequenza', 'DAB+ Digitale Terrestre'),
            addVerticalSpace(10),
            _infoRow(Icons.wifi, 'Streaming', 'stereo98.com'),
            addVerticalSpace(10),
            _infoRow(Icons.location_on, 'Studi', 'Veneto • Piemonte • Lazio'),
            addVerticalSpace(10),
            _infoRow(Icons.music_note, 'Licenza SIAE', 'n. 202500000803'),
            addVerticalSpace(40),
            Center(
              child: Text(
                _version.isNotEmpty ? _version : 'Versione 1.1.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
            ),
            addVerticalSpace(20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF4EC8E8).withOpacity(0.06),
        border: Border.all(color: const Color(0xFF4EC8E8).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4EC8E8), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Color(0xFF4EC8E8), fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
