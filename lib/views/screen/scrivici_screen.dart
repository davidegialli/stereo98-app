import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../utils/custom_color.dart';

class ScriviciScreen extends StatefulWidget {
  const ScriviciScreen({super.key});

  @override
  State<ScriviciScreen> createState() => _ScriviciScreenState();
}

class _ScriviciScreenState extends State<ScriviciScreen> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: CustomColor.whiteColor,
          onPressed: () => Get.close(1),
        ),
        title: const Text(
          'Scrivici',
          style: TextStyle(color: CustomColor.whiteColor),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://stereo98.com/scrivici/'),
            ),
            onWebViewCreated: (InAppWebViewController controller) {},
            onLoadStart: (InAppWebViewController controller, Uri? url) {
              setState(() { isLoading = true; });
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) {
              setState(() { isLoading = false; });
            },
          ),
          Visibility(
            visible: isLoading,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFD85D9D)),
            ),
          ),
        ],
      ),
    );
  }
}
