import 'package:flutter/material.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/dimsensions.dart';
import 'package:stereo98/utils/size.dart';
import 'package:stereo98/utils/strings.dart';
import 'package:stereo98/widget_helper/image_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).cardColor,
              Theme.of(context).canvasColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: mainSpaceBet,
          children: [
            Container(),
            Column(
              crossAxisAlignment: crossCenter,
              children: const [ImageWidget()],
            ),
            Column(
              crossAxisAlignment: crossCenter,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.defaultPaddingSize,
                  ),
                  child: CircularProgressIndicator(
                    color: CustomColor.primaryColor,
                    backgroundColor: CustomColor.gray.withValues(alpha: 0.5),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Dimensions.defaultPaddingSize * 0.5),
                  child: const Text(
                    Strings.version,
                    style: TextStyle(
                      color: CustomColor.whiteColor,
                      fontSize: 10,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
