import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Extension on BuildContext for theme-aware colors.
/// Usage: context.s98Text, context.s98Surface(0.1), etc.
extension S98Theme on BuildContext {
  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;

  // ── Text colors ──────────────────────────────────────────────────────────
  Color get s98Text =>
      isLightTheme ? const Color(0xFF1A1A1A) : Colors.white;

  Color get s98TextSecondary =>
      isLightTheme ? const Color(0xFF4A4A4A) : const Color(0xB3FFFFFF); // white70

  Color get s98TextMuted =>
      isLightTheme ? const Color(0xFF777777) : const Color(0x8AFFFFFF); // white54

  Color get s98TextFaint =>
      isLightTheme ? const Color(0xFFAAAAAA) : const Color(0x4DFFFFFF); // white30

  Color get s98TextDisabled =>
      isLightTheme ? const Color(0xFFBBBBBB) : const Color(0x3DFFFFFF); // white24

  // ── Icon colors ──────────────────────────────────────────────────────────
  Color get s98Icon =>
      isLightTheme ? const Color(0xFF1A1A1A) : Colors.white;

  Color get s98IconMuted =>
      isLightTheme ? const Color(0xFF777777) : const Color(0x8AFFFFFF);

  // ── Surface overlays (for cards, borders, subtle backgrounds) ───────────
  Color s98Surface(double opacity) =>
      isLightTheme
          ? Colors.black.withOpacity(opacity)
          : Colors.white.withOpacity(opacity);

  // ── Divider ──────────────────────────────────────────────────────────────
  Color get s98Divider =>
      isLightTheme
          ? Colors.black.withOpacity(0.12)
          : Colors.white.withOpacity(0.12);

  // ── Modal / bottom-sheet gradient backgrounds ───────────────────────────
  List<Color> get s98ModalGradient => isLightTheme
      ? [const Color(0xFFF5EEF0), const Color(0xFFEDE8F0)]
      : [const Color(0xFF2A1A2E), const Color(0xFF1A0A1E)];

  // ── Section card gradient (istruzioni, FAQ) ─────────────────────────────
  List<Color> get s98SectionGradient => isLightTheme
      ? [const Color(0xFFECE5EB), const Color(0xFFE5EBF0)]
      : [const Color(0xFF16213E), const Color(0xFF1A1A2E)];

  // ── Home body gradient ──────────────────────────────────────────────────
  List<Color> get s98BodyGradient => isLightTheme
      ? [
          Theme.of(this).primaryColor,
          Theme.of(this).cardColor,
          Theme.of(this).canvasColor,
        ]
      : [const Color(0xFF1A0A10), const Color(0xFF000000), const Color(0xFF0A0A1A)];

  // ── AlertDialog background ──────────────────────────────────────────────
  Color get s98DialogBg =>
      isLightTheme ? const Color(0xFFF5F0F2) : const Color(0xFF1A1A2E);

  // ── Form field fill ─────────────────────────────────────────────────────
  Color get s98FieldFill =>
      isLightTheme
          ? Colors.black.withOpacity(0.05)
          : Colors.black.withOpacity(0.15);

  // ── System UI overlay style (status bar icons) ──────────────────────────
  SystemUiOverlayStyle get s98SystemUI => isLightTheme
      ? const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        )
      : const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        );

  // ── RefreshIndicator background ─────────────────────────────────────────
  Color get s98RefreshBg =>
      isLightTheme ? const Color(0xFFF5EEF0) : const Color(0xFF1A0A1E);
}
