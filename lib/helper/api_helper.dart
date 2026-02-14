import 'package:stereo98/utils/config.dart';


class ApiHelper {
  static Uri url (String endpoint) {
    return Uri.parse('${Config.baseUrl}$endpoint');
  }

}