import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('🌐 Initializing WebView for URL: ${widget.url}');
    try {
      controller =
          WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (url) {
                  print('🌐 WebView started loading: $url');
                  setState(() => isLoading = true);
                },
                onPageFinished: (url) {
                  print('🌐 WebView finished loading: $url');
                  setState(() => isLoading = false);
                },
                onWebResourceError: (WebResourceError error) {
                  print(
                    '❌ WebView error: ${error.description} (code: ${error.errorCode})',
                  );
                  setState(() {
                    isLoading = false;
                    errorMessage = error.description;
                  });
                },
              ),
            );

      // Load the URL with error handling
      controller.loadRequest(Uri.parse(widget.url)).catchError((e) {
        print('❌ Error loading WebView URL: $e');
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      });

      if (Platform.isAndroid) {
        controller.setBackgroundColor(Colors.white);
      }
    } catch (e) {
      print('❌ Error initializing WebView: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Stack(
        children: [
          if (errorMessage != null)
            Center(
              child: Text(
                'Error: $errorMessage',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          else
            WebViewWidget(controller: controller),
          if (isLoading && errorMessage == null)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
