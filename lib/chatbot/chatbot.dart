import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/responsive_layout.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  InAppWebViewController? _controller;
  bool _isLoading = true;

  final String chatbotUrl =

      'https://chatgpt.com/g/g-691e9e9922548191b8a2a50e33645eae-m-health';

  bool _isGoogleOAuthUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('accounts.google.com') ||
        u.contains('oauth2') ||
        u.contains('signin') ||
        u.contains('gsi') ||
        u.contains('googleusercontent');
  }

  Future<void> _openExternally(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "mHealth"),


      bottomNavigationBar: const BottomNavBar(currentIndex: 1),

      // ✅ RESPONSIVE LAYOUT WRAPPER
      body: ResponsiveLayout(
        child: Stack(
          children: [
            if (kIsWeb)
              const Center(
                child: Text(
                  'Iframe rendering handled automatically for Web build.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(chatbotUrl)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  thirdPartyCookiesEnabled: true,
                  useHybridComposition: true,
                  supportZoom: true,
                  supportMultipleWindows: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  mediaPlaybackRequiresUserGesture: false,
                  clearCache: false,
                ),

                onWebViewCreated: (controller) => _controller = controller,

                shouldOverrideUrlLoading:
                    (controller, navigationAction) async {
                  final url = navigationAction.request.url?.toString() ?? '';
                  if (url.isEmpty) {
                    return NavigationActionPolicy.ALLOW;
                  }

                  if (_isGoogleOAuthUrl(url)) {
                    await _openExternally(url);
                    return NavigationActionPolicy.CANCEL;
                  }

                  if (url.contains('disallowed_useragent')) {
                    await _openExternally(chatbotUrl);
                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },

                onCreateWindow: (controller, createWindowAction) async {
                  final url = createWindowAction.request.url?.toString();
                  if (url != null && _isGoogleOAuthUrl(url)) {
                    await _openExternally(url);
                    return true;
                  }
                  if (url != null) {
                    await _openExternally(url);
                    return true;
                  }
                  return false;
                },

                onLoadStart: (controller, url) {
                  setState(() => _isLoading = true);
                },

                onLoadStop: (controller, url) async {
                  setState(() => _isLoading = false);
                },

                onReceivedError: (controller, request, error) {
                  debugPrint('🌐 [InAppWebView] Error: ${error.description}');
                },
              ),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),


          ],
        ),

      ),
    );
  }
}