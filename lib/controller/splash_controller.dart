import 'package:get/get.dart';
import 'package:stereo98/routes/routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    Get.offNamed(Routes.homeScreen);
  }
}
