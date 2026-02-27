class AppThemes {
  static const int light = 0;
  static const int dark = 1;
  static const int auto = 2;

  static String toStr(int themeId) {
    switch (themeId) {
      case light:
        return "Light";
      case dark:
        return "Dark";
      case auto:
        return "Automatico";
      default:
        return "Unknown";
    }
  }
}
