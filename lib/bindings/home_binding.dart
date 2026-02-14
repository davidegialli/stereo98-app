import 'package:get/get.dart';
import 'package:stereo98/controller/home_controller.dart';

class HomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      HomeController(),
    );
  }
}
