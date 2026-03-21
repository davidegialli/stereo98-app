import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/strings.dart';
import 'package:stereo98/utils/themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  String _versionText = '';

  /// Colori splash basati sul tema corrente salvato
  late final _SplashColors _colors = _getSplashColors();

  _SplashColors _getSplashColors() {
    final box = GetStorage();
    final savedMode = box.read('stereo98_theme_mode') ?? AppThemes.scuro;
    int effectiveTheme = savedMode;
    if (savedMode == AppThemes.auto) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final savedDark  = box.read('stereo98_dark_theme') ?? AppThemes.scuro;
      final savedLight = box.read('stereo98_light_theme') ?? AppThemes.chiaro;
      effectiveTheme = brightness == Brightness.dark ? savedDark : savedLight;
    }
    return _SplashColors.fromTheme(effectiveTheme);
  }

  late AnimationController _enterController;
  late Animation<double> _enterScale;
  late Animation<double> _enterFade;

  late AnimationController _breatheController;
  late Animation<double> _breatheScale;

  late AnimationController _ringController;
  late Animation<double> _ringScale;
  late Animation<double> _ringFade;

  late AnimationController _glowController;
  late Animation<double> _glowIntensity;

  late AnimationController _spinnerController;
  late Animation<double> _spinnerFade;

  late AnimationController _versionController;
  late Animation<double> _versionFade;

  @override
  void initState() {
    super.initState();
    _loadVersion();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _enterScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.12).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.95).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
    ]).animate(_enterController);
    _enterFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _breatheScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringScale = Tween<double>(begin: 1.0, end: 3.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    _ringFade = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeIn),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowIntensity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _spinnerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spinnerController, curve: Curves.easeIn),
    );

    _versionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _versionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _versionController, curve: Curves.easeOut),
    );

    _startSequence();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _versionText = 'v${info.version}');
      }
    } catch (_) {
      if (mounted) setState(() => _versionText = Strings.version);
    }
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    _enterController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _ringController.forward();
    _glowController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _breatheController.repeat(reverse: true);

    _spinnerController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _versionController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    _breatheController.dispose();
    _ringController.dispose();
    _glowController.dispose();
    _spinnerController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors.bg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _colors.gradient,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 80),
            _buildAnimatedLogo(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _spinnerFade,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _colors.accent,
                        backgroundColor: CustomColor.gray.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _versionFade,
                    child: Text(
                      _versionText.isNotEmpty ? _versionText : Strings.version,
                      style: TextStyle(
                        color: _colors.textMuted,
                        fontSize: 11,
                        letterSpacing: 0.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    final size = MediaQuery.of(context).size;
    final logoSize = (size.shortestSide * 0.35).clamp(100.0, 180.0);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _enterController, _breatheController,
        _ringController, _glowController,
      ]),
      builder: (context, child) {
        final enterDone = _enterController.isCompleted;
        final scale = enterDone
            ? _breatheScale.value
            : _enterScale.value;
        final opacity = _enterFade.value;

        final glowVal = _glowIntensity.value;

        return SizedBox(
          width: logoSize * 3.5,
          height: logoSize * 3.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_ringController.isAnimating || _ringController.value > 0)
                Transform.scale(
                  scale: _ringScale.value,
                  child: Container(
                    width: logoSize + 20,
                    height: logoSize + 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _colors.accent.withOpacity(_ringFade.value),
                        width: 3,
                      ),
                    ),
                  ),
                ),

              Opacity(
                opacity: opacity,
                child: Container(
                  width: logoSize + 80,
                  height: logoSize + 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _colors.accent.withOpacity(glowVal * 0.5 * opacity),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                      BoxShadow(
                        color: _colors.accentSecondary.withOpacity(glowVal * 0.3 * opacity),
                        blurRadius: 80,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: _colors.logoBg,
                      boxShadow: [
                        BoxShadow(
                          color: _colors.accent.withOpacity(glowVal * 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage(Strings.splashLogo),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Colori adattivi per lo splash screen in base al tema salvato
class _SplashColors {
  final Color bg;
  final List<Color> gradient;
  final Color accent;
  final Color accentSecondary;
  final Color logoBg;
  final Color textMuted;

  const _SplashColors({
    required this.bg,
    required this.gradient,
    required this.accent,
    required this.accentSecondary,
    required this.logoBg,
    required this.textMuted,
  });

  /// Colori per temi scuri — glow leggero, sfondo scuro
  static _SplashColors _dark(Color primary, Color card, Color canvas) {
    return _SplashColors(
      bg: primary,
      gradient: [
        Color.lerp(primary, Colors.black, 0.3)!,
        primary,
        Color.lerp(canvas, Colors.black, 0.3)!,
      ],
      accent: CustomColor.accentFucsia,
      accentSecondary: CustomColor.accentAzzurro,
      logoBg: Colors.transparent,
      textMuted: Colors.white38,
    );
  }

  /// Colori per temi chiari — glow leggero, sfondo chiaro
  static _SplashColors _light(Color primary, Color card, Color canvas) {
    return _SplashColors(
      bg: primary,
      gradient: [primary, card, canvas],
      accent: CustomColor.accentFucsia.withOpacity(0.6),
      accentSecondary: CustomColor.accentAzzurro.withOpacity(0.5),
      logoBg: Colors.transparent,
      textMuted: Colors.black38,
    );
  }

  factory _SplashColors.fromTheme(int themeId) {
    switch (themeId) {
      case AppThemes.vivace:
        return _dark(CustomColor.vivacePrimary, CustomColor.vivaceCard, CustomColor.vivaceCanvas);
      case AppThemes.bluNotte:
        return _dark(CustomColor.bluNottePrimary, CustomColor.bluNotteCard, CustomColor.bluNotteCanvas);
      case AppThemes.amaranto:
        return _dark(CustomColor.amarantoPrimary, CustomColor.amarantoCard, CustomColor.amarantoCanvas);
      case AppThemes.grafite:
        return _dark(CustomColor.grafitePrimary, CustomColor.grafiteCard, CustomColor.grafiteCanvas);
      case AppThemes.chiaro:
        return _light(CustomColor.chiaroPrimary, CustomColor.chiaroCard, CustomColor.chiaroCanvas);
      case AppThemes.rosaCipria:
        return _light(CustomColor.rosaCipriaPrimary, CustomColor.rosaCipriaCard, CustomColor.rosaCipriaCanvas);
      case AppThemes.azzurroCielo:
        return _light(CustomColor.azzurroCieloPrimary, CustomColor.azzurroCieloCard, CustomColor.azzurroCieloCanvas);
      case AppThemes.scuro:
      default:
        return _dark(CustomColor.darkPrimaryColor, CustomColor.darkPrimaryColorOne, CustomColor.darkPrimaryColorTwo);
    }
  }
}
