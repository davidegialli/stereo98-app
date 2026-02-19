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
   
    
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait lock globale per tutta l'app
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Edge-to-edge per Android 15+ (SDK 35)
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

  // Inizializza audio_service
  try {
    final audioHandler = await AudioService.init(
      builder: () => RadioAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.stereo98.dabplus.audio',
        androidNotificationChannelName: 'Stereo 98 DAB+',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
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
  final String oneSignalAppId = '0c551b09-62f8-4877-9f48-4b84b70f9546';

  final dark = ThemeData.dark();
  final themeCollection = ThemeCollection(themes: {
    AppThemes.light: ThemeData(
      primaryColor: CustomColor.primaryColor,
      scaffoldBackgroundColor: CustomColor.primaryColor,
      cardColor: CustomColor.primaryColorOne,
      canvasColor: CustomColor.primaryColorTwo,
    ),
    AppThemes.dark: ThemeData(
      primaryColor: CustomColor.darkPrimaryColor,
      scaffoldBackgroundColor: CustomColor.darkPrimaryColor,
      cardColor: CustomColor.darkPrimaryColorOne,
      canvasColor: CustomColor.darkPrimaryColorTwo,
    ),
  });

  @override
  void initState() {
    super.initState();
    initialConfig();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) => DynamicTheme(
          themeCollection: themeCollection,
          defaultThemeId: AppThemes.light,
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
