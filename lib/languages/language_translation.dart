import 'package:get/get.dart';
import 'spanish.dart';
import 'english.dart';
import 'arabic.dart';
import 'bangla.dart';
import 'italian.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'it_IT': itIT,
        'en_US': enUS,
        'bn_BD': bnBD,
        'ar_SA': arSA,
        'es_ES': esES,
      };
}
