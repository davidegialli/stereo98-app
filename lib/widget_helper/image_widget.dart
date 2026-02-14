import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/strings.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      height: 150.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: CustomColor.whiteColor,
          boxShadow: const [
            BoxShadow(
              color: CustomColor.whiteColor,
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage(Strings.splashLogo),
            fit: BoxFit.fill,
          )),
    );
  }
}
