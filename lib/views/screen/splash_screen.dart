import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stereo98/controller/splash_controller.dart';
import 'package:stereo98/utils/strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    // Logo: scala da piccolo a grande con effetto elastico
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Testo: fade in + slide up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Pulsazione logo sottile
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    // Piccola pausa iniziale
    await Future.delayed(const Duration(milliseconds: 200));

    // Logo entra
    _logoController.forward();

    // Testo dopo 600ms
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    // Pulsazione sottile dopo che il logo è arrivato
    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Il controller gestisce la navigazione
    Get.find<SplashController>();

    return Scaffold(
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
        child: Stack(
          children: [
            // Cerchi decorativi di sfondo
            Positioned(
              top: -80,
              right: -80,
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value * 0.1,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFD85D9D).withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value * 0.1,
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF4EC8E8).withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Contenuto principale
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animato
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoController, _pulseController]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value * _pulseScale.value,
                          child: child,
                        ),
                      );
                    },
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

                  const SizedBox(height: 30),

                  // Titolo
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
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

                  // Sottotitolo
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
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
                  FadeTransition(
                    opacity: _textOpacity,
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

            // Indicatore di caricamento in basso
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textOpacity,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0x66D85D9D),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
