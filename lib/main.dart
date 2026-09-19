import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MaterialApp(
    home: YoutubeAdblockScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class YoutubeAdblockScreen extends StatefulWidget {
  const YoutubeAdblockScreen({super.key});

  @override
  State<YoutubeAdblockScreen> createState() => _YoutubeAdblockScreenState();
}

class _YoutubeAdblockScreenState extends State<YoutubeAdblockScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.youtube.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}