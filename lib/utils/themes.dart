class AppThemes {
  static const int scuro    = 1; // Scuro (nero profondo)
  static const int vivace   = 0; // Vivace (azzurro-fucsia, brand puro)
  static const int auto     = 2; // Automatico (sistema)
  static const int bluNotte = 3; // Blu Notte (navy flat)
  static const int amaranto = 4; // Amaranto (vino/fucsia profondo)

  static const int light = vivace;
  static const int dark  = scuro;

  static String toStr(int themeId) {
    switch (themeId) {
      case scuro:    return "Scuro";
      case vivace:   return "Vivace";
      case auto:     return "Automatico";
      case bluNotte: return "Blu Notte";
      case amaranto: return "Amaranto";
      default:       return "Scuro";
    }
  }
}
