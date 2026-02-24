// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/dimsensions.dart';
import 'package:stereo98/utils/size.dart';
import 'package:stereo98/utils/strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          padding: EdgeInsets.all(Dimensions.defaultPaddingSize),
          children: [
            addVerticalSpace(20.h),
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
                    width: 160.w,
                    height: 160.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            addVerticalSpace(24.h),
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
            addVerticalSpace(6.h),
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
            addVerticalSpace(30.h),
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)],
                ),
              ),
            ),
            addVerticalSpace(24.h),
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
            addVerticalSpace(24.h),
            _infoRow(Icons.radio, 'Frequenza', 'DAB+ Digitale Terrestre'),
            addVerticalSpace(10.h),
            _infoRow(Icons.wifi, 'Streaming', 'stereo98.com'),
            addVerticalSpace(10.h),
            _infoRow(Icons.location_on, 'Studi', 'Veneto • Piemonte • Lazio'),
            addVerticalSpace(40.h),
            Center(
              child: Text(
                'Versione 1.1.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
            ),
            addVerticalSpace(20.h),
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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
