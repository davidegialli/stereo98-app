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
  bool hasError = false;
  InAppWebViewController? _webController;

  void _reload() {
    setState(() { hasError = false; isLoading = true; });
    _webController?.loadUrl(
      urlRequest: URLRequest(url: WebUri('https://stereo98.com/scrivici/')),
    );
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _reload,
          ),
        ],
      ),
      body: Stack(
        children: [
          Visibility(
            visible: !hasError,
            maintainState: true,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://stereo98.com/scrivici/'),
              ),
              initialSettings: InAppWebViewSettings(
                useWideViewPort: false,
                loadWithOverviewMode: true,
                supportZoom: true,
                builtInZoomControls: false,
                javaScriptEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                thirdPartyCookiesEnabled: true,
                cacheEnabled: true,
                clearCache: false,
              ),
              onWebViewCreated: (controller) {
                _webController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() { isLoading = true; hasError = false; });
              },
              onLoadStop: (controller, url) async {
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
              onReceivedError: (controller, request, error) {
                if (request.url.toString().contains('stereo98.com/scrivici')) {
                  setState(() { isLoading = false; hasError = true; });
                }
              },
              onReceivedHttpError: (controller, request, response) {
                if (request.url.toString().contains('stereo98.com/scrivici') &&
                    response.statusCode != null && response.statusCode! >= 500) {
                  setState(() { isLoading = false; hasError = true; });
                }
              },
            ),
          ),

          if (hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white.withOpacity(0.3), size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Connessione non disponibile',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Controlla la tua connessione e riprova',
                    style: TextStyle(color: Colors.white30, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Riprova'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD85D9D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (isLoading && !hasError)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFD85D9D)),
            ),
        ],
      ),
    );
  }
}
