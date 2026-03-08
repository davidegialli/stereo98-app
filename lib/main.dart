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

  // ✅ Rotazione libera — tutte le orientazioni supportate
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

  // OneSignal
  OneSignal.initialize('3e87897b-47fb-4389-9efe-9b99ecc6949d');
  OneSignal.Notifications.requestPermission(true);

  // Local notifications (palinsesto reminders)
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final storage = Get.put(StorageService());
  final _box = GetStorage();

  final dark = ThemeData.dark();
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
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initialConfig();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Aggiorna tema se è in modalità auto
    final savedMode = _box.read('stereo98_theme_mode') ?? 0;
    if (savedMode == AppThemes.auto) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final effectiveTheme = brightness == Brightness.dark
          ? AppThemes.scuro
          : AppThemes.vivace;
      DynamicTheme.of(context)?.setTheme(effectiveTheme);
    }
  }

  int _getInitialTheme() {
    final savedMode = _box.read('stereo98_theme_mode') ?? 0;
    if (savedMode == AppThemes.auto)     return AppThemes.scuro;
    if (savedMode == AppThemes.scuro)    return AppThemes.scuro;
    if (savedMode == AppThemes.bluNotte) return AppThemes.bluNotte;
    if (savedMode == AppThemes.amaranto) return AppThemes.amaranto;
    return AppThemes.vivace;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) => DynamicTheme(
          themeCollection: themeCollection,
          defaultThemeId: _getInitialTheme(),
          builder: (context, theme) {
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
              theme: theme,
              navigatorKey: Get.key,
              initialRoute: Routes.splashScreen,
              getPages: Routes.list,
            );
          }),
    );
  }
}
