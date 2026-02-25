import 'dart:async';

import 'package:get/get.dart';
import 'package:stereo98/routes/routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _goToScreen();
  }

  Future<void> _goToScreen() async {
    Timer(const Duration(seconds: 3), () => Get.offAllNamed(Routes.homeScreen));
  }
}
