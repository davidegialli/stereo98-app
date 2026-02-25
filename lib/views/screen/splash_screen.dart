import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stereo98/controller/splash_controller.dart';
import 'package:stereo98/utils/strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLogo = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    Get.find<SplashController>();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showLogo = true);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showText = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0a0a1a),
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo con animazione scala + fade
            AnimatedScale(
              scale: _showLogo ? 1.0 : 0.3,
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              child: AnimatedOpacity(
                opacity: _showLogo ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD85D9D).withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: const Color(0xFF4EC8E8).withOpacity(0.2),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      Strings.splashLogo,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // STEREO 98 con gradiente
            AnimatedSlide(
              offset: _showText ? Offset.zero : const Offset(0, 0.5),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _showText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)],
                  ).createShader(bounds),
                  child: const Text(
                    'STEREO 98',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // DAB+
            AnimatedSlide(
              offset: _showText ? Offset.zero : const Offset(0, 0.5),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _showText ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: const Text(
                  'DAB+',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF4EC8E8),
                    letterSpacing: 8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tagline
            AnimatedOpacity(
              opacity: _showText ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: const Text(
                'La radio che ti ascolta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0x99FFFFFF),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
