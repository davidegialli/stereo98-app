import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../utils/custom_color.dart';

class IstruzioniScreen extends StatefulWidget {
  const IstruzioniScreen({super.key});

  @override
  State<IstruzioniScreen> createState() => _IstruzioniScreenState();
}

class _IstruzioniScreenState extends State<IstruzioniScreen> {
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
          'Come funziona',
          style: TextStyle(color: CustomColor.whiteColor),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://stereo98.com/istruzioni-uso-applicazione-stereo-98-dab-plus/'),
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
