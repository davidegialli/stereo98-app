import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../utils/custom_color.dart';

class SondaggiScreen extends StatefulWidget {
  const SondaggiScreen({super.key});

  @override
  State<SondaggiScreen> createState() => _SondaggiScreenState();
}

class _SondaggiScreenState extends State<SondaggiScreen> {
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
          'Sondaggi',
          style: TextStyle(color: CustomColor.whiteColor),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://stereo98.com/sondaggi/'),
            ),
            initialSettings: InAppWebViewSettings(
              useWideViewPort: false,
              loadWithOverviewMode: true,
              supportZoom: true,
              builtInZoomControls: false,
            ),
            onWebViewCreated: (InAppWebViewController controller) {},
            onLoadStart: (InAppWebViewController controller, Uri? url) {
              setState(() { isLoading = true; });
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) async {
              // ✅ Forza il contenuto a stare dentro lo schermo
              await controller.evaluateJavascript(source: '''
                var style = document.createElement('style');
                style.textContent = '* { max-width: 100vw !important; box-sizing: border-box !important; } html, body { overflow-x: hidden !important; width: 100% !important; }';
                document.head.appendChild(style);
                
                var meta = document.querySelector('meta[name="viewport"]');
                if (meta) {
                  meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=3.0';
                } else {
                  meta = document.createElement('meta');
                  meta.name = 'viewport';
                  meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=3.0';
                  document.head.appendChild(meta);
                }
              ''');
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
