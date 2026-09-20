import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouTube Lite',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const YoutubeLightScreen(),
    );
  }
}

class YoutubeLightScreen extends StatefulWidget {
  const YoutubeLightScreen({super.key});

  @override
  State<YoutubeLightScreen> createState() => _YoutubeLightScreenState();
}

class _YoutubeLightScreenState extends State<YoutubeLightScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  
  final List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            if (url.contains('/watch?')) {
              _controller.runJavaScriptReturningResult('document.title').then((title) {
                String cleanTitle = title.toString().replaceAll('"', '');
                if (!_history.any((item) => item['url'] == url)) {
                  setState(() {
                    _history.insert(0, {'title': cleanTitle, 'url': url});
                  });
                }
              });
            }

            // Script chặn triệt để banner quảng cáo và video quảng cáo
            _controller.runJavaScript('''
              (function() {
                var style = document.createElement('style');
                style.innerHTML = `
                  .video-ads, .ytp-ad-module, ytd-promoted-video-renderer, .ad-showing,
                  ytd-rich-item-renderer:has(span.ytd-badge-supported-renderer),
                  div[class*="promoted"], section[class*="promoted"],
                  c-wiz[data-is-sponsored], [aria-label*="Được tài trợ"], [aria-label*="Sponsored"] {
                    display: none !important;
                  }
                `;
                document.head.appendChild(style);

                setInterval(function() {
                  var skipBtn = document.querySelector('.ytp-ad-skip-button, .ytp-skip-ad-button, .ytp-ad-skip-button-modern');
                  if (skipBtn) { skipBtn.click(); }
                  
                  var videos = document.querySelectorAll('video');
                  videos.forEach(v => {
                    if (document.querySelector('.ad-showing')) {
                      v.playbackRate = 16.0;
                      v.currentTime = v.duration;
                    }
                  });
                }, 200);
              })();
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://m.youtube.com'));
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lịch sử video đã xem',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.grey),
              Expanded(
                child: _history.isEmpty
                    ? const Center(
                        child: Text('Chưa có video nào trong lịch sử', style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _history[index]['title'] ?? 'Video',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _controller.loadRequest(Uri.parse(_history[index]['url']!));
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _showHistoryModal,
            tooltip: 'Lịch sử xem',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}