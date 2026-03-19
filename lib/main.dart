// ignore_for_file: deprecated_member_use

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:stereo98/languages/datastorage_service.dart';
import 'package:stereo98/languages/language_translation.dart';
import 'package:stereo98/routes/routes.dart';
import 'package:stereo98/services/audio_handler.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/network_check/dependency_injection.dart';
import 'package:stereo98/utils/strings.dart';
import 'package:stereo98/utils/themes.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stereo98/services/notification_service.dart';

// Notifier globale per il tema — accessibile da settings_screen
final appThemeNotifier = ValueNotifier<int>(0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  await GetStorage.init();
  await initialConfig();
  InternetCheckDependencyInjection.init();

  OneSignal.initialize('3e87897b-47fb-4389-9efe-9b99ecc6949d');
  OneSignal.Notifications.requestPermission(true);

  await NotificationService().init();

  try {
    final audioHandler = await AudioService.init(
      builder: () => RadioAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.stereo98.dabplus.audio',
        androidNotificationChannelName: 'Stereo 98 DAB+',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'drawable/ic_notification',
      ),
    );
    Get.put<RadioAudioHandler>(audioHandler, permanent: true);
  } catch (e) {
    debugPrint('[Stereo98] AudioService.init failed: $e');
    Get.put<RadioAudioHandler>(RadioAudioHandler(), permanent: true);
  }

  runApp(const MyApp());
}

Future<void> initialConfig() async {
  await Get.putAsync(() => StorageService().init());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = Get.put(StorageService());
  final _box = GetStorage();

  // Temi scuri disponibili
  ThemeData get _scuroTheme => ThemeData(
    primaryColor: CustomColor.darkPrimaryColor,
    scaffoldBackgroundColor: CustomColor.darkPrimaryColor,
    cardColor: CustomColor.darkPrimaryColorOne,
    canvasColor: CustomColor.darkPrimaryColorTwo,
  );

  ThemeData get _vivaceTheme => ThemeData(
    primaryColor: CustomColor.vivacePrimary,
    scaffoldBackgroundColor: CustomColor.vivacePrimary,
    cardColor: CustomColor.vivaceCard,
    canvasColor: CustomColor.vivaceCanvas,
  );

  ThemeData get _bluNotteTheme => ThemeData(
    primaryColor: CustomColor.bluNottePrimary,
    scaffoldBackgroundColor: CustomColor.bluNottePrimary,
    cardColor: CustomColor.bluNotteCard,
    canvasColor: CustomColor.bluNotteCanvas,
  );

  ThemeData get _amarantoTheme => ThemeData(
    primaryColor: CustomColor.amarantoPrimary,
    scaffoldBackgroundColor: CustomColor.amarantoPrimary,
    cardColor: CustomColor.amarantoCard,
    canvasColor: CustomColor.amarantoCanvas,
  );

  // Tema chiaro di sistema
  ThemeData get _lightSystemTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0D4A5E),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: const Color(0xFFFFFFFF),
    canvasColor: const Color(0xFFEEEEEE),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D4A5E),
      foregroundColor: Colors.white,
    ),
  );

  @override
  void initState() {
    super.initState();
    appThemeNotifier.value = _box.read('stereo98_theme_mode') ?? AppThemes.scuro;
  }

  ThemeData _getTheme(int themeId) {
    switch (themeId) {
      case AppThemes.vivace:   return _vivaceTheme;
      case AppThemes.bluNotte: return _bluNotteTheme;
      case AppThemes.amaranto: return _amarantoTheme;
      default:                 return _scuroTheme;
    }
  }

  ThemeData _getDarkTheme() {
    final savedDark = _box.read('stereo98_dark_theme') ?? AppThemes.scuro;
    return _getTheme(savedDark);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) => _AutoThemeListener(
        box: _box,
        child: ValueListenableBuilder<int>(
          valueListenable: appThemeNotifier,
          builder: (context, themeId, _) {
            final isAuto = themeId == AppThemes.auto;
            return GetMaterialApp(
              builder: (context, widget) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: widget!,
                );
              },
              translations: AppTranslations(),
              locale: storage.languageCode != null
                  ? Locale(storage.languageCode!, storage.countryCode)
                  : const Locale('it', 'IT'),
              fallbackLocale: const Locale('it', 'IT'),
              title: Strings.oneRadio,
              debugShowCheckedModeBanner: false,
              theme: isAuto ? _lightSystemTheme : _getTheme(themeId),
              darkTheme: isAuto ? _getDarkTheme() : null,
              themeMode: isAuto ? ThemeMode.system : ThemeMode.light,
              navigatorKey: Get.key,
              initialRoute: Routes.splashScreen,
              getPages: Routes.list,
            );
          },
        ),
      ),
    );
  }
}

class _AutoThemeListener extends StatefulWidget {
  final GetStorage box;
  final Widget child;
  const _AutoThemeListener({required this.box, required this.child});

  @override
  State<_AutoThemeListener> createState() => _AutoThemeListenerState();
}

class _AutoThemeListenerState extends State<_AutoThemeListener> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Con ThemeMode.system Flutter gestisce tutto automaticamente
    // Forziamo solo un rebuild del ValueListenableBuilder
    final savedMode = widget.box.read('stereo98_theme_mode') ?? AppThemes.scuro;
    if (savedMode == AppThemes.auto) {
      appThemeNotifier.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
