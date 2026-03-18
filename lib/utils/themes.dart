class AppThemes {
  static const int scuro    = 1; // Scuro (nero profondo)
  static const int vivace   = 0; // Vivace (azzurro-fucsia, brand puro) — mantenuto per retrocompat
  static const int auto     = 2; // Automatico (Chiaro ↔ Scuro)
  static const int bluNotte = 3; // Blu Notte (navy flat)
  static const int amaranto = 4; // Amaranto (vino/fucsia profondo)
  static const int chiaro   = 5; // Chiaro (bianco, testo scuro)

  // retrocompatibilità alias
  static const int light = chiaro;
  static const int dark  = scuro;

  static String toStr(int themeId) {
    switch (themeId) {
      case chiaro:   return "Chiaro";
      case scuro:    return "Scuro";
      case auto:     return "Automatico";
      case bluNotte: return "Blu Notte";
      case amaranto: return "Amaranto";
      case vivace:   return "Vivace";
      default:       return "Scuro";
    }
  }
}
