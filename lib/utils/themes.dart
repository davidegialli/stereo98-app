class AppThemes {
  static const int light = 0;
  static const int dark = 1;

  static String toStr(int themeId) {
    switch (themeId) {
      case light:
        return "Light";
      case dark:
        return "Dark";
      default:
        return "Unknown";
    }
  }
}
