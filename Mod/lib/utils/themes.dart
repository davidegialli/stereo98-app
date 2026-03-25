class AppThemes {
  // ── Temi scuri ──
  static const int vivace    = 0; // Vivace (azzurro-fucsia, brand puro)
  static const int scuro     = 1; // Scuro (nero profondo)
  static const int auto      = 2; // Automatico (Chiaro ↔ tema scuro scelto)
  static const int bluNotte  = 3; // Blu Notte (navy flat)
  static const int amaranto  = 4; // Amaranto (vino/fucsia profondo)
  static const int grafite   = 6; // Grafite (grigio carbone elegante)

  // ── Temi chiari ──
  static const int chiaro    = 5; // Chiaro (bianco classico)
  static const int rosaCipria = 7; // Rosa Cipria (rosa caldo tenue)
  static const int azzurroCielo = 8; // Azzurro Cielo (celeste luminoso)

  // Alias
  static const int light = chiaro;
  static const int dark  = scuro;

  /// Ritorna true se il tema è chiaro/diurno
  static bool isLight(int themeId) {
    return themeId == chiaro || themeId == rosaCipria || themeId == azzurroCielo || themeId == vivace;
  }

  /// Tutti i temi scuri/notturni disponibili (per la selezione in Automatico)
  static const List<int> darkThemes = [scuro, bluNotte, amaranto, grafite];

  /// Tutti i temi chiari/diurni disponibili
  static const List<int> lightThemes = [chiaro, vivace, rosaCipria, azzurroCielo];

  static String toStr(int themeId) {
    switch (themeId) {
      case vivace:       return "Vivace";
      case scuro:        return "Scuro";
      case auto:         return "Automatico";
      case bluNotte:     return "Blu Notte";
      case amaranto:     return "Amaranto";
      case chiaro:       return "Chiaro";
      case grafite:      return "Grafite";
      case rosaCipria:   return "Rosa Cipria";
      case azzurroCielo: return "Azzurro Cielo";
      default:           return "Scuro";
    }
  }

  /// Icona per ogni tema
  static String icon(int themeId) {
    switch (themeId) {
      case vivace:       return "🎨";
      case scuro:        return "🌑";
      case auto:         return "🔄";
      case bluNotte:     return "🌊";
      case amaranto:     return "🍷";
      case chiaro:       return "☀️";
      case grafite:      return "⚙️";
      case rosaCipria:   return "🌸";
      case azzurroCielo: return "🩵";
      default:           return "🌑";
    }
  }
}
