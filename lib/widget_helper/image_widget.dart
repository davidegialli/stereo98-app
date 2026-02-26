import 'package:flutter/material.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/strings.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Dimensione responsiva: usa il lato più corto per non schiacciarsi in landscape
    final size = MediaQuery.of(context).size;
    final logoSize = (size.shortestSide * 0.3).clamp(80.0, 150.0);

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
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
