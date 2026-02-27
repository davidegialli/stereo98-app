import 'package:get/get.dart';
import 'package:stereo98/bindings/home_binding.dart';
import 'package:stereo98/controller/splash_controller.dart';
import 'package:stereo98/views/screen/about_screen.dart';
import 'package:stereo98/views/screen/cronologia_screen.dart';
import 'package:stereo98/views/screen/home_screen.dart';
import 'package:stereo98/views/screen/settings_screen.dart';
import 'package:stereo98/views/screen/splash_screen.dart';
import 'package:stereo98/views/screen/podcast_screen.dart';
import 'package:stereo98/views/screen/palinsesto_screen.dart';
import 'package:stereo98/views/screen/shows_screen.dart';
import 'package:stereo98/views/screen/sondaggi_screen.dart';
import 'package:stereo98/views/screen/scrivici_screen.dart';
import 'package:stereo98/views/screen/istruzioni_screen.dart';

class Routes {
  static const String splashScreen = '/splashScreen';
  static const String homeScreen = '/homeScreen';
  static const String aboutScreen = '/aboutScreen';
  static const String settingsScreen = '/settingsScreen';
  static const String podcastScreen = '/podcastScreen';
  static const String palinsestoScreen = '/palinsestoScreen';
  static const String showsScreen = '/showsScreen';
  static const String sondaggiScreen = '/sondaggiScreen';
  static const String scriviciScreen = '/scriviciScreen';
  static const String istruzioniScreen = '/istruzioniScreen';
  static const String cronologiaScreen = '/cronologiaScreen';

  static var list = [
    GetPage(
      name: splashScreen,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() => Get.put(SplashController())),
    ),
    GetPage(
      name: homeScreen,
      page: () => const HomeScreen(),
      binding: HomeScreenBinding(),
    ),
    GetPage(name: aboutScreen, page: () => const AboutScreen()),
    GetPage(name: settingsScreen, page: () => const SettingsScreen()),
    GetPage(name: podcastScreen, page: () => const PodcastScreen()),
    GetPage(name: palinsestoScreen, page: () => const PalinsestoScreen()),
    GetPage(name: showsScreen, page: () => const ShowsScreen()),
    GetPage(name: sondaggiScreen, page: () => const SondaggiScreen()),
    GetPage(name: scriviciScreen, page: () => const ScriviciScreen()),
    GetPage(name: istruzioniScreen, page: () => const IstruzioniScreen()),
    GetPage(name: cronologiaScreen, page: () => const CronologiaScreen()),
  ];
}
