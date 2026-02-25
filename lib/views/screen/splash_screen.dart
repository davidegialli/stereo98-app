import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stereo98/controller/splash_controller.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>();

    return Scaffold(
      backgroundColor: CustomColor.primaryColor,
      body: Center(
        child: Image.asset(
          Strings.splashLogo,
          width: 200.w,
          height: 200.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
