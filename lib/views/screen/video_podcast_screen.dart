// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../utils/custom_color.dart';
import '../../utils/strings.dart';
import '../../widget_helper/video_player_view.dart';

class VideoPodcastScreen extends StatelessWidget {
  const VideoPodcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
           color: CustomColor.whiteColor,
          onPressed: (() {
            Get.close(1);
          }),
        ),
        title: Text(
          Strings.video.tr,
          style: const TextStyle(color: CustomColor.whiteColor),
        ),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).cardColor,
                Theme.of(context).canvasColor,
              ]),
        ),
        child:_bodyWidget(context),
     ) );
  }

  VideoPlayerView _bodyWidget(BuildContext context) {
    return const VideoPlayerView(
      url: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      dataSourceType: DataSourceType.network,
    );
  }
}
