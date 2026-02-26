import 'package:flutter/material.dart';
import 'package:stereo98/utils/size.dart';
import 'package:url_launcher/url_launcher.dart';

class NetworkWidget extends StatelessWidget {
  const NetworkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainCenter,
      children: [
        GestureDetector(
          onTap: () {
            // ignore: deprecated_member_use
            launch('https://m.facebook.com/');
          },
          child: Image.asset(
            "assets/images/facebook.png",
            height: 50,
          ),
        ),
        addHorizontalSpace(22),
        GestureDetector(
          onTap: () {
            // ignore: deprecated_member_use
            launch('https://m.instagram.com/');
          },
          child: Image.asset(
            "assets/images/instagram.png",
            height: 50,
          ),
        ),
        addHorizontalSpace(22),
        GestureDetector(
          onTap: () {
            // ignore: deprecated_member_use
            launch('https://m.twitter.com/');
          },
          child: Image.asset(
            "assets/images/twitter.png",
            height: 50,
          ),
        ),
      ],
    );
  }
}
