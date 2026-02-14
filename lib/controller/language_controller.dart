import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../languages/datastorage_service.dart';

class LanguageController extends GetxController {
  final storage = Get.find<StorageService>();
  final RxString locale = Get.locale.toString().obs;

  final Map<String, dynamic> optionsLocales = {
    // 🔥 Italiano PRIMO nella lista
    'it_IT': {
      'languageCode': 'it',
      'countryCode': 'IT',
      'description': '🇮🇹 Italiano'
    },
    'en_US': {
      'languageCode': 'en',
      'countryCode': 'US',
      'description': '🇬🇧 English'
    },
    'es_ES': {
      'languageCode': 'es',
      'countryCode': 'ES',
      'description': '🇪🇸 Español'
    },
    'ar_SA': {
      'languageCode': 'ar',
      'countryCode': 'SA',
      'description': '🇸🇦 عربى',
    },
  };

  void updateLocale(String? key) {
    final String languageCode = optionsLocales[key]['languageCode'];
    final String countryCode = optionsLocales[key]['countryCode'];
    Get.updateLocale(Locale(languageCode, countryCode));
    locale.value = Get.locale.toString();
    storage.write('languageCode', languageCode);
    storage.write('countryCode', countryCode);
  }
}
