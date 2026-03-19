// ignore_for_file: deprecated_member_use

import 'package:audio_service/audio_service.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
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

  final themeCollection = ThemeCollection(themes: {
    AppThemes.vivace: ThemeData(
      primaryColor: CustomColor.vivacePrimary,
      scaffoldBackgroundColor: CustomColor.vivacePrimary,
      cardColor: CustomColor.vivaceCard,
      canvasColor: CustomColor.vivaceCanvas,
    ),
    AppThemes.scuro: ThemeData(
      primaryColor: CustomColor.darkPrimaryColor,
      scaffoldBackgroundColor: CustomColor.darkPrimaryColor,
      cardColor: CustomColor.darkPrimaryColorOne,
      canvasColor: CustomColor.darkPrimaryColorTwo,
    ),
    AppThemes.auto: ThemeData(
      primaryColor: CustomColor.darkPrimaryColor,
      scaffoldBackgroundColor: CustomColor.darkPrimaryColor,
      cardColor: CustomColor.darkPrimaryColorOne,
      canvasColor: CustomColor.darkPrimaryColorTwo,
    ),
    AppThemes.bluNotte: ThemeData(
      primaryColor: CustomColor.bluNottePrimary,
      scaffoldBackgroundColor: CustomColor.bluNottePrimary,
      cardColor: CustomColor.bluNotteCard,
      canvasColor: CustomColor.bluNotteCanvas,
    ),
    AppThemes.amaranto: ThemeData(
      primaryColor: CustomColor.amarantoPrimary,
      scaffoldBackgroundColor: CustomColor.amarantoPrimary,
      cardColor: CustomColor.amarantoCard,
      canvasColor: CustomColor.amarantoCanvas,
    ),
    AppThemes.chiaro: ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFFFFFFFF),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      cardColor: const Color(0xFFF5F5F5),
      canvasColor: const Color(0xFFEEEEEE),
      iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D4A5E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
        bodyMedium: TextStyle(color: Color(0xFF1A1A1A)),
        bodySmall: TextStyle(color: Color(0xFF1A1A1A)),
        titleLarge: TextStyle(color: Color(0xFF1A1A1A)),
        titleMedium: TextStyle(color: Color(0xFF1A1A1A)),
        titleSmall: TextStyle(color: Color(0xFF1A1A1A)),
      ),
    ),
  });

  int _getInitialTheme() {
    final savedMode = _box.read('stereo98_theme_mode') ?? AppThemes.scuro;
    if (savedMode == AppThemes.auto) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final savedDark = _box.read('stereo98_dark_theme') ?? AppThemes.scuro;
      return brightness == Brightness.dark ? savedDark : AppThemes.chiaro;
    }
    return savedMode;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) => DynamicTheme(
        themeCollection: themeCollection,
        defaultThemeId: _getInitialTheme(),
        builder: (context, theme) {
          // _AutoThemeListener è DENTRO DynamicTheme — può chiamare DynamicTheme.of(context)
          return _AutoThemeListener(
            box: _box,
            child: GetMaterialApp(
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
              theme: theme,
              navigatorKey: Get.key,
              initialRoute: Routes.splashScreen,
              getPages: Routes.list,
            ),
          );
        },
      ),
    );
  }
}

// Questo widget è DENTRO DynamicTheme, quindi DynamicTheme.of(context) funziona
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
    final savedMode = widget.box.read('stereo98_theme_mode') ?? AppThemes.scuro;
    if (savedMode == AppThemes.auto) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final savedDark = widget.box.read('stereo98_dark_theme') ?? AppThemes.scuro;
      final effectiveTheme = brightness == Brightness.dark ? savedDark : AppThemes.chiaro;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DynamicTheme.of(context)?.setTheme(effectiveTheme);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
