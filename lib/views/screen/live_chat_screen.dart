import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../utils/custom_color.dart';
import '../../utils/strings.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Strings.liveChatWithRj.tr,
          style: const TextStyle(color: CustomColor.whiteColor),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(Strings.liveChatLink)),
            onWebViewCreated: (InAppWebViewController controller) {},
            onLoadStart: (InAppWebViewController controller, Uri? url) {
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) {
              // widget.onFinished!(url);
              setState(() {
                isLoading = false;
              });
            },
          ),
          Visibility(
            visible: isLoading,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
