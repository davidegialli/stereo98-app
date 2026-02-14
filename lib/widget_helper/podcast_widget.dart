import 'package:flutter/material.dart';
import '../utils/custom_color.dart';
import '../utils/dimsensions.dart';
import '../utils/size.dart';

class VideoListWidget extends StatelessWidget {
  const VideoListWidget({
    super.key,
    required this.path,
    required this.title,
    required this.boxFit,
    this.child,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
  });

  final String path;
  final String title;
  final BoxFit boxFit;
  final double? width;
  final double? height;
  final Widget? child;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: crossStart,
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.24,
            width: MediaQuery.sizeOf(context).width,
            margin: const EdgeInsets.only(
              bottom: 4,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: borderRadius ??
                  BorderRadius.circular(Dimensions.radius * 1.5),
              image: DecorationImage(
                image: AssetImage(
                  path,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              title,
              style: TextStyle(
                color: CustomColor.primaryBackgroundColor,
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.aboutTitleTextSize * 1.4,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
